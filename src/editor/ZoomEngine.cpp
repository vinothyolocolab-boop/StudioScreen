#include "ZoomEngine.h"
#include <QtMath>
#include <QDebug>
#include <algorithm>

ZoomEngine::ZoomEngine(QObject *parent)
    : QObject(parent)
    , m_nextId(1)
    , m_selectedSegmentId(-1)
    , m_currentScale(1.0)
    , m_currentTargetX(0.5)
    , m_currentTargetY(0.5)
    , m_isZoomActive(false)
{
}

void ZoomEngine::setSelectedSegmentId(int id)
{
    if (m_selectedSegmentId != id) {
        m_selectedSegmentId = id;
        emit selectedSegmentIdChanged();
    }
}

QVariantMap ZoomEngine::selectedSegment() const
{
    return getSegment(m_selectedSegmentId);
}

QVariantMap ZoomEngine::getSegment(int id) const
{
    for (const auto &seg : m_segments) {
        if (seg.id == id) {
            QVariantMap map;
            map["id"] = seg.id;
            map["startTimeMs"] = seg.startTimeMs;
            map["endTimeMs"] = seg.endTimeMs;
            map["targetX"] = seg.targetX;
            map["targetY"] = seg.targetY;
            map["scale"] = seg.scale;
            map["label"] = seg.label;
            return map;
        }
    }
    return QVariantMap();
}

QVariantList ZoomEngine::segmentsAsVariant() const
{
    QVariantList list;
    for (const auto &seg : m_segments) {
        QVariantMap map;
        map["id"] = seg.id;
        map["startTimeMs"] = seg.startTimeMs;
        map["endTimeMs"] = seg.endTimeMs;
        map["targetX"] = seg.targetX;
        map["targetY"] = seg.targetY;
        map["scale"] = seg.scale;
        map["label"] = seg.label;
        list.append(map);
    }
    return list;
}

void ZoomEngine::addSegment(qint64 startTimeMs, qint64 endTimeMs, qreal targetX, qreal targetY, qreal scale, const QString &label)
{
    ZoomSegment seg;
    seg.id = m_nextId++;
    seg.startTimeMs = startTimeMs;
    seg.endTimeMs = endTimeMs;
    seg.targetX = qBound(0.0, targetX, 1.0);
    seg.targetY = qBound(0.0, targetY, 1.0);
    seg.scale = qBound(1.0, scale, 3.0);
    seg.label = label.isEmpty() ? QString("Zoom %1").arg(seg.id) : label;

    m_segments.append(seg);
    std::sort(m_segments.begin(), m_segments.end(), [](const ZoomSegment &a, const ZoomSegment &b) {
        return a.startTimeMs < b.startTimeMs;
    });

    m_selectedSegmentId = seg.id;
    emit selectedSegmentIdChanged();
    emit segmentsChanged();
}

void ZoomEngine::updateSegment(int id, qint64 startTimeMs, qint64 endTimeMs, qreal targetX, qreal targetY, qreal scale)
{
    for (auto &seg : m_segments) {
        if (seg.id == id) {
            seg.startTimeMs = qMax(qint64(0), startTimeMs);
            seg.endTimeMs = qMax(seg.startTimeMs + 200, endTimeMs);
            seg.targetX = qBound(0.0, targetX, 1.0);
            seg.targetY = qBound(0.0, targetY, 1.0);
            seg.scale = qBound(1.0, scale, 3.0);
            std::sort(m_segments.begin(), m_segments.end(), [](const ZoomSegment &a, const ZoomSegment &b) {
                return a.startTimeMs < b.startTimeMs;
            });
            emit segmentsChanged();
            if (m_selectedSegmentId == id) emit selectedSegmentIdChanged();
            return;
        }
    }
}

void ZoomEngine::setSegmentTarget(int id, qreal targetX, qreal targetY)
{
    for (auto &seg : m_segments) {
        if (seg.id == id) {
            seg.targetX = qBound(0.0, targetX, 1.0);
            seg.targetY = qBound(0.0, targetY, 1.0);
            emit segmentsChanged();
            if (m_selectedSegmentId == id) emit selectedSegmentIdChanged();
            return;
        }
    }
}

void ZoomEngine::setSegmentTiming(int id, qint64 startTimeMs, qint64 endTimeMs)
{
    for (auto &seg : m_segments) {
        if (seg.id == id) {
            seg.startTimeMs = qMax(qint64(0), startTimeMs);
            seg.endTimeMs = qMax(seg.startTimeMs + 200, endTimeMs);
            std::sort(m_segments.begin(), m_segments.end(), [](const ZoomSegment &a, const ZoomSegment &b) {
                return a.startTimeMs < b.startTimeMs;
            });
            emit segmentsChanged();
            if (m_selectedSegmentId == id) emit selectedSegmentIdChanged();
            return;
        }
    }
}

void ZoomEngine::setSegmentScale(int id, qreal scale)
{
    for (auto &seg : m_segments) {
        if (seg.id == id) {
            seg.scale = qBound(1.0, scale, 3.0);
            emit segmentsChanged();
            if (m_selectedSegmentId == id) emit selectedSegmentIdChanged();
            return;
        }
    }
}

void ZoomEngine::duplicateSegment(int id)
{
    for (const auto &seg : m_segments) {
        if (seg.id == id) {
            qint64 dur = seg.endTimeMs - seg.startTimeMs;
            addSegment(seg.endTimeMs + 200, seg.endTimeMs + 200 + dur, seg.targetX, seg.targetY, seg.scale, seg.label + " (Copy)");
            return;
        }
    }
}

