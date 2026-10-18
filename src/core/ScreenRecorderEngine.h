#ifndef SCREENRECORDERENGINE_H
#define SCREENRECORDERENGINE_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QTimer>
#include <QProcess>
#include <QGuiApplication>
#include <QScreen>
#include <QCursor>
#include <QDateTime>
#include <QMediaDevices>
#include <QCameraDevice>

class AudioCaptureManager;
class ZoomEngine;

class ScreenRecorderEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString state READ state NOTIFY stateChanged)
    Q_PROPERTY(qint64 recordingDurationMs READ recordingDurationMs NOTIFY durationChanged)
    Q_PROPERTY(qint64 lastRecordingDurationMs READ lastRecordingDurationMs NOTIFY durationChanged)
    Q_PROPERTY(QString formattedTime READ formattedTime NOTIFY durationChanged)
    Q_PROPERTY(int countdownValue READ countdownValue NOTIFY countdownChanged)
    Q_PROPERTY(QStringList availableScreens READ availableScreens NOTIFY screensChanged)
    Q_PROPERTY(int selectedScreenIndex READ selectedScreenIndex WRITE setSelectedScreenIndex NOTIFY selectedScreenIndexChanged)
    Q_PROPERTY(QString recordedVideoPath READ recordedVideoPath WRITE setRecordedVideoPath NOTIFY recordedVideoPathChanged)
    Q_PROPERTY(QString recordDirectory READ recordDirectory CONSTANT)
    Q_PROPERTY(QVariantList recordedClicks READ recordedClicks NOTIFY clicksChanged)
    
    // Smooth cinematic cursor positioning & inactivity fading
    Q_PROPERTY(qreal currentCursorX READ currentCursorX NOTIFY cursorPositionChanged)
    Q_PROPERTY(qreal currentCursorY READ currentCursorY NOTIFY cursorPositionChanged)
    Q_PROPERTY(qreal currentCursorOpacity READ currentCursorOpacity NOTIFY cursorPositionChanged)

    // Advanced Production Recording Options
    Q_PROPERTY(QString recordingQuality READ recordingQuality WRITE setRecordingQuality NOTIFY recordingQualityChanged)
    Q_PROPERTY(int recordingFps READ recordingFps WRITE setRecordingFps NOTIFY recordingFpsChanged)
    Q_PROPERTY(QString captureMode READ captureMode WRITE setCaptureMode NOTIFY captureModeChanged)
    Q_PROPERTY(bool hardwareAcceleration READ hardwareAcceleration WRITE setHardwareAcceleration NOTIFY hardwareAccelerationChanged)
    Q_PROPERTY(QString detectedGpuEncoder READ detectedGpuEncoder CONSTANT)

    // Facecam / Webcam Hardware Integration
    Q_PROPERTY(QStringList availableCameras READ availableCameras NOTIFY camerasChanged)
    Q_PROPERTY(int selectedCameraIndex READ selectedCameraIndex WRITE setSelectedCameraIndex NOTIFY selectedCameraIndexChanged)
    Q_PROPERTY(bool recordWebcam READ recordWebcam WRITE setRecordWebcam NOTIFY recordWebcamChanged)
    Q_PROPERTY(QString currentKeystrokeText READ currentKeystrokeText NOTIFY currentKeystrokeTextChanged)
    Q_PROPERTY(QVariantList recordedKeystrokes READ recordedKeystrokes NOTIFY recordedKeystrokesChanged)

