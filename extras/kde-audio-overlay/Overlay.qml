import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.layershell as LayerShell
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.volume

// Game Bar style audio overlay for KDE Plasma 6. Runs as a layer-shell overlay,
// so it appears above everything, fullscreen games included. Uses the active
// KDE colour scheme and font.
Window {
    id: win

    // ── Settings ─────────────────────────────────────────────────────
    // Where the panel appears: "top", "center" or "bottom".
    readonly property string position: "top"
    // Distance from the screen edge for "top"/"bottom", e.g. your panel height plus a gap.
    readonly property int edgeOffset: 52
    // Overall size; 1.0 is the default.
    readonly property real sizeFactor: 1.0
    // ─────────────────────────────────────────────────────────────────

    visible: false
    width: Screen.width
    height: Screen.height
    color: "transparent"
    title: "Audio Overlay"

    LayerShell.Window.scope: "kde-audio-overlay"
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop | LayerShell.Window.AnchorBottom
        | LayerShell.Window.AnchorLeft | LayerShell.Window.AnchorRight
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityExclusive
    LayerShell.Window.wantsToBeOnActiveScreen: true

    Component.onCompleted: {
        visible = true
        keys.forceActiveFocus()
    }

    // Testing aid: `qml6 Overlay.qml -- --snapshot=/path.png` saves a screenshot and exits.
    Timer {
        readonly property string path: (Qt.application.arguments.find(a => a.startsWith("--snapshot=")) || "").slice(11)
        running: path !== ""
        interval: 2500
        onTriggered: win.contentItem.grabToImage(r => { r.saveToFile(path); Qt.quit() })
    }

    function close() {
        closing.start()
    }

    // ── Audio models ─────────────────────────────────────────────────
    SinkModel { id: sinkModel }
    SourceModel { id: sourceModel }
    SinkInputModel { id: streamModel }

    // Collects the devices of a model into plain lists and tracks which one is
    // the default. The Default role only becomes true once PipeWire reports it,
    // so this updates whenever a device changes.
    component DeviceTracker: Item {
        id: tracker
        property alias model: repeater.model
        property bool skipMonitors: false
        property var objects: []
        property var names: []
        property int defaultIndex: -1
        readonly property var current: defaultIndex >= 0 ? objects[defaultIndex] : null

        function refresh() {
            const objs = [], labels = []
            let def = -1
            for (let i = 0; i < repeater.count; i++) {
                const item = repeater.itemAt(i)
                if (!item || (skipMonitors && String(item.deviceName).endsWith(".monitor")))
                    continue
                if (item.isDefault)
                    def = objs.length
                objs.push(item.pulseObject)
                labels.push(item.description)
            }
            objects = objs
            names = labels
            defaultIndex = def
        }

        Timer { id: debounce; interval: 50; onTriggered: tracker.refresh() }

        Repeater {
            id: repeater
            onCountChanged: debounce.restart()
            Item {
                required property var model
                readonly property var pulseObject: model.PulseObject
                readonly property string deviceName: model.Name
                readonly property string description: model.Description
                readonly property bool isDefault: model.Default
                onIsDefaultChanged: debounce.restart()
                onDescriptionChanged: debounce.restart()
            }
        }
    }

    DeviceTracker { id: outputs; model: sinkModel }
    DeviceTracker { id: inputs; model: sourceModel; skipMonitors: true }

    // ── Reusable volume row ──────────────────────────────────────────
    component VolumeRow: RowLayout {
        id: row
        property var pulseObject
        property string label
        property string iconName: ""

        readonly property bool muted: pulseObject ? pulseObject.muted : false
        readonly property real percent: pulseObject ? pulseObject.volume / PulseAudio.NormalVolume * 100 : 0

        spacing: Kirigami.Units.smallSpacing * 2 * win.sizeFactor

        QQC2.ToolButton {
            icon.name: row.muted ? "audio-volume-muted" : (row.iconName || "audio-volume-high")
            icon.width: Kirigami.Units.iconSizes.smallMedium * win.sizeFactor
            icon.height: Kirigami.Units.iconSizes.smallMedium * win.sizeFactor
            checkable: true
            checked: row.muted
            enabled: row.pulseObject !== null
            onClicked: row.pulseObject.muted = !row.pulseObject.muted
            QQC2.ToolTip.text: row.muted ? qsTr("Unmute") : qsTr("Mute")
            QQC2.ToolTip.visible: hovered
        }
        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 9 * win.sizeFactor
            text: row.label
            elide: Text.ElideRight
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * win.sizeFactor
        }
        QQC2.Slider {
            Layout.fillWidth: true
            from: 0
            to: 100
            value: row.percent
            enabled: row.pulseObject !== null
            opacity: row.muted ? 0.5 : 1
            onMoved: {
                row.pulseObject.volume = Math.round(value / 100 * PulseAudio.NormalVolume)
                if (row.pulseObject.muted && value > 0)
                    row.pulseObject.muted = false
            }
        }
        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5 * win.sizeFactor
            horizontalAlignment: Text.AlignRight
            text: Math.round(row.percent) + "%"
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * win.sizeFactor
            font.features: { "tnum": 1 }
        }
    }

    // ── Backdrop: dims the screen, click to close ────────────────────
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "black"
        opacity: 0
        MouseArea { anchors.fill: parent; onClicked: win.close() }
    }

    Item {
        id: keys
        Keys.onEscapePressed: win.close()
        Keys.onPressed: event => {
            if (event.key === Qt.Key_G && (event.modifiers & Qt.MetaModifier))
                win.close()
        }
    }

    // ── The panel ────────────────────────────────────────────────────
    Kirigami.ShadowedRectangle {
        id: panel

        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false

        width: Math.min(parent.width - Kirigami.Units.gridUnit * 2, Kirigami.Units.gridUnit * 34 * win.sizeFactor)
        height: content.implicitHeight + Kirigami.Units.largeSpacing * 2
        anchors.horizontalCenter: parent.horizontalCenter
        y: win.position === "bottom" ? parent.height - height - win.edgeOffset
            : win.position === "center" ? (parent.height - height) / 2
            : win.edgeOffset
        transformOrigin: win.position === "bottom" ? Item.Bottom : Item.Top

        color: Kirigami.Theme.backgroundColor
        radius: Kirigami.Units.cornerRadius * 2
        border.width: 1
        border.color: Qt.alpha(Kirigami.Theme.textColor, 0.15)
        shadow.size: Kirigami.Units.gridUnit
        shadow.color: Qt.rgba(0, 0, 0, 0.4)
        shadow.yOffset: 2

        opacity: 0
        scale: 0.97

        // swallow clicks so they don't reach the backdrop
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: content
            anchors { fill: parent; margins: Kirigami.Units.largeSpacing }
            spacing: Kirigami.Units.smallSpacing * 2

            RowLayout {
                Layout.fillWidth: true
                Kirigami.Heading {
                    Layout.fillWidth: true
                    level: 2
                    text: qsTr("Audio")
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.4 * win.sizeFactor
                }
                QQC2.ToolButton {
                    icon.name: "configure"
                    text: qsTr("Sound Settings")
                    display: QQC2.AbstractButton.IconOnly
                    onClicked: {
                        Qt.openUrlExternally("systemsettings://kcm_pulseaudio")
                        win.close()
                    }
                    QQC2.ToolTip.text: text
                    QQC2.ToolTip.visible: hovered
                }
                QQC2.ToolButton {
                    icon.name: "window-close"
                    text: qsTr("Close")
                    display: QQC2.AbstractButton.IconOnly
                    onClicked: win.close()
                }
            }

            // Output
            Kirigami.Heading { level: 4; text: qsTr("Output"); opacity: 0.7 }
            QQC2.ComboBox {
                Layout.fillWidth: true
                model: outputs.names
                currentIndex: outputs.defaultIndex
                onActivated: index => outputs.objects[index].default = true
            }
            VolumeRow {
                Layout.fillWidth: true
                pulseObject: outputs.current
                label: qsTr("Volume")
            }

            Kirigami.Separator { Layout.fillWidth: true }

            // Input
            Kirigami.Heading { level: 4; text: qsTr("Microphone"); opacity: 0.7 }
            QQC2.ComboBox {
                Layout.fillWidth: true
                model: inputs.names
                currentIndex: inputs.defaultIndex
                onActivated: index => inputs.objects[index].default = true
            }
            VolumeRow {
                Layout.fillWidth: true
                pulseObject: inputs.current
                label: qsTr("Input level")
                iconName: "audio-input-microphone"
            }

            Kirigami.Separator { Layout.fillWidth: true }

            // Applications
            Kirigami.Heading { level: 4; text: qsTr("Applications"); opacity: 0.7 }
            QQC2.Label {
                visible: appList.count === 0
                text: qsTr("No applications are playing audio")
                opacity: 0.6
            }
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, Kirigami.Units.gridUnit * 12)
                visible: count > 0
                clip: true
                spacing: Kirigami.Units.smallSpacing
                boundsBehavior: Flickable.StopAtBounds
                model: streamModel
                delegate: VolumeRow {
                    required property var model
                    width: ListView.view.width
                    pulseObject: model.PulseObject
                    label: model.PulseObject.client ? model.PulseObject.client.name : model.PulseObject.name
                    iconName: {
                        const p = model.PulseObject.properties || {}
                        return p["application.icon_name"] || p["application.process.binary"] || "audio-volume-high"
                    }
                }
            }
        }
    }

    // ── Open / close animations ──────────────────────────────────────
    ParallelAnimation {
        running: true
        NumberAnimation { target: backdrop; property: "opacity"; to: 0.35; duration: Kirigami.Units.shortDuration }
        NumberAnimation { target: panel; property: "opacity"; to: 1; duration: Kirigami.Units.shortDuration }
        NumberAnimation { target: panel; property: "scale"; to: 1; duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic }
    }
    SequentialAnimation {
        id: closing
        ParallelAnimation {
            NumberAnimation { target: backdrop; property: "opacity"; to: 0; duration: Kirigami.Units.shortDuration }
            NumberAnimation { target: panel; property: "opacity"; to: 0; duration: Kirigami.Units.shortDuration }
            NumberAnimation { target: panel; property: "scale"; to: 0.97; duration: Kirigami.Units.shortDuration }
        }
        ScriptAction { script: Qt.quit() }
    }
}
