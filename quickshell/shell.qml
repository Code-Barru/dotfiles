import Quickshell
import QtQuick

ShellRoot {
    Bar {
        powerMenu: powerMenuRoot
    }
    ControlCenter {
        id: controlCenterRoot
    }
    PowerMenu {
        id: powerMenuRoot
    }
}
