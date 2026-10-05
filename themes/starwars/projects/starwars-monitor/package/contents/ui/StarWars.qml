pragma Singleton
import QtQuick

// STARWARS palette, font and value formatting shared by every view.
QtObject {
    readonly property color orange: "#FFE81F"
    readonly property color gold: "#FF9F1C"
    readonly property color tan: "#EAF2FF"
    readonly property color peach: "#FF6B4A"
    readonly property color violet: "#1F3A93"
    readonly property color lilac: "#4FC3F7"
    readonly property color blue: "#2E6DB4"
    readonly property color sky: "#CDEBFF"
    readonly property color red: "#E0242B"
    readonly property color alert: "#FF2D2D"
    readonly property color green: "#39FF6A"
    readonly property color bg: "#04060A"
    readonly property color navy: "#04060A"

    // Shape and type: rounded LCARS-style pills, or square/cut corners.
    readonly property bool round: false
    readonly property string corner: "cut"
    readonly property bool italic: false

    readonly property FontLoader fontLoader: FontLoader { source: Qt.resolvedUrl("../fonts/ShareTech-Regular.ttf") }
    readonly property string font: fontLoader.status === FontLoader.Ready ? fontLoader.font.family : "Share Tech"

    function dim(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a === undefined ? 0.18 : a)
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

    // Text colour that reads on a filled block: dark on light accents, white on dark ones.
    function ink(c) {
        return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) > 0.52 ? navy : "#FFFFFF"
    }

    // Theme clock shown in the headers (ABY).
    function clock(d) {
        const doy = Math.floor((d - new Date(d.getFullYear(), 0, 0)) / 864e5)
        return (d.getFullYear() - 1977) + "." + ("00" + doy).slice(-3)
    }
}
