import QtQuick
import "."

// One panel readout: coloured RBR cap with a label, the value, and a level meter.
Item {
    id: p

    property string label
    property string value
    property string widest: "100%"
    property real fraction: 0
    property color color: Rbr.orange
    property bool vertical: false
    property real thickness: 32

    readonly property real h: Math.max(12, Math.round(thickness * 0.66))
    readonly property color meterColor: fraction >= 0.9 ? Rbr.alert : color

    TextMetrics {
        id: widestMetrics
        font.family: Rbr.font
        font.italic: true
        font.weight: Font.Medium
        font.pixelSize: p.h * 0.82
        text: p.widest
    }

    implicitWidth: vertical ? thickness : cap.width + valueText.width + meter.width + h * 0.5
    implicitHeight: vertical ? vCol.implicitHeight : h

    // ── Horizontal panel ──
    Item {
        visible: !p.vertical
        anchors.fill: parent

        Item {
            id: cap
            width: p.h * 1.7
            height: p.h
            // Slanted leading edge, like an F1 timing-tower tab.
            Canvas {
                anchors.fill: parent
                property color fill: p.color
                onFillChanged: requestPaint()
                onWidthChanged: requestPaint()
                onPaint: {
                    const c = getContext("2d")
                    c.reset()
                    c.fillStyle = fill
                    c.beginPath()
                    c.moveTo(height * 0.45, 0); c.lineTo(width, 0); c.lineTo(width, height); c.lineTo(0, height)
                    c.closePath(); c.fill()
                }
            }
            LText {
                anchors { right: parent.right; rightMargin: p.h * 0.18; verticalCenter: parent.verticalCenter }
                text: p.label
                color: Rbr.ink(p.color)
                font.pixelSize: p.h * 0.66
            }
        }
        LText {
            id: valueText
            x: cap.width + p.h * 0.25
            width: widestMetrics.advanceWidth
            height: p.h
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            text: p.value
            color: p.color
            font.pixelSize: p.h * 0.82
        }
        Rectangle {
            id: meter
            x: valueText.x + valueText.width + p.h * 0.25
            width: Math.max(3, p.h * 0.2)
            height: p.h
            color: Rbr.dim(p.color)
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Math.min(1, Math.max(0, p.fraction)) * parent.height
                color: p.meterColor
                Behavior on height { NumberAnimation { duration: 200 } }
            }
        }
    }

    // ── Vertical panel ──
    Column {
        id: vCol
        visible: p.vertical
        width: p.thickness
        spacing: 2

        Rectangle {
            width: parent.width
            height: Math.max(12, p.thickness * 0.38)
            color: p.color
            topLeftRadius: 0
            topRightRadius: 0
            LText {
                anchors.centerIn: parent
                text: p.label
                color: Rbr.ink(p.color)
                font.pixelSize: parent.height * 0.72
            }
        }
        LText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: p.value
            color: p.color
            font.pixelSize: Math.max(10, p.thickness * 0.34)
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: 8
        }
        Rectangle {
            width: parent.width
            height: Math.max(3, p.thickness * 0.08)
            color: Rbr.dim(p.color)
            Rectangle {
                width: Math.min(1, Math.max(0, p.fraction)) * parent.width
                height: parent.height
                color: p.meterColor
                Behavior on width { NumberAnimation { duration: 200 } }
            }
        }
    }
}
