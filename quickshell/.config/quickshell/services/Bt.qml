pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false

    readonly property var devices: adapter?.devices.values ?? []

    readonly property var connected: devices.filter(d => d.connected)
    readonly property string status: {
        if (!enabled)
            return "Désactivé"
        if (connected.length === 1)
            return connected[0].deviceName
        if (connected.length > 1)
            return `${connected.length} appareils`
        return "Aucun appareil"
    }

    readonly property var sorted: devices.slice().sort((a, b) => {
        if (a.connected !== b.connected)
            return a.connected ? -1 : 1
        if (a.paired !== b.paired)
            return a.paired ? -1 : 1
        return a.deviceName.localeCompare(b.deviceName)
    })

    property bool scanning: false

    Binding {
        target: root.adapter
        property: "discovering"
        value: root.scanning && root.enabled
        when: root.available
    }

    function setEnabled(on) {
        if (adapter)
            adapter.enabled = on
    }

    function toggleDevice(device) {
        if (device.connected)
            device.disconnect()
        else if (device.paired)
            device.connect()
        else
            device.pair()
    }
}
