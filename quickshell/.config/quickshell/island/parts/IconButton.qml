import QtQuick
import "../.."

Item {
    id: root

    property string icon: ""
    property int iconSize: Theme.normalFontSize
    property color iconColor: Theme.text
    property bool enabled: true

    signal clicked()

    implicitWidth: 28
    implicitHeight: 28
    opacity: enabled ? 1.0 : 0.35

    Behavior on opacity {
        NumberAnimation { duration: Theme.fastDuration }
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: mouse.containsMouse && root.enabled ? Theme.surface0 : "transparent"

        Behavior on color {
            ColorAnimation { duration: Theme.fastDuration }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.family: Theme.fontFamily
        font.pixelSize: root.iconSize
    }

    scale: mouse.pressed && root.enabled ? 0.88 : 1.0

    Behavior on scale {
        NumberAnimation { duration: Theme.fastDuration; easing.type: Easing.OutQuad }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
