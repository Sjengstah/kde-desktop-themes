import QtQuick
import "."

// STARGATE button: filled when active, outlined otherwise.
Rectangle {
    id: pill

    property string text
    property color accent: Stargate.orange
    property bool active: false
    property real fontSize: 1.8 * Stargate.u
    signal clicked()

    implicitHeight: 3.2 * Stargate.u
    implicitWidth: label.implicitWidth + 3 * Stargate.u
    radius: Stargate.round ? height / 2 : 0
    opacity: enabled ? 1 : 0.4
    color: active ? accent : (mouse.containsMouse ? Stargate.dim(accent, 0.3) : "transparent")
    border.color: accent
    border.width: active ? 0 : Math.max(1, 0.18 * Stargate.u)
    Behavior on color { ColorAnimation { duration: 120 } }

    LText {
        id: label
        anchors.centerIn: parent
        width: Math.min(implicitWidth, pill.width - 1.6 * Stargate.u)
        text: pill.text
        color: pill.active ? Stargate.ink(pill.accent) : pill.accent
        font.pixelSize: pill.fontSize
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: pill.clicked()
    }
}
