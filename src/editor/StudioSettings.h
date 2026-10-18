#ifndef STUDIOSETTINGS_H
#define STUDIOSETTINGS_H

#include <QObject>
#include <QString>
#include <QColor>

class StudioSettings : public QObject
{
    Q_OBJECT
    // Canvas & Frame Properties
    Q_PROPERTY(QString aspectRatio READ aspectRatio WRITE setAspectRatio NOTIFY aspectRatioChanged)
    Q_PROPERTY(int canvasPadding READ canvasPadding WRITE setCanvasPadding NOTIFY canvasPaddingChanged)
    Q_PROPERTY(int cornerRadius READ cornerRadius WRITE setCornerRadius NOTIFY cornerRadiusChanged)
    Q_PROPERTY(int shadowBlur READ shadowBlur WRITE setShadowBlur NOTIFY shadowBlurChanged)
    Q_PROPERTY(qreal shadowOpacity READ shadowOpacity WRITE setShadowOpacity NOTIFY shadowOpacityChanged)
    
    // Background / Wallpaper Properties
    Q_PROPERTY(QString backgroundType READ backgroundType WRITE setBackgroundType NOTIFY backgroundTypeChanged)
    Q_PROPERTY(QString wallpaperPreset READ wallpaperPreset WRITE setWallpaperPreset NOTIFY wallpaperPresetChanged)
    Q_PROPERTY(QString customBgColor READ customBgColor WRITE setCustomBgColor NOTIFY customBgColorChanged)
    Q_PROPERTY(QString customBgImagePath READ customBgImagePath WRITE setCustomBgImagePath NOTIFY customBgImagePathChanged)

    // Cursor Styling & Motion Smoothing
    Q_PROPERTY(QString cursorStyle READ cursorStyle WRITE setCursorStyle NOTIFY cursorStyleChanged)
    Q_PROPERTY(qreal cursorScale READ cursorScale WRITE setCursorScale NOTIFY cursorScaleChanged)
    Q_PROPERTY(bool clickRippleEnabled READ clickRippleEnabled WRITE setClickRippleEnabled NOTIFY clickRippleEnabledChanged)
    Q_PROPERTY(QString rippleColor READ rippleColor WRITE setRippleColor NOTIFY rippleColorChanged)
    Q_PROPERTY(bool smoothCursorMotion READ smoothCursorMotion WRITE setSmoothCursorMotion NOTIFY smoothCursorMotionChanged)
    Q_PROPERTY(qreal cursorSmoothingIntensity READ cursorSmoothingIntensity WRITE setCursorSmoothingIntensity NOTIFY cursorSmoothingIntensityChanged)
    Q_PROPERTY(bool cursorAutoHideStationary READ cursorAutoHideStationary WRITE setCursorAutoHideStationary NOTIFY cursorAutoHideStationaryChanged)
    Q_PROPERTY(bool cursorClickSound READ cursorClickSound WRITE setCursorClickSound NOTIFY cursorClickSoundChanged)
    Q_PROPERTY(QString cursorMotionMode READ cursorMotionMode WRITE setCursorMotionMode NOTIFY cursorMotionModeChanged)
    Q_PROPERTY(QString clickAnimationType READ clickAnimationType WRITE setClickAnimationType NOTIFY clickAnimationTypeChanged)
    Q_PROPERTY(bool keystrokesEnabled READ keystrokesEnabled WRITE setKeystrokesEnabled NOTIFY keystrokesEnabledChanged)
    Q_PROPERTY(QString keystrokesPosition READ keystrokesPosition WRITE setKeystrokesPosition NOTIFY keystrokesPositionChanged)
    Q_PROPERTY(bool ambientMotion READ ambientMotion WRITE setAmbientMotion NOTIFY ambientMotionChanged)

    // Camera Pan & Zoom Engine
    Q_PROPERTY(bool autoZoomEnabled READ autoZoomEnabled WRITE setAutoZoomEnabled NOTIFY autoZoomEnabledChanged)
    Q_PROPERTY(qreal defaultZoomScale READ defaultZoomScale WRITE setDefaultZoomScale NOTIFY defaultZoomScaleChanged)
    Q_PROPERTY(int zoomTransitionMs READ zoomTransitionMs WRITE setZoomTransitionMs NOTIFY zoomTransitionMsChanged)

    // Webcam / Facecam PIP Overlay
    Q_PROPERTY(bool webcamEnabled READ webcamEnabled WRITE setWebcamEnabled NOTIFY webcamEnabledChanged)
    Q_PROPERTY(QString webcamShape READ webcamShape WRITE setWebcamShape NOTIFY webcamShapeChanged)
    Q_PROPERTY(QString webcamPosition READ webcamPosition WRITE setWebcamPosition NOTIFY webcamPositionChanged)
    Q_PROPERTY(int webcamSize READ webcamSize WRITE setWebcamSize NOTIFY webcamSizeChanged)
    Q_PROPERTY(int webcamBorderWidth READ webcamBorderWidth WRITE setWebcamBorderWidth NOTIFY webcamBorderWidthChanged)
    Q_PROPERTY(QString webcamBorderColor READ webcamBorderColor WRITE setWebcamBorderColor NOTIFY webcamBorderColorChanged)
    Q_PROPERTY(bool webcamMirror READ webcamMirror WRITE setWebcamMirror NOTIFY webcamMirrorChanged)
    Q_PROPERTY(bool webcamShadow READ webcamShadow WRITE setWebcamShadow NOTIFY webcamShadowChanged)
    Q_PROPERTY(bool webcamAutoDuck READ webcamAutoDuck WRITE setWebcamAutoDuck NOTIFY webcamAutoDuckChanged)

