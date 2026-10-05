import QtQuick
import QtQuick.Layouts
import "."

// Panel representation: a row (or column, on vertical panels) of ORANJE pills.
Item {
    id: c

    property Monitor mon
    property bool vertical: false
    property var keys: ["cpu", "gpu", "mem", "net"]
    signal activated()

    readonly property real thickness: vertical ? width : height

    readonly property var specs: ({
        cpu:  { label: "CPU", color: Oranje.orange, widest: "100%" },
        gpu:  { label: "GPU", color: Oranje.violet, widest: "100%" },
        mem:  { label: "MEM", color: Oranje.lilac, widest: "100%" },
        net:  { label: "NET", color: Oranje.peach, widest: "▼888.8M" },
        disk: { label: "DSK", color: Oranje.blue, widest: "100%" }
    })

    function valueOf(key) {
        switch (key) {
        case "cpu": return Oranje.pct(mon.cpu)
        case "gpu": return Oranje.pct(mon.gpu)
        case "mem": return Oranje.pct(mon.mem)
        case "net": return "▼" + Oranje.shortRate(mon.down)
        case "disk": return Oranje.pct(mon.diskPct)
        }
        return ""
    }

    function fractionOf(key) {
        switch (key) {
        case "cpu": return mon.cpu / 100
        case "gpu": return mon.gpu / 100
        case "mem": return mon.mem / 100
        case "net": return mon.down / mon.netPeak
        case "disk": return mon.diskPct / 100
        }
        return 0
    }

    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight
    Layout.minimumWidth: vertical ? -1 : grid.implicitWidth
    Layout.preferredWidth: vertical ? -1 : grid.implicitWidth
    Layout.minimumHeight: vertical ? grid.implicitHeight : -1
    Layout.preferredHeight: vertical ? grid.implicitHeight : -1

    Grid {
        id: grid
        anchors.centerIn: parent
        columns: c.vertical ? 1 : Math.max(1, c.keys.length)
        spacing: Math.round(c.thickness * (c.vertical ? 0.15 : 0.25))

        Repeater {
            model: c.keys
            Pill {
                required property string modelData
                vertical: c.vertical
                thickness: c.thickness
                label: c.specs[modelData].label
                color: c.specs[modelData].color
                widest: c.specs[modelData].widest
                value: c.valueOf(modelData)
                fraction: c.fractionOf(modelData)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: c.activated()
    }
}
