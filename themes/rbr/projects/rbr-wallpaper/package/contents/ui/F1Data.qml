import QtQuick

// F1 season data from the Jolpica API (the Ergast successor, free, no key).
// Fetches the schedule, last result and driver standings every 30 minutes,
// retries every 5 minutes when offline, and keeps the last good data meanwhile.
QtObject {
    id: f1

    property bool enabled: true
    property var races: []       // current season schedule
    property var last: null      // last race, with Results
    property var standings: []   // DriverStandings
    property int round: 0        // rounds completed
    property bool online: false
    property bool loaded: false

    readonly property string base: "https://api.jolpi.ca/ergast/f1/"

    // Expected session lengths in minutes, for the LIVE state.
    readonly property var sessions: [
        { key: "FirstPractice", name: "FP1", mins: 60 },
        { key: "SecondPractice", name: "FP2", mins: 60 },
        { key: "SprintQualifying", name: "SPRINT QUALI", mins: 45 },
        { key: "ThirdPractice", name: "FP3", mins: 60 },
        { key: "Sprint", name: "SPRINT", mins: 60 },
        { key: "Qualifying", name: "QUALI", mins: 60 }
    ]

    function get(path, done) {
        const x = new XMLHttpRequest()
        x.onreadystatechange = function() {
            if (x.readyState !== XMLHttpRequest.DONE)
                return
            let data = null
            if (x.status === 200) {
                try { data = JSON.parse(x.responseText).MRData } catch (e) { data = null }
            }
            done(data)
        }
        x.open("GET", base + path)
        x.send()
    }

    function refresh() {
        if (!enabled)
            return
        let ok = true
        let pending = 3
        function finish(good) {
            ok = ok && good
            if (--pending === 0) {
                online = ok
                loaded = loaded || ok
            }
        }
        get("current.json?limit=100", function(d) {
            if (d && d.RaceTable) races = d.RaceTable.Races
            finish(!!d)
        })
        get("current/last/results.json", function(d) {
            if (d && d.RaceTable && d.RaceTable.Races.length) {
                last = d.RaceTable.Races[0]
                round = parseInt(last.round)
            }
            finish(!!d)
        })
        get("current/driverStandings.json", function(d) {
            if (d && d.StandingsTable && d.StandingsTable.StandingsLists.length)
                standings = d.StandingsTable.StandingsLists[0].DriverStandings
            finish(!!d)
        })
    }

    property Timer timer: Timer {
        interval: (f1.online ? 30 : 5) * 60000
        running: f1.enabled
        repeat: true
        triggeredOnStart: true
        onTriggered: f1.refresh()
    }
    onEnabledChanged: if (enabled) refresh()

    // ── Helpers for the view ─────────────────────────────────────

    function when(s) {
        return s && s.date ? new Date(s.date + "T" + (s.time || "00:00:00Z")) : null
    }

    function shortName(race) {
        return race ? race.raceName.replace("Grand Prix", "GP").toUpperCase() : ""
    }

    function code(driver) {
        return (driver.code || driver.familyName || "").toUpperCase()
    }

    // The race weekend that is on now or next: its race hasn't finished yet.
    function nextRace(now) {
        for (let i = 0; i < races.length; i++) {
            const t = when(races[i])
            if (t && t.getTime() + 2 * 3600e3 > now.getTime())
                return races[i]
        }
        return null
    }

    // Next or running session of a race weekend: {name, start, live}.
    function nextSession(race, now) {
        if (!race)
            return null
        const list = []
        for (const s of sessions) {
            const t = when(race[s.key])
            if (t) list.push({ name: s.name, start: t, mins: s.mins })
        }
        list.push({ name: "RACE", start: when(race), mins: 120 })
        list.sort((a, b) => a.start - b.start)
        for (const s of list) {
            const end = s.start.getTime() + s.mins * 60000
            if (end > now.getTime())
                return { name: s.name, start: s.start, live: s.start <= now }
        }
        return null
    }

    function countdown(to, now) {
        let m = Math.max(0, Math.floor((to - now) / 60000))
        const d = Math.floor(m / 1440), h = Math.floor(m % 1440 / 60)
        m = m % 60
        const p = n => (n < 10 ? "0" : "") + n
        if (d > 0) return d + "D " + p(h) + "H"
        if (h > 0) return h + "H " + p(m) + "M"
        return m + "M"
    }
}
