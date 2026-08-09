import Quickshell.Io
import QtQuick
import "../.."

Item {
    id: root

    property string path: ""
    property bool selected: false
    property bool active: false

    property string label: ""
    property var swatches: []

    signal activated()

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.activated()
    }

    FileView {
        path: root.path
        printErrors: false

        onLoaded: {
            const data = JSON.parse(text())
            const c = data.colors

            root.label = data.label ?? ""
            root.swatches = [c.bg, c.surface, c.accent, c.accentAlt, c.success, c.error]
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4

        radius: 8
        color: root.selected ? Theme.surface : "transparent"
        border.width: root.selected ? 2 : (hover.hovered ? 1 : 0)
        border.color: root.selected ? Theme.accent : Theme.surfaceMax

        Behavior on border.width {
            NumberAnimation { duration: Theme.fastDuration }
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacing
            anchors.verticalCenter: parent.verticalCenter

            text: root.label
            color: root.active ? Theme.accent : Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.normalFontSize
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing
            anchors.verticalCenter: parent.verticalCenter

            spacing: 4

            Repeater {
                model: root.swatches

                Rectangle {
                    required property color modelData

                    width: Theme.themeSwatchSize
                    height: Theme.themeSwatchSize
                    radius: Theme.themeSwatchSize / 2
                    color: modelData
                }
            }
        }
    }
}
