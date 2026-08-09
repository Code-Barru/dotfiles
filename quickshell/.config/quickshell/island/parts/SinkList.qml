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
    model: Audio.sinks
    boundsBehavior: Flickable.StopAtBounds

    delegate: Rectangle {
        id: row

        required property var modelData
        readonly property bool current: modelData === Audio.sink

        width: ListView.view.width
        height: 30
        radius: 8
        color: hover.hovered ? Theme.surface : "transparent"

        HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: Audio.setSink(row.modelData)
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            Text {
                text: "󰓃"
                color: row.current ? Theme.accent : Theme.fgDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
            }

            Text {
                Layout.fillWidth: true
                text: Audio.sinkLabel(row.modelData)
                color: row.current ? Theme.fg : Theme.fgDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
                elide: Text.ElideRight
            }

            Text {
                visible: row.current
                text: "󰄬"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
            }
        }
    }
}
