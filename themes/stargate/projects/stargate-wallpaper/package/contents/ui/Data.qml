import QtQuick

// Gate-room readouts for the wallpaper, all worked out locally from the date (nothing is
// fetched): the gate address of the day, the iris status and the SG teams offworld.
// The bar next to the badge is the wormhole timer: a gate stays open for 38 minutes.
QtObject {
    id: d

    property bool enabled: true
    property bool loaded: true
    property real progress: -1
    property string progressLabel: ""

    // Small seeded generator so a day always gives the same address and teams.
    function rng(seed) {
        let s = seed >>> 0
        return function() {
            s = (s * 1664525 + 1013904223) >>> 0
            return s / 4294967296
        }
    }

    function daySeed(now) {
        return now.getFullYear() * 1000 + Math.floor((now - new Date(now.getFullYear(), 0, 0)) / 864e5)
    }

    // Seven different symbols out of 39, the seventh one is the point of origin (1).
    function address(now) {
        const r = rng(daySeed(now)), used = [1], out = []
        while (out.length < 6) {
            const n = 2 + Math.floor(r() * 38)
            if (used.indexOf(n) < 0) { used.push(n); out.push(n) }
        }
        out.push(1)
        return out.map(n => (n < 10 ? "0" : "") + n).join("-")
    }

    function sectors(now) {
        const r = rng(daySeed(now) * 31 + 7)
        const teams = 2 + Math.floor(r() * 9)
        // The iris closes for an incoming wormhole a few times a day, for ten minutes each.
        const minute = now.getHours() * 60 + now.getMinutes()
        const closed = [0, 1, 2, 3].some(i => {
            const at = Math.floor(r() * 1430)
            return minute >= at && minute < at + 10
        })
        return [
            { title: "GATE ADDRESS OF THE DAY", value: address(now) },
            closed ? { title: "IRIS · INCOMING WORMHOLE", value: "IRIS CLOSED", live: true }
                   : { title: "IRIS", value: "OPEN · GATE IDLE" },
            { title: "SG TEAMS OFFWORLD", value: teams + " OF 25 TEAMS" }
        ]
    }

    property Timer timer: Timer {
        interval: 30000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            const n = new Date()
            const m = (n.getHours() * 60 + n.getMinutes()) % 38
            d.progress = m / 38
            d.progressLabel = "WORMHOLE " + (38 - m) + " MIN"
        }
    }
}