    // Audio & Voice Enhancement
    Q_PROPERTY(bool noiseSuppression READ noiseSuppression WRITE setNoiseSuppression NOTIFY noiseSuppressionChanged)
    Q_PROPERTY(bool voiceClarity READ voiceClarity WRITE setVoiceClarity NOTIFY voiceClarityChanged)

    // Playback Speed & Timeline Ramping
    Q_PROPERTY(qreal playbackSpeed READ playbackSpeed WRITE setPlaybackSpeed NOTIFY playbackSpeedChanged)

    // Export & Production Settings
    Q_PROPERTY(QString exportFormat READ exportFormat WRITE setExportFormat NOTIFY exportFormatChanged)
    Q_PROPERTY(QString exportResolution READ exportResolution WRITE setExportResolution NOTIFY exportResolutionChanged)
    Q_PROPERTY(int exportFps READ exportFps WRITE setExportFps NOTIFY exportFpsChanged)
    Q_PROPERTY(bool hardwareAcceleration READ hardwareAcceleration WRITE setHardwareAcceleration NOTIFY hardwareAccelerationChanged)
    Q_PROPERTY(QString recordingQuality READ recordingQuality WRITE setRecordingQuality NOTIFY recordingQualityChanged)
    Q_PROPERTY(int recordingFps READ recordingFps WRITE setRecordingFps NOTIFY recordingFpsChanged)

public:
    explicit StudioSettings(QObject *parent = nullptr);
    ~StudioSettings() override = default;

    QString aspectRatio() const { return m_aspectRatio; }
    int canvasPadding() const { return m_canvasPadding; }
    int cornerRadius() const { return m_cornerRadius; }
    int shadowBlur() const { return m_shadowBlur; }
    qreal shadowOpacity() const { return m_shadowOpacity; }

    QString backgroundType() const { return m_backgroundType; }
    QString wallpaperPreset() const { return m_wallpaperPreset; }
    QString customBgColor() const { return m_customBgColor; }
    QString customBgImagePath() const { return m_customBgImagePath; }

    QString cursorStyle() const { return m_cursorStyle; }
    qreal cursorScale() const { return m_cursorScale; }
    bool clickRippleEnabled() const { return m_clickRippleEnabled; }
    QString rippleColor() const { return m_rippleColor; }
    bool smoothCursorMotion() const { return m_smoothCursorMotion; }
    qreal cursorSmoothingIntensity() const { return m_cursorSmoothingIntensity; }
    bool cursorAutoHideStationary() const { return m_cursorAutoHideStationary; }
    bool cursorClickSound() const { return m_cursorClickSound; }
    QString cursorMotionMode() const { return m_cursorMotionMode; }
    QString clickAnimationType() const { return m_clickAnimationType; }
    bool keystrokesEnabled() const { return m_keystrokesEnabled; }
    QString keystrokesPosition() const { return m_keystrokesPosition; }
    bool ambientMotion() const { return m_ambientMotion; }

    bool autoZoomEnabled() const { return m_autoZoomEnabled; }
    qreal defaultZoomScale() const { return m_defaultZoomScale; }
    int zoomTransitionMs() const { return m_zoomTransitionMs; }

    bool webcamEnabled() const { return m_webcamEnabled; }
    QString webcamShape() const { return m_webcamShape; }
    QString webcamPosition() const { return m_webcamPosition; }
    int webcamSize() const { return m_webcamSize; }
    int webcamBorderWidth() const { return m_webcamBorderWidth; }
    QString webcamBorderColor() const { return m_webcamBorderColor; }
    bool webcamMirror() const { return m_webcamMirror; }
    bool webcamShadow() const { return m_webcamShadow; }
    bool webcamAutoDuck() const { return m_webcamAutoDuck; }

    bool noiseSuppression() const { return m_noiseSuppression; }
    bool voiceClarity() const { return m_voiceClarity; }

    qreal playbackSpeed() const { return m_playbackSpeed; }

    QString exportFormat() const { return m_exportFormat; }
    QString exportResolution() const { return m_exportResolution; }
    int exportFps() const { return m_exportFps; }
    bool hardwareAcceleration() const { return m_hardwareAcceleration; }
    QString recordingQuality() const { return m_recordingQuality; }
    int recordingFps() const { return m_recordingFps; }

    void setAspectRatio(const QString &ratio);
    void setCanvasPadding(int padding);
    void setCornerRadius(int radius);
    void setShadowBlur(int blur);
    void setShadowOpacity(qreal opacity);

