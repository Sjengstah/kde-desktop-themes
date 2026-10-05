import QtQuick
import QtQuick.Layouts
import org.kde.notificationmanager as NotificationManager
import "."

// RBR notification centre: history, actions, clear all and RBR Do Not Disturb.
Item {
    id: view

    required property var notifications     // NotificationManager.Notifications (history)
    required property var rbrFocus        // FocusMode
    property int total: 0                   // row count kept by main.qml (the model's count can lag)
    signal closeRequested()

    readonly property real u: Rbr.u

    implicitWidth: 52 * u
    implicitHeight: content.implicitHeight + 3 * u
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredHeight: implicitHeight
    Layout.maximumHeight: implicitHeight

    property date now: new Date()
    Timer { interval: 30000; running: true; repeat: true; triggeredOnStart: true; onTriggered: view.now = new Date() }

    readonly property string focusText: {
        if (!rbrFocus.active) return ""
        if (rbrFocus.indefinite) return "UNTIL TURNED OFF"
        const until = new Date(rbrFocus.until)
        return "UNTIL " + Qt.formatDateTime(until, until.toDateString() === now.toDateString() ? "HH:mm" : "ddd HH:mm").toUpperCase()
    }

    function clearAll() {
        for (let i = notifications.rowCount() - 1; i >= 0; i--)
            notifications.close(notifications.index(i, 0))
        notifications.clear(NotificationManager.Notifications.ClearExpired)
    }

    Column {
        id: content
        x: 1.5 * u
        y: 1.5 * u
        width: parent.width - 3 * u
        spacing: 1.2 * u

        Header {
            width: parent.width
            title: "COMMUNICATIONS"
            color: Rbr.peach
            status: view.rbrFocus.active ? "DO NOT DISTURB " + view.focusText
                    : (view.total === 0 ? "NO TRANSMISSIONS"
                       : view.total + " TRANSMISSION" + (view.total === 1 ? "" : "S"))
            statusColor: view.rbrFocus.active ? Rbr.red : Rbr.lilac
        }

        Flow {
            width: parent.width
            spacing: 0.6 * u

            LPill {
                text: view.rbrFocus.active ? "DO NOT DISTURB: ON" : "DO NOT DISTURB"
                accent: Rbr.red
                active: view.rbrFocus.active
                onClicked: view.rbrFocus.toggle()
            }
            LPill { visible: !view.rbrFocus.active; text: "1 HOUR"; accent: Rbr.red; onClicked: view.rbrFocus.set(60) }
            LPill { visible: !view.rbrFocus.active; text: "4 HOURS"; accent: Rbr.red; onClicked: view.rbrFocus.set(240) }
            LPill {
                text: "CLEAR ALL"
                accent: Rbr.orange
                enabled: view.total > 0
                onClicked: view.clearAll()
            }
            LPill {
                text: "SETTINGS"
                accent: Rbr.lilac
                onClicked: {
                    view.closeRequested()
                    Qt.openUrlExternally("systemsettings://kcm_notifications")
                }
            }
        }

        LText {
            visible: view.total === 0
            width: parent.width
            topPadding: 2 * u
            bottomPadding: 2 * u
            horizontalAlignment: Text.AlignHCenter
            text: "NO INCOMING TRANSMISSIONS"
            color: Rbr.dim(Rbr.tan, 0.6)
            font.pixelSize: 2.4 * u
        }

        ListView {
            id: list
            visible: count > 0
            width: parent.width
            height: Math.min(contentHeight, 60 * u)
            clip: true
            spacing: 0.8 * u
            boundsBehavior: Flickable.StopAtBounds
            model: view.notifications

            delegate: NotificationCard {
                notifications: view.notifications
                width: list.width
                height: implicitHeight
                now: view.now
                onActivated: view.closeRequested()
            }
        }
    }
}
