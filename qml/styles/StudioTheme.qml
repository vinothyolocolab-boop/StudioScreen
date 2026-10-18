pragma Singleton
import QtQuick

QtObject {
    id: theme

    // Background & Surfaces
    readonly property color bgDark: "#070a12"
    readonly property color bgSurface: "#0f172a"
    readonly property color bgCard: "#131d33"
    readonly property color bgCardHover: "#1b2946"
    readonly property color borderSubtle: "#1e293b"
    readonly property color borderActive: "#3b82f6"

    // Accents & Gradients
    readonly property color accentPrimary: "#6366f1" // Indigo
    readonly property color accentSecondary: "#8b5cf6" // Violet
    readonly property color accentCyan: "#06b6d4" // Cyan
    readonly property color accentPink: "#ec4899" // Pink

    // State Colors
    readonly property color textPrimary: "#f8fafc"
    readonly property color textSecondary: "#94a3b8"
    readonly property color textMuted: "#64748b"
    readonly property color statusRecording: "#ef4444"
    readonly property color statusSuccess: "#10b981"
    readonly property color statusWarning: "#f59e0b"

    // Wallpaper Preset Colors
    readonly property var wallpapers: {
        "sonoma": ["#8b5cf6", "#ec4899", "#f97316"],
        "sunset": ["#7f1d1d", "#ea580c", "#fbbf24"],
        "midnight": ["#030712", "#1e1b4b", "#0284c7"],
        "cyberpunk": ["#581c87", "#c026d3", "#06b6d4"],
        "aurora": ["#022c22", "#059669", "#06b6d4"],
        "dark_slate": ["#0b0f19", "#1e293b", "#334155"]
    }

    // Typography
    readonly property string fontFamily: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif"
    readonly property int fontSizeXs: 11
    readonly property int fontSizeSm: 12
    readonly property int fontSizeMd: 14
    readonly property int fontSizeLg: 16
    readonly property int fontSizeXl: 20
    readonly property int fontSizeTitle: 26

    // Dimensions
    readonly property int radiusSm: 6
    readonly property int radiusMd: 10
    readonly property int radiusLg: 16
    readonly property int radiusPill: 999
}
