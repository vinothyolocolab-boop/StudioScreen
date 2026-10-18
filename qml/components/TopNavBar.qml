import QtQuick
import QtQuick.Controls

Rectangle {
    id: navRoot
    height: 56
    color: studioTheme.bgDark
    border.color: studioTheme.borderSubtle
    border.width: 1

    signal toggleMode()
    signal openSupabaseDialog()
    signal triggerInstantShare()
    signal triggerExport()
    signal requestUploadVideo()

    property string currentMode: "editor" // "recorder" or "editor"

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        // Brand Logo
        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: 32
                height: 32
                radius: 8
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#6366f1" }
                    GradientStop { position: 1.0; color: "#06b6d4" }
                }
                StudioIcon {
                    anchors.centerIn: parent
                    name: "facecam"
                    size: 16
                    color: "#ffffff"
                }
            }

            Text {
                text: "StudioScreen"
                color: studioTheme.textPrimary
                font.bold: true
                font.pixelSize: studioTheme.fontSizeLg
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                height: 20
                width: 32
                radius: 4
                color: "#1e1b4b"
                border.color: studioTheme.accentPrimary
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "AI"
                    color: "#818cf8"
                    font.bold: true
                    font.pixelSize: 10
                }
            }
        }

        Rectangle { width: 1; height: 24; color: studioTheme.borderSubtle; anchors.verticalCenter: parent.verticalCenter }

        // Mode Switcher Pill
        Rectangle {
            height: 34
            width: 220
            radius: studioTheme.radiusPill
            color: studioTheme.bgSurface
            border.color: studioTheme.borderSubtle
            anchors.verticalCenter: parent.verticalCenter

            Row {
                anchors.fill: parent

                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    radius: studioTheme.radiusPill
                    color: navRoot.currentMode === "recorder" ? studioTheme.accentPrimary : "transparent"

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        StudioIcon {
                            name: "record"
                            size: 10
                            color: navRoot.currentMode === "recorder" ? "#ffffff" : studioTheme.statusRecording
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Recorder"
                            color: navRoot.currentMode === "recorder" ? "#ffffff" : studioTheme.textSecondary
                            font.bold: navRoot.currentMode === "recorder"
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (navRoot.currentMode !== "recorder") navRoot.toggleMode();
                        }
                    }
                }

                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    radius: studioTheme.radiusPill
                    color: navRoot.currentMode === "editor" ? studioTheme.accentPrimary : "transparent"

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        StudioIcon {
                            name: "split"
                            size: 11
                            color: navRoot.currentMode === "editor" ? "#ffffff" : studioTheme.textSecondary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Studio"
                            color: navRoot.currentMode === "editor" ? "#ffffff" : studioTheme.textSecondary
                            font.bold: navRoot.currentMode === "editor"
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (navRoot.currentMode !== "editor") navRoot.toggleMode();
                        }
                    }
                }
            }
        }

        // Upload / Import Video Button
        Rectangle {
            height: 34
            width: 124
            radius: studioTheme.radiusPill
            color: uploadMouse.containsMouse ? studioTheme.bgCardHover : studioTheme.bgSurface
            border.color: uploadMouse.containsMouse ? studioTheme.accentPrimary : studioTheme.borderSubtle
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter

            Row {
                anchors.centerIn: parent
                spacing: 6
                StudioIcon { name: "folder"; size: 13; color: studioTheme.textPrimary; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: "Import Video"
                    color: studioTheme.textPrimary
                    font.bold: true
                    font.pixelSize: studioTheme.fontSizeSm
                }
            }

            MouseArea {
                id: uploadMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: navRoot.requestUploadVideo()
            }
        }

        // Screen Selector (Shown in Recorder Mode)
        ComboBox {
            id: screenCombo
            visible: navRoot.currentMode === "recorder"
            anchors.verticalCenter: parent.verticalCenter
            width: 180
            model: recorderEngine.availableScreens
            currentIndex: recorderEngine.selectedScreenIndex
            onActivated: recorderEngine.selectedScreenIndex = currentIndex
        }
    }

    // Right Actions Bar
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // Audio Status Chips
        Row {
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                height: 28
                width: 76
                radius: studioTheme.radiusSm
                color: audioManager.recordMic && !audioManager.micMuted ? "#064e3b" : studioTheme.bgCard
                border.color: audioManager.recordMic && !audioManager.micMuted ? "#059669" : studioTheme.borderSubtle

                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    StudioIcon { name: "audio"; size: 11; color: audioManager.recordMic && !audioManager.micMuted ? "#34d399" : studioTheme.textMuted; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: audioManager.recordMic && !audioManager.micMuted ? "Mic ON" : "Mic Muted"
                        color: audioManager.recordMic && !audioManager.micMuted ? "#34d399" : studioTheme.textMuted
                        font.pixelSize: 10
                    }
                }
            }

            Rectangle {
                height: 28
                width: 86
                radius: studioTheme.radiusSm
                color: audioManager.recordSystemAudio && !audioManager.systemMuted ? "#0e3a5a" : studioTheme.bgCard
                border.color: audioManager.recordSystemAudio && !audioManager.systemMuted ? "#0284c7" : studioTheme.borderSubtle

                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    StudioIcon { name: "speaker"; size: 11; color: audioManager.recordSystemAudio && !audioManager.systemMuted ? "#38bdf8" : studioTheme.textMuted; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: audioManager.recordSystemAudio && !audioManager.systemMuted ? "Desktop ON" : "Desktop OFF"
                        color: audioManager.recordSystemAudio && !audioManager.systemMuted ? "#38bdf8" : studioTheme.textMuted
                        font.pixelSize: 10
                    }
                }
            }

            // Facecam Toggle Chip
            Rectangle {
                height: 28
                width: 96
                radius: studioTheme.radiusSm
                color: studioSettings.webcamEnabled ? "#312e81" : studioTheme.bgCard
                border.color: studioSettings.webcamEnabled ? "#818cf8" : studioTheme.borderSubtle

                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    StudioIcon { name: "facecam"; size: 11; color: studioSettings.webcamEnabled ? "#c7d2fe" : studioTheme.textMuted; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: studioSettings.webcamEnabled ? "Facecam ON" : "Facecam OFF"
                        color: studioSettings.webcamEnabled ? "#c7d2fe" : studioTheme.textMuted
                        font.pixelSize: 10
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: studioSettings.webcamEnabled = !studioSettings.webcamEnabled
                }
            }
        }

        // GIF Quick Export Button
        Rectangle {
            height: 36
            width: 76
            radius: studioTheme.radiusSm
            color: gifMouse.containsMouse ? studioTheme.bgCardHover : studioTheme.bgCard
            border.color: studioTheme.borderSubtle

            Row {
                anchors.centerIn: parent
                spacing: 5
                StudioIcon { name: "gif"; size: 13; color: studioTheme.textPrimary; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: "GIF"
                    color: studioTheme.textPrimary
                    font.bold: true
                    font.pixelSize: studioTheme.fontSizeSm
                }
            }
            MouseArea {
                id: gifMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    studioSettings.exportFormat = "gif";
                    navRoot.triggerExport();
                }
            }
        }

        // Export MP4 Button
        Rectangle {
            height: 36
            width: 104
            radius: studioTheme.radiusSm
            color: exportMouse.containsMouse ? studioTheme.bgCardHover : studioTheme.bgCard
            border.color: studioTheme.borderSubtle

            Row {
                anchors.centerIn: parent
                spacing: 6
                StudioIcon { name: "save"; size: 13; color: studioTheme.textPrimary; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: exportManager.isExporting ? "Rendering..." : "Export MP4"
                    color: studioTheme.textPrimary
                    font.bold: true
                    font.pixelSize: studioTheme.fontSizeSm
                }
            }
            MouseArea {
                id: exportMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: navRoot.triggerExport()
            }
        }

        // Instant Share Button (Supabase)
        Rectangle {
            height: 36
            width: 130
            radius: studioTheme.radiusSm
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#10b981" }
                GradientStop { position: 1.0; color: "#059669" }
            }

            Row {
                anchors.centerIn: parent
                spacing: 6
                StudioIcon { name: "export"; size: 13; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: "Instant Share"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: studioTheme.fontSizeSm
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: navRoot.triggerInstantShare()
            }
        }

        // Supabase Settings Gear
        Rectangle {
            height: 36
            width: 36
            radius: studioTheme.radiusSm
            color: gearMouse.containsMouse ? studioTheme.bgCardHover : studioTheme.bgCard
            border.color: studioTheme.borderSubtle

            StudioIcon {
                anchors.centerIn: parent
                name: "settings"
                size: 16
                color: gearMouse.containsMouse ? "#ffffff" : studioTheme.textSecondary
            }
            MouseArea {
                id: gearMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: navRoot.openSupabaseDialog()
            }
        }
    }
}
