import QtQuick
import org.kde.ksysguard.sensors as Sensors

// All sensor readings in one place, shared by the panel and full views.
Item {
    id: m

    property int interval: 1000
    property string disks: ""
    property string gpuId: "gpu0"
    property string networkId: "all"
    property string cpuTempSensor: "cpu/all/maximumTemperature"
    property int historyLength: 40

    // "sensor-id=LABEL,sensor-id=LABEL" -> [{id, label}]
    // Empty means "all disks combined".
    readonly property var diskList: {
        const list = disks.split(",").map(s => s.trim()).filter(s => s.length > 0).map(s => {
            const [id, label] = s.split("=")
            return { id: id.trim(), label: (label || id).trim() }
        })
        return list.length > 0 ? list : [{ id: "all", label: "ALL DISKS" }]
    }

    function num(sensor) {
        const x = Number(sensor.value)
        return isFinite(x) ? x : 0
    }

    Sensors.Sensor { id: cpuUsage; sensorId: "cpu/all/usage"; updateRateLimit: m.interval }
    Sensors.Sensor { id: cpuTemp; sensorId: m.cpuTempSensor; updateRateLimit: m.interval }
    Sensors.Sensor { id: cpuFreq; sensorId: "cpu/all/averageFrequency"; updateRateLimit: m.interval }
    Sensors.Sensor { id: cpuCount; sensorId: "cpu/all/coreCount" }

    Sensors.Sensor { id: gpuUsage; sensorId: "gpu/" + m.gpuId + "/usage"; updateRateLimit: m.interval }
    Sensors.Sensor { id: gpuTemp; sensorId: "gpu/" + m.gpuId + "/temperature"; updateRateLimit: m.interval }
    Sensors.Sensor { id: gpuJunction; sensorId: "gpu/" + m.gpuId + "/temp2"; updateRateLimit: m.interval }
    // AMD reports package power as power1 (PPT); other drivers use power.
    Sensors.Sensor { id: gpuPower; sensorId: "gpu/" + m.gpuId + "/power"; updateRateLimit: m.interval }
    Sensors.Sensor { id: gpuPpt; sensorId: "gpu/" + m.gpuId + "/power1"; updateRateLimit: m.interval }
    Sensors.Sensor { id: gpuClock; sensorId: "gpu/" + m.gpuId + "/coreFrequency"; updateRateLimit: m.interval }
    Sensors.Sensor { id: gpuVram; sensorId: "gpu/" + m.gpuId + "/usedVram"; updateRateLimit: m.interval }
    Sensors.Sensor { id: gpuVramTotal; sensorId: "gpu/" + m.gpuId + "/totalVram" }
    Sensors.Sensor { id: gpuName; sensorId: "gpu/" + m.gpuId + "/name" }

    Sensors.Sensor { id: memUsed; sensorId: "memory/physical/used"; updateRateLimit: m.interval }
    Sensors.Sensor { id: memTotal; sensorId: "memory/physical/total" }
    Sensors.Sensor { id: swapPct; sensorId: "memory/swap/usedPercent"; updateRateLimit: m.interval }

    Sensors.Sensor { id: netDown; sensorId: "network/" + m.networkId + "/download"; updateRateLimit: m.interval }
    Sensors.Sensor { id: netUp; sensorId: "network/" + m.networkId + "/upload"; updateRateLimit: m.interval }

    Sensors.Sensor {
        id: firstDisk
        sensorId: "disk/" + m.diskList[0].id + "/usedPercent"
        updateRateLimit: m.interval
    }

    readonly property real cpu: num(cpuUsage)
    readonly property real cpuTempC: num(cpuTemp)
    readonly property real cpuMHz: num(cpuFreq)
    readonly property int threads: num(cpuCount)

    readonly property real gpu: num(gpuUsage)
    readonly property real gpuTempC: num(gpuTemp)
    readonly property real gpuJunctionC: num(gpuJunction)
    readonly property real gpuWatts: Math.max(num(gpuPower), num(gpuPpt))
    readonly property bool hasJunction: gpuJunction.name !== ""
    readonly property real gpuMHz: num(gpuClock)
    readonly property real vramUsed: num(gpuVram)
    readonly property real vramTotal: num(gpuVramTotal)
    readonly property string gpuModel: String(gpuName.value || "")

    readonly property real memUsedB: num(memUsed)
    readonly property real memTotalB: num(memTotal)
    readonly property real mem: memTotalB > 0 ? memUsedB / memTotalB * 100 : 0
    readonly property real swap: num(swapPct)

    readonly property real down: num(netDown)
    readonly property real up: num(netUp)
    readonly property real diskPct: num(firstDisk)

    property var downHistory: []
    property var upHistory: []
    readonly property real netPeak: Math.max(64 * 1024, ...downHistory, ...upHistory)

    // 0 = nominal, 1 = yellow alert, 2 = red alert
    readonly property int alertLevel: (cpuTempC >= 90 || gpuJunctionC >= 105) ? 2
        : (cpuTempC >= 80 || gpuJunctionC >= 95 || cpu >= 90 || mem >= 90 || diskPct >= 90) ? 1
        : 0

    function pushed(arr, v) {
        const a = arr.slice(-(historyLength - 1))
        a.push(v)
        return a
    }

    Timer {
        interval: m.interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            m.downHistory = m.pushed(m.downHistory, m.down)
            m.upHistory = m.pushed(m.upHistory, m.up)
        }
    }
}
