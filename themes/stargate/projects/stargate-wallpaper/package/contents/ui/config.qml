import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root
    twinFormLayouts: parentLayout

    property alias cfg_PanelTop: top.value
    property alias cfg_PanelBottom: bottom.value
    property alias cfg_ShowLiveData: live.checked
    property alias formLayout: root

    QQC2.SpinBox {
        id: top
        Kirigami.FormData.label: "Top panel height:"
        from: 0; to: 200
    }
    QQC2.SpinBox {
        id: bottom
        Kirigami.FormData.label: "Bottom panel height:"
        from: 0; to: 200
    }
    QQC2.CheckBox {
        id: live
        Kirigami.FormData.label: "Sectors:"
        text: "Show the gate-room readouts"
    }
}
