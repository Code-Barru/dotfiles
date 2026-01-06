import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "components"

PanelWindow {
    id: bar

    // Catppuccin Mocha
    readonly property color base: "#1e1e2e"
    readonly property color crust: "#11111b"
    readonly property color surface0: "#313244"
    readonly property color text_: "#89b4fa"
    readonly property color subtext0: "#a6adc8"
    readonly property color blue: "#89b4fa"
    readonly property color green: "#a6e3a1"
    readonly property color yellow: "#f9e2af"
    readonly property color red: "#f38ba8"
    readonly property color mauve: "#cba6f7"

    anchors {
        top: true
        left: true
        right: true
    }

    height: 42
    color: crust

    WlrLayershell.namespace: "quickshell"
    WlrLayershell.layer: WlrLayer.Top

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 0

        // Gauche - Workspaces
        RowLayout {
          Layout.alignment: Qt.AlignRight
          spacing: 16

          Workspaces {
              Layout.alignment: Qt.AlignLeft
          }
          SystemStats {}
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // Droite - Modules
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 16

            Network {}
            Audio {}
            Brightness {}
            Battery {}

            // Horloge
            Text {
                color: text_
                font.pixelSize: 16
                font.family: "JetBrains Mono"
                text: Qt.formatDateTime(new Date(), "ddd dd MMM  HH:mm")

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: parent.text = Qt.formatDateTime(new Date(), "ddd dd MMM  HH:mm")
                }
            }
        }
    }
}
