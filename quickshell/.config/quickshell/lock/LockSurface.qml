import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import ".."
import "../island"
import "../services"

WlSessionLock {
    id: sessionLock

    locked: Lock.locked

    WlSessionLockSurface {
        id: surface

        color: Theme.crust

        Item {
            id: shot

            anchors.fill: parent
            visible: false

            Image {
                anchors.fill: parent
                source: surface.screen ? `file://${Lock.cleanPath(surface.screen.name)}` : ""
                fillMode: Image.PreserveAspectCrop
                cache: false
                asynchronous: false
            }

            Image {
                id: shotCard

                anchors.fill: parent
                source: surface.screen ? `file://${Lock.shotPath(surface.screen.name)}` : ""
                fillMode: Image.PreserveAspectCrop
                cache: false
                asynchronous: false
            }
        }

        MultiEffect {
            id: background

            anchors.fill: parent
            source: shot

            blurEnabled: true
            blurMax: Theme.lockBlurMax
            blur: 0
        }

        NumberAnimation {
            target: background
            property: "blur"
            running: true
            from: 0
            to: Theme.lockBlur
            duration: Theme.lockBlurDuration
            easing.type: Easing.OutCubic
        }

        Rectangle {
            id: scrim

            anchors.fill: parent
            color: "black"
            opacity: 0
        }

        NumberAnimation {
            target: scrim
            property: "opacity"
            running: true
            from: 0
            to: Theme.lockScrimOpacity
            duration: Theme.lockBlurDuration
            easing.type: Easing.OutCubic
        }

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        IslandSurface {
            id: card

            morphDuration: Theme.lockMorphDuration
            surfaceColor: Theme.crust

            targetWidth: Theme.lockCardWidth
            targetHeight: Theme.lockCardHeight
            targetRadius: Theme.islandRadius
            topRadius: Theme.islandRadius
            notchOpacity: 0

            x: (surface.width - width) / 2
            y: (surface.height - Theme.lockCardHeight) / 2
        }

        Rectangle {
            id: panel

            property bool settled: false

            width: Theme.lockPanelWidth
            height: Theme.lockPanelHeight
            radius: Theme.islandRadius - Theme.lockCardInset / 2
            color: Theme.base

            x: (surface.width - width) / 2
            y: (surface.height - height) / 2 + (settled ? 0 : Theme.lockSettleOffset)
            opacity: settled ? 1 : 0

            Behavior on y {
                NumberAnimation {
                    duration: Theme.lockSettleDuration
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.lockSettleDuration
                    easing.type: Easing.OutQuad
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacing

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    color: Theme.white
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.lockClockFontSize
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: `󰌾 ${Quickshell.env("USER")}`
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.lockUserFontSize
                }

                Rectangle {
                    id: field

                    anchors.horizontalCenter: parent.horizontalCenter

                    width: Theme.lockFieldWidth
                    height: Theme.lockFieldHeight
                    radius: Theme.islandRadius

                    color: Theme.crust
                    border.width: 2
                    border.color: Lock.failed ? Theme.red : Theme.surface1

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Theme.lockFadeDuration
                        }
                    }

                    TextInput {
                        id: input

                        anchors.fill: parent
                        opacity: 0

                        echoMode: TextInput.Password
                        enabled: !Lock.unlocking

                        text: Lock.password
                        onTextEdited: Lock.password = text

                        focus: true
                        Component.onCompleted: forceActiveFocus()

                        onAccepted: Lock.submit()
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: Lock.password === ""
                        text: "Mot de passe"
                        color: Theme.overlay0
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.normalFontSize
                    }

                    Row {
                        id: dots

                        readonly property int maxDots: Math.floor((field.width - Theme.islandPadding * 2 + Theme.lockDotSpacing) / (Theme.lockDotSize + Theme.lockDotSpacing))

                        spacing: Theme.lockDotSpacing

                        x: (field.width - width) / 2
                        y: (field.height - height) / 2

                        Behavior on x {
                            NumberAnimation {
                                duration: Theme.lockDotDuration
                                easing.type: Easing.OutCubic
                            }
                        }

                        ListModel {
                            id: dotModel
                        }

                        function sync() {
                            const target = Math.min(Lock.password.length, dots.maxDots);

                            while (dotModel.count > target)
                                dotModel.remove(dotModel.count - 1);

                            while (dotModel.count < target)
                                dotModel.append({
                                    n: dotModel.count
                                });
                        }

                        Component.onCompleted: dots.sync()

                        Connections {
                            target: Lock

                            function onPasswordChanged() {
                                dots.sync();
                            }
                        }

                        Repeater {
                            model: dotModel

                            Rectangle {
                                width: Theme.lockDotSize
                                height: Theme.lockDotSize
                                radius: width / 2
                                color: Theme.subtext0

                                opacity: 0

                                NumberAnimation on opacity {
                                    running: true
                                    to: 1
                                    duration: Theme.lockDotDuration
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: Theme.lockFieldWidth
                    height: Theme.lockMessageHeight

                    Text {
                        anchors.centerIn: parent

                        text: Lock.message
                        opacity: text !== "" ? 1 : 0

                        color: Theme.red
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.smallFontSize

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.lockFadeDuration
                            }
                        }
                    }
                }
            }
        }

        SequentialAnimation {
            running: true

            PauseAnimation {
                duration: Theme.lockSettleDuration / 2
            }
            ScriptAction {
                script: panel.settled = true
            }
        }

        Connections {
            target: Lock

            function onUnlockingChanged() {
                if (Lock.unlocking)
                    outroAnimation.restart();
            }
        }

        SequentialAnimation {
            id: outroAnimation

            ScriptAction {
                script: panel.settled = false
            }

            NumberAnimation {
                target: shotCard
                property: "opacity"
                to: 0
                duration: Theme.lockSettleDuration
                easing.type: Easing.InOutQuad
            }

            ParallelAnimation {
                NumberAnimation {
                    target: background
                    property: "blur"
                    to: 0
                    duration: Theme.lockMorphDuration * 0.5
                    easing.type: Easing.InQuad
                }
                NumberAnimation {
                    target: scrim
                    property: "opacity"
                    to: 0
                    duration: Theme.lockMorphDuration * 0.5
                    easing.type: Easing.InQuad
                }
            }

            ScriptAction {
                script: Lock.finishUnlock()
            }
        }
    }
}
