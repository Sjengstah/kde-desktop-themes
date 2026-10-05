import QtQuick
import QtQuick.Window
import org.kde.layershell as LayerShell
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.volume

// FEYENOORD audio overlay, opened with Meta+G. Runs as a layer-shell overlay so it
// appears above everything, fullscreen games included.
Window {
    id: win

    // true when run with qml6 (closing quits); false inside the Plasma widget,
    // where closing must only emit finished() so the shell keeps running.
    property bool standalone: true
    signal finished()

    visible: false
    width: Screen.width
    height: Screen.height
    color: "transparent"
    title: "FEYENOORD Audio"

    LayerShell.Window.scope: "feyenoord-audio"
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop | LayerShell.Window.AnchorBottom
        | LayerShell.Window.AnchorLeft | LayerShell.Window.AnchorRight
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityExclusive
    LayerShell.Window.wantsToBeOnActiveScreen: true

    Component.onCompleted: {
        visible = true
        root.forceActiveFocus()
    }

    // Testing aid: `qml6 Overlay.qml -- --snapshot=/path.png` saves a screenshot and exits.
    Timer {
        readonly property string path: (Qt.application.arguments.find(a => a.startsWith("--snapshot=")) || "").slice(11)
        running: win.standalone && path !== ""
        interval: 2500
        onTriggered: win.contentItem.grabToImage(r => { r.saveToFile(path); Qt.quit() })
    }

    // ── Palette ──
    readonly property color orange: "#E30613"
    readonly property color gold: "#F2C230"
    readonly property color tan: "#F5F5F7"
    readonly property color peach: "#FF7A7A"
    readonly property color violet: "#5A5A68"
    readonly property color lilac: "#C9CDD6"
    readonly property color blue: "#8E929E"
    readonly property color red: "#9C0010"
    readonly property color alert: "#FF3B30"
    readonly property color navy: "#0B0B0E"
    readonly property bool round: false
    readonly property string corner: "cut"

    FontLoader { id: themeFont; source: "fonts/Teko-Variable.ttf" }
    readonly property string fontFamily: themeFont.status === FontLoader.Ready ? themeFont.font.family : "Teko"

    // Placement: centred horizontally, just below the top panel.
    readonly property int topPanelHeight: 34
    readonly property int panelGap: 8
    readonly property real sizeFactor: 0.7

    readonly property real u: Math.max(4, Math.min(width / 170, height / 100) * sizeFactor)

    function dim(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a === undefined ? 0.18 : a)
    }

    // Text colour that reads on a filled block: navy on light accents, white on dark ones.
    function ink(c) {
        return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) > 0.52 ? navy : "#FFFFFF"
    }

    function close() {
        if (!closing.running)
            closing.start()
    }

    // ── Audio models ──
    SinkModel { id: sinks }
    SourceModel { id: sources }

    // The current default devices. The models flag them with the Default role
    // once PipeWire reports it; the device pills below keep these up to date.
    property var outputDevice: null
    property var inputDevice: null
    SinkInputModel { id: streams }

    // ── Reusable pieces ──
    component LText: Text {
        font.family: win.fontFamily
        font.italic: false
        font.weight: Font.DemiBold
        font.capitalization: Font.AllUppercase
        color: win.tan
        elide: Text.ElideRight
        lineHeightMode: Text.ProportionalHeight
        lineHeight: 0.85
    }

    // Pill button: filled when active, outlined when not.
    component Pill: Rectangle {
        id: pill
        property string text
        property color accent: win.orange
        property bool active: false
        signal clicked()

        height: 3.4 * win.u
        width: Math.min(pillText.implicitWidth + 3.4 * win.u, 34 * win.u)
        radius: win.round ? height / 2 : 0
        color: active ? accent : (pillMouse.containsMouse ? win.dim(accent, 0.3) : "transparent")
        border.color: accent
        border.width: active ? 0 : Math.max(1, 0.2 * win.u)
        Behavior on color { ColorAnimation { duration: 120 } }

        LText {
            id: pillText
            anchors.centerIn: parent
            width: Math.min(implicitWidth, pill.width - 2 * win.u)
            text: pill.text
            color: pill.active ? win.ink(pill.accent) : pill.accent
            font.pixelSize: 1.9 * win.u
        }
        MouseArea {
            id: pillMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pill.clicked()
        }
    }

    // Segmented FEYENOORD volume slider. value is 0..1 of normal volume.
    component VolumeSlider: Item {
        id: slider
        property real value: 0
        property color accent: win.orange
        property bool muted: false
        property int segments: 40
        signal moved(real value)

        height: 2.6 * win.u
        readonly property real gap: Math.max(1, 0.3 * win.u)
        readonly property int lit: Math.round(Math.max(0, Math.min(1, value)) * segments)

        Row {
            anchors.fill: parent
            spacing: slider.gap
            Repeater {
                model: slider.segments
                Rectangle {
                    required property int index
                    width: (slider.width - slider.gap * (slider.segments - 1)) / slider.segments
                    height: slider.height
                    radius: win.round && (index === 0 || index === slider.segments - 1) ? 0.4 * win.u : 0
                    color: index < slider.lit
                        ? (slider.muted ? win.dim(slider.accent, 0.35) : slider.accent)
                        : win.dim(slider.accent)
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -win.u
            cursorShape: Qt.PointingHandCursor
            function update(mx) {
                slider.moved(Math.max(0, Math.min(1, (mx - win.u) / slider.width)))
            }
            onPressed: mouse => update(mouse.x)
            onPositionChanged: mouse => { if (pressed) update(mouse.x) }
            onWheel: wheel => slider.moved(Math.max(0, Math.min(1, slider.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
        }
    }

    // One volume row: label, slider, percentage and mute toggle for a PulseObject.
    component VolumeRow: Item {
        id: row
        property var pulseObject
        property string label
        property string iconName: ""
        property color accent: win.orange

        readonly property real value: pulseObject ? pulseObject.volume / PulseAudio.NormalVolume : 0
        height: 4.4 * win.u

        Kirigami.Icon {
            id: icon
            visible: row.iconName !== ""
            width: visible ? 3.2 * win.u : 0
            height: width
            anchors.verticalCenter: parent.verticalCenter
            source: row.iconName
        }
        LText {
            id: rowLabel
            x: icon.width + (icon.visible ? 1.2 * win.u : 0)
            width: 20 * win.u - x
            anchors.verticalCenter: parent.verticalCenter
            text: row.label
            color: row.accent
            font.pixelSize: 2.2 * win.u
        }
        VolumeSlider {
            id: rowSlider
            x: 21 * win.u
            width: parent.width - x - 21 * win.u
            anchors.verticalCenter: parent.verticalCenter
            accent: row.accent
            value: row.value
            muted: row.pulseObject ? row.pulseObject.muted : false
            onMoved: v => {
                if (!row.pulseObject)
                    return
                row.pulseObject.volume = Math.round(v * PulseAudio.NormalVolume)
                if (row.pulseObject.muted && v > 0)
                    row.pulseObject.muted = false
            }
        }
        LText {
            anchors { right: muteButton.left; rightMargin: 1.5 * win.u; verticalCenter: parent.verticalCenter }
            width: 7 * win.u
            horizontalAlignment: Text.AlignRight
            text: Math.round(row.value * 100) + "%"
            color: win.gold
            font.pixelSize: 2.6 * win.u
        }
        Pill {
            id: muteButton
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            width: 10 * win.u
            text: row.pulseObject && row.pulseObject.muted ? "MUTED" : "MUTE"
            accent: win.red
            active: row.pulseObject ? row.pulseObject.muted : false
            onClicked: if (row.pulseObject) row.pulseObject.muted = !row.pulseObject.muted
        }
    }

    // FEYENOORD section: coloured sidebar block with label, content to the right.
    component Section: Item {
        id: sec
        property string label
        property string code
        property color accent: win.orange
        default property alias content: holder.data

        Rectangle {
            width: 14 * win.u
            height: sec.height
            color: sec.accent
            LText {
                anchors { right: parent.right; top: parent.top; margins: 0.8 * win.u }
                text: sec.code
                color: win.ink(sec.accent)
                font.pixelSize: 1.6 * win.u
            }
            LText {
                anchors { right: parent.right; bottom: parent.bottom; margins: 0.8 * win.u }
                text: sec.label
                color: win.ink(sec.accent)
                font.pixelSize: 2.8 * win.u
            }
        }
        Item {
            id: holder
            x: 17 * win.u
            y: 0.6 * win.u
            width: sec.width - x
            height: sec.height - 1.2 * win.u
        }
    }

    // ── Backdrop: dims the game, click to close ──
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: win.navy
        opacity: 0
        MouseArea { anchors.fill: parent; onClicked: win.close() }
    }

    Item {
        id: root
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: win.close()
        Keys.onPressed: event => {
            if (event.key === Qt.Key_G && (event.modifiers & Qt.MetaModifier))
                win.close()
        }
    }

    // ── The panel ──
    Item {
        id: panel
        width: 110 * win.u
        height: frame.implicitHeight + 4 * win.u
        anchors.horizontalCenter: parent.horizontalCenter
        y: win.topPanelHeight + win.panelGap
        transformOrigin: Item.Top
        opacity: 0
        scale: 0.96

        // swallow clicks so they don't reach the backdrop
        MouseArea { anchors.fill: parent }

        Rectangle {
            anchors.fill: parent
            color: win.navy
            radius: win.round ? 2.5 * win.u : 0
            border.color: win.dim(win.orange, 0.35)
            border.width: 1
        }

        Column {
            id: frame
            x: 2 * win.u
            y: 2 * win.u
            width: parent.width - 4 * win.u
            spacing: 0.6 * win.u

            // Header elbow
            Item {
                width: frame.width
                height: 8 * win.u

                Canvas {
                    id: elbow
                    width: 22 * win.u
                    height: parent.height
                    onWidthChanged: requestPaint()
                    onPaint: {
                        const c = getContext("2d"), u = win.u
                        const sw = 14 * u, bh = 3 * u, R = 5 * u, r = 2 * u
                        c.reset()
                        c.fillStyle = win.orange
                        c.beginPath()
                        c.moveTo(0, height); c.lineTo(0, R)
                        if (win.corner === "round") c.arcTo(0, 0, R, 0, R)
                        else if (win.corner === "square") { c.lineTo(0, 0); c.lineTo(R, 0) }
                        else c.lineTo(R, 0)
                        c.lineTo(width, 0); c.lineTo(width, bh); c.lineTo(sw + r, bh)
                        if (win.corner === "round") c.arcTo(sw, bh, sw, bh + r, r)
                        else if (win.corner === "square") { c.lineTo(sw, bh); c.lineTo(sw, bh + r) }
                        else c.lineTo(sw, bh + r)
                        c.lineTo(sw, height)
                        c.closePath(); c.fill()
                    }
                }
                Row {
                    x: elbow.width + 0.6 * win.u
                    width: parent.width - x
                    spacing: 0.6 * win.u
                    Rectangle { width: parent.width - title.width - 16 * win.u; height: 3 * win.u; color: win.violet }
                    LText {
                        id: title
                        height: 3 * win.u
                        verticalAlignment: Text.AlignVCenter
                        text: "AUDIO CONTROL"
                        color: win.orange
                        font.pixelSize: 4.2 * win.u
                    }
                    Rectangle { width: 8 * win.u; height: 3 * win.u; color: win.peach }
                    Rectangle { width: 6 * win.u; height: 3 * win.u; color: win.orange; radius: win.round ? height / 2 : 0 }
                }
                LText {
                    x: 17 * win.u
                    anchors.bottom: parent.bottom
                    text: "DE KUIP PA · " + sinks.count + " OUTPUT · " + sources.count + " INPUT"
                    color: win.lilac
                    font.pixelSize: 2.2 * win.u
                }
            }

            // Output devices
            Section {
                width: frame.width
                height: outCol.implicitHeight + 2.4 * win.u
                label: "OUTPUT"
                code: "01-" + sinks.count
                accent: win.orange

                Column {
                    id: outCol
                    width: parent.width
                    spacing: 1.2 * win.u
                    Flow {
                        width: parent.width
                        spacing: 0.8 * win.u
                        Repeater {
                            model: sinks
                            Pill {
                                required property var model
                                readonly property bool isDefault: model.Default
                                onIsDefaultChanged: if (isDefault) win.outputDevice = model.PulseObject
                                Component.onCompleted: if (isDefault) win.outputDevice = model.PulseObject
                                text: model.Description
                                active: isDefault
                                accent: win.orange
                                onClicked: model.PulseObject.default = true
                            }
                        }
                    }
                    VolumeRow {
                        width: parent.width
                        pulseObject: win.outputDevice
                        label: "MASTER"
                        accent: win.orange
                    }
                }
            }

            // Input devices
            Section {
                width: frame.width
                height: inCol.implicitHeight + 2.4 * win.u
                label: "INPUT"
                code: "02-" + sources.count
                accent: win.lilac

                Column {
                    id: inCol
                    width: parent.width
                    spacing: 1.2 * win.u
                    Flow {
                        width: parent.width
                        spacing: 0.8 * win.u
                        Repeater {
                            model: sources
                            Pill {
                                required property var model
                                // Hide monitor sources (loopbacks of outputs).
                                visible: !String(model.Name).endsWith(".monitor")
                                readonly property bool isDefault: model.Default
                                onIsDefaultChanged: if (isDefault) win.inputDevice = model.PulseObject
                                Component.onCompleted: if (isDefault) win.inputDevice = model.PulseObject
                                text: model.Description
                                active: isDefault
                                accent: win.lilac
                                onClicked: model.PulseObject.default = true
                            }
                        }
                    }
                    VolumeRow {
                        width: parent.width
                        pulseObject: win.inputDevice
                        label: "MICROPHONE"
                        accent: win.lilac
                    }
                }
            }

            // Per-application streams
            Section {
                width: frame.width
                height: Math.max(8 * win.u, appList.height + 2.4 * win.u)
                label: "APPS"
                code: "03-" + appList.count
                accent: win.peach

                LText {
                    visible: appList.count === 0
                    anchors.verticalCenter: parent.verticalCenter
                    text: "NO ACTIVE AUDIO STREAMS"
                    color: win.dim(win.tan, 0.6)
                    font.pixelSize: 2.4 * win.u
                }

                ListView {
                    id: appList
                    width: parent.width
                    height: Math.min(contentHeight, 30 * win.u)
                    clip: true
                    spacing: 0.6 * win.u
                    model: streams
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: VolumeRow {
                        required property var model
                        width: appList.width
                        pulseObject: model.PulseObject
                        label: model.PulseObject.client ? model.PulseObject.client.name : model.PulseObject.name
                        iconName: {
                            const p = model.PulseObject.properties || {}
                            return p["application.icon_name"] || p["application.process.binary"] || "audio-volume-high"
                        }
                        accent: win.peach
                    }
                }
            }

            // Footer
            Item {
                width: frame.width
                height: 5 * win.u

                Canvas {
                    id: footElbow
                    width: 22 * win.u
                    height: parent.height
                    onWidthChanged: requestPaint()
                    onPaint: {
                        const c = getContext("2d"), u = win.u
                        const sw = 14 * u, bh = 2 * u, R = 3.5 * u, r = 1.4 * u
                        c.reset()
                        c.translate(0, height); c.scale(1, -1)
                        c.fillStyle = win.tan
                        c.beginPath()
                        c.moveTo(0, height); c.lineTo(0, R)
                        if (win.corner === "round") c.arcTo(0, 0, R, 0, R)
                        else if (win.corner === "square") { c.lineTo(0, 0); c.lineTo(R, 0) }
                        else c.lineTo(R, 0)
                        c.lineTo(width, 0); c.lineTo(width, bh); c.lineTo(sw + r, bh)
                        if (win.corner === "round") c.arcTo(sw, bh, sw, bh + r, r)
                        else if (win.corner === "square") { c.lineTo(sw, bh); c.lineTo(sw, bh + r) }
                        else c.lineTo(sw, bh + r)
                        c.lineTo(sw, height)
                        c.closePath(); c.fill()
                    }
                }
                Row {
                    x: footElbow.width + 0.6 * win.u
                    anchors.bottom: parent.bottom
                    width: parent.width - x
                    spacing: 0.6 * win.u
                    Rectangle { width: 10 * win.u; height: 2 * win.u; color: win.red }
                    Rectangle { width: parent.width - hint.width - 14 * win.u; height: 2 * win.u; color: win.gold }
                    LText {
                        id: hint
                        height: 2 * win.u
                        verticalAlignment: Text.AlignVCenter
                        text: "ESC OR META+G TO CLOSE"
                        font.pixelSize: 2.4 * win.u
                    }
                    Rectangle { width: 2 * win.u; height: 2 * win.u; color: win.tan; radius: win.round ? height / 2 : 0 }
                }
            }
        }
    }

    // ── Open / close animations ──
    ParallelAnimation {
        running: true
        NumberAnimation { target: backdrop; property: "opacity"; to: 0.55; duration: 160 }
        NumberAnimation { target: panel; property: "opacity"; to: 1; duration: 160 }
        NumberAnimation { target: panel; property: "scale"; to: 1; duration: 200; easing.type: Easing.OutCubic }
    }
    SequentialAnimation {
        id: closing
        ParallelAnimation {
            NumberAnimation { target: backdrop; property: "opacity"; to: 0; duration: 120 }
            NumberAnimation { target: panel; property: "opacity"; to: 0; duration: 120 }
            NumberAnimation { target: panel; property: "scale"; to: 0.96; duration: 120 }
        }
        ScriptAction {
            script: {
                if (win.standalone)
                    Qt.quit()
                else
                    win.finished()
            }
        }
    }
}
