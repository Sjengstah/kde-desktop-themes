import QtQuick
import org.kde.kirigami as Kirigami
import "."

// Quick-settings tile: ORANJE block that toggles, with an optional details arrow.
Item {
    id: tile

    property string title
    property string subtitle
    property string iconName
    property color accent: Oranje.orange
    property bool active: false
    property bool hasDetails: false
    signal toggled()
    signal details()

    implicitHeight: 7 * Oranje.u

    Rectangle {
        id: body
        width: tile.hasDetails ? parent.width - arrow.width - 0.5 * Oranje.u : parent.width
        height: parent.height
        topLeftRadius: Oranje.round ? 2.5 * Oranje.u : 0
        bottomLeftRadius: Oranje.round ? 2.5 * Oranje.u : 0
        topRightRadius: Oranje.round && !tile.hasDetails ? 2.5 * Oranje.u : 0
        bottomRightRadius: Oranje.round && !tile.hasDetails ? 2.5 * Oranje.u : 0
        color: tile.active ? tile.accent : (bodyMouse.containsMouse ? Oranje.dim(tile.accent, 0.3) : Oranje.dim(tile.accent, 0.14))
        border.color: tile.active ? "transparent" : Oranje.dim(tile.accent, 0.6)
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Kirigami.Icon {
            id: icon
            x: 1.4 * Oranje.u
            anchors.verticalCenter: parent.verticalCenter
            width: 3.2 * Oranje.u
            height: width
            source: tile.iconName
            fallback: tile.iconName.replace("-symbolic", "")
            color: tile.active ? Oranje.ink(tile.accent) : tile.accent
            isMask: true
        }
        LText {
            id: titleText
            x: icon.x + icon.width + 1.2 * Oranje.u
            y: 1.2 * Oranje.u
            width: parent.width - x - Oranje.u
            text: tile.title
            color: tile.active ? Oranje.ink(tile.accent) : tile.accent
            font.pixelSize: 2.3 * Oranje.u
        }
        LText {
            x: titleText.x
            anchors.top: titleText.bottom
            anchors.topMargin: 0.4 * Oranje.u
            width: titleText.width
            text: tile.subtitle
            color: tile.active ? Oranje.dim(Oranje.ink(tile.accent), 0.75) : Oranje.tan
            font.pixelSize: 1.7 * Oranje.u
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
        width: 3.4 * Oranje.u
        height: parent.height
        topRightRadius: Oranje.round ? 2.5 * Oranje.u : 0
        bottomRightRadius: Oranje.round ? 2.5 * Oranje.u : 0
        color: arrowMouse.containsMouse ? tile.accent : Oranje.dim(tile.accent, 0.45)
        LText {
            anchors.centerIn: parent
            text: "›"
            color: Oranje.ink(tile.accent)
            font.pixelSize: 3.6 * Oranje.u
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
