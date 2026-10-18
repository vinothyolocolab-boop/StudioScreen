#ifndef ZOOMENGINE_H
#define ZOOMENGINE_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>
#include <QString>

struct ZoomSegment {
    int id;
    qint64 startTimeMs;
    qint64 endTimeMs;
    qreal targetX;
    qreal targetY;
    qreal scale;
    QString label;
};

class ZoomEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int segmentCount READ segmentCount NOTIFY segmentsChanged)
    Q_PROPERTY(QVariantList segments READ segmentsAsVariant NOTIFY segmentsChanged)
    Q_PROPERTY(qreal currentScale READ currentScale NOTIFY currentZoomStateChanged)
    Q_PROPERTY(qreal currentTargetX READ currentTargetX NOTIFY currentZoomStateChanged)
    Q_PROPERTY(qreal currentTargetY READ currentTargetY NOTIFY currentZoomStateChanged)
    Q_PROPERTY(bool isZoomActive READ isZoomActive NOTIFY currentZoomStateChanged)
    Q_PROPERTY(int selectedSegmentId READ selectedSegmentId WRITE setSelectedSegmentId NOTIFY selectedSegmentIdChanged)
    Q_PROPERTY(QVariantMap selectedSegment READ selectedSegment NOTIFY selectedSegmentIdChanged)

public:
    explicit ZoomEngine(QObject *parent = nullptr);
    ~ZoomEngine() override = default;

    int segmentCount() const { return m_segments.size(); }
    const QVector<ZoomSegment>& segments() const { return m_segments; }
    QVariantList segmentsAsVariant() const;
    qreal currentScale() const { return m_currentScale; }
    qreal currentTargetX() const { return m_currentTargetX; }
    qreal currentTargetY() const { return m_currentTargetY; }
    bool isZoomActive() const { return m_isZoomActive; }
    int selectedSegmentId() const { return m_selectedSegmentId; }
    void setSelectedSegmentId(int id);
    QVariantMap selectedSegment() const;

    Q_INVOKABLE void addSegment(qint64 startTimeMs, qint64 endTimeMs, qreal targetX, qreal targetY, qreal scale, const QString &label = "Zoom");
    Q_INVOKABLE void removeSegment(int id);
    Q_INVOKABLE void updateSegment(int id, qint64 startTimeMs, qint64 endTimeMs, qreal targetX, qreal targetY, qreal scale);
    Q_INVOKABLE void setSegmentTarget(int id, qreal targetX, qreal targetY);
    Q_INVOKABLE void setSegmentTiming(int id, qint64 startTimeMs, qint64 endTimeMs);
    Q_INVOKABLE void setSegmentScale(int id, qreal scale);
    Q_INVOKABLE void duplicateSegment(int id);
    Q_INVOKABLE QVariantMap getSegment(int id) const;
    Q_INVOKABLE void clearSegments();
    Q_INVOKABLE void updatePlayhead(qint64 currentMs, int transitionDurationMs = 380);
    Q_INVOKABLE void generateAutoZoomsFromClicks(const QVariantList &clicksList, qreal defaultScale = 1.9);
    Q_INVOKABLE void setCurrentTarget(qreal x, qreal y, qreal scale = 1.9);

signals:
    void segmentsChanged();
    void currentZoomStateChanged();
    void selectedSegmentIdChanged();

private:
    qreal smoothStep(qreal edge0, qreal edge1, qreal x) const;

    QVector<ZoomSegment> m_segments;
    int m_nextId;
    int m_selectedSegmentId;
    qreal m_currentScale;
    qreal m_currentTargetX;
    qreal m_currentTargetY;
    bool m_isZoomActive;
};

#endif // ZOOMENGINE_H
