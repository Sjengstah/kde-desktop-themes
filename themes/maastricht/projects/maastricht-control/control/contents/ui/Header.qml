import QtQuick
import "."

// MAASTRICHT header: elbow, title bar and a status line under it.
Item {
    id: h

    property string title
    property string status
    property color statusColor: Maastricht.lilac
    property color color: Maastricht.orange

    implicitHeight: 7 * Maastricht.u

    Elbow {
        id: elbow
        width: 13 * Maastricht.u
        height: parent.height
        color: h.color
        sidebarWidth: 7 * Maastricht.u
        barHeight: 2.6 * Maastricht.u
        outerRadius: 3.5 * Maastricht.u
        innerRadius: 1.4 * Maastricht.u
    }
    Row {
        x: elbow.width + 0.5 * Maastricht.u
        width: parent.width - x
        spacing: 0.5 * Maastricht.u
        Rectangle { width: parent.width - titleText.width - 6 * Maastricht.u; height: 2.6 * Maastricht.u; color: Maastricht.violet }
        LText {
            id: titleText
            height: 2.6 * Maastricht.u
            verticalAlignment: Text.AlignVCenter
            text: h.title
            color: h.color
            font.pixelSize: 3.4 * Maastricht.u
        }
        Rectangle { width: 2.5 * Maastricht.u; height: 2.6 * Maastricht.u; color: Maastricht.peach }
        Rectangle { width: 2.5 * Maastricht.u; height: 2.6 * Maastricht.u; color: h.color; radius: Maastricht.round ? height / 2 : 0 }
    }
    LText {
        x: 8.5 * Maastricht.u
        width: parent.width - x
        anchors.bottom: parent.bottom
        text: h.status
        color: h.statusColor
        font.pixelSize: 1.9 * Maastricht.u
    }
}
