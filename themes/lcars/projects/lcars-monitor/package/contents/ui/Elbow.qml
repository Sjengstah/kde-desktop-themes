import QtQuick

// LCARS corner: sidebar and horizontal bar joined by a rounded outer corner
// and a concave inner corner. Set flipped to mirror it vertically.
Canvas {
    id: e

    property color color: "#FF9900"
    property real sidebarWidth: 60
    property real barHeight: 20
    property real outerRadius: 30
    property real innerRadius: 12
    property bool flipped: false

    onColorChanged: requestPaint()
    onSidebarWidthChanged: requestPaint()
    onBarHeightChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const c = getContext("2d")
        c.reset()
        const w = width, h = height, sw = sidebarWidth, bh = barHeight
        const R = Math.min(outerRadius, h, sw)
        const r = Math.min(innerRadius, h - bh, w - sw)
        c.save()
        if (flipped) {
            c.translate(0, h)
            c.scale(1, -1)
        }
        c.fillStyle = e.color
        c.beginPath()
        c.moveTo(0, h)
        c.lineTo(0, R)
        c.arcTo(0, 0, R, 0, R)
        c.lineTo(w, 0)
        c.lineTo(w, bh)
        c.lineTo(sw + r, bh)
        c.arcTo(sw, bh, sw, bh + r, r)
        c.lineTo(sw, h)
        c.closePath()
        c.fill()
        c.restore()
    }
}
