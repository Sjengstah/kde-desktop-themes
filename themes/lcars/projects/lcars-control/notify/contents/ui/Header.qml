import QtQuick
import "."

// LCARS header: elbow, title bar and a status line under it.
Item {
    id: h

    property string title
    property string status
    property color statusColor: Lcars.lilac
    property color color: Lcars.orange

    implicitHeight: 7 * Lcars.u

    Elbow {
        id: elbow
        width: 13 * Lcars.u
        height: parent.height
        color: h.color
        sidebarWidth: 7 * Lcars.u
        barHeight: 2.6 * Lcars.u
        outerRadius: 3.5 * Lcars.u
        innerRadius: 1.4 * Lcars.u
    }
    Row {
        x: elbow.width + 0.5 * Lcars.u
        width: parent.width - x
        spacing: 0.5 * Lcars.u
        Rectangle { width: parent.width - titleText.width - 6 * Lcars.u; height: 2.6 * Lcars.u; color: Lcars.violet }
        LText {
            id: titleText
            height: 2.6 * Lcars.u
            verticalAlignment: Text.AlignVCenter
            text: h.title
            color: h.color
            font.pixelSize: 3.4 * Lcars.u
        }
        Rectangle { width: 2.5 * Lcars.u; height: 2.6 * Lcars.u; color: Lcars.peach }
        Rectangle { width: 2.5 * Lcars.u; height: 2.6 * Lcars.u; color: h.color; radius: height / 2 }
    }
    LText {
        x: 8.5 * Lcars.u
        width: parent.width - x
        anchors.bottom: parent.bottom
        text: h.status
        color: h.statusColor
        font.pixelSize: 1.9 * Lcars.u
    }
}
