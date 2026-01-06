import QtQuick
import QtQuick.Layouts
import Quickshell.Io

RowLayout {
    id: battery
    spacing: 4

    property int percent: 100
    property string status: "Unknown"

    Process {
        id: getCapacity
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true
        stdout: SplitParser {
            onRead: data => { battery.percent = parseInt(data.trim()) || 0 }
        }
    }

    Process {
        id: getStatus
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        running: true
        stdout: SplitParser {
            onRead: data => { battery.status = data.trim() }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            getCapacity.running = true
            getStatus.running = true
        }
    }

    Text {
        font.pixelSize: 16
        font.family: "JetBrains Mono"
        color: {
            if (battery.status === "Charging") return bar.green
            if (battery.percent <= 20) return bar.red
            if (battery.percent <= 40) return bar.yellow
            return bar.text_
        }
        text: {
            if (battery.status === "Charging") return "󰂄"
            if (battery.percent > 90) return "󰁹"
            if (battery.percent > 80) return "󰂂"
            if (battery.percent > 70) return "󰂁"
            if (battery.percent > 60) return "󰂀"
            if (battery.percent > 50) return "󰁿"
            if (battery.percent > 40) return "󰁾"
            if (battery.percent > 30) return "󰁽"
            if (battery.percent > 20) return "󰁼"
            if (battery.percent > 10) return "󰁻"
            return "󰁺"
        }
    }

    Text {
        font.pixelSize: 16
        font.family: "JetBrains Mono"
        color: {
            if (battery.status === "Charging") return bar.green
            if (battery.percent <= 20) return bar.red
            if (battery.percent <= 40) return bar.yellow
            return bar.text_
        }
        text: battery.percent + "%"
    }
}
