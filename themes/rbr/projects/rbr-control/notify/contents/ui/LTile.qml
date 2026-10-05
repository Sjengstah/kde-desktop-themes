import QtQuick
import org.kde.kirigami as Kirigami
import "."

// Quick-settings tile: RBR block that toggles, with an optional details arrow.
Item {
    id: tile

    property string title
    property string subtitle
    property string iconName
    property color accent: Rbr.orange
    property bool active: false
    property bool hasDetails: false
    signal toggled()
    signal details()

    implicitHeight: 7 * Rbr.u

    Rectangle {
        id: body
        width: tile.hasDetails ? parent.width - arrow.width - 0.5 * Rbr.u : parent.width
        height: parent.height
        topLeftRadius: 0
        bottomLeftRadius: 0
        topRightRadius: 0
        bottomRightRadius: 0
        color: tile.active ? tile.accent : (bodyMouse.containsMouse ? Rbr.dim(tile.accent, 0.3) : Rbr.dim(tile.accent, 0.14))
        border.color: tile.active ? "transparent" : Rbr.dim(tile.accent, 0.6)
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Kirigami.Icon {
            id: icon
            x: 1.4 * Rbr.u
            anchors.verticalCenter: parent.verticalCenter
            width: 3.2 * Rbr.u
            height: width
            source: tile.iconName
            fallback: tile.iconName.replace("-symbolic", "")
            color: tile.active ? Rbr.ink(tile.accent) : tile.accent
            isMask: true
        }
        LText {
            id: titleText
            x: icon.x + icon.width + 1.2 * Rbr.u
            y: 1.2 * Rbr.u
            width: parent.width - x - Rbr.u
            text: tile.title
            color: tile.active ? Rbr.ink(tile.accent) : tile.accent
            font.pixelSize: 2.3 * Rbr.u
        }
        LText {
            x: titleText.x
            // pinned to the bottom, so tall fonts don't push it out of the tile
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0.8 * Rbr.u
            width: titleText.width
            text: tile.subtitle
            color: tile.active ? Rbr.dim(Rbr.ink(tile.accent), 0.75) : Rbr.tan
            font.pixelSize: 1.7 * Rbr.u
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
        width: 3.4 * Rbr.u
        height: parent.height
        topRightRadius: 0
        bottomRightRadius: 0
        color: arrowMouse.containsMouse ? tile.accent : Rbr.dim(tile.accent, 0.45)
        LText {
            anchors.centerIn: parent
            text: "›"
            color: Rbr.ink(tile.accent)
            font.pixelSize: 3.6 * Rbr.u
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
