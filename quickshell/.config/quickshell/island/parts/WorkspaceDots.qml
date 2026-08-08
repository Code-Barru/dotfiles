import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../.."
import "../../services"

RowLayout {
    id: root

    property int first: 1
    property int count: 2

    spacing: Theme.dotSpacing

    Repeater {
        model: root.count

        Rectangle {
            required property int index

            readonly property int wsId: root.first + index
            readonly property bool active: Workspaces.active === wsId
            readonly property bool occupied: Hyprland.workspaces.values.some(w => w.id === wsId)

            implicitWidth: Theme.dotSize
            implicitHeight: Theme.dotSize
            radius: width / 2

            color: active
                ? Theme.blue
                : (occupied ? Theme.subtext0 : Theme.surface0)

            Behavior on color {
                ColorAnimation { duration: Theme.fastDuration }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch(`workspace ${parent.wsId}`)
            }
        }
    }
}
