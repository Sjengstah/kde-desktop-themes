import QtQuick

// Maastricht readouts for the wallpaper: the weather from Open-Meteo's free API (no key),
// sunrise and sunset, and a countdown to carnival (vastelaovend) worked out locally.
// The bar next to the badge shows how much of today's daylight has passed.
QtObject {
    id: d

    property bool enabled: true
    property bool loaded: false
    property bool online: false
    property real progress: -1
    property string progressLabel: ""

    readonly property string url: "https://api.open-meteo.com/v1/forecast?latitude=50.85&longitude=5.69"
        + "&current=temperature_2m,weather_code,wind_speed_10m&daily=sunrise,sunset"
        + "&timezone=Europe%2FAmsterdam&forecast_days=1"

    property var current: null
    property date sunrise
    property date sunset
    property bool haveSun: false

    function refresh() {
        if (!enabled)
            return
        const x = new XMLHttpRequest()
        x.onreadystatechange = function() {
            if (x.readyState !== XMLHttpRequest.DONE)
                return
            let r = null
            if (x.status === 200) {
                try { r = JSON.parse(x.responseText) } catch (e) { r = null }
            }
            if (r && r.current) {
                current = r.current
                if (r.daily && r.daily.sunrise && r.daily.sunrise.length) {
                    sunrise = new Date(r.daily.sunrise[0])
                    sunset = new Date(r.daily.sunset[0])
                    haveSun = true
                }
                loaded = true
            }
            online = !!r
        }
        x.open("GET", url)
        x.send()
    }

    property Timer timer: Timer {
        interval: (d.online ? 30 : 5) * 60000
        running: d.enabled
        repeat: true
        triggeredOnStart: true
        onTriggered: d.refresh()
    }
    onEnabledChanged: if (enabled) refresh()

    // WMO weather codes, shortened.
    function sky(code) {
        if (code === 0) return "CLEAR"
        if (code <= 2) return "PARTLY CLOUDY"
        if (code === 3) return "OVERCAST"
        if (code <= 48) return "FOG"
        if (code <= 57) return "DRIZZLE"
        if (code <= 67) return "RAIN"
        if (code <= 77) return "SNOW"
        if (code <= 82) return "SHOWERS"
        if (code <= 86) return "SNOW SHOWERS"
        return "THUNDER"
    }

    // Easter Sunday (Gregorian, anonymous algorithm).
    function easter(y) {
        const a = y % 19, b = Math.floor(y / 100), c = y % 100
        const dd = Math.floor(b / 4), e = b % 4, f = Math.floor((b + 8) / 25)
        const g = Math.floor((b - f + 1) / 3), h = (19 * a + b - dd - g + 15) % 30
        const i = Math.floor(c / 4), k = c % 4, l = (32 + 2 * e + 2 * i - h - k) % 7
        const m = Math.floor((a + 11 * h + 22 * l) / 451)
        const month = Math.floor((h + l - 7 * m + 114) / 31), day = (h + l - 7 * m + 114) % 31 + 1
        return new Date(y, month - 1, day)
    }

    // Carnival runs Sunday to Tuesday before Ash Wednesday (Easter minus 49 days to minus 47).
    function carnival(now) {
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        for (let y = now.getFullYear(); y <= now.getFullYear() + 1; y++) {
            const e = easter(y)
            const start = new Date(e.getFullYear(), e.getMonth(), e.getDate() - 49)
            const end = new Date(e.getFullYear(), e.getMonth(), e.getDate() - 47)
            if (today <= end)
                return { start: start, on: today >= start }
        }
        return null
    }

    function sectors(now) {
        const s = []
        if (current)
            s.push({ title: "WEER · MAASTRICHT",
                     value: Math.round(current.temperature_2m) + "° · " + sky(current.weather_code) + " · " + Math.round(current.wind_speed_10m) + " KM/H" })
        else
            s.push({ title: "WEER", value: "WAITING FOR WEATHER" })
        if (haveSun)
            s.push({ title: now < sunset ? "ZON · SUNSET " + Qt.formatTime(sunset, "HH:mm") : "ZON · DOWN",
                     value: "↑ " + Qt.formatTime(sunrise, "HH:mm") + "   ↓ " + Qt.formatTime(sunset, "HH:mm") })
        else
            s.push({ title: "ZON", value: "--:--" })
        const c = carnival(now)
        if (c && c.on)
            s.push({ title: "VASTELAOVEND", value: "ALAAF! IT'S CARNIVAL", live: true })
        else if (c) {
            const days = Math.ceil((c.start - now) / 864e5)
            s.push({ title: "VASTELAOVEND · " + Qt.formatDate(c.start, "d MMM yyyy").toUpperCase(),
                     value: days + (days === 1 ? " DAY TO GO" : " DAYS TO GO") })
        }
        return s
    }

    // Daylight bar
    onLoadedChanged: updateProgress()
    property Timer daylight: Timer {
        interval: 60000; running: d.haveSun; repeat: true; triggeredOnStart: true
        onTriggered: d.updateProgress()
    }
    function updateProgress() {
        if (!haveSun) { progress = -1; return }
        const now = new Date()
        const p = (now - sunrise) / (sunset - sunrise)
        progress = Math.max(0, Math.min(1, p))
        progressLabel = p < 0 ? "BEFORE SUNRISE" : p > 1 ? "AFTER SUNSET" : "DAYLIGHT " + Math.round(p * 100) + "%"
    }
}
