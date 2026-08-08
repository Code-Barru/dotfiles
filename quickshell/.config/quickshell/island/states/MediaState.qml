import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../services"
import "../parts"

// Lecteur média : pochette, titre/artiste, progression, contrôles, heure
Item {
    id: root

    implicitWidth: Theme.mediaWidth
    implicitHeight: Theme.mediaHeight

    // Le rafraîchissement de la position n'a lieu que tant que cet état est monté
    Component.onCompleted: Media.positionTracking = true
    Component.onDestruction: Media.positionTracking = false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.islandPadding
        spacing: Theme.spacing

        // ==================== POCHETTE ====================

        ClippingRectangle {
            Layout.preferredWidth: 76
            Layout.preferredHeight: 76
            Layout.alignment: Qt.AlignVCenter
            radius: 10
            color: Theme.surface0

            Text {
                anchors.centerIn: parent
                visible: cover.status !== Image.Ready
                text: "󰝚"
                color: Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: 30
            }

            Image {
                id: cover

                anchors.fill: parent
                source: Media.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                sourceSize.width: 152
                sourceSize.height: 152
                visible: status === Image.Ready
            }
        }

        // ==================== INFOS ====================

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: Media.title !== "" ? Media.title : "Aucune lecture"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.smallFontSize
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: Media.artist
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.tinyFontSize
                elide: Text.ElideRight
                visible: text !== ""
            }

            SeekBar {
                Layout.fillWidth: true
                Layout.topMargin: 2
                progress: Media.progress
                seekable: Media.canSeek
                onSeeked: ratio => Media.seekRatio(ratio)
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: Media.formatTime(Media.position)
                    color: Theme.overlay0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.tinyFontSize
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: Media.length > 0 ? Media.formatTime(Media.length) : "--:--"
                    color: Theme.overlay0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.tinyFontSize
                }
            }
        }

        // ==================== HEURE + CONTRÔLES ====================

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(clock.date, "HH:mm")
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.largeFontSize
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2

                IconButton {
                    icon: "󰒮"
                    enabled: Media.canGoPrevious
                    onClicked: Media.previous()
                }

                IconButton {
                    icon: Media.isPlaying ? "󰏤" : "󰐊"
                    iconSize: Theme.largeFontSize
                    iconColor: Theme.blue
                    enabled: Media.canTogglePlaying
                    onClicked: Media.togglePlaying()
                }

                IconButton {
                    icon: "󰒭"
                    enabled: Media.canGoNext
                    onClicked: Media.next()
                }
            }
        }
    }
}
