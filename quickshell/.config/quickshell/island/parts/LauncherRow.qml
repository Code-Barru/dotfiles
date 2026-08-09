import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root

    property var app: null
    property bool selected: false

    signal activated()

    readonly property string iconSource: (app?.icon ?? "") !== ""
        ? Quickshell.iconPath(app.icon, true)
        : ""

    height: Theme.launcherRowHeight
    radius: 10
    color: root.selected ? Theme.surface : (hover.hovered ? Theme.bg : "transparent")

    Behavior on color {
        ColorAnimation { duration: Theme.fastDuration }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.activated()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 12
        spacing: 12

        Item {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                visible: !icon.visible
                text: "󰣆"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.largeFontSize
            }

            IconImage {
                id: icon

                anchors.centerIn: parent
                implicitSize: 28
                source: root.iconSource
                visible: source != ""
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.app?.name ?? ""
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.smallFontSize
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.app?.genericName ?? ""
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        Text {
            visible: root.selected
            text: "󰌑"
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.tinyFontSize
        }
    }
}
