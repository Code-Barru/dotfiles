import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: audio
    implicitWidth: row.width
    implicitHeight: row.height

    property int volume: 0
    property bool muted: false

    Process {
        id: getVolume
        command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/(\d+)%/)
                if (match) audio.volume = parseInt(match[1])
            }
        }
    }

    Process {
        id: getMute
        command: ["pactl", "get-sink-mute", "@DEFAULT_SINK@"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                audio.muted = data.includes("yes")
            }
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            getVolume.running = true
            getMute.running = true
        }
    }

    RowLayout {
        id: row
        spacing: 4

        Text {
            color: audio.muted ? bar.red : bar.text_
            font.pixelSize: 16
            font.family: "JetBrains Mono"
            text: {
                if (audio.muted) return "󰝟"
                if (audio.volume > 66) return "󰕾"
                if (audio.volume > 33) return "󰖀"
                return "󰕿"
            }
        }

        Text {
            color: audio.muted ? bar.red : bar.text_
            font.pixelSize: 16
            font.family: "JetBrains Mono"
            text: " " + audio.volume + "%"
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                toggleMute.running = true
            }
        }

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) volUp.running = true
            else volDown.running = true
        }
    }

    Process { id: toggleMute; command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"] }
    Process { id: volUp; command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%"] }
    Process { id: volDown; command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%"] }
}
