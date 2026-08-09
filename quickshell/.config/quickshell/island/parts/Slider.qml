import QtQuick
import "../.."

Rectangle {
    id: root

    property real value: 0
    property real min: 0
    property real max: 100

    readonly property bool dragging: mouse.pressed
    property real dragValue: 0

    readonly property real displayValue: dragging ? dragValue : value
    readonly property real ratio: max > min
        ? Math.max(0, Math.min(1, (displayValue - min) / (max - min)))
        : 0

    signal userChanged(real newValue)

    implicitWidth: 160
    implicitHeight: Theme.sliderHeight
    radius: height / 2
    color: Theme.surface
    opacity: enabled ? 1.0 : 0.35

    Rectangle {
        id: fill

        width: root.ratio * parent.width
        height: parent.height
        radius: parent.radius
        color: Theme.accent
    }

    Rectangle {
        width: 14
        height: 14
        radius: 7
        color: Theme.accent
        border.width: 2
        border.color: Theme.fg
        x: Math.max(0, Math.min(parent.width - width, fill.width - width / 2))
        y: (parent.height - height) / 2

        Behavior on x {
            enabled: !root.dragging
            NumberAnimation { duration: Theme.fastDuration; easing.type: Easing.OutQuad }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        anchors.margins: -6
        cursorShape: Qt.PointingHandCursor

        function apply(x) {
            const clamped = Math.max(0, Math.min(x - 6, root.width))
            const v = Math.round(root.min + (clamped / root.width) * (root.max - root.min))

            if (v !== root.dragValue) {
                root.dragValue = v
                root.userChanged(v)
            }
        }

        onPressed: event => {
            root.dragValue = root.value
            apply(event.x)
        }

        onPositionChanged: event => {
            if (pressed)
                apply(event.x)
        }
    }
}
