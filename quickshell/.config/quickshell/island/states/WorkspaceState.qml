import QtQuick
import "../.."
import "../../services"
import "../parts"

Item {
    id: root

    implicitWidth: Theme.workspaceWidth
    implicitHeight: Theme.workspaceHeight

    function travel() {
        worm.travelTo(Workspaces.slotOf(Workspaces.active))
    }

    Component.onCompleted: {
        worm.jumpTo(Workspaces.slotOf(Workspaces.previous))
        kick.start()
    }

    Timer {
        id: kick
        interval: 16
        onTriggered: root.travel()
    }

    Connections {
        target: Workspaces
        function onActiveChanged() {
            root.travel()
        }
    }

    Worm {
        id: worm
        anchors.centerIn: parent
    }
}
