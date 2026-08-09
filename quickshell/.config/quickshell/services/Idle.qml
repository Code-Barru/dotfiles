pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

Singleton {
    id: root

    signal lockRequested
    signal suspendRequested

    readonly property int dimTimeout: 300
    readonly property int lockTimeout: 315
    readonly property int dpmsTimeout: 360
    readonly property int suspendTimeout: 600

    Process {
        id: brightnessProc
        command: []
    }

    function runBrightness(args) {
        brightnessProc.running = false;
        brightnessProc.command = args;
        brightnessProc.running = true;
    }

    IdleMonitor {
        enabled: true
        timeout: root.dimTimeout
        onIsIdleChanged: root.runBrightness(isIdle ? ["brightnessctl", "-s", "set", "10%"] : ["brightnessctl", "-r"])
    }

    IdleMonitor {
        enabled: true
        timeout: root.lockTimeout
        onIsIdleChanged: if (isIdle)
            root.lockRequested()
    }

    IdleMonitor {
        enabled: true
        timeout: root.dpmsTimeout
        onIsIdleChanged: Hyprland.dispatch(isIdle ? "dpms off" : "dpms on")
    }

    IdleMonitor {
        enabled: true
        timeout: root.suspendTimeout
        onIsIdleChanged: if (isIdle)
            root.suspendRequested()
    }
}
