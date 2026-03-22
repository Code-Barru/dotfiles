import QtQuick
import QtQuick.Layouts
import Quickshell.Io

ColumnLayout {
    id: brightnessControl
    spacing: Theme.spacing

    // État brightness (bindé depuis ControlCenter, alimenté par l'OSD)
    property int percent: 50

    Process {
        id: setBrightness
        command: ["brightnessctl", "set", "50%"]
    }

    // Header
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: "  Luminosité"
            color: Theme.blue
            font.pixelSize: Theme.normalFontSize
            font.family: "JetBrains Mono"
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        Text {
            text: brightnessControl.percent + "%"
            color: Theme.text
            font.pixelSize: Theme.normalFontSize
            font.family: "JetBrains Mono"
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // Slider
    Slider {
        id: slider
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.sliderHeight
        min: 1
        max: 100
        value: brightnessControl.percent

        onUserChanged: newValue => {
            setBrightness.command = ["brightnessctl", "set", newValue + "%"]
            setBrightness.running = true
        }
    }
}
