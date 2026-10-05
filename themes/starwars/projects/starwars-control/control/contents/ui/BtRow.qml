import QtQuick
import org.kde.kirigami as Kirigami
import "."

// One Bluetooth device row. mode "paired" shows known devices, "nearby" shows new ones.
Item {
    id: row

    required property var model
    property string mode: "paired"

    readonly property real u: StarWars.u
    readonly property var device: model.Device
    readonly property var view: parent ? findView(parent) : null
    readonly property bool known: device !== null && (device.paired || device.connected)
    readonly property bool shown: device !== null && (mode === "paired" ? known : (!known && device.remoteName !== ""))
    readonly property bool connected: device !== null && device.connected
    readonly property bool pairing: view !== null && device !== null && view.btPairing === device.address

    function findView(item) {
        while (item && item.btPairing === undefined)
            item = item.parent
        return item
    }

    width: parent ? parent.width : 0
    height: shown ? 4 * u : 0
    visible: shown

    Rectangle {
        anchors.fill: parent
        radius: StarWars.round ? height / 2 : 0
        color: row.connected ? StarWars.sky : (mouse.containsMouse ? StarWars.dim(StarWars.sky, 0.22) : StarWars.dim(StarWars.sky, 0.12))
        MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true }

        Kirigami.Icon {
            x: 1.4 * u
            anchors.verticalCenter: parent.verticalCenter
            width: 2.4 * u
            height: width
            source: row.device ? (row.device.icon || "network-bluetooth") + "-symbolic" : ""
            fallback: row.device ? row.device.icon || "network-bluetooth" : ""
            color: row.connected ? StarWars.ink(StarWars.sky) : StarWars.sky
            isMask: true
        }
        LText {
            x: 5 * u
            width: parent.width - x - buttons.width - 6 * u
            anchors.verticalCenter: parent.verticalCenter
            text: row.device ? row.device.name : ""
            color: row.connected ? StarWars.ink(StarWars.sky) : StarWars.tan
            font.pixelSize: 2 * u
            font.capitalization: Font.MixedCase
        }
        LText {
            anchors { right: buttons.left; rightMargin: u; verticalCenter: parent.verticalCenter }
            text: row.device && row.device.battery ? row.device.battery.percentage + "%" : ""
            color: row.connected ? StarWars.ink(StarWars.sky) : StarWars.gold
            font.pixelSize: 1.7 * u
        }

        Row {
            id: buttons
            anchors { right: parent.right; rightMargin: 0.4 * u; verticalCenter: parent.verticalCenter }
            spacing: 0.4 * u

            LPill {
                visible: row.mode === "paired" && !row.connected
                width: 8 * u
                height: 3.2 * u
                text: "FORGET"
                accent: StarWars.red
                onClicked: if (row.view) row.view.forgetDevice(row.device)
            }
            LPill {
                width: 12 * u
                height: 3.2 * u
                text: row.mode === "nearby" ? (row.pairing ? "PAIRING…" : "PAIR")
                                            : (row.connected ? "DISCONNECT" : "CONNECT")
                accent: row.connected ? StarWars.ink(StarWars.sky) : StarWars.sky
                active: row.pairing
                enabled: !row.pairing
                onClicked: {
                    if (!row.device || !row.view) return
                    if (row.mode === "nearby") row.view.pairDevice(row.device)
                    else if (row.connected) row.device.disconnectFromDevice()
                    else row.device.connectToDevice()
                }
            }
        }
    }
}
