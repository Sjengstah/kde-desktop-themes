import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "."

PlasmoidItem {
    id: root

    readonly property bool inPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
        || Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property var cfg: Plasmoid.configuration

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: inPanel ? compactRepresentation : fullRepresentation

    toolTipMainText: "MAASTRICHT System Monitor"
    toolTipSubText: "CPU " + Maastricht.pct(sensors.cpu) + " · " + Math.round(sensors.cpuTempC) + "°C\n"
        + "GPU " + Maastricht.pct(sensors.gpu) + " · " + Math.round(sensors.gpuTempC) + "°C\n"
        + "RAM " + Maastricht.bytes(sensors.memUsedB) + " / " + Maastricht.bytes(sensors.memTotalB) + "\n"
        + "NET ▼ " + Maastricht.rate(sensors.down) + "  ▲ " + Maastricht.rate(sensors.up)

    Monitor {
        id: sensors
        interval: root.cfg.updateInterval
        disks: root.cfg.disks
        gpuId: root.cfg.gpu
        networkId: root.cfg.network
        cpuTempSensor: root.cfg.cpuTempSensor
    }

    compactRepresentation: CompactView {
        mon: sensors
        vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        keys: ["cpu", "gpu", "mem", "net", "disk"].filter(k => root.cfg["panel" + k.charAt(0).toUpperCase() + k.slice(1)])
        onActivated: root.expanded = !root.expanded
    }

    fullRepresentation: FullView {
        mon: sensors
        showCpu: root.cfg.showCpu
        showGpu: root.cfg.showGpu
        showMem: root.cfg.showMem
        showNet: root.cfg.showNet
        showDisk: root.cfg.showDisk
        backgroundOpacity: root.inPanel ? 1 : [1, 0.55, 0][root.cfg.background] ?? 1
        footerText: root.cfg.footerText
    }
}
