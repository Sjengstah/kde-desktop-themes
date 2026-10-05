import QtQuick
import "."

// STARWARS corner: sidebar and horizontal bar joined at the outer and inner corner,
// shaped by the theme (StarWars.corner: "round", "cut" or "square").
// Set flipped to mirror it vertically.
Canvas {
    id: e

    property color color: StarWars.orange
    property string corner: StarWars.corner
    property real sidebarWidth: 60
    property real barHeight: 20
    property real outerRadius: 30
    property real innerRadius: 12
    property bool flipped: false

    onColorChanged: requestPaint()
    onCornerChanged: requestPaint()
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
        if (corner === "round") c.arcTo(0, 0, R, 0, R)
        else if (corner === "square") { c.lineTo(0, 0); c.lineTo(R, 0) }
        else c.lineTo(R, 0)
        c.lineTo(w, 0)
        c.lineTo(w, bh)
        c.lineTo(sw + r, bh)
        if (corner === "round") c.arcTo(sw, bh, sw, bh + r, r)
        else if (corner === "square") { c.lineTo(sw, bh); c.lineTo(sw, bh + r) }
        else c.lineTo(sw, bh + r)
        c.lineTo(sw, h)
        c.closePath()
        c.fill()
        c.restore()
    }
}
