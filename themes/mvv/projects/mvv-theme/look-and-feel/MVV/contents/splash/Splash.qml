import QtQuick

// MVV boot screen. ksplash raises `stage` from 1 to 6 while Plasma starts.
Rectangle {
    id: root

    property int stage

    readonly property real u: Math.min(width / 160, height / 90)
    readonly property var messages: ["GATES OPEN", "WARMING UP", "TEAM SHEET IN", "WALKING OUT", "THE GEUSSELT ROARS", "KICK-OFF"]
    readonly property string corner: "square"
    // Stage indicators: one lights up per stage (start lights, chevrons, ...).
    readonly property int lights: 5
    readonly property bool lightsOutAtEnd: false

    color: "#120A0B"

    FontLoader { id: themeFont; source: "fonts/ArchivoNarrow-Variable.ttf" }
    readonly property string font: themeFont.status === FontLoader.Ready ? themeFont.font.family : "Archivo Narrow"

    component LText: Text {
        font.family: root.font
        font.italic: false
        font.weight: Font.DemiBold
        color: "#FFF6F0"
    }

    Item {
        id: panel
        width: 96 * root.u
        height: 44 * root.u
        anchors.centerIn: parent
        opacity: 0

        OpacityAnimator on opacity { from: 0; to: 1; duration: 600; running: true }

        // Top elbow and bar
        Canvas {
            id: elbow
            width: 30 * root.u
            height: 16 * root.u
            onPaint: {
                const c = getContext("2d"), u = root.u
                const sw = 12 * u, bh = 3 * u, R = 6 * u, r = 2.2 * u
                c.reset()
                c.fillStyle = "#D2001F"
                c.beginPath()
                c.moveTo(0, height); c.lineTo(0, R)
                if (root.corner === "round") c.arcTo(0, 0, R, 0, R)
                else if (root.corner === "square") { c.lineTo(0, 0); c.lineTo(R, 0) }
                else c.lineTo(R, 0)
                c.lineTo(width, 0); c.lineTo(width, bh); c.lineTo(sw + r, bh)
                if (root.corner === "round") c.arcTo(sw, bh, sw, bh + r, r)
                else if (root.corner === "square") { c.lineTo(sw, bh); c.lineTo(sw, bh + r) }
                else c.lineTo(sw, bh + r)
                c.lineTo(sw, height)
                c.closePath(); c.fill()
            }
        }
        Row {
            x: elbow.width + 0.8 * root.u
            spacing: 0.8 * root.u
            Rectangle { width: 30 * root.u; height: 3 * root.u; color: "#7A1020"; radius: root.corner === "round" ? height / 2 : 0 }
            Rectangle { width: 12 * root.u; height: 3 * root.u; color: "#F28C8C"; radius: root.corner === "round" ? height / 2 : 0 }
            Rectangle { width: 20.6 * root.u; height: 3 * root.u; color: "#E8B4B8"; radius: root.corner === "round" ? height / 2 : 0 }
        }

        // Sidebar blocks
        Column {
            y: elbow.height + 0.8 * root.u
            spacing: 0.8 * root.u
            Repeater {
                // [colour, height, label, text colour]
                model: [["#E8B4B8", 8, "GK", "#120A0B"], ["#F28C8C", 11, "DEF", "#120A0B"], ["#9A6A6E", 7.2, "FWD", "#FFFFFF"]]
                Rectangle {
                    required property var modelData
                    width: 12 * root.u
                    height: modelData[1] * root.u
                    color: modelData[0]
                    LText {
                        anchors { right: parent.right; bottom: parent.bottom; margins: 0.6 * root.u }
                        text: parent.modelData[2]
                        color: parent.modelData[3]
                        font.pixelSize: 1.8 * root.u
                    }
                }
            }
        }

        LText {
            x: 15 * root.u
            y: 5 * root.u
            text: "MVV"
            color: "#D2001F"
            font.pixelSize: 14 * root.u
            font.letterSpacing: 0.6 * root.u
        }
        LText {
            x: 15.6 * root.u
            y: 23 * root.u
            text: "MAASTRICHT · DE GEUSSELT"
            font.pixelSize: 2.4 * root.u
            opacity: 0.8
        }

        LText {
            id: message
            x: 15.6 * root.u
            y: 29 * root.u
            text: root.messages[Math.max(0, Math.min(root.messages.length, root.stage) - 1)]
            color: root.stage >= 6 ? "#E8B4B8" : "#FFD200"
            font.pixelSize: 3 * root.u

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.stage < 6
                NumberAnimation { to: 0.35; duration: 500 }
                NumberAnimation { to: 1; duration: 500 }
            }
        }

        // Stage indicators: they light up one by one as Plasma loads.
        Row {
            x: 15.6 * root.u
            y: 33.4 * root.u
            spacing: 1.2 * root.u
            Repeater {
                model: root.lights
                Rectangle {
                    required property int index
                    // spread the indicators over stages 1-5; optionally all off at the end
                    readonly property bool lit: root.stage > Math.floor(index * 5 / root.lights)
                                                && !(root.lightsOutAtEnd && root.stage >= 6)
                    width: 6 * root.u * Math.min(1, 5 / root.lights)
                    height: width
                    radius: root.corner === "round" ? width / 2 : 0
                    color: "#1E1011"
                    border.color: "#381C1E"
                    border.width: Math.max(1, 0.2 * root.u)
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.7
                        height: width
                        radius: width / 2
                        color: parent.lit ? "#D2001F" : "#381C1E"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }
            }
        }

        // Bottom bar
        Row {
            x: 15.6 * root.u
            y: 41 * root.u
            spacing: 0.8 * root.u
            Rectangle { width: 8 * root.u; height: 1.6 * root.u; color: "#A00018"; radius: root.corner === "round" ? height / 2 : 0 }
            Rectangle { width: 50 * root.u; height: 1.6 * root.u; color: "#FFD200"; radius: root.corner === "round" ? height / 2 : 0 }
            Rectangle { width: 1.6 * root.u; height: 1.6 * root.u; color: "#FFF6F0"; radius: root.corner === "round" ? height / 2 : 0 }
        }
    }
}
