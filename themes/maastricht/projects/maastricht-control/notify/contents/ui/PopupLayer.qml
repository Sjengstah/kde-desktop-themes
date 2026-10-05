import QtQuick
import QtQuick.Window
import org.kde.layershell as LayerShell
import org.kde.notificationmanager as NotificationManager
import "."

// MAASTRICHT notification popups, stacked in the top-right corner of the active screen.
// A layer-shell surface on the "top" layer: above normal windows, below fullscreen games.
Window {
    id: popupLayer

    required property var popups                // NotificationManager.Notifications (popup model)
    required property var notifySettings        // NotificationManager.Settings
    property int topMargin: 42
    property int sideMargin: 10
    property bool playSounds: true

    readonly property real u: Maastricht.u

    color: "transparent"
    width: 44 * u
    height: Math.max(1, stack.implicitHeight)
    visible: true

    LayerShell.Window.scope: "maastricht-notifications"
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop | LayerShell.Window.AnchorRight
    LayerShell.Window.margins.top: topMargin
    LayerShell.Window.margins.right: sideMargin
    LayerShell.Window.exclusionZone: 0
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone
    LayerShell.Window.wantsToBeOnActiveScreen: true

    property date now: new Date()
    Timer { interval: 30000; running: popupLayer.visible; repeat: true; onTriggered: popupLayer.now = new Date() }

    Column {
        id: stack
        width: parent.width
        spacing: 0.8 * popupLayer.u

        Repeater {
            model: popupLayer.popups

            NotificationCard {
                id: popup

                notifications: popupLayer.popups
                width: stack.width
                now: popupLayer.now

                // -1 = use the configured popup time; 0 = stay until dismissed
                readonly property int effectiveTimeout: model.timeout === -1
                    ? popupLayer.notifySettings.popupTimeout + ((model.urls || []).length > 0 ? 5000 : 0)
                    : model.timeout
                readonly property int notificationId: model.notificationId

                progress: effectiveTimeout > 0 ? remaining : -1
                property real remaining: 1

                onActivated: {} // the model closes non-resident notifications itself

                NumberAnimation on remaining {
                    id: countdown
                    from: 1
                    to: 0
                    duration: Math.max(1, popup.effectiveTimeout)
                    running: popup.effectiveTimeout > 0
                    paused: running && popup.hovered
                    onFinished: popupLayer.popups.expire(popupLayer.popups.index(popup.index, 0))
                }

                Component.onCompleted: {
                    // We run the timeout ourselves (with hover pause), like Plasma's own popups.
                    popupLayer.popups.stopTimeout(popupLayer.popups.index(index, 0))
                    if (popupLayer.playSounds)
                        popupLayer.popups.playSoundHint(popupLayer.popups.index(index, 0))
                }
                // Removed without expiring (e.g. by a filter change): hand the timeout back to the model.
                Component.onDestruction: popupLayer.popups.startTimeout(notificationId)
            }
        }
    }
}
