#ifndef AIVIDEOCUSTOMIZER_H
#define AIVIDEOCUSTOMIZER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class StudioSettings;
class ZoomEngine;

struct SubtitleCue {
    int id;
    qint64 startMs;
    qint64 endMs;
    QString text;
    QString highlightedWord;
};

class AiVideoCustomizer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isProcessing READ isProcessing NOTIFY processingChanged)
    Q_PROPERTY(qreal aiProgress READ aiProgress NOTIFY progressChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusChanged)
    Q_PROPERTY(bool hasCaptions READ hasCaptions NOTIFY captionsChanged)
    Q_PROPERTY(QVariantList captions READ captionsAsVariant NOTIFY captionsChanged)
    Q_PROPERTY(QString currentSubtitleText READ currentSubtitleText NOTIFY currentSubtitleChanged)
    Q_PROPERTY(QString currentActiveWord READ currentActiveWord NOTIFY currentSubtitleChanged)
    Q_PROPERTY(int silenceCutsCount READ silenceCutsCount NOTIFY silenceCutsChanged)
    Q_PROPERTY(QVariantList silenceCuts READ silenceCutsAsVariant NOTIFY silenceCutsChanged)

public:
    explicit AiVideoCustomizer(QObject *parent = nullptr);
    ~AiVideoCustomizer() override = default;

    bool isProcessing() const { return m_isProcessing; }
    qreal aiProgress() const { return m_aiProgress; }
    QString statusMessage() const { return m_statusMessage; }
    bool hasCaptions() const { return !m_cues.isEmpty(); }
    QVariantList captionsAsVariant() const;
    QVariantList silenceCutsAsVariant() const;
    QString currentSubtitleText() const { return m_currentSubtitleText; }
    QString currentActiveWord() const { return m_currentActiveWord; }
    int silenceCutsCount() const { return m_silenceCuts.size(); }

    Q_INVOKABLE void generateCaptions(const QString &audioPath, qint64 totalDurationMs);
    Q_INVOKABLE void detectSilences(qint64 totalDurationMs, const QString &mediaPath = "");
    Q_INVOKABLE void autoTrimSilences(ZoomEngine *zoomEngine = nullptr);
    Q_INVOKABLE void applyAiPrompt(const QString &prompt, StudioSettings *settings, ZoomEngine *zoomEngine);
    Q_INVOKABLE void updatePlayhead(qint64 currentMs);
    Q_INVOKABLE void clearCaptions();

signals:
    void processingChanged();
    void progressChanged();
    void statusChanged();
    void captionsChanged();
    void currentSubtitleChanged();
    void silenceCutsChanged();
    void promptApplied(const QString &explanation);

private:
    void setStatus(const QString &msg);
    void simulateWhisperTranscription(qint64 totalDurationMs);

    bool m_isProcessing;
    qreal m_aiProgress;
    QString m_statusMessage;
    QVector<SubtitleCue> m_cues;
    QVector<QPair<qint64, qint64>> m_silenceCuts;
    QString m_currentSubtitleText;
    QString m_currentActiveWord;
    QNetworkAccessManager *m_network;
};

#endif // AIVIDEOCUSTOMIZER_H
