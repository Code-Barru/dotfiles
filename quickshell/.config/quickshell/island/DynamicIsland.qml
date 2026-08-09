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
    readonly property bool isLauncher: state === "launcher"
    readonly property bool isWallpaper: state === "wallpaper"
    readonly property bool surfaceHidden: isStrip && !IslandState.stripVisible

    property string displayedState: IslandState.state

    anchors {
        top: true
        left: true
        right: true
    }

    readonly property bool dismissable: isPowerMenu || isNotifCenter || isLauncher || isWallpaper

    implicitHeight: dismissable ? screen.height : Theme.islandWindowHeight
    color: "transparent"

    WlrLayershell.namespace: "quickshell-island"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: {
        if (isPowerMenu || isLauncher || isWallpaper)
            return WlrKeyboardFocus.Exclusive

        if (isNotifCenter || IslandState.inputActive)
            return WlrKeyboardFocus.OnDemand
        return WlrKeyboardFocus.None
    }

    exclusiveZone: 0

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
            mouse.accepted = true;
            IslandState.resetState();
        }
    }

    function sizeFor(name) {
        switch (name) {
        case "strip":
            return {
                w: Theme.stripWidth,
                h: Theme.stripHeight
            };
        case "controlCenter":
            return {
                w: Theme.controlCenterWidth,
                h: island.controlCenterHeight
            };
        case "mediaViz":
            return {
                w: Theme.mediaVizWidth,
                h: Theme.mediaVizHeight
            };
        case "media":
            return {
                w: Theme.mediaWidth,
                h: Theme.mediaHeight
            };
        case "flash":
            return {
                w: Theme.flashWidth,
                h: Theme.flashHeight
            };
        case "workspace":
            return {
                w: Theme.workspaceWidth,
                h: Theme.workspaceHeight
            };
        case "notification":
            return {
                w: Theme.notifWidth,
                h: Theme.notifHeight
            };
        case "notifCenter":
            return {
                w: Theme.notifCenterWidth,
                h: island.notifCenterHeight
            };
        case "powerMenu":
            return {
                w: Theme.powerMenuWidth,
                h: Theme.powerMenuHeight
            };
        case "launcher":
            return {
                w: Theme.launcherWidth,
                h: island.launcherHeight
            };
        case "wallpaper":
            return {
                w: Theme.wallpaperPickerWidth,
                h: island.wallpaperHeight
            };
        }
        return {
            w: Theme.hourWidth,
            h: Theme.hourHeight
        };
    }

    readonly property int notifCenterHeight: Math.min(Theme.notifCenterMaxHeight, 34 + Theme.islandPadding * 2 + Math.max(72, Notifs.count * 72))

    readonly property int controlCenterHeight: island.displayedState === "controlCenter"
        ? Math.min(Theme.controlCenterMaxHeight, contentLoader.item?.implicitHeight ?? Theme.controlCenterMinHeight)
        : Theme.controlCenterMinHeight

    readonly property int launcherHeight: island.displayedState === "launcher"
        ? Math.min(Theme.launcherMaxHeight, contentLoader.item?.implicitHeight ?? Theme.launcherMinHeight)
        : Theme.launcherMinHeight

    readonly property int wallpaperHeight: island.displayedState === "wallpaper"
        ? Math.min(Theme.wallpaperMaxHeight, contentLoader.item?.implicitHeight ?? Theme.wallpaperMinHeight)
        : Theme.wallpaperMinHeight

    readonly property var targetSize: sizeFor(island.state)

    property int swapDuration: Theme.fadeDuration

    IslandSurface {
        id: surface

        anchors.horizontalCenter: parent.horizontalCenter
        y: 0

        targetWidth: island.targetSize.w
        targetHeight: island.targetSize.h
        targetRadius: island.isStrip ? Theme.stripRadius : Theme.islandRadius

        morphDuration: island.state === "workspace" ? Theme.workspaceMorphDuration : Theme.morphDuration

        surfaceColor: island.isStrip ? Theme.surface1 : Theme.crust

        opacity: island.surfaceHidden ? 0.0 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.slowDuration
                easing.type: island.surfaceHidden ? Easing.InQuad : Easing.OutQuad
            }
        }

        HoverHandler {
            onHoveredChanged: if (hovered)
                IslandState.wake()
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
            Notifs.dismiss(IslandState.currentNotif);
            IslandState.clearOverlay();
            break;
        case "flash":
        case "workspace":
            IslandState.clearOverlay();
            break;
        case "mediaViz":
            IslandState.dismissMedia();
            break;
        case "media":
            IslandState.clearOverlay();
            break;
        case "notifCenter":
        case "powerMenu":
        case "controlCenter":
        case "launcher":
        case "wallpaper":
            break;
        default:
            IslandState.toggleNotifCenter();
        }
    }

    Connections {
        target: IslandState

        function onStateChanged() {
            island.swapDuration = IslandState.state === "workspace" ? Theme.workspaceFadeDuration : Theme.fadeDuration;
            swapAnimation.restart();
        }
    }

    SequentialAnimation {
        id: swapAnimation

        ParallelAnimation {
            NumberAnimation {
                target: contentLoader
                property: "opacity"
                to: 0
                duration: island.swapDuration / 2
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: contentLoader
                property: "scale"
                to: 0.92
                duration: island.swapDuration / 2
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
                duration: island.swapDuration
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: contentLoader
                property: "scale"
                to: 1
                duration: island.swapDuration
                easing.type: Easing.OutQuad
            }
        }
    }

    function componentFor(name) {
        switch (name) {
        case "strip":
            return stripComponent;
        case "controlCenter":
            return controlCenterComponent;
        case "mediaViz":
            return mediaVizComponent;
        case "media":
            return mediaComponent;
        case "flash":
            return flashComponent;
        case "workspace":
            return workspaceComponent;
        case "notification":
            return notifComponent;
        case "notifCenter":
            return notifCenterComponent;
        case "powerMenu":
            return powerMenuComponent;
        case "launcher":
            return launcherComponent;
        case "wallpaper":
            return wallpaperComponent;
        }
        return hourComponent;
    }

    Component {
        id: stripComponent
        StripState {}
    }
    Component {
        id: hourComponent
        HourState {}
    }
    Component {
        id: controlCenterComponent
        ControlCenterState {}
    }
    Component {
        id: mediaVizComponent
        MediaVizState {}
    }
    Component {
        id: mediaComponent
        MediaState {}
    }

    Binding {
        target: Vpn
        property: "watching"
        value: island.displayedState === "controlCenter"
    }

    Binding {
        target: Cava
        property: "active"
        value: island.displayedState === "mediaViz" || island.displayedState === "media"
    }
    Component {
        id: flashComponent
        FlashState {}
    }
    Component {
        id: workspaceComponent
        WorkspaceState {}
    }
    Component {
        id: notifComponent
        NotifState {}
    }
    Component {
        id: notifCenterComponent
        NotifCenterState {}
    }
    Component {
        id: powerMenuComponent
        PowerMenuState {}
    }
    Component {
        id: launcherComponent
        LauncherState {}
    }
    Component {
        id: wallpaperComponent
        WallpaperState {}
    }
}
