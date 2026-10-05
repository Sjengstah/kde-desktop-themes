import QtQuick
import QtCore

// STARWARS Do Not Disturb ("focus mode"): no STARWARS popups and no notification sounds.
// Stored in ~/.config/starwars-desktop.conf so the control and notification centres share it.
Item {
    id: focus

    property real until: 0                      // epoch ms; 0 = off
    property real now: Date.now()
    readonly property bool active: until > now
    readonly property bool indefinite: until > now + 365 * 24 * 3600 * 1000

    Settings {
        id: store
        location: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/starwars-desktop.conf"
        category: "Focus"
    }

    function reload() {
        store.sync()
        const v = Number(store.value("dndUntil", 0))
        if (v !== until)
            until = isNaN(v) ? 0 : v
        now = Date.now()
    }

    // minutes: 0 = off, -1 = until turned off, otherwise a duration
    function set(minutes) {
        const v = minutes === 0 ? 0 : minutes < 0 ? 8640000000000 : Date.now() + minutes * 60 * 1000
        store.setValue("dndUntil", v)
        store.sync()
        reload()
    }

    function toggle() {
        set(active ? 0 : -1)
    }

    Timer { interval: 1000; running: true; repeat: true; onTriggered: focus.reload() }
    Component.onCompleted: reload()
}
