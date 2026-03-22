import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout {
    id: stats
    spacing: 12

    property int cpuPercent: 0
    property int ramPercent: 0
    property real ramUsedGb: 0
    property real ramTotalGb: 0
    property int temperature: 0
    property var prevIdle: 0
    property var prevTotal: 0

    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        running: true

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const lines = data.split('\n')
                const cpuLine = lines[0]
                const parts = cpuLine.split(/\s+/).slice(1).map(Number)
                const idle = parts[3] + parts[4]
                const total = parts.reduce((a, b) => a + b, 0)

                if (stats.prevTotal > 0) {
                    const diffIdle = idle - stats.prevIdle
                    const diffTotal = total - stats.prevTotal
                    stats.cpuPercent = Math.round(100 * (1 - diffIdle / diffTotal))
                }
                stats.prevIdle = idle
                stats.prevTotal = total
            }
        }
    }

    Process {
        id: ramProc
        command: ["cat", "/proc/meminfo"]
        running: true

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const lines = data.split('\n')
                let total = 0, available = 0
                for (const line of lines) {
                    if (line.startsWith("MemTotal:"))
                        total = parseInt(line.split(/\s+/)[1])
                    if (line.startsWith("MemAvailable:"))
                        available = parseInt(line.split(/\s+/)[1])
                }
                if (total > 0) {
                    stats.ramPercent = Math.round(100 * (1 - available / total))
                    stats.ramTotalGb = total / 1024 / 1024
                    stats.ramUsedGb = (total - available) / 1024 / 1024
                }
            }
        }
    }

    Process {
        id: tempProc
        command: ["cat", "/sys/class/thermal/thermal_zone0/temp"]
        running: true

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                stats.temperature = Math.round(parseInt(data.trim()) / 1000)
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
            tempProc.running = true
        }
    }

    Text {
        color: stats.cpuPercent > 80 ? bar.red : bar.text_
        font.pixelSize: 16
        font.family: "JetBrains Mono"
        text: "  " + stats.cpuPercent + "%"
    }

    Item {
        id: ramItem
        implicitWidth: ramText.width
        implicitHeight: ramText.height

        Text {
            id: ramText
            color: stats.ramPercent > 80 ? bar.red : bar.text_
            font.pixelSize: 16
            font.family: "JetBrains Mono"
            text: "  "  + stats.ramPercent + "%"
        }

        MouseArea {
            id: ramMouse
            anchors.fill: parent
            hoverEnabled: true
        }

        PopupWindow {
            id: ramTooltip
            visible: ramMouse.containsMouse
            anchor.window: bar
            anchor.rect.x: ramItem.x + 30
            anchor.rect.y: bar.height
            anchor.rect.width: ramItem.width
            anchor.rect.height: 1
            anchor.edges: Edges.Bottom

            implicitWidth: tooltipContent.width
            implicitHeight: tooltipContent.height
            color: "transparent"

            Rectangle {
                id: tooltipContent
                width: tooltipText.width + 16
                height: tooltipText.height + 10
                radius: 4
                color: bar.surface0

                Text {
                    id: tooltipText
                    anchors.centerIn: parent
                    color: bar.text_
                    font.pixelSize: 14
                    font.family: "JetBrains Mono"
                    text: stats.ramUsedGb.toFixed(1) + " GiB / " + stats.ramTotalGb.toFixed(1) + " GiB"
                }
            }
        }
    }

    Text {
        color: stats.temperature > 60 ? bar.red : (stats.temperature > 55 ? bar.yellow : bar.text_)
        font.pixelSize: 16
        font.family: "JetBrains Mono"
        text: " " + stats.temperature + "°C"
    }
}
