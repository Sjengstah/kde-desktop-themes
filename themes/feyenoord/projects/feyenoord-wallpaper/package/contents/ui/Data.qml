import QtQuick

// Football readouts for the wallpaper, from TheSportsDB's free API (public test key).
// Next match with a countdown (LIVE during the match), last result, and the league
// table (free tier: top 5) or, without a league, a countdown to the next tournament.
QtObject {
    id: d

    property bool enabled: true
    property bool loaded: false
    property bool online: false
    property real progress: -1
    property string progressLabel: ""

    readonly property string teamId: "133758"
    readonly property string teamName: "Feyenoord"
    readonly property string leagueId: "4337"
    readonly property string leagueName: "EREDIVISIE"
    readonly property int leagueRounds: 34
    readonly property string tournament: ""
    readonly property string tournamentDate: ""
    readonly property string base: "https://www.thesportsdb.com/api/v1/json/123/"

    property var next: null
    property var last: null
    property var table: []

    function get(path, done) {
        const x = new XMLHttpRequest()
        x.onreadystatechange = function() {
            if (x.readyState !== XMLHttpRequest.DONE)
                return
            let data = null
            if (x.status === 200) {
                try { data = JSON.parse(x.responseText) } catch (e) { data = null }
            }
            done(data)
        }
        x.open("GET", base + path)
        x.send()
    }

    // Football seasons run August to July: "2026-2027".
    function season(now) {
        const y = now.getFullYear() - (now.getMonth() < 7 ? 1 : 0)
        return y + "-" + (y + 1)
    }

    function refresh() {
        if (!enabled)
            return
        let pending = leagueId ? 3 : 2, ok = true
        function finish(good) {
            ok = ok && good
            if (--pending === 0) {
                online = ok
                loaded = loaded || ok
            }
        }
        get("eventsnext.php?id=" + teamId, function(r) {
            if (r) next = (r.events && r.events.length) ? r.events[0] : null
            finish(!!r)
        })
        get("eventslast.php?id=" + teamId, function(r) {
            if (r && r.results && r.results.length) last = r.results[0]
            finish(!!r)
        })
        if (leagueId) {
            get("lookuptable.php?l=" + leagueId + "&s=" + season(new Date()), function(r) {
                if (r && r.table) {
                    table = r.table
                    const played = Math.max.apply(null, table.map(t => parseInt(t.intPlayed) || 0))
                    progress = played / leagueRounds
                    progressLabel = "MATCHDAY " + played + " / " + leagueRounds
                }
                finish(!!r)
            })
        }
    }

    property Timer timer: Timer {
        interval: (d.online ? 30 : 5) * 60000
        running: d.enabled
        repeat: true
        triggeredOnStart: true
        onTriggered: d.refresh()
    }
    onEnabledChanged: if (enabled) refresh()

    function kickoff(e) {
        return e && e.strTimestamp ? new Date(e.strTimestamp + "Z") : null
    }

    function countdown(to, now) {
        let m = Math.max(0, Math.floor((to - now) / 60000))
        const days = Math.floor(m / 1440), h = Math.floor(m % 1440 / 60)
        m = m % 60
        const p = n => (n < 10 ? "0" : "") + n
        if (days > 0) return days + "D " + p(h) + "H"
        if (h > 0) return h + "H " + p(m) + "M"
        return m + "M"
    }

    function opponent(e) {
        const home = e.idHomeTeam === teamId
        return (home ? e.strAwayTeam : e.strHomeTeam).toUpperCase() + (home ? " (H)" : " (A)")
    }

    function sectors(now) {
        if (!loaded)
            return [{ title: "NO SIGNAL", value: "WAITING FOR MATCH DATA" }, { title: "", value: "" }, { title: "", value: "" }]
        const s = []
        const k = kickoff(next)
        if (next && k) {
            const live = k <= now && now - k < 115 * 60000
            s.push({ title: "NEXT · VS " + opponent(next),
                     value: live ? "LIVE NOW" : Qt.formatDateTime(k, "ddd HH:mm").toUpperCase() + " · IN " + countdown(k, now),
                     live: live })
        } else {
            s.push({ title: "NEXT MATCH", value: "NOT SCHEDULED YET" })
        }
        if (last)
            s.push({ title: "LAST · " + (last.strLeague || "").toUpperCase(),
                     value: last.strHomeTeam.toUpperCase() + " " + last.intHomeScore + "–" + last.intAwayScore + " " + last.strAwayTeam.toUpperCase() })
        else
            s.push({ title: "LAST MATCH", value: "NONE YET" })
        if (leagueId) {
            const mine = table.find(t => t.idTeam === teamId)
            if (mine)
                s.push({ title: leagueName + " · TABLE",
                         value: "P" + mine.intRank + " · " + mine.intPoints + " PTS · GD " + (parseInt(mine.intGoalDifference) > 0 ? "+" : "") + mine.intGoalDifference })
            else if (table.length)
                s.push({ title: leagueName + " · LEADER", value: table[0].strTeam.toUpperCase() + " · " + table[0].intPoints + " PTS" })
            else
                s.push({ title: leagueName, value: "TABLE NOT AVAILABLE" })
        } else if (tournament) {
            const t = new Date(tournamentDate + "T00:00:00")
            const days = Math.ceil((t - now) / 864e5)
            s.push({ title: tournament, value: days > 0 ? "KICK-OFF IN " + days + " DAYS" : "TOURNAMENT TIME" })
        }
        return s
    }
}
