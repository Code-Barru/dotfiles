import QtQuick
import QtQuick.Layouts
import Quickshell.Io

ColumnLayout {
    id: brightnessControl
    spacing: Theme.spacing

    property int percent: 50

    Process {
        id: getBrightness
        command: ["brightnessctl", "-m"]
        running: true

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const parts = data.trim().split(',')
                if (parts.length >= 5) {
                    brightnessControl.percent = parseInt(parts[3].replace('%', ''))
                    slider.value = brightnessControl.percent
                }
            }
        }
    }

    Process {
        id: setBrightness
        command: ["brightnessctl", "set", "50%"]
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: getBrightness.running = true
    }

    // Header
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: "  Luminosité"
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
            brightnessControl.percent = newValue
            setBrightness.command = ["brightnessctl", "set", newValue + "%"]
            setBrightness.running = true
        }
    }
}
