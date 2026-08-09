pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick
import ".."

Singleton {
    id: root

    property bool mediaDismissed: false

    property bool panelHeld: false
    property bool inputActive: false

    readonly property string computedBase: WindowState.isFullscreen
        ? "strip"
        : (Media.active && !mediaDismissed ? "mediaViz" : "hour")

    property string pinnedBase: ""

    readonly property string baseState: pinnedBase !== "" ? pinnedBase : computedBase

    property string overlayState: ""

    readonly property string state: overlayState !== "" ? overlayState : baseState

    property string flashKind: ""

    property int flashValue: 0
    property bool flashValueCritical: false

    readonly property int flashPercent: {
        switch (flashKind) {
        case "volume":
            return Audio.muted ? 0 : Audio.percent
        case "brightness":
            return Brightness.percent
        }
        return flashValue
    }

    readonly property bool flashCritical: flashKind === "volume" ? Audio.muted : flashValueCritical

    property Notification currentNotif: null

    property bool stripVisible: true

    Timer {
        id: stripTimer
        interval: Theme.stripTimeout
        onTriggered: root.stripVisible = false
    }

    function wake() {
        stripVisible = true
        stripTimer.restart()
    }

    onStateChanged: {
        wake()

        if (state !== "controlCenter")
            inputActive = false

        if (state !== "media")
            panelHeld = false
    }

    onBaseStateChanged: wake()

    Component.onCompleted: wake()

    Timer {
        id: overlayTimer
        onTriggered: root.clearOverlay()
    }

    function clearOverlay() {
        overlayTimer.stop()
        overlayState = ""
        flashKind = ""
        currentNotif = null
    }

    function flash(kind, value, critical) {
        if (overlayState === "powerMenu")
            return

        flashKind = kind
        flashValue = value ?? 0
        flashValueCritical = critical ?? false
        overlayState = "flash"
        overlayTimer.interval = kind === "battery" ? Theme.batteryFlashTimeout : Theme.flashTimeout
        overlayTimer.restart()
        wake()
    }

    function showWorkspace() {
        if (overlayState === "powerMenu" || overlayState === "notifCenter")
            return

        overlayState = "workspace"
        overlayTimer.interval = Theme.workspaceTimeout
        overlayTimer.restart()
        wake()
    }

    Connections {
        target: Workspaces

        function onSwitched() {
            root.showWorkspace()
        }
    }

    function showNotification(notif) {
        if (Notifs.dnd || Media.isFromPlayer(notif)
            || overlayState === "notifCenter" || overlayState === "powerMenu")
            return

        currentNotif = notif
        overlayState = "notification"

        const requested = (notif && notif.expireTimeout > 0)
            ? notif.expireTimeout
            : Theme.notifTimeout

        overlayTimer.interval = Math.min(requested, Theme.notifMaxTimeout)
        overlayTimer.restart()
        wake()
    }

    function openNotifCenter() {
        overlayTimer.stop()
        currentNotif = null
        overlayState = "notifCenter"
        wake()
    }

    function toggleNotifCenter() {
        if (overlayState === "notifCenter")
            clearOverlay()
        else
            openNotifCenter()
    }

    function openPowerMenu() {
        overlayTimer.stop()
        currentNotif = null
        overlayState = "powerMenu"
        wake()
    }

    onPanelHeldChanged: {
        if (overlayState !== "media")
            return

        if (panelHeld)
            overlayTimer.stop()
        else
            overlayTimer.restart()
    }

    function announceMedia() {
        mediaDismissed = false

        if (overlayState === "powerMenu" || overlayState === "notifCenter")
            return

        overlayState = "media"
        overlayTimer.interval = Theme.mediaIntroTimeout
        overlayTimer.restart()
        wake()
    }

    function dismissMedia() {
        mediaDismissed = true
        if (overlayState === "media")
            clearOverlay()
    }

    Connections {
        target: Media

        function onActiveChanged() {
            if (Media.active)
                root.announceMedia()
        }
    }

    function pinBase(name) {
        pinnedBase = name
        wake()
    }

    function unpinBase() {
        pinnedBase = ""
        wake()
    }

    function resetState() {
        clearOverlay()
        unpinBase()
    }

    function requestState(name) {
        const wasActive = state === name

        resetState()

        if (wasActive)
            return

        switch (name) {
        case "notifCenter":
            openNotifCenter()
            break
        case "powerMenu":
            openPowerMenu()
            break
        default:
            pinBase(name)
        }
    }

    function cycle() {
        if (overlayState === "notifCenter") {
            clearOverlay()
            pinBase("hour")
        } else if (baseState === "hour") {
            pinBase("controlCenter")
        } else if (baseState === "controlCenter" || baseState === "mediaViz") {
            openNotifCenter()
        } else {
            openNotifCenter()
        }
    }

    Connections {
        target: Power
        function onLowBattery(percent) {
            root.flash("battery", percent, true)
        }
    }

    Connections {
        target: Notifs
        function onReceived(notif) {
            root.showNotification(notif)
        }
    }

    Connections {
        target: root.currentNotif
        ignoreUnknownSignals: true
        function onClosed() {
            if (root.overlayState === "notification")
                root.clearOverlay()
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "island_hour"
        description: "Island : afficher l'heure"
        onPressed: root.requestState("hour")
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "island_controlcenter"
        description: "Island : Control Center"
        onPressed: root.requestState("controlCenter")
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "island_media"
        description: "Island : lecteur média"
        onPressed: root.requestState("media")
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "island_strip"
        description: "Island : mode discret"
        onPressed: root.requestState("strip")
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "island_notifications"
        description: "Island : centre de notifications"
        onPressed: root.requestState("notifCenter")
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "island_cycle"
        description: "Island : état suivant"
        onPressed: root.cycle()
    }

    IpcHandler {
        target: "island"

        function setState(name: string): string {
            if (["hour", "controlCenter", "mediaViz", "media", "strip"].indexOf(name) !== -1) {
                root.clearOverlay()
                root.pinBase(name)
                return `base -> ${name}`
            }

            if (name === "workspace") {
                root.showWorkspace()
                return "overlay -> workspace"
            }

            if (name === "notifCenter") {
                root.openNotifCenter()
                return "overlay -> notifCenter"
            }

            if (name === "powerMenu") {
                root.openPowerMenu()
                return "overlay -> powerMenu"
            }

            return `état inconnu: ${name}`
        }

        function flash(kind: string, value: int): string {
            root.flash(kind, value, kind === "battery")
            return `flash ${kind} ${value}`
        }

        function reset(): string {
            root.clearOverlay()
            root.pinnedBase = ""
            return `state = ${root.state}`
        }

        function status(): string {
            return `state=${root.state} base=${root.baseState} overlay=${root.overlayState} pinned=${root.pinnedBase} dismissed=${root.mediaDismissed} held=${root.panelHeld} input=${root.inputActive} ws=${Workspaces.previous}->${Workspaces.active} stripVisible=${root.stripVisible}`
        }
    }
}
