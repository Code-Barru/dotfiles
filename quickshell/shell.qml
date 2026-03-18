import Quickshell
import QtQuick

ShellRoot {
    Bar {
        powerMenu: powerMenuRoot
    }
    ControlCenter {
        id: controlCenterRoot
        currentVolume: osdRoot.volumeValue
        currentMuted: osdRoot.volumeMuted
        currentBrightness: osdRoot.brightnessValue
    }
    PowerMenu {
        id: powerMenuRoot
    }
    OSD {
        id: osdRoot
        controlCenterOpen: controlCenterRoot.isOpen
    }
}
