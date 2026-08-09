import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../services"
import "../parts"

Item {
    id: root

    implicitWidth: Theme.mediaVizWidth
    implicitHeight: Theme.mediaVizHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 10

        ClippingRectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            radius: 5
            color: Theme.surface

            Image {
                anchors.fill: parent
                source: Media.art
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                sourceSize.width: 40
                sourceSize.height: 40
            }
        }

        Text {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.smallFontSize
        }

        CavaBars {
            Layout.preferredHeight: Theme.barMaxHeight
        }
    }
}
