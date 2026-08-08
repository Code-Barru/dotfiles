import Quickshell
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../services"
import "../parts"

Item {
    id: root

    implicitWidth: Math.max(Theme.hourWidth, row.implicitWidth + Theme.islandPadding * 2)
    implicitHeight: Theme.hourHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: 10

        // La rangée garde sa largeur : la pilule se rétrécit autour d'elle et
        // rogne les pastilles pendant qu'elles s'effacent, symétriquement, donc
        // l'horloge ne bouge pas
        WorkspaceDots {
            first: 1
            opacity: Workspaces.revealed ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: Theme.fadeDuration }
            }
        }

        Text {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.smallFontSize
        }

        WorkspaceDots {
            first: 3
            opacity: Workspaces.revealed ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: Theme.fadeDuration }
            }
        }
    }
}
