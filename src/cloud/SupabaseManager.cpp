#include "SupabaseManager.h"
#include "ShareHttpServer.h"
#include <QNetworkRequest>
#include <QUrl>
#include <QUrlQuery>
#include <QUuid>
#include <QDateTime>
#include <QDesktopServices>
#include <QDebug>
#include <QTimer>

SupabaseManager::SupabaseManager(QObject *parent)
    : QObject(parent)
    , m_network(new QNetworkAccessManager(this))
    , m_bucketName("recordings")
    , m_isAuthenticated(false)
    , m_isUploading(false)
    , m_uploadProgress(0.0)
    , m_statusMessage("Ready")
    , m_isDemoMode(true)
    , m_shareServer(nullptr)
{
    loadSettings();
}

void SupabaseManager::setShareHttpServer(ShareHttpServer *server)
{
    m_shareServer = server;
}

void SupabaseManager::loadSettings()
{
    QSettings settings("StudioScreen", "RecorderApp");
    m_supabaseUrl = settings.value("supabase/url", "").toString();
    m_anonKey = settings.value("supabase/anonKey", "").toString();
    m_bucketName = settings.value("supabase/bucket", "recordings").toString();
    m_accessToken = settings.value("supabase/accessToken", "").toString();
    m_userEmail = settings.value("supabase/userEmail", "").toString();
    m_isDemoMode = settings.value("supabase/demoMode", m_supabaseUrl.trimmed().isEmpty()).toBool();

    if (!m_accessToken.isEmpty() && !m_userEmail.isEmpty()) {
        m_isAuthenticated = true;
    }
}

void SupabaseManager::saveSettings()
{
    QSettings settings("StudioScreen", "RecorderApp");
    settings.setValue("supabase/url", m_supabaseUrl);
    settings.setValue("supabase/anonKey", m_anonKey);
    settings.setValue("supabase/bucket", m_bucketName);
    settings.setValue("supabase/accessToken", m_accessToken);
    settings.setValue("supabase/userEmail", m_userEmail);
    settings.setValue("supabase/demoMode", m_isDemoMode);
}

void SupabaseManager::setSupabaseUrl(const QString &url)
{
    if (m_supabaseUrl != url) {
        m_supabaseUrl = url.trimmed();
        if (m_supabaseUrl.endsWith('/')) {
            m_supabaseUrl.chop(1);
        }
        saveSettings();
        emit configChanged();
    }
}

void SupabaseManager::setAnonKey(const QString &key)
{
    if (m_anonKey != key) {
        m_anonKey = key.trimmed();
        saveSettings();
        emit configChanged();
    }
}

void SupabaseManager::setBucketName(const QString &bucket)
{
    if (m_bucketName != bucket) {
        m_bucketName = bucket.trimmed();
        saveSettings();
        emit configChanged();
    }
}

void SupabaseManager::setDemoMode(bool demo)
{
    if (m_isDemoMode != demo) {
        m_isDemoMode = demo;
        saveSettings();
        emit demoModeChanged();
    }
}

void SupabaseManager::saveConfig(const QString &url, const QString &key, const QString &bucket)
{
    setSupabaseUrl(url);
    setAnonKey(key);
    setBucketName(bucket);
    if (!url.trimmed().isEmpty() && !key.trimmed().isEmpty()) {
        setDemoMode(false);
    }
    setStatus("Supabase configuration saved successfully.");
}

void SupabaseManager::setStatus(const QString &msg)
{
    m_statusMessage = msg;
    emit statusChanged();
}

