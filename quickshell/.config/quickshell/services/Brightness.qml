pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string device: ""
    property int raw: 0
    property int max: 1

    readonly property bool available: device !== ""
    readonly property int percent: max > 0 ? Math.round(raw * 100 / max) : 0

    Process {
        running: true
        command: ["sh", "-c", "ls -1 /sys/class/backlight | head -n1"]

        stdout: SplitParser {
            onRead: data => {
                const name = data.trim()
                if (name !== "")
                    root.device = name
            }
        }
    }

    FileView {
        path: root.available ? `/sys/class/backlight/${root.device}/max_brightness` : ""

        onLoaded: {
            const v = parseInt(text())
            if (!isNaN(v) && v > 0)
                root.max = v
        }
    }

    FileView {
        path: root.available ? `/sys/class/backlight/${root.device}/brightness` : ""
        watchChanges: true

        onFileChanged: reload()

        onLoaded: {
            const v = parseInt(text())
            if (!isNaN(v))
                root.raw = v
        }
    }

    // Les touches répètent plus vite que brightnessctl ne se termine, et réaffecter
    // command pendant que le Process tourne est une erreur : on cumule les pas
    property int pendingDelta: 0

    Process {
        id: setProcess
        command: []
        onExited: root.flush()
    }

    function flush() {
        if (setProcess.running || pendingDelta === 0)
            return

        const d = pendingDelta
        pendingDelta = 0

        setProcess.command = ["brightnessctl", "-e4", "-n2", "set", `${Math.abs(d)}%${d > 0 ? "+" : "-"}`]
        setProcess.running = true
    }

    function step(delta) {
        pendingDelta += delta
        flush()
    }

    function setPercent(p) {
        if (setProcess.running)
            return

        const clamped = Math.max(1, Math.min(100, Math.round(p)))
        setProcess.command = ["brightnessctl", "-e4", "-n2", "set", `${clamped}%`]
        setProcess.running = true
    }
}
