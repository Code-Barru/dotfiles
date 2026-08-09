pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property int bars: 5
    property var values: []

    property bool active: false

    Process {
        running: true
        command: ["pkill", "-f", `cava -p ${Quickshell.shellPath("services/cava.conf")}`]
    }

    Process {
        running: root.active
        command: ["cava", "-p", Quickshell.shellPath("services/cava.conf")]

        stdout: SplitParser {
            onRead: line => {
                const parts = line.split(";")
                const out = []
                for (let i = 0; i < root.bars; i++)
                    out.push((parseInt(parts[i]) || 0) / 100)
                root.values = out
            }
        }
    }

    onActiveChanged: if (!active) values = []
}
