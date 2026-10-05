import QtQuick
import "."

// One FEYENOORD row: coloured sidebar block with a label, content to its right.
Item {
    id: s

    property string label
    property string sublabel  // plain name under the themed one, e.g. "CPU"
    property string code
    property color color: Feyenoord.orange
    property real u: 8
    property real sidebarWidth: 60
    default property alias content: holder.data

    Rectangle {
        width: s.sidebarWidth
        height: s.height
        color: s.color
        LText {
            id: codeText
            anchors { right: parent.right; top: parent.top; margins: 0.6 * s.u }
            text: s.code
            color: Feyenoord.ink(s.color)
            font.pixelSize: 1.4 * s.u
        }
        LText {
            id: subText
            anchors { right: parent.right; top: codeText.bottom; rightMargin: 0.6 * s.u; topMargin: 0.3 * s.u }
            visible: s.sublabel !== ""
            text: s.sublabel
            color: Feyenoord.ink(s.color)
            opacity: 0.7
            font.pixelSize: 1.4 * s.u
        }
        // The themed name. If two lines give a bigger font than one, split it at the space
        // that balances the lines best. Then shrink it to fit the block.
        TextMetrics {
            id: labelMetrics
            font.family: Feyenoord.font
            font.weight: Font.Medium
            font.pixelSize: 2.6 * s.u
            text: s.label.toUpperCase()
        }
        LText {
            id: labelText
            readonly property real room: s.sidebarWidth - 1.2 * s.u
            // Font size each way, roughly: one line is limited by the width, two lines also by the height.
            readonly property real full: 2.6 * s.u
            readonly property real oneLine: Math.min(full, full * room / labelMetrics.advanceWidth, height)
            readonly property real twoLines: Math.min(full, full * room / (labelMetrics.advanceWidth * widest / s.label.length), height / 2)
            readonly property int widest: {
                const words = s.label.split(" ")
                let w = s.label.length
                for (let i = 1; i < words.length; i++)
                    w = Math.min(w, Math.max(words.slice(0, i).join(" ").length, words.slice(i).join(" ").length))
                return w
            }
            readonly property bool split: s.label.indexOf(" ") > 0 && twoLines > oneLine * 1.1
            readonly property string lines: {
                if (!split)
                    return s.label
                const words = s.label.split(" ")
                let best = s.label, worst = Infinity
                for (let i = 1; i < words.length; i++) {
                    const a = words.slice(0, i).join(" "), b = words.slice(i).join(" ")
                    const w = Math.max(a.length, b.length)
                    if (w < worst) { worst = w; best = a + "\n" + b }
                }
                return best
            }
            anchors {
                right: parent.right; bottom: parent.bottom
                top: s.sublabel !== "" ? subText.bottom : codeText.bottom
                rightMargin: 0.6 * s.u; topMargin: 0.4 * s.u; bottomMargin: 0.2 * s.u
            }
            width: room
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
            fontSizeMode: Text.Fit
            minimumPixelSize: 0.9 * s.u
            text: lines
            color: Feyenoord.ink(s.color)
            font.pixelSize: 2.6 * s.u
        }
    }

    Item {
        id: holder
        x: s.sidebarWidth + 2 * s.u
        y: 0.4 * s.u
        width: s.width - x
        height: s.height - 0.8 * s.u
    }
}
