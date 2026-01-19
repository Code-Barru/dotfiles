import QtQuick
import QtQuick.Layouts
import Quickshell.Io

ColumnLayout {
    id: networkControl
    spacing: Theme.spacing

    property string wifiStatus: "disconnected"
    property string wifiName: ""
    property int wifiSignal: 0
    property bool vpnConnected: false
    property string vpnState: "disconnected"  // "disconnected", "connecting", "connected"

    Process {
        id: nmcliWifi
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const parts = data.split(':')
                if (parts[0] === "yes" || parts[0] === "oui") {
                    networkControl.wifiStatus = "connected"
                    networkControl.wifiName = parts[1] || ""
                    networkControl.wifiSignal = parseInt(parts[2]) || 0
                }
            }
        }
    }

    Process {
        id: nmcliVpn
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "con", "show", "--active"]
        running: true

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const isConnected = data.includes("vpn") || data.includes("wireguard")
                networkControl.vpnConnected = isConnected
                networkControl.vpnState = isConnected ? "connected" : "disconnected"
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            nmcliWifi.running = true
            nmcliVpn.running = true
        }
    }

    // Header
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: "󰤨  Réseau"
            color: Theme.blue
            font.pixelSize: Theme.normalFontSize
            font.family: "JetBrains Mono"
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }
    }

    // WiFi Status
    Rectangle {
        Layout.fillWidth: true
        height: 65
        radius: 8
        color: Theme.surface0

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 1

            Text {
                text: networkControl.wifiStatus === "connected" ? "󰤨" : "󰤭"
                color: networkControl.wifiStatus === "connected" ? Theme.green : Theme.red
                font.pixelSize: 28
                font.family: "JetBrains Mono"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: networkControl.wifiStatus === "connected" ? networkControl.wifiName : "Déconnecté"
                    color: Theme.text
                    font.pixelSize: Theme.largeFontSize
                    font.family: "JetBrains Mono"
                    font.bold: true
                }

                Text {
                    visible: networkControl.wifiStatus === "connected"
                    text: "Signal: " + networkControl.wifiSignal + "%"
                    color: Theme.subtext0
                    font.pixelSize: Theme.smallFontSize
                    font.family: "JetBrains Mono"
                }
            }
        }
    }

    // VPN Toggle
    Rectangle {
        Layout.fillWidth: true
        height: 50
        radius: 8
        color: Theme.surface0

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing
            spacing: Theme.spacing

            Text {
                text: "󰦝  VPN"
                color: Theme.text
                font.pixelSize: Theme.largeFontSize
                font.family: "JetBrains Mono"
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Toggle {
                checked: networkControl.vpnState === "connected"
                connecting: networkControl.vpnState === "connecting"
                onToggled: state => {
                    // TODO: Implémenter toggle VPN
                    // Pour tester l'état connecting, décommenter la ligne suivante:
                    // networkControl.vpnState = state ? "connecting" : "disconnected"
                    console.log("VPN toggle:", state)
                }
            }
        }
    }
}
