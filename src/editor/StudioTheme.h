#ifndef STUDIOTHEME_H
#define STUDIOTHEME_H

#include <QObject>
#include <QColor>
#include <QString>

class StudioTheme : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor bgDark READ bgDark CONSTANT)
    Q_PROPERTY(QColor bgSurface READ bgSurface CONSTANT)
    Q_PROPERTY(QColor bgCard READ bgCard CONSTANT)
    Q_PROPERTY(QColor bgCardHover READ bgCardHover CONSTANT)
    Q_PROPERTY(QColor borderSubtle READ borderSubtle CONSTANT)
    Q_PROPERTY(QColor borderActive READ borderActive CONSTANT)

    Q_PROPERTY(QColor accentPrimary READ accentPrimary CONSTANT)
    Q_PROPERTY(QColor accentSecondary READ accentSecondary CONSTANT)
    Q_PROPERTY(QColor accentCyan READ accentCyan CONSTANT)
    Q_PROPERTY(QColor accentPink READ accentPink CONSTANT)

    Q_PROPERTY(QColor textPrimary READ textPrimary CONSTANT)
    Q_PROPERTY(QColor textSecondary READ textSecondary CONSTANT)
    Q_PROPERTY(QColor textMuted READ textMuted CONSTANT)

    Q_PROPERTY(QColor statusRecording READ statusRecording CONSTANT)
    Q_PROPERTY(QColor statusSuccess READ statusSuccess CONSTANT)
    Q_PROPERTY(QColor statusWarning READ statusWarning CONSTANT)

    Q_PROPERTY(int radiusSm READ radiusSm CONSTANT)
    Q_PROPERTY(int radiusMd READ radiusMd CONSTANT)
    Q_PROPERTY(int radiusLg READ radiusLg CONSTANT)
    Q_PROPERTY(int radiusPill READ radiusPill CONSTANT)

    Q_PROPERTY(int fontSizeXs READ fontSizeXs CONSTANT)
    Q_PROPERTY(int fontSizeSm READ fontSizeSm CONSTANT)
    Q_PROPERTY(int fontSizeMd READ fontSizeMd CONSTANT)
    Q_PROPERTY(int fontSizeLg READ fontSizeLg CONSTANT)
    Q_PROPERTY(int fontSizeXl READ fontSizeXl CONSTANT)
    Q_PROPERTY(int fontSizeTitle READ fontSizeTitle CONSTANT)

public:
    explicit StudioTheme(QObject *parent = nullptr) : QObject(parent) {}

    QColor bgDark() const { return QColor("#070a12"); }
    QColor bgSurface() const { return QColor("#0f172a"); }
    QColor bgCard() const { return QColor("#131d33"); }
    QColor bgCardHover() const { return QColor("#1e293b"); }
    QColor borderSubtle() const { return QColor("#1e293b"); }
    QColor borderActive() const { return QColor("#6366f1"); }

    QColor accentPrimary() const { return QColor("#6366f1"); }
    QColor accentSecondary() const { return QColor("#8b5cf6"); }
    QColor accentCyan() const { return QColor("#06b6d4"); }
    QColor accentPink() const { return QColor("#f43f5e"); }

    QColor textPrimary() const { return QColor("#f8fafc"); }
    QColor textSecondary() const { return QColor("#94a3b8"); }
    QColor textMuted() const { return QColor("#64748b"); }

    QColor statusRecording() const { return QColor("#ef4444"); }
    QColor statusSuccess() const { return QColor("#10b981"); }
    QColor statusWarning() const { return QColor("#f59e0b"); }

    int radiusSm() const { return 6; }
    int radiusMd() const { return 10; }
    int radiusLg() const { return 16; }
    int radiusPill() const { return 999; }

    int fontSizeXs() const { return 11; }
    int fontSizeSm() const { return 12; }
    int fontSizeMd() const { return 14; }
    int fontSizeLg() const { return 16; }
    int fontSizeXl() const { return 20; }
    int fontSizeTitle() const { return 26; }
};

#endif // STUDIOTHEME_H
