import QtQuick
import "../.."

// Barre de progression média, cliquable/draggable si le lecteur supporte le seek
Item {
    id: root

    property real progress: 0
    property bool seekable: false
    property color fillColor: Theme.blue

    signal seeked(real ratio)

    implicitHeight: 12

    property bool dragging: false

    Rectangle {
        id: track

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        radius: 2
        color: Theme.surface0

        Rectangle {
            width: Math.max(0, Math.min(1, root.progress)) * parent.width
            height: parent.height
            radius: parent.radius
            color: root.fillColor

            // Pas d'animation pendant le drag, sinon la poignée flotte
            Behavior on width {
                enabled: !root.dragging
                NumberAnimation { duration: Theme.fastDuration; easing.type: Easing.OutCubic }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.seekable
        cursorShape: root.seekable ? Qt.PointingHandCursor : Qt.ArrowCursor

        onPressed: mouse => {
            root.dragging = true
            root.seeked(mouse.x / width)
        }

        onPositionChanged: mouse => {
            if (root.dragging)
                root.seeked(mouse.x / width)
        }

        onReleased: root.dragging = false
        onCanceled: root.dragging = false
    }
}
