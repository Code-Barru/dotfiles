import QtQuick
import ".."

// Corps morphant de l'island : la taille est pilotée depuis l'extérieur,
// toute la transformation vient des Behavior.
Item {
    id: root

    property int targetWidth: Theme.hourWidth
    property int targetHeight: Theme.hourHeight
    property int targetRadius: Theme.islandRadius
    property color surfaceColor: Theme.crust

    default property alias content: contentHolder.data

    readonly property alias body: body
    readonly property real cornerRadius: Math.min(Theme.cornerRadius, height)

    width: targetWidth
    height: targetHeight

    Behavior on width {
        NumberAnimation {
            duration: Theme.morphDuration
            easing.type: Easing.OutBack
            easing.overshoot: 0.6
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: Theme.morphDuration
            easing.type: Easing.OutBack
            easing.overshoot: 0.6
        }
    }

    // L'island pend du bord de l'écran : le haut reste droit, seul le bas s'arrondit
    Behavior on surfaceColor {
        ColorAnimation { duration: Theme.morphDuration; easing.type: Easing.OutQuad }
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
            NumberAnimation { duration: Theme.morphDuration; easing.type: Easing.OutCubic }
        }
        Behavior on bottomRightRadius {
            NumberAnimation { duration: Theme.morphDuration; easing.type: Easing.OutCubic }
        }

        Item {
            id: contentHolder
            anchors.fill: parent
        }
    }

    InvertedCorner {
        anchors.right: body.left
        anchors.top: body.top
        radius: root.cornerRadius
        fillColor: root.surfaceColor
    }

    InvertedCorner {
        anchors.left: body.right
        anchors.top: body.top
        radius: root.cornerRadius
        fillColor: root.surfaceColor
        mirrored: true
    }
}
