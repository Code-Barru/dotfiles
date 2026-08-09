import QtQuick
import QtQuick.Layouts
import "../.."
import "../../services"
import "../parts"

Item {
    id: root

    readonly property string mode: IslandState.launcherMode
    readonly property bool isRun: mode === "run"

    property int selected: 0

    readonly property var results: root.isRun
        ? []
        : Apps.search(input.text, Theme.launcherMaxRows)

    readonly property int listHeight: results.length > 0
        ? results.length * Theme.launcherRowHeight + Theme.spacing
        : 0

    implicitWidth: Theme.launcherWidth
    implicitHeight: Math.min(Theme.launcherMaxHeight, Theme.launcherMinHeight + listHeight)

    onResultsChanged: selected = 0

    Component.onCompleted: input.forceActiveFocus()

    function activate() {
        if (root.isRun) {
            Apps.run(input.text)
            IslandState.clearOverlay()
            return
        }

        const entry = results[selected]
        if (!entry)
            return

        Apps.launch(entry.app)
        IslandState.clearOverlay()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.islandPadding
        spacing: Theme.spacing

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.launcherInputHeight

            radius: 10
            color: Theme.base
            border.width: 1
            border.color: Theme.surface1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: root.isRun ? "󰆍" : "󰍉"
                    color: root.isRun ? Theme.green : Theme.blue
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.smallFontSize
                }

                TextInput {
                    id: input

                    Layout.fillWidth: true
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.smallFontSize
                    selectByMouse: true
                    clip: true

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: input.text === ""
                        text: root.isRun ? "Commande" : "Rechercher une application"
                        color: Theme.overlay0
                        font: input.font
                    }

                    Keys.onEscapePressed: IslandState.clearOverlay()

                    Keys.onDownPressed: root.selected = Math.min(root.selected + 1, Math.max(0, root.results.length - 1))
                    Keys.onUpPressed: root.selected = Math.max(root.selected - 1, 0)

                    Keys.onReturnPressed: root.activate()
                    Keys.onEnterPressed: root.activate()
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: root.results.length * Theme.launcherRowHeight

            visible: root.results.length > 0
            clip: true
            interactive: false
            currentIndex: root.selected
            model: root.results

            delegate: LauncherRow {
                required property var modelData
                required property int index

                width: ListView.view.width
                app: modelData.app
                selected: index === root.selected

                onActivated: {
                    root.selected = index
                    root.activate()
                }
            }
        }
    }
}
