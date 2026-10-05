import QtQuick
import org.kde.kirigami as Kirigami
import "."

// Quick-settings tile: MAASTRICHT block that toggles, with an optional details arrow.
Item {
    id: tile

    property string title
    property string subtitle
    property string iconName
    property color accent: Maastricht.orange
    property bool active: false
    property bool hasDetails: false
    signal toggled()
    signal details()

    implicitHeight: 7 * Maastricht.u

    Rectangle {
        id: body
        width: tile.hasDetails ? parent.width - arrow.width - 0.5 * Maastricht.u : parent.width
        height: parent.height
        topLeftRadius: Maastricht.round ? 2.5 * Maastricht.u : 0
        bottomLeftRadius: Maastricht.round ? 2.5 * Maastricht.u : 0
        topRightRadius: Maastricht.round && !tile.hasDetails ? 2.5 * Maastricht.u : 0
        bottomRightRadius: Maastricht.round && !tile.hasDetails ? 2.5 * Maastricht.u : 0
        color: tile.active ? tile.accent : (bodyMouse.containsMouse ? Maastricht.dim(tile.accent, 0.3) : Maastricht.dim(tile.accent, 0.14))
        border.color: tile.active ? "transparent" : Maastricht.dim(tile.accent, 0.6)
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Kirigami.Icon {
            id: icon
            x: 1.4 * Maastricht.u
            anchors.verticalCenter: parent.verticalCenter
            width: 3.2 * Maastricht.u
            height: width
            source: tile.iconName
            fallback: tile.iconName.replace("-symbolic", "")
            color: tile.active ? Maastricht.ink(tile.accent) : tile.accent
            isMask: true
        }
        LText {
            id: titleText
            x: icon.x + icon.width + 1.2 * Maastricht.u
            y: 1.2 * Maastricht.u
            width: parent.width - x - Maastricht.u
            text: tile.title
            color: tile.active ? Maastricht.ink(tile.accent) : tile.accent
            font.pixelSize: 2.3 * Maastricht.u
        }
        LText {
            x: titleText.x
            // pinned to the bottom, so tall fonts don't push it out of the tile
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0.8 * Maastricht.u
            width: titleText.width
            text: tile.subtitle
            color: tile.active ? Maastricht.dim(Maastricht.ink(tile.accent), 0.75) : Maastricht.tan
            font.pixelSize: 1.7 * Maastricht.u
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
        width: 3.4 * Maastricht.u
        height: parent.height
        topRightRadius: Maastricht.round ? 2.5 * Maastricht.u : 0
        bottomRightRadius: Maastricht.round ? 2.5 * Maastricht.u : 0
        color: arrowMouse.containsMouse ? tile.accent : Maastricht.dim(tile.accent, 0.45)
        LText {
            anchors.centerIn: parent
            text: "›"
            color: Maastricht.ink(tile.accent)
            font.pixelSize: 3.6 * Maastricht.u
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
