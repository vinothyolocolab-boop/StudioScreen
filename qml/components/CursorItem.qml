import QtQuick

Item {
    id: root

    property real normX: 0.5
    property real normY: 0.5
    property real cursorScale: studioSettings.cursorScale
    property string cursorStyle: studioSettings.cursorStyle
    property color rippleColor: studioSettings.rippleColor
    property bool rippleEnabled: studioSettings.clickRippleEnabled

    width: 24 * cursorScale
    height: 24 * cursorScale
    opacity: studioSettings.cursorAutoHideStationary ? recorderEngine.currentCursorOpacity : 1.0

    Behavior on opacity {
        NumberAnimation { duration: 180 }
    }

    // Position centered on pointer tip
    x: (parent.width * normX) - (cursorStyle === "highlight_circle" ? width / 2 : 2)
    y: (parent.height * normY) - (cursorStyle === "highlight_circle" ? height / 2 : 2)

    // Smooth movement interpolation with Cinematic Bezier Easing
    readonly property int motionDuration: {
        var m = studioSettings.cursorMotionMode;
        if (m === "cinematic") return 85;
        if (m === "snappy") return 25;
        return 50; // natural
    }

    Behavior on x {
        enabled: studioSettings.smoothCursorMotion
        NumberAnimation { duration: root.motionDuration; easing.type: studioSettings.cursorMotionMode === "cinematic" ? Easing.OutCubic : Easing.OutQuad }
    }
    Behavior on y {
        enabled: studioSettings.smoothCursorMotion
        NumberAnimation { duration: root.motionDuration; easing.type: studioSettings.cursorMotionMode === "cinematic" ? Easing.OutCubic : Easing.OutQuad }
    }

    // Expanding Click Ripple Rings (Screen Studio style)
    Rectangle {
        id: rippleRing
        anchors.centerIn: cursorStyle === "highlight_circle" ? parent : pointerTip
        width: 10
        height: 10
        radius: width / 2
        color: studioSettings.clickAnimationType === "burst" ? root.rippleColor : "transparent"
        border.color: root.rippleColor
        border.width: studioSettings.clickAnimationType === "burst" ? 0 : 3
        opacity: 0.0

        ParallelAnimation {
            id: clickPulseAnim
            NumberAnimation {
                target: rippleRing
                property: "width"
                from: 10
                to: 60 * root.cursorScale
                duration: 420
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: rippleRing
                property: "height"
                from: 10
                to: 60 * root.cursorScale
                duration: 420
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: rippleRing
                property: "opacity"
                from: 0.90
                to: 0.0
                duration: 420
                easing.type: Easing.OutCubic
            }
        }
    }

    // Secondary Neon Ring for Neon Burst mode
    Rectangle {
        id: secondRing
        visible: studioSettings.clickAnimationType === "neonRing"
        anchors.centerIn: cursorStyle === "highlight_circle" ? parent : pointerTip
        width: 10
        height: 10
        radius: width / 2
        color: "transparent"
        border.color: "#c084fc"
        border.width: 2
        opacity: 0.0

        ParallelAnimation {
            id: secondPulseAnim
            NumberAnimation { target: secondRing; property: "width"; from: 6; to: 82 * root.cursorScale; duration: 520; easing.type: Easing.OutQuad }
            NumberAnimation { target: secondRing; property: "height"; from: 6; to: 82 * root.cursorScale; duration: 520; easing.type: Easing.OutQuad }
            NumberAnimation { target: secondRing; property: "opacity"; from: 0.8; to: 0.0; duration: 520; easing.type: Easing.OutQuad }
        }
    }

    Connections {
        target: recorderEngine
        function onClickDetected(x, y) {
            if (root.rippleEnabled) {
                clickPulseAnim.restart();
                if (studioSettings.clickAnimationType === "neonRing") {
                    secondPulseAnim.restart();
                }
            }
            if (studioSettings.cursorClickSound) {
                audioManager.playClickSound();
            }
        }
    }

    Item {
        id: pointerTip
        x: 4
        y: 4
        width: 1
        height: 1
    }

    // Cursor Graphic Rendering based on selected style
    Canvas {
        id: cursorCanvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            var s = root.cursorScale;

            if (root.cursorStyle === "macos_black") {
                // Classic macOS High-Contrast Black Cursor
                ctx.save();
                ctx.scale(s, s);
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(0, 18);
                ctx.lineTo(4.5, 14.5);
                ctx.lineTo(8.5, 22);
                ctx.lineTo(11.5, 20.5);
                ctx.lineTo(7.5, 13.5);
                ctx.lineTo(13.5, 13.5);
                ctx.closePath();

                // White outline
                ctx.strokeStyle = "#ffffff";
                ctx.lineWidth = 2.2;
                ctx.stroke();

                // Black fill
                ctx.fillStyle = "#0f172a";
                ctx.fill();
                ctx.restore();

            } else if (root.cursorStyle === "neon_cyan") {
                // Neon Cyber Cursor
                ctx.save();
                ctx.scale(s, s);
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(0, 16);
                ctx.lineTo(4, 12);
                ctx.lineTo(9, 20);
                ctx.lineTo(12, 18);
                ctx.lineTo(7, 11);
                ctx.lineTo(13, 11);
                ctx.closePath();

                ctx.strokeStyle = "#ffffff";
                ctx.lineWidth = 1.5;
                ctx.stroke();

                ctx.fillStyle = "#06b6d4";
                ctx.shadowColor = "#06b6d4";
                ctx.shadowBlur = 8;
                ctx.fill();
                ctx.restore();

            } else if (root.cursorStyle === "modern_glow") {
                // Modern Violet Glow
                ctx.save();
                ctx.scale(s, s);
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(13, 13);
                ctx.lineTo(6, 13);
                ctx.lineTo(0, 19);
                ctx.closePath();

                ctx.fillStyle = "#8b5cf6";
                ctx.shadowColor = "#a855f7";
                ctx.shadowBlur = 10;
                ctx.fill();
                ctx.restore();

            } else {
                // Highlight Circle Cursor
                ctx.save();
                ctx.beginPath();
                ctx.arc(width / 2, height / 2, width / 2.4, 0, Math.PI * 2);
                ctx.fillStyle = "rgba(99, 102, 241, 0.45)";
                ctx.fill();
                ctx.strokeStyle = "#6366f1";
                ctx.lineWidth = 2;
                ctx.stroke();

                ctx.beginPath();
                ctx.arc(width / 2, height / 2, 3, 0, Math.PI * 2);
                ctx.fillStyle = "#ffffff";
                ctx.fill();
                ctx.restore();
            }
        }
    }

    Connections {
        target: studioSettings
        function onCursorStyleChanged() { cursorCanvas.requestPaint(); }
        function onCursorScaleChanged() { cursorCanvas.requestPaint(); }
    }

    function triggerClickRipple() {
        if (root.rippleEnabled) {
            clickPulseAnim.restart();
        }
    }
}
