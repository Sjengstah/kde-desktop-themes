import QtQuick
import "."

// Bar history that grows up from the bottom, or down from the top when inverted.
Item {
    id: h

    property var values: []
    property real peak: 1
    property int slots: 40
    property color color: Oranje.sky
    property bool inverted: false
    readonly property real gap: Math.max(1, width / slots * 0.25)

    Repeater {
        model: h.values.length
        Rectangle {
            required property int index
            readonly property real frac: Math.min(1, h.values[index] / h.peak)
            x: h.width - (h.values.length - index) * (h.width / h.slots)
            width: h.width / h.slots - h.gap
            height: Math.max(1, frac * h.height)
            y: h.inverted ? 0 : h.height - height
            color: h.color
            opacity: 0.45 + 0.55 * (index + 1) / h.values.length
        }
    }
}
