pragma Singleton
import QtQuick
import org.kde.kirigami as Kirigami

// RBR (F1 livery) palette, font and sizing shared by the control and notification centres.
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
    readonly property color navy: "#050A1E"

    // Base unit: half a KDE grid unit, so everything follows the system font size.
    readonly property real u: Kirigami.Units.gridUnit * 0.5

    readonly property FontLoader barlow: FontLoader { source: Qt.resolvedUrl("fonts/BarlowCondensed-SemiBoldItalic.ttf") }
    readonly property string font: barlow.status === FontLoader.Ready ? barlow.font.family : "sans-serif"

    function dim(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a === undefined ? 0.18 : a)
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