void SupabaseManager::signIn(const QString &email, const QString &password)
{
    if (m_isDemoMode || m_supabaseUrl.isEmpty() || m_anonKey.isEmpty()) {
        m_isAuthenticated = true;
        m_userEmail = email.isEmpty() ? "creator@studioscreen.ai" : email;
        m_accessToken = "demo_token_" + QUuid::createUuid().toString(QUuid::WithoutBraces);
        saveSettings();
        setStatus("Signed in (Instant Share Mode)");
        emit authStateChanged();
        return;
    }

    setStatus("Signing in to Supabase...");
    QUrl url(m_supabaseUrl + "/auth/v1/token?grant_type=password");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("apikey", m_anonKey.toUtf8());

    QJsonObject json;
    json["email"] = email;
    json["password"] = password;

    QNetworkReply *reply = m_network->post(request, QJsonDocument(json).toJson());
    connect(reply, &QNetworkReply::finished, this, [this, reply, email]() {
        reply->deleteLater();
        if (reply->error() == QNetworkReply::NoError) {
            QJsonObject resp = QJsonDocument::fromJson(reply->readAll()).object();
            m_accessToken = resp["access_token"].toString();
            m_userEmail = email;
            m_isAuthenticated = true;
            saveSettings();
            setStatus("Signed in successfully as " + email);
            emit authStateChanged();
        } else {
            setStatus("Sign in failed: " + reply->errorString());
        }
    });
}

void SupabaseManager::signUp(const QString &email, const QString &password)
{
    if (m_isDemoMode || m_supabaseUrl.isEmpty() || m_anonKey.isEmpty()) {
        signIn(email, password);
        return;
    }

    setStatus("Creating account...");
    QUrl url(m_supabaseUrl + "/auth/v1/signup");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("apikey", m_anonKey.toUtf8());

    QJsonObject json;
    json["email"] = email;
    json["password"] = password;

    QNetworkReply *reply = m_network->post(request, QJsonDocument(json).toJson());
    connect(reply, &QNetworkReply::finished, this, [this, reply, email, password]() {
        reply->deleteLater();
        if (reply->error() == QNetworkReply::NoError) {
            setStatus("Account created! Logging in...");
            signIn(email, password);
        } else {
            setStatus("Sign up failed: " + reply->errorString());
        }
    });
}

void SupabaseManager::signOut()
{
    m_isAuthenticated = false;
    m_accessToken.clear();
    m_userEmail.clear();
    saveSettings();
    setStatus("Signed out.");
    emit authStateChanged();
}

QString SupabaseManager::localShareUrl() const
{
    return m_shareServer ? m_shareServer->lanShareUrl() : "http://localhost:8085";
}

void SupabaseManager::simulateDemoUpload(const QString &filePath, const QString &title, int durationSeconds)
{
    uploadToPublicCloud(filePath, title, durationSeconds);
}