void ZoomEngine::removeSegment(int id)
{
    for (int i = 0; i < m_segments.size(); ++i) {
        if (m_segments[i].id == id) {
            m_segments.removeAt(i);
            if (m_selectedSegmentId == id) {
                m_selectedSegmentId = -1;
                emit selectedSegmentIdChanged();
            }
            emit segmentsChanged();
            return;
        }
    }
}

void ZoomEngine::clearSegments()
{
    m_segments.clear();
    m_currentScale = 1.0;
    m_currentTargetX = 0.5;
    m_currentTargetY = 0.5;
    m_isZoomActive = false;
    emit segmentsChanged();
    emit currentZoomStateChanged();
}

qreal ZoomEngine::smoothStep(qreal edge0, qreal edge1, qreal x) const
{
    qreal t = qBound(0.0, (x - edge0) / (edge1 - edge0), 1.0);
    // Smooth Hermite interpolation (Cubic ease in-out)
    return t * t * (3.0 - 2.0 * t);
}

void ZoomEngine::updatePlayhead(qint64 currentMs, int transitionDurationMs)
{
    // Find if playhead is within or transitioning into/out of a zoom segment
    const ZoomSegment *activeSeg = nullptr;
    const ZoomSegment *prevSeg = nullptr;
    const ZoomSegment *nextSeg = nullptr;

    for (int i = 0; i < m_segments.size(); ++i) {
        const auto &seg = m_segments[i];
        if (currentMs >= seg.startTimeMs && currentMs <= seg.endTimeMs) {
            activeSeg = &seg;
            break;
        } else if (currentMs < seg.startTimeMs) {
            nextSeg = &seg;
            if (i > 0) prevSeg = &m_segments[i - 1];
            break;
        } else {
            prevSeg = &seg;
        }
    }

    qreal targetScale = 1.0;
    qreal targetX = 0.5;
    qreal targetY = 0.5;
    bool active = false;

    if (activeSeg) {
        active = true;
        qint64 elapsed = currentMs - activeSeg->startTimeMs;
        qint64 remaining = activeSeg->endTimeMs - currentMs;

        if (elapsed < transitionDurationMs) {
            // Easing in
            qreal t = smoothStep(0.0, 1.0, static_cast<qreal>(elapsed) / transitionDurationMs);
            targetScale = 1.0 + (activeSeg->scale - 1.0) * t;
            targetX = 0.5 + (activeSeg->targetX - 0.5) * t;
            targetY = 0.5 + (activeSeg->targetY - 0.5) * t;
        } else if (remaining < transitionDurationMs) {
            // Easing out
            qreal t = smoothStep(0.0, 1.0, static_cast<qreal>(remaining) / transitionDurationMs);
            targetScale = 1.0 + (activeSeg->scale - 1.0) * t;
            targetX = 0.5 + (activeSeg->targetX - 0.5) * t;
            targetY = 0.5 + (activeSeg->targetY - 0.5) * t;
        } else {
            // Fully zoomed in
            targetScale = activeSeg->scale;
            targetX = activeSeg->targetX;
            targetY = activeSeg->targetY;
        }
    }

    if (!qFuzzyCompare(m_currentScale, targetScale) ||
        !qFuzzyCompare(m_currentTargetX, targetX) ||
        !qFuzzyCompare(m_currentTargetY, targetY) ||
        m_isZoomActive != active) {
        m_currentScale = targetScale;
        m_currentTargetX = targetX;
        m_currentTargetY = targetY;
        m_isZoomActive = active;
        emit currentZoomStateChanged();
    }
}

void ZoomEngine::generateAutoZoomsFromClicks(const QVariantList &clicksList, qreal defaultScale)
{
    clearSegments();

    if (clicksList.isEmpty()) {
        return;
    }

    // Auto-cluster clicks and plan cinematic camera shots (Screen Studio style)
    for (const auto &var : clicksList) {
        QVariantMap click = var.toMap();
        qint64 t = click.value("timeMs", 0).toLongLong();
        qreal x = click.value("x", 0.5).toReal();
        qreal y = click.value("y", 0.5).toReal();
        QString label = click.value("label", "Action").toString();

        qint64 startMs = qMax(qint64(0), t - 300);
        qint64 endMs = t + 2200; // Hold zoom for 2.2s

        // If overlaps with the last added segment, extend it or blend
        if (!m_segments.isEmpty() && startMs <= m_segments.last().endTimeMs + 600) {
            m_segments.last().endTimeMs = qMax(m_segments.last().endTimeMs, endMs);
            // Slightly nudge target towards latest click
            m_segments.last().targetX = (m_segments.last().targetX + x) * 0.5;
            m_segments.last().targetY = (m_segments.last().targetY + y) * 0.5;
        } else {
            addSegment(startMs, endMs, x, y, defaultScale, label);
        }
    }

    emit segmentsChanged();
}

void ZoomEngine::setCurrentTarget(qreal x, qreal y, qreal scale)
{
    m_currentTargetX = qBound(0.0, x, 1.0);
    m_currentTargetY = qBound(0.0, y, 1.0);
    if (scale > 1.0) {
        m_currentScale = qBound(1.0, scale, 3.5);
        m_isZoomActive = true;
    }
    emit currentZoomStateChanged();
}
