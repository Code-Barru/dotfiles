import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import "../.."
import "../../services"

ColumnLayout {
    id: root

    property var pending: null

    spacing: 4

    function icon(network) {
        const p = Wifi.percentOf(network)
        if (p >= 75)
            return "󰤨"
        if (p >= 50)
            return "󰤥"
        if (p >= 25)
            return "󰤢"
        if (p > 0)
            return "󰤟"
        return "󰤯"
    }

    function activate(network) {
        if (network.connected) {
            network.disconnect()
            return
        }

        if (Wifi.needsPassword(network))
            root.pending = network
        else
            network.connect()
    }

    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(Theme.listMaxHeight, contentHeight)

        clip: true
        spacing: 2
        model: Wifi.sorted
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            id: row

            required property var modelData

            width: ListView.view.width
            height: 30
            radius: 8
            color: hover.hovered ? Theme.surface : "transparent"

            HoverHandler {
                id: hover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.activate(row.modelData)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: root.icon(row.modelData)
                    color: row.modelData.connected ? Theme.accent : Theme.fgDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.tinyFontSize
                }

                Text {
                    Layout.fillWidth: true
                    text: row.modelData.name
                    color: row.modelData.connected ? Theme.fg : Theme.fgDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.tinyFontSize
                    elide: Text.ElideRight
                }

                Text {
                    visible: row.modelData.security !== WifiSecurityType.Open
                    text: "󰌾"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.tinyFontSize
                }

                Text {
                    visible: row.modelData.connected || row.modelData.stateChanging
                    text: row.modelData.stateChanging ? "󰑮" : "󰄬"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.tinyFontSize
                }
            }
        }
    }

    Loader {
        Layout.fillWidth: true
        active: root.pending !== null

        sourceComponent: PskPrompt {
            ssid: root.pending?.name ?? ""

            onAccepted: psk => {
                root.pending.connectWithPsk(psk)
                root.pending = null
            }

            onCancelled: root.pending = null
        }
    }
}
