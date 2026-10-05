import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.bluezqt as BluezQt
import org.kde.plasma.private.batterymonitor
import org.kde.plasma.private.sessions as Sessions
import org.kde.plasma.private.volume
import org.kde.plasma.workspace.dbus as DBus
import "."

// MAASTRICHT control centre: quick toggles, power plan, volume, and Wi-Fi/Bluetooth pages.
Item {
    id: view

    signal closeRequested()

    readonly property real u: Maastricht.u
    property string page: "main"   // "main", "wifi" or "bluetooth"

    implicitWidth: 58 * u
    implicitHeight: content.implicitHeight + 3 * u
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredHeight: implicitHeight
    Layout.maximumHeight: implicitHeight

    property date now: new Date()
    Timer { interval: 30000; running: true; repeat: true; onTriggered: view.now = new Date() }

    // ── Backends ─────────────────────────────────────────────────────
    PlasmaNM.Handler { id: nmHandler }
    PlasmaNM.EnabledConnections { id: enabledConnections }
    PlasmaNM.NetworkModel { id: networkModel }
    PlasmaNM.AppletProxyModel { id: networks; sourceModel: networkModel }

    readonly property var btManager: BluezQt.Manager
    BluezQt.DevicesModel { id: btDevices }

    PowerProfilesControl { id: power }
    InhibitionControl { id: inhibition }
    FocusMode { id: focusMode }
    Sessions.SessionManagement { id: session }

    DBus.Properties {
        id: nightLight
        busType: DBus.BusType.Session
        service: "org.kde.KWin"
        path: "/org/kde/KWin/NightLight"
        iface: "org.kde.KWin.NightLight"
    }
    property int nightLightCookie: -1

    P5Support.DataSource {
        id: exec
        engine: "executable"
        onNewData: source => disconnectSource(source)
        function run(command) {
            connectSource(command)
        }
    }

    // Default audio devices (the Default role appears once PipeWire reports it).
    SinkModel { id: sinkModel }
    SourceModel { id: sourceModel }
    property var outputDevice: null
    property var inputDevice: null
    Repeater {
        model: sinkModel
        Item {
            required property var model
            readonly property bool isDefault: model.Default
            onIsDefaultChanged: if (isDefault) view.outputDevice = model.PulseObject
            Component.onCompleted: if (isDefault) view.outputDevice = model.PulseObject
        }
    }
    Repeater {
        model: sourceModel
        Item {
            required property var model
            readonly property bool isDefault: model.Default
            onIsDefaultChanged: if (isDefault) view.inputDevice = model.PulseObject
            Component.onCompleted: if (isDefault) view.inputDevice = model.PulseObject
        }
    }

    // Connected Wi-Fi network name, for the tile subtitle.
    property string wifiName: ""
    Repeater {
        model: networks
        Item {
            required property var model
            readonly property bool connectedWifi: model.Type === PlasmaNM.Enums.Wireless && model.ConnectionState === PlasmaNM.Enums.Activated
            onConnectedWifiChanged: view.updateWifiName()
            Component.onCompleted: view.updateWifiName()
            Component.onDestruction: view.updateWifiName()
        }
    }
    function updateWifiName() {
        Qt.callLater(() => {
            let name = ""
            for (let i = 0; i < networks.rowCount(); i++) {
                const idx = networks.index(i, 0)
                if (networks.data(idx, PlasmaNM.NetworkModel.TypeRole) === PlasmaNM.Enums.Wireless
                        && networks.data(idx, PlasmaNM.NetworkModel.ConnectionStateRole) === PlasmaNM.Enums.Activated) {
                    name = networks.data(idx, PlasmaNM.NetworkModel.ItemUniqueNameRole)
                }
            }
            wifiName = name
        })
    }

    // ── State helpers ────────────────────────────────────────────────
    readonly property bool btOn: btManager.bluetoothOperational
    readonly property int btConnected: {
        let n = 0
        for (const d of btManager.devices)
            if (d.connected) n++
        return n
    }
    readonly property bool dndOn: focusMode.active
    readonly property bool nightLightEnabled: nightLight.properties.enabled === true
    readonly property bool nightLightOn: nightLightEnabled && nightLight.properties.inhibited !== true

    readonly property var btAdapter: btManager.usableAdapter
    readonly property bool btScanning: btAdapter ? btAdapter.discovering : false
    property string btPairing: ""     // address of the device being paired
    property string btError: ""

    function startBtScan() {
        btError = ""
        if (btAdapter && !btAdapter.discovering)
            btAdapter.startDiscovery()
    }
    function stopBtScan() {
        if (btAdapter && btAdapter.discovering)
            btAdapter.stopDiscovery()
    }
    onPageChanged: page === "bluetooth" && btOn ? startBtScan() : stopBtScan()

    // Pair, trust (so it reconnects automatically) and connect. PIN prompts come from KDE's agent.
    function pairDevice(device) {
        btError = ""
        btPairing = device.address
        const call = device.pair()
        call.finished.connect(() => {
            btPairing = ""
            if (call.error) {
                btError = "PAIRING FAILED: " + (call.errorText || "UNKNOWN ERROR").toUpperCase()
                return
            }
            device.trusted = true
            device.connectToDevice()
        })
    }

    function forgetDevice(device) {
        if (btAdapter)
            btAdapter.removeDevice(device)
    }

    function toggleBluetooth() {
        const enable = !btOn
        btManager.bluetoothBlocked = !enable
        for (const adapter of btManager.adapters)
            adapter.powered = enable
    }

    function toggleDnd() {
        focusMode.toggle()
    }

    function toggleNightLight() {
        if (!nightLightEnabled) {
            exec.run("kcmshell6 kcm_nightlight")
            closeRequested()
            return
        }
        const msg = { service: "org.kde.KWin", path: "/org/kde/KWin/NightLight", iface: "org.kde.KWin.NightLight" }
        if (nightLight.properties.inhibited && nightLightCookie >= 0) {
            DBus.SessionBus.asyncCall(Object.assign({ member: "uninhibit", arguments: [new DBus.uint32(nightLightCookie)] }, msg))
            nightLightCookie = -1
        } else if (!nightLight.properties.inhibited) {
            DBus.SessionBus.asyncCall(Object.assign({ member: "inhibit", arguments: [] }, msg),
                                      reply => view.nightLightCookie = Number(reply.value))
        }
    }

    function openHome() {
        Qt.openUrlExternally(StandardPaths.writableLocation(StandardPaths.HomeLocation))
        closeRequested()
    }

    readonly property var profileLabels: ({ "power-saver": "POWER SAVER", "balanced": "BALANCED", "performance": "PERFORMANCE" })
    readonly property var profileColors: ({ "power-saver": Maastricht.lilac, "balanced": Maastricht.gold, "performance": Maastricht.red })

    // ── Layout ───────────────────────────────────────────────────────
    Column {
        id: content
        x: 1.5 * u
        y: 1.5 * u
        width: parent.width - 3 * u
        spacing: 1.2 * u

        Header {
            width: parent.width
            title: view.page === "wifi" ? "WI-FI" : view.page === "bluetooth" ? "BLUETOOTH" : "CONTROL CENTER"
            status: "STADSKLOK " + Maastricht.clock(view.now)
                    + (inhibition.isManuallyInhibited ? "  ·  SLEEP BLOCKED" : "")
                    + (view.dndOn ? "  ·  DO NOT DISTURB" : "")
        }

        // ── Main page ──
        Column {
            visible: view.page === "main"
            width: parent.width
            spacing: 1.2 * u

            Grid {
                id: tiles
                width: parent.width
                columns: 2
                columnSpacing: u
                rowSpacing: u
                readonly property real tileWidth: (width - columnSpacing) / 2

                LTile {
                    width: tiles.tileWidth
                    title: "WI-FI"
                    iconName: "network-wireless-symbolic"
                    accent: Maastricht.orange
                    active: enabledConnections.wirelessEnabled
                    subtitle: !enabledConnections.wirelessHwEnabled ? "HARDWARE OFF"
                              : !enabledConnections.wirelessEnabled ? "OFFLINE"
                              : view.wifiName !== "" ? view.wifiName : "NOT CONNECTED"
                    hasDetails: true
                    onToggled: nmHandler.enableWireless(!enabledConnections.wirelessEnabled)
                    onDetails: view.page = "wifi"
                }
                LTile {
                    width: tiles.tileWidth
                    title: "BLUETOOTH"
                    iconName: "network-bluetooth-symbolic"
                    accent: Maastricht.sky
                    active: view.btOn
                    subtitle: !view.btManager.adapters.length ? "NO ADAPTER"
                              : !view.btOn ? "OFFLINE"
                              : view.btConnected > 0 ? view.btConnected + " CONNECTED" : "ONLINE"
                    hasDetails: true
                    onToggled: view.toggleBluetooth()
                    onDetails: view.page = "bluetooth"
                }
                LTile {
                    width: tiles.tileWidth
                    title: "CAFFEINE"
                    iconName: "system-suspend-inhibited-symbolic"
                    accent: Maastricht.gold
                    active: inhibition.isManuallyInhibited
                    subtitle: active ? "SLEEP + LOCK BLOCKED" : "SLEEP ALLOWED"
                    onToggled: active ? inhibition.uninhibit() : inhibition.inhibit("MAASTRICHT Control Center: caffeine mode")
                }
                LTile {
                    width: tiles.tileWidth
                    title: "DO NOT DISTURB"
                    iconName: "notifications-disabled-symbolic"
                    accent: Maastricht.red
                    active: view.dndOn
                    subtitle: active ? "ALL NOTIFICATIONS SILENT" : "NOTIFICATIONS ON"
                    onToggled: view.toggleDnd()
                }
                LTile {
                    width: tiles.tileWidth
                    title: "NIGHT LIGHT"
                    iconName: "redshift-status-on-symbolic"
                    accent: Maastricht.peach
                    active: view.nightLightOn
                    subtitle: !view.nightLightEnabled ? "SET UP" : active ? "ACTIVE" : "PAUSED"
                    onToggled: view.toggleNightLight()
                }
                LTile {
                    width: tiles.tileWidth
                    title: "HOME"
                    iconName: "user-home-symbolic"
                    accent: Maastricht.violet
                    subtitle: "OPEN HOME FOLDER"
                    onToggled: view.openHome()
                }
            }

            // Power plan
            Column {
                width: parent.width
                spacing: 0.6 * u
                visible: power.isPowerProfileDaemonInstalled
                LText { text: "POWER PLAN"; color: Maastricht.lilac; font.pixelSize: 1.9 * u }
                Row {
                    width: parent.width
                    spacing: 0.6 * u
                    Repeater {
                        model: power.profiles
                        LPill {
                            required property string modelData
                            width: (parent.width - 0.6 * u * (power.profiles.length - 1)) / power.profiles.length
                            height: 3.6 * u
                            text: view.profileLabels[modelData] || modelData
                            accent: view.profileColors[modelData] || Maastricht.orange
                            active: power.activeProfile === modelData
                            onClicked: power.setProfile(modelData)
                        }
                    }
                }
                LText {
                    visible: text !== ""
                    width: parent.width
                    text: power.degradationReason || power.inhibitionReason || ""
                    color: Maastricht.gold
                    font.pixelSize: 1.6 * u
                }
            }

            // Volume
            Column {
                width: parent.width
                spacing: 0.8 * u
                LText { text: "AUDIO"; color: Maastricht.lilac; font.pixelSize: 1.9 * u }
                Repeater {
                    model: [
                        { label: "OUTPUT", device: view.outputDevice, accent: Maastricht.orange },
                        { label: "MIC", device: view.inputDevice, accent: Maastricht.lilac }
                    ]
                    Item {
                        required property var modelData
                        readonly property var device: modelData.device
                        width: parent.width
                        height: 3.2 * u
                        LText {
                            width: 7 * u
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label
                            color: modelData.accent
                        }
                        LSlider {
                            x: 7.5 * u
                            width: parent.width - x - 14 * u
                            height: 1.8 * u
                            anchors.verticalCenter: parent.verticalCenter
                            accent: modelData.accent
                            value: device ? device.volume / PulseAudio.NormalVolume : 0
                            muted: device ? device.muted : false
                            onMoved: v => {
                                if (!device) return
                                device.volume = Math.round(v * PulseAudio.NormalVolume)
                                if (device.muted && v > 0) device.muted = false
                            }
                        }
                        LText {
                            anchors { right: muteButton.left; rightMargin: u; verticalCenter: parent.verticalCenter }
                            width: 6 * u
                            horizontalAlignment: Text.AlignRight
                            text: device ? Math.round(device.volume / PulseAudio.NormalVolume * 100) + "%" : "--"
                            color: Maastricht.gold
                        }
                        LPill {
                            id: muteButton
                            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                            width: 7 * u
                            text: device && device.muted ? "MUTED" : "MUTE"
                            accent: Maastricht.red
                            active: device ? device.muted : false
                            onClicked: if (device) device.muted = !device.muted
                        }
                    }
                }
            }

            // Quick actions
            Row {
                width: parent.width
                spacing: 0.6 * u
                Repeater {
                    model: [
                        { label: "SETTINGS", accent: Maastricht.lilac, action: "settings" },
                        { label: "SCREENSHOT", accent: Maastricht.violet, action: "screenshot" },
                        { label: "LOCK", accent: Maastricht.sky, action: "lock" },
                        { label: "POWER", accent: Maastricht.red, action: "power" }
                    ]
                    LPill {
                        required property var modelData
                        width: (parent.width - 0.6 * u * 3) / 4
                        height: 3.4 * u
                        text: modelData.label
                        accent: modelData.accent
                        onClicked: {
                            view.closeRequested()
                            switch (modelData.action) {
                            case "settings": exec.run("systemsettings"); break
                            case "screenshot": exec.run("spectacle"); break
                            case "lock": session.lock(); break
                            case "power": session.requestLogoutPrompt(); break
                            }
                        }
                    }
                }
            }
        }

        // ── Wi-Fi page ──
        Column {
            visible: view.page === "wifi"
            width: parent.width
            spacing: u

            Row {
                spacing: 0.6 * u
                LPill { text: "‹ BACK"; accent: Maastricht.tan; onClicked: view.page = "main" }
                LPill {
                    text: enabledConnections.wirelessEnabled ? "WI-FI ON" : "WI-FI OFF"
                    accent: Maastricht.orange
                    active: enabledConnections.wirelessEnabled
                    onClicked: nmHandler.enableWireless(!enabledConnections.wirelessEnabled)
                }
                LPill {
                    text: nmHandler.scanning ? "SCANNING…" : "SCAN"
                    accent: Maastricht.sky
                    enabled: enabledConnections.wirelessEnabled
                    onClicked: nmHandler.requestScan("")
                }
                LPill {
                    text: "NETWORK SETTINGS"
                    accent: Maastricht.lilac
                    onClicked: { view.closeRequested(); exec.run("kcmshell6 kcm_networkmanagement") }
                }
            }

            ListView {
                id: wifiList
                width: parent.width
                height: Math.min(contentHeight, 40 * u)
                clip: true
                spacing: 0.5 * u
                boundsBehavior: Flickable.StopAtBounds
                model: enabledConnections.wirelessEnabled ? networks : null
                property string passwordFor: ""

                delegate: Item {
                    id: net
                    required property var model
                    readonly property bool isWifi: model.Type === PlasmaNM.Enums.Wireless
                    readonly property bool isActive: model.ConnectionState === PlasmaNM.Enums.Activated
                    readonly property bool isBusy: model.ConnectionState === PlasmaNM.Enums.Activating
                    readonly property bool secured: model.SecurityType !== PlasmaNM.Enums.NoneSecurity
                    readonly property bool askPassword: wifiList.passwordFor === model.ItemUniqueName

                    width: wifiList.width
                    height: isWifi ? (askPassword ? 8.4 * u : 4 * u) : 0
                    visible: isWifi

                    function connect() {
                        if (isActive) {
                            nmHandler.deactivateConnection(model.ConnectionPath, model.DevicePath)
                        } else if (model.Uuid || !secured) {
                            if (model.Uuid)
                                nmHandler.activateConnection(model.ConnectionPath, model.DevicePath, model.SpecificPath)
                            else
                                nmHandler.addAndActivateConnection(model.DevicePath, model.SpecificPath)
                        } else {
                            wifiList.passwordFor = model.ItemUniqueName
                            passwordField.forceActiveFocus()
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 4 * u
                        radius: Maastricht.round ? height / 2 : 0
                        color: net.isActive ? Maastricht.orange : (rowMouse.containsMouse ? Maastricht.dim(Maastricht.orange, 0.3) : Maastricht.dim(Maastricht.orange, 0.12))

                        // Signal strength as four MAASTRICHT segments
                        Row {
                            x: 1.5 * u
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0.25 * u
                            Repeater {
                                model: 4
                                Rectangle {
                                    required property int index
                                    width: 0.6 * u
                                    height: (0.8 + index * 0.45) * u
                                    anchors.bottom: parent.bottom
                                    color: net.model.Signal > index * 25
                                           ? (net.isActive ? Maastricht.ink(Maastricht.orange) : Maastricht.orange)
                                           : (net.isActive ? Maastricht.dim(Maastricht.ink(Maastricht.orange), 0.3) : Maastricht.dim(Maastricht.orange, 0.35))
                                }
                            }
                        }
                        LText {
                            x: 6 * u
                            width: parent.width - x - 14 * u
                            anchors.verticalCenter: parent.verticalCenter
                            text: net.model.ItemUniqueName
                            color: net.isActive ? Maastricht.ink(Maastricht.orange) : Maastricht.tan
                            font.pixelSize: 2 * u
                            font.capitalization: Font.MixedCase
                        }
                        LText {
                            anchors { right: parent.right; rightMargin: 1.5 * u; verticalCenter: parent.verticalCenter }
                            text: net.isActive ? "CONNECTED" : net.isBusy ? "CONNECTING…" : (net.secured ? "SECURED" : "OPEN")
                                  + (net.model.Uuid ? " · SAVED" : "")
                            color: net.isActive ? Maastricht.dim(Maastricht.ink(Maastricht.orange), 0.75) : Maastricht.dim(Maastricht.tan, 0.7)
                            font.pixelSize: 1.5 * u
                        }
                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: net.connect()
                        }
                    }

                    Row {
                        visible: net.askPassword
                        y: 4.6 * u
                        x: 2 * u
                        spacing: 0.6 * u
                        QQC2.TextField {
                            id: passwordField
                            width: net.width - 20 * u
                            height: 3.2 * u
                            echoMode: TextInput.Password
                            placeholderText: "Password"
                            onAccepted: connectButton.clicked()
                        }
                        LPill {
                            id: connectButton
                            text: "CONNECT"
                            accent: Maastricht.orange
                            active: true
                            onClicked: {
                                nmHandler.addAndActivateConnection(net.model.DevicePath, net.model.SpecificPath, passwordField.text)
                                passwordField.text = ""
                                wifiList.passwordFor = ""
                            }
                        }
                        LPill {
                            text: "CANCEL"
                            accent: Maastricht.tan
                            onClicked: { passwordField.text = ""; wifiList.passwordFor = "" }
                        }
                    }
                }
            }

            LText {
                visible: !enabledConnections.wirelessEnabled
                text: "WI-FI IS OFFLINE"
                color: Maastricht.dim(Maastricht.tan, 0.6)
            }
        }

        // ── Bluetooth page ──
        Column {
            visible: view.page === "bluetooth"
            width: parent.width
            spacing: u

            Row {
                spacing: 0.6 * u
                LPill { text: "‹ BACK"; accent: Maastricht.tan; onClicked: view.page = "main" }
                LPill {
                    text: view.btOn ? "BLUETOOTH ON" : "BLUETOOTH OFF"
                    accent: Maastricht.sky
                    active: view.btOn
                    enabled: view.btManager.adapters.length > 0
                    onClicked: view.toggleBluetooth()
                }
                LPill {
                    text: view.btScanning ? "SCANNING…" : "SCAN"
                    accent: Maastricht.lilac
                    active: view.btScanning
                    enabled: view.btOn
                    onClicked: view.btScanning ? view.stopBtScan() : view.startBtScan()
                }
                LPill {
                    text: "BLUETOOTH SETTINGS"
                    accent: Maastricht.violet
                    onClicked: { view.closeRequested(); exec.run("kcmshell6 kcm_bluetooth") }
                }
            }

            LText {
                visible: view.btError !== ""
                width: parent.width
                text: view.btError
                color: Maastricht.alert
                font.pixelSize: 1.7 * u
            }

            LText { visible: view.btOn; text: "PAIRED DEVICES"; color: Maastricht.lilac; font.pixelSize: 1.9 * u }
            Column {
                visible: view.btOn
                width: parent.width
                spacing: 0.5 * u
                Repeater {
                    model: view.btOn ? btDevices : null
                    BtRow { mode: "paired" }
                }
                LText {
                    visible: view.btManager.devices.filter(d => d.paired || d.connected).length === 0
                    text: "NONE YET"
                    color: Maastricht.dim(Maastricht.tan, 0.6)
                    font.pixelSize: 1.8 * u
                }
            }

            LText { visible: view.btOn; text: "NEARBY DEVICES"; color: Maastricht.lilac; font.pixelSize: 1.9 * u }
            Flickable {
                visible: view.btOn
                width: parent.width
                height: Math.min(nearbyColumn.implicitHeight, 26 * u)
                contentHeight: nearbyColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                Column {
                    id: nearbyColumn
                    width: parent.width
                    spacing: 0.5 * u
                    Repeater {
                        model: view.btOn ? btDevices : null
                        BtRow { mode: "nearby" }
                    }
                    LText {
                        visible: view.btManager.devices.filter(d => !d.paired && !d.connected && d.remoteName !== "").length === 0
                        text: view.btScanning ? "SEARCHING… PUT YOUR DEVICE IN PAIRING MODE" : "PRESS SCAN TO SEARCH"
                        color: Maastricht.dim(Maastricht.tan, 0.6)
                        font.pixelSize: 1.8 * u
                    }
                }
            }

            LText {
                visible: !view.btOn
                text: view.btManager.adapters.length ? "BLUETOOTH IS OFFLINE" : "NO BLUETOOTH ADAPTER FOUND"
                color: Maastricht.dim(Maastricht.tan, 0.6)
            }
        }
    }
}
