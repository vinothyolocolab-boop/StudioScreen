import QtQuick
import QtQuick.Controls

Rectangle {
    id: shareModalRoot
    anchors.fill: parent
    color: "#b3000000"
    visible: false
    z: 100

    signal closed()

    Rectangle {
        width: 560
        height: 540
        radius: studioTheme.radiusLg
        color: studioTheme.bgSurface
        border.color: studioTheme.borderSubtle
        border.width: 1
        anchors.centerIn: parent

        Column {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 18

            // Header Container
            Item {
                width: parent.width
                height: 50

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Row {
                        spacing: 8
                        StudioIcon {
                            name: "share"
                            size: 18
                            color: studioTheme.statusSuccess
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Video Ready for Instant Sharing!"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeXl
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Text {
                        text: supabaseManager.isCloudUrl ? "24/7 Autoplay Link Active — Plays instantly even when app is closed!" : "Streaming via built-in server (configure Supabase for custom cloud storage)"
                        color: supabaseManager.isCloudUrl ? "#34d399" : studioTheme.textSecondary
                        font.pixelSize: studioTheme.fontSizeSm
                    }
                }

                Rectangle {
                    id: closeBtn
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    height: 32
                    radius: 16
                    color: closeM.containsMouse ? studioTheme.bgCardHover : studioTheme.bgCard

                    StudioIcon {
                        anchors.centerIn: parent
                        name: "close"
                        size: 12
                        color: studioTheme.textSecondary
                    }
                    MouseArea {
                        id: closeM
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: shareModalRoot.closed()
                    }
                }
            }

            // Cloud Upload Progress Bar (when uploading)
            Rectangle {
                visible: supabaseManager.isUploading
                width: parent.width
                height: 32
                radius: 6
                color: studioTheme.bgCard
                border.color: studioTheme.accentPrimary
                clip: true

                Rectangle {
                    width: parent.width * Math.max(0.05, supabaseManager.uploadProgress)
                    height: parent.height
                    radius: 6
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#6366f1" }
                        GradientStop { position: 1.0; color: "#06b6d4" }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: supabaseManager.statusMessage
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 11
                }
            }

            // Share Link Box
            Rectangle {
                width: parent.width
                height: 54
                radius: studioTheme.radiusSm
                color: studioTheme.bgCard
                border.color: supabaseManager.isCloudUrl ? "#059669" : studioTheme.accentPrimary
                border.width: 1.5

                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    StudioIcon {
                        name: supabaseManager.isCloudUrl ? "cloud" : "share"
                        size: 16
                        color: supabaseManager.isCloudUrl ? "#34d399" : studioTheme.accentCyan
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: supabaseManager.currentShareUrl !== "" ? supabaseManager.currentShareUrl : shareServer.lanShareUrl
                        color: supabaseManager.isCloudUrl ? "#34d399" : studioTheme.accentCyan
                        font.bold: true
                        font.pixelSize: studioTheme.fontSizeSm
                        elide: Text.ElideMiddle
                        width: parent.width - 150
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        id: copyBtn
                        width: 90
                        height: 34
                        radius: studioTheme.radiusSm
                        color: copyM.containsMouse ? "#4f46e5" : studioTheme.accentPrimary
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "Copy Link"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        MouseArea {
                            id: copyM
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                supabaseManager.copyShareUrlToClipboard();
                                copiedToast.text = supabaseManager.isCloudUrl ? "Cloud link copied! Works anywhere even when app is closed." : "Link copied to clipboard!";
                                copiedToast.visible = true;
                            }
                        }
                    }
                }
            }

            // Local Storage Path Box
            Rectangle {
                width: parent.width
                height: 46
                radius: studioTheme.radiusSm
                color: studioTheme.bgCard
                border.color: studioTheme.borderSubtle

                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    StudioIcon {
                        name: "save"
                        size: 14
                        color: studioTheme.textSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Saved to: " + (recorderEngine.recordedVideoPath !== "" ? recorderEngine.recordedVideoPath : (recorderEngine.recordDirectory + "/exact_test.mp4"))
                        color: studioTheme.textSecondary
                        font.pixelSize: studioTheme.fontSizeXs
                        elide: Text.ElideMiddle
                        width: parent.width - 160
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: 100
                        height: 28
                        radius: 4
                        color: folderM.containsMouse ? studioTheme.bgCardHover : "#1e293b"
                        border.color: studioTheme.borderSubtle
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "Open Folder"
                            color: studioTheme.textPrimary
                            font.pixelSize: 11
                        }
                        MouseArea {
                            id: folderM
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: recorderEngine.openRecordingsFolder()
                        }
                    }
                }
            }

            // QR Code Mock & Details
            Rectangle {
                width: parent.width
                height: 130
                radius: studioTheme.radiusSm
                color: studioTheme.bgCard
                border.color: studioTheme.borderSubtle

                Row {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 18

                    // QR Code Box
                    Rectangle {
                        width: 100
                        height: 100
                        radius: 8
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter

                        Grid {
                            anchors.centerIn: parent
                            columns: 6
                            spacing: 3
                            Repeater {
                                model: 36
                                delegate: Rectangle {
                                    width: 12
                                    height: 12
                                    color: (index % 3 === 0 || index % 5 === 0) ? "#0f172a" : "transparent"
                                }
                            }
                        }
                    }

                    // Sharing Options
                    Column {
                        spacing: 6
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 140

                        Row {
                            spacing: 6
                            StudioIcon {
                                name: supabaseManager.isCloudUrl ? "cloud" : "export"
                                size: 14
                                color: supabaseManager.isCloudUrl ? "#34d399" : studioTheme.accentCyan
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: supabaseManager.isCloudUrl ? "24/7 Cloud Video Stream:" : "Local LAN Streaming Live:"
                                color: studioTheme.textPrimary
                                font.bold: true
                                font.pixelSize: studioTheme.fontSizeSm
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            text: supabaseManager.isCloudUrl
                                ? "• Plays automatically in any browser — zero download click required!\n• Hosted in the cloud — stays online 24/7 even after closing this app\n• Share directly to Slack, WhatsApp, Twitter, or email with rich player"
                                : "• Fast peer-to-peer streaming on your local Wi-Fi network\n• Note: Keep app open for local streaming, or configure Supabase for custom cloud storage"
                            color: studioTheme.textSecondary
                            font.pixelSize: studioTheme.fontSizeXs
                            lineHeight: 1.4
                        }
                    }
                }
            }

            // Copied Toast
            Row {
                id: copiedToast
                visible: false
                spacing: 6
                anchors.horizontalCenter: parent.horizontalCenter

                StudioIcon {
                    name: "check"
                    size: 13
                    color: studioTheme.statusSuccess
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Link copied! Ready to paste into browser or Slack."
                    color: studioTheme.statusSuccess
                    font.bold: true
                    font.pixelSize: studioTheme.fontSizeSm
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Action Buttons (Open in Browser & Done)
            Row {
                width: parent.width
                spacing: 12

                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 44
                    radius: studioTheme.radiusSm
                    color: openBrowserM.containsMouse ? "#4338ca" : studioTheme.accentPrimary

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        StudioIcon {
                            name: "globe"
                            size: 14
                            color: "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Open in Browser"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        id: openBrowserM
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: supabaseManager.openShareUrlInBrowser()
                    }
                }

                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 44
                    radius: studioTheme.radiusSm
                    color: doneM.containsMouse ? "#059669" : studioTheme.statusSuccess

                    Text {
                        anchors.centerIn: parent
                        text: "Done"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: studioTheme.fontSizeSm
                    }
                    MouseArea {
                        id: doneM
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: shareModalRoot.closed()
                    }
                }
            }
        }
    }
}
