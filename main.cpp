#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>

#include "src/core/ScreenRecorderEngine.h"
#include "src/core/AudioCaptureManager.h"
#include "src/core/GlobalHotkeyManager.h"
#include "src/editor/StudioSettings.h"
#include "src/editor/ZoomEngine.h"
#include "src/editor/StudioTheme.h"
#include "src/ai/AiVideoCustomizer.h"
#include "src/cloud/SupabaseManager.h"
#include "src/cloud/ShareHttpServer.h"
#include "src/export/VideoExportManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("StudioScreen");
    app.setApplicationName("StudioScreen AI");
    app.setWindowIcon(QIcon("windows/app_icon_256.png"));

    ScreenRecorderEngine recorderEngine;
    AudioCaptureManager audioManager;
    GlobalHotkeyManager hotkeyManager;
    StudioSettings studioSettings;
    ZoomEngine zoomEngine;
    StudioTheme studioTheme;
    AiVideoCustomizer aiCustomizer;
    SupabaseManager supabaseManager;
    ShareHttpServer shareServer;
    VideoExportManager exportManager;

    // Connect native global hotkeys (Ctrl+Shift+R and Ctrl+Shift+P)
    QObject::connect(&hotkeyManager, &GlobalHotkeyManager::recordToggleRequested,
                     &recorderEngine, &ScreenRecorderEngine::toggleRecording);
    QObject::connect(&hotkeyManager, &GlobalHotkeyManager::pauseToggleRequested, [&recorderEngine]() {
        if (recorderEngine.state() == "recording") {
            recorderEngine.pauseRecording();
        } else if (recorderEngine.state() == "paused") {
            recorderEngine.resumeRecording();
        }
    });

    // Start embedded HTTP sharing server on port 8085
    shareServer.start(8085);

    // Direct C++ wiring avoids QML type marshalling failures
    recorderEngine.setAudioCaptureManager(&audioManager);
    recorderEngine.setZoomEngine(&zoomEngine);
    supabaseManager.setShareHttpServer(&shareServer);

    QQmlApplicationEngine engine;

    // Expose core C++ backend engines directly to QML
    QQmlContext *rootCtx = engine.rootContext();
    rootCtx->setContextProperty("recorderEngine", &recorderEngine);
    rootCtx->setContextProperty("audioManager", &audioManager);
    rootCtx->setContextProperty("studioSettings", &studioSettings);
    rootCtx->setContextProperty("zoomEngine", &zoomEngine);
    rootCtx->setContextProperty("studioTheme", &studioTheme);
    rootCtx->setContextProperty("StudioTheme", &studioTheme);
    rootCtx->setContextProperty("aiCustomizer", &aiCustomizer);
    rootCtx->setContextProperty("supabaseManager", &supabaseManager);
    rootCtx->setContextProperty("shareServer", &shareServer);
    rootCtx->setContextProperty("exportManager", &exportManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("Recorder_App", "Main");

    return app.exec();
}
