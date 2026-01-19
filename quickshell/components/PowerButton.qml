import QtQuick
import QtQuick.Layouts
import "controlcenter"

Rectangle {
    id: root

    property var powerMenu: null

    width: 40
    height: 30
    radius: 0
    color: Theme.crust
  
    Text {
        anchors.centerIn: parent
        text: "󰣇"
        font.pixelSize: 20
        font.family: "JetBrains Mono"
        color: Theme.blue
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (powerMenu) {
                powerMenu.isOpen = !powerMenu.isOpen
            }
        }
    }
}
