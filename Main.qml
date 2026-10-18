import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "qml/components"

ApplicationWindow {
    id: appWindow
    width: 1280
    height: 820
    minimumWidth: 1024
    minimumHeight: 680
    visible: true
    title: qsTr("StudioScreen AI — Screen Studio Pro (Windows, Linux, macOS, Android)")
    color: studioTheme.bgDark

    property string currentMode: "editor" // "recorder" or "editor"

    // Screen Studio Pro Ergonomic Shortcuts
    Shortcut {
        sequence: "Space"
        onActivated: {
            timelineView.isPlaying = !timelineView.isPlaying;
        }
    }
    Shortcut {
        sequence: "Ctrl+Shift+R"
        onActivated: {
            recorderEngine.toggleRecording();
            appWindow.currentMode = (recorderEngine.state === "recording") ? "recorder" : "editor";
        }
    }
    Shortcut {
        sequence: "Ctrl+R"
        onActivated: {
            recorderEngine.toggleRecording();
            appWindow.currentMode = (recorderEngine.state === "recording") ? "recorder" : "editor";
        }
    }
    Shortcut {
        sequence: "Z"
        onActivated: {
            zoomEngine.addSegment(timelineView.currentMs, timelineView.currentMs + 2200, 0.5, 0.5, studioSettings.defaultZoomScale, "Zoom Marker");
        }
    }
    Shortcut {
        sequence: "Delete"
        onActivated: {
            if (zoomEngine.selectedSegmentId !== -1) {
                zoomEngine.removeSegment(zoomEngine.selectedSegmentId);
            }
        }
    }
    Shortcut {
        sequence: "Backspace"
        onActivated: {
            if (zoomEngine.selectedSegmentId !== -1) {
                zoomEngine.removeSegment(zoomEngine.selectedSegmentId);
            }
        }
    }
    Shortcut {
        sequence: "Left"
        onActivated: {
            timelineView.currentMs = Math.max(0, timelineView.currentMs - 1000);
            zoomEngine.updatePlayhead(timelineView.currentMs, studioSettings.zoomTransitionMs);
            recorderEngine.seekKeystrokes(timelineView.currentMs);
        }
    }
    Shortcut {
        sequence: "Right"
        onActivated: {
            timelineView.currentMs = Math.min(timelineView.totalDurationMs, timelineView.currentMs + 1000);
            zoomEngine.updatePlayhead(timelineView.currentMs, studioSettings.zoomTransitionMs);
            recorderEngine.seekKeystrokes(timelineView.currentMs);
        }
    }
    Shortcut {
        sequence: "Ctrl+O"
        onActivated: {
            videoFileDialog.open();
        }
    }

    // KeyCast: Capture Keyboard Shortcuts for Video Visualizer
    Item {
        focus: true
        anchors.fill: parent
        Keys.onPressed: function(event) {
            var mods = [];
            if (event.modifiers & Qt.ControlModifier) mods.push("Ctrl");
            if (event.modifiers & Qt.MetaModifier) mods.push("Cmd");
            if (event.modifiers & Qt.AltModifier) mods.push("Alt");
            if (event.modifiers & Qt.ShiftModifier) mods.push("Shift");

            var keyName = "";
            if (event.key >= Qt.Key_A && event.key <= Qt.Key_Z) {
                keyName = String.fromCharCode(event.key);
            } else if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                keyName = String.fromCharCode(event.key);
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                keyName = "Enter";
            } else if (event.key === Qt.Key_Tab) {
                keyName = "Tab";
            } else if (event.key === Qt.Key_Escape) {
                keyName = "Esc";
            }

            if (mods.length > 0 && keyName !== "") {
                var combo = mods.join(" + ") + " + " + keyName;
                recorderEngine.recordKeystroke(combo);
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. Top Navigation Bar
        TopNavBar {
            id: topNav
            Layout.fillWidth: true
            currentMode: appWindow.currentMode

            onToggleMode: {
                appWindow.currentMode = (appWindow.currentMode === "editor") ? "recorder" : "editor";
            }
            onRequestUploadVideo: {
                videoFileDialog.open();
            }
            onOpenSupabaseDialog: {
                supabaseDialog.visible = true;
            }
            onTriggerInstantShare: {
                var vPath = recorderEngine.recordedVideoPath;
                if (!vPath || vPath === "") {
                    vPath = recorderEngine.recordDirectory + "/exact_test.mp4";
                }
                var durSec = Math.max(1, Math.round((timelineView.totalDurationMs > 0 ? timelineView.totalDurationMs : recorderEngine.lastRecordingDurationMs) / 1000));
                supabaseManager.uploadRecording(vPath, "Studio Recording", durSec, studioSettings.aspectRatio);
                shareModal.visible = true;
            }
            onTriggerExport: {
                var vPath = recorderEngine.recordedVideoPath;
                if (!vPath || vPath === "") {
                    vPath = recorderEngine.recordDirectory + "/exact_test.mp4";
                }
                exportManager.exportVideo(vPath, studioSettings, zoomEngine, supabaseManager, false);
            }
        }

        // 2. Main Content Area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // ==========================================
            // VIEW A: STUDIO EDITOR WORKSPACE
            // ==========================================
            RowLayout {
                anchors.fill: parent
                spacing: 0
                visible: appWindow.currentMode === "editor"

                // Center Column: Canvas + Timeline
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    // Canvas Viewport Area
                    StudioCanvas {
                        id: studioCanvas
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        playheadMs: timelineView.currentMs
                        isPlaying: timelineView.isPlaying

                        onRequestOpenVideoDialog: {
                            videoFileDialog.open();
                        }
                        onVideoPositionChanged: function(posMs) {
                            timelineView.currentMs = posMs;
                            zoomEngine.updatePlayhead(posMs, studioSettings.zoomTransitionMs);
                            aiCustomizer.updatePlayhead(posMs);
                        }
                        onVideoDurationChanged: function(durMs) {
                            timelineView.totalDurationMs = durMs;
                        }
                    }

                    // Bottom Multi-Track Timeline
                    TimelineView {
                        id: timelineView
                        Layout.fillWidth: true
                    }
                }

                // Right Column: Screen Studio Inspector Panel
                InspectorPanel {
                    id: inspectorPanel
                    Layout.fillHeight: true

                    onOpenSupabaseSettings: {
                        supabaseDialog.visible = true;
                    }
                    onOpenShareModal: {
                        var vPath = recorderEngine.recordedVideoPath;
                        if (!vPath || vPath === "") {
                            vPath = recorderEngine.recordDirectory + "/exact_test.mp4";
                        }
                        var durSec = Math.max(1, Math.round((timelineView.totalDurationMs > 0 ? timelineView.totalDurationMs : recorderEngine.lastRecordingDurationMs) / 1000));
                        supabaseManager.uploadRecording(vPath, "Studio Recording", durSec, studioSettings.aspectRatio);
                        shareModal.visible = true;
                    }
                }
            }

            // ==========================================
            // VIEW B: RECORDER LAUNCHER WORKSPACE
            // ==========================================
            Item {
                anchors.fill: parent
                visible: appWindow.currentMode === "recorder"

                Column {
                    anchors.centerIn: parent
                    spacing: 24

                    // Pulse Logo Badge
                    Rectangle {
                        width: 90
                        height: 90
                        radius: 45
                        anchors.horizontalCenter: parent.horizontalCenter
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "#6366f1" }
                            GradientStop { position: 1.0; color: "#06b6d4" }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "📹"
                            font.pixelSize: 42
                        }
                    }

                    Column {
                        spacing: 6
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            text: recorderEngine.state === "recording" ? "Recording in Progress..." : "Ready to Capture"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeTitle
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: recorderEngine.state === "recording"
                                ? "Saving raw video and 60Hz cursor telemetry to your local Videos folder"
                                : "Record your screen, microphone, and desktop loopback audio with zero lag"
                            color: studioTheme.textSecondary
                            font.pixelSize: studioTheme.fontSizeMd
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    // Recording Main Center Button
                    Rectangle {
                        width: 230
                        height: 56
                        radius: studioTheme.radiusPill
                        color: recorderEngine.state === "recording" ? studioTheme.statusRecording : studioTheme.accentPrimary
                        anchors.horizontalCenter: parent.horizontalCenter

                        Row {
                            anchors.centerIn: parent
                            spacing: 10
                            Text {
                                text: recorderEngine.state === "recording" ? "⏹" : "⏺"
                                font.pixelSize: 20
                                color: "#ffffff"
                            }
                            Text {
                                text: recorderEngine.state === "recording" ? "Stop Recording" : "Start Recording"
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: studioTheme.fontSizeLg
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (recorderEngine.state === "recording") {
                                    recorderEngine.stopRecording();
                                    appWindow.currentMode = "editor";
                                } else {
                                    recorderEngine.startRecording();
                                }
                            }
                        }
                    }
                }

                // Floating Recording Pill
                RecordingOverlay {
                    onFinishedRecording: {
                        appWindow.currentMode = "editor";
                    }
                }
            }
        }
    }

    // Modal Dialogs
    FileDialog {
        id: videoFileDialog
        title: "Select Video to Edit with Studio AI"
        fileMode: FileDialog.OpenFile
        nameFilters: [
            "Video files (*.mp4 *.mov *.webm *.mkv *.avi)",
            "All files (*)"
        ]
        currentFolder: "file://" + recorderEngine.recordDirectory
        onAccepted: {
            var path = selectedFile.toString();
            recorderEngine.openVideoFile(path);
            appWindow.currentMode = "editor";
        }
    }

    SupabaseDialog {
        id: supabaseDialog
        onClosed: visible = false
    }

    ShareModal {
        id: shareModal
        onClosed: visible = false
    }

    Connections {
        target: recorderEngine
        function onRecordingCompleted(filePath) {
            appWindow.currentMode = "editor";
        }
    }

    Connections {
        target: supabaseManager
        function onUploadCompleted(shareUrl) {
            shareModal.visible = true;
        }
    }
}
