pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pam
import QtQuick
import ".."

Singleton {
    id: root

    property bool locked: false
    property bool arming: false
    property bool islandHeld: false
    property bool sleepPending: false

    property bool unlocking: false

    property string password: ""
    property bool failed: false

    readonly property string shotDir: "/dev/shm"

    property bool capturing: false

    function shotPath(name) {
        return `${shotDir}/qs-lock-shot-${name}.png`;
    }

    function cleanPath(name) {
        return `${shotDir}/qs-lock-clean-${name}.png`;
    }

    function grimFor(pathFn) {
        return ["sh", "-c", Quickshell.screens.map(s => `grim -l 0 -o '${s.name}' '${pathFn(s.name)}'`).join("; ")];
    }

    function lock() {
        if (locked || arming || capturing)
            return;

        capturing = true;
        password = "";
        failed = false;

        cleanProc.command = grimFor(root.cleanPath);
        cleanProc.running = true;
    }

    Process {
        id: cleanProc
        command: []

        onExited: {
            root.capturing = false;
            root.arming = true;
            root.islandHeld = true;
            introTimer.start();
        }
    }

    Timer {
        id: introTimer

        interval: Theme.lockMorphDuration + 40

        onTriggered: {
            shotProc.command = root.grimFor(root.shotPath);
            shotProc.running = true;
        }
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
        if (pam.active || unlocking || password === "")
            return;

        failed = false;
        pam.start();
    }

    function finishUnlock() {
        islandHeld = false;
        password = "";
        failed = false;
        locked = false;
        cleanupProc.running = true;
    }

    Timer {
        running: root.unlocking && root.locked
        interval: Theme.lockUnlockTimeout
        onTriggered: root.finishUnlock()
    }

    PamContext {
        id: pam

        config: "login"

        onResponseRequiredChanged: if (responseRequired)
            pam.respond(root.password)

        onCompleted: result => {
            if (result === PamResult.Success) {
                root.unlocking = true;
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

    IpcHandler {
        target: "lock"

        function lock(): string {
            root.lock();
            return `locked=${root.locked} arming=${root.arming}`;
        }

        function status(): string {
            return `locked=${root.locked} capturing=${root.capturing} arming=${root.arming} islandHeld=${root.islandHeld} unlocking=${root.unlocking} sleepPending=${root.sleepPending} pamActive=${pam.active} failed=${root.failed}`;
        }
    }
}
