import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

// Panel button that opens the STARGATE audio overlay. Click it, or give the widget
// a keyboard shortcut (Configure → Keyboard Shortcuts), e.g. Meta+G.
PlasmoidItem {
    id: root

    property var overlay: null

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: compactRepresentation
    fullRepresentation: Item {}

    toolTipMainText: "STARGATE Audio"
    toolTipSubText: "Open the audio overlay"

    function toggleOverlay() {
        if (overlay) {
            overlay.close()
            return
        }
        const component = Qt.createComponent(Qt.resolvedUrl("Overlay.qml"))
        if (component.status !== Component.Ready) {
            console.warn("STARGATE Audio:", component.errorString())
            return
        }
        overlay = component.createObject(null, { standalone: false })
        overlay.finished.connect(() => {
            overlay.destroy()
            overlay = null
        })
    }

    // The widget's keyboard shortcut toggles "expanded"; open the overlay instead of a popup.
    onExpandedChanged: {
        if (expanded) {
            expanded = false
            toggleOverlay()
        }
    }

    compactRepresentation: MouseArea {
        id: button

        readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        readonly property real thickness: vertical ? width : height
        readonly property real h: Math.max(14, Math.round(thickness * 0.66))

        implicitWidth: vertical ? thickness : pill.width
        implicitHeight: vertical ? pill.height : thickness
        hoverEnabled: true
        onClicked: root.toggleOverlay()

        FontLoader { id: themeFont; source: "fonts/Rajdhani-SemiBold.ttf" }

        Rectangle {
            id: pill
            anchors.centerIn: parent
            width: button.vertical ? button.thickness * 0.9 : label.implicitWidth + button.h * 1.2
            height: button.h
            radius: false ? height / 2 : 0
            color: root.overlay ? "#FFD27A" : (button.containsMouse ? Qt.lighter("#F2A33A", 1.15) : "#F2A33A")
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                id: label
                anchors.centerIn: parent
                text: button.vertical ? "AUD" : "AUDIO"
                color: root.overlay || false ? "#071018" : "white"
                font.family: themeFont.status === FontLoader.Ready ? themeFont.font.family : "Rajdhani"
                font.italic: false
                font.weight: Font.DemiBold
                font.pixelSize: button.h * 0.7
            }
        }
    }
}
