import QtQuick
import QtQuick.Shapes
import org.kde.plasma.plasmoid

// MVV Live: the MVV wallpaper drawn in QML, with live readouts next to the three
// side blocks. The readouts come from Data.qml (one per theme); the look from theme.json.
WallpaperItem {
    id: root

    readonly property real ww: width
    readonly property real hh: height
    readonly property real u: hh / 100
    readonly property real m: 3 * u
    readonly property real floatGap: 10
    readonly property real mt: (root.configuration.PanelTop > 0 ? root.configuration.PanelTop + floatGap : 0) + 1.5 * u
    readonly property real mb: (root.configuration.PanelBottom > 0 ? root.configuration.PanelBottom + floatGap : 0) + 1.5 * u
    readonly property real sw: 7 * u
    readonly property real bh: 1.8 * u
    readonly property string corner: "square"

    readonly property color accent: "#D2001F"
    readonly property color gold: "#FFD200"
    readonly property color text: "#FFF6F0"
    readonly property color peach: "#F28C8C"
    readonly property color violet: "#7A1020"
    readonly property color lilac: "#E8B4B8"
    readonly property color blue: "#9A6A6E"
    readonly property color red: "#A00018"
    readonly property color green: "#3DDC84"
    readonly property color navy0: "#120A0B"
    readonly property color navy1: "#1E1011"
    readonly property color navy2: "#2A1517"
    readonly property color glow: role("orange")

    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
    function ink(c) { return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) > 0.52 ? navy0 : "#FFFFFF" }
    function role(name) {
        return ({ orange: accent, gold: gold, tan: text, peach: peach, violet: violet, lilac: lilac,
                  blue: blue, red: red, green: green, navy: navy0, panel: navy1, panel2: navy2 })[name] || accent
    }

    FontLoader { id: themeFont; source: Qt.resolvedUrl("../fonts/ArchivoNarrow-Variable.ttf") }
    readonly property string font: themeFont.status === FontLoader.Ready ? themeFont.font.family : "Archivo Narrow"

    property date now: new Date()
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Data {
        id: live
        enabled: root.configuration.ShowLiveData
    }

    component Label: Text {
        property real size: 2 * root.u
        font.family: root.font
        font.italic: false
        font.weight: Font.DemiBold
        font.pixelSize: size
        font.letterSpacing: size * 0.04
        textFormat: Text.PlainText
    }

    // Corner piece; x/y is the top-left of its box, flipX/flipY mirror it within it.
    component Elbow: Shape {
        id: e
        property real sw
        property real bh
        property real w
        property real h
        property real outerR
        property real innerR
        property color fill
        property bool flipX: false
        property bool flipY: false
        width: w
        height: h
        preferredRendererType: Shape.CurveRenderer
        function pt(px, py) { return (flipX ? w - px : px) + "," + (flipY ? h - py : py) }
        function arc(r, px, py) {
            // a quarter circle ending at (px, py); sweep flips with the mirroring
            return " A" + r + "," + r + " 0 0 " + ((flipX !== flipY) ? 0 : 1) + " " + pt(px, py)
        }
        ShapePath {
            strokeWidth: -1
            fillColor: e.fill
            PathSvg {
                path: {
                    const c = root.corner, R = e.outerR, r = e.innerR
                    let d = "M" + e.pt(0, e.h) + " L" + e.pt(0, R)
                    if (c === "round") d += e.arc(R, R, 0)
                    else if (c === "square") d += " L" + e.pt(0, 0) + " L" + e.pt(R, 0)
                    else d += " L" + e.pt(R, 0)
                    d += " L" + e.pt(e.w, 0) + " L" + e.pt(e.w, e.bh) + " L" + e.pt(e.sw + r, e.bh)
                    if (c === "round") {
                        // concave inner corner
                        d += " A" + r + "," + r + " 0 0 " + ((e.flipX !== e.flipY) ? 1 : 0) + " " + e.pt(e.sw, e.bh + r)
                    } else if (c === "square") d += " L" + e.pt(e.sw, e.bh) + " L" + e.pt(e.sw, e.bh + r)
                    else d += " L" + e.pt(e.sw, e.bh + r)
                    return d + " L" + e.pt(e.sw, e.h) + " Z"
                }
            }
        }
    }

    // ── Background ───────────────────────────────────────────────
    Shape {
        anchors.fill: parent
        ShapePath {
            strokeWidth: -1
            fillGradient: LinearGradient {
                x1: 0; y1: 0; x2: root.ww; y2: root.hh
                GradientStop { position: 0; color: root.navy1 }
                GradientStop { position: 0.55; color: root.navy0 }
                GradientStop { position: 1; color: "#0B0607" }
            }
            PathRectangle { width: root.ww; height: root.hh }
        }
    }

    // Texture: carbon weave, star field, grid or nothing
    Item {
        anchors.fill: parent
        clip: true
        visible: "grid" === "carbon"
        Image {
            readonly property real d: Math.hypot(root.ww, root.hh)
            width: d; height: d
            anchors.centerIn: parent
            rotation: 45
            fillMode: Image.Tile
            source: "carbon.svg"
            sourceSize: Qt.size(Math.max(2, Math.round(0.8 * root.u)), Math.max(2, Math.round(0.8 * root.u)))
            smooth: false
        }
    }
    Repeater {
        // a fixed pseudo-random star field, the same on every start
        model: "grid" === "stars" ? 260 : 0
        delegate: Rectangle {
            required property int index
            readonly property real r1: (Math.sin(index * 12.9898) * 43758.5453) % 1
            readonly property real r2: (Math.sin(index * 78.233) * 12345.6789) % 1
            readonly property real r3: (Math.sin(index * 3.7) * 9876.54321) % 1
            x: Math.abs(r1) * root.ww
            y: Math.abs(r2) * root.hh
            width: Math.max(1, (Math.abs(r3) * 0.22 + 0.06) * root.u)
            height: width
            radius: width / 2
            color: root.text
            opacity: 0.15 + Math.abs(r3) * 0.55
        }
    }
    Shape {
        anchors.fill: parent
        visible: "grid" === "grid"
        ShapePath {
            strokeColor: root.alpha(root.text, 0.035)
            strokeWidth: Math.max(1, 0.08 * root.u)
            fillColor: "transparent"
            PathSvg {
                path: {
                    let d = "", step = 4 * root.u
                    if (!(step > 0)) return d
                    for (let x = 0; x <= root.ww; x += step) d += "M" + x + ",0 V" + root.hh + " "
                    for (let y = 0; y <= root.hh; y += step) d += "M0," + y + " H" + root.ww + " "
                    return d
                }
            }
        }
    }

    // Soft glow
    Shape {
        readonly property real rx: root.ww * 0.45
        readonly property real ry: root.hh * 0.5
        x: root.ww * 0.62 - rx
        y: root.hh * 0.6 - ry
        width: 2 * rx
        height: 2 * rx
        transform: Scale { yScale: (root.hh * 0.5) / (root.ww * 0.45) }
        ShapePath {
            strokeWidth: -1
            fillGradient: RadialGradient {
                centerX: root.ww * 0.45; centerY: root.ww * 0.45; centerRadius: root.ww * 0.45
                focalX: centerX; focalY: centerY
                GradientStop { position: 0; color: root.alpha(root.glow, 0.18) }
                GradientStop { position: 1; color: root.alpha(root.glow, 0) }
            }
            PathRectangle { width: root.ww * 0.9; height: root.ww * 0.9 }
        }
    }

    // Diagonal stripes, rising to the right, fading in from the left
    Repeater {
        model: [[92, 9.0, "panel2", 0.9], [101.6, 5.2, "orange", 0.85], [107.4, 1.1, "tan", 0.9], [109.1, 2.4, "violet", 0.8], [112.2, 0.5, "peach", 0.35]]
        delegate: Shape {
            required property var modelData
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            readonly property real yl: modelData[0] * root.u
            readonly property real yr: yl - 44 * root.u
            readonly property real t: modelData[1] * root.u
            readonly property color c: root.role(modelData[2])
            ShapePath {
                strokeWidth: -1
                fillGradient: LinearGradient {
                    x1: root.ww * 0.2; y1: 0; x2: root.ww * 0.5; y2: 0
                    GradientStop { position: 0; color: root.alpha(c, 0) }
                    GradientStop { position: 1; color: root.alpha(c, modelData[3]) }
                }
                PathPolyline {
                    path: [Qt.point(0, yl), Qt.point(root.ww, yr), Qt.point(root.ww, yr + t), Qt.point(0, yl + t), Qt.point(0, yl)]
                }
            }
        }
    }

    // Optional fading chequered band along the bottom right
    Item {
        id: chequer
        anchors.fill: parent
        visible: true
        readonly property real sq: 1.6 * root.u
        readonly property int cols: visible ? Math.floor(root.ww * 0.42 / sq) : 0
        readonly property real x0: root.ww - cols * sq
        readonly property real y0: root.hh - 3 * sq - 1.5 * root.u
        Repeater {
            model: chequer.cols * 3
            delegate: Rectangle {
                required property int index
                readonly property int r: Math.floor(index / chequer.cols)
                readonly property int c: index % chequer.cols
                visible: (r + c) % 2 === 0
                x: chequer.x0 + c * chequer.sq
                y: chequer.y0 + r * chequer.sq
                width: chequer.sq
                height: chequer.sq
                color: root.text
                opacity: 0.16 * 0.5 * (1 - x / root.ww)
            }
        }
    }

    // ── Top right: elbow, progress bar and the readouts ──────────
    Elbow {
        x: root.ww - root.m - w
        y: root.mt
        sw: root.sw; bh: root.bh; w: 34 * root.u; h: 18 * root.u
        outerR: 4 * root.u; innerR: 1.6 * root.u
        fill: root.alpha(root.accent, 0.55)
        flipX: true
    }

    Rectangle {
        id: progressBar
        x: root.ww - root.m - 56 * root.u
        y: root.mt
        width: 20 * root.u
        height: root.bh
        radius: root.corner === "round" ? height / 2 : 0
        color: root.alpha(root.violet, live.progress >= 0 ? 0.22 : 0.5)
        Rectangle {
            visible: live.progress >= 0
            width: Math.max(parent.radius * 2, parent.width * Math.min(1, live.progress))
            height: parent.height
            radius: parent.radius
            color: root.alpha(root.violet, 0.65)
        }
    }
    Label {
        anchors { right: progressBar.left; rightMargin: 1.5 * root.u; baseline: progressBar.bottom; baselineOffset: -0.05 * root.bh }
        size: 2.6 * root.u
        text: "MVV"
        color: root.alpha(root.accent, 0.6)
    }
    Label {
        visible: live.progress >= 0 && live.progressLabel !== ""
        anchors { right: progressBar.right; top: progressBar.bottom; topMargin: 0.5 * root.u }
        size: 1.4 * root.u
        text: live.progressLabel
        color: root.alpha(root.lilac, 0.6)
    }

    Repeater {
        model: 12
        delegate: Rectangle {
            required property int index
            x: root.ww - root.m - 34 * root.u + index * 2.4 * root.u
            y: root.mt + root.bh + root.u
            width: 0.25 * root.u
            height: (index % 3 ? 1.2 : 2.2) * root.u
            color: root.alpha(root.accent, 0.35)
        }
    }

    readonly property var sectors: live.sectors(now)
    readonly property var sideColors: ["peach", "lilac", "blue"]
    readonly property var accentColors: ["orange", "gold", "tan"]
    readonly property var sideNames: ["NEXT", "LAST", "TABLE"]

    Repeater {
        model: 3
        delegate: Item {
            id: sector
            required property int index
            readonly property color c: root.role(root.sideColors[index])
            readonly property var info: (root.sectors && root.sectors[index]) || { title: "", value: "" }
            readonly property bool showData: root.configuration.ShowLiveData && (info.title !== "" || info.value !== "")
            x: 0; y: root.mt + 18.6 * root.u + index * 7.6 * root.u
            width: root.ww; height: 7 * root.u

            Rectangle {
                id: block
                x: root.ww - root.m - root.sw
                width: root.sw
                height: parent.height
                color: root.alpha(sector.c, 0.45)
                Label {
                    anchors { right: parent.right; bottom: parent.bottom; rightMargin: 0.6 * root.u; bottomMargin: 0.5 * root.u }
                    size: 1.5 * root.u
                    text: root.sideNames[sector.index]
                    color: root.alpha(root.ink(sector.c), 0.9)
                }
            }

            Rectangle {
                id: accent
                visible: sector.showData
                anchors { right: block.left; rightMargin: 0.8 * root.u; verticalCenter: block.verticalCenter }
                width: 0.4 * root.u
                height: block.height * 0.75
                radius: root.corner === "round" ? width / 2 : 0
                color: root.alpha(sector.info.live ? root.green : root.role(root.accentColors[sector.index]), 0.8)
            }
            Column {
                visible: sector.showData
                anchors { right: accent.left; rightMargin: 1.2 * root.u; verticalCenter: block.verticalCenter }
                spacing: 0.3 * root.u
                Label {
                    anchors.right: parent.right
                    size: 1.5 * root.u
                    text: sector.info.title
                    color: root.alpha(sector.c, 0.75)
                }
                Label {
                    anchors.right: parent.right
                    size: 2.7 * root.u
                    text: sector.info.value
                    color: root.alpha(sector.info.live ? root.green : root.text, 0.85)
                }
            }
        }
    }

    // ── Bottom left: elbow with bars and a label ─────────────────
    Elbow {
        x: root.m
        y: root.hh - root.mb - h
        sw: root.sw; bh: root.bh; w: 30 * root.u; h: 14 * root.u
        outerR: 3.5 * root.u; innerR: 1.4 * root.u
        fill: root.alpha(root.text, 0.45)
        flipY: true
    }
    Rectangle {
        x: root.m + 30.8 * root.u; y: root.hh - root.mb - root.bh
        width: 8 * root.u; height: root.bh
        radius: root.corner === "round" ? height / 2 : 0
        color: root.alpha(root.red, 0.45)
    }
    Rectangle {
        x: root.m + 39.6 * root.u; y: root.hh - root.mb - root.bh
        width: 24 * root.u; height: root.bh
        radius: root.corner === "round" ? height / 2 : 0
        color: root.alpha(root.gold, 0.35)
    }
    Label {
        x: root.m + 65 * root.u
        anchors { baseline: parent.top; baselineOffset: root.hh - root.mb - 0.05 * root.bh }
        size: 2.4 * root.u
        text: "MAASTRICHT · DE GEUSSELT"
        color: root.alpha(root.text, 0.5)
    }
}
