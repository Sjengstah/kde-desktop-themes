import QtQuick
import "."

// FEYENOORD header: elbow, title bar and a status line under it.
Item {
    id: h

    property string title
    property string status
    property color statusColor: Feyenoord.lilac
    property color color: Feyenoord.orange

    implicitHeight: 7 * Feyenoord.u

    Elbow {
        id: elbow
        width: 13 * Feyenoord.u
        height: parent.height
        color: h.color
        sidebarWidth: 7 * Feyenoord.u
        barHeight: 2.6 * Feyenoord.u
        outerRadius: 3.5 * Feyenoord.u
        innerRadius: 1.4 * Feyenoord.u
    }
    TextMetrics {
        id: titleMetrics
        font.family: Feyenoord.font
        font.italic: Feyenoord.italic
        font.weight: Font.DemiBold
        font.pixelSize: 3.4 * Feyenoord.u
        text: h.title.toUpperCase()
    }
    Row {
        x: elbow.width + 0.5 * Feyenoord.u
        width: parent.width - x
        spacing: 0.5 * Feyenoord.u
        Rectangle { width: Math.max(Feyenoord.u, parent.width - titleText.width - 6 * Feyenoord.u); height: 2.6 * Feyenoord.u; color: Feyenoord.violet }
        LText {
            id: titleText
            // never wider than the space next to the elbow (it shrinks to fit instead)
            width: Math.min(Math.ceil(titleMetrics.advanceWidth) + 2, parent.width - 7 * Feyenoord.u)
            height: 2.6 * Feyenoord.u
            verticalAlignment: Text.AlignVCenter
            text: h.title
            color: h.color
            font.pixelSize: 3.4 * Feyenoord.u
        }
        Rectangle { width: 2.5 * Feyenoord.u; height: 2.6 * Feyenoord.u; color: Feyenoord.peach }
        Rectangle { width: 2.5 * Feyenoord.u; height: 2.6 * Feyenoord.u; color: h.color; radius: Feyenoord.round ? height / 2 : 0 }
    }
    LText {
        x: 8.5 * Feyenoord.u
        width: parent.width - x
        anchors.bottom: parent.bottom
        text: h.status
        color: h.statusColor
        font.pixelSize: 1.9 * Feyenoord.u
    }
}