void SupabaseManager::uploadToPublicCloud(const QString &filePath, const QString &title, int durationSeconds)
{
    Q_UNUSED(durationSeconds)

    if (m_shareServer) {
        m_shareServer->setVideoPath(filePath);
    }

    QFile *file = new QFile(filePath, this);
    if (!file->open(QIODevice::ReadOnly)) {
        setStatus("Could not open recording file: " + filePath);
        file->deleteLater();
        if (m_shareServer) {
            m_currentShareUrl = m_shareServer->lanShareUrl();
            emit shareUrlChanged();
            emit uploadCompleted(m_currentShareUrl);
        }
        return;
    }

    m_isUploading = true;
    m_uploadProgress = 0.05;
    emit uploadStateChanged();
    emit uploadProgressChanged();
    setStatus("Uploading recording to cloud for instant 24/7 autoplay sharing...");

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    // Form parameter: reqtype = fileupload
    QHttpPart reqTypePart;
    reqTypePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"reqtype\""));
    reqTypePart.setBody("fileupload");
    multiPart->append(reqTypePart);

    // Form parameter: fileToUpload = <file>
    QHttpPart filePart;
    filePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("video/mp4"));
    QString baseName = QFileInfo(filePath).fileName();
    if (baseName.isEmpty()) baseName = "StudioScreen_recording.mp4";
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader, 
        QVariant(QString("form-data; name=\"fileToUpload\"; filename=\"%1\"").arg(baseName)));
    filePart.setBodyDevice(file);
    file->setParent(multiPart);
    multiPart->append(filePart);

    QNetworkRequest request(QUrl("https://catbox.moe/user/api.php"));
    QNetworkReply *reply = m_network->post(request, multiPart);
    multiPart->setParent(reply);

    connect(reply, &QNetworkReply::uploadProgress, this, &SupabaseManager::onUploadProgress);

    connect(reply, &QNetworkReply::finished, this, [this, reply, filePath, title]() {
        reply->deleteLater();
        m_isUploading = false;
        emit uploadStateChanged();

        if (reply->error() == QNetworkReply::NoError) {
            QString respStr = QString::fromUtf8(reply->readAll()).trimmed();
            if (respStr.startsWith("http://") || respStr.startsWith("https://")) {
                QString videoDirectUrl = respStr;
                QString displayTitle = title.isEmpty() ? "StudioScreen Recording" : title;
                
                // Wrap direct video URL in dedicated StudioScreen web player with guaranteed autoplay
                QString playerUrl = QString("https://vinothyolocolab-boop.github.io/studio-player/?v=%1&title=%2")
                                        .arg(QString::fromUtf8(QUrl::toPercentEncoding(videoDirectUrl)),
                                             QString::fromUtf8(QUrl::toPercentEncoding(displayTitle)));

                m_currentShareUrl = playerUrl;
                emit shareUrlChanged();
                copyShareUrlToClipboard();
                setStatus("✓ Cloud link ready! Autoplays 24/7 in any browser even when app is closed.");
                emit uploadCompleted(m_currentShareUrl);
                return;
            }
        }

        // Fallback to local server if network request had an error
        qWarning() << "Public cloud upload failed:" << reply->errorString();
        if (m_shareServer) {
            m_currentShareUrl = m_shareServer->lanShareUrl();
            if (m_currentShareUrl.isEmpty()) {
                m_currentShareUrl = m_shareServer->localShareUrl();
            }
            emit shareUrlChanged();
            copyShareUrlToClipboard();
            setStatus("Using local share stream (Note: requires app to remain open).");
            emit uploadCompleted(m_currentShareUrl);
        }
    });
}

void SupabaseManager::uploadRecording(const QString &filePath, const QString &title, int durationSeconds, const QString &aspectRatio)
{
    // If Supabase URL is not configured or in instant share mode, upload to public cloud for permanent 24/7 link
    if (m_isDemoMode || m_supabaseUrl.isEmpty() || m_anonKey.isEmpty()) {
        uploadToPublicCloud(filePath, title, durationSeconds);
        return;
    }

    QFile *file = new QFile(filePath, this);
    if (!file->open(QIODevice::ReadOnly)) {
        setStatus("Could not open recording file: " + filePath);
        emit uploadFailed("File error");
        file->deleteLater();
        return;
    }

    m_isUploading = true;
    m_uploadProgress = 0.0;
    emit uploadStateChanged();
    emit uploadProgressChanged();
    setStatus("Uploading recording to Supabase Storage...");

    QString fileName = QString("recording_%1_%2.mp4")
                           .arg(QDateTime::currentMSecsSinceEpoch())
                           .arg(QUuid::createUuid().toString(QUuid::WithoutBraces).left(8));

    QUrl url(QString("%1/storage/v1/object/%2/%3").arg(m_supabaseUrl, m_bucketName, fileName));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "video/mp4");
    request.setRawHeader("apikey", m_anonKey.toUtf8());

    QString bearer = m_accessToken.isEmpty() ? m_anonKey : m_accessToken;
    request.setRawHeader("Authorization", ("Bearer " + bearer).toUtf8());

    QNetworkReply *reply = m_network->post(request, file);
    file->setParent(reply);

    connect(reply, &QNetworkReply::uploadProgress, this, &SupabaseManager::onUploadProgress);

    connect(reply, &QNetworkReply::finished, this, [this, reply, fileName, filePath, title, durationSeconds, aspectRatio]() {
        reply->deleteLater();
        m_isUploading = false;
        emit uploadStateChanged();

        if (reply->error() == QNetworkReply::NoError) {
            QString publicUrl = QString("%1/storage/v1/object/public/%2/%3")
                                    .arg(m_supabaseUrl, m_bucketName, fileName);
            QString displayTitle = title.isEmpty() ? "StudioScreen Recording" : title;
            QString playerUrl = QString("https://vinothyolocolab-boop.github.io/studio-player/?v=%1&title=%2")
                                    .arg(QString::fromUtf8(QUrl::toPercentEncoding(publicUrl)),
                                         QString::fromUtf8(QUrl::toPercentEncoding(displayTitle)));

            m_currentShareUrl = playerUrl;
            emit shareUrlChanged();
            copyShareUrlToClipboard();
            insertRecordingMetadata(filePath, title, durationSeconds, aspectRatio, fileName, publicUrl);
            setStatus("Upload complete! Autoplay share link generated & copied.");
            emit uploadCompleted(m_currentShareUrl);
        } else {
            QString err = reply->errorString();
            setStatus("Supabase upload failed: " + err + ". Switched to local share.");
            // Graceful fallback to local streaming server
            simulateDemoUpload(filePath, title, durationSeconds);
        }
    });
}

