import QtQuick

Rectangle {
    id: slider

    property real value: 50  // 0-100
    property real min: 0
    property real max: 100
    property color trackColor: Theme.surface0
    property color fillColor: Theme.blue

    signal userChanged(real newValue)  // Signal custom pour changements utilisateur

    implicitWidth: 300
    implicitHeight: Theme.sliderHeight
    radius: 4
    color: trackColor

    // Fill bar
    Rectangle {
        id: fill
        width: ((slider.value - slider.min) / (slider.max - slider.min)) * parent.width
        height: parent.height
        radius: 4
        color: fillColor
    }

    // Handle
    Rectangle {
        id: handle
        width: Theme.handleSize
        height: Theme.handleSize
        radius: Theme.handleSize / 2
        color: fillColor  // Bleu au lieu de blanc
        border.width: 2
        border.color: Theme.white
        x: fill.width - width / 2
        y: (parent.height - height) / 2

        Behavior on x {
            NumberAnimation {
                duration: Theme.fastDuration
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        function updateValue(mouseX) {
            const clampedX = Math.max(0, Math.min(mouseX, width))
            const newValue = slider.min + (clampedX / width) * (slider.max - slider.min)
            const roundedValue = Math.round(newValue)

            if (roundedValue !== slider.value) {
                slider.value = roundedValue
                slider.userChanged(roundedValue)
            }
        }

        onPressed: mouse => updateValue(mouse.x)
        onPositionChanged: mouse => {
            if (pressed) updateValue(mouse.x)
        }
    }
}
