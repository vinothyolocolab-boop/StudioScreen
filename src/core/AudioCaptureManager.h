#ifndef AUDIOCAPTUREMANAGER_H
#define AUDIOCAPTUREMANAGER_H

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QTimer>
#include <QMediaDevices>
#include <QAudioDevice>

class AudioCaptureManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool recordMic READ recordMic WRITE setRecordMic NOTIFY recordMicChanged)
    Q_PROPERTY(bool recordSystemAudio READ recordSystemAudio WRITE setRecordSystemAudio NOTIFY recordSystemAudioChanged)
    Q_PROPERTY(qreal micVolume READ micVolume WRITE setMicVolume NOTIFY micVolumeChanged)
    Q_PROPERTY(qreal systemVolume READ systemVolume WRITE setSystemVolume NOTIFY systemVolumeChanged)
    Q_PROPERTY(bool micMuted READ micMuted WRITE setMicMuted NOTIFY micMutedChanged)
    Q_PROPERTY(bool systemMuted READ systemMuted WRITE setSystemMuted NOTIFY systemMutedChanged)
    Q_PROPERTY(qreal micLevel READ micLevel NOTIFY audioLevelsChanged)
    Q_PROPERTY(qreal systemAudioLevel READ systemAudioLevel NOTIFY audioLevelsChanged)
    Q_PROPERTY(QStringList availableMics READ availableMics NOTIFY devicesChanged)
    Q_PROPERTY(QStringList availableAudioOutputs READ availableAudioOutputs NOTIFY devicesChanged)
    Q_PROPERTY(int selectedMicIndex READ selectedMicIndex WRITE setSelectedMicIndex NOTIFY selectedMicIndexChanged)
    Q_PROPERTY(int selectedSystemAudioIndex READ selectedSystemAudioIndex WRITE setSelectedSystemAudioIndex NOTIFY selectedSystemAudioIndexChanged)
    Q_PROPERTY(bool noiseSuppression READ noiseSuppression WRITE setNoiseSuppression NOTIFY noiseSuppressionChanged)
    Q_PROPERTY(bool voiceClarity READ voiceClarity WRITE setVoiceClarity NOTIFY voiceClarityChanged)
    Q_PROPERTY(QVariantList audioWaveform READ audioWaveform NOTIFY audioWaveformChanged)

public:
    explicit AudioCaptureManager(QObject *parent = nullptr);
    ~AudioCaptureManager() override;

    bool recordMic() const { return m_recordMic; }
    bool recordSystemAudio() const { return m_recordSystemAudio; }
    qreal micVolume() const { return m_micVolume; }
    qreal systemVolume() const { return m_systemVolume; }
    bool micMuted() const { return m_micMuted; }
    bool systemMuted() const { return m_systemMuted; }
    qreal micLevel() const { return m_micLevel; }
    qreal systemAudioLevel() const { return m_systemAudioLevel; }
    QStringList availableMics() const { return m_availableMics; }
    QStringList availableAudioOutputs() const { return m_availableAudioOutputs; }
    int selectedMicIndex() const { return m_selectedMicIndex; }
    int selectedSystemAudioIndex() const { return m_selectedSystemAudioIndex; }

    bool noiseSuppression() const { return m_noiseSuppression; }
    bool voiceClarity() const { return m_voiceClarity; }
    QVariantList audioWaveform() const { return m_audioWaveform; }

    bool isMicActive() const { return m_recordMic && !m_micMuted; }
    bool isSystemAudioActive() const { return m_recordSystemAudio && !m_systemMuted; }

    void setRecordMic(bool record);
    void setRecordSystemAudio(bool record);
    void setMicVolume(qreal volume);
    void setSystemVolume(qreal volume);
    void setMicMuted(bool muted);
    void setSystemMuted(bool muted);
    void setSelectedMicIndex(int index);
    void setSelectedSystemAudioIndex(int index);
    void setNoiseSuppression(bool enabled);
    void setVoiceClarity(bool enabled);

    Q_INVOKABLE void refreshDevices();
    Q_INVOKABLE void startMonitoring();
    Q_INVOKABLE void stopMonitoring();
    Q_INVOKABLE void extractWaveformFromMedia(const QString &mediaPath, int numBuckets = 48);
    Q_INVOKABLE void playClickSound();
    
    // Generates platform-specific FFmpeg audio capture CLI args
    QStringList getFfmpegAudioInputArgs() const;

signals:
    void recordMicChanged();
    void recordSystemAudioChanged();
    void micVolumeChanged();
    void systemVolumeChanged();
    void micMutedChanged();
    void systemMutedChanged();
    void audioLevelsChanged();
    void devicesChanged();
    void selectedMicIndexChanged();
    void selectedSystemAudioIndexChanged();
    void noiseSuppressionChanged();
    void voiceClarityChanged();
    void audioWaveformChanged();

private slots:
    void updateLevels();

private:
    bool m_recordMic;
    bool m_recordSystemAudio;
    qreal m_micVolume;
    qreal m_systemVolume;
    bool m_micMuted;
    bool m_systemMuted;
    qreal m_micLevel;
    qreal m_systemAudioLevel;
    bool m_noiseSuppression;
    bool m_voiceClarity;
    QStringList m_availableMics;
    QStringList m_availableAudioOutputs;
    int m_selectedMicIndex;
    int m_selectedSystemAudioIndex;
    QTimer *m_levelTimer;
    bool m_isMonitoring;
    QVariantList m_audioWaveform;
};

#endif // AUDIOCAPTUREMANAGER_H
