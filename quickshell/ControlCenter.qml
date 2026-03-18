import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "components/controlcenter"

Item {
    id: controlCenterRoot

    property bool isOpen: false

    // État centralisé volume/brightness (alimenté par l'OSD via shell.qml)
    property int currentVolume: 0
    property bool currentMuted: false
    property int currentBrightness: 0

    GlobalShortcut {
        appid: "quickshell"
        name: "controlcenter_toggle"
        description: "Toggle Control Center"

        onPressed: {
            controlCenterRoot.isOpen = !controlCenterRoot.isOpen
        }
    }

    // Backdrop invisible plein écran pour capter les clics en dehors
    PanelWindow {
        id: backdrop
        visible: controlCenterRoot.isOpen

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"

        WlrLayershell.namespace: "quickshell-controlcenter-backdrop"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // Cliquer sur le backdrop ferme le control center
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: mouse => {
                mouse.accepted = true
                controlCenterRoot.isOpen = false
            }
        }
    }

    // Panneau du Control Center
    PanelWindow {
        id: controlCenter

        visible: controlCenterRoot.isOpen

        implicitWidth: 550
        implicitHeight: contentColumn.implicitHeight + 40

        anchors {
            top: true
            right: true
        }

        margins {
            top: 50
            right: controlCenterRoot.isOpen ? 16 : -(controlCenter.width + 50)
        }

        Behavior on margins.right {
            id: slideAnimation
            NumberAnimation {
                duration: Theme.fastDuration
                easing.type: Easing.OutCubic
            }
        }

        WlrLayershell.namespace: "quickshell-controlcenter-panel"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: controlCenterRoot.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        color: "transparent"

        // Close on Escape
        Keys.onEscapePressed: {
            controlCenterRoot.isOpen = false
        }

        // Container avec opacité animée
        Item {
            anchors.fill: parent
            opacity: controlCenterRoot.isOpen ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.slowDuration
                    easing.type: Easing.OutQuad
                }
            }

            // Backdrop semi-transparent
            Rectangle {
                id: panelBackdrop
                anchors.fill: parent
                color: Theme.crust
                opacity: 0.95
                radius: 12

                // Empêcher les clics de passer à travers
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.AllButtons
                    onPressed: mouse => mouse.accepted = true
                }
            }

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: Theme.margin
                spacing: Theme.largeSpacing

                // Header
                Text {
                    text: "Centre de Contrôle"
                    color: Theme.blue
                    font.pixelSize: Theme.headerFontSize
                    font.family: "JetBrains Mono"
                    font.bold: true
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.surface0
                }

                // Volume Control
                VolumeControl {
                    Layout.fillWidth: true
                    volume: controlCenterRoot.currentVolume
                    muted: controlCenterRoot.currentMuted
                }

                // Brightness Control
                BrightnessControl {
                    Layout.fillWidth: true
                    percent: controlCenterRoot.currentBrightness
                }

                // Network Control
                NetworkControl {
                    Layout.fillWidth: true
                    isOpen: controlCenterRoot.isOpen
                }

                // Notifications Area
                NotificationsArea {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
