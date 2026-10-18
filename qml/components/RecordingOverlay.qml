import QtQuick
import QtQuick.Controls

Item {
    id: overlayRoot
    anchors.fill: parent

    signal finishedRecording()

    // 1. Large 3-2-1 Countdown Overlay
    Rectangle {
        visible: recorderEngine.state === "countdown"
        anchors.fill: parent
        color: "#d9000000"
        z: 99

        Column {
            anchors.centerIn: parent
            spacing: 16

            Text {
                text: recorderEngine.countdownValue > 0 ? recorderEngine.countdownValue : "GO!"
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 120
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Get ready to record your screen..."
                color: studioTheme.textSecondary
                font.pixelSize: studioTheme.fontSizeLg
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // 2. Sleek Floating Mini-Recorder Bar
    Rectangle {
        id: floatingPill
        width: 480
        height: 64
        radius: studioTheme.radiusPill
        color: studioTheme.bgSurface
        border.color: recorderEngine.state === "recording" ? studioTheme.statusRecording : studioTheme.borderSubtle
        border.width: recorderEngine.state === "recording" ? 2 : 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        z: 50
        visible: recorderEngine.state === "recording" || recorderEngine.state === "paused"
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Row {
            anchors.centerIn: parent
            spacing: 16

            // Status Indicator & Timer
            Row {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: 14
                    height: 14
                    radius: 7
                    color: recorderEngine.state === "recording" ? studioTheme.statusRecording : (recorderEngine.state === "paused" ? studioTheme.statusWarning : studioTheme.textMuted)
                    anchors.verticalCenter: parent.verticalCenter

                    SequentialAnimation on opacity {
                        running: recorderEngine.state === "recording"
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
                        NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
                    }
                }

                Text {
                    text: recorderEngine.formattedTime
                    color: studioTheme.textPrimary
                    font.family: "monospace"
                    font.bold: true
                    font.pixelSize: studioTheme.fontSizeXl
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle { width: 1; height: 28; color: studioTheme.borderSubtle; anchors.verticalCenter: parent.verticalCenter }

            // Audio Level Mini Meters
            Column {
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter
                width: 60

                // Mic meter
                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 2
                    color: studioTheme.bgCard
                    Rectangle {
                        width: parent.width * audioManager.micLevel
                        height: parent.height
                        radius: 2
                        color: studioTheme.statusSuccess
                    }
                }
                // System meter
                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 2
                    color: studioTheme.bgCard
                    Rectangle {
                        width: parent.width * audioManager.systemAudioLevel
                        height: parent.height
                        radius: 2
                        color: studioTheme.accentCyan
                    }
                }
            }

            Rectangle { width: 1; height: 28; color: studioTheme.borderSubtle; anchors.verticalCenter: parent.verticalCenter }

            // Control Buttons
            Row {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter

                // Record Start / Stop Button
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: recorderEngine.state === "recording" ? studioTheme.statusRecording : studioTheme.accentPrimary

                    StudioIcon {
                        anchors.centerIn: parent
                        name: recorderEngine.state === "recording" ? "stop" : "record"
                        size: recorderEngine.state === "recording" ? 16 : 18
                        color: "#ffffff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (recorderEngine.state === "recording") {
                                recorderEngine.stopRecording();
                                overlayRoot.finishedRecording();
                            } else {
                                recorderEngine.startRecording();
                            }
                        }
                    }
                }

                // Pause / Resume Button
                Rectangle {
                    visible: recorderEngine.state === "recording" || recorderEngine.state === "paused"
                    width: 38
                    height: 38
                    radius: 19
                    color: studioTheme.bgCard
                    border.color: studioTheme.borderSubtle

                    StudioIcon {
                        anchors.centerIn: parent
                        name: recorderEngine.state === "paused" ? "play" : "pause"
                        size: 14
                        color: studioTheme.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (recorderEngine.state === "paused") {
                                recorderEngine.resumeRecording();
                            } else {
                                recorderEngine.pauseRecording();
                            }
                        }
                    }
                }

                // Cancel Button
                Rectangle {
                    visible: recorderEngine.state === "recording" || recorderEngine.state === "paused"
                    width: 38
                    height: 38
                    radius: 19
                    color: studioTheme.bgCard
                    border.color: studioTheme.borderSubtle

                    StudioIcon {
                        anchors.centerIn: parent
                        name: "close"
                        size: 12
                        color: studioTheme.textMuted
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: recorderEngine.cancelRecording()
                    }
                }
            }
        }
    }
}
