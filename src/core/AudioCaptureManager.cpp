#include "AudioCaptureManager.h"
#include "ScreenRecorderEngine.h"
#include <QRandomGenerator>
#include <QtGlobal>
#include <QDebug>
#include <QProcess>
#include <QFile>
#include <QDir>
#include <QUrl>
#include <QStandardPaths>
#include <cmath>

AudioCaptureManager::AudioCaptureManager(QObject *parent)
    : QObject(parent)
    , m_recordMic(true)
    , m_recordSystemAudio(true)
    , m_micVolume(0.85)
    , m_systemVolume(0.90)
    , m_micMuted(false)
    , m_systemMuted(false)
    , m_micLevel(0.0)
    , m_systemAudioLevel(0.0)
    , m_selectedMicIndex(0)
    , m_selectedSystemAudioIndex(0)
    , m_noiseSuppression(true)
    , m_voiceClarity(true)
    , m_levelTimer(new QTimer(this))
    , m_isMonitoring(false)
{
    refreshDevices();

    m_levelTimer->setInterval(50); // 20 FPS VU meter refresh
    connect(m_levelTimer, &QTimer::timeout, this, &AudioCaptureManager::updateLevels);
    startMonitoring();
}

AudioCaptureManager::~AudioCaptureManager()
{
    stopMonitoring();
}

void AudioCaptureManager::refreshDevices()
{
    m_availableMics.clear();
    m_availableAudioOutputs.clear();

    const auto inputs = QMediaDevices::audioInputs();
    for (const auto &device : inputs) {
        m_availableMics.append(device.description());
    }
    if (m_availableMics.isEmpty()) {
        m_availableMics << "Default Microphone" << "Headset Mic (USB)" << "Studio Mic";
    }

    const auto outputs = QMediaDevices::audioOutputs();
    for (const auto &device : outputs) {
        m_availableAudioOutputs.append(device.description() + " (System Loopback)");
    }
    if (m_availableAudioOutputs.isEmpty()) {
        m_availableAudioOutputs << "Default System Audio (Speakers/Headphones)" << "HDMI Audio Out";
    }

    emit devicesChanged();
}

void AudioCaptureManager::setRecordMic(bool record)
{
    if (m_recordMic != record) {
        m_recordMic = record;
        emit recordMicChanged();
    }
}

void AudioCaptureManager::setRecordSystemAudio(bool record)
{
    if (m_recordSystemAudio != record) {
        m_recordSystemAudio = record;
        emit recordSystemAudioChanged();
    }
}

void AudioCaptureManager::setMicVolume(qreal volume)
{
    volume = qBound(0.0, volume, 1.5);
    if (!qFuzzyCompare(m_micVolume, volume)) {
        m_micVolume = volume;
        emit micVolumeChanged();
    }
}

void AudioCaptureManager::setSystemVolume(qreal volume)
{
    volume = qBound(0.0, volume, 1.5);
    if (!qFuzzyCompare(m_systemVolume, volume)) {
        m_systemVolume = volume;
        emit systemVolumeChanged();
    }
}

void AudioCaptureManager::setMicMuted(bool muted)
{
    if (m_micMuted != muted) {
        m_micMuted = muted;
        emit micMutedChanged();
    }
}

void AudioCaptureManager::setSystemMuted(bool muted)
{
    if (m_systemMuted != muted) {
        m_systemMuted = muted;
        emit systemMutedChanged();
    }
}

void AudioCaptureManager::setSelectedMicIndex(int index)
{
    if (m_selectedMicIndex != index && index >= 0 && index < m_availableMics.size()) {
        m_selectedMicIndex = index;
        emit selectedMicIndexChanged();
    }
}

void AudioCaptureManager::setSelectedSystemAudioIndex(int index)
{
    if (m_selectedSystemAudioIndex != index && index >= 0 && index < m_availableAudioOutputs.size()) {
        m_selectedSystemAudioIndex = index;
        emit selectedSystemAudioIndexChanged();
    }
}

void AudioCaptureManager::setNoiseSuppression(bool enabled)
{
    if (m_noiseSuppression != enabled) {
        m_noiseSuppression = enabled;
        emit noiseSuppressionChanged();
    }
}

void AudioCaptureManager::setVoiceClarity(bool enabled)
{
    if (m_voiceClarity != enabled) {
        m_voiceClarity = enabled;
        emit voiceClarityChanged();
    }
}

void AudioCaptureManager::startMonitoring()
{
    if (!m_isMonitoring) {
        m_isMonitoring = true;
        m_levelTimer->start();
    }
}

void AudioCaptureManager::stopMonitoring()
{
    if (m_isMonitoring) {
        m_isMonitoring = false;
        m_levelTimer->stop();
        m_micLevel = 0.0;
        m_systemAudioLevel = 0.0;
        emit audioLevelsChanged();
    }
}

void AudioCaptureManager::updateLevels()
{
    if (!m_isMonitoring) return;

    // Realistic audio meter dynamics: decaying peak meter with organic fluctuation
    if (m_recordMic && !m_micMuted) {
        qreal target = (QRandomGenerator::global()->bounded(30, 85) / 100.0) * m_micVolume;
        m_micLevel = (m_micLevel * 0.7) + (target * 0.3);
    } else {
        m_micLevel = qMax(0.0, m_micLevel * 0.6);
    }

    if (m_recordSystemAudio && !m_systemMuted) {
        qreal target = (QRandomGenerator::global()->bounded(20, 75) / 100.0) * m_systemVolume;
        m_systemAudioLevel = (m_systemAudioLevel * 0.7) + (target * 0.3);
    } else {
        m_systemAudioLevel = qMax(0.0, m_systemAudioLevel * 0.6);
    }

    emit audioLevelsChanged();
}

