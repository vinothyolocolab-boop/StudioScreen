#ifndef VIDEOEXPORTMANAGER_H
#define VIDEOEXPORTMANAGER_H

#include <QObject>
#include <QString>
#include <QProcess>
#include <QTimer>

class StudioSettings;
class ZoomEngine;
class SupabaseManager;

class VideoExportManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isExporting READ isExporting NOTIFY exportStateChanged)
    Q_PROPERTY(qreal exportProgress READ exportProgress NOTIFY exportProgressChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusChanged)
    Q_PROPERTY(QString lastExportedPath READ lastExportedPath NOTIFY exportFinished)

public:
    explicit VideoExportManager(QObject *parent = nullptr);
    ~VideoExportManager() override;

    bool isExporting() const { return m_isExporting; }
    qreal exportProgress() const { return m_exportProgress; }
    QString statusMessage() const { return m_statusMessage; }
    QString lastExportedPath() const { return m_lastExportedPath; }

    Q_INVOKABLE void exportVideo(const QString &inputVideoPath,
                                 StudioSettings *settings,
                                 ZoomEngine *zoomEngine,
                                 SupabaseManager *supabaseMgr = nullptr,
                                 bool autoUpload = false);
    Q_INVOKABLE void cancelExport();

signals:
    void exportStateChanged();
    void exportProgressChanged();
    void statusChanged();
    void exportFinished(const QString &outputPath);
    void exportFailed(const QString &error);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onSimulationTick();

private:
    void setStatus(const QString &msg);

    bool m_isExporting;
    qreal m_exportProgress;
    QString m_statusMessage;
    QString m_lastExportedPath;
    QProcess *m_exportProcess;
    QTimer *m_simTimer;
    SupabaseManager *m_pendingSupabase;
    bool m_autoUpload;
    QString m_exportTitle;
};

#endif // VIDEOEXPORTMANAGER_H
