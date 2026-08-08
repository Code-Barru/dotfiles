import Quickshell
import Quickshell.Wayland
import QtQuick
import ".."
import "../services"
import "states"

PanelWindow {
    id: island

    readonly property string state: IslandState.state
    readonly property bool isStrip: state === "strip"
    readonly property bool isNotifCenter: state === "notifCenter"
    readonly property bool isPowerMenu: state === "powerMenu"
    readonly property bool surfaceHidden: isStrip && !IslandState.stripVisible

    // Contenu réellement monté : décalé d'un demi-fondu par rapport à l'état,
    // pour que la forme commence à bouger avant que le contenu ne change
    property string displayedState: IslandState.state

    anchors {
        top: true
        left: true
        right: true
    }

    // États dont on doit pouvoir sortir en cliquant à côté
    readonly property bool dismissable: isPowerMenu || isNotifCenter || IslandState.pinnedBase !== ""

    // Plein écran seulement le temps de capter ce clic : une surface plein écran
    // permanente sur la couche top empêcherait le direct scanout des jeux/vidéos
    implicitHeight: dismissable ? screen.height : Theme.islandWindowHeight
    color: "transparent"

    WlrLayershell.namespace: "quickshell-island"

    // Top et non Overlay : en Overlay l'island passerait au-dessus des vidéos
    // et des jeux en plein écran
    WlrLayershell.layer: WlrLayer.Top
    // Exclusive pour le power menu : Escape doit marcher sans cliquer dans le panneau d'abord
    WlrLayershell.keyboardFocus: isPowerMenu
        ? WlrKeyboardFocus.Exclusive
        : (isNotifCenter ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None)

    // Island flottante : elle survole les fenêtres, rien n'est réservé
    exclusiveZone: 0

    // Sans masque, la fenêtre pleine largeur avalerait tous les clics du haut de
    // l'écran. En état refermable au contraire elle les capte tous, pour que le
    // premier clic à côté ramène au défaut.
    mask: Region {
        item: island.dismissable ? fullArea : surface
    }

    Item {
        id: fullArea
        anchors.fill: parent
    }

    MouseArea {
        z: -1
        anchors.fill: parent
        enabled: island.dismissable
        acceptedButtons: Qt.AllButtons

        onPressed: mouse => {
            mouse.accepted = true
            IslandState.resetState()
        }
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
        case "powerMenu":
            return { w: Theme.powerMenuWidth, h: Theme.powerMenuHeight }
        }
        return {
            w: Workspaces.revealed ? Theme.hourWorkspacesWidth : Theme.hourWidth,
            h: Theme.hourHeight
        }
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
            focus: true
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
        case "powerMenu":
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
        case "powerMenu":
            return powerMenuComponent
        }
        return hourComponent
    }

    Component { id: stripComponent; StripState {} }
    Component { id: hourComponent; HourState {} }
    Component { id: mediaComponent; MediaState {} }
    Component { id: flashComponent; FlashState {} }
    Component { id: notifComponent; NotifState {} }
    Component { id: notifCenterComponent; NotifCenterState {} }
    Component { id: powerMenuComponent; PowerMenuState {} }
}
