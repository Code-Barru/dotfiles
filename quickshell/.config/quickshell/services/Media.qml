pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    readonly property var players: Mpris.players?.values ?? []

    readonly property MprisPlayer player: {
        const list = players
        if (list.length === 0)
            return null

        for (const p of list) {
            if (p.isPlaying)
                return p
        }

        return list[0]
    }

    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: player?.isPlaying ?? false

    readonly property bool active: hasPlayer && player.playbackState !== MprisPlaybackState.Stopped

    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string album: player?.trackAlbum ?? ""
    readonly property string artUrl: player?.trackArtUrl ?? ""

    property string art: ""

    onArtUrlChanged: if (artUrl !== "")
        art = artUrl

    onTitleChanged: if (artUrl === "")
        art = ""
    readonly property string identity: player?.identity ?? ""

    readonly property bool canGoNext: player?.canGoNext ?? false
    readonly property bool canGoPrevious: player?.canGoPrevious ?? false
    readonly property bool canTogglePlaying: player?.canTogglePlaying ?? false
    readonly property bool canSeek: (player?.canSeek ?? false) && (player?.positionSupported ?? false)

    readonly property real position: player?.position ?? 0
    readonly property real length: (player?.lengthSupported ?? false) ? (player?.length ?? 0) : 0
    readonly property real progress: length > 0 ? Math.max(0, Math.min(1, position / length)) : 0

    property bool positionTracking: false

    Timer {
        interval: 1000
        repeat: true
        running: root.positionTracking && root.isPlaying && (root.player?.positionSupported ?? false)
        onTriggered: root.player.positionChanged()
    }

    function togglePlaying() {
        if (player?.canTogglePlaying)
            player.togglePlaying()
    }

    function next() {
        if (player?.canGoNext)
            player.next()
    }

    function previous() {
        if (player?.canGoPrevious)
            player.previous()
    }

    function seekRatio(ratio) {
        if (canSeek && length > 0)
            player.position = Math.max(0, Math.min(1, ratio)) * length
    }

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00"

        const total = Math.floor(seconds)
        const m = Math.floor(total / 60)
        const s = total % 60
        return `${m}:${s < 10 ? "0" : ""}${s}`
    }
}
