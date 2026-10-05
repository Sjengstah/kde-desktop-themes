pragma Singleton
import QtQuick
import org.kde.kirigami as Kirigami

// FEYENOORD palette, font and sizing shared by the control and notification centres.
QtObject {
    readonly property color orange: "#E30613"
    readonly property color gold: "#F2C230"
    readonly property color tan: "#F5F5F7"
    readonly property color peach: "#FF7A7A"
    readonly property color violet: "#5A5A68"
    readonly property color lilac: "#C9CDD6"
    readonly property color blue: "#8E929E"
    readonly property color sky: "#E6E8EE"
    readonly property color red: "#9C0010"
    readonly property color alert: "#FF3B30"
    readonly property color green: "#3DDC84"
    readonly property color bg: "#0B0B0E"
    readonly property color navy: "#0B0B0E"

    // Shape and type: rounded LCARS-style pills, or square/cut corners.
    readonly property bool round: false
    readonly property string corner: "cut"
    readonly property bool italic: false

    // Base unit: half a KDE grid unit, so everything follows the system font size.
    readonly property real u: Kirigami.Units.gridUnit * 0.5

    readonly property FontLoader fontLoader: FontLoader { source: Qt.resolvedUrl("fonts/Teko-Variable.ttf") }
    readonly property string font: fontLoader.status === FontLoader.Ready ? fontLoader.font.family : "Teko"

    function dim(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a === undefined ? 0.18 : a)
    }

    // Text colour that reads on a filled block: dark on light accents, white on dark ones.
    function ink(c) {
        return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) > 0.52 ? navy : "#FFFFFF"
    }

    // Theme clock shown in the headers (MINUTE).
    function clock(d) {
        const m = d.getHours() * 60 + d.getMinutes()
        return Math.floor(m * 90 / 1440) + "'"
    }
}
