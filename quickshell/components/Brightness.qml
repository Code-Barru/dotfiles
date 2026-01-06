import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: brightness
    implicitWidth: row.width
    implicitHeight: row.height

    property int percent: 0

    Process {
        id: getBrightness
        command: ["brightnessctl", "-m"]
        running: true

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const parts = data.trim().split(',')
                if (parts.length >= 5) {
                    brightness.percent = parseInt(parts[3].replace('%', ''))
                }
            }
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: getBrightness.running = true
    }

    RowLayout {
        id: row
        spacing: 4

        Text {
            color: bar.text_
            font.pixelSize: 16
            font.family: "JetBrains Mono"
            text: "  " + brightness.percent + "%"
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) brightUp.running = true
            else brightDown.running = true
        }
    }

    Process {
        id: brightUp
        command: ["brightnessctl", "set", "+1%"]
        onRunningChanged: if (!running) getBrightness.running = true
    }

    Process {
        id: brightDown
        command: ["brightnessctl", "set", "1%-"]
        onRunningChanged: if (!running) getBrightness.running = true
    }
}
