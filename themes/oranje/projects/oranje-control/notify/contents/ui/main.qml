import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.private.volume
import "."

// ORANJE Notification Center. Give it a hotkey in Configure → Keyboard Shortcuts.
//
// ORANJE popups ("takeover"): KDE's notification applet always draws its own popups,
// so while ORANJE popups are enabled we keep KDE's Do Not Disturb switched on (which
// hides KDE's popups) and draw our own. KDE's DND also mutes the notification sound
// stream, so we unmute it again and play each notification's sound ourselves.
// The separate ORANJE Do Not Disturb (FocusMode) silences everything.
PlasmoidItem {
    id: root

    readonly property var cfg: Plasmoid.configuration
    readonly property bool takeover: cfg.oranjePopups

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground | PlasmaCore.Types.ConfigurableBackground
    Plasmoid.icon: "preferences-desktop-notification-bell"
    switchWidth: Oranje.u * 45
    switchHeight: Oranje.u * 30

    FocusMode { id: focusMode }
    NotificationManager.Settings { id: dndSettings }

    NotificationManager.Notifications {
        id: history
        showExpired: true
        showDismissed: true
        showJobs: false
        groupMode: NotificationManager.Notifications.GroupDisabled
        sortMode: NotificationManager.Notifications.SortByDate
        urgencies: NotificationManager.Notifications.LowUrgency
                   | NotificationManager.Notifications.NormalUrgency
                   | NotificationManager.Notifications.CriticalUrgency
    }

    // What the ORANJE popups show: same rules as Plasma's popups, but they ignore KDE's
    // DND (that's the takeover) and show nothing at all in ORANJE focus mode.
    NotificationManager.Notifications {
        id: popupModel
        limit: 5
        showExpired: false
        showDismissed: false
        showJobs: false
        showAddedDuringInhibition: true
        blacklistedDesktopEntries: dndSettings.popupBlacklistedApplications
        blacklistedNotifyRcNames: dndSettings.popupBlacklistedServices
        groupMode: NotificationManager.Notifications.GroupDisabled
        sortMode: NotificationManager.Notifications.SortByDate
        sortOrder: Qt.DescendingOrder
        urgencies: (!root.takeover || focusMode.active) ? 0
                   : NotificationManager.Notifications.NormalUrgency
                     | NotificationManager.Notifications.CriticalUrgency
                     | (dndSettings.lowPriorityPopups ? NotificationManager.Notifications.LowUrgency : 0)
    }

    // Row counts we maintain ourselves: Notifications.count can lag one insert behind
    // (countChanged fires before the proxy chain has updated), which left the first
    // notification without a popup window until the next one arrived.
    property int popupRows: 0
    property int historyRows: 0
    function recount() {
        popupRows = popupModel.rowCount()
        historyRows = history.rowCount()
    }
    Connections {
        target: popupModel
        function onRowsInserted() { Qt.callLater(root.recount) }
        function onRowsRemoved() { Qt.callLater(root.recount) }
        function onModelReset() { Qt.callLater(root.recount) }
        function onLayoutChanged() { Qt.callLater(root.recount) }
    }
    Connections {
        target: history
        function onRowsInserted() { Qt.callLater(root.recount) }
        function onRowsRemoved() { Qt.callLater(root.recount) }
        function onModelReset() { Qt.callLater(root.recount) }
        function onLayoutChanged() { Qt.callLater(root.recount) }
    }

    // A fresh popup window for each batch of notifications: a layer-shell window that was
    // hidden once is not shown again inside plasmashell, so create/destroy instead of hide/show.
    Loader {
        active: root.popupRows > 0
        sourceComponent: PopupLayer {
            popups: popupModel
            notifySettings: dndSettings
            topMargin: root.cfg.popupTopMargin
            playSounds: !focusMode.active
        }
    }

    // ── Takeover of KDE's popups ─────────────────────────────────────
    function applyTakeover() {
        let changed = false
        if (takeover) {
            const until = dndSettings.notificationsInhibitedUntil
            if (isNaN(until) || until - Date.now() < 180 * 24 * 3600 * 1000) {
                const d = new Date()
                d.setFullYear(d.getFullYear() + 1)
                dndSettings.notificationsInhibitedUntil = d
                changed = true
            }
            if (dndSettings.criticalPopupsInDoNotDisturbMode) {
                dndSettings.criticalPopupsInDoNotDisturbMode = false
                changed = true
            }
            if (!cfg.takeoverApplied)
                cfg.takeoverApplied = true
        } else if (cfg.takeoverApplied) {
            // Give KDE its popups back.
            dndSettings.notificationsInhibitedUntil = new Date(NaN)
            dndSettings.criticalPopupsInDoNotDisturbMode = true
            cfg.takeoverApplied = false
            changed = true
        }
        if (changed)
            dndSettings.save()
        syncSounds()
    }
    onTakeoverChanged: applyTakeover()
    Component.onCompleted: {
        Qt.callLater(applyTakeover)
        Qt.callLater(recount)
    }
    // Renew the "one year" DND and re-check sounds now and then.
    Timer { interval: 6 * 3600 * 1000; running: true; repeat: true; onTriggered: root.applyTakeover() }

    // ── Notification sounds ──────────────────────────────────────────
    property QtObject eventStream: null
    Instantiator {
        model: StreamRestoreModel {}
        delegate: QtObject {
            readonly property string name: Name
            readonly property bool muted: Muted
            function setMuted(value) { Muted = value }
        }
        onObjectAdded: (index, object) => {
            if (object.name === "sink-input-by-media-role:event") {
                root.eventStream = object
                Qt.callLater(root.syncSounds)
            }
        }
    }
    Connections {
        target: root.eventStream
        function onMutedChanged() { Qt.callLater(root.syncSounds) }
    }
    Connections {
        target: focusMode
        function onActiveChanged() { root.syncSounds() }
    }

    function syncSounds() {
        if (!eventStream)
            return
        if (focusMode.active) {
            // ORANJE focus mode: silence notification sounds, remember that we did.
            if (!eventStream.muted) {
                eventStream.setMuted(true)
                cfg.focusMutedSounds = true
            }
            return
        }
        if (cfg.focusMutedSounds) {
            eventStream.setMuted(false)
            cfg.focusMutedSounds = false
        }
        // Plasma mutes the sound stream when its DND turns on and flags that it did.
        // During the takeover we undo only that mute, never one you set yourself.
        if (takeover && dndSettings.notificationSoundsInhibited && eventStream.muted) {
            eventStream.setMuted(false)
            dndSettings.notificationSoundsInhibited = false
            dndSettings.save()
        }
    }

    toolTipMainText: "ORANJE Notification Center"
    toolTipSubText: focusMode.active ? "Do Not Disturb is on" : root.historyRows === 0 ? "No notifications" : root.historyRows + " notification(s)"

    compactRepresentation: MouseArea {
        id: button

        readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        readonly property real thickness: vertical ? width : height
        readonly property real h: Math.max(14, Math.round(thickness * 0.66))

        implicitWidth: vertical ? thickness : pill.width + 2
        implicitHeight: vertical ? pill.height + 2 : thickness
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded

        // Flash briefly when a new notification arrives.
        property int lastCount: root.historyRows
        Connections {
            target: root
            function onHistoryRowsChanged() {
                if (root.historyRows > button.lastCount && !focusMode.active)
                    flash.restart()
                button.lastCount = root.historyRows
            }
        }
        SequentialAnimation {
            id: flash
            loops: 3
            ColorAnimation { target: pill; property: "color"; to: Oranje.gold; duration: 180 }
            ColorAnimation { target: pill; property: "color"; to: button.baseColor; duration: 180 }
        }

        readonly property color baseColor: focusMode.active ? Oranje.red : (root.expanded ? Oranje.gold : (containsMouse ? Qt.lighter(Oranje.peach, 1.12) : Oranje.peach))

        Rectangle {
            id: pill
            anchors.centerIn: parent
            width: button.vertical ? button.thickness * 0.9 : label.implicitWidth + badge.width + button.h * 1.4
            height: button.h
            radius: Oranje.round ? height / 2 : 0
            color: button.baseColor

            LText {
                id: label
                x: button.vertical ? (parent.width - width) / 2 : button.h * 0.55
                anchors.verticalCenter: parent.verticalCenter
                text: button.vertical ? (root.historyRows > 0 ? String(root.historyRows) : "ALR") : (focusMode.active ? "DND" : "ALERTS")
                color: Oranje.ink(button.baseColor)
                font.pixelSize: button.h * 0.7
            }
            Rectangle {
                id: badge
                visible: !button.vertical && root.historyRows > 0
                anchors { left: label.right; leftMargin: button.h * 0.3; verticalCenter: parent.verticalCenter }
                width: visible ? Math.max(button.h * 0.8, count.implicitWidth + button.h * 0.4) : 0
                height: button.h * 0.72
                radius: Oranje.round ? height / 2 : 0
                color: Oranje.ink(button.baseColor)
                LText {
                    id: count
                    anchors.centerIn: parent
                    text: root.historyRows > 99 ? "99+" : String(root.historyRows)
                    color: button.baseColor
                    font.pixelSize: button.h * 0.55
                }
            }
        }
    }

    fullRepresentation: NotifyView {
        notifications: history
        total: root.historyRows
        oranjeFocus: focusMode
        onCloseRequested: root.expanded = false
    }
}
