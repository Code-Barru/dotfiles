import QtQuick
import "../.."

Rectangle {
    id: root

    property bool checked: false
    property bool busy: false

    signal toggled(bool state)

    implicitWidth: Theme.toggleSmallWidth
    implicitHeight: Theme.toggleSmallHeight
    radius: height / 2
    opacity: enabled ? 1.0 : 0.35

    color: {
        if (busy)
            return Theme.warning
        return checked ? Theme.accent : Theme.surfaceHi
    }

    Behavior on color {
        enabled: !root.busy
        ColorAnimation { duration: Theme.fastDuration; easing.type: Easing.OutQuad }
    }

    SequentialAnimation on opacity {
        running: root.busy
        loops: Animation.Infinite
        NumberAnimation { to: 0.55; duration: 600; easing.type: Easing.InOutQuad }
        NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
    }

    Rectangle {
        width: parent.height - 6
        height: width
        radius: width / 2
        color: root.checked ? Theme.bg : Theme.fg
        x: root.checked ? parent.width - width - 3 : 3
        y: 3

        Behavior on x {
            NumberAnimation { duration: Theme.fastDuration; easing.type: Easing.OutQuad }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
