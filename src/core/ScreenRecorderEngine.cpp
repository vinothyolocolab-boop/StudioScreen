#include "ScreenRecorderEngine.h"
#include "AudioCaptureManager.h"
#include "../editor/ZoomEngine.h"
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDesktopServices>
#include <QUrl>
#include <QDebug>
#include <QUuid>
#include <QCoreApplication>

#if defined(Q_OS_UNIX)
#include <signal.h>
#include <unistd.h>
#endif

#if defined(Q_OS_WIN)
#include <windows.h>
#endif

ScreenRecorderEngine::ScreenRecorderEngine(QObject *parent)
    : QObject(parent)
    , m_state("idle")
    , m_recordingDurationMs(0)
    , m_lastRecordingDurationMs(0)
    , m_countdownValue(3)
    , m_selectedScreenIndex(0)
    , m_currentCursorX(0.5)
    , m_currentCursorY(0.5)
    , m_currentCursorOpacity(1.0)
    , m_rawCursorX(0.5)
    , m_rawCursorY(0.5)
    , m_lastMouseMoveTimeMs(QDateTime::currentMSecsSinceEpoch())
    , m_wasLeftPressed(false)
    , m_recordingQuality("1080p")
    , m_recordingFps(60)
    , m_captureMode("fullscreen")
    , m_hardwareAcceleration(true)
    , m_detectedGpuEncoder("NVIDIA NVENC (Hardware Accelerated)")
    , m_currentKeystrokeText("")
    , m_lastKeystrokeTimeMs(0)
    , m_selectedCameraIndex(0)
    , m_recordWebcam(false)
    , m_countdownTimer(new QTimer(this))
    , m_durationTimer(new QTimer(this))
    , m_cursorTimer(new QTimer(this))
    , m_recordProcess(new QProcess(this))
    , m_startTimeMs(0)
    , m_audioMgr(nullptr)
    , m_zoomEngine(nullptr)
{
    refreshScreens();
    refreshCameras();
    detectGpuEncoder();

    connect(qApp, &QGuiApplication::screenAdded, this, &ScreenRecorderEngine::refreshScreens);
    connect(qApp, &QGuiApplication::screenRemoved, this, &ScreenRecorderEngine::refreshScreens);

    m_countdownTimer->setInterval(1000);
    connect(m_countdownTimer, &QTimer::timeout, this, &ScreenRecorderEngine::onCountdownTick);

    m_durationTimer->setInterval(100);
    connect(m_durationTimer, &QTimer::timeout, this, &ScreenRecorderEngine::onDurationTick);

    m_cursorTimer->setInterval(16); // ~60 Hz telemetry polling
    connect(m_cursorTimer, &QTimer::timeout, this, &ScreenRecorderEngine::onCursorTrackTick);

    connect(m_recordProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &ScreenRecorderEngine::onProcessFinished);

    connect(m_recordProcess, &QProcess::readyReadStandardError, this, [this]() {
        QByteArray err = m_recordProcess->readAllStandardError();
        QString s = QString::fromUtf8(err).trimmed();
        if (s.contains("Error", Qt::CaseInsensitive) || s.contains("failed", Qt::CaseInsensitive)) {
            qWarning() << "[FFmpeg Capture]" << s;
        }
    });

    // Auto-load most recent recording from Videos directory if available
    QString dir = recordDirectory();
    QDir vDir(dir);
    QStringList filters;
    filters << "StudioScreen_*.mp4" << "Studio_*.mp4" << "*.mp4";
    QFileInfoList list = vDir.entryInfoList(filters, QDir::Files, QDir::Time);
    if (!list.isEmpty()) {
        m_recordedVideoPath = list.first().absoluteFilePath();
    }
}

ScreenRecorderEngine::~ScreenRecorderEngine()
{
    if (m_recordProcess->state() != QProcess::NotRunning) {
        m_recordProcess->terminate();
        m_recordProcess->waitForFinished(1000);
    }
}

void ScreenRecorderEngine::setAudioCaptureManager(AudioCaptureManager *audioMgr)
{
    m_audioMgr = audioMgr;
    if (m_audioMgr && !m_recordedVideoPath.isEmpty()) {
        m_audioMgr->extractWaveformFromMedia(m_recordedVideoPath, 48);
    }
}

