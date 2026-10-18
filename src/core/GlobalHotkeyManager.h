#ifndef GLOBALHOTKEYMANAGER_H
#define GLOBALHOTKEYMANAGER_H

#include <QObject>
#include <QAbstractNativeEventFilter>

class GlobalHotkeyManager : public QObject, public QAbstractNativeEventFilter
{
    Q_OBJECT
public:
    explicit GlobalHotkeyManager(QObject *parent = nullptr);
    ~GlobalHotkeyManager() override;

    void registerHotkeys();
    void unregisterHotkeys();

    bool nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result) override;

signals:
    void recordToggleRequested();
    void pauseToggleRequested();

private:
    bool m_registered;
};

#endif // GLOBALHOTKEYMANAGER_H
