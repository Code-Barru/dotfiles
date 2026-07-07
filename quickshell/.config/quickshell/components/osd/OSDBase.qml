import QtQuick
import QtQuick.Layouts
import "../controlcenter"

Rectangle {
    id: osdBase
    
    // Properties exposées
    property string icon: ""
    property int value: 0
    property color iconColor: Theme.blue
    property color barColor: Theme.blue
    property int timeout: 1500

    // Signaux
    signal showTriggered()
    signal hideTriggered()

    // État interne
    property bool isVisible: false
    
    // Style
    color: Theme.crust
    opacity: isVisible ? 0.95 : 0.0
    radius: 12
    
    width: 280
    height: 60
    
    // Animation d'opacité
    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: isVisible ? Easing.OutQuad : Easing.InQuad
        }
    }
    
    // Timer d'auto-masquage
    Timer {
        id: hideTimer
        interval: osdBase.timeout
        repeat: false
        onTriggered: osdBase.dismiss()
    }

    // Méthode publique pour afficher l'OSD
    function show() {
        isVisible = true
        showTriggered()
        hideTimer.restart()
    }

    function dismiss() {
        isVisible = false
        hideTimer.stop()
        hideTriggered()
    }
    
    // Layout horizontal compact
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12
        
        // Icône
        Text {
            text: osdBase.icon
            color: osdBase.iconColor
            font.pixelSize: 24
            font.family: "JetBrains Mono"
            Layout.alignment: Qt.AlignVCenter
        }
        
        // Barre de progression
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 12
            Layout.alignment: Qt.AlignVCenter
            radius: 6
            color: Theme.surface0
            
            // Fill bar
            Rectangle {
                width: (osdBase.value / 100) * parent.width
                height: parent.height
                radius: 6
                color: osdBase.barColor
                
                Behavior on width {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
        
        // Pourcentage
        Text {
            text: osdBase.value + "%"
            color: Theme.text
            font.pixelSize: 18
            font.family: "JetBrains Mono"
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 50
        }
    }
}