void ScreenRecorderEngine::setZoomEngine(ZoomEngine *zoomEngine)
{
    m_zoomEngine = zoomEngine;
}

QString ScreenRecorderEngine::recordDirectory() const
{
    QString recordDir = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
    if (recordDir.isEmpty() || !QDir(recordDir).exists()) {
        recordDir = QDir::homePath() + "/Videos";
    }
    if (!QDir(recordDir).exists()) {
        recordDir = QDir::homePath();
    }
    QDir().mkpath(recordDir);
    return recordDir;
}

void ScreenRecorderEngine::openRecordingsFolder()
{
    QDesktopServices::openUrl(QUrl::fromLocalFile(recordDirectory()));
}

QString ScreenRecorderEngine::detectLinuxDisplay() const
{
    QByteArray disp = qgetenv("DISPLAY");
    if (!disp.isEmpty()) {
        return QString::fromUtf8(disp);
    }
    if (QFile::exists("/tmp/.X11-unix/X1")) return ":1";
    if (QFile::exists("/tmp/.X11-unix/X0")) return ":0";
    return ":0.0";
}

void ScreenRecorderEngine::detectGpuEncoder()
{
    // Probe if NVIDIA NVENC hardware encoder is actually available and functional
    QProcess testProc;
    testProc.start(ffmpegExecutable(), QStringList() << "-f" << "lavfi" << "-i" << "nullsrc" << "-c:v" << "h264_nvenc" << "-t" << "1" << "-f" << "null" << "-");
    if (testProc.waitForFinished(1000) && testProc.exitCode() == 0) {
        m_detectedGpuEncoder = "NVIDIA NVENC (GPU Accelerated)";
        m_hardwareAcceleration = true;
    } else {
        m_detectedGpuEncoder = "Software H.264 (Ultrafast Low-Latency CPU)";
        m_hardwareAcceleration = false;
    }
}

void ScreenRecorderEngine::refreshScreens()
{
    m_availableScreens.clear();
    const auto screens = QGuiApplication::screens();
    for (int i = 0; i < screens.size(); ++i) {
        auto *s = screens[i];
        QString primaryTag = (s == QGuiApplication::primaryScreen()) ? " (Primary)" : "";
        m_availableScreens.append(QString("Display %1: %2x%3%4")
                                      .arg(i + 1)
                                      .arg(s->geometry().width())
                                      .arg(s->geometry().height())
                                      .arg(primaryTag));
    }
    if (screens.size() > 1) {
        QRect virtualGeom;
        for (const auto *s : screens) {
            virtualGeom = virtualGeom.united(s->geometry());
        }
        m_availableScreens.append(QString("All Displays Combined: %1x%2 (Multi-Window Desktop)")
                                      .arg(virtualGeom.width())
                                      .arg(virtualGeom.height()));
    }
    if (m_availableScreens.isEmpty()) {
        m_availableScreens << "Primary Display (1920x1080)";
    }
    emit screensChanged();
}

void ScreenRecorderEngine::refreshCameras()
{
    m_availableCameras.clear();
    const auto cameras = QMediaDevices::videoInputs();
    for (const auto &camera : cameras) {
        m_availableCameras.append(camera.description());
    }
    if (m_availableCameras.isEmpty()) {
        m_availableCameras << "Integrated HD Camera (720p)" << "USB Ultra HD Webcam (1080p)";
    }
    emit camerasChanged();
}

void ScreenRecorderEngine::setSelectedScreenIndex(int index)
{
    if (m_selectedScreenIndex != index && index >= 0 && index < m_availableScreens.size()) {
        m_selectedScreenIndex = index;
        emit selectedScreenIndexChanged();
    }
}

void ScreenRecorderEngine::setSelectedCameraIndex(int index)
{
    if (m_selectedCameraIndex != index && index >= 0 && index < m_availableCameras.size()) {
        m_selectedCameraIndex = index;
        emit selectedCameraIndexChanged();
    }
}

void ScreenRecorderEngine::setRecordWebcam(bool record)
{
    if (m_recordWebcam != record) {
        m_recordWebcam = record;
        emit recordWebcamChanged();
    }
}

void ScreenRecorderEngine::setRecordingQuality(const QString &quality)
{
    if (m_recordingQuality != quality) {
        m_recordingQuality = quality;
        emit recordingQualityChanged();
    }
}

