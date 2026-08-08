pragma Singleton

import Quickshell
import Quickshell.Hyprland

// État des fenêtres du workspace focus
Singleton {
    id: root

    // hasFullscreen est natif côté Hyprland, pas besoin de parser lastIpcObject
    readonly property bool isFullscreen: Hyprland.focusedWorkspace?.hasFullscreen ?? false

    readonly property string activeTitle: Hyprland.activeToplevel?.title ?? ""
}
