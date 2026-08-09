import QtQuick
import QtQuick.Layouts
import "../.."
import "../../services"
import "../parts"

Item {
    id: root

    property string openTile: ""

    implicitWidth: Theme.controlCenterWidth
    implicitHeight: column.implicitHeight + Theme.islandPadding * 2

    function toggleTile(name) {
        openTile = openTile === name ? "" : name
    }

    Binding {
        target: Wifi
        property: "scanning"
        value: root.openTile === "wifi"
    }

    Binding {
        target: Bt
        property: "scanning"
        value: root.openTile === "bt"
    }

    ColumnLayout {
        id: column

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.islandPadding

        spacing: 8

        Tile {
            Layout.fillWidth: true

            icon: Wifi.enabled ? "󰖩" : "󰖪"
            label: "Wi-Fi"
            status: {
                if (!Wifi.available)
                    return "Aucune carte"
                if (!Wifi.enabled)
                    return "Désactivé"
                return Wifi.ssid !== "" ? `${Wifi.ssid} · ${Wifi.signalPercent}%` : "Non connecté"
            }
            checked: Wifi.enabled
            busy: Wifi.connecting
            expandable: Wifi.available && Wifi.enabled
            expanded: root.openTile === "wifi"

            onToggled: state => Wifi.setEnabled(state)
            onHeaderClicked: root.toggleTile("wifi")

            WifiList {
                Layout.fillWidth: true
            }
        }

        Tile {
            Layout.fillWidth: true
            visible: Bt.available

            icon: Bt.enabled ? "󰂯" : "󰂲"
            label: "Bluetooth"
            status: Bt.status
            checked: Bt.enabled
            expandable: Bt.enabled
            expanded: root.openTile === "bt"

            onToggled: state => Bt.setEnabled(state)
            onHeaderClicked: root.toggleTile("bt")

            BtList {}
        }

        Tile {
            Layout.fillWidth: true
            visible: Vpn.available

            icon: "󰖂"
            label: "VPN"
            status: Vpn.connected ? `${Vpn.name} · connecté` : Vpn.name
            checked: Vpn.connected
            busy: Vpn.busy

            onToggled: state => Vpn.setEnabled(state)
        }

        Tile {
            Layout.fillWidth: true

            icon: "󰓃"
            label: "Sortie audio"
            status: Audio.sinkLabel(Audio.sink)
            showToggle: false
            expandable: Audio.sinks.length > 1
            expanded: root.openTile === "sink"

            onHeaderClicked: root.toggleTile("sink")

            SinkList {}
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.controlRowHeight
            spacing: 8

            IconButton {
                icon: Audio.muted ? "󰝟" : "󰕾"
                iconSize: Theme.smallFontSize
                iconColor: Audio.muted ? Theme.muted : Theme.fg
                onClicked: Audio.toggleMute()
            }

            Slider {
                Layout.fillWidth: true
                value: Audio.percent
                enabled: Audio.ready
                onUserChanged: v => Audio.setVolume(v / 100)
            }

            Text {
                Layout.preferredWidth: 32
                text: `${Audio.percent}%`
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
                horizontalAlignment: Text.AlignRight
            }

            IconButton {
                icon: Audio.micMuted ? "󰍭" : "󰍬"
                iconSize: Theme.smallFontSize
                iconColor: Audio.micMuted ? Theme.error : Theme.fg
                onClicked: Audio.toggleMicMute()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.controlRowHeight
            spacing: 8
            visible: Brightness.available

            IconButton {
                icon: "󰃠"
                iconSize: Theme.smallFontSize
                enabled: false
            }

            Slider {
                Layout.fillWidth: true
                min: 1
                value: Brightness.percent
                onUserChanged: v => Brightness.setPercent(v)
            }

            Text {
                Layout.preferredWidth: 32
                text: `${Brightness.percent}%`
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
                horizontalAlignment: Text.AlignRight
            }

            Item {
                Layout.preferredWidth: 28
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            Text {
                visible: Power.present
                text: Power.charging ? "󰂄" : "󰁹"
                color: Power.percent <= Power.lowThreshold ? Theme.error : Theme.fgDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.smallFontSize
            }

            Text {
                visible: Power.present
                text: `${Power.percent}%`
                color: Theme.fgDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
            }

            Item {
                Layout.fillWidth: true
            }

            IconButton {
                icon: Notifs.dnd ? "󰂛" : "󰂚"
                iconSize: Theme.smallFontSize
                iconColor: Notifs.dnd ? Theme.warning : Theme.fg
                onClicked: Notifs.dnd = !Notifs.dnd
            }

            IconButton {
                icon: "󰐥"
                iconSize: Theme.smallFontSize
                iconColor: Theme.error
                onClicked: IslandState.openPowerMenu()
            }
        }
    }
}
