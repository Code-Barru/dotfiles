import QtQuick
import QtQuick.Layouts
import "../.."

ColumnLayout {
    id: root

    property string icon: ""
    property string label: ""
    property string status: ""

    property bool showToggle: true
    property bool checked: false
    property bool busy: false

    property bool expandable: false
    property bool expanded: false

    property real expansionHeight: expanded ? inner.implicitHeight + 6 : 0

    default property alias expandedContent: inner.data

    signal toggled(bool state)
    signal headerClicked

    spacing: 0

    Behavior on expansionHeight {
        NumberAnimation { duration: Theme.normalDuration; easing.type: Easing.OutCubic }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.tileHeight
        radius: 12
        color: header.hovered && root.expandable ? Theme.surface0 : Theme.base

        Behavior on color {
            ColorAnimation { duration: Theme.fastDuration }
        }

        HoverHandler {
            id: header
            enabled: root.expandable
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            enabled: root.expandable
            onTapped: root.headerClicked()
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 10
            spacing: 10

            Text {
                text: root.icon
                color: root.checked ? Theme.blue : Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.largeFontSize

                Behavior on color {
                    ColorAnimation { duration: Theme.fastDuration }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: root.label
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.tinyFontSize
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.status
                    color: Theme.overlay0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.tinyFontSize
                    elide: Text.ElideRight
                    visible: text !== ""
                }
            }

            Toggle {
                visible: root.showToggle
                checked: root.checked
                busy: root.busy
                onToggled: state => root.toggled(state)
            }

            Text {
                visible: root.expandable
                text: "󰅀"
                color: Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
                rotation: root.expanded ? 180 : 0

                Behavior on rotation {
                    NumberAnimation { duration: Theme.normalDuration; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.expansionHeight
        clip: true

        ColumnLayout {
            id: inner

            width: parent.width
            y: 6
            spacing: 4
        }
    }
}
