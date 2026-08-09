import Quickshell
import Quickshell.Io
import QtQuick
import ".."

Scope {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string kittyPath: `${home}/dotfiles/kitty/.config/kitty/theme.conf`
    readonly property string hyprPath: `${home}/dotfiles/hypr/.config/hypr/hyprland/colors.lua`
    readonly property string btopPath: `${home}/dotfiles/btop/.config/btop/themes/current.theme`
    readonly property string zedSettingsPath: `${home}/.config/zed/settings.json`

    property bool primed: false

    function bare(color) {
        return color.toString().slice(1)
    }

    function kittyConf() {
        return `# généré par quickshell
background ${Theme.bg}
foreground ${Theme.fg}
cursor ${Theme.magenta}
cursor_text_color ${Theme.bg}
selection_background ${Theme.accentAlt}
selection_foreground ${Theme.bg}
visual_bell_color ${Theme.surface}

color0 ${Theme.black}
color1 ${Theme.error}
color2 ${Theme.success}
color3 ${Theme.warning}
color4 ${Theme.accent}
color5 ${Theme.magenta}
color6 ${Theme.cyan}
color7 ${Theme.brightFg}

color8 ${Theme.brightBlack}
color9 ${Theme.error}
color10 ${Theme.success}
color11 ${Theme.warning}
color12 ${Theme.accent}
color13 ${Theme.magenta}
color14 ${Theme.cyan}
color15 ${Theme.fgDim}
`
    }

    function hyprColors() {
        return `-- généré par quickshell
return {
    bg = "${bare(Theme.bg)}",
    accent = "${bare(Theme.accent)}",
    accentAlt = "${bare(Theme.accentAlt)}",
    muted = "${bare(Theme.muted)}",
}
`
    }

    function btopTheme() {
        return `# généré par quickshell
theme[main_bg]="${Theme.bg}"
theme[main_fg]="${Theme.fg}"
theme[title]="${Theme.fg}"
theme[hi_fg]="${Theme.accent}"
theme[selected_bg]="${Theme.surfaceHi}"
theme[selected_fg]="${Theme.accent}"
theme[inactive_fg]="${Theme.muted}"
theme[graph_text]="${Theme.fgDim}"
theme[meter_bg]="${Theme.surfaceHi}"
theme[proc_misc]="${Theme.fgDim}"

theme[cpu_box]="${Theme.accentAlt}"
theme[mem_box]="${Theme.success}"
theme[net_box]="${Theme.error}"
theme[proc_box]="${Theme.accent}"
theme[div_line]="${Theme.muted}"

theme[temp_start]="${Theme.success}"
theme[temp_mid]="${Theme.warning}"
theme[temp_end]="${Theme.error}"

theme[cpu_start]="${Theme.cyan}"
theme[cpu_mid]="${Theme.accent}"
theme[cpu_end]="${Theme.accentAlt}"

theme[free_start]="${Theme.accentAlt}"
theme[free_mid]="${Theme.accent}"
theme[free_end]="${Theme.cyan}"

theme[cached_start]="${Theme.cyan}"
theme[cached_mid]="${Theme.accent}"
theme[cached_end]="${Theme.accentAlt}"

theme[available_start]="${Theme.warning}"
theme[available_mid]="${Theme.orange}"
theme[available_end]="${Theme.error}"

theme[used_start]="${Theme.success}"
theme[used_mid]="${Theme.cyan}"
theme[used_end]="${Theme.accent}"

theme[download_start]="${Theme.warning}"
theme[download_mid]="${Theme.orange}"
theme[download_end]="${Theme.error}"

theme[upload_start]="${Theme.success}"
theme[upload_mid]="${Theme.cyan}"
theme[upload_end]="${Theme.accent}"

theme[process_start]="${Theme.accent}"
theme[process_mid]="${Theme.accentAlt}"
theme[process_end]="${Theme.magenta}"
`
    }

    function write() {
        kittyFile.setText(kittyConf())
        hyprFile.setText(hyprColors())
        btopFile.setText(btopTheme())
    }

    function reloadApps() {
        Quickshell.execDetached(["pkill", "-SIGUSR1", "-x", "kitty"])
        Quickshell.execDetached(["hyprctl", "reload"])

        if (Theme.meta.zed)
            Quickshell.execDetached(["sed", "-i",
                "-e", `/"theme": {/,/}/ s/"dark": ".*"/"dark": "${Theme.meta.zed}"/`,
                "-e", `/"icon_theme": {/,/}/ s/"dark": ".*"/"dark": "${Theme.meta.zedIcon}"/`,
                root.zedSettingsPath])
    }

    Connections {
        target: Theme

        function onLoaded() {
            root.write()

            if (root.primed)
                root.reloadApps()

            root.primed = true
        }
    }

    FileView {
        id: kittyFile
        path: root.kittyPath
        preload: false
        printErrors: false
    }

    FileView {
        id: hyprFile
        path: root.hyprPath
        preload: false
        printErrors: false
    }

    FileView {
        id: btopFile
        path: root.btopPath
        preload: false
        printErrors: false
    }
}
