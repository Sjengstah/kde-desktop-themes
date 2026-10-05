import QtQuick

// LCARS boot screen. ksplash raises `stage` from 1 to 6 while Plasma starts.
Rectangle {
    id: root

    property int stage

    readonly property real u: Math.min(width / 160, height / 90)
    readonly property var messages: [
        "ESTABLISHING LINK",
        "INITIALIZING COMPUTER CORE",
        "LOADING LCARS INTERFACE",
        "SYNCHRONIZING SUBSYSTEMS",
        "CALIBRATING SENSOR ARRAYS",
        "ALL SYSTEMS NOMINAL"
    ]
    readonly property int segments: 36

    color: "black"

    FontLoader { id: antonio; source: "fonts/Antonio.ttf" }
    readonly property string font: antonio.status === FontLoader.Ready ? antonio.font.family : "sans-serif"

    component LText: Text {
        font.family: root.font
        font.weight: Font.DemiBold
        color: "#FFCC99"
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
                c.fillStyle = "#FF9900"
                c.beginPath()
                c.moveTo(0, height); c.lineTo(0, R); c.arcTo(0, 0, R, 0, R)
                c.lineTo(width, 0); c.lineTo(width, bh); c.lineTo(sw + r, bh)
                c.arcTo(sw, bh, sw, bh + r, r); c.lineTo(sw, height)
                c.closePath(); c.fill()
            }
        }
        Row {
            x: elbow.width + 0.8 * root.u
            spacing: 0.8 * root.u
            Rectangle { width: 30 * root.u; height: 3 * root.u; color: "#CC99CC" }
            Rectangle { width: 12 * root.u; height: 3 * root.u; color: "#FF9966" }
            Rectangle { width: 20.6 * root.u; height: 3 * root.u; color: "#9999FF"; radius: height / 2 }
        }

        // Sidebar blocks
        Column {
            y: elbow.height + 0.8 * root.u
            spacing: 0.8 * root.u
            Repeater {
                model: [["#9999FF", 8, "02-47"], ["#FF9966", 11, "03-1701"], ["#6699CC", 7.2, "04-09"]]
                Rectangle {
                    required property var modelData
                    width: 12 * root.u
                    height: modelData[1] * root.u
                    color: modelData[0]
                    LText {
                        anchors { right: parent.right; bottom: parent.bottom; margins: 0.6 * root.u }
                        text: parent.modelData[2]
                        color: "black"
                        font.pixelSize: 1.8 * root.u
                    }
                }
            }
        }

        LText {
            x: 15 * root.u
            y: 5 * root.u
            text: "LCARS"
            color: "#FF9900"
            font.pixelSize: 14 * root.u
            font.letterSpacing: 0.6 * root.u
        }
        LText {
            x: 15.6 * root.u
            y: 23 * root.u
            text: "LIBRARY COMPUTER ACCESS AND RETRIEVAL SYSTEM"
            font.pixelSize: 2.4 * root.u
            opacity: 0.8
        }

        LText {
            id: message
            x: 15.6 * root.u
            y: 29 * root.u
            text: root.messages[Math.max(0, Math.min(root.messages.length, root.stage) - 1)]
            color: root.stage >= 6 ? "#9999FF" : "#FFCC66"
            font.pixelSize: 3 * root.u

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.stage < 6
                NumberAnimation { to: 0.35; duration: 500 }
                NumberAnimation { to: 1; duration: 500 }
            }
        }

        // Segmented progress bar
        Row {
            x: 15.6 * root.u
            y: 35 * root.u
            spacing: 0.4 * root.u
            Repeater {
                model: root.segments
                Rectangle {
                    required property int index
                    width: (80 * root.u - root.segments * 0.4 * root.u) / root.segments
                    height: 2 * root.u
                    color: index < Math.round(root.stage / 6 * root.segments) ? "#FF9900" : "#2a1f10"
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
            }
        }

        // Bottom bar
        Row {
            x: 15.6 * root.u
            y: 41 * root.u
            spacing: 0.8 * root.u
            Rectangle { width: 8 * root.u; height: 1.6 * root.u; color: "#CC6666" }
            Rectangle { width: 50 * root.u; height: 1.6 * root.u; color: "#FFCC66" }
            Rectangle { width: 1.6 * root.u; height: 1.6 * root.u; color: "#FFCC99"; radius: height / 2 }
        }
    }
}
