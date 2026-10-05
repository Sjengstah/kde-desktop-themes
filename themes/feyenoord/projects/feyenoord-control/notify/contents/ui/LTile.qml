import QtQuick
import org.kde.kirigami as Kirigami
import "."

// Quick-settings tile: FEYENOORD block that toggles, with an optional details arrow.
Item {
    id: tile

    property string title
    property string subtitle
    property string iconName
    property color accent: Feyenoord.orange
    property bool active: false
    property bool hasDetails: false
    signal toggled()
    signal details()

    implicitHeight: 7 * Feyenoord.u

    Rectangle {
        id: body
        width: tile.hasDetails ? parent.width - arrow.width - 0.5 * Feyenoord.u : parent.width
        height: parent.height
        topLeftRadius: Feyenoord.round ? 2.5 * Feyenoord.u : 0
        bottomLeftRadius: Feyenoord.round ? 2.5 * Feyenoord.u : 0
        topRightRadius: Feyenoord.round && !tile.hasDetails ? 2.5 * Feyenoord.u : 0
        bottomRightRadius: Feyenoord.round && !tile.hasDetails ? 2.5 * Feyenoord.u : 0
        color: tile.active ? tile.accent : (bodyMouse.containsMouse ? Feyenoord.dim(tile.accent, 0.3) : Feyenoord.dim(tile.accent, 0.14))
        border.color: tile.active ? "transparent" : Feyenoord.dim(tile.accent, 0.6)
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Kirigami.Icon {
            id: icon
            x: 1.4 * Feyenoord.u
            anchors.verticalCenter: parent.verticalCenter
            width: 3.2 * Feyenoord.u
            height: width
            source: tile.iconName
            fallback: tile.iconName.replace("-symbolic", "")
            color: tile.active ? Feyenoord.ink(tile.accent) : tile.accent
            isMask: true
        }
        LText {
            id: titleText
            x: icon.x + icon.width + 1.2 * Feyenoord.u
            y: 1.2 * Feyenoord.u
            width: parent.width - x - Feyenoord.u
            text: tile.title
            color: tile.active ? Feyenoord.ink(tile.accent) : tile.accent
            font.pixelSize: 2.3 * Feyenoord.u
        }
        LText {
            x: titleText.x
            // pinned to the bottom, so tall fonts don't push it out of the tile
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0.8 * Feyenoord.u
            width: titleText.width
            text: tile.subtitle
            color: tile.active ? Feyenoord.dim(Feyenoord.ink(tile.accent), 0.75) : Feyenoord.tan
            font.pixelSize: 1.7 * Feyenoord.u
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
        width: 3.4 * Feyenoord.u
        height: parent.height
        topRightRadius: Feyenoord.round ? 2.5 * Feyenoord.u : 0
        bottomRightRadius: Feyenoord.round ? 2.5 * Feyenoord.u : 0
        color: arrowMouse.containsMouse ? tile.accent : Feyenoord.dim(tile.accent, 0.45)
        LText {
            anchors.centerIn: parent
            text: "›"
            color: Feyenoord.ink(tile.accent)
            font.pixelSize: 3.6 * Feyenoord.u
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
