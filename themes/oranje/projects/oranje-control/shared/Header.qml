import QtQuick
import "."

// ORANJE header: elbow, title bar and a status line under it.
Item {
    id: h

    property string title
    property string status
    property color statusColor: Oranje.lilac
    property color color: Oranje.orange

    implicitHeight: 7 * Oranje.u

    Elbow {
        id: elbow
        width: 13 * Oranje.u
        height: parent.height
        color: h.color
        sidebarWidth: 7 * Oranje.u
        barHeight: 2.6 * Oranje.u
        outerRadius: 3.5 * Oranje.u
        innerRadius: 1.4 * Oranje.u
    }
    TextMetrics {
        id: titleMetrics
        font.family: Oranje.font
        font.italic: Oranje.italic
        font.weight: Font.DemiBold
        font.pixelSize: 3.4 * Oranje.u
        text: h.title.toUpperCase()
    }
    Row {
        x: elbow.width + 0.5 * Oranje.u
        width: parent.width - x
        spacing: 0.5 * Oranje.u
        Rectangle { width: Math.max(Oranje.u, parent.width - titleText.width - 6 * Oranje.u); height: 2.6 * Oranje.u; color: Oranje.violet }
        LText {
            id: titleText
            // never wider than the space next to the elbow (it shrinks to fit instead)
            width: Math.min(Math.ceil(titleMetrics.advanceWidth) + 2, parent.width - 7 * Oranje.u)
            height: 2.6 * Oranje.u
            verticalAlignment: Text.AlignVCenter
            text: h.title
            color: h.color
            font.pixelSize: 3.4 * Oranje.u
        }
        Rectangle { width: 2.5 * Oranje.u; height: 2.6 * Oranje.u; color: Oranje.peach }
        Rectangle { width: 2.5 * Oranje.u; height: 2.6 * Oranje.u; color: h.color; radius: Oranje.round ? height / 2 : 0 }
    }
    LText {
        x: 8.5 * Oranje.u
        width: parent.width - x
        anchors.bottom: parent.bottom
        text: h.status
        color: h.statusColor
        font.pixelSize: 1.9 * Oranje.u
    }
}
