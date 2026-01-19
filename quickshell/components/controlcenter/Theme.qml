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

    // Sizes
    readonly property int headerFontSize: 22
    readonly property int normalFontSize: 16
    readonly property int smallFontSize: 14
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
}
