import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_showCpu: showCpu.checked
    property alias cfg_showGpu: showGpu.checked
    property alias cfg_showMem: showMem.checked
    property alias cfg_showNet: showNet.checked
    property alias cfg_showDisk: showDisk.checked
    property alias cfg_panelCpu: panelCpu.checked
    property alias cfg_panelGpu: panelGpu.checked
    property alias cfg_panelMem: panelMem.checked
    property alias cfg_panelNet: panelNet.checked
    property alias cfg_panelDisk: panelDisk.checked
    property alias cfg_background: background.currentIndex
    property alias cfg_updateInterval: updateInterval.value
    property alias cfg_footerText: footerText.text
    property string cfg_gpu
    property string cfg_network
    property string cfg_cpuTempSensor
    property string cfg_disks

    property var cfg_showCpuDefault
    property var cfg_showGpuDefault
    property var cfg_showMemDefault
    property var cfg_showNetDefault
    property var cfg_showDiskDefault
    property var cfg_panelCpuDefault
    property var cfg_panelGpuDefault
    property var cfg_panelMemDefault
    property var cfg_panelNetDefault
    property var cfg_panelDiskDefault
    property var cfg_backgroundDefault
    property var cfg_updateIntervalDefault
    property var cfg_footerTextDefault
    property var cfg_gpuDefault
    property var cfg_networkDefault
    property var cfg_cpuTempSensorDefault
    property var cfg_disksDefault

    HardwareScanner { id: scanner }

    // Detected entries, plus the saved value if it isn't present on this machine.
    function withCurrent(list, current) {
        if (current && !list.some(e => e.id === current)) {
            return [{ id: current, label: current + " " + i18n("(not detected)") }].concat(list)
        }
        return list
    }

    // Disk rows: detected disks plus saved ones that are missing, in saved order first.
    property var diskRows: []
    property var diskState: ({})

    function buildDiskRows() {
        const saved = cfg_disks.split(",").map(s => s.trim()).filter(s => s.length > 0).map(s => {
            const [id, label] = s.split("=")
            return { id: id.trim(), label: (label || id).trim() }
        })
        const rows = []
        const state = {}
        for (const s of saved) {
            const found = scanner.disks.find(d => d.id === s.id)
            rows.push({ id: s.id, name: found ? found.label : i18n("not detected") })
            state[s.id] = { checked: true, label: s.label }
        }
        for (const d of scanner.disks) {
            if (!state[d.id]) {
                rows.push({ id: d.id, name: d.label })
                state[d.id] = { checked: false, label: d.label.toUpperCase() }
            }
        }
        diskState = state
        diskRows = rows
    }

    function saveDisks() {
        cfg_disks = diskRows.filter(r => diskState[r.id].checked)
            .map(r => r.id + "=" + (diskState[r.id].label || r.name).replace(/[,=]/g, " "))
            .join(",")
    }

    Connections {
        target: scanner
        function onDisksChanged() { page.buildDiskRows() }
    }

    Kirigami.FormLayout {
        // ── Hardware ──
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Hardware")
        }

        QQC2.ComboBox {
            id: gpuBox
            Kirigami.FormData.label: i18n("Graphics card:")
            Layout.fillWidth: true
            textRole: "label"
            valueRole: "id"
            model: page.withCurrent(scanner.gpus, page.cfg_gpu)
            onModelChanged: currentIndex = Math.max(0, indexOfValue(page.cfg_gpu))
            onActivated: page.cfg_gpu = currentValue
        }

        QQC2.ComboBox {
            id: tempBox
            Kirigami.FormData.label: i18n("CPU temperature sensor:")
            Layout.fillWidth: true
            textRole: "label"
            valueRole: "id"
            model: page.withCurrent(scanner.cpuTemps, page.cfg_cpuTempSensor)
            onModelChanged: currentIndex = Math.max(0, indexOfValue(page.cfg_cpuTempSensor))
            onActivated: page.cfg_cpuTempSensor = currentValue
        }

        QQC2.ComboBox {
            id: netBox
            Kirigami.FormData.label: i18n("Network interface:")
            Layout.fillWidth: true
            textRole: "label"
            valueRole: "id"
            model: page.withCurrent([{ id: "all", label: i18n("All interfaces combined") }].concat(scanner.interfaces), page.cfg_network)
            onModelChanged: currentIndex = Math.max(0, indexOfValue(page.cfg_network))
            onActivated: page.cfg_network = currentValue
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Disks:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            QQC2.Label {
                visible: page.diskRows.length === 0
                text: scanner.ready ? i18n("No disks detected; showing all disks combined.") : i18n("Detecting…")
                opacity: 0.7
            }

            Repeater {
                model: page.diskRows
                RowLayout {
                    required property var modelData
                    Layout.fillWidth: true

                    QQC2.CheckBox {
                        id: diskCheck
                        Layout.minimumWidth: Kirigami.Units.gridUnit * 8
                        checked: page.diskState[modelData.id].checked
                        text: modelData.name
                        onToggled: {
                            page.diskState[modelData.id].checked = checked
                            page.saveDisks()
                        }
                    }
                    QQC2.TextField {
                        Layout.fillWidth: true
                        enabled: diskCheck.checked
                        placeholderText: i18n("Label")
                        text: page.diskState[modelData.id].label
                        onTextEdited: {
                            page.diskState[modelData.id].label = text
                            page.saveDisks()
                        }
                    }
                }
            }

            QQC2.Label {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font: Kirigami.Theme.smallFont
                opacity: 0.7
                text: i18n("Checked disks appear in the Storage section, in this order. The first one is used for the panel readout. With none checked, all disks are combined.")
            }
        }

        // ── Full view ──
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Full view")
        }

        QQC2.CheckBox { id: showCpu; Kirigami.FormData.label: i18n("Sections:"); text: i18n("CPU") }
        QQC2.CheckBox { id: showGpu; text: i18n("GPU") }
        QQC2.CheckBox { id: showMem; text: i18n("Memory") }
        QQC2.CheckBox { id: showNet; text: i18n("Network") }
        QQC2.CheckBox { id: showDisk; text: i18n("Storage") }

        QQC2.ComboBox {
            id: background
            Kirigami.FormData.label: i18n("Background on desktop:")
            model: [i18n("Black"), i18n("Translucent"), i18n("Transparent")]
        }
        QQC2.TextField { id: footerText; Kirigami.FormData.label: i18n("Footer text:") }

        // ── Panel ──
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Panel")
        }

        QQC2.CheckBox { id: panelCpu; Kirigami.FormData.label: i18n("Show:"); text: i18n("CPU") }
        QQC2.CheckBox { id: panelGpu; text: i18n("GPU") }
        QQC2.CheckBox { id: panelMem; text: i18n("Memory") }
        QQC2.CheckBox { id: panelNet; text: i18n("Network download") }
        QQC2.CheckBox { id: panelDisk; text: i18n("First disk usage") }

        // ── General ──
        Item { Kirigami.FormData.isSection: true }

        QQC2.SpinBox {
            id: updateInterval
            Kirigami.FormData.label: i18n("Update every (ms):")
            from: 250
            to: 10000
            stepSize: 250
        }
    }
}
