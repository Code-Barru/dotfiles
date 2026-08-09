import Quickshell
import Quickshell.Hyprland
import "services"

Scope {
    GlobalShortcut {
        appid: "quickshell"
        name: "volume_up"
        description: "Volume +"
        onPressed: {
            Audio.stepVolume(0.05)
            IslandState.flash("volume")
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "volume_down"
        description: "Volume -"
        onPressed: {
            Audio.stepVolume(-0.05)
            IslandState.flash("volume")
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "volume_mute"
        description: "Couper le son"
        onPressed: {
            Audio.toggleMute()
            IslandState.flash("volume")
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "mic_mute"
        description: "Couper le micro"
        onPressed: Audio.toggleMicMute()
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "brightness_up"
        description: "Luminosité +"
        onPressed: {
            Brightness.step(5)
            IslandState.flash("brightness")
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "brightness_down"
        description: "Luminosité -"
        onPressed: {
            Brightness.step(-5)
            IslandState.flash("brightness")
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "media_toggle"
        description: "Lecture / pause"
        onPressed: Media.togglePlaying()
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "media_next"
        description: "Piste suivante"
        onPressed: Media.next()
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "media_prev"
        description: "Piste précédente"
        onPressed: Media.previous()
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "lock"
        description: "Verrouiller la session"
        onPressed: Lock.lock()
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "powermenu_toggle"
        description: "Menu d'alimentation"
        onPressed: IslandState.requestState("powerMenu")
    }
}
