import QtQuick
import "../.."
import "../../services"

Row {
    id: root

    property int count: Cava.bars
    property int maxHeight: Theme.barMaxHeight
    property int barWidth: Theme.barWidth

    function level(i) {
        const src = count > 1
            ? Math.round(i * (Cava.bars - 1) / (count - 1))
            : 0
        return Cava.values[src] ?? 0
    }

    spacing: Theme.barSpacing

    Repeater {
        model: root.count

        Rectangle {
            required property int index

            anchors.verticalCenter: parent.verticalCenter
            width: root.barWidth

            height: Math.max(Theme.barWidth, root.level(index) * root.maxHeight)
            radius: width / 2
            color: Theme.blue

            Behavior on height {
                NumberAnimation {
                    duration: 80
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}
