pragma Singleton
import QtQuick
import org.kde.kirigami as Kirigami

// STARGATE palette, font and sizing shared by the control and notification centres.
QtObject {
    readonly property color orange: "#F2A33A"
    readonly property color gold: "#FFD27A"
    readonly property color tan: "#E6F1F7"
    readonly property color peach: "#FF8A5B"
    readonly property color violet: "#1B4D6B"
    readonly property color lilac: "#6EC6FF"
    readonly property color blue: "#2F7FA8"
    readonly property color sky: "#BFE8FF"
    readonly property color red: "#D7332B"
    readonly property color alert: "#FF3B30"
    readonly property color green: "#4FD18B"
    readonly property color bg: "#071018"
    readonly property color navy: "#071018"

    // Shape and type: rounded LCARS-style pills, or square/cut corners.
    readonly property bool round: false
    readonly property string corner: "square"
    readonly property bool italic: false

    // Base unit: half a KDE grid unit, so everything follows the system font size.
    readonly property real u: Kirigami.Units.gridUnit * 0.5

    readonly property FontLoader fontLoader: FontLoader { source: Qt.resolvedUrl("fonts/Rajdhani-SemiBold.ttf") }
    readonly property string font: fontLoader.status === FontLoader.Ready ? fontLoader.font.family : "Rajdhani"

    function dim(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a === undefined ? 0.18 : a)
    }

    // Text colour that reads on a filled block: dark on light accents, white on dark ones.
    function ink(c) {
        return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) > 0.52 ? navy : "#FFFFFF"
    }

    // Theme clock shown in the headers (ZULU).
    function clock(d) {
        const p = n => (n < 10 ? "0" : "") + n
        return p(d.getUTCHours()) + ":" + p(d.getUTCMinutes()) + "Z"
    }
}
