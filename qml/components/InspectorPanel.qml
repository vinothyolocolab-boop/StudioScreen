import QtQuick
import QtQuick.Controls

Rectangle {
    id: inspectorRoot
    width: 360
    color: studioTheme.bgDark
    border.color: studioTheme.borderSubtle
    border.width: 1

    signal openSupabaseSettings()
    signal openShareModal()

    property int activeTab: 0 // 0: Frame, 1: Zoom, 2: Cursor, 3: Facecam, 4: BG, 5: Audio, 6: AI, 7: Export

    Column {
        anchors.fill: parent
        spacing: 0

        // Tab Navigation Header (8 Comprehensive Tabs)
        Rectangle {
            width: parent.width
            height: 54
            color: studioTheme.bgSurface
            border.color: studioTheme.borderSubtle

            Row {
                anchors.fill: parent

                Repeater {
                    model: [
                        { icon: "frame", name: "Frame" },
                        { icon: "zoom", name: "Zoom" },
                        { icon: "cursor", name: "Cursor" },
                        { icon: "facecam", name: "Facecam" },
                        { icon: "bg", name: "BG" },
                        { icon: "audio", name: "Audio" },
                        { icon: "ai", name: "AI" },
                        { icon: "export", name: "Export" }
                    ]
                    delegate: Rectangle {
                        width: parent.width / 8
                        height: parent.height
                        color: inspectorRoot.activeTab === index ? studioTheme.bgCard : (tabMouse.containsMouse ? studioTheme.bgCardHover : "transparent")
                        border.color: inspectorRoot.activeTab === index ? studioTheme.accentPrimary : "transparent"
                        border.width: inspectorRoot.activeTab === index ? 2 : 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 4
                            StudioIcon {
                                name: modelData.icon
                                size: 15
                                color: inspectorRoot.activeTab === index ? "#ffffff" : studioTheme.textSecondary
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: modelData.name
                                color: inspectorRoot.activeTab === index ? "#ffffff" : studioTheme.textSecondary
                                font.bold: inspectorRoot.activeTab === index
                                font.pixelSize: 9
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        MouseArea {
                            id: tabMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: inspectorRoot.activeTab = index
                        }
                    }
                }
            }
        }

        // Tab Contents Scroll Area
        ScrollView {
            width: parent.width
            height: parent.height - 54
            clip: true
            contentWidth: width

            Column {
                width: parent.width - 24
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                topPadding: 16
                bottomPadding: 32

                // ==========================================
                // TAB 0: FRAME & RESOLUTION
                // ==========================================
                Column {
                    visible: inspectorRoot.activeTab === 0
                    width: parent.width
                    spacing: 16

                    Text { text: "Canvas Aspect Ratio"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }

                    Row {
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: ["16:9", "9:16", "1:1", "4:3", "4:5"]
                            delegate: Rectangle {
                                width: (parent.width - 24) / 5
                                height: 32
                                radius: studioTheme.radiusSm
                                color: studioSettings.aspectRatio === modelData ? studioTheme.accentPrimary : studioTheme.bgCard
                                border.color: studioTheme.borderSubtle

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: studioSettings.aspectRatio === modelData ? "#ffffff" : studioTheme.textSecondary
                                    font.bold: true
                                    font.pixelSize: studioTheme.fontSizeXs
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: studioSettings.aspectRatio = modelData
                                }
                            }
                        }
                    }

                    Text { text: "Playback Speed"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Row {
                        width: parent.width
                        spacing: 8
                        Repeater {
                            model: [
                                { label: "0.5x", speed: 0.5 },
                                { label: "1.0x", speed: 1.0 },
                                { label: "1.25x", speed: 1.25 },
                                { label: "1.5x", speed: 1.5 },
                                { label: "2.0x", speed: 2.0 }
                            ]
                            delegate: Rectangle {
                                width: (parent.width - 32) / 5
                                height: 28
                                radius: studioTheme.radiusSm
                                color: Math.abs(studioSettings.playbackSpeed - modelData.speed) < 0.05 ? studioTheme.accentCyan : studioTheme.bgCard
                                border.color: studioTheme.borderSubtle
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: Math.abs(studioSettings.playbackSpeed - modelData.speed) < 0.05 ? "#000000" : studioTheme.textSecondary
                                    font.bold: true
                                    font.pixelSize: studioTheme.fontSizeXs
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: studioSettings.playbackSpeed = modelData.speed
                                }
                            }
                        }
                    }

                    Text { text: "Inset Padding (" + studioSettings.canvasPadding + "px)"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Slider {
                        width: parent.width
                        from: 10
                        to: 140
                        value: studioSettings.canvasPadding
                        onMoved: studioSettings.canvasPadding = value
                    }

                    // Keystrokes Visualizer Overlay Control (Screen Studio feature)
                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Keyboard Shortcut Visualizer (KeyCast)"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: studioSettings.keystrokesEnabled
                            onToggled: studioSettings.keystrokesEnabled = checked
                        }
                    }

                    Text { text: "Shortcut Pill Position"; color: studioTheme.textSecondary; font.pixelSize: studioTheme.fontSizeXs }
                    Row {
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: [
                                { id: "bottomLeft", name: "Bottom Left" },
                                { id: "bottomRight", name: "Bottom Right" },
                                { id: "topLeft", name: "Top Left" },
                                { id: "topRight", name: "Top Right" }
                            ]
                            delegate: Rectangle {
                                width: (parent.width - 18) / 4
                                height: 28
                                radius: 4
                                color: studioSettings.keystrokesPosition === modelData.id ? studioTheme.accentPrimary : studioTheme.bgCard
                                border.color: studioTheme.borderSubtle
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: studioSettings.keystrokesPosition === modelData.id ? "#ffffff" : studioTheme.textSecondary
                                    font.bold: studioSettings.keystrokesPosition === modelData.id
                                    font.pixelSize: 9
                                }
                                MouseArea { anchors.fill: parent; onClicked: studioSettings.keystrokesPosition = modelData.id }
                            }
                        }
                    }

                    Text { text: "Corner Radius (" + studioSettings.cornerRadius + "px)"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Slider {
                        width: parent.width
                        from: 0
                        to: 42
                        value: studioSettings.cornerRadius
                        onMoved: studioSettings.cornerRadius = value
                    }

                    Text { text: "Window Drop Shadow (" + Math.round(studioSettings.shadowOpacity * 100) + "%)"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Slider {
                        width: parent.width
                        from: 0.0
                        to: 0.8
                        value: studioSettings.shadowOpacity
                        onMoved: studioSettings.shadowOpacity = value
                    }
                }

                // ==========================================
                // TAB 1: CAMERA & SMOOTH ZOOM
                // ==========================================
                Column {
                    visible: inspectorRoot.activeTab === 1
                    width: parent.width
                    spacing: 16

                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Auto-Zoom on Clicks"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: studioSettings.autoZoomEnabled
                            onToggled: studioSettings.autoZoomEnabled = checked
                        }
                    }

                    Text { text: "Default Zoom Depth (" + studioSettings.defaultZoomScale.toFixed(1) + "x)"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Slider {
                        width: parent.width
                        from: 1.2
                        to: 3.2
                        value: studioSettings.defaultZoomScale
                        onMoved: studioSettings.defaultZoomScale = value
                    }

                    Text { text: "Hermite Transition (" + studioSettings.zoomTransitionMs + "ms)"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Slider {
                        width: parent.width
                        from: 150
                        to: 800
                        value: studioSettings.zoomTransitionMs
                        onMoved: studioSettings.zoomTransitionMs = value
                    }

                    // Selected Zoom Block Inspector (Screen Studio feature)
                    Rectangle {
                        visible: zoomEngine.selectedSegmentId !== -1
                        width: parent.width
                        height: selectedZoomCol.height + 24
                        radius: studioTheme.radiusSm
                        color: studioTheme.bgSurface
                        border.color: studioTheme.accentPrimary
                        border.width: 1.5

                        Column {
                            id: selectedZoomCol
                            anchors.centerIn: parent
                            width: parent.width - 24
                            spacing: 10

                            Row {
                                width: parent.width
                                spacing: 6
                                StudioIcon { name: "zoom"; size: 13; color: studioTheme.accentCyan; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "Selected Zoom Block #" + zoomEngine.selectedSegmentId
                                    color: studioTheme.accentCyan
                                    font.bold: true
                                    font.pixelSize: studioTheme.fontSizeSm
                                }
                            }

                            Text {
                                text: "Focal Target X (" + Math.round((zoomEngine.selectedSegment.targetX || 0.5) * 100) + "%)"
                                color: studioTheme.textPrimary
                                font.pixelSize: studioTheme.fontSizeXs
                            }
                            Slider {
                                width: parent.width
                                from: 0.05
                                to: 0.95
                                value: zoomEngine.selectedSegment.targetX !== undefined ? zoomEngine.selectedSegment.targetX : 0.5
                                onMoved: zoomEngine.setSegmentTarget(zoomEngine.selectedSegmentId, value, zoomEngine.selectedSegment.targetY !== undefined ? zoomEngine.selectedSegment.targetY : 0.5)
                            }

                            Text {
                                text: "Focal Target Y (" + Math.round((zoomEngine.selectedSegment.targetY || 0.5) * 100) + "%)"
                                color: studioTheme.textPrimary
                                font.pixelSize: studioTheme.fontSizeXs
                            }
                            Slider {
                                width: parent.width
                                from: 0.05
                                to: 0.95
                                value: zoomEngine.selectedSegment.targetY !== undefined ? zoomEngine.selectedSegment.targetY : 0.5
                                onMoved: zoomEngine.setSegmentTarget(zoomEngine.selectedSegmentId, zoomEngine.selectedSegment.targetX !== undefined ? zoomEngine.selectedSegment.targetX : 0.5, value)
                            }

                            Text {
                                text: "Zoom Scale (" + Number(zoomEngine.selectedSegment.scale || 1.9).toFixed(1) + "x)"
                                color: studioTheme.textPrimary
                                font.pixelSize: studioTheme.fontSizeXs
                            }
                            Slider {
                                width: parent.width
                                from: 1.1
                                to: 3.2
                                value: zoomEngine.selectedSegment.scale !== undefined ? zoomEngine.selectedSegment.scale : 1.9
                                onMoved: zoomEngine.setSegmentScale(zoomEngine.selectedSegmentId, value)
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    width: (parent.width - 8) / 2
                                    height: 32
                                    radius: 4
                                    color: studioTheme.bgCard
                                    border.color: studioTheme.borderSubtle
                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 5
                                        StudioIcon { name: "copy"; size: 12; color: studioTheme.textPrimary }
                                        Text { text: "Duplicate"; color: studioTheme.textPrimary; font.pixelSize: 11 }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: zoomEngine.duplicateSegment(zoomEngine.selectedSegmentId) }
                                }
                                Rectangle {
                                    width: (parent.width - 8) / 2
                                    height: 32
                                    radius: 4
                                    color: "#ef4444"
                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 5
                                        StudioIcon { name: "trash"; size: 12; color: "#ffffff" }
                                        Text { text: "Delete"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: zoomEngine.removeSegment(zoomEngine.selectedSegmentId) }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 40
                        radius: studioTheme.radiusSm
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#6366f1" }
                            GradientStop { position: 1.0; color: "#8b5cf6" }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            StudioIcon { name: "ai"; size: 14; color: "#ffffff" }
                            Text {
                                text: "Auto-Plan Camera Shots from Clicks"
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: studioTheme.fontSizeSm
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: zoomEngine.generateAutoZoomsFromClicks(recorderEngine.recordedClicks, studioSettings.defaultZoomScale)
                        }
                    }
                }

                // ==========================================
                // TAB 2: CURSOR & BUTTERY MOTION
                // ==========================================
                Column {
                    visible: inspectorRoot.activeTab === 2
                    width: parent.width
                    spacing: 16

                    Text { text: "Cursor Style"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }

                    Column {
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: [
                                { id: "macos_black", name: "macOS Dark Pointer" },
                                { id: "macos_white", name: "macOS Light Pointer" },
                                { id: "neon_cyan", name: "Cyber Neon Pointer" },
                                { id: "highlight_circle", name: "Highlight Circle Halo" },
                                { id: "crosshair", name: "Precision Crosshair" }
                            ]
                            delegate: Rectangle {
                                width: parent.width
                                height: 34
                                radius: studioTheme.radiusSm
                                color: studioSettings.cursorStyle === modelData.id ? studioTheme.bgCardHover : studioTheme.bgCard
                                border.color: studioSettings.cursorStyle === modelData.id ? studioTheme.accentPrimary : studioTheme.borderSubtle

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.name
                                    color: studioSettings.cursorStyle === modelData.id ? "#ffffff" : studioTheme.textSecondary
                                    font.bold: studioSettings.cursorStyle === modelData.id
                                    font.pixelSize: studioTheme.fontSizeSm
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: studioSettings.cursorStyle = modelData.id
                                }
                            }
                        }
                    }

                    Text { text: "Cursor Scale (" + studioSettings.cursorScale.toFixed(1) + "x)"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Slider {
                        width: parent.width
                        from: 0.8
                        to: 3.2
                        value: studioSettings.cursorScale
                        onMoved: studioSettings.cursorScale = value
                    }

                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Auto-Hide When Inactive (>2s)"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: studioSettings.cursorAutoHideStationary
                            onToggled: studioSettings.cursorAutoHideStationary = checked
                        }
                    }

                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Click Ripple Animation"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: studioSettings.clickRippleEnabled
                            onToggled: studioSettings.clickRippleEnabled = checked
                        }
                    }

                    Text { text: "Motion Smoothing Mode"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Row {
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: [
                                { id: "cinematic", name: "Cinematic Glide" },
                                { id: "snappy", name: "Snappy Pro" },
                                { id: "natural", name: "Natural Fluid" }
                            ]
                            delegate: Rectangle {
                                width: (parent.width - 12) / 3
                                height: 32
                                radius: studioTheme.radiusSm
                                color: studioSettings.cursorMotionMode === modelData.id ? studioTheme.accentPrimary : studioTheme.bgCard
                                border.color: studioTheme.borderSubtle
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: studioSettings.cursorMotionMode === modelData.id ? "#ffffff" : studioTheme.textSecondary
                                    font.bold: studioSettings.cursorMotionMode === modelData.id
                                    font.pixelSize: 10
                                }
                                MouseArea { anchors.fill: parent; onClicked: studioSettings.cursorMotionMode = modelData.id }
                            }
                        }
                    }

                    Text { text: "Click Animation Style"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Row {
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: [
                                { id: "ripple", name: "Ripple Ring" },
                                { id: "neonRing", name: "Neon Dual" },
                                { id: "burst", name: "Starburst" }
                            ]
                            delegate: Rectangle {
                                width: (parent.width - 12) / 3
                                height: 32
                                radius: studioTheme.radiusSm
                                color: studioSettings.clickAnimationType === modelData.id ? studioTheme.accentPrimary : studioTheme.bgCard
                                border.color: studioTheme.borderSubtle
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: studioSettings.clickAnimationType === modelData.id ? "#ffffff" : studioTheme.textSecondary
                                    font.bold: studioSettings.clickAnimationType === modelData.id
                                    font.pixelSize: 10
                                }
                                MouseArea { anchors.fill: parent; onClicked: studioSettings.clickAnimationType = modelData.id }
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Click Sound Effect"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: studioSettings.cursorClickSound
                            onToggled: studioSettings.cursorClickSound = checked
                        }
                    }

                    Text { text: "Ripple Color"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Row {
                        spacing: 12
                        Repeater {
                            model: ["#38bdf8", "#f59e0b", "#ec4899", "#10b981", "#8b5cf6"]
                            delegate: Rectangle {
                                width: 28
                                height: 28
                                radius: 14
                                color: modelData
                                border.color: studioSettings.rippleColor === modelData ? "#ffffff" : "transparent"
                                border.width: 2

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: studioSettings.rippleColor = modelData
                                }
                            }
                        }
                    }
                }

                // ==========================================
                // TAB 3: FACECAM / WEBCAM PIP OVERLAY
                // ==========================================
                Column {
                    visible: inspectorRoot.activeTab === 3
                    width: parent.width
                    spacing: 16

                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Enable Facecam Overlay"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: studioSettings.webcamEnabled
                            onToggled: studioSettings.webcamEnabled = checked
                        }
                    }

                    Text { text: "Facecam Shape"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Row {
                        width: parent.width
                        spacing: 8
                        Repeater {
                            model: [
                                { id: "circle", name: "Circle" },
                                { id: "rounded", name: "Rounded" },
                                { id: "square", name: "Square" }
                            ]
                            delegate: Rectangle {
                                width: (parent.width - 16) / 3
                                height: 32
                                radius: studioTheme.radiusSm
                                color: studioSettings.webcamShape === modelData.id ? studioTheme.accentPrimary : studioTheme.bgCard
                                border.color: studioTheme.borderSubtle
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: studioSettings.webcamShape === modelData.id ? "#ffffff" : studioTheme.textSecondary
                                    font.bold: true
                                    font.pixelSize: studioTheme.fontSizeXs
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: studioSettings.webcamShape = modelData.id
                                }
                            }
                        }
                    }

                    Text { text: "Anchor Position"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Grid {
                        columns: 2
                        width: parent.width
                        spacing: 8
                        Repeater {
                            model: [
                                { id: "bottom_right", name: "Bottom Right" },
                                { id: "bottom_left", name: "Bottom Left" },
                                { id: "top_right", name: "Top Right" },
                                { id: "top_left", name: "Top Left" }
                            ]
                            delegate: Rectangle {
                                width: (parent.width - 8) / 2
                                height: 32
                                radius: studioTheme.radiusSm
                                color: studioSettings.webcamPosition === modelData.id ? studioTheme.accentPrimary : studioTheme.bgCard
                                border.color: studioTheme.borderSubtle
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: studioSettings.webcamPosition === modelData.id ? "#ffffff" : studioTheme.textSecondary
                                    font.bold: true
                                    font.pixelSize: studioTheme.fontSizeXs
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: studioSettings.webcamPosition = modelData.id
                                }
                            }
                        }
                    }

                    Text { text: "Facecam Size (" + studioSettings.webcamSize + "px)"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Slider {
                        width: parent.width
                        from: 90
                        to: 280
                        value: studioSettings.webcamSize
                        onMoved: studioSettings.webcamSize = Math.round(value)
                    }

                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Mirror Video Feed"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: studioSettings.webcamMirror
                            onToggled: studioSettings.webcamMirror = checked
                        }
                    }

                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Smart Auto-Ducking (Fade When Cursor Near)"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: studioSettings.webcamAutoDuck
                            onToggled: studioSettings.webcamAutoDuck = checked
                        }
                    }
                }

                // ==========================================
                // TAB 4: WALLPAPERS & BACKDROP
                // ==========================================
                Column {
                    visible: inspectorRoot.activeTab === 4
                    width: parent.width
                    spacing: 16

                    Text { text: "Preset Wallpapers"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }

                    Grid {
                        columns: 2
                        spacing: 10
                        width: parent.width

                        Repeater {
                            model: [
                                { id: "sonoma", name: "Sonoma Sunset", c1: "#8b5cf6", c2: "#ec4899" },
                                { id: "sunset", name: "Sunset Glow", c1: "#7f1d1d", c2: "#fbbf24" },
                                { id: "midnight", name: "Midnight Ocean", c1: "#030712", c2: "#0284c7" },
                                { id: "cyberpunk", name: "Cyberpunk Neon", c1: "#581c87", c2: "#06b6d4" },
                                { id: "aurora", name: "Emerald Aurora", c1: "#022c22", c2: "#06b6d4" },
                                { id: "dark_slate", name: "Dark Slate Minimal", c1: "#0b0f19", c2: "#334155" }
                            ]
                            delegate: Rectangle {
                                width: (parent.width - 10) / 2
                                height: 60
                                radius: studioTheme.radiusSm
                                border.color: studioSettings.wallpaperPreset === modelData.id ? "#ffffff" : studioTheme.borderSubtle
                                border.width: studioSettings.wallpaperPreset === modelData.id ? 2 : 1
                                clip: true

                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: modelData.c1 }
                                    GradientStop { position: 1.0; color: modelData.c2 }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: studioTheme.fontSizeXs
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: studioSettings.wallpaperPreset = modelData.id
                                }
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Ambient Breathing Motion"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: studioSettings.ambientMotion
                            onToggled: studioSettings.ambientMotion = checked
                        }
                    }
                }

                // ==========================================
                // TAB 5: AUDIO STUDIO & NOISE SUPPRESSION
                // ==========================================
                Column {
                    visible: inspectorRoot.activeTab === 5
                    width: parent.width
                    spacing: 16

                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Studio Noise Suppression"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: audioManager.noiseSuppression
                            onToggled: audioManager.noiseSuppression = checked
                        }
                    }

                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Voice Clarity Enhancer"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: audioManager.voiceClarity
                            onToggled: audioManager.voiceClarity = checked
                        }
                    }

                    Text { text: "Microphone Gain (" + Math.round(audioManager.micVolume * 100) + "%)"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Slider {
                        width: parent.width
                        from: 0.0
                        to: 1.5
                        value: audioManager.micVolume
                        onMoved: audioManager.micVolume = value
                    }

                    Text { text: "System Audio Gain (" + Math.round(audioManager.systemVolume * 100) + "%)"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Slider {
                        width: parent.width
                        from: 0.0
                        to: 1.5
                        value: audioManager.systemVolume
                        onMoved: audioManager.systemVolume = value
                    }
                }

                // ==========================================
                // TAB 6: AI STUDIO (GEMINI POWERED)
                // ==========================================
                Column {
                    visible: inspectorRoot.activeTab === 6
                    width: parent.width
                    spacing: 16

                    Rectangle {
                        width: parent.width
                        height: 42
                        radius: studioTheme.radiusSm
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#06b6d4" }
                            GradientStop { position: 1.0; color: "#3b82f6" }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            StudioIcon { name: "ai"; size: 14; color: "#ffffff" }
                            Text {
                                text: "Generate Hormozi AI Captions"
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: studioTheme.fontSizeSm
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: aiCustomizer.generateCaptions("", 15000)
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 42
                        radius: studioTheme.radiusSm
                        color: studioTheme.bgCard
                        border.color: studioTheme.borderSubtle

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            StudioIcon { name: "split"; size: 14; color: studioTheme.textPrimary }
                            Text {
                                text: "Auto-Trim Silence & Pauses"
                                color: studioTheme.textPrimary
                                font.bold: true
                                font.pixelSize: studioTheme.fontSizeSm
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: aiCustomizer.detectSilences(15000)
                        }
                    }

                    Text { text: "Prompt-to-Video Transformation"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }

                    TextField {
                        id: promptField
                        width: parent.width
                        placeholderText: "e.g. 9:16 vertical reels with Sunset wallpaper and deep zooms"
                        color: studioTheme.textPrimary
                        background: Rectangle {
                            radius: studioTheme.radiusSm
                            color: studioTheme.bgCard
                            border.color: promptField.activeFocus ? studioTheme.accentPrimary : studioTheme.borderSubtle
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 38
                        radius: studioTheme.radiusSm
                        color: studioTheme.accentPrimary

                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            StudioIcon { name: "wand"; size: 14; color: "#ffffff" }
                            Text {
                                text: "Apply Prompt"
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: studioTheme.fontSizeSm
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: aiCustomizer.applyAiPrompt(promptField.text, studioSettings, zoomEngine)
                        }
                    }
                }

                // ==========================================
                // TAB 7: PRODUCTION EXPORT & SHARING
                // ==========================================
                Column {
                    visible: inspectorRoot.activeTab === 7
                    width: parent.width
                    spacing: 16

                    Text { text: "Export Format"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Row {
                        width: parent.width
                        spacing: 8
                        Repeater {
                            model: [
                                { id: "mp4", name: "MP4 Video" },
                                { id: "gif", name: "Crisp GIF" }
                            ]
                            delegate: Rectangle {
                                width: (parent.width - 8) / 2
                                height: 34
                                radius: studioTheme.radiusSm
                                color: studioSettings.exportFormat === modelData.id ? studioTheme.accentPrimary : studioTheme.bgCard
                                border.color: studioTheme.borderSubtle
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: studioSettings.exportFormat === modelData.id ? "#ffffff" : studioTheme.textSecondary
                                    font.bold: true
                                    font.pixelSize: studioTheme.fontSizeXs
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: studioSettings.exportFormat = modelData.id
                                }
                            }
                        }
                    }

                    Text { text: "Export Resolution"; color: studioTheme.textPrimary; font.bold: true; font.pixelSize: studioTheme.fontSizeSm }
                    Row {
                        width: parent.width
                        spacing: 8
                        Repeater {
                            model: ["4k", "1080p", "720p"]
                            delegate: Rectangle {
                                width: (parent.width - 16) / 3
                                height: 32
                                radius: studioTheme.radiusSm
                                color: studioSettings.exportResolution === modelData ? studioTheme.accentCyan : studioTheme.bgCard
                                border.color: studioTheme.borderSubtle
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.toUpperCase()
                                    color: studioSettings.exportResolution === modelData ? "#000000" : studioTheme.textSecondary
                                    font.bold: true
                                    font.pixelSize: studioTheme.fontSizeXs
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: studioSettings.exportResolution = modelData
                                }
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: 36
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "GPU Acceleration (" + recorderEngine.detectedGpuEncoder.split(' ')[0] + ")"
                            color: studioTheme.textPrimary
                            font.bold: true
                            font.pixelSize: studioTheme.fontSizeSm
                        }
                        Switch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: studioSettings.hardwareAcceleration
                            onToggled: studioSettings.hardwareAcceleration = checked
                        }
                    }

                    // Render / Export Trigger Button
                    Rectangle {
                        width: parent.width
                        height: 44
                        radius: studioTheme.radiusSm
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#10b981" }
                            GradientStop { position: 1.0; color: "#059669" }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            StudioIcon { name: "save"; size: 15; color: "#ffffff" }
                            Text {
                                text: exportManager.isExporting ? "Rendering..." : "Export " + studioSettings.exportFormat.toUpperCase()
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: studioTheme.fontSizeSm
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var vPath = recorderEngine.recordedVideoPath;
                                if (!vPath || vPath === "") {
                                    vPath = recorderEngine.recordDirectory + "/exact_test.mp4";
                                }
                                exportManager.exportVideo(vPath, studioSettings, zoomEngine, supabaseManager, false);
                            }
                        }
                    }

                    // Instant Share Button
                    Rectangle {
                        width: parent.width
                        height: 42
                        radius: studioTheme.radiusSm
                        color: studioTheme.bgCard
                        border.color: studioTheme.borderSubtle

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            StudioIcon { name: "share"; size: 14; color: studioTheme.textPrimary }
                            Text {
                                text: "Get Instant Share Link"
                                color: studioTheme.textPrimary
                                font.bold: true
                                font.pixelSize: studioTheme.fontSizeSm
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var vPath = recorderEngine.recordedVideoPath;
                                if (!vPath || vPath === "") {
                                    vPath = recorderEngine.recordDirectory + "/exact_test.mp4";
                                }
                                supabaseManager.uploadRecording(vPath, "Studio Recording", 15, studioSettings.aspectRatio);
                                inspectorRoot.openShareModal();
                            }
                        }
                    }
                }
            }
        }
    }
}
