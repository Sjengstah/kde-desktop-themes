import QtQuick
import org.kde.kirigami as Kirigami
import "."

// Quick-settings tile: MVV block that toggles, with an optional details arrow.
Item {
    id: tile

    property string title
    property string subtitle
    property string iconName
    property color accent: Mvv.orange
    property bool active: false
    property bool hasDetails: false
    signal toggled()
    signal details()

    implicitHeight: 7 * Mvv.u

    Rectangle {
        id: body
        width: tile.hasDetails ? parent.width - arrow.width - 0.5 * Mvv.u : parent.width
        height: parent.height
        topLeftRadius: Mvv.round ? 2.5 * Mvv.u : 0
        bottomLeftRadius: Mvv.round ? 2.5 * Mvv.u : 0
        topRightRadius: Mvv.round && !tile.hasDetails ? 2.5 * Mvv.u : 0
        bottomRightRadius: Mvv.round && !tile.hasDetails ? 2.5 * Mvv.u : 0
        color: tile.active ? tile.accent : (bodyMouse.containsMouse ? Mvv.dim(tile.accent, 0.3) : Mvv.dim(tile.accent, 0.14))
        border.color: tile.active ? "transparent" : Mvv.dim(tile.accent, 0.6)
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Kirigami.Icon {
            id: icon
            x: 1.4 * Mvv.u
            anchors.verticalCenter: parent.verticalCenter
            width: 3.2 * Mvv.u
            height: width
            source: tile.iconName
            fallback: tile.iconName.replace("-symbolic", "")
            color: tile.active ? Mvv.ink(tile.accent) : tile.accent
            isMask: true
        }
        LText {
            id: titleText
            x: icon.x + icon.width + 1.2 * Mvv.u
            y: 1.2 * Mvv.u
            width: parent.width - x - Mvv.u
            text: tile.title
            color: tile.active ? Mvv.ink(tile.accent) : tile.accent
            font.pixelSize: 2.3 * Mvv.u
        }
        LText {
            x: titleText.x
            // pinned to the bottom, so tall fonts don't push it out of the tile
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0.8 * Mvv.u
            width: titleText.width
            text: tile.subtitle
            color: tile.active ? Mvv.dim(Mvv.ink(tile.accent), 0.75) : Mvv.tan
            font.pixelSize: 1.7 * Mvv.u
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
        width: 3.4 * Mvv.u
        height: parent.height
        topRightRadius: Mvv.round ? 2.5 * Mvv.u : 0
        bottomRightRadius: Mvv.round ? 2.5 * Mvv.u : 0
        color: arrowMouse.containsMouse ? tile.accent : Mvv.dim(tile.accent, 0.45)
        LText {
            anchors.centerIn: parent
            text: "›"
            color: Mvv.ink(tile.accent)
            font.pixelSize: 3.6 * Mvv.u
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
