import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import "components/osd"
import "components/controlcenter"

PanelWindow {
    id: osd
    
    // État partagé - quel OSD est actif
    property string activeOSD: ""
    
    // Polling adaptatif : rapide quand l'OSD ou le CC est visible
    property bool controlCenterOpen: false
    readonly property bool fastPolling: activeOSD !== "" || controlCenterOpen
    
    // Valeurs surveillées
    property int volumeValue: 50
    property bool volumeMuted: false
    property int brightnessValue: 50
    
    // Valeurs précédentes pour détection de changement
    property int previousVolume: -1
    property bool previousMuted: false
    property int previousBrightness: -1
    
    visible: activeOSD !== ""
    
    anchors {
        top: true
        left: true
        right: true
    }
    
    implicitHeight: 60
    
    margins {
        top: 80
    }
    
    WlrLayershell.namespace: "quickshell-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusiveZone: 0
    
    color: "transparent"
    
    // ==================== SURVEILLANCE VOLUME ====================
    
    Process {
        id: getVolume
        command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]
        
        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/(\d+)%/)
                if (match) {
                    const newVolume = parseInt(match[1])
                    if (newVolume !== previousVolume && previousVolume !== -1) {
                        volumeOSD.show()
                    }
                    volumeValue = newVolume
                    previousVolume = newVolume
                }
            }
        }
    }
    
    Process {
        id: getMute
        command: ["pactl", "get-sink-mute", "@DEFAULT_SINK@"]
        
        stdout: SplitParser {
            onRead: data => {
                const newMuted = data.includes("yes") || data.includes("oui")
                if (newMuted !== previousMuted && previousMuted !== false && previousVolume !== -1) {
                    volumeMuted = newMuted
                    volumeOSD.show()
                }
                previousMuted = newMuted
                volumeMuted = newMuted
            }
        }
    }
    
    Timer {
        interval: osd.fastPolling ? 100 : 500
        running: true
        repeat: true
        onTriggered: {
            getVolume.running = true
            getMute.running = true
        }
    }
    
    // ==================== SURVEILLANCE LUMINOSITÉ ====================
    
    Process {
        id: getBrightness
        command: ["brightnessctl", "-m"]
        
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const parts = data.trim().split(',')
                if (parts.length >= 5) {
                    const newBrightness = parseInt(parts[3].replace('%', ''))
                    if (newBrightness !== previousBrightness && previousBrightness !== -1) {
                        brightnessOSD.show()
                    }
                    brightnessValue = newBrightness
                    previousBrightness = newBrightness
                }
            }
        }
    }
    
    Timer {
        interval: osd.fastPolling ? 100 : 500
        running: true
        repeat: true
        onTriggered: {
            getBrightness.running = true
        }
    }

    // ==================== SURVEILLANCE BATTERIE ====================

    property bool batteryWarned20: false
    property bool batteryWarned10: false

    function checkBatteryThresholds() {
        const device = UPower.displayDevice
        if (!device.isPresent) return

        const pct = device.percentage * 100
        const discharging = device.state === UPowerDeviceState.Discharging

        if (!discharging || pct > 25) {
            batteryWarned20 = false
            batteryWarned10 = false
            return
        }

        if (pct <= 10 && !batteryWarned10) {
            batteryWarned10 = true
            batteryWarned20 = true
            showBatteryWarning(Math.round(pct), true)
        } else if (pct <= 20 && !batteryWarned20) {
            batteryWarned20 = true
            showBatteryWarning(Math.round(pct), false)
        }
    }

    function showBatteryWarning(pct, critical) {
        batteryOSD.warningPercent = pct
        batteryOSD.isCritical = critical
        batteryOSD.show()
    }

    Connections {
        target: UPower.displayDevice
        function onPercentageChanged() { checkBatteryThresholds() }
        function onStateChanged() { checkBatteryThresholds() }
    }

    Component.onCompleted: checkBatteryThresholds()

    // ==================== OSD VOLUME ====================
    
    OSDBase {
        id: volumeOSD
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        visible: activeOSD === "volume"
        
        icon: volumeMuted ? "󰝟" : "󰕾"
        value: volumeValue
        iconColor: volumeMuted ? Theme.red : Theme.blue
        barColor: volumeMuted ? Theme.red : Theme.blue
        
        onShowTriggered: {
            activeOSD = "volume"
        }
        
        onHideTriggered: {
            if (activeOSD === "volume") {
                activeOSD = ""
            }
        }
    }
    
    // ==================== OSD LUMINOSITÉ ====================
    
    OSDBase {
        id: brightnessOSD
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        visible: activeOSD === "brightness"
        
        icon: ""
        value: brightnessValue
        iconColor: Theme.blue
        barColor: Theme.blue
        
        onShowTriggered: {
            activeOSD = "brightness"
        }
        
        onHideTriggered: {
            if (activeOSD === "brightness") {
                activeOSD = ""
            }
        }
    }

    // ==================== OSD BATTERIE ====================

    OSDBase {
        id: batteryOSD
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        visible: activeOSD === "battery"

        property int warningPercent: 0
        property bool isCritical: false

        timeout: 3000

        icon: isCritical ? "󰁺" : "󰁼"
        value: warningPercent
        iconColor: isCritical ? Theme.red : Theme.yellow
        barColor: isCritical ? Theme.red : Theme.yellow

        onShowTriggered: {
            activeOSD = "battery"
        }

        onHideTriggered: {
            if (activeOSD === "battery") {
                activeOSD = ""
            }
        }
    }
}
