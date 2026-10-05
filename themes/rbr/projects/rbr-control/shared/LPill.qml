import QtQuick
import "."

// RBR button: filled when active, outlined otherwise.
Rectangle {
    id: pill

    property string text
    property color accent: Rbr.orange
    property bool active: false
    property real fontSize: 1.8 * Rbr.u
    signal clicked()

    implicitHeight: 3.2 * Rbr.u
    implicitWidth: label.implicitWidth + 3 * Rbr.u
    radius: 0
    opacity: enabled ? 1 : 0.4
    color: active ? accent : (mouse.containsMouse ? Rbr.dim(accent, 0.3) : "transparent")
    border.color: accent
    border.width: active ? 0 : Math.max(1, 0.18 * Rbr.u)
    Behavior on color { ColorAnimation { duration: 120 } }

    LText {
        id: label
        anchors.centerIn: parent
        width: Math.min(implicitWidth, pill.width - 1.6 * Rbr.u)
        text: pill.text
        color: pill.active ? Rbr.ink(pill.accent) : pill.accent
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
