import QtQuick
import ".."

Item {
    id: root

    property int targetWidth: Theme.hourWidth
    property int targetHeight: Theme.hourHeight
    property int targetRadius: Theme.islandRadius
    property int topRadius: 0
    property real notchOpacity: 1
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

        topLeftRadius: root.topRadius
        topRightRadius: root.topRadius
        bottomLeftRadius: root.targetRadius
        bottomRightRadius: root.targetRadius

        Behavior on topLeftRadius {
            NumberAnimation { duration: root.morphDuration; easing.type: Easing.OutCubic }
        }
        Behavior on topRightRadius {
            NumberAnimation { duration: root.morphDuration; easing.type: Easing.OutCubic }
        }
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
        opacity: root.notchOpacity
    }

    InvertedCorner {
        anchors.left: body.right
        anchors.leftMargin: -1
        anchors.top: body.top
        radius: root.cornerRadius
        fillColor: root.surfaceColor
        mirrored: true
        opacity: root.notchOpacity
    }
}
