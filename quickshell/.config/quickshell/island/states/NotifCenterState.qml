import QtQuick
import QtQuick.Layouts
import "../.."
import "../../services"
import "../parts"

// Historique des notifications
Item {
    id: root

    readonly property int rowHeight: 72
    readonly property int headerHeight: 34

    implicitWidth: Theme.notifCenterWidth
    implicitHeight: Math.min(
        Theme.notifCenterMaxHeight,
        headerHeight + Theme.islandPadding * 2 + Math.max(rowHeight, Notifs.count * rowHeight))

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.islandPadding
        spacing: 6

        // ==================== EN-TÊTE ====================

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.headerHeight
            spacing: 8

            Text {
                text: "Notifications"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.smallFontSize
                font.bold: true
            }

            Rectangle {
                visible: Notifs.count > 0
                implicitWidth: countLabel.implicitWidth + 12
                implicitHeight: 18
                radius: 9
                color: Theme.surface0

                Text {
                    id: countLabel
                    anchors.centerIn: parent
                    text: Notifs.count
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.tinyFontSize
                }
            }

            Item { Layout.fillWidth: true }

            IconButton {
                visible: Notifs.count > 0
                icon: "󰎟"
                iconSize: Theme.smallFontSize
                iconColor: Theme.overlay0
                onClicked: Notifs.clearAll()
            }
        }

        // ==================== LISTE ====================

        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: Notifs.count === 0
            text: "Aucune notification"
            color: Theme.overlay0
            font.family: Theme.fontFamily
            font.pixelSize: Theme.tinyFontSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: Notifs.count > 0
            clip: true
            spacing: 4
            boundsBehavior: Flickable.StopAtBounds

            // Les plus récentes en haut
            model: Notifs.history.slice().reverse()

            delegate: Rectangle {
                id: row

                required property var modelData

                width: ListView.view.width
                height: root.rowHeight - 4
                radius: 10
                color: Theme.base

                NotifCard {
                    anchors.fill: parent
                    anchors.margins: 8
                    notif: row.modelData
                    bodyLines: 1
                    showClose: true
                    onCloseRequested: Notifs.dismiss(row.modelData)
                }
            }
        }
    }
}
