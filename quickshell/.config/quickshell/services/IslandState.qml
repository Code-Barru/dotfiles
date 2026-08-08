pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick
import ".."

// Base : strip | hour | media — Overlay : flash | notification | notifCenter
Singleton {
    id: root

    readonly property string computedBase: WindowState.isFullscreen
        ? "strip"
        : (Media.active ? "media" : "hour")

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

    onStateChanged: wake()
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

    function showNotification(notif) {
        if (overlayState === "notifCenter" || overlayState === "powerMenu")
            return

        currentNotif = notif
        overlayState = "notification"

        // expireTimeout vaut -1 quand l'app laisse le serveur décider
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

    // Un raccourci d'état bascule vers cet état en repartant de zéro ; le même
    // raccourci une seconde fois ramène au défaut
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
        } else if (baseState === "hour" && Media.hasPlayer) {
            pinBase("media")
        } else if (baseState === "media") {
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
        name: "island_media"
        description: "Island : afficher le média"
        onPressed: root.requestState("media")
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
            if (["hour", "media", "strip"].indexOf(name) !== -1) {
                root.clearOverlay()
                root.pinBase(name)
                return `base -> ${name}`
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

        // value n'est utilisé que pour battery : volume et brightness se lisent en direct
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
            return `state=${root.state} base=${root.baseState} overlay=${root.overlayState} pinned=${root.pinnedBase} stripVisible=${root.stripVisible}`
        }
    }
}
