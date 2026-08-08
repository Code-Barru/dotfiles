import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "../.."

// Rendu d'une notification, partagé entre le toast et le centre de notifications
Item {
    id: root

    property Notification notif: null
    property bool showClose: false
    property int bodyLines: 2

    signal closeRequested()

    readonly property bool critical: notif?.urgency === NotificationUrgency.Critical

    implicitHeight: layout.implicitHeight + 4

    RowLayout {
        id: layout

        anchors.fill: parent
        spacing: 10

        // ==================== ICÔNE ====================

        Item {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter

            ClippingRectangle {
                anchors.fill: parent
                radius: 8
                color: root.critical ? Theme.red : Theme.surface0

                Text {
                    anchors.centerIn: parent
                    visible: !image.visible && !appIcon.visible
                    text: root.critical ? "󰀪" : "󰂚"
                    color: root.critical ? Theme.crust : Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.largeFontSize
                }

                Image {
                    id: image

                    anchors.fill: parent
                    source: root.notif?.image ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize.width: 80
                    sourceSize.height: 80
                    visible: source != "" && status === Image.Ready
                }

                IconImage {
                    id: appIcon

                    anchors.centerIn: parent
                    implicitSize: 26
                    source: (root.notif?.appIcon ?? "") !== ""
                        ? Quickshell.iconPath(root.notif.appIcon, true)
                        : ""
                    visible: !image.visible && source != ""
                }
            }
        }

        // ==================== TEXTE ====================

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.notif?.appName ?? ""
                color: root.critical ? Theme.red : Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
                elide: Text.ElideRight
                visible: text !== ""
            }

            Text {
                Layout.fillWidth: true
                text: root.notif?.summary ?? ""
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.smallFontSize
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.notif?.body ?? ""
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                maximumLineCount: root.bodyLines
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        // ==================== FERMETURE ====================

        IconButton {
            Layout.alignment: Qt.AlignTop
            visible: root.showClose
            icon: "󰅖"
            iconSize: Theme.tinyFontSize
            iconColor: Theme.overlay0
            onClicked: root.closeRequested()
        }
    }
}
