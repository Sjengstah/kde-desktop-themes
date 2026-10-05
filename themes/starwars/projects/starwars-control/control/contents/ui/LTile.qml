import QtQuick
import org.kde.kirigami as Kirigami
import "."

// Quick-settings tile: STARWARS block that toggles, with an optional details arrow.
Item {
    id: tile

    property string title
    property string subtitle
    property string iconName
    property color accent: StarWars.orange
    property bool active: false
    property bool hasDetails: false
    signal toggled()
    signal details()

    implicitHeight: 7 * StarWars.u

    Rectangle {
        id: body
        width: tile.hasDetails ? parent.width - arrow.width - 0.5 * StarWars.u : parent.width
        height: parent.height
        topLeftRadius: StarWars.round ? 2.5 * StarWars.u : 0
        bottomLeftRadius: StarWars.round ? 2.5 * StarWars.u : 0
        topRightRadius: StarWars.round && !tile.hasDetails ? 2.5 * StarWars.u : 0
        bottomRightRadius: StarWars.round && !tile.hasDetails ? 2.5 * StarWars.u : 0
        color: tile.active ? tile.accent : (bodyMouse.containsMouse ? StarWars.dim(tile.accent, 0.3) : StarWars.dim(tile.accent, 0.14))
        border.color: tile.active ? "transparent" : StarWars.dim(tile.accent, 0.6)
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Kirigami.Icon {
            id: icon
            x: 1.4 * StarWars.u
            anchors.verticalCenter: parent.verticalCenter
            width: 3.2 * StarWars.u
            height: width
            source: tile.iconName
            fallback: tile.iconName.replace("-symbolic", "")
            color: tile.active ? StarWars.ink(tile.accent) : tile.accent
            isMask: true
        }
        LText {
            id: titleText
            x: icon.x + icon.width + 1.2 * StarWars.u
            y: 1.2 * StarWars.u
            width: parent.width - x - StarWars.u
            text: tile.title
            color: tile.active ? StarWars.ink(tile.accent) : tile.accent
            font.pixelSize: 2.3 * StarWars.u
        }
        LText {
            x: titleText.x
            // pinned to the bottom, so tall fonts don't push it out of the tile
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0.8 * StarWars.u
            width: titleText.width
            text: tile.subtitle
            color: tile.active ? StarWars.dim(StarWars.ink(tile.accent), 0.75) : StarWars.tan
            font.pixelSize: 1.7 * StarWars.u
        }
        MouseArea {
            id: bodyMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.toggled()
        }
    }

    Rectangle {
        id: arrow
        visible: tile.hasDetails
        anchors.right: parent.right
        width: 3.4 * StarWars.u
        height: parent.height
        topRightRadius: StarWars.round ? 2.5 * StarWars.u : 0
        bottomRightRadius: StarWars.round ? 2.5 * StarWars.u : 0
        color: arrowMouse.containsMouse ? tile.accent : StarWars.dim(tile.accent, 0.45)
        LText {
            anchors.centerIn: parent
            text: "›"
            color: StarWars.ink(tile.accent)
            font.pixelSize: 3.6 * StarWars.u
        }
        MouseArea {
            id: arrowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.details()
        }
    }
}
