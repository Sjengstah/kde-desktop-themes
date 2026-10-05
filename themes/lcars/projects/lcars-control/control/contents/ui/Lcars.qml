pragma Singleton
import QtQuick
import org.kde.kirigami as Kirigami

// LCARS palette, font and sizing shared by the control and notification centres.
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

    // Base unit: half a KDE grid unit, so everything follows the system font size.
    readonly property real u: Kirigami.Units.gridUnit * 0.5

    readonly property FontLoader antonio: FontLoader { source: Qt.resolvedUrl("fonts/Antonio.ttf") }
    readonly property string font: antonio.status === FontLoader.Ready ? antonio.font.family : "sans-serif"

    function dim(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a === undefined ? 0.18 : a)
    }

    function stardate(d) {
        const start = new Date(d.getFullYear(), 0, 1)
        const yearLen = new Date(d.getFullYear() + 1, 0, 1) - start
        return ((d.getFullYear() % 100) * 1000 + (d - start) / yearLen * 1000).toFixed(1)
    }
}
