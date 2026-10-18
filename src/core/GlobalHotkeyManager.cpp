#include "GlobalHotkeyManager.h"
#include <QCoreApplication>
#include <QDebug>

#if defined(Q_OS_WIN)
#include <windows.h>
#define HOTKEY_RECORD_ID 101
#define HOTKEY_PAUSE_ID 102
#endif

GlobalHotkeyManager::GlobalHotkeyManager(QObject *parent)
    : QObject(parent)
    , m_registered(false)
{
    if (QCoreApplication::instance()) {
        QCoreApplication::instance()->installNativeEventFilter(this);
    }
    registerHotkeys();
}

GlobalHotkeyManager::~GlobalHotkeyManager()
{
    unregisterHotkeys();
    if (QCoreApplication::instance()) {
        QCoreApplication::instance()->removeNativeEventFilter(this);
    }
}

void GlobalHotkeyManager::registerHotkeys()
{
#if defined(Q_OS_WIN)
    if (!m_registered) {
        // Register Ctrl + Shift + R for Record / Stop toggle
        BOOL ok1 = RegisterHotKey(NULL, HOTKEY_RECORD_ID, MOD_CONTROL | MOD_SHIFT, 'R');
        // Register Ctrl + Shift + P for Pause / Resume toggle
        BOOL ok2 = RegisterHotKey(NULL, HOTKEY_PAUSE_ID, MOD_CONTROL | MOD_SHIFT, 'P');
        m_registered = ok1 || ok2;
        qDebug() << "Windows Global Hotkeys Registered (Ctrl+Shift+R, Ctrl+Shift+P):" << (m_registered ? "SUCCESS" : "FAILED");
    }
#endif
}

void GlobalHotkeyManager::unregisterHotkeys()
{
#if defined(Q_OS_WIN)
    if (m_registered) {
        UnregisterHotKey(NULL, HOTKEY_RECORD_ID);
        UnregisterHotKey(NULL, HOTKEY_PAUSE_ID);
        m_registered = false;
    }
#endif
}

bool GlobalHotkeyManager::nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result)
{
    Q_UNUSED(result);
#if defined(Q_OS_WIN)
    if (eventType == "windows_generic_MSG" || eventType == "windows_dispatcher_MSG") {
        MSG *msg = static_cast<MSG*>(message);
        if (msg && msg->message == WM_HOTKEY) {
            if (msg->wParam == HOTKEY_RECORD_ID) {
                emit recordToggleRequested();
                return true;
            } else if (msg->wParam == HOTKEY_PAUSE_ID) {
                emit pauseToggleRequested();
                return true;
            }
        }
    }
#endif
    return false;
}
