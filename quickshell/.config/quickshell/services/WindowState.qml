pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property bool isFullscreen: Hyprland.focusedWorkspace?.hasFullscreen ?? false

    readonly property string activeTitle: Hyprland.activeToplevel?.title ?? ""
}
