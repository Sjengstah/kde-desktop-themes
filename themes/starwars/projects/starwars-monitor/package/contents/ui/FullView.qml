import QtQuick
import QtQuick.Layouts
import org.kde.ksysguard.sensors as Sensors
import "."

// Full STARWARS panel: header elbow, one sidebar section per subsystem, footer elbow.
// Everything is sized in "u" so the whole panel scales with the widget.
Item {
    id: view

    property Monitor mon
    property bool showCpu: true
    property bool showGpu: true
    property bool showMem: true
    property bool showNet: true
    property bool showDisk: true
    property real backgroundOpacity: 1
    property real baseU: 8
    property string footerText: "MAY THE FORCE BE WITH YOU"

    readonly property int diskCount: Math.max(1, mon ? mon.diskList.length : 1)
    readonly property int sectionCount: showCpu + showGpu + showMem + showNet + showDisk
    readonly property real contentU: 7 + 5 + (showCpu ? 13 : 0) + (showGpu ? 12.5 : 0) + (showMem ? 9 : 0)
        + (showNet ? 10.5 : 0) + (showDisk ? 1.5 + 5.5 * diskCount : 0) + 0.5 * (sectionCount + 1)
    readonly property real totalU: contentU + 3
    readonly property real u: Math.max(3, Math.min(width / 64, height / totalU))
    readonly property real sw: 9 * u
    readonly property real gap: Math.max(2, Math.round(0.5 * u))

    implicitWidth: 64 * baseU
    implicitHeight: totalU * baseU
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.minimumWidth: 32 * baseU
    Layout.minimumHeight: totalU * baseU / 2

    property date now: new Date()
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: view.now = new Date()
    }

    readonly property var alertText: ["ALL SYSTEMS GO", "SHIELDS LOW", "HULL BREACH"]
    readonly property var alertColor: ["green", "gold", "red"].map(k => StarWars[k])

    Rectangle {
        anchors.fill: parent
        visible: view.backgroundOpacity > 0
        color: StarWars.dim(StarWars.bg, view.backgroundOpacity)
        radius: StarWars.round ? 2 * view.u : 0
    }

    Column {
        id: frame
        width: 61 * view.u
        anchors.centerIn: parent
        spacing: view.gap

        // ── Header ────────────────────────────────────────────────
        Item {
            width: frame.width
            height: 7 * view.u

            Elbow {
                id: topElbow
                width: view.sw + 6 * view.u
                height: parent.height
                color: StarWars.orange
                sidebarWidth: view.sw
                barHeight: 2.6 * view.u
                outerRadius: 4.5 * view.u
                innerRadius: 1.8 * view.u
            }

            RowLayout {
                x: topElbow.width + view.gap
                width: parent.width - x
                height: topElbow.barHeight
                spacing: view.gap

                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: StarWars.violet }
                LText {
                    text: "BRIDGE STATUS"
                    color: StarWars.orange
                    font.pixelSize: 3.7 * view.u
                    Layout.preferredHeight: parent.height
                    verticalAlignment: Text.AlignVCenter
                }
                Rectangle { Layout.preferredWidth: 4 * view.u; Layout.fillHeight: true; color: StarWars.peach }
                Rectangle { Layout.preferredWidth: 2.6 * view.u; Layout.fillHeight: true; color: StarWars.orange; radius: StarWars.round ? height / 2 : 0 }
            }

            LText {
                id: statusText
                x: view.sw + 2 * view.u
                anchors.bottom: parent.bottom
                text: view.alertText[view.mon ? view.mon.alertLevel : 0]
                color: view.alertColor[view.mon ? view.mon.alertLevel : 0]
                font.pixelSize: 2.4 * view.u

                SequentialAnimation on opacity {
                    running: view.mon && view.mon.alertLevel === 2
                    loops: Animation.Infinite
                    onRunningChanged: if (!running) statusText.opacity = 1
                    NumberAnimation { to: 0.2; duration: 450 }
                    NumberAnimation { to: 1; duration: 450 }
                }
            }
            LText {
                anchors { right: parent.right; bottom: parent.bottom }
                text: "ABY " + StarWars.clock(view.now)
                color: StarWars.tan
                font.pixelSize: 2.4 * view.u
            }
        }

        // ── CPU ───────────────────────────────────────────────────
        Section {
            visible: view.showCpu
            width: frame.width
            height: 13 * view.u
            u: view.u
            sidebarWidth: view.sw
            color: StarWars.orange
            label: "HYPERDRIVE"
            sublabel: "CPU"
            code: "01-" + (view.mon ? view.mon.threads : 0)

            Column {
                anchors.fill: parent
                spacing: 0.8 * view.u

                Row {
                    spacing: 3 * view.u
                    LText {
                        width: 9 * view.u
                        text: StarWars.pct(view.mon.cpu)
                        color: StarWars.orange
                        font.pixelSize: 4.8 * view.u
                    }
                    Stat { u: view.u; label: "FREQUENCY"; value: (view.mon.cpuMHz / 1000).toFixed(2) + " GHZ" }
                    Stat {
                        u: view.u; label: "TEMPERATURE"; value: Math.round(view.mon.cpuTempC) + "°C"
                        color: view.mon.cpuTempC >= 80 ? StarWars.alert : StarWars.gold
                    }
                    Stat { u: view.u; label: "THREADS"; value: view.mon.threads }
                }

                SegBar {
                    width: parent.width
                    height: 1.4 * view.u
                    value: view.mon.cpu / 100
                    color: StarWars.orange
                }

                // Per-thread load, one bar per logical CPU.
                Row {
                    id: coreRow
                    width: parent.width
                    height: 2.8 * view.u
                    spacing: Math.max(1, 0.3 * view.u)
                    Repeater {
                        model: view.mon ? view.mon.threads : 0
                        Rectangle {
                            id: coreBar
                            required property int index
                            width: (coreRow.width - coreRow.spacing * (view.mon.threads - 1)) / view.mon.threads
                            height: coreRow.height
                            color: StarWars.dim(StarWars.orange)
                            Sensors.Sensor {
                                id: coreSensor
                                sensorId: "cpu/cpu" + coreBar.index + "/usage"
                                updateRateLimit: view.mon.interval
                            }
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: Math.min(1, (Number(coreSensor.value) || 0) / 100) * parent.height
                                color: (Number(coreSensor.value) || 0) >= 90 ? StarWars.alert : StarWars.gold
                                Behavior on height { NumberAnimation { duration: 200 } }
                            }
                        }
                    }
                }
            }
        }

        // ── GPU ───────────────────────────────────────────────────
        Section {
            visible: view.showGpu
            width: frame.width
            height: 12.5 * view.u
            u: view.u
            sidebarWidth: view.sw
            color: StarWars.violet
            label: "TURBOLASERS"
            sublabel: "GPU"
            code: "02-" + Math.round(view.mon.vramTotal / 1073741824)

            Column {
                anchors.fill: parent
                spacing: 0.8 * view.u

                Row {
                    spacing: 3 * view.u
                    LText {
                        width: 9 * view.u
                        text: StarWars.pct(view.mon.gpu)
                        color: StarWars.violet
                        font.pixelSize: 4.8 * view.u
                    }
                    Stat { u: view.u; label: "CLOCK"; value: Math.round(view.mon.gpuMHz) + " MHZ" }
                    Stat { u: view.u; label: "EDGE"; value: Math.round(view.mon.gpuTempC) + "°C" }
                    Stat {
                        visible: view.mon.hasJunction
                        u: view.u; label: "JUNCTION"; value: Math.round(view.mon.gpuJunctionC) + "°C"
                        color: view.mon.gpuJunctionC >= 95 ? StarWars.alert : StarWars.gold
                    }
                    Stat { u: view.u; label: "POWER"; value: Math.round(view.mon.gpuWatts) + " W" }
                }

                SegBar {
                    width: parent.width
                    height: 1.4 * view.u
                    value: view.mon.gpu / 100
                    color: StarWars.violet
                }

                Row {
                    width: parent.width
                    spacing: 1.5 * view.u
                    LText {
                        id: vramLabel
                        text: "VRAM"
                        color: StarWars.lilac
                        font.pixelSize: 2 * view.u
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    SegBar {
                        width: parent.width - vramLabel.width - vramValue.width - 3 * view.u
                        height: 1.1 * view.u
                        anchors.verticalCenter: parent.verticalCenter
                        value: view.mon.vramTotal > 0 ? view.mon.vramUsed / view.mon.vramTotal : 0
                        color: StarWars.lilac
                        segments: 24
                    }
                    LText {
                        id: vramValue
                        text: StarWars.bytes(view.mon.vramUsed) + " / " + StarWars.bytes(view.mon.vramTotal)
                        color: StarWars.gold
                        font.pixelSize: 2 * view.u
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // ── Memory ────────────────────────────────────────────────
        Section {
            visible: view.showMem
            width: frame.width
            height: 9 * view.u
            u: view.u
            sidebarWidth: view.sw
            color: StarWars.lilac
            label: "DEFLECTORS"
            sublabel: "MEMORY"
            code: "03-" + Math.round(view.mon.memTotalB / 1073741824)

            Column {
                anchors.fill: parent
                spacing: 0.8 * view.u

                Row {
                    spacing: 3 * view.u
                    LText {
                        width: 9 * view.u
                        text: StarWars.pct(view.mon.mem)
                        color: StarWars.lilac
                        font.pixelSize: 4.8 * view.u
                    }
                    Stat { u: view.u; label: "IN USE"; value: StarWars.bytes(view.mon.memUsedB) }
                    Stat { u: view.u; label: "CAPACITY"; value: StarWars.bytes(view.mon.memTotalB) }
                    Stat { u: view.u; label: "SWAP"; value: StarWars.pct(view.mon.swap) }
                }

                SegBar {
                    width: parent.width
                    height: 1.4 * view.u
                    value: view.mon.mem / 100
                    color: StarWars.lilac
                }
            }
        }

        // ── Network ───────────────────────────────────────────────
        Section {
            visible: view.showNet
            width: frame.width
            height: 10.5 * view.u
            u: view.u
            sidebarWidth: view.sw
            color: StarWars.peach
            label: "HOLONET"
            sublabel: "NETWORK"
            code: "04-" + StarWars.shortRate(view.mon.netPeak)

            Row {
                anchors.fill: parent
                spacing: 3 * view.u

                Column {
                    id: netStats
                    width: 16 * view.u
                    spacing: 0.5 * view.u
                    Stat { u: view.u; label: "▼ DOWNLINK"; value: StarWars.rate(view.mon.down); color: StarWars.sky }
                    Stat { u: view.u; label: "▲ UPLINK"; value: StarWars.rate(view.mon.up); color: StarWars.peach }
                }

                Item {
                    width: parent.width - netStats.width - parent.spacing
                    height: parent.height

                    HistoryBars {
                        width: parent.width
                        height: parent.height / 2 - 1
                        values: view.mon.downHistory
                        peak: view.mon.netPeak
                        slots: view.mon.historyLength
                        color: StarWars.sky
                    }
                    Rectangle {
                        y: parent.height / 2 - 1
                        width: parent.width
                        height: 2
                        color: StarWars.dim(StarWars.tan)
                    }
                    HistoryBars {
                        y: parent.height / 2 + 1
                        width: parent.width
                        height: parent.height / 2 - 1
                        values: view.mon.upHistory
                        peak: view.mon.netPeak
                        slots: view.mon.historyLength
                        color: StarWars.peach
                        inverted: true
                    }
                }
            }
        }

        // ── Disks ─────────────────────────────────────────────────
        Section {
            visible: view.showDisk
            width: frame.width
            height: (1.5 + 5.5 * view.diskCount) * view.u
            u: view.u
            sidebarWidth: view.sw
            color: StarWars.blue
            label: "CARGO HOLD"
            sublabel: "STORAGE"
            code: "05-" + view.diskCount

            Column {
                anchors.fill: parent
                spacing: 1.5 * view.u

                Repeater {
                    model: view.mon ? view.mon.diskList : []

                    Column {
                        id: disk
                        required property var modelData
                        width: parent.width
                        spacing: 0.6 * view.u

                        Sensors.Sensor { id: dUsed; sensorId: "disk/" + disk.modelData.id + "/used"; updateRateLimit: view.mon.interval }
                        Sensors.Sensor { id: dTotal; sensorId: "disk/" + disk.modelData.id + "/total" }
                        Sensors.Sensor { id: dRead; sensorId: "disk/" + disk.modelData.id + "/read"; updateRateLimit: view.mon.interval }
                        Sensors.Sensor { id: dWrite; sensorId: "disk/" + disk.modelData.id + "/write"; updateRateLimit: view.mon.interval }
                        readonly property real used: Number(dUsed.value) || 0
                        readonly property real total: Number(dTotal.value) || 0
                        readonly property real frac: total > 0 ? used / total : 0

                        Item {
                            width: parent.width
                            height: diskName.height
                            LText {
                                id: diskName
                                text: disk.modelData.label
                                color: StarWars.sky
                                font.pixelSize: 2.4 * view.u
                            }
                            LText {
                                x: 16 * view.u
                                anchors.baseline: diskName.baseline
                                text: StarWars.pct(disk.frac * 100) + "   " + StarWars.bytes(disk.used) + " / " + StarWars.bytes(disk.total)
                                color: StarWars.gold
                                font.pixelSize: 2 * view.u
                            }
                            LText {
                                anchors { right: parent.right; baseline: diskName.baseline }
                                text: "R " + StarWars.rate(dRead.value) + "   W " + StarWars.rate(dWrite.value)
                                color: StarWars.tan
                                opacity: 0.8
                                font.pixelSize: 1.7 * view.u
                            }
                        }
                        SegBar {
                            width: parent.width
                            height: 1.2 * view.u
                            value: disk.frac
                            color: StarWars.blue
                        }
                    }
                }
            }
        }

        // ── Footer ────────────────────────────────────────────────
        Item {
            width: frame.width
            height: 5 * view.u

            Elbow {
                id: bottomElbow
                width: view.sw + 6 * view.u
                height: parent.height
                color: StarWars.tan
                sidebarWidth: view.sw
                barHeight: 1.8 * view.u
                outerRadius: 3.5 * view.u
                innerRadius: 1.4 * view.u
                flipped: true
            }

            RowLayout {
                x: bottomElbow.width + view.gap
                width: parent.width - x
                height: bottomElbow.barHeight
                anchors.bottom: parent.bottom
                spacing: view.gap

                Rectangle { Layout.preferredWidth: 8 * view.u; Layout.fillHeight: true; color: StarWars.red }
                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: StarWars.gold }
                LText {
                    text: view.footerText
                    color: StarWars.tan
                    font.pixelSize: 2.5 * view.u
                    Layout.preferredHeight: parent.height
                    verticalAlignment: Text.AlignVCenter
                }
                Rectangle { Layout.preferredWidth: 1.8 * view.u; Layout.fillHeight: true; color: StarWars.tan; radius: StarWars.round ? height / 2 : 0 }
            }
        }
    }
}
