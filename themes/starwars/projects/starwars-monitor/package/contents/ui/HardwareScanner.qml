import QtQuick
import org.kde.ksysguard.sensors as Sensors
import org.kde.kitemmodels as KItemModels

// Walks the ksystemstats sensor tree and lists the hardware this machine has,
// so the settings page can offer real choices instead of hardcoded IDs.
Item {
    id: scan

    property var gpus: []       // [{ id: "gpu0", label }]
    property var disks: []      // [{ id: "<uuid or device>", label }]
    property var interfaces: [] // [{ id: "enp8s0", label }]
    property var cpuTemps: []   // [{ id: "<full sensor id>", label }]
    property bool ready: false

    Sensors.SensorTreeModel { id: tree }

    KItemModels.KDescendantsProxyModel {
        id: flat
        model: tree
    }

    Timer {
        id: debounce
        interval: 300
        onTriggered: scan.rescan()
    }

    Connections {
        target: flat
        function onRowsInserted() { debounce.restart() }
        function onModelReset() { debounce.restart() }
    }

    Component.onCompleted: debounce.restart()

    function rescan() {
        const g = [], d = [], n = [], t = []
        let parentLabel = ""
        for (let row = 0; row < flat.rowCount(); row++) {
            const index = flat.index(row, 0)
            const id = flat.data(index, Sensors.SensorTreeModel.SensorId) || ""
            const label = flat.data(index) || ""
            // Rows without an ID are the device/object nodes; their sensors follow them.
            if (!id) {
                parentLabel = label
                continue
            }
            // Skip group placeholders such as "disk/(?!all).*".
            if (/[()\[\]*]/.test(id))
                continue
            let m
            if ((m = id.match(/^gpu\/(gpu\d+)\/usage$/))) {
                g.push({ id: m[1], label: parentLabel })
            } else if ((m = id.match(/^disk\/([^/]+)\/usedPercent$/)) && m[1] !== "all") {
                d.push({ id: m[1], label: parentLabel })
            } else if ((m = id.match(/^network\/([^/]+)\/download$/)) && m[1] !== "all") {
                n.push({ id: m[1], label: parentLabel + " (" + m[1] + ")" })
            } else if (/^cpu\/all\/(maximum|average)Temperature$/.test(id)) {
                t.push({ id: id, label: "CPU · " + label.replace(/ \(°C\)$/, "") })
            } else if ((m = id.match(/^lmsensors\/([^/]+)\/temp\d+$/))) {
                t.push({ id: id, label: m[1] + " · " + label.replace(/ \(°C\)$/, "") })
            }
        }
        gpus = g
        disks = d
        interfaces = n
        cpuTemps = t
        ready = flat.rowCount() > 0
    }
}
