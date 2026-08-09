pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property var vpnTypes: ["vpn", "wireguard"]

    property var connections: []
    property string activeName: ""
    property bool busy: false

    readonly property bool available: connections.length > 0
    readonly property bool connected: activeName !== ""
    readonly property string name: connected ? activeName : (connections[0] ?? "")

    function splitLast(line) {
        const cut = line.lastIndexOf(":")
        if (cut < 0)
            return null
        return {
            name: line.slice(0, cut).replace(/\\:/g, ":"),
            type: line.slice(cut + 1)
        }
    }

    property var pendingAll: []

    Process {
        id: listProc

        running: true
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        environment: ({ LC_ALL: "C" })

        stdout: SplitParser {
            onRead: line => {
                const entry = root.splitLast(line)
                if (entry && root.vpnTypes.indexOf(entry.type) !== -1)
                    root.pendingAll.push(entry.name)
            }
        }

        onExited: {
            root.connections = root.pendingAll
            root.pendingAll = []
            root.refresh()
        }
    }

    property var pendingActive: []

    Process {
        id: activeProc

        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"]
        environment: ({ LC_ALL: "C" })

        stdout: SplitParser {
            onRead: line => {
                const entry = root.splitLast(line)
                if (entry && root.vpnTypes.indexOf(entry.type) !== -1)
                    root.pendingActive.push(entry.name)
            }
        }

        onExited: {
            root.activeName = root.pendingActive[0] ?? ""
            root.pendingActive = []
        }
    }

    function refresh() {
        if (activeProc.running)
            return

        pendingActive = []
        activeProc.running = true
    }

    property bool watching: false

    onWatchingChanged: if (watching)
        refresh()

    Timer {
        running: root.watching
        interval: 2000
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: toggleProc

        environment: ({ LC_ALL: "C" })

        onExited: {
            root.busy = false
            root.refresh()
        }
    }

    function setEnabled(on) {
        if (toggleProc.running || name === "")
            return

        busy = true
        toggleProc.command = ["nmcli", "connection", on ? "up" : "down", "id", name]
        toggleProc.running = true
    }
}
