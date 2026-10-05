import QtQuick
import org.kde.kirigami as Kirigami
import "."

// Quick-settings tile: LCARS block that toggles, with an optional details arrow.
Item {
    id: tile

    property string title
    property string subtitle
    property string iconName
    property color accent: Lcars.orange
    property bool active: false
    property bool hasDetails: false
    signal toggled()
    signal details()

    implicitHeight: 7 * Lcars.u

    Rectangle {
        id: body
        width: tile.hasDetails ? parent.width - arrow.width - 0.5 * Lcars.u : parent.width
        height: parent.height
        topLeftRadius: 2.5 * Lcars.u
        bottomLeftRadius: 2.5 * Lcars.u
        topRightRadius: tile.hasDetails ? 0 : 2.5 * Lcars.u
        bottomRightRadius: tile.hasDetails ? 0 : 2.5 * Lcars.u
        color: tile.active ? tile.accent : (bodyMouse.containsMouse ? Lcars.dim(tile.accent, 0.3) : Lcars.dim(tile.accent, 0.14))
        border.color: tile.active ? "transparent" : Lcars.dim(tile.accent, 0.6)
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Kirigami.Icon {
            id: icon
            x: 1.4 * Lcars.u
            anchors.verticalCenter: parent.verticalCenter
            width: 3.2 * Lcars.u
            height: width
            source: tile.iconName
            fallback: tile.iconName.replace("-symbolic", "")
            color: tile.active ? "black" : tile.accent
            isMask: true
        }
        LText {
            id: titleText
            x: icon.x + icon.width + 1.2 * Lcars.u
            y: 1.2 * Lcars.u
            width: parent.width - x - Lcars.u
            text: tile.title
            color: tile.active ? "black" : tile.accent
            font.pixelSize: 2.3 * Lcars.u
        }
        LText {
            x: titleText.x
            // pinned to the bottom, so tall fonts don't push it out of the tile
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0.8 * Lcars.u
            width: titleText.width
            text: tile.subtitle
            color: tile.active ? Qt.rgba(0, 0, 0, 0.7) : Lcars.tan
            font.pixelSize: 1.7 * Lcars.u
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
        width: 3.4 * Lcars.u
        height: parent.height
        topRightRadius: 2.5 * Lcars.u
        bottomRightRadius: 2.5 * Lcars.u
        color: arrowMouse.containsMouse ? tile.accent : Lcars.dim(tile.accent, 0.45)
        LText {
            anchors.centerIn: parent
            text: "›"
            color: "black"
            font.pixelSize: 3.6 * Lcars.u
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
