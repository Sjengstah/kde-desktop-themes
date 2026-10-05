import QtQuick
import "."

// STARGATE header: elbow, title bar and a status line under it.
Item {
    id: h

    property string title
    property string status
    property color statusColor: Stargate.lilac
    property color color: Stargate.orange

    implicitHeight: 7 * Stargate.u

    Elbow {
        id: elbow
        width: 13 * Stargate.u
        height: parent.height
        color: h.color
        sidebarWidth: 7 * Stargate.u
        barHeight: 2.6 * Stargate.u
        outerRadius: 3.5 * Stargate.u
        innerRadius: 1.4 * Stargate.u
    }
    Row {
        x: elbow.width + 0.5 * Stargate.u
        width: parent.width - x
        spacing: 0.5 * Stargate.u
        Rectangle { width: parent.width - titleText.width - 6 * Stargate.u; height: 2.6 * Stargate.u; color: Stargate.violet }
        LText {
            id: titleText
            height: 2.6 * Stargate.u
            verticalAlignment: Text.AlignVCenter
            text: h.title
            color: h.color
            font.pixelSize: 3.4 * Stargate.u
        }
        Rectangle { width: 2.5 * Stargate.u; height: 2.6 * Stargate.u; color: Stargate.peach }
        Rectangle { width: 2.5 * Stargate.u; height: 2.6 * Stargate.u; color: h.color; radius: Stargate.round ? height / 2 : 0 }
    }
    LText {
        x: 8.5 * Stargate.u
        width: parent.width - x
        anchors.bottom: parent.bottom
        text: h.status
        color: h.statusColor
        font.pixelSize: 1.9 * Stargate.u
    }
}
