import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: Theme.spacing

    // Header
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: "󰂚  Notifications"
            color: Theme.blue
            font.pixelSize: Theme.normalFontSize
            font.family: "JetBrains Mono"
        }

        Item { Layout.fillWidth: true }
    }

    // Placeholder
    Rectangle {
        Layout.fillWidth: true
        height: 100
        radius: 8
        color: Theme.surface0

        Text {
            anchors.centerIn: parent
            text: "Aucune notification"
            color: Theme.overlay0
            font.pixelSize: Theme.smallFontSize
            font.family: "JetBrains Mono"
            font.italic: true
        }
    }
}
