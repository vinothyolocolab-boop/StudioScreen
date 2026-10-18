import QtQuick
import QtQuick.Controls
import QtMultimedia
import QtQuick.Dialogs

Item {
    id: canvasRoot

    property real playheadMs: 0
    property bool isPlaying: false

    signal videoPositionChanged(real posMs)
    signal videoDurationChanged(real durMs)
    signal requestOpenVideoDialog()

    // Dark backdrop for the canvas area
    Rectangle {
        anchors.fill: parent
        color: studioTheme.bgDark
    }

    // Qt Multimedia Player for Real Video Playback
    MediaPlayer {
        id: studioPlayer
        audioOutput: AudioOutput { id: studioAudioOut; volume: 1.0 }
        videoOutput: studioVideoOut
        source: {
            var p = recorderEngine.recordedVideoPath;
            if (!p || p === "") return "";
            return p.startsWith("file:") ? p : ("file://" + p);
        }
        loops: MediaPlayer.Infinite
        playbackRate: studioSettings.playbackSpeed

        onPositionChanged: {
            if (playbackState === MediaPlayer.PlayingState) {
                canvasRoot.videoPositionChanged(position);
            }
        }
        onDurationChanged: {
            if (duration > 0) {
                canvasRoot.videoDurationChanged(duration);
            }
        }
    }

    onIsPlayingChanged: {
        if (isPlaying) {
            if (studioPlayer.playbackState !== MediaPlayer.PlayingState) {
                studioPlayer.play();
            }
        } else {
            if (studioPlayer.playbackState === MediaPlayer.PlayingState) {
                studioPlayer.pause();
            }
        }
    }

    onPlayheadMsChanged: {
        if (Math.abs(studioPlayer.position - playheadMs) > 200 && studioPlayer.playbackState !== MediaPlayer.PlayingState) {
            studioPlayer.position = playheadMs;
        }
    }

    // Compute Canvas Aspect Ratio Dimensions
    readonly property real canvasAspectRatio: {
        var r = studioSettings.aspectRatio;
        if (r === "9:16") return 9.0 / 16.0;
        if (r === "1:1") return 1.0;
        if (r === "4:3") return 4.0 / 3.0;
        return 16.0 / 9.0;
    }

    readonly property real fittedWidth: {
        var maxW = width - 40;
        var maxH = height - 40;
        if (maxW / canvasAspectRatio <= maxH) {
            return maxW;
        } else {
            return maxH * canvasAspectRatio;
        }
    }

    readonly property real fittedHeight: fittedWidth / canvasAspectRatio

    // Main Studio Viewport Box
    Rectangle {
        id: canvasBox
        width: canvasRoot.fittedWidth
        height: canvasRoot.fittedHeight
        anchors.centerIn: parent
        radius: studioTheme.radiusMd
        clip: true

        // 1. Wallpaper Backdrop (Screen Studio Style Gradient)
        Rectangle {
            id: wallpaperBg
            anchors.fill: parent

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: {
                        var p = studioSettings.wallpaperPreset;
                        if (p === "sunset") return "#7f1d1d";
                        if (p === "midnight") return "#030712";
                        if (p === "cyberpunk") return "#581c87";
                        if (p === "aurora") return "#022c22";
                        if (p === "dark_slate") return "#0b0f19";
                        return "#8b5cf6"; // Sonoma default
                    }
                }
                GradientStop {
                    position: 0.5
                    color: {
                        var p = studioSettings.wallpaperPreset;
                        if (p === "sunset") return "#ea580c";
                        if (p === "midnight") return "#1e1b4b";
                        if (p === "cyberpunk") return "#c026d3";
                        if (p === "aurora") return "#059669";
                        if (p === "dark_slate") return "#1e293b";
                        return "#ec4899"; // Sonoma
                    }
                }
                GradientStop {
                    position: 1.0
                    color: {
                        var p = studioSettings.wallpaperPreset;
                        if (p === "sunset") return "#fbbf24";
                        if (p === "midnight") return "#0284c7";
                        if (p === "cyberpunk") return "#06b6d4";
                        if (p === "aurora") return "#06b6d4";
                        if (p === "dark_slate") return "#334155";
                        return "#f97316"; // Sonoma
                    }
                }
            }

            // Subtle Mesh overlay texture for depth
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#40000000" }
                }
            }

            // Subtle breathing ambient oscillation
            SequentialAnimation on opacity {
                running: studioSettings.ambientMotion
                loops: Animation.Infinite
                NumberAnimation { from: 0.92; to: 1.0; duration: 4000; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.0; to: 0.92; duration: 4000; easing.type: Easing.InOutSine }
            }
        }

        // 2. Floating Window Shadow Container
        Item {
            id: windowWrapper
            anchors.fill: parent
            anchors.margins: studioSettings.canvasPadding

            // Multi-layer ambient drop shadow
            Rectangle {
                anchors.fill: floatingWindow
                anchors.margins: -4
                radius: studioSettings.cornerRadius + 4
                color: "#000000"
                opacity: studioSettings.shadowOpacity
                z: 0

                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // 3. Floating Window Content Box (Screen Content)
            Rectangle {
                id: floatingWindow
                anchors.fill: parent
                radius: studioSettings.cornerRadius
                color: studioTheme.bgSurface
                border.color: studioTheme.borderSubtle
                border.width: 1
                clip: true
                z: 1

                // Camera Zoom & Pan Transform
                Item {
                    id: cameraViewport
                    anchors.fill: parent

                    // Fluid Camera Transform centering on cursor target
                    transformOrigin: Item.TopLeft
                    scale: zoomEngine.currentScale

                    x: -((zoomEngine.currentTargetX * width * (zoomEngine.currentScale - 1.0)))
                    y: -((zoomEngine.currentTargetY * height * (zoomEngine.currentScale - 1.0)))

                    Behavior on scale {
                        enabled: true
                        NumberAnimation { duration: studioSettings.zoomTransitionMs; easing.type: Easing.InOutCubic }
                    }
                    Behavior on x {
                        enabled: true
                        NumberAnimation { duration: studioSettings.zoomTransitionMs; easing.type: Easing.InOutCubic }
                    }
                    Behavior on y {
                        enabled: true
                        NumberAnimation { duration: studioSettings.zoomTransitionMs; easing.type: Easing.InOutCubic }
                    }

                    // REAL VIDEO STREAM (Hardware-Accelerated VideoOutput)
                    VideoOutput {
                        id: studioVideoOut
                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectFit
                        visible: recorderEngine.recordedVideoPath && recorderEngine.recordedVideoPath !== ""
                    }

                    // Window Title Bar (Mac-style pill header)
                    Rectangle {
                        id: titleBar
                        width: parent.width
                        height: 38
                        color: "#d90b0f19"
                        border.color: studioTheme.borderSubtle
                        border.width: 1
                        z: 2
                        visible: recorderEngine.recordedVideoPath && recorderEngine.recordedVideoPath !== ""

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Rectangle { width: 12; height: 12; radius: 6; color: "#ef4444" }
                            Rectangle { width: 12; height: 12; radius: 6; color: "#f59e0b" }
                            Rectangle { width: 12; height: 12; radius: 6; color: "#10b981" }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            StudioIcon {
                                name: "video"
                                size: 14
                                color: studioTheme.textSecondary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: {
                                    var p = recorderEngine.recordedVideoPath;
                                    if (!p || p === "") return "";
                                    var parts = p.split('/');
                                    return parts[parts.length - 1];
                                }
                                color: studioTheme.textSecondary
                                font.pixelSize: studioTheme.fontSizeSm
                                font.bold: true
                            }
                        }
                    }

                    // High-Fidelity Animated Cursor Overlay
                    CursorItem {
                        id: studioCursor
                        normX: recorderEngine.currentCursorX
                        normY: recorderEngine.currentCursorY
                        z: 3
                    }

                    // Interactive Focal Crosshair Target for Selected Zoom Block
                    Item {
                        id: zoomCrosshairTarget
                        visible: zoomEngine.selectedSegmentId !== -1
                        property var curSeg: zoomEngine.selectedSegment
                        property real tgtX: curSeg ? (curSeg.targetX !== undefined ? curSeg.targetX : 0.5) : 0.5
                        property real tgtY: curSeg ? (curSeg.targetY !== undefined ? curSeg.targetY : 0.5) : 0.5

                        x: (parent.width * tgtX) - width / 2
                        y: (parent.height * tgtY) - height / 2
                        width: 52
                        height: 52
                        z: 15

                        // Pulsing outer focus circle
                        Rectangle {
                            anchors.centerIn: parent
                            width: 44
                            height: 44
                            radius: 22
                            color: "transparent"
                            border.color: "#38bdf8"
                            border.width: 2.5

                            SequentialAnimation on scale {
                                running: zoomCrosshairTarget.visible
                                loops: Animation.Infinite
                                NumberAnimation { from: 1.0; to: 1.15; duration: 800; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: 1.15; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                            }
                        }

                        // Crosshair lines
                        Rectangle { anchors.centerIn: parent; width: 2; height: 32; color: "#38bdf8" }
                        Rectangle { anchors.centerIn: parent; width: 32; height: 2; color: "#38bdf8" }
                        Rectangle { anchors.centerIn: parent; width: 8; height: 8; radius: 4; color: "#c084fc" }

                        // Coordinate Badge
                        Rectangle {
                            anchors.top: parent.bottom
                            anchors.topMargin: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: 18
                            width: coordText.width + 12
                            radius: 4
                            color: "#d9090d16"
                            border.color: "#38bdf8"
                            border.width: 1

                            Text {
                                id: coordText
                                anchors.centerIn: parent
                                text: "Focus: " + Math.round(zoomCrosshairTarget.tgtX * 100) + "%, " + Math.round(zoomCrosshairTarget.tgtY * 100) + "%"
                                color: "#ffffff"
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }

                        // Drag Area to move focal point on the preview
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            drag.target: zoomCrosshairTarget
                            drag.axis: Drag.XAndYAxis
                            drag.minimumX: 0
                            drag.maximumX: cameraViewport.width - zoomCrosshairTarget.width
                            drag.minimumY: 0
                            drag.maximumY: cameraViewport.height - zoomCrosshairTarget.height

                            onPositionChanged: {
                                if (pressed && zoomEngine.selectedSegmentId !== -1) {
                                    var newNormX = (zoomCrosshairTarget.x + zoomCrosshairTarget.width / 2) / cameraViewport.width;
                                    var newNormY = (zoomCrosshairTarget.y + zoomCrosshairTarget.height / 2) / cameraViewport.height;
                                    zoomEngine.setSegmentTarget(zoomEngine.selectedSegmentId, newNormX, newNormY);
                                }
                            }
                        }
                    }
                }

                // ==========================================
                // EMPTY STATE / UPLOAD ZONE
                // Shown when no video is loaded
                // ==========================================
                Rectangle {
                    anchors.fill: parent
                    color: "#0f172a"
                    visible: !recorderEngine.recordedVideoPath || recorderEngine.recordedVideoPath === ""
                    z: 4

                    Column {
                        anchors.centerIn: parent
                        spacing: 16

                        Rectangle {
                            width: 76
                            height: 76
                            radius: 38
                            color: studioTheme.bgCard
                            border.color: studioTheme.accentPrimary
                            border.width: 2
                            anchors.horizontalCenter: parent.horizontalCenter

                            StudioIcon {
                                anchors.centerIn: parent
                                name: "upload"
                                size: 36
                                color: studioTheme.accentPrimary
                            }
                        }

                        Column {
                            spacing: 6
                            anchors.horizontalCenter: parent.horizontalCenter
                            Text {
                                text: "Upload or Drop Your Video to Edit"
                                color: studioTheme.textPrimary
                                font.bold: true
                                font.pixelSize: studioTheme.fontSizeTitle
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "Compatible with MP4, MOV, WEBM, MKV — Auto-applies Screen Studio zooms & AI captions"
                                color: studioTheme.textSecondary
                                font.pixelSize: studioTheme.fontSizeSm
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Rectangle {
                            height: 44
                            width: 200
                            radius: studioTheme.radiusSm
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#6366f1" }
                                GradientStop { position: 1.0; color: "#8b5cf6" }
                            }
                            anchors.horizontalCenter: parent.horizontalCenter

                            Row {
                                anchors.centerIn: parent
                                spacing: 8
                                StudioIcon {
                                    name: "folder"
                                    size: 16
                                    color: "#ffffff"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Choose Video File..."
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: studioTheme.fontSizeSm
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: canvasRoot.requestOpenVideoDialog()
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // DRAG & DROP AREA
        // ==========================================
        DropArea {
            id: canvasDropArea
            anchors.fill: parent
            onEntered: function(drag) {
                if (drag.hasUrls) {
                    drag.acceptProposedAction();
                }
            }
            onDropped: function(drop) {
                if (drop.hasUrls && drop.urls.length > 0) {
                    var url = drop.urls[0].toString();
                    recorderEngine.openVideoFile(url);
                    drop.acceptProposedAction();
                }
            }
        }

        // Visual Drag & Drop Glow Indicator
        Rectangle {
            anchors.fill: parent
            color: "#60000000"
            border.color: studioTheme.accentPrimary
            border.width: 3
            radius: studioTheme.radiusMd
            visible: canvasDropArea.containsDrag
            z: 10

            Rectangle {
                anchors.centerIn: parent
                height: 52
                width: 320
                radius: studioTheme.radiusPill
                color: studioTheme.bgDark
                border.color: studioTheme.accentPrimary

                Row {
                    anchors.centerIn: parent
                    spacing: 10
                    StudioIcon {
                        name: "upload"
                        size: 20
                        color: studioTheme.accentCyan
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Release to Import Video into Studio"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: studioTheme.fontSizeMd
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // 4. Animated AI Subtitles / Captions (Hormozi Style)
        Rectangle {
            id: subtitlePill
            visible: aiCustomizer.hasCaptions && aiCustomizer.currentSubtitleText !== ""
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            height: 48
            radius: studioTheme.radiusPill
            color: "#e6000000"
            border.color: "#40ffffff"
            border.width: 1.5
            z: 8

            implicitWidth: subtitleRow.width + 36

            Row {
                id: subtitleRow
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: aiCustomizer.currentSubtitleText
                    color: studioTheme.textPrimary
                    font.bold: true
                    font.pixelSize: studioTheme.fontSizeLg
                }

                Rectangle {
                    visible: aiCustomizer.currentActiveWord !== ""
                    height: 28
                    width: activeWordText.width + 16
                    radius: 6
                    color: studioTheme.statusWarning
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: activeWordText
                        anchors.centerIn: parent
                        text: aiCustomizer.currentActiveWord
                        color: "#000000"
                        font.bold: true
                        font.pixelSize: studioTheme.fontSizeLg
                    }
                }
            }
        }

        // Zoom Active Pill Tag
        Rectangle {
            visible: zoomEngine.isZoomActive
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            height: 26
            width: zoomTagRow.width + 16
            radius: studioTheme.radiusPill
            color: studioTheme.accentPrimary
            z: 8

            Row {
                id: zoomTagRow
                anchors.centerIn: parent
                spacing: 6
                StudioIcon {
                    name: "zoom"
                    size: 11
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Zoom " + Number(zoomEngine.currentScale).toFixed(1) + "x"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: studioTheme.fontSizeXs
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ==========================================
        // FLOATING SHORTCUT VISUALIZER (KeyCast)
        // ==========================================
        Rectangle {
            id: keystrokePill
            visible: studioSettings.keystrokesEnabled && recorderEngine.currentKeystrokeText !== ""
            z: 20
            height: 38
            width: keystrokeRow.width + 24
            radius: 10
            color: "#e60f172a"
            border.color: studioTheme.accentPrimary
            border.width: 1.5

            x: {
                var pos = studioSettings.keystrokesPosition;
                if (pos.indexOf("Right") !== -1) return parent.width - width - 24;
                return 24;
            }
            y: {
                var pos = studioSettings.keystrokesPosition;
                if (pos.indexOf("top") !== -1) return 24;
                return parent.height - height - 24;
            }

            Row {
                id: keystrokeRow
                anchors.centerIn: parent
                spacing: 6

                StudioIcon {
                    name: "keyboard"
                    size: 14
                    color: studioTheme.accentCyan
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: recorderEngine.currentKeystrokeText
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        // ==========================================
        // 5. FLOATING FACECAM / WEBCAM PIP
        // ==========================================
        Item {
            id: webcamPipWrapper
            visible: studioSettings.webcamEnabled
            z: 9

            property real customX: -1
            property real customY: -1

            width: studioSettings.webcamSize
            height: studioSettings.webcamSize

            // Smart Auto-Ducking: fades when cursor/focus is in same quadrant
            opacity: {
                if (!studioSettings.webcamAutoDuck) return 1.0;
                var wcCenterX = webcamPipWrapper.x + webcamPipWrapper.width / 2;
                var wcCenterY = webcamPipWrapper.y + webcamPipWrapper.height / 2;
                var curPixelX = recorderEngine.currentCursorX * canvasBox.width;
                var curPixelY = recorderEngine.currentCursorY * canvasBox.height;
                var distSq = (curPixelX - wcCenterX) * (curPixelX - wcCenterX) + (curPixelY - wcCenterY) * (curPixelY - wcCenterY);
                if (distSq < (webcamPipWrapper.width * 1.3) * (webcamPipWrapper.width * 1.3)) {
                    return 0.22;
                }
                return 1.0;
            }
            Behavior on opacity { NumberAnimation { duration: 250 } }

            x: {
                if (customX >= 0) return customX;
                var pos = studioSettings.webcamPosition;
                if (pos.indexOf("left") !== -1) return 32;
                return parent.width - width - 32;
            }
            y: {
                if (customY >= 0) return customY;
                var pos = studioSettings.webcamPosition;
                if (pos.indexOf("top") !== -1) return 32;
                return parent.height - height - 32;
            }

            // Ambient Drop Shadow
            Rectangle {
                anchors.fill: parent
                radius: webcamFrame.radius
                color: "#90000000"
                visible: studioSettings.webcamShadow
                anchors.margins: -4
            }

            // Webcam Frame
            Rectangle {
                id: webcamFrame
                anchors.fill: parent
                radius: {
                    var s = studioSettings.webcamShape;
                    if (s === "circle") return width / 2;
                    if (s === "rounded") return 24;
                    return 8;
                }
                color: "#0f172a"
                border.color: studioSettings.webcamBorderColor
                border.width: studioSettings.webcamBorderWidth
                clip: true

                transform: Scale {
                    xScale: studioSettings.webcamMirror ? -1 : 1
                    origin.x: webcamFrame.width / 2
                }

                // Aesthetic Studio Presenter Badge
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: "#1e1b4b" }
                        GradientStop { position: 1.0; color: "#312e81" }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        StudioIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "user"
                            size: Math.round(webcamPipWrapper.width * 0.32)
                            color: "#c7d2fe"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Facecam"
                            color: "#c7d2fe"
                            font.bold: true
                            font.pixelSize: 10
                        }
                    }

                    // Dynamic Audio Speaking Halo Ring
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.color: studioTheme.accentPrimary
                        border.width: audioManager.recordMic && !audioManager.micMuted ? Math.round(audioManager.micLevel * 5) : 0
                        opacity: audioManager.micLevel > 0.1 ? 0.9 : 0.0
                        Behavior on border.width { NumberAnimation { duration: 50 } }
                    }
                }

                // Drag Handler: drag Facecam anywhere on canvas
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeAllCursor
                    drag.target: webcamPipWrapper
                    drag.minimumX: 10
                    drag.maximumX: canvasBox.width - webcamPipWrapper.width - 10
                    drag.minimumY: 10
                    drag.maximumY: canvasBox.height - webcamPipWrapper.height - 10
                    onPositionChanged: {
                        webcamPipWrapper.customX = webcamPipWrapper.x;
                        webcamPipWrapper.customY = webcamPipWrapper.y;
                    }
                }
            }
        }
    }
}
