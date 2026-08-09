import QtQuick
import ".."

Item {
    id: root

    property int targetWidth: Theme.hourWidth
    property int targetHeight: Theme.hourHeight
    property int targetRadius: Theme.islandRadius
    property color surfaceColor: Theme.crust
    property int morphDuration: Theme.morphDuration

    default property alias content: contentHolder.data

    readonly property alias body: body
    readonly property real cornerRadius: Math.min(Theme.cornerRadius, height)

    width: targetWidth
    height: targetHeight

    Behavior on width {
        NumberAnimation {
            duration: root.morphDuration
            easing.type: Easing.OutBack
            easing.overshoot: 0.6
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: root.morphDuration
            easing.type: Easing.OutBack
            easing.overshoot: 0.6
        }
    }

    Behavior on surfaceColor {
        ColorAnimation { duration: root.morphDuration; easing.type: Easing.OutQuad }
    }

    Rectangle {
        id: body

        anchors.fill: parent
        color: root.surfaceColor
        clip: true

        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: root.targetRadius
        bottomRightRadius: root.targetRadius

        Behavior on bottomLeftRadius {
            NumberAnimation { duration: root.morphDuration; easing.type: Easing.OutCubic }
        }
        Behavior on bottomRightRadius {
            NumberAnimation { duration: root.morphDuration; easing.type: Easing.OutCubic }
        }

        Item {
            id: contentHolder
            anchors.fill: parent
        }
    }

    InvertedCorner {
        anchors.right: body.left
        anchors.rightMargin: -1
        anchors.top: body.top
        radius: root.cornerRadius
        fillColor: root.surfaceColor
    }

    InvertedCorner {
        anchors.left: body.right
        anchors.leftMargin: -1
        anchors.top: body.top
        radius: root.cornerRadius
        fillColor: root.surfaceColor
        mirrored: true
    }
}
