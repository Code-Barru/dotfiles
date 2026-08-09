import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import ".."
import "../services"

WlSessionLock {
    id: sessionLock

    locked: Lock.locked

    WlSessionLockSurface {
        id: surface

        color: Theme.crust

        Image {
            id: shot

            anchors.fill: parent
            visible: false

            source: surface.screen ? `file://${Lock.shotPath(surface.screen.name)}` : ""
            fillMode: Image.PreserveAspectCrop
            cache: false
            asynchronous: false
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
            anchors.fill: parent
            color: "black"
            opacity: 0

            NumberAnimation on opacity {
                running: true
                from: 0
                to: Theme.lockScrimOpacity
                duration: Theme.lockBlurDuration
                easing.type: Easing.OutCubic
            }
        }

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.largeSpacing

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
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

                    // Qt.formatDateTime utilise la locale C, d'où une date en anglais
                    text: {
                        const d = clock.date.toLocaleDateString(Qt.locale("fr_FR"), "dddd d MMMM yyyy");
                        return d.charAt(0).toUpperCase() + d.slice(1);
                    }

                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.lockDateFontSize
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacing

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

                    color: Theme.base
                    border.width: 2
                    border.color: Lock.failed ? Theme.red : Theme.surface1

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Theme.lockFadeDuration
                        }
                    }

                    // Invisible : la saisie est rendue par la rangée de points
                    TextInput {
                        id: input

                        anchors.fill: parent
                        opacity: 0

                        echoMode: TextInput.Password

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

                        // la rangée se recentre à chaque caractère : on lisse le décalage
                        Behavior on x {
                            NumberAnimation {
                                duration: Theme.lockDotDuration
                                easing.type: Easing.OutCubic
                            }
                        }

                        // un modèle entier ferait régénérer tout le Repeater à chaque frappe :
                        // les points déjà posés refondraient et l'animation en cours serait coupée
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

                // hauteur réservée en permanence : l'erreur ne doit pas déplacer le champ
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
    }
}
