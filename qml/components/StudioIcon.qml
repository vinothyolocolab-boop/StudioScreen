import QtQuick

Item {
    id: iconRoot

    property string name: "frame" // frame, zoom, cursor, facecam, bg, audio, ai, export, gif, save, share, settings, play, pause, rewind, split, plus, trash, copy, speaker, record, folder, check, close, wand
    property color color: studioTheme ? studioTheme.textPrimary : "#ffffff"
    property int size: 16
    property real strokeWidth: 1.8
    property bool filled: false

    width: size
    height: size

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var s = iconRoot.size;
            var c = iconRoot.color;
            var w = iconRoot.strokeWidth;
            var scale = s / 24.0;

            ctx.save();
            ctx.scale(scale, scale);
            ctx.strokeStyle = c;
            ctx.fillStyle = c;
            ctx.lineWidth = w;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            var n = iconRoot.name.toLowerCase();

            if (n === "frame" || n === "aspect") {
                // Viewfinder / Aspect Frame
                ctx.beginPath();
                // Outer framing rectangle
                ctx.rect(3, 4, 18, 16);
                ctx.stroke();
                // Corner tick marks
                ctx.beginPath();
                ctx.moveTo(7, 9); ctx.lineTo(17, 9);
                ctx.moveTo(7, 15); ctx.lineTo(17, 15);
                ctx.lineWidth = w * 0.8;
                ctx.stroke();

            } else if (n === "zoom" || n === "search") {
                // Magnifying glass
                ctx.beginPath();
                ctx.arc(10.5, 10.5, 6.5, 0, Math.PI * 2);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(15.5, 15.5);
                ctx.lineTo(21, 21);
                ctx.lineWidth = w * 1.2;
                ctx.stroke();

            } else if (n === "cursor" || n === "mouse") {
                // Sleek pointer arrow
                ctx.beginPath();
                ctx.moveTo(4, 3);
                ctx.lineTo(4, 19);
                ctx.lineTo(8.5, 15);
                ctx.lineTo(13.5, 22);
                ctx.lineTo(16, 20.5);
                ctx.lineTo(11.5, 14);
                ctx.lineTo(17, 14);
                ctx.closePath();
                if (iconRoot.filled) {
                    ctx.fill();
                } else {
                    ctx.stroke();
                    ctx.fillStyle = Qt.rgba(c.r, c.g, c.b, 0.25);
                    ctx.fill();
                }

            } else if (n === "facecam" || n === "camera") {
                // Camera / Webcam
                ctx.beginPath();
                ctx.moveTo(3, 8);
                ctx.lineTo(8, 8);
                ctx.lineTo(9.5, 5.5);
                ctx.lineTo(14.5, 5.5);
                ctx.lineTo(16, 8);
                ctx.lineTo(21, 8);
                ctx.lineTo(21, 19);
                ctx.lineTo(3, 19);
                ctx.closePath();
                ctx.stroke();
                // Lens circle
                ctx.beginPath();
                ctx.arc(12, 13.5, 3.5, 0, Math.PI * 2);
                ctx.stroke();

            } else if (n === "bg" || n === "palette") {
                // Art Palette
                ctx.beginPath();
                ctx.moveTo(12, 3);
                ctx.bezierCurveTo(6, 3, 3, 7, 3, 12);
                ctx.bezierCurveTo(3, 17, 6.5, 21, 12, 21);
                ctx.bezierCurveTo(14, 21, 15, 19.5, 15, 18);
                ctx.bezierCurveTo(15, 16.5, 16.5, 15.5, 18, 15.5);
                ctx.bezierCurveTo(19.8, 15.5, 21, 14.5, 21, 12);
                ctx.bezierCurveTo(21, 7, 17, 3, 12, 3);
                ctx.closePath();
                ctx.stroke();
                // Palette paint dots
                ctx.beginPath();
                ctx.arc(8, 9, 1.2, 0, Math.PI * 2);
                ctx.arc(12, 7.5, 1.2, 0, Math.PI * 2);
                ctx.arc(16, 9.5, 1.2, 0, Math.PI * 2);
                ctx.fill();

            } else if (n === "audio" || n === "mic") {
                // Microphone
                ctx.beginPath();
                // Capsule body
                ctx.moveTo(9, 6);
                ctx.arc(12, 6, 3, Math.PI, 0, false);
                ctx.lineTo(15, 11);
                ctx.arc(12, 11, 3, 0, Math.PI, false);
                ctx.closePath();
                ctx.stroke();
                // U-cradle
                ctx.beginPath();
                ctx.arc(12, 11, 6, 0, Math.PI, false);
                ctx.stroke();
                // Vertical stand and foot
                ctx.beginPath();
                ctx.moveTo(12, 17); ctx.lineTo(12, 21);
                ctx.moveTo(8, 21); ctx.lineTo(16, 21);
                ctx.stroke();

            } else if (n === "ai" || n === "sparkles" || n === "magic") {
                // AI Sparkle Star (4-point star)
                ctx.beginPath();
                ctx.moveTo(12, 2);
                ctx.quadraticCurveTo(12, 10, 20, 10);
                ctx.quadraticCurveTo(12, 10, 12, 18);
                ctx.quadraticCurveTo(12, 10, 4, 10);
                ctx.quadraticCurveTo(12, 10, 12, 2);
                ctx.closePath();
                ctx.fill();
                // Satellite mini sparkle
                ctx.beginPath();
                ctx.moveTo(19, 15);
                ctx.quadraticCurveTo(19, 18, 22, 18);
                ctx.quadraticCurveTo(19, 18, 19, 21);
                ctx.quadraticCurveTo(19, 18, 16, 18);
                ctx.quadraticCurveTo(19, 18, 19, 15);
                ctx.closePath();
                ctx.fill();

            } else if (n === "export" || n === "lightning") {
                // Lightning Bolt
                ctx.beginPath();
                ctx.moveTo(13, 2);
                ctx.lineTo(5, 13);
                ctx.lineTo(12, 13);
                ctx.lineTo(10.5, 22);
                ctx.lineTo(19, 10.5);
                ctx.lineTo(12.5, 10.5);
                ctx.closePath();
                ctx.fill();

            } else if (n === "gif") {
                // GIF Frame Card
                ctx.beginPath();
                ctx.rect(3, 4, 18, 16);
                ctx.stroke();
                // Inner image sun & mountains
                ctx.beginPath();
                ctx.arc(8, 9, 1.8, 0, Math.PI * 2);
                ctx.fill();
                ctx.beginPath();
                ctx.moveTo(5, 17);
                ctx.lineTo(10, 12);
                ctx.lineTo(14, 16);
                ctx.lineTo(16, 14);
                ctx.lineTo(19, 17);
                ctx.stroke();

            } else if (n === "save" || n === "download") {
                // Export Tray + Down Arrow
                ctx.beginPath();
                // Arrow
                ctx.moveTo(12, 4); ctx.lineTo(12, 15);
                ctx.moveTo(8, 11); ctx.lineTo(12, 15); ctx.lineTo(16, 11);
                ctx.stroke();
                // Tray
                ctx.beginPath();
                ctx.moveTo(4, 15);
                ctx.lineTo(4, 19);
                ctx.lineTo(20, 19);
                ctx.lineTo(20, 15);
                ctx.stroke();

            } else if (n === "share" || n === "link") {
                // Two Interlocking Links
                ctx.beginPath();
                ctx.moveTo(9, 15);
                ctx.lineTo(7, 17);
                ctx.arc(7, 17, 3.5, Math.PI * 0.75, Math.PI * 1.75, false);
                ctx.lineTo(11, 13);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(15, 9);
                ctx.lineTo(17, 7);
                ctx.arc(17, 7, 3.5, -Math.PI * 0.25, Math.PI * 0.75, false);
                ctx.lineTo(13, 11);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(8.5, 15.5);
                ctx.lineTo(15.5, 8.5);
                ctx.stroke();

            } else if (n === "settings" || n === "gear") {
                // Sleek Gear Wheel
                ctx.beginPath();
                ctx.arc(12, 12, 4.5, 0, Math.PI * 2);
                ctx.stroke();
                // 8 teeth
                for (var i = 0; i < 8; ++i) {
                    var ang = (i * Math.PI) / 4;
                    var x1 = 12 + Math.cos(ang) * 6.5;
                    var y1 = 12 + Math.sin(ang) * 6.5;
                    var x2 = 12 + Math.cos(ang) * 9.5;
                    var y2 = 12 + Math.sin(ang) * 9.5;
                    ctx.beginPath();
                    ctx.moveTo(x1, y1);
                    ctx.lineTo(x2, y2);
                    ctx.stroke();
                }

            } else if (n === "play") {
                // Solid Play Triangle
                ctx.beginPath();
                ctx.moveTo(7, 5);
                ctx.lineTo(19, 12);
                ctx.lineTo(7, 19);
                ctx.closePath();
                ctx.fill();

            } else if (n === "pause") {
                // Pause Bars
                ctx.beginPath();
                ctx.rect(6, 5, 3.5, 14);
                ctx.rect(14.5, 5, 3.5, 14);
                ctx.fill();

            } else if (n === "stop") {
                // Solid Stop Square
                ctx.beginPath();
                ctx.rect(6.5, 6.5, 11, 11);
                ctx.fill();

            } else if (n === "rewind") {
                // Rewind
                ctx.beginPath();
                ctx.moveTo(12, 5); ctx.lineTo(4, 12); ctx.lineTo(12, 19); ctx.closePath();
                ctx.moveTo(20, 5); ctx.lineTo(12, 12); ctx.lineTo(20, 19); ctx.closePath();
                ctx.fill();

            } else if (n === "split" || n === "scissors") {
                // Scissors
                ctx.beginPath();
                // Finger rings
                ctx.arc(6, 6, 2.5, 0, Math.PI * 2);
                ctx.arc(6, 18, 2.5, 0, Math.PI * 2);
                ctx.stroke();
                // Blades
                ctx.beginPath();
                ctx.moveTo(8, 7.5); ctx.lineTo(20, 17);
                ctx.moveTo(8, 16.5); ctx.lineTo(20, 7);
                ctx.stroke();

            } else if (n === "plus" || n === "add") {
                // Plus sign
                ctx.beginPath();
                ctx.moveTo(12, 5); ctx.lineTo(12, 19);
                ctx.moveTo(5, 12); ctx.lineTo(19, 12);
                ctx.lineWidth = w * 1.2;
                ctx.stroke();

            } else if (n === "trash" || n === "delete") {
                // Trash can
                ctx.beginPath();
                // Lid
                ctx.moveTo(4, 6); ctx.lineTo(20, 6);
                ctx.moveTo(9, 6); ctx.lineTo(9, 4); ctx.lineTo(15, 4); ctx.lineTo(15, 6);
                // Body
                ctx.moveTo(6, 6); ctx.lineTo(7, 20); ctx.lineTo(17, 20); ctx.lineTo(18, 6);
                ctx.stroke();
                // Lines
                ctx.beginPath();
                ctx.moveTo(10, 10); ctx.lineTo(10, 16);
                ctx.moveTo(14, 10); ctx.lineTo(14, 16);
                ctx.stroke();

            } else if (n === "copy" || n === "duplicate") {
                // Overlapping Cards
                ctx.beginPath();
                ctx.rect(8, 8, 12, 12);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(5, 16); ctx.lineTo(5, 5); ctx.lineTo(16, 5);
                ctx.stroke();

            } else if (n === "speaker" || n === "sound") {
                // Speaker
                ctx.beginPath();
                ctx.moveTo(4, 9);
                ctx.lineTo(8, 9);
                ctx.lineTo(13, 5);
                ctx.lineTo(13, 19);
                ctx.lineTo(8, 15);
                ctx.lineTo(4, 15);
                ctx.closePath();
                ctx.fill();
                // Sound waves
                ctx.beginPath();
                ctx.arc(13, 12, 4.5, -Math.PI * 0.3, Math.PI * 0.3, false);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(13, 12, 7.5, -Math.PI * 0.3, Math.PI * 0.3, false);
                ctx.stroke();

            } else if (n === "record" || n === "dot") {
                // Solid Record Circle
                ctx.beginPath();
                ctx.arc(12, 12, 6.5, 0, Math.PI * 2);
                ctx.fill();

            } else if (n === "folder") {
                // Folder
                ctx.beginPath();
                ctx.moveTo(3, 6);
                ctx.lineTo(9, 6);
                ctx.lineTo(11, 8);
                ctx.lineTo(21, 8);
                ctx.lineTo(21, 19);
                ctx.lineTo(3, 19);
                ctx.closePath();
                ctx.stroke();

            } else if (n === "wand") {
                // Magic Wand
                ctx.beginPath();
                ctx.moveTo(4, 20);
                ctx.lineTo(16, 8);
                ctx.lineWidth = w * 1.3;
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(18, 6, 2, 0, Math.PI * 2);
                ctx.fill();

            } else if (n === "video" || n === "film") {
                // Filmstrip strip
                ctx.beginPath();
                ctx.rect(3, 5, 18, 14);
                ctx.stroke();
                // Film sprockets
                ctx.beginPath();
                ctx.rect(4.5, 6.5, 2.5, 2);
                ctx.rect(10.5, 6.5, 2.5, 2);
                ctx.rect(16.5, 6.5, 2.5, 2);
                ctx.rect(4.5, 15.5, 2.5, 2);
                ctx.rect(10.5, 15.5, 2.5, 2);
                ctx.rect(16.5, 15.5, 2.5, 2);
                ctx.fill();

            } else if (n === "captions" || n === "chat" || n === "subtitle") {
                // Speech bubble
                ctx.beginPath();
                ctx.moveTo(4, 5);
                ctx.lineTo(20, 5);
                ctx.arcTo(21, 5, 21, 6, 2);
                ctx.lineTo(21, 15);
                ctx.arcTo(21, 16, 20, 16, 2);
                ctx.lineTo(10, 16);
                ctx.lineTo(6, 20);
                ctx.lineTo(6, 16);
                ctx.lineTo(4, 16);
                ctx.arcTo(3, 16, 3, 15, 2);
                ctx.lineTo(3, 6);
                ctx.arcTo(3, 5, 4, 5, 2);
                ctx.closePath();
                ctx.stroke();
                // Caption lines inside
                ctx.beginPath();
                ctx.moveTo(7, 9); ctx.lineTo(17, 9);
                ctx.moveTo(7, 12); ctx.lineTo(14, 12);
                ctx.stroke();

            } else if (n === "close" || n === "x") {
                // Clean X
                ctx.beginPath();
                ctx.moveTo(6, 6); ctx.lineTo(18, 18);
                ctx.moveTo(18, 6); ctx.lineTo(6, 18);
                ctx.lineWidth = w * 1.2;
                ctx.stroke();

            } else if (n === "check") {
                // Checkmark
                ctx.beginPath();
                ctx.moveTo(5, 12);
                ctx.lineTo(10, 17);
                ctx.lineTo(19, 7);
                ctx.lineWidth = w * 1.3;
                ctx.stroke();

            } else if (n === "user" || n === "person") {
                // User avatar head & shoulders
                ctx.beginPath();
                ctx.arc(12, 8, 4, 0, Math.PI * 2);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(12, 21, 8, Math.PI, 0, false);
                ctx.stroke();

            } else if (n === "upload") {
                // Arrow pointing up
                ctx.beginPath();
                ctx.moveTo(12, 16); ctx.lineTo(12, 5);
                ctx.moveTo(8, 9); ctx.lineTo(12, 5); ctx.lineTo(16, 9);
                ctx.stroke();
                // Bottom tray
                ctx.beginPath();
                ctx.moveTo(4, 15); ctx.lineTo(4, 19); ctx.lineTo(20, 19); ctx.lineTo(20, 15);
                ctx.stroke();

            } else if (n === "cloud") {
                // Cloud outline
                ctx.beginPath();
                ctx.moveTo(6.5, 17);
                ctx.lineTo(18, 17);
                ctx.arc(18, 14.5, 2.5, Math.PI * 0.5, -Math.PI * 0.5, true);
                ctx.arc(14.5, 10.5, 3.5, 0, Math.PI * 1.25, true);
                ctx.arc(9, 11.5, 3.5, -Math.PI * 0.1, -Math.PI * 0.85, true);
                ctx.arc(6.5, 14.5, 2.5, -Math.PI * 0.5, Math.PI * 0.5, true);
                ctx.closePath();
                ctx.stroke();

            } else if (n === "globe" || n === "web") {
                // Globe circle
                ctx.beginPath();
                ctx.arc(12, 12, 8.5, 0, Math.PI * 2);
                ctx.stroke();
                // Equator
                ctx.beginPath();
                ctx.moveTo(3.5, 12); ctx.lineTo(20.5, 12);
                ctx.stroke();
                // Meridian oval
                ctx.beginPath();
                ctx.ellipse(12, 12, 4.5, 8.5, 0, 0, Math.PI * 2);
                ctx.stroke();

            } else if (n === "keyboard" || n === "key") {
                // Keyboard outline
                ctx.beginPath();
                ctx.rect(3, 6, 18, 12);
                ctx.stroke();
                // Key dots / dashes
                ctx.beginPath();
                ctx.moveTo(6, 9.5); ctx.lineTo(8, 9.5);
                ctx.moveTo(11, 9.5); ctx.lineTo(13, 9.5);
                ctx.moveTo(16, 9.5); ctx.lineTo(18, 9.5);
                ctx.moveTo(7, 14); ctx.lineTo(17, 14);
                ctx.stroke();

            } else {
                // Default clean dot / square
                ctx.beginPath();
                ctx.arc(12, 12, 5, 0, Math.PI * 2);
                ctx.stroke();
            }

            ctx.restore();
        }
    }

    onColorChanged: canvas.requestPaint()
    onSizeChanged: canvas.requestPaint()
    onNameChanged: canvas.requestPaint()
    onFilledChanged: canvas.requestPaint()

    Component.onCompleted: canvas.requestPaint()
}
