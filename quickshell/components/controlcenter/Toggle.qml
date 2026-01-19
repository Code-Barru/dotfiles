import QtQuick

Rectangle {
    id: toggle

    property bool checked: false
    property bool connecting: false
    property color checkedColor: Theme.blue
    property color uncheckedColor: Theme.surface1
    property color connectingColor: Theme.yellow
    signal toggled(bool state)

    implicitWidth: Theme.toggleWidth
    implicitHeight: Theme.toggleHeight
    radius: Theme.toggleHeight / 2
    color: {
        if (connecting) return connectingColor
        return checked ? checkedColor : uncheckedColor
    }

    Behavior on color {
        enabled: !connecting
        ColorAnimation {
            duration: Theme.fastDuration
            easing.type: Easing.OutQuad
        }
    }

    // Animation de pulsation pour l'état connecting
    SequentialAnimation on opacity {
        running: connecting
        loops: Animation.Infinite
        NumberAnimation { to: 0.6; duration: 600; easing.type: Easing.InOutQuad }
        NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
    }

    // Handle
    Rectangle {
        width: 24
        height: 24
        radius: 12
        color: checked ? Theme.base : Theme.text
        x: checked ? parent.width - width - 3 : 3
        y: 3

        Behavior on x {
            NumberAnimation {
                duration: Theme.fastDuration
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            toggle.checked = !toggle.checked
            toggle.toggled(toggle.checked)
        }
    }
}
