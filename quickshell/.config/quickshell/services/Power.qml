pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool present: device?.isPresent ?? false
    readonly property int percent: Math.round((device?.percentage ?? 0) * 100)
    readonly property bool charging: device?.state === UPowerDeviceState.Charging
    readonly property bool discharging: device?.state === UPowerDeviceState.Discharging

    readonly property int lowThreshold: 10
    readonly property int rearmThreshold: 25

    signal lowBattery(int percent)

    property bool warned: false

    function check() {
        if (!present)
            return

        if (!discharging || percent > rearmThreshold) {
            warned = false
            return
        }

        if (percent <= lowThreshold && !warned) {
            warned = true
            lowBattery(percent)
        }
    }

    Connections {
        target: UPower.displayDevice

        function onPercentageChanged() { root.check() }
        function onStateChanged() { root.check() }
    }

    Component.onCompleted: check()
}
