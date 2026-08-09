pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pam
import QtQuick

Singleton {
    id: root

    property bool locked: false
    property bool arming: false
    property bool sleepPending: false

    property string password: ""
    property bool failed: false

    readonly property string shotDir: "/dev/shm"

    function shotPath(name) {
        return `${shotDir}/qs-lock-${name}.png`;
    }

    // Hyprland refuse le screencopy une fois la session verrouillée :
    // la capture doit être terminée avant locked = true.
    function lock() {
        if (locked || arming)
            return;

        arming = true;
        password = "";
        failed = false;

        // -l 0 : PNG sans compression, 66 ms au lieu de 2,7 s en 2880x1800
        shotProc.command = ["sh", "-c", Quickshell.screens.map(s => `grim -l 0 -o '${s.name}' '${root.shotPath(s.name)}'`).join("; ")];
        shotProc.running = true;
    }

    Process {
        id: shotProc
        command: []

        onExited: {
            root.locked = true;
            root.arming = false;
        }
    }

    Process {
        id: cleanupProc
        command: ["sh", "-c", `rm -f ${root.shotDir}/qs-lock-*.png`]
    }

    Process {
        id: suspendProc
        command: ["systemctl", "suspend"]
    }

    function submit() {
        if (pam.active || password === "")
            return;

        failed = false;
        pam.start();
    }

    function finishUnlock() {
        locked = false;
        password = "";
        failed = false;
        cleanupProc.running = true;
    }

    PamContext {
        id: pam

        config: "login"

        onResponseRequiredChanged: if (responseRequired)
            pam.respond(root.password)

        onCompleted: result => {
            if (result === PamResult.Success) {
                root.finishUnlock();
                return;
            }

            root.failed = true;
            root.password = "";
        }

        onError: {
            root.failed = true;
            root.password = "";
        }
    }

    readonly property string message: {
        if (pam.messageIsError && pam.message !== "")
            return pam.message;
        return failed ? "Mot de passe incorrect" : "";
    }

    onLockedChanged: if (locked && sleepPending)
        Logind.inhibitSleep = false

    Connections {
        target: Idle

        function onLockRequested() {
            root.lock();
        }

        function onSuspendRequested() {
            root.lock();
            suspendProc.running = true;
        }
    }

    Connections {
        target: Logind

        function onLockRequested() {
            root.lock();
        }

        function onSleepPending() {
            root.sleepPending = true;
            root.lock();
        }

        function onResumed() {
            Hyprland.dispatch("dpms on");
            root.sleepPending = false;
            Logind.inhibitSleep = true;
        }
    }

    // FILET TEMPORAIRE
    Timer {
        running: root.locked
        interval: 60000
        onTriggered: root.finishUnlock()
    }

    IpcHandler {
        target: "lock"

        function fill(n: int): string {
            root.password = "x".repeat(n);
            return `len=${root.password.length}`;
        }

        function lock(): string {
            root.lock();
            return `locked=${root.locked} arming=${root.arming}`;
        }

        function status(): string {
            return `locked=${root.locked} arming=${root.arming} sleepPending=${root.sleepPending} pamActive=${pam.active} failed=${root.failed}`;
        }
    }
}
