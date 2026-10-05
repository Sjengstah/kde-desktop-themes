import QtQuick
import QtQuick.Layouts
import org.kde.notificationmanager as NotificationManager
import "."

// ORANJE notification centre: history, actions, clear all and ORANJE Do Not Disturb.
Item {
    id: view

    required property var notifications     // NotificationManager.Notifications (history)
    required property var oranjeFocus        // FocusMode
    property int total: 0                   // row count kept by main.qml (the model's count can lag)
    signal closeRequested()

    readonly property real u: Oranje.u

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
        if (!oranjeFocus.active) return ""
        if (oranjeFocus.indefinite) return "UNTIL TURNED OFF"
        const until = new Date(oranjeFocus.until)
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
            color: Oranje.peach
            status: view.oranjeFocus.active ? "DO NOT DISTURB " + view.focusText
                    : (view.total === 0 ? "NO TRANSMISSIONS"
                       : view.total + " TRANSMISSION" + (view.total === 1 ? "" : "S"))
            statusColor: view.oranjeFocus.active ? Oranje.red : Oranje.lilac
        }

        Flow {
            width: parent.width
            spacing: 0.6 * u

            LPill {
                text: view.oranjeFocus.active ? "DO NOT DISTURB: ON" : "DO NOT DISTURB"
                accent: Oranje.red
                active: view.oranjeFocus.active
                onClicked: view.oranjeFocus.toggle()
            }
            LPill { visible: !view.oranjeFocus.active; text: "1 HOUR"; accent: Oranje.red; onClicked: view.oranjeFocus.set(60) }
            LPill { visible: !view.oranjeFocus.active; text: "4 HOURS"; accent: Oranje.red; onClicked: view.oranjeFocus.set(240) }
            LPill {
                text: "CLEAR ALL"
                accent: Oranje.orange
                enabled: view.total > 0
                onClicked: view.clearAll()
            }
            LPill {
                text: "SETTINGS"
                accent: Oranje.lilac
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
            color: Oranje.dim(Oranje.tan, 0.6)
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
