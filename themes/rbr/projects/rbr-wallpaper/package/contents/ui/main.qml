import QtQuick
import QtQuick.Shapes
import org.kde.plasma.plasmoid

// RBR Live: the RBR wallpaper (same layout as rbr-theme/wallpapers/make-wallpaper.py)
// drawn in QML, with live F1 season data next to the three sector blocks.
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

    readonly property color red: "#DB0A40"
    readonly property color yellow: "#FFC906"
    readonly property color white: "#E8EDF7"
    readonly property color silver: "#A9B4CC"
    readonly property color blue: "#3671C6"
    readonly property color light: "#8FAEF5"
    readonly property color steel: "#6C7FA8"
    readonly property color coral: "#FF5A5F"
    readonly property color navy0: "#050A1E"
    readonly property color navy1: "#0B1433"
    readonly property color navy2: "#121E45"
    // F1 timing-screen colours for the sector readouts
    readonly property color purple: "#B05CFF"
    readonly property color green: "#2FD36B"

    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    FontLoader { id: barlow; source: Qt.resolvedUrl("../fonts/BarlowCondensed-SemiBoldItalic.ttf") }
    readonly property string font: barlow.status === FontLoader.Ready ? barlow.font.family : "Barlow Condensed"

    property date now: new Date()
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    F1Data {
        id: f1
        enabled: root.configuration.ShowF1Data
    }

    component Label: Text {
        property real size: 2 * root.u
        font.family: root.font
        font.italic: true
        font.weight: Font.DemiBold
        font.pixelSize: size
        font.letterSpacing: size * 0.04
        textFormat: Text.PlainText
    }

    // Corner piece with a 45° cut outer corner and a chamfered inner corner.
    // x/y is the top-left of its box; flipX/flipY mirror it within that box.
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
        ShapePath {
            strokeWidth: -1
            fillColor: e.fill
            PathSvg {
                path: "M" + e.pt(0, e.h) + " L" + e.pt(0, e.outerR) + " L" + e.pt(e.outerR, 0) + " L" + e.pt(e.w, 0)
                      + " L" + e.pt(e.w, e.bh) + " L" + e.pt(e.sw + e.innerR, e.bh) + " L" + e.pt(e.sw, e.bh + e.innerR)
                      + " L" + e.pt(e.sw, e.h) + " Z"
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
                GradientStop { position: 1; color: "#03061A" }
            }
            PathRectangle { width: root.ww; height: root.hh }
        }
    }

    // Carbon weave
    Item {
        anchors.fill: parent
        clip: true
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

    // Soft blue glow
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
                GradientStop { position: 0; color: root.alpha(root.blue, 0.18) }
                GradientStop { position: 1; color: root.alpha(root.blue, 0) }
            }
            PathRectangle { width: root.ww * 0.9; height: root.ww * 0.9 }
        }
    }

    // Speed stripes, rising to the right, fading in from the left
    Repeater {
        model: [
            { y: 92, t: 9.0, c: root.navy2, o: 0.9 },
            { y: 101.6, t: 5.2, c: root.red, o: 0.85 },
            { y: 107.4, t: 1.1, c: root.yellow, o: 0.9 },
            { y: 109.1, t: 2.4, c: root.blue, o: 0.6 },
            { y: 112.2, t: 0.5, c: root.silver, o: 0.35 }
        ]
        delegate: Shape {
            required property var modelData
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            readonly property real yl: modelData.y * root.u
            readonly property real yr: yl - 42 * root.u
            readonly property real t: modelData.t * root.u
            ShapePath {
                strokeWidth: -1
                fillGradient: LinearGradient {
                    x1: root.ww * 0.2; y1: 0; x2: root.ww * 0.5; y2: 0
                    GradientStop { position: 0; color: root.alpha(modelData.c, 0) }
                    GradientStop { position: 1; color: root.alpha(modelData.c, modelData.o) }
                }
                PathPolyline {
                    path: [Qt.point(0, yl), Qt.point(root.ww, yr), Qt.point(root.ww, yr + t), Qt.point(0, yl + t), Qt.point(0, yl)]
                }
            }
        }
    }

    // Fading chequered band along the bottom right
    Item {
        id: chequer
        anchors.fill: parent
        readonly property real sq: 1.6 * root.u
        readonly property int cols: Math.floor(root.ww * 0.42 / sq)
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
                color: root.white
                opacity: 0.16 * 0.5 * (1 - x / root.ww)
            }
        }
    }

    // ── Top right: elbow, season bar and the sector readouts ─────
    Elbow {
        x: root.ww - root.m - w
        y: root.mt
        sw: root.sw; bh: root.bh; w: 34 * root.u; h: 18 * root.u
        outerR: 4 * root.u; innerR: 1.6 * root.u
        fill: root.alpha(root.red, 0.55)
        flipX: true
    }

    // Season progress: the blue bar fills one step per completed round.
    Rectangle {
        id: seasonBar
        x: root.ww - root.m - 56 * root.u
        y: root.mt
        width: 20 * root.u
        height: root.bh
        color: root.alpha(root.blue, f1.races.length ? 0.22 : 0.5)
        Rectangle {
            visible: f1.races.length > 0
            width: parent.width * Math.min(1, f1.round / Math.max(1, f1.races.length))
            height: parent.height
            color: root.alpha(root.blue, 0.65)
        }
    }
    Label {
        anchors { right: seasonBar.left; rightMargin: 1.5 * root.u; baseline: seasonBar.bottom; baselineOffset: -0.05 * root.bh }
        size: 2.6 * root.u
        text: "RBR 01"
        color: root.alpha(root.red, 0.6)
    }
    Label {
        visible: f1.races.length > 0
        anchors { right: seasonBar.right; top: seasonBar.bottom; topMargin: 0.5 * root.u }
        size: 1.4 * root.u
        text: "ROUND " + f1.round + " / " + f1.races.length
        color: root.alpha(root.light, 0.6)
    }

    Repeater {
        model: 12
        delegate: Rectangle {
            required property int index
            x: root.ww - root.m - 34 * root.u + index * 2.4 * root.u
            y: root.mt + root.bh + root.u
            width: 0.25 * root.u
            height: (index % 3 ? 1.2 : 2.2) * root.u
            color: root.alpha(root.red, 0.35)
        }
    }

    readonly property var race: f1.nextRace(now)
    readonly property var session: f1.nextSession(race, now)

    readonly property var sectors: {
        const s = [], lastRace = f1.last, st = f1.standings
        if (!f1.loaded) {
            s.push({ title: "NO SIGNAL", value: "WAITING FOR TIMING DATA" })
            s.push({ title: "", value: "" })
            s.push({ title: "", value: "" })
            return s
        }
        if (race && session)
            s.push({ title: "NEXT · R" + race.round + " " + f1.shortName(race),
                     value: session.live ? session.name + " LIVE" : session.name + " IN " + f1.countdown(session.start, now),
                     live: session.live })
        else
            s.push({ title: "SEASON COMPLETE", value: "SEE YOU NEXT YEAR" })

        if (lastRace && lastRace.Results)
            s.push({ title: "LAST · R" + lastRace.round + " " + f1.shortName(lastRace),
                     value: lastRace.Results.slice(0, 3).map((r, i) => "P" + (i + 1) + " " + f1.code(r.Driver)).join("   ") })
        else
            s.push({ title: "LAST RACE", value: "NONE YET" })

        if (st.length)
            s.push({ title: "CHAMPIONSHIP · AFTER R" + f1.round,
                     value: st.slice(0, 3).map(d => f1.code(d.Driver) + " " + d.points).join("   ") })
        else
            s.push({ title: "CHAMPIONSHIP", value: "NO POINTS YET" })
        return s
    }

    Repeater {
        model: [
            { c: root.silver, ink: root.navy0, accent: root.purple },
            { c: root.light, ink: root.navy0, accent: root.green },
            { c: root.steel, ink: "#ffffff", accent: root.yellow }
        ]
        delegate: Item {
            id: sector
            required property var modelData
            required property int index
            readonly property var info: root.sectors[index] || { title: "", value: "" }
            readonly property bool showData: root.configuration.ShowF1Data && (info.title !== "" || info.value !== "")
            x: 0; y: root.mt + 18.6 * root.u + index * 7.6 * root.u
            width: root.ww; height: 7 * root.u

            Rectangle {
                id: block
                x: root.ww - root.m - root.sw
                width: root.sw
                height: parent.height
                color: root.alpha(sector.modelData.c, 0.45)
                Label {
                    anchors { right: parent.right; bottom: parent.bottom; rightMargin: 0.6 * root.u; bottomMargin: 0.5 * root.u }
                    size: 1.5 * root.u
                    text: "SECTOR " + (sector.index + 1)
                    color: root.alpha(sector.modelData.ink, 0.9)
                }
            }

            Rectangle {
                id: accent
                visible: sector.showData
                anchors { right: block.left; rightMargin: 0.8 * root.u; verticalCenter: block.verticalCenter }
                width: 0.4 * root.u
                height: block.height * 0.75
                color: root.alpha(sector.info.live ? root.green : sector.modelData.accent, 0.8)
            }
            Column {
                visible: sector.showData
                anchors { right: accent.left; rightMargin: 1.2 * root.u; verticalCenter: block.verticalCenter }
                spacing: 0.3 * root.u
                Label {
                    anchors.right: parent.right
                    size: 1.5 * root.u
                    text: sector.info.title
                    color: root.alpha(sector.modelData.c, 0.75)
                }
                Label {
                    anchors.right: parent.right
                    size: 2.7 * root.u
                    text: sector.info.value
                    color: root.alpha(sector.info.live ? root.green : root.white, 0.85)
                }
            }
        }
    }

    // ── Bottom left: elbow with bars and the race-operations label ──
    Elbow {
        x: root.m
        y: root.hh - root.mb - h
        sw: root.sw; bh: root.bh; w: 30 * root.u; h: 14 * root.u
        outerR: 3.5 * root.u; innerR: 1.4 * root.u
        fill: root.alpha(root.white, 0.45)
        flipY: true
    }
    Rectangle {
        x: root.m + 30.8 * root.u; y: root.hh - root.mb - root.bh
        width: 8 * root.u; height: root.bh
        color: root.alpha(root.coral, 0.45)
    }
    Rectangle {
        x: root.m + 39.6 * root.u; y: root.hh - root.mb - root.bh
        width: 24 * root.u; height: root.bh
        color: root.alpha(root.yellow, 0.35)
    }
    Label {
        x: root.m + 65 * root.u
        anchors { baseline: parent.top; baselineOffset: root.hh - root.mb - 0.05 * root.bh }
        size: 2.4 * root.u
        text: "PIT WALL · RACE OPERATIONS"
        color: root.alpha(root.white, 0.5)
    }
}
