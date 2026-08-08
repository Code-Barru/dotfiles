import Quickshell
import QtQuick
import "../.."

// État de repos : date + heure
Item {
    id: root

    implicitWidth: Math.max(Theme.hourWidth, label.implicitWidth + Theme.islandPadding * 2)
    implicitHeight: Theme.hourHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: label

        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "ddd dd   HH:mm")
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.smallFontSize
    }
}
