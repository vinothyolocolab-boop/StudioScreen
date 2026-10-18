cmake_minimum_required(VERSION 3.16)

project(Recorder_App VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Multimedia Network Svg)

qt_standard_project_setup(REQUIRES 6.5)

set(EXTRA_PLATFORM_SOURCES)
if(WIN32)
    set(EXTRA_PLATFORM_SOURCES windows/app.rc)
endif()

qt_add_executable(appRecorder_App
    main.cpp
    src/core/ScreenRecorderEngine.h
    src/core/ScreenRecorderEngine.cpp
    src/core/AudioCaptureManager.h
    src/core/AudioCaptureManager.cpp
    src/core/GlobalHotkeyManager.h
    src/core/GlobalHotkeyManager.cpp
    src/editor/StudioSettings.h
    src/editor/StudioSettings.cpp
    src/editor/StudioTheme.h
    src/editor/ZoomEngine.h
    src/editor/ZoomEngine.cpp
    src/ai/AiVideoCustomizer.h
    src/ai/AiVideoCustomizer.cpp
    src/cloud/SupabaseManager.h
    src/cloud/SupabaseManager.cpp
    src/cloud/ShareHttpServer.h
    src/cloud/ShareHttpServer.cpp
    src/export/VideoExportManager.h
    src/export/VideoExportManager.cpp
    ${EXTRA_PLATFORM_SOURCES}
)

qt_add_qml_module(appRecorder_App
    URI Recorder_App
    QML_FILES
        Main.qml
        qml/components/StudioCanvas.qml
        qml/components/TimelineView.qml
        qml/components/InspectorPanel.qml
        qml/components/TopNavBar.qml
        qml/components/RecordingOverlay.qml
        qml/components/SupabaseDialog.qml
        qml/components/ShareModal.qml
        qml/components/CursorItem.qml
        qml/components/StudioIcon.qml
        qml/styles/StudioTheme.qml
)

set_target_properties(appRecorder_App PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appRecorder_App
    PRIVATE
        Qt6::Quick
        Qt6::Multimedia
        Qt6::Network
        Qt6::Svg
)

include(GNUInstallDirs)
install(TARGETS appRecorder_App
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
