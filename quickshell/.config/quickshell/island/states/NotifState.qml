import QtQuick
import "../.."
import "../../services"
import "../parts"

Item {
    id: root

    implicitWidth: Theme.notifWidth
    implicitHeight: Theme.notifHeight

    NotifCard {
        anchors.fill: parent
        anchors.margins: Theme.islandPadding
        notif: IslandState.currentNotif
        bodyLines: 2
    }
}
