import Quickshell.Widgets
import QtQuick
import "../.."

Item {
    id: root

    property string path: ""
    property bool selected: false
    property bool active: false

    signal activated()

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.activated()
    }

    ClippingRectangle {
        anchors.fill: parent
        anchors.margins: 4

        radius: 8
        color: Theme.surface

        Image {
            anchors.fill: parent
            source: root.path !== "" ? `file://${root.path}` : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: Theme.wallpaperCellWidth * 2
            sourceSize.height: Theme.wallpaperCellHeight * 2
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4

        radius: 8
        color: "transparent"
        border.width: root.selected ? 2 : (hover.hovered ? 1 : 0)
        border.color: root.selected ? Theme.accent : Theme.surfaceMax

        Behavior on border.width {
            NumberAnimation { duration: Theme.fastDuration }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8

        visible: root.active
        width: 20
        height: 20
        radius: 10
        color: Theme.bgDeep

        Text {
            anchors.centerIn: parent
            text: "󰄬"
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.tinyFontSize
        }
    }
}
