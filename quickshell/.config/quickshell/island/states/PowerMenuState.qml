import QtQuick
import QtQuick.Layouts
import "../.."
import "../../services"
import "../parts"

Item {
    id: root

    implicitWidth: Theme.powerMenuWidth
    implicitHeight: Theme.powerMenuHeight

    focus: true
    Keys.onEscapePressed: IslandState.clearOverlay()

    GridLayout {
        anchors.centerIn: parent
        columns: 3
        columnSpacing: 12
        rowSpacing: 12

        PowerAction {
            icon: "󰐥"
            label: "Éteindre"
            actionColor: Theme.red
            command: "systemctl poweroff"
            onTriggered: IslandState.clearOverlay()
        }

        PowerAction {
            icon: "󰜉"
            label: "Redémarrer"
            actionColor: Theme.yellow
            command: "systemctl reboot"
            onTriggered: IslandState.clearOverlay()
        }

        PowerAction {
            icon: "󰌾"
            label: "Verrouiller"
            actionColor: Theme.blue
            command: "hyprlock"
            onTriggered: IslandState.clearOverlay()
        }

        PowerAction {
            icon: "󰍃"
            label: "Déconnexion"
            actionColor: Theme.mauve
            command: "hyprctl dispatch exit"
            onTriggered: IslandState.clearOverlay()
        }

        PowerAction {
            icon: "󰒲"
            label: "Suspendre"
            actionColor: Theme.green
            command: "systemctl suspend"
            onTriggered: IslandState.clearOverlay()
        }

        PowerAction {
            icon: "󰋊"
            label: "Hiberner"
            actionColor: Theme.green
            command: "systemctl hibernate"
            onTriggered: IslandState.clearOverlay()
        }
    }
}
