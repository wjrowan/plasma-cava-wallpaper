import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root
    twinFormLayouts: parentLayout

    property alias formLayout: root

    property string cfg_Image
    property int cfg_FillMode
    property alias cfg_Framerate: framerateSpinbox.value
    property alias cfg_BarCount: barCountSpinbox.value
    property alias cfg_BarGap: barGapSpinbox.value
    property alias cfg_BarMaxHeight: barMaxHeightSpinbox.value
    property alias cfg_BarTopMargin: barTopMarginSpinbox.value
    property alias cfg_BarBottomMargin: barBottomMarginSpinbox.value
    property int cfg_ColorMode
    property alias cfg_BarColorTop: topColorButton.colorHex
    property alias cfg_BarColorBottom: bottomColorButton.colorHex
    property alias cfg_BarOpacity: opacitySlider.value
    property alias cfg_NoiseReduction: noiseReductionSpinbox.value
    property alias cfg_AutoSensitivity: autoSensitivityCheckbox.checked

    // CAVA aborts above this many bars.
    readonly property int cavaMaxBars: 512

    RowLayout {
        Kirigami.FormData.label: "Background image:"
        QQC2.TextField {
            id: imagePathField
            text: root.cfg_Image
            Layout.fillWidth: true
            Layout.minimumWidth: 300
            onEditingFinished: root.cfg_Image = text
        }
        QQC2.Button {
            text: "Browse…"
            onClicked: fileDialog.open()
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select Background Image"
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.bmp *.webp)"]
        onAccepted: {
            root.cfg_Image = selectedFile;
            imagePathField.text = selectedFile;
        }
    }

    QQC2.ComboBox {
        id: fillModeCombo
        Kirigami.FormData.label: "Fill mode:"
        textRole: "text"
        model: [
            { text: "Scaled and Cropped", value: 2 },
            { text: "Scaled", value: 1 },
            { text: "Stretched", value: 0 }
        ]
        Component.onCompleted: currentIndex = model.findIndex(m => m.value === root.cfg_FillMode)
        onActivated: root.cfg_FillMode = model[currentIndex].value
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Bars"
    }

    QQC2.SpinBox {
        id: framerateSpinbox
        Kirigami.FormData.label: "Framerate:"
        from: 1
        to: 144
    }

    QQC2.SpinBox {
        id: barCountSpinbox
        Kirigami.FormData.label: "Number of bars:"
        from: 2
        to: root.cavaMaxBars
    }

    QQC2.SpinBox {
        id: barGapSpinbox
        Kirigami.FormData.label: "Bar gap (px):"
        from: 0
        to: 100
    }

    QQC2.SpinBox {
        id: barMaxHeightSpinbox
        Kirigami.FormData.label: "Bar max height (px):"
        from: 1
        to: 1000
    }

    QQC2.SpinBox {
        id: barTopMarginSpinbox
        Kirigami.FormData.label: "Top row offset (px):"
        from: 0
        to: 500
    }

    QQC2.SpinBox {
        id: barBottomMarginSpinbox
        Kirigami.FormData.label: "Bottom row offset (px):"
        from: 0
        to: 500
    }

    QQC2.ComboBox {
        id: colorModeCombo
        Kirigami.FormData.label: "Bar color:"
        textRole: "text"
        model: [
            { text: "Solid", value: 0 },
            { text: "Rainbow", value: 1 },
            { text: "Adaptive (from background)", value: 2 }
        ]
        Component.onCompleted: currentIndex = model.findIndex(m => m.value === root.cfg_ColorMode)
        onActivated: root.cfg_ColorMode = model[currentIndex].value
    }

    ColorPickerButton {
        id: topColorButton
        Kirigami.FormData.label: "Top bar color:"
        visible: root.cfg_ColorMode === 0
    }

    ColorPickerButton {
        id: bottomColorButton
        Kirigami.FormData.label: "Bottom bar color:"
        visible: root.cfg_ColorMode === 0
    }

    QQC2.Slider {
        id: opacitySlider
        Kirigami.FormData.label: "Bar opacity:"
        from: 0.1
        to: 1
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Audio"
    }

    QQC2.SpinBox {
        id: noiseReductionSpinbox
        Kirigami.FormData.label: "Noise reduction:"
        from: 0
        to: 100
    }

    QQC2.CheckBox {
        id: autoSensitivityCheckbox
        Kirigami.FormData.label: "Automatic sensitivity:"
    }
}
