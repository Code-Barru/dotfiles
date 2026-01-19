import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Item {
    id: workspaces
    width: (10 * 4) + (4 * 3)
    height: 10

    property int actualWorkspace: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1
    property bool isInRange: actualWorkspace >= 1 && actualWorkspace <= 4
    property int activeIndex: Math.min(Math.max(actualWorkspace - 1, 0), 3)
    property int previousIndex: activeIndex
    property bool wasOutOfRange: false
    property bool initialized: false

    Component.onCompleted: {
        previousIndex = activeIndex
        initialized = true
    }

    onActiveIndexChanged: {
        if (!initialized) return

        if (isInRange) {
            if (!wasOutOfRange && activeIndex !== previousIndex) {
                // Animation normale
                indicator.startAnimation(previousIndex, activeIndex)
            } else if (wasOutOfRange) {
                // Fade in simple, pas d'animation d'extension
                indicator.currentIndex = activeIndex
                wasOutOfRange = false
            }
            previousIndex = activeIndex
        } else {
            wasOutOfRange = true
        }
    }

    // Workspaces sobres
    RowLayout {
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: 4

            Rectangle {
                required property int index
                property int wsNum: index + 1
                property bool isOccupied: Hyprland.workspaces.values.some(w => w.id === wsNum)
                property bool isActive: index === activeIndex
                property bool displayOccupied: false

                width: 10
                height: 10
                radius: 4
                color: displayOccupied ? bar.subtext0 : bar.surface0
                opacity: isActive ? 0 : 1

                onIsOccupiedChanged: {
                    if (isOccupied) {
                        // Délai avant de passer à "rempli"
                        occupiedTimer.restart()
                    } else {
                        // Passer à vide immédiatement
                        occupiedTimer.stop()
                        displayOccupied = false
                    }
                }

                Timer {
                    id: occupiedTimer
                    interval: 300
                    onTriggered: {
                        displayOccupied = true
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + wsNum)
                }
            }
        }
    }

    // Indicateur bleu avec animation stretch + contract
    Rectangle {
        id: indicator
        height: 10
        radius: 4
        color: bar.blue
        y: 0
        z: 1

        property int currentIndex: 0
        property int targetIndex: 0
        property int animationPhase: 0  // 0 = idle, 1 = stretch, 2 = contract
        property bool movingRight: false
        property int distance: 0
        property real animationProgress: 0

        opacity: isInRange ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Component.onCompleted: {
            currentIndex = activeIndex
            targetIndex = activeIndex
        }

        function startAnimation(fromIndex, toIndex) {
            if (fromIndex === toIndex) return

            // Si une animation est en cours, l'arrêter et finaliser instantanément
            if (animationPhase !== 0) {
                stretchAnimation.stop()
                contractAnimation.stop()
                currentIndex = targetIndex
                animationPhase = 0
                animationProgress = 0
                // Mettre à jour fromIndex pour partir de la bonne position
                fromIndex = currentIndex
            }

            currentIndex = fromIndex
            targetIndex = toIndex
            movingRight = toIndex > fromIndex
            distance = Math.abs(toIndex - fromIndex) * 14
            animationPhase = 1
            animationProgress = 0

            stretchAnimation.restart()
        }

        x: {
            if (animationPhase === 0) {
                // Idle
                return currentIndex * 14
            } else if (animationPhase === 1) {
                // Stretch phase
                if (movingRight) {
                    return currentIndex * 14
                } else {
                    return (currentIndex * 14 + 10) - (10 + distance * animationProgress)
                }
            } else {
                // Contract phase
                if (movingRight) {
                    return currentIndex * 14 + distance * animationProgress
                } else {
                    return targetIndex * 14
                }
            }
        }

        width: {
            if (animationPhase === 0) {
                return 10
            } else if (animationPhase === 1) {
                // Stretch: 10 → distance + 10
                return 10 + distance * animationProgress
            } else {
                // Contract: distance + 10 → 10
                return (distance + 10) - distance * animationProgress
            }
        }

        NumberAnimation on animationProgress {
            id: stretchAnimation
            from: 0
            to: 1
            duration: 150
            easing.type: Easing.InOutQuad
            running: false
            onFinished: {
                indicator.animationPhase = 2
                indicator.animationProgress = 0
                contractAnimation.restart()
            }
        }

        NumberAnimation on animationProgress {
            id: contractAnimation
            from: 0
            to: 1
            duration: 150
            easing.type: Easing.InOutQuad
            running: false
            onFinished: {
                indicator.currentIndex = indicator.targetIndex
                indicator.animationPhase = 0
                indicator.animationProgress = 0
            }
        }
    }
}
