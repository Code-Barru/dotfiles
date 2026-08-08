pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool ready: sink?.ready ?? false
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property bool micMuted: source?.audio?.muted ?? false

    readonly property real nodeVolume: sink?.audio?.volume ?? 0

    // Pipewire ne relit pas la valeur écrite tout de suite : en répétition de touche
    // les pas suivants repartiraient tous de l'ancienne valeur
    property real pendingVolume: -1

    readonly property real volume: pendingVolume >= 0 ? pendingVolume : nodeVolume
    readonly property int percent: Math.round(volume * 100)

    Timer {
        id: settleTimer
        interval: 300
        onTriggered: root.pendingVolume = -1
    }

    // Sans tracker les nodes ne sont pas liés et leurs propriétés restent invalides
    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    function setVolume(v) {
        const clamped = Math.max(0, Math.min(1, v))

        pendingVolume = clamped
        settleTimer.restart()

        if (sink?.audio)
            sink.audio.volume = clamped
    }

    function stepVolume(delta) {
        setVolume(volume + delta)
    }

    function toggleMute() {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted
    }

    function toggleMicMute() {
        if (source?.audio)
            source.audio.muted = !source.audio.muted
    }
}