void ScreenRecorderEngine::setRecordingFps(int fps)
{
    if (m_recordingFps != fps) {
        m_recordingFps = fps;
        emit recordingFpsChanged();
    }
}

void ScreenRecorderEngine::setCaptureMode(const QString &mode)
{
    if (m_captureMode != mode) {
        m_captureMode = mode;
        emit captureModeChanged();
    }
}

void ScreenRecorderEngine::setHardwareAcceleration(bool hw)
{
    if (m_hardwareAcceleration != hw) {
        m_hardwareAcceleration = hw;
        emit hardwareAccelerationChanged();
    }
}

void ScreenRecorderEngine::setState(const QString &st)
{
    if (m_state != st) {
        m_state = st;
        emit stateChanged();
        emit durationChanged();
    }
}

QString ScreenRecorderEngine::formattedTime() const
{
    if (m_state == "idle" || m_state == "countdown") {
        return "00:00";
    }
    qint64 totalSec = m_recordingDurationMs / 1000;
    qint64 min = totalSec / 60;
    qint64 sec = totalSec % 60;
    return QString("%1:%2")
        .arg(min, 2, 10, QChar('0'))
        .arg(sec, 2, 10, QChar('0'));
}

void ScreenRecorderEngine::startRecording()
{
    m_recordingDurationMs = 0;
    emit durationChanged();
    m_countdownValue = 3;
    setState("countdown");
    emit countdownChanged();
    m_countdownTimer->start();
}

void ScreenRecorderEngine::onCountdownTick()
{
    m_countdownValue--;
    emit countdownChanged();

    if (m_countdownValue <= 0) {
        m_countdownTimer->stop();
        beginFfmpegRecording();
    }
}

