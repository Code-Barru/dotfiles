import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../controlcenter"

Rectangle {
    id: root

    property string icon: "󰐥"
    property string label: "Action"
    property color actionColor: Theme.blue
    property string command: ""
    signal triggered()

    width: 160
    height: 120
    radius: 12
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
        spacing: 12

        Text {
            text: root.icon
            font.pixelSize: 48
            font.family: "JetBrains Mono"
            color: root.actionColor
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: root.label
            font.pixelSize: Theme.normalFontSize
            font.family: "JetBrains Mono"
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
            closeTimer.start()
        }
    }

    Process {
        id: executeProcess
        command: root.command.split(" ")
    }

    Timer {
        id: closeTimer
        interval: 100
        onTriggered: {
            // Signal will be caught by PowerMenu to close itself
        }
    }
}
