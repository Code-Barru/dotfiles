pragma Singleton

import Quickshell
import Quickshell.Hyprland
import QtQuick
import ".."

Singleton {
    id: root

    readonly property int active: Hyprland.focusedWorkspace?.id ?? 0

    property bool revealed: false

    // Déclenché sur l'événement et non sur active : une liaison se réveillerait
    // aussi à la résolution initiale, et les pastilles apparaîtraient au démarrage
    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name !== "workspace" && event.name !== "workspacev2")
                return

            root.revealed = true
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: Theme.workspaceTimeout
        onTriggered: root.revealed = false
    }
}
