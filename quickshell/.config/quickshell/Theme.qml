pragma Singleton
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import QtQuick

Singleton {
    id: root

    readonly property string directory: `${Quickshell.env("HOME")}/dotfiles/themes`
    readonly property string storePath: Quickshell.statePath("theme")

    property string name: ""

    property var meta: ({})

    readonly property alias model: folder
    readonly property int count: folder.count

    property color bg: "#1e1e2e"
    property color bgDeep: "#11111b"
    property color surface: "#313244"
    property color surfaceHi: "#45475a"
    property color surfaceMax: "#585b70"
    property color muted: "#6c7086"
    property color fg: "#cdd6f4"
    property color fgDim: "#a6adc8"
    property color accent: "#89b4fa"
    property color accentAlt: "#cba6f7"
    property color success: "#a6e3a1"
    property color warning: "#f9e2af"
    property color error: "#f38ba8"
    property color cyan: "#94e2d5"
    property color magenta: "#f5c2e7"
    property color orange: "#fab387"
    property color black: "#45475a"
    property color brightBlack: "#585b70"
    property color brightFg: "#bac2de"

    readonly property color white: "#ffffff"

    signal loaded()

    function set(themeName) {
        if (themeName === "" || themeName === root.name)
            return

        root.name = themeName
        store.setText(themeName)
    }

    function ensureName() {
        if (root.name === "")
            root.name = "catppuccin-mocha"
    }

    function apply(raw) {
        const data = JSON.parse(raw)

        root.meta = data

        for (const key in data.colors) {
            if (root[key] !== undefined)
                root[key] = data.colors[key]
        }

        root.loaded()
    }

    function nameAt(index) {
        return folder.get(index, "fileBaseName") ?? ""
    }

    function indexOf(themeName) {
        for (let i = 0; i < folder.count; i++) {
            if (nameAt(i) === themeName)
                return i
        }
        return 0
    }

    Process {
        running: true
        command: ["mkdir", "-p", Quickshell.stateDir]
    }

    FolderListModel {
        id: folder

        folder: `file://${root.directory}`
        nameFilters: ["*.json"]
        showDirs: false
        sortField: FolderListModel.Name
    }

    FileView {
        id: store

        path: root.storePath
        printErrors: false

        onLoaded: {
            const saved = text().trim()
            if (saved !== "")
                root.name = saved
            root.ensureName()
        }

        onLoadFailed: root.ensureName()
    }

    FileView {
        id: palette

        path: root.name !== "" ? `${root.directory}/${root.name}.json` : ""
        printErrors: false
        watchChanges: true

        onFileChanged: reload()
        onLoaded: root.apply(text())
    }

    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    readonly property int headerFontSize: 22
    readonly property int normalFontSize: 16
    readonly property int smallFontSize: 14
    readonly property int tinyFontSize: 12
    readonly property int largeFontSize: 18

    readonly property int sliderHeight: 10
    readonly property int handleSize: 18
    readonly property int toggleWidth: 56
    readonly property int toggleHeight: 30

    readonly property int spacing: 12
    readonly property int largeSpacing: 24
    readonly property int margin: 20

    readonly property int fastDuration: 150
    readonly property int normalDuration: 200
    readonly property int slowDuration: 300

    readonly property int morphDuration: 320
    readonly property int workspaceMorphDuration: 150
    readonly property int workspaceFadeDuration: 80
    readonly property int fadeDuration: 180

    readonly property int stripTimeout: 5000
    readonly property int flashTimeout: 1500
    readonly property int batteryFlashTimeout: 2400
    readonly property int notifTimeout: 5000
    readonly property int notifMaxTimeout: 10000
    readonly property int mediaIntroTimeout: 2000
    readonly property int workspaceTimeout: 1100

    readonly property int islandRadius: 18
    readonly property int stripRadius: 3
    readonly property int cornerRadius: 14
    readonly property int islandPadding: 14

    readonly property int stripWidth: 120
    readonly property int stripHeight: 4

    readonly property int hourWidth: 90
    readonly property int hourHeight: 30

    readonly property int controlCenterWidth: 440
    readonly property int controlCenterMinHeight: 116
    readonly property int controlCenterMaxHeight: 560

    readonly property int tileHeight: 44
    readonly property int controlRowHeight: 28
    readonly property int listMaxHeight: 160

    readonly property int toggleSmallWidth: 40
    readonly property int toggleSmallHeight: 22

    readonly property int workspaceWidth: 150
    readonly property int workspaceHeight: 30

    readonly property int wormTrackWidth: 104
    readonly property int wormHeight: 4
    readonly property int wormSlots: 4

    readonly property int mediaVizWidth: 135
    readonly property int mediaVizHeight: 30

    readonly property int mediaWidth: 440
    readonly property int mediaHeight: 104

    readonly property int launcherWidth: 520
    readonly property int launcherInputHeight: 36
    readonly property int launcherRowHeight: 46
    readonly property int launcherMaxRows: 6
    readonly property int launcherMinHeight: launcherInputHeight + islandPadding * 2
    readonly property int launcherMaxHeight: launcherMinHeight + launcherRowHeight * launcherMaxRows + spacing

    readonly property int barWidth: 3
    readonly property int barSpacing: 2
    readonly property int barMaxHeight: 16

    readonly property int wallpaperColumns: 3
    readonly property int wallpaperCellWidth: 168
    readonly property int wallpaperCellHeight: 104
    readonly property int wallpaperMaxRows: 3
    readonly property int wallpaperPickerWidth: wallpaperColumns * wallpaperCellWidth + islandPadding * 2
    readonly property int wallpaperMinHeight: wallpaperCellHeight + islandPadding * 2
    readonly property int wallpaperMaxHeight: wallpaperCellHeight * wallpaperMaxRows + islandPadding * 2
    readonly property int wallpaperFadeDuration: 600

    readonly property int themePickerWidth: 360
    readonly property int themeRowHeight: 52
    readonly property int themeMaxRows: 5
    readonly property int themeMinHeight: themeRowHeight + islandPadding * 2
    readonly property int themeMaxHeight: themeRowHeight * themeMaxRows + islandPadding * 2
    readonly property int themeSwatchSize: 14

    readonly property real lockBlur: 1.0
    readonly property int lockBlurMax: 64
    readonly property real lockScrimOpacity: 0.35
    readonly property int lockClockFontSize: 96
    readonly property int lockUserFontSize: 18
    readonly property int lockFieldWidth: 360
    readonly property int lockFieldHeight: 52
    readonly property int lockFadeDuration: 250
    readonly property int lockBlurDuration: 700
    readonly property int lockDotSize: 12
    readonly property int lockDotSpacing: 5
    readonly property int lockDotDuration: 180
    readonly property int lockMessageHeight: 20

    readonly property int lockCardWidth: 440
    readonly property int lockCardHeight: 302
    readonly property int lockCardInset: 16
    readonly property int lockPanelWidth: lockCardWidth - lockCardInset * 2
    readonly property int lockPanelHeight: lockCardHeight - lockCardInset * 2
    readonly property int lockMorphDuration: 420
    readonly property int lockSettleDuration: 260
    readonly property int lockSettleOffset: 18
    readonly property int lockUnlockTimeout: 1500

    readonly property int flashWidth: 220
    readonly property int flashHeight: 36

    readonly property int notifWidth: 380
    readonly property int notifHeight: 92

    readonly property int notifCenterWidth: 400
    readonly property int notifCenterMaxHeight: 420

    readonly property int powerMenuWidth: 412
    readonly property int powerMenuHeight: 224

    readonly property int powerActionWidth: 120
    readonly property int powerActionHeight: 92

    readonly property int hoverBandHeight: 4
}