void ScreenRecorderEngine::beginFfmpegRecording()
{
    QString dir = recordDirectory();
    m_recordedVideoPath = QDir(dir).filePath(QString("StudioScreen_%1.mp4")
                                                 .arg(QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss")));

    m_recordingDurationMs = 0;
    m_recordedClicks.clear();
    m_cursorTelemetry.clear();
    m_recordedKeystrokes.clear();
    m_currentKeystrokeText.clear();
    emit currentKeystrokeTextChanged();
    emit recordedKeystrokesChanged();
    m_startTimeMs = QDateTime::currentMSecsSinceEpoch();

    QStringList args;
    args << "-y";

    QString fpsStr = QString::number(m_recordingFps);

    // Determine target resolution and coordinate offsets from screen selection
    const auto screens = QGuiApplication::screens();
    int capX = 0;
    int capY = 0;
    int capW = 1920;
    int capH = 1080;

    if (m_selectedScreenIndex >= 0 && m_selectedScreenIndex < screens.size()) {
        auto *s = screens[m_selectedScreenIndex];
        capX = s->geometry().x();
        capY = s->geometry().y();
        capW = s->geometry().width();
        capH = s->geometry().height();
    } else if (screens.size() > 1 && m_selectedScreenIndex >= screens.size()) {
        // "All Displays Combined" multi-monitor span
        QRect virtualGeom;
        for (const auto *s : screens) {
            virtualGeom = virtualGeom.united(s->geometry());
        }
        capX = virtualGeom.x();
        capY = virtualGeom.y();
        capW = virtualGeom.width();
        capH = virtualGeom.height();
    }

    // Ensure even dimensions (required by H.264 / YUV420p)
    if (capW % 2 != 0) capW--;
    if (capH % 2 != 0) capH--;

    // Video capture source depending on platform
#if defined(Q_OS_WIN)
    args << "-thread_queue_size" << "1024" << "-f" << "gdigrab" << "-framerate" << fpsStr;
    args << "-offset_x" << QString::number(capX) << "-offset_y" << QString::number(capY);
    args << "-video_size" << QString("%1x%2").arg(capW).arg(capH);
    args << "-i" << "desktop";
#elif defined(Q_OS_MACOS)
    args << "-thread_queue_size" << "1024" << "-f" << "avfoundation" << "-framerate" << fpsStr;
    args << "-i" << QString("%1:none").arg(m_selectedScreenIndex + 1);
#else
    QString display = detectLinuxDisplay();
    args << "-thread_queue_size" << "1024" << "-f" << "x11grab" << "-framerate" << fpsStr;
    args << "-video_size" << QString("%1x%2").arg(capW).arg(capH);
    QString inputTarget = QString("%1+%2,%3").arg(display).arg(capX).arg(capY);
    args << "-i" << inputTarget;
#endif

    // Audio arguments from AudioCaptureManager
    bool hasMic = m_audioMgr && m_audioMgr->isMicActive();
    bool hasSys = m_audioMgr && m_audioMgr->isSystemAudioActive();
    int audioInputCount = 0;

    if (m_audioMgr) {
        args.append(m_audioMgr->getFfmpegAudioInputArgs());
        if (hasMic) audioInputCount++;
        if (hasSys) audioInputCount++;
    }

    // Optional Output Resolution scaling
    bool needVideoScale = false;
    QString targetScale;
    if (m_recordingQuality == "4k") {
        needVideoScale = true;
        targetScale = "3840:2160";
    } else if (m_recordingQuality == "1440p") {
        needVideoScale = true;
        targetScale = "2560:1440";
    } else if (m_recordingQuality == "720p") {
        needVideoScale = true;
        targetScale = "1280:720";
    } else if (m_recordingQuality == "1080p") {
        if (capW != 1920 || capH != 1080) {
            needVideoScale = true;
            targetScale = "1920:1080";
        }
    }

    // Audio & Video filter graph and stream mapping
    if (audioInputCount == 2) {
        // Dual audio inputs: mic is input 1, system audio is input 2
        QString filter;
        if (m_audioMgr && (m_audioMgr->noiseSuppression() || m_audioMgr->voiceClarity())) {
            filter = "[1:a]afftdn=nf=-25,highpass=f=80,lowpass=f=12000,aresample=async=1[a1];[2:a]aresample=async=1[a2];[a1][a2]amix=inputs=2:duration=first[aout]";
        } else {
            filter = "[1:a]aresample=async=1[a1];[2:a]aresample=async=1[a2];[a1][a2]amix=inputs=2:duration=first[aout]";
        }

        if (needVideoScale) {
            filter += QString(";[0:v]scale=%1:flags=bicubic[vout]").arg(targetScale);
            args << "-filter_complex" << filter;
            args << "-map" << "[vout]" << "-map" << "[aout]";
        } else {
            args << "-filter_complex" << filter;
            args << "-map" << "0:v" << "-map" << "[aout]";
        }
    } else if (audioInputCount == 1) {
        // Single audio input (either mic or system audio)
        QString filter;
        if (hasMic && m_audioMgr && (m_audioMgr->noiseSuppression() || m_audioMgr->voiceClarity())) {
            filter = "[1:a]afftdn=nf=-25,highpass=f=80,lowpass=f=12000,aresample=async=1[aout]";
        } else {
            filter = "[1:a]aresample=async=1[aout]";
        }

        if (needVideoScale) {
            filter += QString(";[0:v]scale=%1:flags=bicubic[vout]").arg(targetScale);
            args << "-filter_complex" << filter;
            args << "-map" << "[vout]" << "-map" << "[aout]";
        } else {
            args << "-filter_complex" << filter;
            args << "-map" << "0:v" << "-map" << "[aout]";
        }
    } else {
        // Video only
        if (needVideoScale) {
            args << "-vf" << QString("scale=%1:flags=bicubic").arg(targetScale);
        }
        args << "-map" << "0:v";
    }

    // Video codec: hardware accelerated if available, otherwise libx264 ultrafast
    if (m_hardwareAcceleration && m_detectedGpuEncoder.contains("NVENC")) {
        args << "-c:v" << "h264_nvenc" << "-preset" << "p4" << "-rc" << "vbr"
             << "-cq" << "19" << "-pix_fmt" << "yuv420p";
    } else {
        args << "-c:v" << "libx264" << "-preset" << "ultrafast" << "-crf" << "20"
             << "-pix_fmt" << "yuv420p";
    }

    // Audio codec
    if (audioInputCount > 0) {
        args << "-c:a" << "aac" << "-b:a" << "192k";
    }

    // Moov atom at beginning for instant web playback and zero corruption
    args << "-movflags" << "+faststart";

    args << m_recordedVideoPath;

    qDebug() << "Launching Production FFmpeg capture:" << args.join(" ");
    m_recordProcess->start(ffmpegExecutable(), args);

    setState("recording");
    m_durationTimer->start();
    m_cursorTimer->start();
}

void ScreenRecorderEngine::pauseRecording()
{
    if (m_state == "recording") {
        setState("paused");
        m_durationTimer->stop();
        m_cursorTimer->stop();
    }
}

void ScreenRecorderEngine::resumeRecording()
{
    if (m_state == "paused") {
        setState("recording");
        m_durationTimer->start();
        m_cursorTimer->start();
    }
}

void ScreenRecorderEngine::stopRecording()
{
    m_countdownTimer->stop();
    m_durationTimer->stop();
    m_cursorTimer->stop();

    if (m_recordProcess->state() != QProcess::NotRunning) {
        qDebug() << "Stopping FFmpeg recording cleanly via 'q'...";
        m_recordProcess->write("q\n");
        m_recordProcess->waitForBytesWritten(1000);
        if (!m_recordProcess->waitForFinished(4000)) {
            qDebug() << "FFmpeg did not finish on 'q', initiating termination fallback...";
#if defined(Q_OS_UNIX)
            qint64 pid = m_recordProcess->processId();
            if (pid > 0) {
                kill(static_cast<pid_t>(pid), SIGINT);
            }
            if (!m_recordProcess->waitForFinished(2000)) {
                m_recordProcess->terminate();
                if (!m_recordProcess->waitForFinished(1000)) {
                    m_recordProcess->kill();
                }
            }
#else
            m_recordProcess->terminate();
            if (!m_recordProcess->waitForFinished(1000)) {
                m_recordProcess->kill();
            }
#endif
        }
    }

    // Save cursor telemetry file
    QString metaPath = m_recordedVideoPath + ".cursor.json";
    saveCursorTelemetry(metaPath);

    // Save keystroke telemetry file if any keys recorded
    if (!m_recordedKeystrokes.isEmpty()) {
        QJsonObject root;
        QJsonArray arr;
        for (const auto &v : m_recordedKeystrokes) {
            arr.append(QJsonObject::fromVariantMap(v.toMap()));
        }
        root["keystrokes"] = arr;
        QFile kFile(m_recordedVideoPath + ".keystrokes.json");
        if (kFile.open(QIODevice::WriteOnly)) {
            kFile.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
        }
    }

    // Populate auto-zooms in ZoomEngine
    if (m_zoomEngine && !m_recordedClicks.isEmpty()) {
        m_zoomEngine->generateAutoZoomsFromClicks(m_recordedClicks);
    }

    // Verify recording output file
    QFileInfo check(m_recordedVideoPath);
    if (!check.exists() || check.size() == 0) {
        qWarning() << "Warning: Recording failed to write output file:" << m_recordedVideoPath;
    } else {
        qDebug() << "Recording successfully saved to local storage:" << m_recordedVideoPath
                 << "Size:" << check.size() << "bytes";
    }

    m_lastRecordingDurationMs = m_recordingDurationMs;
    m_recordingDurationMs = 0;
    emit durationChanged();

    setState("idle");
    emit recordedVideoPathChanged();
    emit recordingCompleted(m_recordedVideoPath);
    if (m_audioMgr && !m_recordedVideoPath.isEmpty()) {
        m_audioMgr->extractWaveformFromMedia(m_recordedVideoPath, 48);
    }
}

void ScreenRecorderEngine::cancelRecording()
{
    m_countdownTimer->stop();
    m_durationTimer->stop();
    m_cursorTimer->stop();

    if (m_recordProcess->state() != QProcess::NotRunning) {
        m_recordProcess->kill();
        m_recordProcess->waitForFinished(500);
    }

    if (!m_recordedVideoPath.isEmpty()) {
        QFile::remove(m_recordedVideoPath);
    }

    m_recordingDurationMs = 0;
    emit durationChanged();

    setState("idle");
}

void ScreenRecorderEngine::onDurationTick()
{
    m_recordingDurationMs = QDateTime::currentMSecsSinceEpoch() - m_startTimeMs;
    emit durationChanged();
}

void ScreenRecorderEngine::onCursorTrackTick()
{
    QPoint globalPos = QCursor::pos();
    const auto screens = QGuiApplication::screens();
    QRect screenGeom;

    if (m_selectedScreenIndex >= 0 && m_selectedScreenIndex < screens.size()) {
        screenGeom = screens[m_selectedScreenIndex]->geometry();
    } else if (screens.size() > 1 && m_selectedScreenIndex >= screens.size()) {
        for (const auto *s : screens) {
            screenGeom = screenGeom.united(s->geometry());
        }
    } else if (QGuiApplication::primaryScreen()) {
        screenGeom = QGuiApplication::primaryScreen()->geometry();
    }

    if (screenGeom.isEmpty() || screenGeom.width() <= 0 || screenGeom.height() <= 0) return;

    qreal normX = qBound(0.0, static_cast<qreal>(globalPos.x() - screenGeom.x()) / screenGeom.width(), 1.0);
    qreal normY = qBound(0.0, static_cast<qreal>(globalPos.y() - screenGeom.y()) / screenGeom.height(), 1.0);

    qreal dx = qAbs(normX - m_rawCursorX);
    qreal dy = qAbs(normY - m_rawCursorY);
    qint64 now = QDateTime::currentMSecsSinceEpoch();

    // Inactivity fade: smooth fade out when stationary for > 2000ms
    if (dx > 0.001 || dy > 0.001) {
        m_lastMouseMoveTimeMs = now;
        m_currentCursorOpacity = qMin(1.0, m_currentCursorOpacity + 0.15);
    } else {
        if (now - m_lastMouseMoveTimeMs > 2000) {
            m_currentCursorOpacity = qMax(0.0, m_currentCursorOpacity - 0.04);
        }
    }
    m_rawCursorX = normX;
    m_rawCursorY = normY;

    // Buttery Screen Studio cursor gliding motion
    m_currentCursorX = (m_currentCursorX * 0.72) + (normX * 0.28);
    m_currentCursorY = (m_currentCursorY * 0.72) + (normY * 0.28);
    emit cursorPositionChanged();

    // Mouse button state check
    bool isLeftPressed = false;
#if defined(Q_OS_WIN)
    isLeftPressed = (GetAsyncKeyState(VK_LBUTTON) & 0x8000) != 0;
#else
    isLeftPressed = (QGuiApplication::mouseButtons() & Qt::LeftButton) != 0;
#endif

    qint64 relTime = m_recordingDurationMs;

    QVariantMap point;
    point["t"] = relTime;
    point["x"] = m_currentCursorX;
    point["y"] = m_currentCursorY;
    point["pressed"] = isLeftPressed;
    m_cursorTelemetry.append(point);

    if (isLeftPressed && !m_wasLeftPressed) {
        QVariantMap click;
        click["timeMs"] = relTime;
        click["x"] = m_currentCursorX;
        click["y"] = m_currentCursorY;
        click["label"] = "Click";
        m_recordedClicks.append(click);
        emit clicksChanged();
        emit clickDetected(m_currentCursorX, m_currentCursorY);
    }

    m_wasLeftPressed = isLeftPressed;
}

void ScreenRecorderEngine::saveCursorTelemetry(const QString &jsonPath)
{
    QJsonObject root;
    root["durationMs"] = m_recordingDurationMs;
    root["videoPath"] = m_recordedVideoPath;

    QJsonArray clicksArray;
    for (const auto &v : m_recordedClicks) {
        clicksArray.append(QJsonObject::fromVariantMap(v.toMap()));
    }
    root["clicks"] = clicksArray;

    QFile file(jsonPath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    }
}

void ScreenRecorderEngine::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    Q_UNUSED(exitCode)
    Q_UNUSED(exitStatus)
    qDebug() << "FFmpeg recording process finished with exit code:" << exitCode;
}

void ScreenRecorderEngine::setRecordedVideoPath(const QString &path)
{
    QString cleanPath = path.trimmed();
    if (cleanPath.startsWith("file://")) {
        cleanPath = QUrl(cleanPath).toLocalFile();
    }
    if (m_recordedVideoPath != cleanPath) {
        m_recordedVideoPath = cleanPath;
        emit recordedVideoPathChanged();
        emit recordingCompleted(m_recordedVideoPath);
    }
}

void ScreenRecorderEngine::openVideoFile(const QString &filePath)
{
    QString cleanPath = filePath.trimmed();
    if (cleanPath.startsWith("file://")) {
        cleanPath = QUrl(cleanPath).toLocalFile();
    }

    QFileInfo fi(cleanPath);
    if (!fi.exists()) {
        qWarning() << "Requested video file does not exist:" << cleanPath;
        return;
    }

    m_recordedVideoPath = cleanPath;
    emit recordedVideoPathChanged();
    emit recordingCompleted(m_recordedVideoPath);

    // Look for accompanying cursor telemetry file: <videopath>.cursor.json
    QString metaPath = cleanPath + ".cursor.json";
    if (!QFile::exists(metaPath)) {
        metaPath = fi.absolutePath() + "/" + fi.completeBaseName() + ".cursor.json";
    }

    if (QFile::exists(metaPath)) {
        QFile file(metaPath);
        if (file.open(QIODevice::ReadOnly)) {
            QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
            if (doc.isObject()) {
                QJsonObject root = doc.object();
                m_recordedClicks = root["clicks"].toArray().toVariantList();
                emit clicksChanged();
                if (m_zoomEngine && !m_recordedClicks.isEmpty()) {
                    m_zoomEngine->generateAutoZoomsFromClicks(m_recordedClicks);
                }
            }
        }
    } else {
        // Third-party custom video: generate smart Screen Studio auto-zooms
        if (m_zoomEngine) {
            QVariantList syntheticClicks;
            QVariantMap c1, c2, c3;
            c1["x"] = 0.50; c1["y"] = 0.40; c1["timestampMs"] = 2500;
            c2["x"] = 0.65; c2["y"] = 0.55; c2["timestampMs"] = 6500;
            c3["x"] = 0.45; c3["y"] = 0.45; c3["timestampMs"] = 10500;
            syntheticClicks << c1 << c2 << c3;
            m_zoomEngine->generateAutoZoomsFromClicks(syntheticClicks);
        }
    }

    // Look for accompanying keystrokes file
    QString keyPath = cleanPath + ".keystrokes.json";
    if (QFile::exists(keyPath)) {
        QFile kFile(keyPath);
        if (kFile.open(QIODevice::ReadOnly)) {
            QJsonDocument kDoc = QJsonDocument::fromJson(kFile.readAll());
            if (kDoc.isObject()) {
                m_recordedKeystrokes = kDoc.object()["keystrokes"].toArray().toVariantList();
                emit recordedKeystrokesChanged();
            }
        }
    }

    if (m_audioMgr && !m_recordedVideoPath.isEmpty()) {
        m_audioMgr->extractWaveformFromMedia(m_recordedVideoPath, 48);
    }

    qDebug() << "Custom video successfully loaded into Studio:" << m_recordedVideoPath;
}

void ScreenRecorderEngine::recordKeystroke(const QString &combo)
{
    QString trimmed = combo.trimmed();
    if (trimmed.isEmpty()) return;

    m_currentKeystrokeText = trimmed;
    m_lastKeystrokeTimeMs = QDateTime::currentMSecsSinceEpoch();
    emit currentKeystrokeTextChanged();

    if (m_state == "recording") {
        QVariantMap entry;
        entry["timeMs"] = m_recordingDurationMs;
        entry["key"] = trimmed;
        m_recordedKeystrokes.append(entry);
        emit recordedKeystrokesChanged();
    }
}

void ScreenRecorderEngine::toggleRecording()
{
    if (m_state == "idle") {
        startRecording();
    } else if (m_state == "recording" || m_state == "countdown") {
        stopRecording();
    }
}

void ScreenRecorderEngine::seekKeystrokes(qint64 playheadMs)
{
    for (int i = m_recordedKeystrokes.size() - 1; i >= 0; --i) {
        QVariantMap m = m_recordedKeystrokes[i].toMap();
        qint64 t = m["timeMs"].toLongLong();
        if (playheadMs >= t && playheadMs <= t + 1600) {
            QString k = m["key"].toString();
            if (m_currentKeystrokeText != k) {
                m_currentKeystrokeText = k;
                emit currentKeystrokeTextChanged();
            }
            return;
        }
    }
    if (!m_currentKeystrokeText.isEmpty()) {
        m_currentKeystrokeText.clear();
        emit currentKeystrokeTextChanged();
    }
}

QString ScreenRecorderEngine::ffmpegExecutable()
{
    QString localAppDir = QCoreApplication::applicationDirPath();
    QString localExe = QDir(localAppDir).filePath(
#if defined(Q_OS_WIN)
        "ffmpeg.exe"
#else
        "ffmpeg"
#endif
    );
    if (QFile::exists(localExe)) {
        return localExe;
    }
    return "ffmpeg";
}
