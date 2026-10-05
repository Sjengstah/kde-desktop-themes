import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_maastrichtPopups: maastrichtPopups.checked
    property alias cfg_popupTopMargin: topMargin.value
    property var cfg_maastrichtPopupsDefault
    property var cfg_popupTopMarginDefault

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: maastrichtPopups
            Kirigami.FormData.label: i18n("Popups:")
            text: i18n("Replace KDE's notification popups with MAASTRICHT popups")
        }
        QQC2.Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 24
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            text: i18n("This keeps KDE's own Do Not Disturb switched on so its popups stay hidden, and plays notification sounds itself. Unchecking it restores KDE's popups.")
        }
        QQC2.SpinBox {
            id: topMargin
            Kirigami.FormData.label: i18n("Distance from top (px):")
            from: 0
            to: 400
        }
    }
}
