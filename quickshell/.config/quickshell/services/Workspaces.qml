pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import ".."

Singleton {
    id: root

    property int active: 0
    property int previous: 0

    signal switched

    function slotOf(id) {
        return Math.min(Math.max(id, 1), Theme.wormSlots) - 1
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name !== "workspace")
                return

            const id = parseInt(event.data)
            if (!id || id === root.active)
                return

            root.previous = root.active
            root.active = id

            if (root.previous !== 0)
                root.switched()
        }
    }

    Process {
        id: seedProc

        command: ["hyprctl", "activeworkspace", "-j"]

        stdout: SplitParser {
            onRead: line => {
                if (root.active !== 0)
                    return

                const found = line.match(/"id"\s*:\s*(\d+)/)
                if (found)
                    root.active = parseInt(found[1])
            }
        }
    }

    Component.onCompleted: seedProc.running = true
}
