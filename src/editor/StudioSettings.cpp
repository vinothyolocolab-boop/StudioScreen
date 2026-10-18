#include "StudioSettings.h"
#include <QtGlobal>

StudioSettings::StudioSettings(QObject *parent)
    : QObject(parent)
    , m_aspectRatio("16:9")
    , m_canvasPadding(56)
    , m_cornerRadius(20)
    , m_shadowBlur(32)
    , m_shadowOpacity(0.40)
    , m_backgroundType("preset")
    , m_wallpaperPreset("sonoma")
    , m_customBgColor("#0f172a")
    , m_customBgImagePath("")
    , m_cursorStyle("macos_black")
    , m_cursorScale(1.5)
    , m_clickRippleEnabled(true)
    , m_rippleColor("#38bdf8")
    , m_smoothCursorMotion(true)
    , m_cursorSmoothingIntensity(0.85)
    , m_cursorAutoHideStationary(true)
    , m_cursorClickSound(false)
    , m_cursorMotionMode("cinematic")
    , m_clickAnimationType("ripple")
    , m_keystrokesEnabled(true)
    , m_keystrokesPosition("bottomLeft")
    , m_ambientMotion(true)
    , m_autoZoomEnabled(true)
    , m_defaultZoomScale(1.9)
    , m_zoomTransitionMs(380)
    , m_webcamEnabled(true)
    , m_webcamShape("circle")
    , m_webcamPosition("bottom_right")
    , m_webcamSize(160)
    , m_webcamBorderWidth(3)
    , m_webcamBorderColor("#818cf8")
    , m_webcamMirror(true)
    , m_webcamShadow(true)
    , m_webcamAutoDuck(true)
    , m_noiseSuppression(true)
    , m_voiceClarity(true)
    , m_playbackSpeed(1.0)
    , m_exportFormat("mp4")
    , m_exportResolution("1080p")
    , m_exportFps(60)
    , m_hardwareAcceleration(true)
    , m_recordingQuality("1080p")
    , m_recordingFps(60)
{
}

void StudioSettings::setAspectRatio(const QString &ratio)
{
    if (m_aspectRatio != ratio) {
        m_aspectRatio = ratio;
        emit aspectRatioChanged();
    }
}

void StudioSettings::setCanvasPadding(int padding)
{
    padding = qBound(0, padding, 180);
    if (m_canvasPadding != padding) {
        m_canvasPadding = padding;
        emit canvasPaddingChanged();
    }
}

void StudioSettings::setCornerRadius(int radius)
{
    radius = qBound(0, radius, 48);
    if (m_cornerRadius != radius) {
        m_cornerRadius = radius;
        emit cornerRadiusChanged();
    }
}

void StudioSettings::setShadowBlur(int blur)
{
    blur = qBound(0, blur, 80);
    if (m_shadowBlur != blur) {
        m_shadowBlur = blur;
        emit shadowBlurChanged();
    }
}

void StudioSettings::setShadowOpacity(qreal opacity)
{
    opacity = qBound(0.0, opacity, 1.0);
    if (!qFuzzyCompare(m_shadowOpacity, opacity)) {
        m_shadowOpacity = opacity;
        emit shadowOpacityChanged();
    }
}

void StudioSettings::setBackgroundType(const QString &type)
{
    if (m_backgroundType != type) {
        m_backgroundType = type;
        emit backgroundTypeChanged();
    }
}

void StudioSettings::setWallpaperPreset(const QString &preset)
{
    if (m_wallpaperPreset != preset) {
        m_wallpaperPreset = preset;
        emit wallpaperPresetChanged();
    }
}

void StudioSettings::setCustomBgColor(const QString &color)
{
    if (m_customBgColor != color) {
        m_customBgColor = color;
        emit customBgColorChanged();
    }
}

void StudioSettings::setCustomBgImagePath(const QString &path)
{
    if (m_customBgImagePath != path) {
        m_customBgImagePath = path;
        emit customBgImagePathChanged();
    }
}

void StudioSettings::setCursorStyle(const QString &style)
{
    if (m_cursorStyle != style) {
        m_cursorStyle = style;
        emit cursorStyleChanged();
    }
}

