import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

// A small swatch button that pops open an inline hex-entry field. Used
// instead of KQuickControls.ColorButton (which opens a separate native
// QtQuick.Dialogs.ColorDialog window per instance) since two of those in the
// same config page led to the second one failing to visibly open - most
// likely a Wayland dialog-stacking/focus quirk. This keeps everything in the
// same window, so there's no separate top-level dialog to get stuck.
QQC2.Button {
    id: root

    property string colorHex: "#ffffff"

    implicitWidth: 44
    implicitHeight: 24

    background: Rectangle {
        color: root.colorHex
        border.width: 1
        border.color: Qt.darker(palette.mid, 1.3)
        radius: 2
    }

    onClicked: popup.open()

    QQC2.Popup {
        id: popup
        y: root.height + 2
        modal: true
        focus: true
        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside

        ColumnLayout {
            spacing: 8

            QQC2.TextField {
                id: hexField
                Layout.preferredWidth: 140
                text: root.colorHex
                placeholderText: "#rrggbb"
                selectByMouse: true
                onEditingFinished: root.colorHex = text
                onAccepted: popup.close()
            }
        }
    }
}
