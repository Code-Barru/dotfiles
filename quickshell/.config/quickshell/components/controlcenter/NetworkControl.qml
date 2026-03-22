import QtQuick
import QtQuick.Layouts
import Quickshell.Io

ColumnLayout {
    id: networkControl
    spacing: Theme.spacing

    // Contrôle de visibilité (lié à ControlCenter.isOpen)
    property bool isOpen: false

    property string wifiStatus: "disconnected"
    property string wifiName: ""
    property int wifiSignal: 0
    property string wifiIP: ""
    property string wifiDevice: ""
    property string publicIP: ""
    property bool vpnConnected: false
    property string vpnState: "disconnected"  // "disconnected", "connecting", "connected"
    property string vpnIP: ""
    property string vpnConnectionName: "maison"

    // ==================== SURVEILLANCE WiFi ====================
    
    Process {
        id: nmcliWifi
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,DEVICE", "dev", "wifi"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const parts = data.split(':')
                if (parts[0] === "yes" || parts[0] === "oui") {
                    networkControl.wifiStatus = "connected"
                    networkControl.wifiName = parts[1] || ""
                    networkControl.wifiSignal = parseInt(parts[2]) || 0
                    networkControl.wifiDevice = parts[3] || ""
                    
                    // Récupérer l'IP du device WiFi
                    if (networkControl.wifiDevice) {
                        getWifiIP.command = ["nmcli", "-t", "-f", "IP4.ADDRESS", "device", "show", networkControl.wifiDevice]
                        getWifiIP.running = true
                    }
                    
                    // Récupérer l'IP publique
                    getPublicIP.running = true
                }
            }
        }
    }

    Process {
        id: getWifiIP
        command: ["nmcli", "-t", "-f", "IP4.ADDRESS", "device", "show", "wlan0"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                // Format: IP4.ADDRESS[1]:10.0.0.123/24
                const match = data.match(/IP4\.ADDRESS\[\d+\]:([^\/]+)/)
                if (match) {
                    networkControl.wifiIP = match[1]
                }
            }
        }
    }

    Process {
        id: getPublicIP
        command: ["curl", "-s", "--max-time", "3", "https://api.ipify.org"]
        running: false

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                networkControl.publicIP = data.trim()
            }
        }
    }

    // ==================== SURVEILLANCE VPN ====================

    Process {
        id: nmcliVpnCheck
        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "con", "show", "--active"]
        running: false

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const isVpnActive = data.includes(networkControl.vpnConnectionName + ":vpn:")
                if (isVpnActive && networkControl.vpnState !== "connecting") {
                    networkControl.vpnState = "connected"
                    // Récupérer l'IP VPN
                    getVpnIP.running = true
                    // Rafraîchir l'IP publique (qui devrait changer)
                    getPublicIP.running = true
                } else if (!isVpnActive && networkControl.vpnState === "connected") {
                    networkControl.vpnState = "disconnected"
                    networkControl.vpnIP = ""
                    // Rafraîchir l'IP publique
                    getPublicIP.running = true
                }
            }
        }
    }

    Process {
        id: getVpnIP
        command: ["nmcli", "-t", "-f", "IP4.ADDRESS", "device", "show", "tun0"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const match = data.match(/IP4\.ADDRESS\[\d+\]:([^\/]+)/)
                if (match) {
                    networkControl.vpnIP = match[1]
                }
            }
        }
    }

    Process {
        id: vpnConnect
        command: ["nmcli", "connection", "up", networkControl.vpnConnectionName]
        running: false

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                console.log("VPN connect output:", data)
                if (data.includes("successfully activated") || data.includes("Connection successfully")) {
                    vpnConnectionTimeout.stop()
                    networkControl.vpnState = "connected"
                    nmcliVpnCheck.running = true
                }
            }
        }

        stderr: SplitParser {
            splitMarker: ""
            onRead: data => {
                console.log("VPN connect error:", data)
                vpnConnectionTimeout.stop()
                networkControl.vpnState = "disconnected"
            }
        }
    }

    Process {
        id: vpnDisconnect
        command: ["nmcli", "connection", "down", networkControl.vpnConnectionName]
        running: false

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                console.log("VPN disconnect output:", data)
                networkControl.vpnState = "disconnected"
                networkControl.vpnIP = ""
                nmcliVpnCheck.running = true
            }
        }
    }

    // ==================== TIMERS ====================

    // Poll immédiat à l'ouverture du Control Center
    onIsOpenChanged: {
        if (isOpen) {
            nmcliWifi.running = true
            nmcliVpnCheck.running = true
            getPublicIP.running = true
        }
    }

    Timer {
        interval: 3000
        running: networkControl.isOpen
        repeat: true
        onTriggered: {
            nmcliWifi.running = true
            nmcliVpnCheck.running = true
        }
    }

    Timer {
        interval: 30000
        running: networkControl.isOpen
        repeat: true
        onTriggered: {
            getPublicIP.running = true
        }
    }

    Timer {
        id: vpnConnectionTimeout
        interval: 30000
        repeat: false
        onTriggered: {
            console.log("VPN connection timeout")
            networkControl.vpnState = "disconnected"
        }
    }

    // ==================== UI ====================

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

    // Layout horizontal : WiFi | VPN (50/50)
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        // ===== WIDGET WiFi =====
        Rectangle {
            id: wifiBox
            Layout.fillWidth: true
            implicitHeight: wifiContent.implicitHeight + 28
            radius: 8
            color: Theme.surface0

            ColumnLayout {
                id: wifiContent
                anchors.fill: parent
                anchors.margins: 14
                spacing: 6

                // Ligne titre : icône + nom
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: networkControl.wifiStatus === "connected" ? "󰤨" : "󰤭"
                        color: networkControl.wifiStatus === "connected" ? Theme.green : Theme.red
                        font.pixelSize: 24
                        font.family: "JetBrains Mono"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: networkControl.wifiStatus === "connected" ? networkControl.wifiName : "Déconnecté"
                            color: Theme.text
                            font.pixelSize: 16
                            font.family: "JetBrains Mono"
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: networkControl.wifiStatus === "connected"
                            text: "Signal: " + networkControl.wifiSignal + "%"
                            color: Theme.subtext0
                            font.pixelSize: 12
                            font.family: "JetBrains Mono"
                        }
                    }
                }

                // Séparateur
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.base
                }

                // IP locale
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: networkControl.wifiStatus === "connected"

                    Text {
                        text: "󰆧 Local"
                        color: Theme.subtext0
                        font.pixelSize: 12
                        font.family: "JetBrains Mono"
                        Layout.preferredWidth: 60
                    }

                    Text {
                        text: networkControl.wifiIP || "..."
                        color: Theme.text
                        font.pixelSize: 12
                        font.family: "JetBrains Mono"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // IP publique
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: networkControl.wifiStatus === "connected"

                    Text {
                        text: "󰞉 Public"
                        color: Theme.subtext0
                        font.pixelSize: 12
                        font.family: "JetBrains Mono"
                        Layout.preferredWidth: 60
                    }

                    Text {
                        text: networkControl.publicIP || "..."
                        color: Theme.text
                        font.pixelSize: 12
                        font.family: "JetBrains Mono"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // ===== WIDGET VPN =====
        Rectangle {
            id: vpnBox
            Layout.fillWidth: true
            implicitHeight: wifiBox.height
            radius: 8
            color: Theme.surface0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 6

                // Ligne titre
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "󰦝"
                        color: {
                            if (networkControl.vpnState === "connected") return Theme.blue
                            if (networkControl.vpnState === "connecting") return Theme.yellow
                            return Theme.subtext0
                        }
                        font.pixelSize: 24
                        font.family: "JetBrains Mono"

                        // Animation pulse si connecting
                        SequentialAnimation on opacity {
                            running: networkControl.vpnState === "connecting"
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.3; duration: 500 }
                            NumberAnimation { from: 0.3; to: 1.0; duration: 500 }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: {
                                if (networkControl.vpnState === "connected") return "VPN Connecté"
                                if (networkControl.vpnState === "connecting") return "Connexion..."
                                return "VPN Déconnecté"
                            }
                            color: Theme.text
                            font.pixelSize: 16
                            font.family: "JetBrains Mono"
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: networkControl.vpnConnectionName
                            color: Theme.subtext0
                            font.pixelSize: 12
                            font.family: "JetBrains Mono"
                        }
                    }
                }

                // Séparateur
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.base
                }

                // IP VPN
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: networkControl.vpnState === "connected"

                    Text {
                        text: "󰆧 VPN IP"
                        color: Theme.subtext0
                        font.pixelSize: 12
                        font.family: "JetBrains Mono"
                        Layout.preferredWidth: 60
                    }

                    Text {
                        text: networkControl.vpnIP || "..."
                        color: Theme.text
                        font.pixelSize: 12
                        font.family: "JetBrains Mono"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // Spacer en haut pour pousser le bouton vers le bas
                Item { Layout.fillHeight: true }

                // Gros bouton lock
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 60
                    height: 50
                    radius: 8
                    color: {
                        if (networkControl.vpnState === "connected") return Theme.blue
                        if (networkControl.vpnState === "connecting") return Theme.yellow
                        return Theme.surface0
                    }
                    border.width: 2
                    border.color: {
                        if (networkControl.vpnState === "connected") return Theme.blue
                        if (networkControl.vpnState === "connecting") return Theme.yellow
                        return Theme.subtext0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰌾"
                        color: {
                            if (networkControl.vpnState === "connected") return Theme.text
                            if (networkControl.vpnState === "connecting") return Theme.text
                            return Theme.subtext0
                        }
                        font.pixelSize: 28
                        font.family: "JetBrains Mono"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (networkControl.vpnState === "connecting") {
                                // Annuler la connexion en cours
                                console.log("VPN: Connection cancelled")
                                vpnConnectionTimeout.stop()
                                vpnConnect.running = false
                                networkControl.vpnState = "disconnected"
                            } else if (networkControl.vpnState === "connected") {
                                // Déconnexion demandée
                                console.log("VPN: Disconnecting from", networkControl.vpnConnectionName)
                                vpnConnectionTimeout.stop()
                                networkControl.vpnState = "disconnected"
                                vpnDisconnect.running = true
                            } else {
                                // Connexion demandée
                                console.log("VPN: Starting connection to", networkControl.vpnConnectionName)
                                networkControl.vpnState = "connecting"
                                vpnConnect.running = true
                                vpnConnectionTimeout.restart()
                            }
                        }
                    }
                }

                // Spacer en bas pour équilibrer
                Item { Layout.fillHeight: true }
            }
        }
    }
}
