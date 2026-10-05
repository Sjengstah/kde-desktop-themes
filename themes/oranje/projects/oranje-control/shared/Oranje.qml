pragma Singleton
import QtQuick
import org.kde.kirigami as Kirigami

// ORANJE palette, font and sizing shared by the control and notification centres.
QtObject {
    readonly property color orange: "#FF6A13"
    readonly property color gold: "#FFB21A"
    readonly property color tan: "#FFF3E8"
    readonly property color peach: "#FFB27A"
    readonly property color violet: "#21468B"
    readonly property color lilac: "#7F9CE0"
    readonly property color blue: "#3E5C9A"
    readonly property color sky: "#CFE0FF"
    readonly property color red: "#AE1C28"
    readonly property color alert: "#FF3B30"
    readonly property color green: "#3DDC84"
    readonly property color bg: "#0A1020"
    readonly property color navy: "#0A1020"

    // Shape and type: rounded LCARS-style pills, or square/cut corners.
    readonly property bool round: false
    readonly property string corner: "square"
    readonly property bool italic: false

    // Base unit: half a KDE grid unit, so everything follows the system font size.
    readonly property real u: Kirigami.Units.gridUnit * 0.5

    readonly property FontLoader fontLoader: FontLoader { source: Qt.resolvedUrl("fonts/Oswald-Variable.ttf") }
    readonly property string font: fontLoader.status === FontLoader.Ready ? fontLoader.font.family : "Oswald"

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
