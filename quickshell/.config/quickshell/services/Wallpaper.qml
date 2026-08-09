pragma Singleton

import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import QtQuick

Singleton {
    id: root

    readonly property string directory: `${Quickshell.env("HOME")}/dotfiles/wallpapers`
    readonly property string storePath: Quickshell.statePath("wallpaper")

    property string current: ""

    readonly property string currentUrl: current !== "" ? `file://${current}` : ""

    readonly property alias model: folder
    readonly property int count: folder.count

    Process {
        running: true
        command: ["mkdir", "-p", Quickshell.stateDir]
    }

    FolderListModel {
        id: folder

        folder: `file://${root.directory}`
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif", "*.bmp", "*.tif", "*.tiff"]
        showDirs: false
        sortField: FolderListModel.Name

        onCountChanged: root.ensureCurrent()
    }

    FileView {
        id: store

        path: root.storePath
        printErrors: false

        onLoaded: {
            const saved = text().trim()
            if (saved !== "")
                root.current = saved
            root.ensureCurrent()
        }

        onLoadFailed: root.ensureCurrent()
    }

    function pathAt(index) {
        return folder.get(index, "filePath") ?? ""
    }

    function indexOf(path) {
        for (let i = 0; i < folder.count; i++) {
            if (pathAt(i) === path)
                return i
        }
        return 0
    }

    function ensureCurrent() {
        if (current === "" && folder.count > 0)
            set(pathAt(0))
    }

    function set(path) {
        if (path === "")
            return

        current = path
        store.setText(path)
    }
}
