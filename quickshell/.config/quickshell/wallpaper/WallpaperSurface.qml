import Quickshell
import Quickshell.Wayland
import QtQuick
import ".."
import "../services"

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        required property var modelData

        screen: modelData

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "quickshell-wallpaper"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        exclusionMode: ExclusionMode.Ignore
        color: Theme.bgDeep

        readonly property int decodeWidth: modelData.width * modelData.devicePixelRatio
        readonly property int decodeHeight: modelData.height * modelData.devicePixelRatio

        property Image baseLayer: layerA
        property Image nextLayer: layerB

        function beginTransition(url) {
            if (url === "" || url === win.baseLayer.source.toString())
                return

            fade.stop()

            win.baseLayer.z = 0
            win.nextLayer.z = 1
            win.nextLayer.opacity = 0
            win.nextLayer.source = url

            win.layerSettled(win.nextLayer)
        }

        function layerSettled(layer) {
            if (layer !== win.nextLayer || layer.status !== Image.Ready)
                return

            fade.target = layer
            fade.restart()
        }

        Component.onCompleted: win.beginTransition(Wallpaper.currentUrl)

        Connections {
            target: Wallpaper

            function onCurrentUrlChanged() {
                win.beginTransition(Wallpaper.currentUrl)
            }
        }

        Image {
            id: layerA

            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            sourceSize.width: win.decodeWidth
            sourceSize.height: win.decodeHeight

            onStatusChanged: win.layerSettled(layerA)
        }

        Image {
            id: layerB

            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            sourceSize.width: win.decodeWidth
            sourceSize.height: win.decodeHeight

            opacity: 0

            onStatusChanged: win.layerSettled(layerB)
        }

        NumberAnimation {
            id: fade

            property: "opacity"
            to: 1
            duration: Theme.wallpaperFadeDuration
            easing.type: Easing.InOutQuad

            onFinished: {
                win.baseLayer.opacity = 0

                const previous = win.baseLayer
                win.baseLayer = win.nextLayer
                win.nextLayer = previous
            }
        }
    }
}
