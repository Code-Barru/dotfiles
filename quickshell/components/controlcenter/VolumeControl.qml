import QtQuick
import QtQuick.Layouts
import Quickshell.Io

ColumnLayout {
    id: volumeControl
    spacing: Theme.spacing

    // État volume/mute (bindé depuis ControlCenter, alimenté par l'OSD)
    property int volume: 50
    property bool muted: false

    Process {
        id: setVolume
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "50%"]
    }

    Process {
        id: toggleMute
        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
    }

    // Header avec icône et bouton mute
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: "󰕾  Volume"
            color: volumeControl.muted ? Theme.red : Theme.blue
            font.pixelSize: Theme.normalFontSize
            font.family: "JetBrains Mono"
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        Text {
            text: volumeControl.volume + "%"
            color: volumeControl.muted ? Theme.red : Theme.text
            font.pixelSize: Theme.normalFontSize
            font.family: "JetBrains Mono"
            Layout.alignment: Qt.AlignVCenter
        }

        // Bouton mute
        Rectangle {
            width: 40
            height: 30
            radius: 4
            color: volumeControl.muted ? Theme.red : Theme.surface0
            Layout.alignment: Qt.AlignVCenter

            Behavior on color {
                ColorAnimation {
                    duration: Theme.fastDuration
                    easing.type: Easing.OutQuad
                }
            }

            Text {
                anchors.centerIn: parent
                text: volumeControl.muted ? "󰝟" : "󰕾"
                color: volumeControl.muted ? Theme.crust : Theme.text
                font.pixelSize: Theme.normalFontSize
                font.family: "JetBrains Mono"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    toggleMute.running = true
                }
            }
        }
    }

    // Slider
    Slider {
        id: slider
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.sliderHeight
        min: 0
        max: 100
        value: volumeControl.volume

        onUserChanged: newValue => {
            setVolume.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", newValue + "%"]
            setVolume.running = true
        }
    }
}
