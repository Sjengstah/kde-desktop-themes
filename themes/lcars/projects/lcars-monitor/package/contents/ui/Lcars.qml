pragma Singleton
import QtQuick

// LCARS palette, font and value formatting shared by every view.
QtObject {
    readonly property color orange: "#FF9900"
    readonly property color gold: "#FFCC66"
    readonly property color tan: "#FFCC99"
    readonly property color peach: "#FF9966"
    readonly property color violet: "#CC99CC"
    readonly property color lilac: "#9999FF"
    readonly property color blue: "#6699CC"
    readonly property color sky: "#99CCFF"
    readonly property color red: "#CC6666"
    readonly property color alert: "#FF3333"
    readonly property color bg: "#000000"

    readonly property FontLoader antonio: FontLoader { source: Qt.resolvedUrl("../fonts/Antonio.ttf") }
    readonly property string font: antonio.status === FontLoader.Ready ? antonio.font.family : "Fira Sans Condensed"

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

    function stardate(d) {
        const start = new Date(d.getFullYear(), 0, 1)
        const yearLen = new Date(d.getFullYear() + 1, 0, 1) - start
        return ((d.getFullYear() % 100) * 1000 + (d - start) / yearLen * 1000).toFixed(1)
    }
}
