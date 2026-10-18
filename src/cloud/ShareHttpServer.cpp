#include "ShareHttpServer.h"
#include <QFile>
#include <QDateTime>
#include <QDebug>

ShareHttpServer::ShareHttpServer(QObject *parent)
    : QObject(parent)
    , m_server(new QTcpServer(this))
    , m_port(8085)
{
    connect(m_server, &QTcpServer::newConnection, this, &ShareHttpServer::onNewConnection);
}

ShareHttpServer::~ShareHttpServer()
{
    stop();
}

void ShareHttpServer::setVideoPath(const QString &path)
{
    if (m_currentVideoPath != path) {
        m_currentVideoPath = path;
        emit urlChanged();
    }
}

bool ShareHttpServer::start(int port)
{
    m_port = port;
    if (m_server->isListening()) {
        m_server->close();
    }

    if (m_server->listen(QHostAddress::Any, m_port)) {
        qDebug() << "Instant Share HTTP Server listening on port" << m_port;
        emit runningChanged();
        emit portChanged();
        emit urlChanged();
        return true;
    } else {
        qWarning() << "Failed to start HTTP server on port" << m_port << ":" << m_server->errorString();
        // Fallback to random free port
        if (m_server->listen(QHostAddress::Any, 0)) {
            m_port = m_server->serverPort();
            emit runningChanged();
            emit portChanged();
            emit urlChanged();
            return true;
        }
    }
    return false;
}

void ShareHttpServer::stop()
{
    if (m_server && m_server->isListening()) {
        m_server->close();
        emit runningChanged();
    }
}

QString ShareHttpServer::getLocalIpAddress() const
{
    const auto addresses = QNetworkInterface::allAddresses();
    for (const auto &addr : addresses) {
        if (addr.protocol() == QAbstractSocket::IPv4Protocol &&
            !addr.isLoopback() &&
            addr != QHostAddress::Null &&
            !addr.toString().startsWith("172.") && // skip docker bridges
            !addr.toString().startsWith("169.254.")) {
            return addr.toString();
        }
    }
    return "127.0.0.1";
}

QString ShareHttpServer::localShareUrl() const
{
    return QString("http://localhost:%1").arg(m_port);
}

QString ShareHttpServer::lanShareUrl() const
{
    return QString("http://%1:%2").arg(getLocalIpAddress()).arg(m_port);
}

void ShareHttpServer::onNewConnection()
{
    while (m_server->hasPendingConnections()) {
        QTcpSocket *client = m_server->nextPendingConnection();
        connect(client, &QTcpSocket::readyRead, this, &ShareHttpServer::onReadyRead);
        connect(client, &QTcpSocket::disconnected, client, &QTcpSocket::deleteLater);
    }
}

void ShareHttpServer::onReadyRead()
{
    auto *client = qobject_cast<QTcpSocket*>(sender());
    if (!client) return;

    QByteArray requestData = client->readAll();
    handleClientRequest(client, requestData);
}

void ShareHttpServer::handleClientRequest(QTcpSocket *client, const QByteArray &requestData)
{
    QString req = QString::fromUtf8(requestData);
    QStringList lines = req.split("\r\n");
    if (lines.isEmpty()) return;

    QString firstLine = lines.first();
    QStringList parts = firstLine.split(' ');
    if (parts.size() < 2) return;

    QString path = parts[1];

    if (path.startsWith("/video") || path.endsWith(".mp4")) {
        QByteArray rangeHeader;
        for (const QString &line : lines) {
            if (line.startsWith("Range:", Qt::CaseInsensitive)) {
                rangeHeader = line.toUtf8();
                break;
            }
        }
        sendVideoStream(client, rangeHeader);
    } else {
        sendHtmlViewer(client);
    }
}

void ShareHttpServer::sendHtmlViewer(QTcpSocket *client)
{
    QString fileName = QFileInfo(m_currentVideoPath).fileName();
    if (fileName.isEmpty()) fileName = "StudioScreen_Recording.mp4";

    QString html = QString(R"HTML(<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>%1 — StudioScreen AI Share</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
            background: #070a12;
            color: #f8fafc;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }
        .header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
        }
        .badge {
            background: linear-gradient(135deg, #6366f1, #06b6d4);
            color: white;
            font-weight: 700;
            padding: 6px 14px;
            border-radius: 999px;
            font-size: 13px;
            letter-spacing: 0.5px;
        }
        .title {
            font-size: 22px;
            font-weight: 700;
            color: #ffffff;
        }
        .player-card {
            background: #0f172a;
            border: 1px solid #1e293b;
            border-radius: 20px;
            padding: 16px;
            box-shadow: 0 25px 60px -15px rgba(0, 0, 0, 0.7);
            max-width: 960px;
            width: 100%;
        }
        video {
            width: 100%;
            border-radius: 14px;
            background: #000000;
            outline: none;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }
        .footer {
            margin-top: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 8px;
        }
        .meta {
            color: #94a3b8;
            font-size: 13px;
        }
        .btn-download {
            background: #1e293b;
            color: #ffffff;
            border: 1px solid #334155;
            padding: 8px 16px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.2s;
        }
        .btn-download:hover {
            background: #6366f1;
            border-color: #6366f1;
        }
    </style>
</head>
<body>
    <div class="header">
        <span class="badge">StudioScreen AI</span>
        <h1 class="title">%1</h1>
    </div>
    <div class="player-card">
        <video controls autoplay loop playsinline src="/video.mp4"></video>
        <div class="footer">
            <span class="meta">Recorded with zero lag &bull; 60 FPS HD</span>
            <a href="/video.mp4" download="%1" class="btn-download">&#11015; Download Video</a>
        </div>
    </div>
</body>
</html>)HTML").arg(fileName);

    QByteArray response;
    response.append("HTTP/1.1 200 OK\r\n");
    response.append("Content-Type: text/html; charset=utf-8\r\n");
    response.append("Content-Length: " + QByteArray::number(html.toUtf8().size()) + "\r\n");
    response.append("Connection: close\r\n\r\n");
    response.append(html.toUtf8());

    client->write(response);
    client->flush();
    client->disconnectFromHost();
}

void ShareHttpServer::sendVideoStream(QTcpSocket *client, const QByteArray &rangeHeader)
{
    Q_UNUSED(rangeHeader)
    QFile file(m_currentVideoPath);
    if (!file.open(QIODevice::ReadOnly)) {
        QByteArray resp = "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nConnection: close\r\n\r\n";
        client->write(resp);
        client->flush();
        client->disconnectFromHost();
        return;
    }

    qint64 fileSize = file.size();
    QByteArray header;
    header.append("HTTP/1.1 200 OK\r\n");
    header.append("Content-Type: video/mp4\r\n");
    header.append("Content-Length: " + QByteArray::number(fileSize) + "\r\n");
    header.append("Accept-Ranges: bytes\r\n");
    header.append("Connection: close\r\n\r\n");

    client->write(header);

    // Stream file contents
    while (!file.atEnd() && client->state() == QAbstractSocket::ConnectedState) {
        QByteArray chunk = file.read(65536);
        client->write(chunk);
        client->waitForBytesWritten(500);
    }
    client->disconnectFromHost();
}
