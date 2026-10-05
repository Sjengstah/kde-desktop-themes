import QtQuick
import "."

// RBR header: elbow, title bar and a status line under it.
Item {
    id: h

    property string title
    property string status
    property color statusColor: Rbr.lilac
    property color color: Rbr.orange

    implicitHeight: 7 * Rbr.u

    Elbow {
        id: elbow
        width: 13 * Rbr.u
        height: parent.height
        color: h.color
        sidebarWidth: 7 * Rbr.u
        barHeight: 2.6 * Rbr.u
        outerRadius: 3.5 * Rbr.u
        innerRadius: 1.4 * Rbr.u
    }
    TextMetrics {
        id: titleMetrics
        font.family: Rbr.font
        font.italic: Rbr.italic
        font.weight: Font.DemiBold
        font.pixelSize: 3.4 * Rbr.u
        text: h.title.toUpperCase()
    }
    Row {
        x: elbow.width + 0.5 * Rbr.u
        width: parent.width - x
        spacing: 0.5 * Rbr.u
        Rectangle { width: Math.max(Rbr.u, parent.width - titleText.width - 6 * Rbr.u); height: 2.6 * Rbr.u; color: Rbr.violet }
        LText {
            id: titleText
            // never wider than the space next to the elbow (it shrinks to fit instead)
            width: Math.min(Math.ceil(titleMetrics.advanceWidth) + 2, parent.width - 7 * Rbr.u)
            height: 2.6 * Rbr.u
            verticalAlignment: Text.AlignVCenter
            text: h.title
            color: h.color
            font.pixelSize: 3.4 * Rbr.u
        }
        Rectangle { width: 2.5 * Rbr.u; height: 2.6 * Rbr.u; color: Rbr.peach }
        Rectangle { width: 2.5 * Rbr.u; height: 2.6 * Rbr.u; color: h.color }
    }
    LText {
        x: 8.5 * Rbr.u
        width: parent.width - x
        anchors.bottom: parent.bottom
        text: h.status
        color: h.statusColor
        font.pixelSize: 1.9 * Rbr.u
    }
}
