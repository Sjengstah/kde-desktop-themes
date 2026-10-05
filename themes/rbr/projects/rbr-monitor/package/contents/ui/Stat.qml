import QtQuick
import "."

// Small caption above a readout value.
Column {
    id: s

    property string label
    property string value
    property color color: Rbr.gold
    property real u: 8

    spacing: 0
    LText { text: s.label; color: Rbr.tan; opacity: 0.75; font.pixelSize: 1.5 * s.u }
    LText { text: s.value; color: s.color; font.pixelSize: 2.4 * s.u }
}
