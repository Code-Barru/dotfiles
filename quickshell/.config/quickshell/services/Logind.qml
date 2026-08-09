pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    signal lockRequested
    signal sleepPending
    signal resumed

    property bool inhibitSleep: true

    // dbus-monitor --system échoue sans privilège (eavesdropping refusé) ;
    // gdbus monitor passe par AddMatch et reçoit les signaux broadcast.
    Process {
        running: true
        command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.login1"]

        stdout: SplitParser {
            onRead: line => {
                if (line.indexOf(".Session.Lock (") !== -1)
                    root.lockRequested();
                else if (line.indexOf(".Manager.PrepareForSleep (true,)") !== -1)
                    root.sleepPending();
                else if (line.indexOf(".Manager.PrepareForSleep (false,)") !== -1)
                    root.resumed();
            }
        }
    }

    Process {
        running: root.inhibitSleep
        command: ["systemd-inhibit", "--what=sleep", "--who=quickshell", "--why=Verrouillage avant veille", "--mode=delay", "sleep", "infinity"]
    }
}