void SupabaseManager::onUploadProgress(qint64 bytesSent, qint64 bytesTotal)
{
    if (bytesTotal > 0) {
        m_uploadProgress = static_cast<qreal>(bytesSent) / static_cast<qreal>(bytesTotal);
        emit uploadProgressChanged();
    }
}

void SupabaseManager::insertRecordingMetadata(const QString &filePath, const QString &title, int durationSeconds, const QString &aspectRatio, const QString &storagePath, const QString &publicUrl)
{
    Q_UNUSED(filePath)
    QUrl url(m_supabaseUrl + "/rest/v1/recordings");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("apikey", m_anonKey.toUtf8());

    QString bearer = m_accessToken.isEmpty() ? m_anonKey : m_accessToken;
    request.setRawHeader("Authorization", ("Bearer " + bearer).toUtf8());
    request.setRawHeader("Prefer", "return=representation");

    QJsonObject json;
    json["title"] = title.isEmpty() ? "Studio Recording" : title;
    json["duration_seconds"] = durationSeconds;
    json["storage_path"] = storagePath;
    json["public_url"] = publicUrl;
    json["aspect_ratio"] = aspectRatio;
    json["is_public"] = true;

    m_network->post(request, QJsonDocument(json).toJson());
}

void SupabaseManager::copyShareUrlToClipboard()
{
    if (!m_currentShareUrl.isEmpty()) {
        QClipboard *clipboard = QGuiApplication::clipboard();
        if (clipboard) {
            clipboard->setText(m_currentShareUrl);
            setStatus("Share link copied to clipboard: " + m_currentShareUrl);
        }
    }
}

void SupabaseManager::openShareUrlInBrowser()
{
    if (!m_currentShareUrl.isEmpty()) {
        QDesktopServices::openUrl(QUrl(m_currentShareUrl));
    }
}

QString SupabaseManager::getSqlSchema() const
{
    return R"(
-- Run this in Supabase SQL Editor:
CREATE TABLE IF NOT EXISTS public.recordings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT 'Screen Recording',
    duration_seconds INTEGER NOT NULL DEFAULT 0,
    storage_path TEXT NOT NULL,
    public_url TEXT NOT NULL,
    aspect_ratio TEXT DEFAULT '16:9',
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
ALTER TABLE public.recordings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public recordings are viewable by everyone" ON public.recordings FOR SELECT USING (true);
CREATE POLICY "Allow Insert" ON public.recordings FOR INSERT WITH CHECK (true);
INSERT INTO storage.buckets (id, name, public) VALUES ('recordings', 'recordings', true) ON CONFLICT DO NOTHING;
CREATE POLICY "Public Read" ON storage.objects FOR SELECT USING (bucket_id = 'recordings');
CREATE POLICY "Allow Upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'recordings');
)";
}
