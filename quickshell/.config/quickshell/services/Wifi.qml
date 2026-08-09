pragma Singleton

import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    id: root

    readonly property var device: {
        for (const d of Networking.devices.values) {
            if (d.type === DeviceType.Wifi)
                return d
        }
        return null
    }

    readonly property bool available: device !== null
    readonly property bool enabled: Networking.wifiEnabled

    readonly property var networks: device?.networks.values ?? []

    readonly property var active: {
        for (const n of networks) {
            if (n.connected)
                return n
        }
        return null
    }

    readonly property string ssid: active?.name ?? ""
    readonly property bool connecting: (active?.stateChanging ?? false)
        || networks.some(n => n.state === ConnectionState.Connecting)

    function percentOf(network) {
        const v = network?.signalStrength ?? 0
        return Math.round(v > 1 ? v : v * 100)
    }

    readonly property int signalPercent: percentOf(active)

    readonly property var sorted: networks.slice().sort((a, b) => {
        if (a.connected !== b.connected)
            return a.connected ? -1 : 1
        if (a.known !== b.known)
            return a.known ? -1 : 1
        return (b.signalStrength ?? 0) - (a.signalStrength ?? 0)
    })

    property bool scanning: false

    Binding {
        target: root.device
        property: "scannerEnabled"
        value: root.scanning
        when: root.available
    }

    function setEnabled(on) {
        Networking.wifiEnabled = on
    }

    function needsPassword(network) {
        return !network.known && network.security !== WifiSecurityType.Open
    }

    function connect(network) {
        if (network.connected)
            network.disconnect()
        else
            network.connect()
    }
}