    void setBackgroundType(const QString &type);
    void setWallpaperPreset(const QString &preset);
    void setCustomBgColor(const QString &color);
    void setCustomBgImagePath(const QString &path);

    void setCursorStyle(const QString &style);
    void setCursorScale(qreal scale);
    void setClickRippleEnabled(bool enabled);
    void setRippleColor(const QString &color);
    void setSmoothCursorMotion(bool smooth);
    void setCursorSmoothingIntensity(qreal intensity);
    void setCursorAutoHideStationary(bool autoHide);
    void setCursorClickSound(bool sound);
    void setCursorMotionMode(const QString &mode);
    void setClickAnimationType(const QString &type);
    void setKeystrokesEnabled(bool enabled);
    void setKeystrokesPosition(const QString &pos);
    void setAmbientMotion(bool enabled);

    void setAutoZoomEnabled(bool enabled);
    void setDefaultZoomScale(qreal scale);
    void setZoomTransitionMs(int ms);

    void setWebcamEnabled(bool enabled);
    void setWebcamShape(const QString &shape);
    void setWebcamPosition(const QString &pos);
    void setWebcamSize(int size);
    void setWebcamBorderWidth(int width);
    void setWebcamBorderColor(const QString &color);
    void setWebcamMirror(bool mirror);
    void setWebcamShadow(bool shadow);
    void setWebcamAutoDuck(bool duck);

    void setNoiseSuppression(bool enabled);
    void setVoiceClarity(bool enabled);

    void setPlaybackSpeed(qreal speed);

    void setExportFormat(const QString &fmt);
    void setExportResolution(const QString &res);
    void setExportFps(int fps);
    void setHardwareAcceleration(bool hw);
    void setRecordingQuality(const QString &quality);
    void setRecordingFps(int fps);

    Q_INVOKABLE void resetDefaults();

signals:
    void aspectRatioChanged();
    void canvasPaddingChanged();
    void cornerRadiusChanged();
    void shadowBlurChanged();
    void shadowOpacityChanged();
    void backgroundTypeChanged();
    void wallpaperPresetChanged();
    void customBgColorChanged();
    void customBgImagePathChanged();
    void cursorStyleChanged();
    void cursorScaleChanged();
    void clickRippleEnabledChanged();
    void rippleColorChanged();
    void smoothCursorMotionChanged();
    void cursorSmoothingIntensityChanged();
    void cursorAutoHideStationaryChanged();
    void cursorClickSoundChanged();
    void cursorMotionModeChanged();
    void clickAnimationTypeChanged();
    void keystrokesEnabledChanged();
    void keystrokesPositionChanged();
    void ambientMotionChanged();
    void autoZoomEnabledChanged();
    void defaultZoomScaleChanged();
    void zoomTransitionMsChanged();
    void webcamEnabledChanged();
    void webcamShapeChanged();
    void webcamPositionChanged();
    void webcamSizeChanged();
    void webcamBorderWidthChanged();
    void webcamBorderColorChanged();
    void webcamMirrorChanged();
    void webcamShadowChanged();
    void webcamAutoDuckChanged();
    void noiseSuppressionChanged();
    void voiceClarityChanged();
    void playbackSpeedChanged();
    void exportFormatChanged();
    void exportResolutionChanged();
    void exportFpsChanged();
    void hardwareAccelerationChanged();
    void recordingQualityChanged();
    void recordingFpsChanged();

private:
    QString m_aspectRatio;
    int m_canvasPadding;
    int m_cornerRadius;
    int m_shadowBlur;
    qreal m_shadowOpacity;

    QString m_backgroundType;
    QString m_wallpaperPreset;
    QString m_customBgColor;
    QString m_customBgImagePath;

    QString m_cursorStyle;
    qreal m_cursorScale;
    bool m_clickRippleEnabled;
    QString m_rippleColor;
    bool m_smoothCursorMotion;
    qreal m_cursorSmoothingIntensity;
    bool m_cursorAutoHideStationary;
    bool m_cursorClickSound;
    QString m_cursorMotionMode;
    QString m_clickAnimationType;
    bool m_keystrokesEnabled;
    QString m_keystrokesPosition;
    bool m_ambientMotion;

    bool m_autoZoomEnabled;
    qreal m_defaultZoomScale;
    int m_zoomTransitionMs;

    bool m_webcamEnabled;
    QString m_webcamShape;
    QString m_webcamPosition;
    int m_webcamSize;
    int m_webcamBorderWidth;
    QString m_webcamBorderColor;
    bool m_webcamMirror;
    bool m_webcamShadow;
    bool m_webcamAutoDuck;

    bool m_noiseSuppression;
    bool m_voiceClarity;

    qreal m_playbackSpeed;

    QString m_exportFormat;
    QString m_exportResolution;
    int m_exportFps;
    bool m_hardwareAcceleration;
    QString m_recordingQuality;
    int m_recordingFps;
};

#endif // STUDIOSETTINGS_H
