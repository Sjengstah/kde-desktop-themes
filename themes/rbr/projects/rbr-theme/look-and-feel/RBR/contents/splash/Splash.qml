import QtQuick

// RBR boot screen. ksplash raises `stage` from 1 to 6 while Plasma starts.
Rectangle {
    id: root

    property int stage

    readonly property real u: Math.min(width / 160, height / 90)
    readonly property var messages: [
        "PIT LANE OPEN",
        "FIRING UP THE POWER UNIT",
        "LOADING RBR TELEMETRY",
        "SYNCING WITH THE PIT WALL",
        "FORMATION LAP",
        "LIGHTS OUT AND AWAY WE GO"
    ]

    color: "#050A1E"

    FontLoader { id: barlow; source: "fonts/BarlowCondensed-SemiBoldItalic.ttf" }
    readonly property string font: barlow.status === FontLoader.Ready ? barlow.font.family : "sans-serif"

    component LText: Text {
        font.family: root.font
        font.italic: true
        font.weight: Font.DemiBold
        color: "#E8EDF7"
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
                c.fillStyle = "#DB0A40"
                c.beginPath()
                c.moveTo(0, height); c.lineTo(0, R); c.lineTo(R, 0)
                c.lineTo(width, 0); c.lineTo(width, bh); c.lineTo(sw + r, bh)
                c.lineTo(sw, bh + r); c.lineTo(sw, height)
                c.closePath(); c.fill()
            }
        }
        Row {
            x: elbow.width + 0.8 * root.u
            spacing: 0.8 * root.u
            Rectangle { width: 30 * root.u; height: 3 * root.u; color: "#3671C6" }
            Rectangle { width: 12 * root.u; height: 3 * root.u; color: "#A9B4CC" }
            Rectangle { width: 20.6 * root.u; height: 3 * root.u; color: "#8FAEF5" }
        }

        // Sidebar blocks
        Column {
            y: elbow.height + 0.8 * root.u
            spacing: 0.8 * root.u
            Repeater {
                // [colour, height, label, text colour]: the three sectors of a lap
                model: [["#8FAEF5", 8, "S1", "#050A1E"], ["#A9B4CC", 11, "S2", "#050A1E"], ["#6C7FA8", 7.2, "S3", "#FFFFFF"]]
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
            text: "RBR"
            color: "#DB0A40"
            font.pixelSize: 14 * root.u
            font.letterSpacing: 0.6 * root.u
        }
        LText {
            x: 15.6 * root.u
            y: 23 * root.u
            text: "RACE OPERATIONS · LIVE TELEMETRY"
            font.pixelSize: 2.4 * root.u
            opacity: 0.8
        }

        LText {
            id: message
            x: 15.6 * root.u
            y: 29 * root.u
            text: root.messages[Math.max(0, Math.min(root.messages.length, root.stage) - 1)]
            color: root.stage >= 6 ? "#8FAEF5" : "#FFC906"
            font.pixelSize: 3 * root.u

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.stage < 6
                NumberAnimation { to: 0.35; duration: 500 }
                NumberAnimation { to: 1; duration: 500 }
            }
        }

        // Start lights: one more red light per stage, all out on the last one.
        Row {
            x: 15.6 * root.u
            y: 33.4 * root.u
            spacing: 1.2 * root.u
            Repeater {
                model: 5
                Rectangle {
                    required property int index
                    readonly property bool lit: root.stage > index && root.stage < 6
                    width: 6 * root.u
                    height: 6 * root.u
                    color: "#0B1433"
                    border.color: "#1A2A5C"
                    border.width: Math.max(1, 0.2 * root.u)
                    Rectangle {
                        anchors.centerIn: parent
                        width: 4.2 * root.u
                        height: width
                        radius: width / 2
                        color: parent.lit ? "#FF1A1A" : "#1A2A5C"
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
            Rectangle { width: 8 * root.u; height: 1.6 * root.u; color: "#FF5A5F" }
            Rectangle { width: 50 * root.u; height: 1.6 * root.u; color: "#FFC906" }
            Rectangle { width: 1.6 * root.u; height: 1.6 * root.u; color: "#E8EDF7" }
        }
    }
}
