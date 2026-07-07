import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "controlcenter"

RowLayout {
    id: battery
    spacing: 4

    readonly property var device: UPower.displayDevice
    readonly property int percent: device.isPresent ? Math.round(device.percentage * 100) : 100
    readonly property bool charging: device.state === UPowerDeviceState.Charging

    Text {
        font.pixelSize: 16
        font.family: "JetBrains Mono"
        color: {
            if (battery.charging) return Theme.green
            if (battery.percent <= 10) return Theme.red
            if (battery.percent <= 20) return Theme.yellow
            return Theme.blue
        }
        text: {
            if (battery.charging) return "󰂄"
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
            if (battery.charging) return Theme.green
            if (battery.percent <= 10) return Theme.red
            if (battery.percent <= 20) return Theme.yellow
            return Theme.blue
        }
        text: battery.percent + "%"
    }
}
