import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import ".."
import "../services"
import "states"

PanelWindow {
    id: island

    readonly property string state: IslandState.state
    readonly property bool isStrip: state === "strip"
    readonly property bool isNotifCenter: state === "notifCenter"
    readonly property bool surfaceHidden: isStrip && !IslandState.stripVisible

    // Contenu réellement monté : décalé d'un demi-fondu par rapport à l'état,
    // pour que la forme commence à bouger avant que le contenu ne change
    property string displayedState: IslandState.state

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.islandWindowHeight
    color: "transparent"

    WlrLayershell.namespace: "quickshell-island"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isNotifCenter ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // La zone réservée suit l'état de BASE, jamais les overlays : sinon un simple
    // toast en plein écran ferait bouger toutes les fenêtres.
    // En strip (plein écran) on ne réserve rien, sinon la hauteur de repos + une marge.
    exclusiveZone: IslandState.baseState === "strip"
        ? 0
        : Theme.hourHeight + Theme.islandGap

    // Sans masque, la fenêtre pleine largeur avalerait tous les clics du haut de l'écran
    mask: Region {
        item: surface
    }

    // ==================== DIMENSIONS PAR ÉTAT ====================

    function sizeFor(name) {
        switch (name) {
        case "strip":
            return { w: Theme.stripWidth, h: Theme.stripHeight }
        case "media":
            return { w: Theme.mediaWidth, h: Theme.mediaHeight }
        case "flash":
            return { w: Theme.flashWidth, h: Theme.flashHeight }
        case "notification":
            return { w: Theme.notifWidth, h: Theme.notifHeight }
        case "notifCenter":
            return { w: Theme.notifCenterWidth, h: island.notifCenterHeight }
        }
        return { w: Theme.hourWidth, h: Theme.hourHeight }
    }

    readonly property int notifCenterHeight: Math.min(
        Theme.notifCenterMaxHeight,
        34 + Theme.islandPadding * 2 + Math.max(72, Notifs.count * 72))

    readonly property var targetSize: sizeFor(island.state)

    // ==================== SURFACE ====================

    IslandSurface {
        id: surface

        anchors.horizontalCenter: parent.horizontalCenter
        y: 0

        targetWidth: island.targetSize.w
        targetHeight: island.targetSize.h
        targetRadius: island.isStrip ? Theme.stripRadius : Theme.islandRadius

        // Le crust se confond avec un fond sombre : le strip a besoin d'être plus clair
        surfaceColor: island.isStrip ? Theme.surface1 : Theme.crust

        // Le strip s'efface après inactivité mais garde sa zone de survol
        opacity: island.surfaceHidden ? 0.0 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.slowDuration
                easing.type: island.surfaceHidden ? Easing.InQuad : Easing.OutQuad
            }
        }

        HoverHandler {
            onHoveredChanged: if (hovered) IslandState.wake()
        }

        TapHandler {
            onTapped: island.handleTap()
        }

        Loader {
            id: contentLoader

            anchors.fill: parent
            sourceComponent: island.componentFor(island.displayedState)
        }
    }

    function handleTap() {
        switch (island.state) {
        case "notification":
            Notifs.dismiss(IslandState.currentNotif)
            IslandState.clearOverlay()
            break
        case "flash":
            IslandState.clearOverlay()
            break
        case "notifCenter":
        case "media":
            // Les enfants gèrent leurs propres clics
            break
        default:
            IslandState.toggleNotifCenter()
        }
    }

    // ==================== FONDU ENTRE CONTENUS ====================

    Connections {
        target: IslandState

        function onStateChanged() {
            swapAnimation.restart()
        }
    }

    SequentialAnimation {
        id: swapAnimation

        ParallelAnimation {
            NumberAnimation {
                target: contentLoader
                property: "opacity"
                to: 0
                duration: Theme.fadeDuration / 2
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: contentLoader
                property: "scale"
                to: 0.92
                duration: Theme.fadeDuration / 2
                easing.type: Easing.InQuad
            }
        }

        ScriptAction {
            script: island.displayedState = IslandState.state
        }

        ParallelAnimation {
            NumberAnimation {
                target: contentLoader
                property: "opacity"
                to: 1
                duration: Theme.fadeDuration
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: contentLoader
                property: "scale"
                to: 1
                duration: Theme.fadeDuration
                easing.type: Easing.OutQuad
            }
        }
    }

    // ==================== FERMETURE DU CENTRE DE NOTIFS ====================

    HyprlandFocusGrab {
        windows: [island]
        active: island.isNotifCenter
        onCleared: IslandState.clearOverlay()
    }

    // ==================== CONTENUS ====================

    function componentFor(name) {
        switch (name) {
        case "strip":
            return stripComponent
        case "media":
            return mediaComponent
        case "flash":
            return flashComponent
        case "notification":
            return notifComponent
        case "notifCenter":
            return notifCenterComponent
        }
        return hourComponent
    }

    Component { id: stripComponent; StripState {} }
    Component { id: hourComponent; HourState {} }
    Component { id: mediaComponent; MediaState {} }
    Component { id: flashComponent; FlashState {} }
    Component { id: notifComponent; NotifState {} }
    Component { id: notifCenterComponent; NotifCenterState {} }
}
