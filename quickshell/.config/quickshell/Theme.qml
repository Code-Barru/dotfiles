pragma Singleton
import QtQuick

QtObject {

    readonly property color base: "#1e1e2e"
    readonly property color crust: "#11111b"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color surface2: "#585b70"
    readonly property color overlay0: "#6c7086"
    readonly property color text: "#cdd6f4"
    readonly property color subtext0: "#a6adc8"
    readonly property color blue: "#89b4fa"
    readonly property color green: "#a6e3a1"
    readonly property color yellow: "#f9e2af"
    readonly property color red: "#f38ba8"
    readonly property color mauve: "#cba6f7"
    readonly property color white: "#ffffff"

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
