import QtQuick

// RBR corner: sidebar and bar joined by a 45° cut outer corner and a chamfered inner corner.
Canvas {
    id: e

    property color color: "#DB0A40"
    property real sidebarWidth: 40
    property real barHeight: 16
    property real outerRadius: 24
    property real innerRadius: 10
    property bool flipped: false

    onColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const c = getContext("2d")
        c.reset()
        const w = width, h = height, sw = sidebarWidth, bh = barHeight
        const R = Math.min(outerRadius, h, sw), r = Math.min(innerRadius, h - bh, w - sw)
        c.save()
        if (flipped) {
            c.translate(0, h)
            c.scale(1, -1)
        }
        c.fillStyle = e.color
        c.beginPath()
        c.moveTo(0, h); c.lineTo(0, R); c.lineTo(R, 0)
        c.lineTo(w, 0); c.lineTo(w, bh); c.lineTo(sw + r, bh)
        c.lineTo(sw, bh + r); c.lineTo(sw, h)
        c.closePath(); c.fill()
        c.restore()
    }
}
