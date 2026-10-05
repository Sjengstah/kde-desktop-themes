import QtQuick
import "."

// Segmented FEYENOORD bar gauge, value in 0..1.
Item {
    id: bar

    property real value: 0
    property color color: Feyenoord.orange
    property real alertAt: 0.9
    property int segments: 32
    readonly property real gap: Math.max(1, Math.round(height * 0.22))
    readonly property int lit: Math.round(Math.max(0, Math.min(1, value)) * segments)
    readonly property color litColor: value >= alertAt ? Feyenoord.alert : color

    Row {
        anchors.fill: parent
        spacing: bar.gap
        Repeater {
            model: bar.segments
            Rectangle {
                required property int index
                width: (bar.width - bar.gap * (bar.segments - 1)) / bar.segments
                height: bar.height
                color: index < bar.lit ? bar.litColor : Feyenoord.dim(bar.color)
                Behavior on color { ColorAnimation { duration: 180 } }
            }
        }
    }
}
