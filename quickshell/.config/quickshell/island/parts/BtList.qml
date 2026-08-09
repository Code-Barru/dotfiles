import QtQuick
import QtQuick.Layouts
import "../.."
import "../../services"

ListView {
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: Math.min(Theme.listMaxHeight, Math.max(30, contentHeight))

    clip: true
    spacing: 2
    model: Bt.sorted
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
            onTapped: Bt.toggleDevice(row.modelData)
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            Text {
                text: row.modelData.connected ? "󰂱" : "󰂯"
                color: row.modelData.connected ? Theme.accent : Theme.fgDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
            }

            Text {
                Layout.fillWidth: true
                text: row.modelData.deviceName
                color: row.modelData.connected ? Theme.fg : Theme.fgDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
                elide: Text.ElideRight
            }

            Text {
                visible: row.modelData.batteryAvailable
                text: `${Math.round(row.modelData.battery * 100)}%`
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
            }

            Text {
                visible: row.modelData.pairing || row.modelData.connected
                text: row.modelData.pairing ? "󰑮" : "󰄬"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
            }
        }
    }
}