void StudioSettings::setCursorScale(qreal scale)
{
    scale = qBound(0.5, scale, 3.5);
    if (!qFuzzyCompare(m_cursorScale, scale)) {
        m_cursorScale = scale;
        emit cursorScaleChanged();
    }
}

void StudioSettings::setClickRippleEnabled(bool enabled)
{
    if (m_clickRippleEnabled != enabled) {
        m_clickRippleEnabled = enabled;
        emit clickRippleEnabledChanged();
    }
}

void StudioSettings::setRippleColor(const QString &color)
{
    if (m_rippleColor != color) {
        m_rippleColor = color;
        emit rippleColorChanged();
    }
}

void StudioSettings::setSmoothCursorMotion(bool smooth)
{
    if (m_smoothCursorMotion != smooth) {
        m_smoothCursorMotion = smooth;
        emit smoothCursorMotionChanged();
    }
}

void StudioSettings::setCursorSmoothingIntensity(qreal intensity)
{
    intensity = qBound(0.0, intensity, 1.0);
    if (!qFuzzyCompare(m_cursorSmoothingIntensity, intensity)) {
        m_cursorSmoothingIntensity = intensity;
        emit cursorSmoothingIntensityChanged();
    }
}

void StudioSettings::setCursorAutoHideStationary(bool autoHide)
{
    if (m_cursorAutoHideStationary != autoHide) {
        m_cursorAutoHideStationary = autoHide;
        emit cursorAutoHideStationaryChanged();
    }
}

void StudioSettings::setCursorClickSound(bool sound)
{
    if (m_cursorClickSound != sound) {
        m_cursorClickSound = sound;
        emit cursorClickSoundChanged();
    }
}

void StudioSettings::setAutoZoomEnabled(bool enabled)
{
    if (m_autoZoomEnabled != enabled) {
        m_autoZoomEnabled = enabled;
        emit autoZoomEnabledChanged();
    }
}

void StudioSettings::setDefaultZoomScale(qreal scale)
{
    scale = qBound(1.0, scale, 3.5);
    if (!qFuzzyCompare(m_defaultZoomScale, scale)) {
        m_defaultZoomScale = scale;
        emit defaultZoomScaleChanged();
    }
}

void StudioSettings::setZoomTransitionMs(int ms)
{
    ms = qBound(100, ms, 1200);
    if (m_zoomTransitionMs != ms) {
        m_zoomTransitionMs = ms;
        emit zoomTransitionMsChanged();
    }
}

void StudioSettings::setWebcamEnabled(bool enabled)
{
    if (m_webcamEnabled != enabled) {
        m_webcamEnabled = enabled;
        emit webcamEnabledChanged();
    }
}

void StudioSettings::setWebcamShape(const QString &shape)
{
    if (m_webcamShape != shape) {
        m_webcamShape = shape;
        emit webcamShapeChanged();
    }
}

void StudioSettings::setWebcamPosition(const QString &pos)
{
    if (m_webcamPosition != pos) {
        m_webcamPosition = pos;
        emit webcamPositionChanged();
    }
}

void StudioSettings::setWebcamSize(int size)
{
    size = qBound(80, size, 360);
    if (m_webcamSize != size) {
        m_webcamSize = size;
        emit webcamSizeChanged();
    }
}

void StudioSettings::setWebcamBorderWidth(int width)
{
    width = qBound(0, width, 12);
    if (m_webcamBorderWidth != width) {
        m_webcamBorderWidth = width;
        emit webcamBorderWidthChanged();
    }
}

void StudioSettings::setWebcamBorderColor(const QString &color)
{
    if (m_webcamBorderColor != color) {
        m_webcamBorderColor = color;
        emit webcamBorderColorChanged();
    }
}

void StudioSettings::setWebcamMirror(bool mirror)
{
    if (m_webcamMirror != mirror) {
        m_webcamMirror = mirror;
        emit webcamMirrorChanged();
    }
}

void StudioSettings::setWebcamShadow(bool shadow)
{
    if (m_webcamShadow != shadow) {
        m_webcamShadow = shadow;
        emit webcamShadowChanged();
    }
}

