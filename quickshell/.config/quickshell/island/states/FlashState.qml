import QtQuick
import QtQuick.Layouts
import "../.."
import "../../services"

Item {
    id: root

    readonly property string kind: IslandState.flashKind
    readonly property bool isBattery: kind === "battery"

    readonly property string icon: {
        switch (kind) {
        case "volume": return IslandState.flashCritical ? "󰝟" : "󰕾"
        case "brightness": return "󰃠"
        case "battery": return "󰁺"
        }
        return ""
    }

    readonly property color accent: {
        switch (kind) {
        case "volume": return IslandState.flashCritical ? Theme.red : Theme.blue
        case "brightness": return Theme.yellow
        case "battery": return Theme.red
        }
        return Theme.blue
    }

    implicitWidth: Theme.flashWidth
    implicitHeight: Theme.flashHeight

    RowLayout {
        id: content

        anchors.fill: parent
        anchors.leftMargin: Theme.islandPadding
        anchors.rightMargin: Theme.islandPadding
        spacing: 10

        Text {
            text: root.icon
            color: root.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.largeFontSize
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            Layout.alignment: Qt.AlignVCenter
            radius: 3
            color: Theme.surface0

            Rectangle {
                width: Math.max(0, Math.min(1, IslandState.flashPercent / 100)) * parent.width
                height: parent.height
                radius: parent.radius
                color: root.accent

                Behavior on width {
                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                }
            }
        }

        Text {
            text: IslandState.flashPercent + "%"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.tinyFontSize
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 38
            horizontalAlignment: Text.AlignRight
        }
    }

    SequentialAnimation {
        running: root.isBattery
        loops: 3

        NumberAnimation {
            target: content
            property: "opacity"
            from: 1.0
            to: 0.15
            duration: 200
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: content
            property: "opacity"
            from: 0.15
            to: 1.0
            duration: 200
            easing.type: Easing.InOutQuad
        }
        PauseAnimation { duration: 200 }
    }
}
