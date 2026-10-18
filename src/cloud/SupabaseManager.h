#ifndef SUPABASEMANAGER_H
#define SUPABASEMANAGER_H

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSettings>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QFileInfo>
#include <QClipboard>
#include <QGuiApplication>
#include <QHttpMultiPart>
#include <QHttpPart>

class ShareHttpServer;

class SupabaseManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isAuthenticated READ isAuthenticated NOTIFY authStateChanged)
    Q_PROPERTY(QString userEmail READ userEmail NOTIFY authStateChanged)
    Q_PROPERTY(QString supabaseUrl READ supabaseUrl WRITE setSupabaseUrl NOTIFY configChanged)
    Q_PROPERTY(QString anonKey READ anonKey WRITE setAnonKey NOTIFY configChanged)
    Q_PROPERTY(QString bucketName READ bucketName WRITE setBucketName NOTIFY configChanged)
    Q_PROPERTY(bool isUploading READ isUploading NOTIFY uploadStateChanged)
    Q_PROPERTY(qreal uploadProgress READ uploadProgress NOTIFY uploadProgressChanged)
    Q_PROPERTY(QString currentShareUrl READ currentShareUrl NOTIFY shareUrlChanged)
    Q_PROPERTY(QString localShareUrl READ localShareUrl NOTIFY shareUrlChanged)
    Q_PROPERTY(bool isCloudUrl READ isCloudUrl NOTIFY shareUrlChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusChanged)
    Q_PROPERTY(bool isDemoMode READ isDemoMode WRITE setDemoMode NOTIFY demoModeChanged)

public:
    explicit SupabaseManager(QObject *parent = nullptr);
    ~SupabaseManager() override = default;

    bool isAuthenticated() const { return m_isAuthenticated; }
    QString userEmail() const { return m_userEmail; }
    QString supabaseUrl() const { return m_supabaseUrl; }
    QString anonKey() const { return m_anonKey; }
    QString bucketName() const { return m_bucketName; }
    bool isUploading() const { return m_isUploading; }
    qreal uploadProgress() const { return m_uploadProgress; }
    QString currentShareUrl() const { return m_currentShareUrl; }
    QString localShareUrl() const;
    bool isCloudUrl() const {
        return m_currentShareUrl.startsWith("https://") ||
               (m_currentShareUrl.startsWith("http://") && !m_currentShareUrl.contains("localhost") && !m_currentShareUrl.contains("127.0.0.1") && !m_currentShareUrl.contains("192.168."));
    }
    QString statusMessage() const { return m_statusMessage; }
    bool isDemoMode() const { return m_isDemoMode; }

    void setSupabaseUrl(const QString &url);
    void setAnonKey(const QString &key);
    void setBucketName(const QString &bucket);
    void setDemoMode(bool demo);
    void setShareHttpServer(ShareHttpServer *server);

    Q_INVOKABLE void saveConfig(const QString &url, const QString &key, const QString &bucket);
    Q_INVOKABLE void signIn(const QString &email, const QString &password);
    Q_INVOKABLE void signUp(const QString &email, const QString &password);
    Q_INVOKABLE void signOut();
    Q_INVOKABLE void uploadRecording(const QString &filePath, const QString &title, int durationSeconds, const QString &aspectRatio);
    Q_INVOKABLE void copyShareUrlToClipboard();
    Q_INVOKABLE void openShareUrlInBrowser();
    Q_INVOKABLE QString getSqlSchema() const;
    Q_INVOKABLE void simulateDemoUpload(const QString &filePath, const QString &title, int durationSeconds);

signals:
    void authStateChanged();
    void configChanged();
    void uploadStateChanged();
    void uploadProgressChanged();
    void shareUrlChanged();
    void statusChanged();
    void demoModeChanged();
    void uploadCompleted(const QString &shareUrl);
    void uploadFailed(const QString &error);

private slots:
    void onUploadProgress(qint64 bytesSent, qint64 bytesTotal);

private:
    void setStatus(const QString &msg);
    void loadSettings();
    void saveSettings();
    void insertRecordingMetadata(const QString &filePath, const QString &title, int durationSeconds, const QString &aspectRatio, const QString &storagePath, const QString &publicUrl);
    void uploadToPublicCloud(const QString &filePath, const QString &title, int durationSeconds);

    QNetworkAccessManager *m_network;
    QString m_supabaseUrl;
    QString m_anonKey;
    QString m_bucketName;
    QString m_accessToken;
    QString m_userEmail;
    bool m_isAuthenticated;
    bool m_isUploading;
    qreal m_uploadProgress;
    QString m_currentShareUrl;
    QString m_statusMessage;
    bool m_isDemoMode;
    ShareHttpServer *m_shareServer;
};

#endif // SUPABASEMANAGER_H
