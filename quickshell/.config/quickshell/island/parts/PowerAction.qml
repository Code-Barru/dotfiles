import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../.."

Rectangle {
    id: root

    property string icon: "󰐥"
    property string label: "Action"
    property color actionColor: Theme.blue
    property string command: ""
    signal triggered()

    width: Theme.powerActionWidth
    height: Theme.powerActionHeight
    radius: 10
    color: mouseArea.containsMouse ? Theme.surface1 : Theme.surface0

    Behavior on color {
        ColorAnimation {
            duration: Theme.fastDuration
            easing.type: Easing.OutQuad
        }
    }

    scale: mouseArea.containsMouse ? 1.05 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: Theme.fastDuration
            easing.type: Easing.OutQuad
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            font.pixelSize: 34
            font.family: Theme.fontFamily
            color: root.actionColor
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: root.label
            font.pixelSize: Theme.tinyFontSize
            font.family: Theme.fontFamily
            color: Theme.text
            Layout.alignment: Qt.AlignHCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.triggered()
            executeProcess.running = true
        }
    }

    Process {
        id: executeProcess
        command: root.command.split(" ")
    }
}
