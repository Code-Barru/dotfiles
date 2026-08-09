import QtQuick
import "../.."
import "../../services"

Rectangle {
    id: root

    property string ssid: ""

    signal accepted(string psk)
    signal cancelled

    implicitHeight: 30
    radius: 8
    color: Theme.bg
    border.width: 1
    border.color: Theme.surfaceHi

    Component.onCompleted: {
        IslandState.inputActive = true
        input.forceActiveFocus()
    }

    Component.onDestruction: IslandState.inputActive = false

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰌾"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.tinyFontSize
        }

        TextInput {
            id: input

            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 60
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.tinyFontSize
            echoMode: TextInput.Password
            selectByMouse: true
            clip: true

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: input.text === ""
                text: `Mot de passe · ${root.ssid}`
                color: Theme.muted
                font: input.font
            }

            onAccepted: if (text !== "")
                root.accepted(text)

            Keys.onEscapePressed: root.cancelled()
        }

        IconButton {
            anchors.verticalCenter: parent.verticalCenter
            icon: "󰅖"
            iconSize: Theme.tinyFontSize
            iconColor: Theme.muted
            implicitWidth: 20
            implicitHeight: 20
            onClicked: root.cancelled()
        }
    }
}
