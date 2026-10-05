import QtQuick
import org.kde.kirigami as Kirigami
import "."

// Quick-settings tile: STARGATE block that toggles, with an optional details arrow.
Item {
    id: tile

    property string title
    property string subtitle
    property string iconName
    property color accent: Stargate.orange
    property bool active: false
    property bool hasDetails: false
    signal toggled()
    signal details()

    implicitHeight: 7 * Stargate.u

    Rectangle {
        id: body
        width: tile.hasDetails ? parent.width - arrow.width - 0.5 * Stargate.u : parent.width
        height: parent.height
        topLeftRadius: Stargate.round ? 2.5 * Stargate.u : 0
        bottomLeftRadius: Stargate.round ? 2.5 * Stargate.u : 0
        topRightRadius: Stargate.round && !tile.hasDetails ? 2.5 * Stargate.u : 0
        bottomRightRadius: Stargate.round && !tile.hasDetails ? 2.5 * Stargate.u : 0
        color: tile.active ? tile.accent : (bodyMouse.containsMouse ? Stargate.dim(tile.accent, 0.3) : Stargate.dim(tile.accent, 0.14))
        border.color: tile.active ? "transparent" : Stargate.dim(tile.accent, 0.6)
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Kirigami.Icon {
            id: icon
            x: 1.4 * Stargate.u
            anchors.verticalCenter: parent.verticalCenter
            width: 3.2 * Stargate.u
            height: width
            source: tile.iconName
            fallback: tile.iconName.replace("-symbolic", "")
            color: tile.active ? Stargate.ink(tile.accent) : tile.accent
            isMask: true
        }
        LText {
            id: titleText
            x: icon.x + icon.width + 1.2 * Stargate.u
            y: 1.2 * Stargate.u
            width: parent.width - x - Stargate.u
            text: tile.title
            color: tile.active ? Stargate.ink(tile.accent) : tile.accent
            font.pixelSize: 2.3 * Stargate.u
        }
        LText {
            x: titleText.x
            anchors.top: titleText.bottom
            anchors.topMargin: 0.4 * Stargate.u
            width: titleText.width
            text: tile.subtitle
            color: tile.active ? Stargate.dim(Stargate.ink(tile.accent), 0.75) : Stargate.tan
            font.pixelSize: 1.7 * Stargate.u
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
        width: 3.4 * Stargate.u
        height: parent.height
        topRightRadius: Stargate.round ? 2.5 * Stargate.u : 0
        bottomRightRadius: Stargate.round ? 2.5 * Stargate.u : 0
        color: arrowMouse.containsMouse ? tile.accent : Stargate.dim(tile.accent, 0.45)
        LText {
            anchors.centerIn: parent
            text: "›"
            color: Stargate.ink(tile.accent)
            font.pixelSize: 3.6 * Stargate.u
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
