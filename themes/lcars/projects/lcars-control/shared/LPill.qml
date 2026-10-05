import QtQuick
import "."

// LCARS pill button: filled when active, outlined otherwise.
Rectangle {
    id: pill

    property string text
    property color accent: Lcars.orange
    property bool active: false
    property real fontSize: 1.8 * Lcars.u
    signal clicked()

    implicitHeight: 3.2 * Lcars.u
    implicitWidth: label.implicitWidth + 3 * Lcars.u
    radius: height / 2
    opacity: enabled ? 1 : 0.4
    color: active ? accent : (mouse.containsMouse ? Lcars.dim(accent, 0.3) : "transparent")
    border.color: accent
    border.width: active ? 0 : Math.max(1, 0.18 * Lcars.u)
    Behavior on color { ColorAnimation { duration: 120 } }

    LText {
        id: label
        anchors.centerIn: parent
        width: Math.min(implicitWidth, pill.width - 1.6 * Lcars.u)
        text: pill.text
        color: pill.active ? "black" : pill.accent
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