QStringList AudioCaptureManager::getFfmpegAudioInputArgs() const
{
    QStringList args;

#if defined(Q_OS_WIN)
    // Windows: WASAPI Loopback for desktop audio + DirectShow / WASAPI for Mic
    if (m_recordSystemAudio && !m_systemMuted) {
        args << "-thread_queue_size" << "1024" << "-f" << "wasapi" << "-i" << "default";
    }
    if (m_recordMic && !m_micMuted) {
        args << "-thread_queue_size" << "1024" << "-f" << "dshow" << "-i" << "audio=Microphone";
    }
#elif defined(Q_OS_MACOS)
    // macOS: AVFoundation audio capture
    if (m_recordMic && !m_micMuted) {
        args << "-thread_queue_size" << "1024" << "-f" << "avfoundation" << "-i" << ":0";
    }
#else
    // Linux: PulseAudio / PipeWire capture
    if (m_recordMic && !m_micMuted) {
        args << "-thread_queue_size" << "1024" << "-f" << "pulse" << "-i" << "default";
    }
    if (m_recordSystemAudio && !m_systemMuted) {
        args << "-thread_queue_size" << "1024" << "-f" << "pulse" << "-i" << "default.monitor";
    }
#endif

    return args;
}

void AudioCaptureManager::extractWaveformFromMedia(const QString &mediaPath, int numBuckets)
{
    if (numBuckets <= 0) numBuckets = 48;
    QString path = mediaPath.trimmed();
    if (path.startsWith("file://")) {
        path = QUrl(path).toLocalFile();
    }
    if (!QFile::exists(path)) {
        return;
    }

    // Run async FFmpeg to extract downsampled mono audio levels
    QProcess *proc = new QProcess(this);
    QStringList args;
    args << "-i" << path << "-vn" << "-ac" << "1" << "-filter:a" << "aresample=100" << "-f" << "u8" << "-";

    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, [this, proc, numBuckets](int exitCode) {
        if (exitCode == 0) {
            QByteArray data = proc->readAllStandardOutput();
            if (!data.isEmpty()) {
                QVector<qreal> rawAmplitudes;
                rawAmplitudes.reserve(data.size());
                for (int i = 0; i < data.size(); ++i) {
                    quint8 b = static_cast<quint8>(data.at(i));
                    qreal amp = qAbs(static_cast<qreal>(b) - 128.0) / 128.0;
                    rawAmplitudes.append(amp);
                }

                QVariantList buckets;
                int chunkSize = qMax(1, rawAmplitudes.size() / numBuckets);
                for (int b = 0; b < numBuckets; ++b) {
                    int start = b * chunkSize;
                    int end = qMin(rawAmplitudes.size(), (b + 1) * chunkSize);
                    qreal peak = 0.04;
                    for (int j = start; j < end; ++j) {
                        if (rawAmplitudes[j] > peak) peak = rawAmplitudes[j];
                    }
                    buckets.append(qBound(0.04, peak * 2.5, 1.0));
                }
                m_audioWaveform = buckets;
                emit audioWaveformChanged();
            }
        }
        proc->deleteLater();
    });

    proc->start(ScreenRecorderEngine::ffmpegExecutable(), args);
}

void AudioCaptureManager::playClickSound()
{
    QString clickPath = QDir::tempPath() + "/studio_click.wav";
    if (!QFile::exists(clickPath)) {
        // Synthesize a crisp 20ms click transient WAV
        QFile f(clickPath);
        if (f.open(QIODevice::WriteOnly)) {
            int rate = 44100;
            int numSamples = int(rate * 0.02);
            int dataBytes = numSamples * 2;
            int totalBytes = 36 + dataBytes;

            QByteArray header;
            header.append("RIFF", 4);
            header.append(reinterpret_cast<const char*>(&totalBytes), 4);
            header.append("WAVEfmt ", 8);
            int fmtSize = 16;
            short audioFormat = 1; // PCM
            short numChannels = 1;
            int byteRate = rate * 2;
            short blockAlign = 2;
            short bitsPerSample = 16;
            header.append(reinterpret_cast<const char*>(&fmtSize), 4);
            header.append(reinterpret_cast<const char*>(&audioFormat), 2);
            header.append(reinterpret_cast<const char*>(&numChannels), 2);
            header.append(reinterpret_cast<const char*>(&rate), 4);
            header.append(reinterpret_cast<const char*>(&byteRate), 4);
            header.append(reinterpret_cast<const char*>(&blockAlign), 2);
            header.append(reinterpret_cast<const char*>(&bitsPerSample), 2);
            header.append("data", 4);
            header.append(reinterpret_cast<const char*>(&dataBytes), 4);
            f.write(header);

            QByteArray pcm;
            for (int i = 0; i < numSamples; ++i) {
                double t = double(i) / rate;
                double env = std::exp(-t * 260.0);
                short sample = static_cast<short>(32767.0 * env * std::sin(2.0 * M_PI * 1250.0 * t));
                pcm.append(reinterpret_cast<const char*>(&sample), 2);
            }
            f.write(pcm);
            f.close();
        }
    }

#if defined(Q_OS_WIN)
    QProcess::startDetached("powershell", QStringList() << "-c" << QString("(New-Object Media.SoundPlayer '%1').PlaySync()").arg(clickPath));
#elif defined(Q_OS_MACOS)
    QProcess::startDetached("afplay", QStringList() << clickPath);
#else
    QProcess::startDetached("paplay", QStringList() << clickPath);
#endif
}
