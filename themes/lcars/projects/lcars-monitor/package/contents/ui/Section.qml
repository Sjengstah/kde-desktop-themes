import QtQuick
import "."

// One LCARS row: coloured sidebar block with a label, content to its right.
Item {
    id: s

    property string label
    property string code
    property color color: Lcars.orange
    property real u: 8
    property real sidebarWidth: 60
    default property alias content: holder.data

    Rectangle {
        width: s.sidebarWidth
        height: s.height
        color: s.color
        LText {
            anchors { right: parent.right; top: parent.top; margins: 0.6 * s.u }
            text: s.code
            color: "black"
            font.pixelSize: 1.4 * s.u
        }
        LText {
            anchors { right: parent.right; bottom: parent.bottom; margins: 0.6 * s.u; bottomMargin: 0.2 * s.u }
            text: s.label
            color: "black"
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
