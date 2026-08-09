import QtQuick
import "../.."
import "../../services"
import "../parts"

Item {
    id: root

    readonly property int count: Wallpaper.count
    readonly property int rows: Math.ceil(count / Theme.wallpaperColumns)

    property int selected: 0

    implicitWidth: Theme.wallpaperPickerWidth
    implicitHeight: count === 0
        ? Theme.wallpaperMinHeight
        : Math.min(Theme.wallpaperMaxHeight, rows * Theme.wallpaperCellHeight + Theme.islandPadding * 2)

    focus: true

    Component.onCompleted: selected = Wallpaper.indexOf(Wallpaper.current)

    function move(delta) {
        if (count === 0)
            return

        selected = Math.max(0, Math.min(count - 1, selected + delta))
        grid.positionViewAtIndex(selected, GridView.Contain)
    }

    function apply(index) {
        const path = Wallpaper.pathAt(index)
        if (path === "")
            return

        Wallpaper.set(path)
        IslandState.clearOverlay()
    }

    Keys.onEscapePressed: IslandState.clearOverlay()

    Keys.onLeftPressed: root.move(-1)
    Keys.onRightPressed: root.move(1)
    Keys.onUpPressed: root.move(-Theme.wallpaperColumns)
    Keys.onDownPressed: root.move(Theme.wallpaperColumns)

    Keys.onReturnPressed: root.apply(root.selected)
    Keys.onEnterPressed: root.apply(root.selected)

    Text {
        anchors.centerIn: parent
        visible: root.count === 0
        text: `Aucun wallpaper dans ${Wallpaper.directory}`
        color: Theme.overlay0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.tinyFontSize
    }

    GridView {
        id: grid

        anchors.fill: parent
        anchors.margins: Theme.islandPadding

        visible: root.count > 0
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        cellWidth: Theme.wallpaperCellWidth
        cellHeight: Theme.wallpaperCellHeight

        model: Wallpaper.model

        delegate: WallpaperTile {
            required property string filePath
            required property int index

            width: grid.cellWidth
            height: grid.cellHeight

            path: filePath
            selected: index === root.selected
            active: filePath === Wallpaper.current

            onActivated: root.apply(index)
        }
    }
}
