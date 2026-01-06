import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: workspaces
    spacing: 4

    Repeater {
        model: 4

        Rectangle {
            required property int index
            property int wsNum: index + 1
            property bool isActive: Hyprland.focusedMonitor?.activeWorkspace?.id === wsNum
            property bool isOccupied: Hyprland.workspaces.values.some(w => w.id === wsNum)

            width: 10
            height: 10
            radius: 4
            color: isActive ? bar.blue : (isOccupied ? bar.subtext0 : bar.surface0)

            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + wsNum)
            }
        }
    }
}
