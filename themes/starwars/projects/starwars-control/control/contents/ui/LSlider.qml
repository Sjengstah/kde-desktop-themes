import QtQuick
import "."

// Segmented STARWARS slider; value in 0..1. Drag, click or scroll.
Item {
    id: slider

    property real value: 0
    property color accent: StarWars.orange
    property bool muted: false
    property int segments: 28
    signal moved(real value)

    implicitHeight: 2 * StarWars.u
    readonly property real gap: Math.max(1, 0.25 * StarWars.u)
    readonly property int lit: Math.round(Math.max(0, Math.min(1, value)) * segments)

    Row {
        anchors.fill: parent
        spacing: slider.gap
        Repeater {
            model: slider.segments
            Rectangle {
                required property int index
                width: (slider.width - slider.gap * (slider.segments - 1)) / slider.segments
                height: slider.height
                color: index < slider.lit ? (slider.muted ? StarWars.dim(slider.accent, 0.35) : slider.accent) : StarWars.dim(slider.accent)
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        anchors.margins: -StarWars.u
        cursorShape: Qt.PointingHandCursor
        function update(mx) {
            slider.moved(Math.max(0, Math.min(1, (mx - StarWars.u) / slider.width)))
        }
        onPressed: mouse => update(mouse.x)
        onPositionChanged: mouse => { if (pressed) update(mouse.x) }
        onWheel: wheel => slider.moved(Math.max(0, Math.min(1, slider.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
