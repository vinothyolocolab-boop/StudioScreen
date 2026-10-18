#ifndef SHAREHTTPSERVER_H
#define SHAREHTTPSERVER_H

#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QString>
#include <QFileInfo>
#include <QNetworkInterface>

class ShareHttpServer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(int port READ port NOTIFY portChanged)
    Q_PROPERTY(QString localShareUrl READ localShareUrl NOTIFY urlChanged)
    Q_PROPERTY(QString lanShareUrl READ lanShareUrl NOTIFY urlChanged)

public:
    explicit ShareHttpServer(QObject *parent = nullptr);
    ~ShareHttpServer() override;

    bool isRunning() const { return m_server && m_server->isListening(); }
    int port() const { return m_port; }
    QString localShareUrl() const;
    QString lanShareUrl() const;

    void setVideoPath(const QString &path);
    QString currentVideoPath() const { return m_currentVideoPath; }

    bool start(int port = 8085);
    void stop();

signals:
    void runningChanged();
    void portChanged();
    void urlChanged();

private slots:
    void onNewConnection();
    void onReadyRead();

private:
    void handleClientRequest(QTcpSocket *client, const QByteArray &requestData);
    void sendHtmlViewer(QTcpSocket *client);
    void sendVideoStream(QTcpSocket *client, const QByteArray &rangeHeader);
    QString getLocalIpAddress() const;

    QTcpServer *m_server;
    int m_port;
    QString m_currentVideoPath;
};

#endif // SHAREHTTPSERVER_H
