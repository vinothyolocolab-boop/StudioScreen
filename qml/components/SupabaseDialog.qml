import QtQuick
import QtQuick.Controls

Rectangle {
    id: dialogRoot
    anchors.fill: parent
    color: "#b3000000"
    visible: false
    z: 100

    signal closed()

    // Dialog Card
    Rectangle {
        width: 540
        height: 600
        radius: studioTheme.radiusLg
        color: studioTheme.bgSurface
        border.color: studioTheme.borderSubtle
        border.width: 1
        anchors.centerIn: parent

        Column {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 16

            // Dialog Header Container
            Item {
                width: parent.width
                height: 52

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Row {
                        spacing: 8
                        StudioIcon {
                            name: "export"
                            size: 18
                            color: studioTheme.accentCyan
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Supabase Cloud Setup"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeTitle
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Text {
                        text: "Instant cross-platform sharing & secure cloud storage"
                        color: studioTheme.textSecondary
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
                    color: closeMouse.containsMouse ? studioTheme.bgCardHover : studioTheme.bgCard

                    StudioIcon {
                        anchors.centerIn: parent
                        name: "close"
                        size: 12
                        color: studioTheme.textSecondary
                    }
                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: dialogRoot.closed()
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: studioTheme.borderSubtle }

            // Demo Mode Notice & Toggle Container
            Rectangle {
                width: parent.width
                height: 52
                radius: studioTheme.radiusSm
                color: "#1e1b4b"
                border.color: studioTheme.accentPrimary

                Item {
                    anchors.fill: parent
                    anchors.margins: 12

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        StudioIcon {
                            name: "ai"
                            size: 16
                            color: "#fbbf24"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text { text: "Demo Mode Active"; color: "#ffffff"; font.bold: true; font.pixelSize: studioTheme.fontSizeXs }
                            Text { text: "Instant cloud links work out of the box without keys"; color: "#a5b4fc"; font.pixelSize: 10 }
                        }
                    }

                    Switch {
                        id: demoSwitch
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        checked: supabaseManager.isDemoMode
                        onToggled: supabaseManager.setDemoMode(checked)
                    }
                }
            }

            // Supabase Project URL Input
            Column {
                width: parent.width
                spacing: 6

                Text { text: "Supabase Project URL"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                TextField {
                    id: urlField
                    width: parent.width
                    height: 40
                    text: supabaseManager.supabaseUrl
                    placeholderText: "https://xyzcompany.supabase.co"
                    color: studioTheme.textPrimary
                    background: Rectangle {
                        radius: studioTheme.radiusSm
                        color: studioTheme.bgCard
                        border.color: urlField.activeFocus ? studioTheme.accentPrimary : studioTheme.borderSubtle
                    }
                }
            }

            // Supabase Anon API Key Input
            Column {
                width: parent.width
                spacing: 6

                Text { text: "Anon Public API Key"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                TextField {
                    id: keyField
                    width: parent.width
                    height: 40
                    text: supabaseManager.anonKey
                    placeholderText: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                    echoMode: TextInput.PasswordEchoOnEdit
                    color: studioTheme.textPrimary
                    background: Rectangle {
                        radius: studioTheme.radiusSm
                        color: studioTheme.bgCard
                        border.color: keyField.activeFocus ? studioTheme.accentPrimary : studioTheme.borderSubtle
                    }
                }
            }

            // Storage Bucket Name Input
            Column {
                width: parent.width
                spacing: 6

                Text { text: "Storage Bucket Name"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                TextField {
                    id: bucketField
                    width: parent.width
                    height: 40
                    text: supabaseManager.bucketName
                    placeholderText: "recordings"
                    color: studioTheme.textPrimary
                    background: Rectangle {
                        radius: studioTheme.radiusSm
                        color: studioTheme.bgCard
                        border.color: bucketField.activeFocus ? studioTheme.accentPrimary : studioTheme.borderSubtle
                    }
                }
            }

            // Action Buttons
            Row {
                width: parent.width
                spacing: 12

                // Copy SQL Schema Button
                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 42
                    radius: studioTheme.radiusSm
                    color: studioTheme.bgCard
                    border.color: studioTheme.borderSubtle

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        StudioIcon {
                            name: "copy"
                            size: 14
                            color: studioTheme.textPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text { text: "Copy SQL Schema"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm; anchors.verticalCenter: parent.verticalCenter }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            supabaseManager.copyShareUrlToClipboard();
                            statusToast.text = "SQL Schema copied! Paste into Supabase SQL Editor.";
                            statusToast.visible = true;
                        }
                    }
                }

                // Save Configuration Button
                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 42
                    radius: studioTheme.radiusSm
                    color: studioTheme.accentPrimary

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        StudioIcon {
                            name: "save"
                            size: 14
                            color: "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text { text: "Save Settings"; color: "#ffffff"; font.bold: true; font.pixelSize: studioTheme.fontSizeSm; anchors.verticalCenter: parent.verticalCenter }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            supabaseManager.saveConfig(urlField.text, keyField.text, bucketField.text);
                            statusToast.text = "Configuration saved successfully!";
                            statusToast.visible = true;
                        }
                    }
                }
            }

            // Notification / Status Toast
            Text {
                id: statusToast
                visible: false
                text: ""
                color: studioTheme.statusSuccess
                font.pixelSize: studioTheme.fontSizeSm
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
