import QtQuick
import "../.."
import "../../services"
import "../parts"

Item {
    id: root

    readonly property int count: Theme.count

    property int selected: 0

    implicitWidth: Theme.themePickerWidth
    implicitHeight: count === 0
        ? Theme.themeMinHeight
        : Math.min(Theme.themeMaxHeight, count * Theme.themeRowHeight + Theme.islandPadding * 2)

    focus: true

    onCountChanged: root.selected = Theme.indexOf(Theme.name)

    function move(delta) {
        if (count === 0)
            return

        selected = Math.max(0, Math.min(count - 1, selected + delta))
        list.positionViewAtIndex(selected, ListView.Contain)
    }

    function apply(index) {
        const name = Theme.nameAt(index)
        if (name === "")
            return

        Theme.set(name)
        IslandState.clearOverlay()
    }

    Keys.onEscapePressed: IslandState.clearOverlay()

    Keys.onUpPressed: root.move(-1)
    Keys.onDownPressed: root.move(1)

    Keys.onReturnPressed: root.apply(root.selected)
    Keys.onEnterPressed: root.apply(root.selected)

    Text {
        anchors.centerIn: parent
        visible: root.count === 0
        text: `Aucun thème dans ${Theme.directory}`
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.tinyFontSize
    }

    ListView {
        id: list

        anchors.fill: parent
        anchors.margins: Theme.islandPadding

        visible: root.count > 0
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        model: Theme.model

        delegate: ThemeTile {
            required property string filePath
            required property string fileBaseName
            required property int index

            width: list.width
            height: Theme.themeRowHeight

            path: filePath
            selected: index === root.selected
            active: fileBaseName === Theme.name

            onActivated: root.apply(index)
        }
    }
}
