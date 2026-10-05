import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.batterymonitor
import "."

// ORANJE Control Center. Give it a hotkey in Configure → Keyboard Shortcuts.
PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground | PlasmaCore.Types.ConfigurableBackground
    Plasmoid.icon: "preferences-system"
    switchWidth: Oranje.u * 50
    switchHeight: Oranje.u * 40

    toolTipMainText: "ORANJE Control Center"
    toolTipSubText: (inhibition.isManuallyInhibited ? "Caffeine on · " : "") + "Wi-Fi, Bluetooth, power plan and more"

    // Only what the panel button needs; the popup has its own backends.
    InhibitionControl { id: inhibition }
    FocusMode { id: focusMode }
    readonly property bool dndOn: focusMode.active

    compactRepresentation: MouseArea {
        id: button

        readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        readonly property real thickness: vertical ? width : height
        readonly property real h: Math.max(14, Math.round(thickness * 0.66))

        implicitWidth: vertical ? thickness : pill.width + 2
        implicitHeight: vertical ? pill.height + 2 : thickness
        Layout.minimumWidth: vertical ? -1 : implicitWidth
        Layout.preferredWidth: vertical ? -1 : implicitWidth
        Layout.minimumHeight: vertical ? implicitHeight : -1
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded

        Rectangle {
            id: pill
            anchors.centerIn: parent
            width: button.vertical ? button.thickness * 0.9 : label.implicitWidth + dots.width + button.h * 1.3
            height: button.h
            radius: Oranje.round ? height / 2 : 0
            color: root.expanded ? Oranje.gold : (button.containsMouse ? Qt.lighter(Oranje.orange, 1.15) : Oranje.orange)
            Behavior on color { ColorAnimation { duration: 120 } }

            LText {
                id: label
                x: button.h * 0.55
                anchors.verticalCenter: parent.verticalCenter
                text: button.vertical ? "CTL" : "CONTROL"
                color: Oranje.ink(pill.color)
                font.pixelSize: button.h * 0.7
            }
            // Status lights: gold = caffeine on, red = Do Not Disturb.
            Row {
                id: dots
                anchors { left: label.right; leftMargin: button.h * 0.25; verticalCenter: parent.verticalCenter }
                spacing: button.h * 0.15
                visible: !button.vertical
                Rectangle { visible: inhibition.isManuallyInhibited; width: button.h * 0.32; height: width; radius: Oranje.round ? width / 2 : 0; color: Oranje.navy
                    Rectangle { anchors.centerIn: parent; width: parent.width * 0.6; height: width; radius: Oranje.round ? width / 2 : 0; color: Oranje.gold } }
                Rectangle { visible: root.dndOn; width: button.h * 0.32; height: width; radius: Oranje.round ? width / 2 : 0; color: Oranje.navy
                    Rectangle { anchors.centerIn: parent; width: parent.width * 0.6; height: width; radius: Oranje.round ? width / 2 : 0; color: Oranje.red } }
            }
        }
    }

    fullRepresentation: ControlView {
        onCloseRequested: root.expanded = false
    }

    // Reset to the main page each time the popup opens.
    // Back to the main page on open and close (this also stops a Bluetooth scan).
    onExpandedChanged: {
        if (root.fullRepresentationItem)
            root.fullRepresentationItem.page = "main"
    }
}
