pragma Singleton
import QtQuick
import org.kde.kirigami as Kirigami

// MAASTRICHT palette, font and sizing shared by the control and notification centres.
QtObject {
    readonly property color orange: "#D9A75F"
    readonly property color gold: "#F0D28C"
    readonly property color tan: "#F6EEDF"
    readonly property color peach: "#E39A78"
    readonly property color violet: "#1F4E79"
    readonly property color lilac: "#8FB8DE"
    readonly property color blue: "#3F6E96"
    readonly property color sky: "#D6E6F4"
    readonly property color red: "#C0392B"
    readonly property color alert: "#FF4D3D"
    readonly property color green: "#6CC08B"
    readonly property color bg: "#0E1418"
    readonly property color navy: "#0E1418"

    // Shape and type: rounded LCARS-style pills, or square/cut corners.
    readonly property bool round: true
    readonly property string corner: "round"
    readonly property bool italic: false

    // Base unit: half a KDE grid unit, so everything follows the system font size.
    readonly property real u: Kirigami.Units.gridUnit * 0.5

    readonly property FontLoader fontLoader: FontLoader { source: Qt.resolvedUrl("fonts/FjallaOne-Regular.ttf") }
    readonly property string font: fontLoader.status === FontLoader.Ready ? fontLoader.font.family : "Fjalla One"

    function dim(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a === undefined ? 0.18 : a)
    }

    // Text colour that reads on a filled block: dark on light accents, white on dark ones.
    function ink(c) {
        return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) > 0.52 ? navy : "#FFFFFF"
    }

    // Theme clock shown in the headers (STADSKLOK).
    function clock(d) {
        return Qt.formatTime(d, "HH:mm")
    }
}
