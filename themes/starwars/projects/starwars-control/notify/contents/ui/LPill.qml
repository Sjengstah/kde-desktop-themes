import QtQuick
import "."

// STARWARS button: filled when active, outlined otherwise.
Rectangle {
    id: pill

    property string text
    property color accent: StarWars.orange
    property bool active: false
    property real fontSize: 1.8 * StarWars.u
    signal clicked()

    implicitHeight: 3.2 * StarWars.u
    implicitWidth: label.implicitWidth + 3 * StarWars.u
    radius: StarWars.round ? height / 2 : 0
    opacity: enabled ? 1 : 0.4
    color: active ? accent : (mouse.containsMouse ? StarWars.dim(accent, 0.3) : "transparent")
    border.color: accent
    border.width: active ? 0 : Math.max(1, 0.18 * StarWars.u)
    Behavior on color { ColorAnimation { duration: 120 } }

    LText {
        id: label
        anchors.centerIn: parent
        width: Math.min(implicitWidth, pill.width - 1.6 * StarWars.u)
        text: pill.text
        color: pill.active ? StarWars.ink(pill.accent) : pill.accent
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
