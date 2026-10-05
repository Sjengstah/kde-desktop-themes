import QtQuick
import "."

// MVV header: elbow, title bar and a status line under it.
Item {
    id: h

    property string title
    property string status
    property color statusColor: Mvv.lilac
    property color color: Mvv.orange

    implicitHeight: 7 * Mvv.u

    Elbow {
        id: elbow
        width: 13 * Mvv.u
        height: parent.height
        color: h.color
        sidebarWidth: 7 * Mvv.u
        barHeight: 2.6 * Mvv.u
        outerRadius: 3.5 * Mvv.u
        innerRadius: 1.4 * Mvv.u
    }
    Row {
        x: elbow.width + 0.5 * Mvv.u
        width: parent.width - x
        spacing: 0.5 * Mvv.u
        Rectangle { width: parent.width - titleText.width - 6 * Mvv.u; height: 2.6 * Mvv.u; color: Mvv.violet }
        LText {
            id: titleText
            height: 2.6 * Mvv.u
            verticalAlignment: Text.AlignVCenter
            text: h.title
            color: h.color
            font.pixelSize: 3.4 * Mvv.u
        }
        Rectangle { width: 2.5 * Mvv.u; height: 2.6 * Mvv.u; color: Mvv.peach }
        Rectangle { width: 2.5 * Mvv.u; height: 2.6 * Mvv.u; color: h.color; radius: Mvv.round ? height / 2 : 0 }
    }
    LText {
        x: 8.5 * Mvv.u
        width: parent.width - x
        anchors.bottom: parent.bottom
        text: h.status
        color: h.statusColor
        font.pixelSize: 1.9 * Mvv.u
    }
}
