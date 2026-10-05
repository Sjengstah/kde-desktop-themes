pragma Singleton
import QtQuick

// RBR (F1 livery) palette, font and value formatting shared by every view.
QtObject {
    readonly property color orange: "#DB0A40"
    readonly property color gold: "#FFC906"
    readonly property color tan: "#E8EDF7"
    readonly property color peach: "#A9B4CC"
    readonly property color violet: "#3671C6"
    readonly property color lilac: "#8FAEF5"
    readonly property color blue: "#6C7FA8"
    readonly property color sky: "#C6D6F7"
    readonly property color red: "#FF5A5F"
    readonly property color alert: "#FF7A00"
    readonly property color green: "#5FD08A"
    readonly property color bg: "#050A1E"
    readonly property color navy: "#050A1E"

    readonly property FontLoader barlow: FontLoader { source: Qt.resolvedUrl("../fonts/BarlowCondensed-SemiBoldItalic.ttf") }
    readonly property string font: barlow.status === FontLoader.Ready ? barlow.font.family : "Barlow Condensed"

    function dim(c) {
        return Qt.rgba(c.r, c.g, c.b, 0.18)
    }

    function pct(v) {
        return isFinite(v) ? Math.round(v) + "%" : "--"
    }

    function bytes(v) {
        const units = ["B", "KB", "MB", "GB", "TB"]
        let i = 0
        v = Number(v) || 0
        while (v >= 1024 && i < units.length - 1) {
            v /= 1024
            i++
        }
        return (v < 10 && i > 0 ? v.toFixed(1) : Math.round(v)) + " " + units[i]
    }

    function rate(v) {
        return bytes(v) + "/S"
    }

    // Compact rate for panel pills: "340K", "1.2M"
    function shortRate(v) {
        const units = ["B", "K", "M", "G"]
        let i = 0
        v = Number(v) || 0
        while (v >= 1024 && i < units.length - 1) {
            v /= 1024
            i++
        }
        return (v < 10 && i > 0 ? v.toFixed(1) : Math.round(v)) + units[i]
    }

    // Text colour that reads on a filled block: navy on light accents, white on dark ones.
    function ink(c) {
        return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) > 0.52 ? navy : "#FFFFFF"
    }

    // The year is the race, each day a lap: "277/365".
    function lap(d) {
        const start = new Date(d.getFullYear(), 0, 1)
        const laps = Math.round((new Date(d.getFullYear() + 1, 0, 1) - start) / 864e5)
        return (Math.floor((d - start) / 864e5) + 1) + "/" + laps
    }
}
