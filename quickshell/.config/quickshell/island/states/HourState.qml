import Quickshell
import QtQuick
import "../.."

Item {
    id: root

    implicitWidth: Theme.hourWidth
    implicitHeight: Theme.hourHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.smallFontSize
    }
}
