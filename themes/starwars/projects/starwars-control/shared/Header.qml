import QtQuick
import "."

// STARWARS header: elbow, title bar and a status line under it.
Item {
    id: h

    property string title
    property string status
    property color statusColor: StarWars.lilac
    property color color: StarWars.orange

    implicitHeight: 7 * StarWars.u

    Elbow {
        id: elbow
        width: 13 * StarWars.u
        height: parent.height
        color: h.color
        sidebarWidth: 7 * StarWars.u
        barHeight: 2.6 * StarWars.u
        outerRadius: 3.5 * StarWars.u
        innerRadius: 1.4 * StarWars.u
    }
    Row {
        x: elbow.width + 0.5 * StarWars.u
        width: parent.width - x
        spacing: 0.5 * StarWars.u
        Rectangle { width: parent.width - titleText.width - 6 * StarWars.u; height: 2.6 * StarWars.u; color: StarWars.violet }
        LText {
            id: titleText
            height: 2.6 * StarWars.u
            verticalAlignment: Text.AlignVCenter
            text: h.title
            color: h.color
            font.pixelSize: 3.4 * StarWars.u
        }
        Rectangle { width: 2.5 * StarWars.u; height: 2.6 * StarWars.u; color: StarWars.peach }
        Rectangle { width: 2.5 * StarWars.u; height: 2.6 * StarWars.u; color: h.color; radius: StarWars.round ? height / 2 : 0 }
    }
    LText {
        x: 8.5 * StarWars.u
        width: parent.width - x
        anchors.bottom: parent.bottom
        text: h.status
        color: h.statusColor
        font.pixelSize: 1.9 * StarWars.u
    }
}