void StudioSettings::setWebcamAutoDuck(bool duck)
{
    if (m_webcamAutoDuck != duck) {
        m_webcamAutoDuck = duck;
        emit webcamAutoDuckChanged();
    }
}

void StudioSettings::setCursorMotionMode(const QString &mode)
{
    if (m_cursorMotionMode != mode) {
        m_cursorMotionMode = mode;
        emit cursorMotionModeChanged();
    }
}

void StudioSettings::setClickAnimationType(const QString &type)
{
    if (m_clickAnimationType != type) {
        m_clickAnimationType = type;
        emit clickAnimationTypeChanged();
    }
}

void StudioSettings::setKeystrokesEnabled(bool enabled)
{
    if (m_keystrokesEnabled != enabled) {
        m_keystrokesEnabled = enabled;
        emit keystrokesEnabledChanged();
    }
}

void StudioSettings::setKeystrokesPosition(const QString &pos)
{
    if (m_keystrokesPosition != pos) {
        m_keystrokesPosition = pos;
        emit keystrokesPositionChanged();
    }
}

void StudioSettings::setAmbientMotion(bool enabled)
{
    if (m_ambientMotion != enabled) {
        m_ambientMotion = enabled;
        emit ambientMotionChanged();
    }
}

void StudioSettings::setNoiseSuppression(bool enabled)
{
    if (m_noiseSuppression != enabled) {
        m_noiseSuppression = enabled;
        emit noiseSuppressionChanged();
    }
}

void StudioSettings::setVoiceClarity(bool enabled)
{
    if (m_voiceClarity != enabled) {
        m_voiceClarity = enabled;
        emit voiceClarityChanged();
    }
}

void StudioSettings::setPlaybackSpeed(qreal speed)
{
    speed = qBound(0.25, speed, 3.0);
    if (!qFuzzyCompare(m_playbackSpeed, speed)) {
        m_playbackSpeed = speed;
        emit playbackSpeedChanged();
    }
}

void StudioSettings::setExportFormat(const QString &fmt)
{
    if (m_exportFormat != fmt) {
        m_exportFormat = fmt;
        emit exportFormatChanged();
    }
}

void StudioSettings::setExportResolution(const QString &res)
{
    if (m_exportResolution != res) {
        m_exportResolution = res;
        emit exportResolutionChanged();
    }
}

void StudioSettings::setExportFps(int fps)
{
    if (m_exportFps != fps) {
        m_exportFps = fps;
        emit exportFpsChanged();
    }
}

void StudioSettings::setHardwareAcceleration(bool hw)
{
    if (m_hardwareAcceleration != hw) {
        m_hardwareAcceleration = hw;
        emit hardwareAccelerationChanged();
    }
}

void StudioSettings::setRecordingQuality(const QString &quality)
{
    if (m_recordingQuality != quality) {
        m_recordingQuality = quality;
        emit recordingQualityChanged();
    }
}

void StudioSettings::setRecordingFps(int fps)
{
    if (m_recordingFps != fps) {
        m_recordingFps = fps;
        emit recordingFpsChanged();
    }
}

void StudioSettings::resetDefaults()
{
    setAspectRatio("16:9");
    setCanvasPadding(56);
    setCornerRadius(20);
    setShadowBlur(32);
    setShadowOpacity(0.40);
    setWallpaperPreset("sonoma");
    setCursorStyle("macos_black");
    setCursorScale(1.5);
    setClickRippleEnabled(true);
    setSmoothCursorMotion(true);
    setCursorSmoothingIntensity(0.85);
    setCursorAutoHideStationary(true);
    setAutoZoomEnabled(true);
    setDefaultZoomScale(1.9);
    setZoomTransitionMs(380);
    setWebcamEnabled(true);
    setWebcamShape("circle");
    setWebcamPosition("bottom_right");
    setWebcamSize(160);
    setNoiseSuppression(true);
    setPlaybackSpeed(1.0);
    setExportFormat("mp4");
    setExportResolution("1080p");
    setExportFps(60);
    setHardwareAcceleration(true);
}
