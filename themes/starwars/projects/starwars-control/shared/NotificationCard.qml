import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager
import "."

// One STARWARS notification card, used for popups and for the history list.
Item {
    id: card

    required property var model
    required property int index
    required property var notifications        // the Notifications model this card belongs to
    property date now: new Date()
    property real progress: -1                  // 0..1 remaining time, -1 = no timeout bar
    readonly property bool hovered: hover.hovered
    signal activated()                          // default action or an action button was used

    readonly property real u: StarWars.u
    readonly property var modelIndex: notifications.index(index, 0)
    readonly property color accent: model.urgency === NotificationManager.Notifications.CriticalUrgency ? StarWars.alert
                                  : model.urgency === NotificationManager.Notifications.LowUrgency ? StarWars.lilac
                                  : StarWars.peach

    implicitHeight: cardColumn.implicitHeight + 2 * u + (progress >= 0 ? 0.9 * u : 0)

    function ago(date) {
        if (!date || isNaN(date)) return ""
        const s = Math.max(0, (now - date) / 1000)
        if (s < 60) return "NOW"
        if (s < 3600) return Math.floor(s / 60) + " MIN AGO"
        if (s < 86400) return Math.floor(s / 3600) + " H AGO"
        return Qt.formatDateTime(date, "ddd d MMM HH:mm").toUpperCase()
    }

    HoverHandler { id: hover }

    Rectangle {
        anchors.fill: parent
        radius: StarWars.round ? 1.5 * u : 0
        color: StarWars.dim(StarWars.navy, 0.94)
        border.color: StarWars.dim(card.accent, card.hovered ? 0.8 : 0.45)
        border.width: 1
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: StarWars.dim(card.accent, card.hovered ? 0.14 : 0.07)
        }
    }
    // STARWARS sidebar in the urgency colour
    Rectangle {
        width: 1.2 * u
        height: parent.height
        topLeftRadius: StarWars.round ? 1.5 * u : 0
        bottomLeftRadius: StarWars.round ? 1.5 * u : 0
        color: card.accent
    }

    TapHandler {
        onTapped: {
            if (card.model.hasDefaultAction) {
                card.notifications.invokeDefaultAction(card.modelIndex)
                card.activated()
            }
        }
    }

    Column {
        id: cardColumn
        x: 2.4 * u
        y: u
        width: parent.width - x - 1.2 * u
        spacing: 0.5 * u

        Item {
            width: parent.width
            height: 2.4 * u
            Kirigami.Icon {
                id: appIcon
                width: 2.2 * u
                height: width
                anchors.verticalCenter: parent.verticalCenter
                source: card.model.applicationIconName || card.model.iconName || "dialog-information"
            }
            LText {
                x: appIcon.width + 0.8 * u
                width: parent.width - x - timeText.width - closeButton.width - 2 * u
                anchors.verticalCenter: parent.verticalCenter
                text: card.model.applicationName || "SYSTEM"
                color: card.accent
                font.pixelSize: 1.7 * u
            }
            LText {
                id: timeText
                anchors { right: closeButton.left; rightMargin: u; verticalCenter: parent.verticalCenter }
                text: card.ago(card.model.updated || card.model.created)
                color: StarWars.dim(StarWars.tan, 0.6)
                font.pixelSize: 1.5 * u
            }
            Rectangle {
                id: closeButton
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                width: 2.4 * u
                height: width
                radius: StarWars.round ? width / 2 : 0
                color: closeHover.hovered ? StarWars.red : StarWars.dim(StarWars.red, 0.3)
                // Cross drawn as two lines so it sits exactly in the centre of the circle.
                Repeater {
                    model: [45, -45]
                    Rectangle {
                        required property int modelData
                        anchors.centerIn: parent
                        width: parent.width * 0.5
                        height: Math.max(1.5, 0.22 * u)
                        radius: StarWars.round ? height / 2 : 0
                        rotation: modelData
                        antialiasing: true
                        color: closeHover.hovered ? StarWars.ink(StarWars.red) : StarWars.red
                    }
                }
                HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: card.notifications.close(card.modelIndex) }
            }
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: card.model.summary || ""
            color: StarWars.gold
            font.family: StarWars.font
            font.italic: StarWars.italic
            font.weight: Font.DemiBold
            font.pixelSize: 2.1 * u
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            textFormat: Text.PlainText
        }
        Text {
            width: parent.width
            visible: text !== ""
            text: card.model.body || ""
            color: StarWars.tan
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
            textFormat: Text.StyledText
            linkColor: StarWars.sky
            onLinkActivated: link => Qt.openUrlExternally(link)
        }

        Flow {
            width: parent.width
            spacing: 0.5 * u
            visible: (card.model.actionNames || []).length > 0
            Repeater {
                model: card.model.actionNames || []
                LPill {
                    required property string modelData
                    required property int index
                    text: (card.model.actionLabels || [])[index] || modelData
                    accent: card.accent
                    height: 2.8 * u
                    fontSize: 1.6 * u
                    onClicked: {
                        card.notifications.invokeAction(card.modelIndex, modelData)
                        card.activated()
                    }
                }
            }
        }
    }

    // Remaining display time as a shrinking STARWARS bar
    Rectangle {
        visible: card.progress >= 0
        x: 2.4 * u
        anchors { bottom: parent.bottom; bottomMargin: 0.7 * u }
        width: (parent.width - x - 1.2 * u) * Math.max(0, card.progress)
        height: 0.4 * u
        radius: StarWars.round ? height / 2 : 0
        color: card.accent
    }
}
