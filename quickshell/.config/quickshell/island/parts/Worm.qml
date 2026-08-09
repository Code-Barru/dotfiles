import QtQuick
import "../.."

Rectangle {
    id: root

    property int slots: Theme.wormSlots
    property int index: 0

    readonly property real slotWidth: width / slots

    implicitWidth: Theme.wormTrackWidth
    implicitHeight: Theme.wormHeight
    radius: height / 2
    color: Theme.surfaceHi

    function jumpTo(i) {
        retract.stop()
        index = i
        worm.x = i * slotWidth
        worm.width = slotWidth
    }

    function travelTo(i) {
        if (i === index)
            return

        const from = Math.min(index, i) * slotWidth
        const to = (Math.max(index, i) + 1) * slotWidth

        index = i
        worm.x = from
        worm.width = to - from

        retract.restart()
    }

    Timer {
        id: retract
        interval: 170
        onTriggered: {
            worm.x = root.index * root.slotWidth
            worm.width = root.slotWidth
        }
    }

    Rectangle {
        id: worm

        height: parent.height
        radius: height / 2
        color: Theme.accent

        Behavior on x {
            NumberAnimation {
                duration: 260
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.34, 1.08, 0.5, 1, 1, 1]
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 380
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.34, 1.08, 0.5, 1, 1, 1]
            }
        }
    }
}
