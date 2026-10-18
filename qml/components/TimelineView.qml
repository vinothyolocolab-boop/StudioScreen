import QtQuick
import QtQuick.Controls

Rectangle {
    id: timelineRoot
    height: 180
    color: studioTheme.bgDark
    border.color: studioTheme.borderSubtle
    border.width: 1

    property real currentMs: 0
    property real totalDurationMs: Math.max(15000, recorderEngine.recordingDurationMs)
    property bool isPlaying: false

    // Playback Timer (only active as fallback when no video file is loaded)
    Timer {
        id: playTimer
        interval: 33 // 30 FPS playback
        repeat: true
        running: timelineRoot.isPlaying && (!recorderEngine.recordedVideoPath || recorderEngine.recordedVideoPath === "")
        onTriggered: {
            timelineRoot.currentMs += 33;
            if (timelineRoot.currentMs > timelineRoot.totalDurationMs) {
                timelineRoot.currentMs = 0; // loop
            }
            zoomEngine.updatePlayhead(timelineRoot.currentMs, studioSettings.zoomTransitionMs);
            aiCustomizer.updatePlayhead(timelineRoot.currentMs);
            recorderEngine.seekKeystrokes(timelineRoot.currentMs);
        }
    }

    function formatTimeMs(ms) {
        var totalSec = Math.floor(ms / 1000);
        var m = Math.floor(totalSec / 60);
        var s = totalSec % 60;
        var tenths = Math.floor((ms % 1000) / 100);
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s) + "." + tenths;
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // Top Controls Bar
        Row {
            width: parent.width
            height: 32
            spacing: 12

            // Play / Pause Button
            Rectangle {
                width: 32
                height: 32
                radius: studioTheme.radiusSm
                color: playMouse.containsMouse ? studioTheme.bgCardHover : studioTheme.bgCard
                border.color: studioTheme.borderSubtle

                StudioIcon {
                    anchors.centerIn: parent
                    name: timelineRoot.isPlaying ? "pause" : "play"
                    size: 14
                    color: studioTheme.textPrimary
                }
                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: timelineRoot.isPlaying = !timelineRoot.isPlaying
                }
            }

            // Rewind to 0
            Rectangle {
                width: 32
                height: 32
                radius: studioTheme.radiusSm
                color: rewMouse.containsMouse ? studioTheme.bgCardHover : studioTheme.bgCard
                border.color: studioTheme.borderSubtle

                StudioIcon {
                    anchors.centerIn: parent
                    name: "rewind"
                    size: 13
                    color: studioTheme.textSecondary
                }
                MouseArea {
                    id: rewMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        timelineRoot.currentMs = 0;
                        zoomEngine.updatePlayhead(0);
                    }
                }
            }

            // Timecode Badge
            Rectangle {
                height: 32
                width: 140
                radius: studioTheme.radiusSm
                color: studioTheme.bgSurface
                border.color: studioTheme.borderSubtle

                Text {
                    anchors.centerIn: parent
                    text: timelineRoot.formatTimeMs(timelineRoot.currentMs) + " / " + timelineRoot.formatTimeMs(timelineRoot.totalDurationMs)
                    color: studioTheme.accentCyan
                    font.family: "monospace"
                    font.pixelSize: studioTheme.fontSizeSm
                    font.bold: true
                }
            }

            // Playback Speed Cycling Chip
            Rectangle {
                height: 32
                width: 68
                radius: studioTheme.radiusSm
                color: speedMouse.containsMouse ? studioTheme.bgCardHover : studioTheme.bgCard
                border.color: studioTheme.borderSubtle

                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    StudioIcon {
                        name: "export"
                        size: 11
                        color: studioTheme.accentCyan
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: studioSettings.playbackSpeed.toFixed(1) + "x"
                        color: studioTheme.textPrimary
                        font.bold: true
                        font.pixelSize: studioTheme.fontSizeXs
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: speedMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var sp = studioSettings.playbackSpeed;
                        if (sp < 0.9) studioSettings.playbackSpeed = 1.0;
                        else if (sp < 1.1) studioSettings.playbackSpeed = 1.25;
                        else if (sp < 1.3) studioSettings.playbackSpeed = 1.5;
                        else if (sp < 1.6) studioSettings.playbackSpeed = 2.0;
                        else studioSettings.playbackSpeed = 0.5;
                    }
                }
            }

            // Split Clip Action
            Rectangle {
                height: 30
                width: 76
                radius: studioTheme.radiusSm
                color: splitMouse.containsMouse ? studioTheme.bgCardHover : studioTheme.bgCard
                border.color: studioTheme.borderSubtle

                Row {
                    anchors.centerIn: parent
                    spacing: 5
                    StudioIcon {
                        name: "split"
                        size: 12
                        color: studioTheme.textPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Split"
                        color: studioTheme.textPrimary
                        font.bold: true
                        font.pixelSize: studioTheme.fontSizeXs
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: splitMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        aiCustomizer.detectSilences(timelineRoot.totalDurationMs);
                    }
                }
            }

            Item { width: 6; height: 1 }

            // Action: Add Zoom Marker
            Rectangle {
                height: 30
                width: 110
                radius: studioTheme.radiusSm
                color: addZoomMouse.containsMouse ? "#4f46e5" : studioTheme.accentPrimary

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    StudioIcon {
                        name: "plus"
                        size: 11
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Add Zoom"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: studioTheme.fontSizeXs
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: addZoomMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        zoomEngine.addSegment(timelineRoot.currentMs, timelineRoot.currentMs + 2200, 0.5, 0.5, studioSettings.defaultZoomScale, "Zoom Marker");
                    }
                }
            }

            // Action: Auto-Zoom All Clicks
            Rectangle {
                height: 30
                width: 124
                radius: studioTheme.radiusSm
                color: autoZoomMouse.containsMouse ? studioTheme.bgCardHover : studioTheme.bgCard
                border.color: studioTheme.borderSubtle

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    StudioIcon {
                        name: "ai"
                        size: 12
                        color: studioTheme.accentCyan
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Auto Zoom Clicks"
                        color: studioTheme.textPrimary
                        font.pixelSize: studioTheme.fontSizeXs
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: autoZoomMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        zoomEngine.generateAutoZoomsFromClicks(recorderEngine.recordedClicks, studioSettings.defaultZoomScale);
                    }
                }
            }

            // Action: Trim Silence
            Rectangle {
                height: 30
                width: 104
                radius: studioTheme.radiusSm
                color: trimMouse.containsMouse ? studioTheme.bgCardHover : studioTheme.bgCard
                border.color: studioTheme.borderSubtle

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    StudioIcon {
                        name: "split"
                        size: 12
                        color: studioTheme.accentPink
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Trim Silence"
                        color: studioTheme.textPrimary
                        font.pixelSize: studioTheme.fontSizeXs
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: trimMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        aiCustomizer.detectSilences(timelineRoot.totalDurationMs);
                    }
                }
            }
        }

        // Timeline Multi-Track Area
        Item {
            id: tracksContainer
            width: parent.width
            height: parent.height - 48

            // Track Labels Column (Left)
            Column {
                id: trackLabels
                width: 90
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 4

                Rectangle {
                    width: parent.width; height: 26; color: "transparent"
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        StudioIcon { name: "zoom"; size: 12; color: studioTheme.accentPrimary; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Zooms"; color: studioTheme.textSecondary; font.pixelSize: studioTheme.fontSizeXs; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
                Rectangle {
                    width: parent.width; height: 28; color: "transparent"
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        StudioIcon { name: "video"; size: 12; color: studioTheme.accentCyan; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Video"; color: studioTheme.textSecondary; font.pixelSize: studioTheme.fontSizeXs; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
                Rectangle {
                    width: parent.width; height: 28; color: "transparent"
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        StudioIcon { name: "speaker"; size: 12; color: studioTheme.statusSuccess; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Audio"; color: studioTheme.textSecondary; font.pixelSize: studioTheme.fontSizeXs; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
                Rectangle {
                    width: parent.width; height: 22; color: "transparent"
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        StudioIcon { name: "captions"; size: 12; color: studioTheme.statusWarning; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Captions"; color: studioTheme.textSecondary; font.pixelSize: studioTheme.fontSizeXs; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }

            // Track Lanes (Right)
            Item {
                id: lanesArea
                anchors.left: trackLabels.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                // Interactive Scrubber MouseArea
                MouseArea {
                    id: timelineScrubMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onPositionChanged: {
                        if (pressed) {
                            var pct = Math.max(0, Math.min(1, mouse.x / width));
                            timelineRoot.currentMs = pct * timelineRoot.totalDurationMs;
                            zoomEngine.updatePlayhead(timelineRoot.currentMs, studioSettings.zoomTransitionMs);
                            aiCustomizer.updatePlayhead(timelineRoot.currentMs);
                            recorderEngine.seekKeystrokes(timelineRoot.currentMs);
                        }
                    }
                    onPressed: {
                        var pct = Math.max(0, Math.min(1, mouse.x / width));
                        timelineRoot.currentMs = pct * timelineRoot.totalDurationMs;
                        zoomEngine.updatePlayhead(timelineRoot.currentMs, studioSettings.zoomTransitionMs);
                        aiCustomizer.updatePlayhead(timelineRoot.currentMs);
                        recorderEngine.seekKeystrokes(timelineRoot.currentMs);
                    }
                }

                Column {
                    anchors.fill: parent
                    spacing: 4

                    // 1. Zoom Markers Lane (Interactive Screen Studio Draggable Blocks)
                    Rectangle {
                        id: zoomLane
                        width: parent.width
                        height: 28
                        radius: 4
                        color: studioTheme.bgSurface
                        border.color: studioTheme.borderSubtle
                        clip: true

                        Repeater {
                            model: zoomEngine.segments
                            delegate: Rectangle {
                                id: zoomBlockItem
                                property int segId: modelData.id
                                property real segStart: modelData.startTimeMs
                                property real segEnd: modelData.endTimeMs
                                property bool isSelected: zoomEngine.selectedSegmentId === segId

                                property real startPct: segStart / Math.max(1, timelineRoot.totalDurationMs)
                                property real widthPct: (segEnd - segStart) / Math.max(1, timelineRoot.totalDurationMs)

                                x: Math.max(0, startPct * zoomLane.width)
                                width: Math.max(28, widthPct * zoomLane.width)
                                height: zoomLane.height - 4
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 4
                                z: isSelected ? 5 : 2

                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: isSelected ? "#7c3aed" : "#6366f1" }
                                    GradientStop { position: 1.0; color: isSelected ? "#06b6d4" : "#8b5cf6" }
                                }
                                border.color: isSelected ? "#38bdf8" : "#c084fc"
                                border.width: isSelected ? 2 : 1

                                // Drag Body (Move Zoom Block)
                                MouseArea {
                                    id: blockDragArea
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    cursorShape: Qt.SizeAllCursor
                                    drag.target: zoomBlockItem
                                    drag.axis: Drag.XAxis
                                    drag.minimumX: 0
                                    drag.maximumX: zoomLane.width - zoomBlockItem.width

                                    onPressed: {
                                        zoomEngine.selectedSegmentId = segId;
                                    }
                                    onPositionChanged: {
                                        if (pressed) {
                                            var newStart = (zoomBlockItem.x / zoomLane.width) * timelineRoot.totalDurationMs;
                                            var dur = segEnd - segStart;
                                            var newEnd = newStart + dur;
                                            zoomEngine.setSegmentTiming(segId, Math.round(newStart), Math.round(newEnd));
                                        }
                                    }
                                }

                                // Left Resize Handle (Start Time)
                                Rectangle {
                                    id: leftHandle
                                    width: 7
                                    height: parent.height
                                    anchors.left: parent.left
                                    radius: 2
                                    color: leftHandleMouse.containsMouse || isSelected ? "#ffffff" : "transparent"
                                    opacity: isSelected ? 0.9 : 0.4

                                    MouseArea {
                                        id: leftHandleMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.SizeHorCursor
                                        hoverEnabled: true
                                        onPressed: zoomEngine.selectedSegmentId = segId
                                        onPositionChanged: {
                                            if (pressed) {
                                                var globalLaneX = mapToItem(zoomLane, mouse.x, 0).x;
                                                var newStart = Math.max(0, Math.min(segEnd - 300, (globalLaneX / zoomLane.width) * timelineRoot.totalDurationMs));
                                                zoomEngine.setSegmentTiming(segId, Math.round(newStart), Math.round(segEnd));
                                            }
                                        }
                                    }
                                }

                                // Right Resize Handle (End Time)
                                Rectangle {
                                    id: rightHandle
                                    width: 7
                                    height: parent.height
                                    anchors.right: parent.right
                                    radius: 2
                                    color: rightHandleMouse.containsMouse || isSelected ? "#ffffff" : "transparent"
                                    opacity: isSelected ? 0.9 : 0.4

                                    MouseArea {
                                        id: rightHandleMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.SizeHorCursor
                                        hoverEnabled: true
                                        onPressed: zoomEngine.selectedSegmentId = segId
                                        onPositionChanged: {
                                            if (pressed) {
                                                var globalLaneX = mapToItem(zoomLane, mouse.x, 0).x;
                                                var newEnd = Math.max(segStart + 300, Math.min(timelineRoot.totalDurationMs, (globalLaneX / zoomLane.width) * timelineRoot.totalDurationMs));
                                                zoomEngine.setSegmentTiming(segId, Math.round(segStart), Math.round(newEnd));
                                            }
                                        }
                                    }
                                }

                                // Zoom Label & Scale Tag
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    StudioIcon {
                                        name: "zoom"
                                        size: 10
                                        color: "#ffffff"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: Number(modelData.scale).toFixed(1) + "x"
                                        color: "#ffffff"
                                        font.bold: true
                                        font.pixelSize: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                // Delete Button when Selected
                                Rectangle {
                                    visible: isSelected
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: -4
                                    width: 14
                                    height: 14
                                    radius: 7
                                    color: "#ef4444"
                                    border.color: "#ffffff"
                                    border.width: 1
                                    z: 10

                                    StudioIcon {
                                        anchors.centerIn: parent
                                        name: "close"
                                        size: 8
                                        color: "#ffffff"
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: zoomEngine.removeSegment(segId)
                                    }
                                }
                            }
                        }
                    }

                    // 2. Video Filmstrip Lane
                    Rectangle {
                        width: parent.width
                        height: 28
                        radius: 4
                        color: studioTheme.bgCard
                        border.color: studioTheme.borderSubtle

                        Row {
                            anchors.fill: parent
                            spacing: 2
                            Repeater {
                                model: 16
                                delegate: Rectangle {
                                    width: (parent.width - 32) / 16
                                    height: parent.height
                                    color: index % 2 === 0 ? studioTheme.bgCard : studioTheme.bgCardHover
                                    border.color: studioTheme.borderSubtle
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: (index * 1) + "s"
                                        color: studioTheme.textMuted
                                        font.pixelSize: 9
                                    }
                                }
                            }
                        }
                    }

                    // 3. Audio Waveform Lane (Genuine RMS Amplitudes from Recording)
                    Rectangle {
                        width: parent.width
                        height: 28
                        radius: 4
                        color: "#0a101d"
                        border.color: studioTheme.borderSubtle

                        Row {
                            anchors.fill: parent
                            anchors.margins: 2
                            spacing: 2

                            Repeater {
                                model: (audioManager.audioWaveform && audioManager.audioWaveform.length > 0) ? audioManager.audioWaveform : 48
                                delegate: Item {
                                    width: Math.max(2, (parent.width - 96) / ((audioManager.audioWaveform && audioManager.audioWaveform.length > 0) ? audioManager.audioWaveform.length : 48))
                                    height: parent.height

                                    property real ampVal: (typeof modelData === "number") ? modelData : Math.max(0.12, (Math.sin(index * 0.45) + 1.0) * 0.42)
                                    property bool isSilence: (aiCustomizer.silenceCutsCount > 0 && ((index >= 16 && index <= 20) || (index >= 34 && index <= 38)))

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: Math.max(2, parent.width - 1)
                                        height: Math.max(3, parent.ampVal * (parent.height - 4))
                                        radius: 1
                                        color: parent.isSilence ? studioTheme.statusRecording : (parent.ampVal > 0.6 ? "#38bdf8" : "#10b981")
                                        opacity: parent.isSilence ? 0.95 : 0.85
                                    }
                                }
                            }
                        }
                    }

                    // 4. Captions Track
                    Rectangle {
                        width: parent.width
                        height: 22
                        radius: 4
                        color: studioTheme.bgSurface
                        border.color: studioTheme.borderSubtle

                        Repeater {
                            model: aiCustomizer.captions
                            delegate: Rectangle {
                                property real cStart: modelData.startMs
                                property real cEnd: modelData.endMs
                                property real cStartPct: cStart / timelineRoot.totalDurationMs
                                property real cWidthPct: (cEnd - cStart) / timelineRoot.totalDurationMs

                                x: cStartPct * parent.width
                                width: Math.max(30, cWidthPct * parent.width)
                                height: parent.height - 4
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 3
                                color: studioTheme.statusWarning
                                opacity: 0.85

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.text
                                    elide: Text.ElideRight
                                    width: parent.width - 6
                                    color: "#000000"
                                    font.bold: true
                                    font.pixelSize: 9
                                }
                            }
                        }
                    }
                }

                // Playhead Scrubber Line
                Rectangle {
                    id: playheadLine
                    x: (timelineRoot.currentMs / timelineRoot.totalDurationMs) * parent.width - 1
                    y: 0
                    width: 2
                    height: parent.height
                    color: studioTheme.accentPink
                    z: 10

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: studioTheme.accentPink
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: -3
                    }
                }
            }
        }
    }
}
