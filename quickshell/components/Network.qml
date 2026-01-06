import QtQuick
import QtQuick.Layouts
import Quickshell.Io

RowLayout {
    id: network
    spacing: 6

    property string wifiStatus: "disconnected"
    property string wifiName: ""
    property bool vpnConnected: false

    Process {
        id: nmcliWifi
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID", "dev", "wifi"]
        running: true

        onRunningChanged: {
            if (running) {
                network.wifiStatus = "disconnected"
                network.wifiName = ""
            }
        }

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const parts = data.split(':')
                if (parts[0] === "yes" || parts[0] === "oui") {
                    network.wifiStatus = "connected"
                    network.wifiName = parts[1] || ""
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
                network.vpnConnected = data.includes("vpn") || data.includes("wireguard")
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            nmcliWifi.running = true
            nmcliVpn.running = true
        }
    }

    Text {
        color: network.wifiStatus === "connected" ? bar.text_ : bar.red
        font.pixelSize: 16
        font.family: "JetBrains Mono"
        text: network.wifiStatus === "connected" ? "󰤨" : "󰤭"
    }

    Text {
        visible: network.vpnConnected
        color: bar.green
        font.pixelSize: 16
        font.family: "JetBrains Mono"
        text: "󰦝"
    }
}