public:
    explicit ScreenRecorderEngine(QObject *parent = nullptr);
    ~ScreenRecorderEngine() override;

    QString state() const { return m_state; }
    qint64 recordingDurationMs() const { return m_recordingDurationMs; }
    qint64 lastRecordingDurationMs() const { return m_lastRecordingDurationMs; }
    QString formattedTime() const;
    int countdownValue() const { return m_countdownValue; }
    QStringList availableScreens() const { return m_availableScreens; }
    int selectedScreenIndex() const { return m_selectedScreenIndex; }
    QString recordedVideoPath() const { return m_recordedVideoPath; }
    QString recordDirectory() const;
    QVariantList recordedClicks() const { return m_recordedClicks; }
    
    qreal currentCursorX() const { return m_currentCursorX; }
    qreal currentCursorY() const { return m_currentCursorY; }
    qreal currentCursorOpacity() const { return m_currentCursorOpacity; }
    QString currentKeystrokeText() const { return m_currentKeystrokeText; }
    QVariantList recordedKeystrokes() const { return m_recordedKeystrokes; }

    QString recordingQuality() const { return m_recordingQuality; }
    int recordingFps() const { return m_recordingFps; }
    QString captureMode() const { return m_captureMode; }
    bool hardwareAcceleration() const { return m_hardwareAcceleration; }
    QString detectedGpuEncoder() const { return m_detectedGpuEncoder; }

    QStringList availableCameras() const { return m_availableCameras; }
    int selectedCameraIndex() const { return m_selectedCameraIndex; }
    bool recordWebcam() const { return m_recordWebcam; }

    void setSelectedScreenIndex(int index);
    void setRecordingQuality(const QString &quality);
    void setRecordingFps(int fps);
    void setCaptureMode(const QString &mode);
    void setHardwareAcceleration(bool hw);
    void setSelectedCameraIndex(int index);
    void setRecordWebcam(bool record);

    void setAudioCaptureManager(AudioCaptureManager *audioMgr);
    void setZoomEngine(ZoomEngine *zoomEngine);

    // Q_INVOKABLE methods for reliable QML binding
    Q_INVOKABLE void startRecording();
    Q_INVOKABLE void pauseRecording();
    Q_INVOKABLE void resumeRecording();
    Q_INVOKABLE void stopRecording();
    Q_INVOKABLE void cancelRecording();
    Q_INVOKABLE void refreshScreens();
    Q_INVOKABLE void refreshCameras();
    Q_INVOKABLE void openRecordingsFolder();
    Q_INVOKABLE void openVideoFile(const QString &filePath);
    Q_INVOKABLE void setRecordedVideoPath(const QString &path);
    Q_INVOKABLE void recordKeystroke(const QString &combo);
    Q_INVOKABLE void toggleRecording();
    Q_INVOKABLE void seekKeystrokes(qint64 playheadMs);

    static QString ffmpegExecutable();

signals:
    void stateChanged();
    void durationChanged();
    void countdownChanged();
    void screensChanged();
    void camerasChanged();
    void selectedScreenIndexChanged();
    void selectedCameraIndexChanged();
    void recordWebcamChanged();
    void recordedVideoPathChanged();
    void recordingCompleted(const QString &filePath);
    void clicksChanged();
    void cursorPositionChanged();
    void clickDetected(qreal x, qreal y);
    void recordingQualityChanged();
    void recordingFpsChanged();
    void captureModeChanged();
    void hardwareAccelerationChanged();
    void currentKeystrokeTextChanged();
    void recordedKeystrokesChanged();

private slots:
    void onCountdownTick();
    void onDurationTick();
    void onCursorTrackTick();
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    void setState(const QString &st);
    void beginFfmpegRecording();
    void saveCursorTelemetry(const QString &jsonPath);
    QString detectLinuxDisplay() const;
    void detectGpuEncoder();

    QString m_state;
    qint64 m_recordingDurationMs;
    qint64 m_lastRecordingDurationMs;
    int m_countdownValue;
    QStringList m_availableScreens;
    int m_selectedScreenIndex;
    QString m_recordedVideoPath;
    QVariantList m_recordedClicks;
    QVariantList m_cursorTelemetry;
    QVariantList m_recordedKeystrokes;
    QString m_currentKeystrokeText;
    qint64 m_lastKeystrokeTimeMs;

    // Cursor smoothing & cinematic motion
    qreal m_currentCursorX;
    qreal m_currentCursorY;
    qreal m_currentCursorOpacity;
    qreal m_rawCursorX;
    qreal m_rawCursorY;
    qint64 m_lastMouseMoveTimeMs;
    bool m_wasLeftPressed;

    // Production settings
    QString m_recordingQuality;
    int m_recordingFps;
    QString m_captureMode;
    bool m_hardwareAcceleration;
    QString m_detectedGpuEncoder;

    // Facecam settings
    QStringList m_availableCameras;
    int m_selectedCameraIndex;
    bool m_recordWebcam;

    QTimer *m_countdownTimer;
    QTimer *m_durationTimer;
    QTimer *m_cursorTimer;
    QProcess *m_recordProcess;
    qint64 m_startTimeMs;

    AudioCaptureManager *m_audioMgr;
    ZoomEngine *m_zoomEngine;
};

#endif // SCREENRECORDERENGINE_H
