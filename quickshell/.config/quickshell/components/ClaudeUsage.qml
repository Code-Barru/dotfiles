import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout {
    id: claude
    spacing: 6

    // --- Données OAuth ---
    property real fiveHourUtil: 0
    property real weeklyUtil: 0
    property string fiveHourReset: ""
    property string weeklyReset: ""
    property real opusUtil: 0
    property real sonnetUtil: 0
    property string opusReset: ""
    property string sonnetReset: ""
    property bool extraUsageEnabled: false

    // --- État interne ---
    property string _cachedToken: ""
    property bool hasError: false
    property bool isLoading: true
    property int consecutiveErrors: 0
    property int pollInterval: 300000  // 5 min
    property string lastUpdate: ""

    // --- Charger le token OAuth au démarrage ---
    Process {
        id: tokenLoader
        command: ["sh", "-c",
            "cat ~/.local/share/opencode/auth.json | jq -r '.anthropic.access // empty'"]
        running: true
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                claude._cachedToken = data.trim()
                if (claude._cachedToken !== "") {
                    usageProc.running = true
                }
            }
        }
    }

    // Relire le token toutes les 30 min (refresh OAuth)
    Timer {
        interval: 1800000
        running: true
        repeat: true
        onTriggered: tokenLoader.running = true
    }

    // --- Polling de l'usage OAuth ---
    Process {
        id: usageProc
        command: ["curl", "-sf", "--max-time", "10",
                  "-H", "Authorization: Bearer " + claude._cachedToken,
                  "-H", "anthropic-beta: oauth-2025-04-20",
                  "https://api.anthropic.com/api/oauth/usage"]
        running: false
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    var resp = JSON.parse(data)
                    claude.fiveHourUtil = resp.five_hour.utilization
                    claude.weeklyUtil = resp.seven_day.utilization
                    claude.fiveHourReset = resp.five_hour.resets_at || ""
                    claude.weeklyReset = resp.seven_day.resets_at || ""
                    claude.opusUtil = resp.seven_day_opus
                        ? resp.seven_day_opus.utilization : 0
                    claude.sonnetUtil = resp.seven_day_sonnet
                        ? resp.seven_day_sonnet.utilization : 0
                    claude.opusReset = resp.seven_day_opus
                        ? (resp.seven_day_opus.resets_at || "") : ""
                    claude.sonnetReset = resp.seven_day_sonnet
                        ? (resp.seven_day_sonnet.resets_at || "") : ""
                    claude.extraUsageEnabled = resp.extra_usage
                        ? resp.extra_usage.is_enabled : false
                    claude.hasError = false
                    claude.isLoading = false
                    claude.consecutiveErrors = 0
                    claude.lastUpdate = Qt.formatDateTime(new Date(), "HH:mm")
                    pollTimer.interval = claude.pollInterval
                } catch(e) {
                    handleError()
                }
            }
        }
        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0) handleError()
        }
    }

    function handleError() {
        consecutiveErrors++
        hasError = true
        isLoading = false
        // Backoff exponentiel avec jitter, cap à 30 min
        var backoff = Math.min(1800000,
            Math.pow(2, consecutiveErrors) * 5000 +
            Math.random() * 3000)
        pollTimer.interval = backoff
    }

    Timer {
        id: pollTimer
        interval: claude.pollInterval
        running: claude._cachedToken !== ""
        repeat: true
        onTriggered: usageProc.running = true
    }

    // --- Utilitaire : formatage du temps restant ---
    function formatResetTime(isoString) {
        if (!isoString) return "N/A"
        var now = new Date()
        var reset = new Date(isoString)
        var diffMs = reset.getTime() - now.getTime()
        if (diffMs <= 0) return "imminent"
        var totalMins = Math.floor(diffMs / 60000)
        var hours = Math.floor(totalMins / 60)
        var mins = totalMins % 60
        if (hours >= 24) {
            var days = Math.floor(hours / 24)
            return days + "j " + (hours % 24) + "h"
        }
        return hours + "h" + (mins < 10 ? "0" : "") + mins + "m"
    }

    // --- Couleur selon le niveau d'utilisation ---
    function utilizationColor(value) {
        if (value > 80) return bar.red
        if (value > 50) return bar.yellow
        return bar.blue
    }

    // --- UI compacte dans la barre ---

    Image {
        source: "icons/claude-color.svg"
        sourceSize.width: 16
        sourceSize.height: 16
        fillMode: Image.PreserveAspectFit
        Layout.alignment: Qt.AlignVCenter
        opacity: claude.hasError ? 0.4 : 1.0
    }

    Text {
        font.pixelSize: 16
        font.family: "JetBrains Mono"
        color: claude.hasError ? bar.red
             : claude.isLoading ? bar.subtext0
             : utilizationColor(claude.fiveHourUtil)
        text: claude.isLoading ? "..."
            : claude.hasError ? "ERR"
            : Math.round(claude.fiveHourUtil) + "%"
        Layout.alignment: Qt.AlignVCenter
    }

    // Mini barre de progression
    Item {
        id: barContainer
        implicitWidth: 40
        implicitHeight: 6
        Layout.alignment: Qt.AlignVCenter

        Rectangle {
            anchors.fill: parent
            radius: 3
            color: bar.surface0
        }

        Rectangle {
            width: claude.isLoading ? 0
                 : parent.width * Math.min(claude.fiveHourUtil, 100) / 100
            height: parent.height
            radius: 3
            color: claude.hasError ? bar.red
                 : utilizationColor(claude.fiveHourUtil)

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            Behavior on color {
                ColorAnimation { duration: 300 }
            }
        }
    }

    // --- MouseArea pour le tooltip ---
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
    }

    // --- Tooltip détaillé ---
    PopupWindow {
        id: tooltip
        visible: hoverArea.containsMouse && !claude.isLoading
        anchor.window: bar
        anchor.rect.x: bar.width - 8 - 108
        anchor.rect.y: bar.height + 100
        anchor.rect.width: 1
        anchor.rect.height: 1
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Right

        implicitWidth: tooltipCol.width + 36
        implicitHeight: tooltipCol.height + 32
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: bar.crust
            border.color: bar.surface0
            border.width: 1

            ColumnLayout {
                id: tooltipCol
                anchors.centerIn: parent
                spacing: 10

                // --- Quota 5h ---
                Text {
                    text: "Quota 5h"
                    color: bar.text_
                    font.pixelSize: 14
                    font.family: "JetBrains Mono"
                    font.bold: true
                }
                RowLayout {
                    spacing: 10
                    Rectangle {
                        width: 180; height: 10; radius: 5
                        color: bar.surface0
                        Rectangle {
                            width: parent.width * Math.min(claude.fiveHourUtil, 100) / 100
                            height: parent.height; radius: 5
                            color: utilizationColor(claude.fiveHourUtil)
                        }
                    }
                    Text {
                        text: Math.round(claude.fiveHourUtil) + "%"
                        color: utilizationColor(claude.fiveHourUtil)
                        font.pixelSize: 13
                        font.family: "JetBrains Mono"
                    }
                }
                Text {
                    text: "Reset : " + formatResetTime(claude.fiveHourReset)
                    color: bar.subtext0
                    font.pixelSize: 12
                    font.family: "JetBrains Mono"
                }

                // --- Séparateur ---
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: bar.surface0
                }

                // --- Quota 7j ---
                Text {
                    text: "Quota 7j"
                    color: bar.text_
                    font.pixelSize: 14
                    font.family: "JetBrains Mono"
                    font.bold: true
                }
                RowLayout {
                    spacing: 10
                    Rectangle {
                        width: 180; height: 10; radius: 5
                        color: bar.surface0
                        Rectangle {
                            width: parent.width * Math.min(claude.weeklyUtil, 100) / 100
                            height: parent.height; radius: 5
                            color: utilizationColor(claude.weeklyUtil)
                        }
                    }
                    Text {
                        text: Math.round(claude.weeklyUtil) + "%"
                        color: utilizationColor(claude.weeklyUtil)
                        font.pixelSize: 13
                        font.family: "JetBrains Mono"
                    }
                }
                Text {
                    text: "Reset : " + formatResetTime(claude.weeklyReset)
                    color: bar.subtext0
                    font.pixelSize: 12
                    font.family: "JetBrains Mono"
                }
            }
        }
    }
}
