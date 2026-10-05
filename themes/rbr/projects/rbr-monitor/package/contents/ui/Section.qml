import QtQuick
import "."

// One RBR row: coloured sidebar block with a label, content to its right.
Item {
    id: s

    property string label
    property string sublabel  // plain name under the F1 one, e.g. "CPU" for ENGINE
    property string code
    property color color: Rbr.orange
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
            color: Rbr.ink(s.color)
            font.pixelSize: 1.4 * s.u
        }
        LText {
            anchors { right: parent.right; top: codeText.bottom; rightMargin: 0.6 * s.u; topMargin: 0.3 * s.u }
            visible: s.sublabel !== ""
            text: s.sublabel
            color: Rbr.ink(s.color)
            opacity: 0.7
            font.pixelSize: 1.4 * s.u
        }
        LText {
            anchors { right: parent.right; bottom: parent.bottom; margins: 0.6 * s.u; bottomMargin: 0.2 * s.u }
            width: s.sidebarWidth - 1.2 * s.u
            horizontalAlignment: Text.AlignRight
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: 1.6 * s.u
            text: s.label
            color: Rbr.ink(s.color)
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
