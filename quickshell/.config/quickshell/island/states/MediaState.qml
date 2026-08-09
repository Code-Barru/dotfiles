import QtQuick
import "../.."
import "../../services"
import "../parts"

Item {
    id: root

    implicitWidth: Theme.mediaWidth
    implicitHeight: Theme.mediaHeight

    HoverHandler {
        id: hover
    }

    Binding {
        target: IslandState
        property: "panelHeld"
        value: hover.hovered
    }

    MediaBlock {
        anchors.fill: parent
        anchors.margins: Theme.islandPadding
    }
}
