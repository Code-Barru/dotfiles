import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../controlcenter"

PanelWindow {
    id: powerMenu

    property bool isOpen: false
    visible: isOpen || contentOpacity > 0

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    property real contentOpacity: 0

    Behavior on contentOpacity {
        NumberAnimation {
            duration: Theme.slowDuration
            easing.type: Easing.OutQuad
        }
    }

    color: "transparent"

    WlrLayershell.namespace: "quickshell-powermenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: powerMenu.isOpen ? WlrFocus.Exclusive : WlrFocus.None

    GlobalShortcut {
        appid: "quickshell"
        name: "powermenu_toggle"
        description: "Toggle Power Menu"

        onPressed: {
            powerMenu.isOpen = !powerMenu.isOpen
        }
    }

    onIsOpenChanged: {
        if (isOpen) {
            contentOpacity = 1.0
        } else {
            contentOpacity = 0.0
        }
    }

    Keys.onEscapePressed: {
        powerMenu.isOpen = false
    }

    // Backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Theme.crust
        opacity: powerMenu.contentOpacity * 0.85

        // Click backdrop to close
        MouseArea {
            enabled: powerMenu.isOpen
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: mouse => {
                mouse.accepted = true
                powerMenu.isOpen = false
            }
        }

        // Centered content container
        Item {
            anchors.centerIn: parent
            width: 600
            height: contentRect.height

            // Prevent clicks from propagating to backdrop
            MouseArea {
                enabled: powerMenu.isOpen
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onPressed: mouse => mouse.accepted = true
            }

            Rectangle {
                id: contentRect
                anchors.centerIn: parent
                width: 600
                height: gridLayout.implicitHeight + 48
                radius: 16
                color: Theme.base
                opacity: powerMenu.contentOpacity * 0.95

                GridLayout {
                    id: gridLayout
                    anchors.centerIn: parent
                    columns: 3
                    rows: 2
                    columnSpacing: 24
                    rowSpacing: 24

                    PowerAction {
                        icon: "󰐥"
                        label: "Éteindre"
                        actionColor: Theme.red
                        command: "systemctl poweroff"
                        onTriggered: powerMenu.isOpen = false
                    }

                    PowerAction {
                        icon: "󰜉"
                        label: "Redémarrer"
                        actionColor: Theme.yellow
                        command: "systemctl reboot"
                        onTriggered: powerMenu.isOpen = false
                    }

                    PowerAction {
                        icon: ""
                        label: "Verrouiller"
                        actionColor: Theme.blue
                        command: "hyprlock"
                        onTriggered: powerMenu.isOpen = false
                    }

                    PowerAction {
                        icon: "󰍃"
                        label: "Déconnexion"
                        actionColor: Theme.mauve
                        command: "hyprctl dispatch exit"
                        onTriggered: powerMenu.isOpen = false
                    }

                    PowerAction {
                        icon: "󰒲"
                        label: "Suspendre"
                        actionColor: Theme.green
                        command: "systemctl suspend"
                        onTriggered: powerMenu.isOpen = false
                    }

                    PowerAction {
                        icon: "󰋊"
                        label: "Hiberner"
                        actionColor: Theme.green
                        command: "systemctl hibernate"
                        onTriggered: powerMenu.isOpen = false
                    }
                }
            }
        }
    }
}
