import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "components/controlcenter"

PanelWindow {
    id: controlCenter

    property bool isOpen: false
    visible: isOpen || slideAnimation.running

    width: 550
    height: contentColumn.implicitHeight + 40

    anchors {
        top: true
        right: true
    }

    margins {
        top: 50
        right: isOpen ? 16 : -(controlCenter.width + 50)
    }

    Behavior on margins.right {
        id: slideAnimation
        NumberAnimation {
            duration: Theme.fastDuration
            easing.type: Easing.OutCubic
        }
    }

    WlrLayershell.namespace: "quickshell-controlcenter"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrFocus.Exclusive

    color: "transparent"

    GlobalShortcut {
        appid: "quickshell"
        name: "controlcenter_toggle"
        description: "Toggle Control Center"

        onPressed: {
            controlCenter.isOpen = !controlCenter.isOpen
        }
    }

    // Container avec opacité animée
    Item {
        anchors.fill: parent
        opacity: isOpen ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.slowDuration
                easing.type: Easing.OutQuad
            }
        }

        // Backdrop semi-transparent
        Rectangle {
            id: backdrop
            anchors.fill: parent
            color: Theme.crust
            opacity: 0.95
            radius: 12
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
        }

        // Brightness Control
        BrightnessControl {
            Layout.fillWidth: true
        }

        // Network Control
        NetworkControl {
            Layout.fillWidth: true
        }

            // Notifications Area
            NotificationsArea {
                Layout.fillWidth: true
            }
        }
    }

    // Close on Escape
    Keys.onEscapePressed: {
        controlCenter.isOpen = false
    }
}
