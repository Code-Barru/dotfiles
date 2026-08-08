pragma Singleton
import QtQuick

QtObject {
    // Catppuccin Mocha Colors
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

    // Police
    readonly property string fontFamily: "JetBrains Mono"

    // Sizes
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

    // Durations
    readonly property int fastDuration: 150
    readonly property int normalDuration: 200
    readonly property int slowDuration: 300

    // ==================== DYNAMIC ISLAND ====================

    // Animations
    readonly property int morphDuration: 320
    readonly property int fadeDuration: 180

    // Délais des états
    readonly property int stripTimeout: 5000
    readonly property int flashTimeout: 1500
    readonly property int batteryFlashTimeout: 2400
    readonly property int notifTimeout: 5000
    readonly property int notifMaxTimeout: 10000
    readonly property int pinTimeout: 5000

    // Formes
    readonly property int islandRadius: 18
    readonly property int stripRadius: 3
    readonly property int cornerRadius: 14
    readonly property int islandPadding: 14

    // Dimensions par état
    readonly property int stripWidth: 120
    readonly property int stripHeight: 4

    readonly property int hourWidth: 150
    readonly property int hourHeight: 30

    readonly property int mediaWidth: 440
    readonly property int mediaHeight: 116

    readonly property int flashWidth: 220
    readonly property int flashHeight: 36

    readonly property int notifWidth: 380
    readonly property int notifHeight: 92

    readonly property int notifCenterWidth: 400
    readonly property int notifCenterMaxHeight: 420

    // Hauteur de la fenêtre layer-shell : doit contenir l'état le plus grand
    readonly property int islandWindowHeight: notifCenterMaxHeight + 20

    // Bande de survol invisible qui réveille le strip
    readonly property int hoverBandHeight: 4

    // Respiration entre le bas de l'island et le haut des fenêtres
    readonly property int islandGap: 8
}
