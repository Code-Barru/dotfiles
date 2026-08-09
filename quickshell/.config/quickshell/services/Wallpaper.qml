pragma Singleton

import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import QtQuick
import ".."

Singleton {
    id: root

    readonly property string directory: `${Quickshell.env("HOME")}/dotfiles/wallpapers/${Theme.name}`
    readonly property string storePath: Quickshell.statePath("wallpapers.json")
    readonly property string folderPrefix: `${directory}/`

    property var saved: ({})

    property string current: ""

    readonly property string currentUrl: current !== "" ? `file://${current}` : ""

    readonly property alias model: folder
    readonly property int count: folder.count

    Process {
        running: true
        command: ["mkdir", "-p", Quickshell.stateDir]
    }

    Connections {
        target: Theme

        function onNameChanged() {
            root.restore()
        }
    }

    FolderListModel {
        id: folder

        folder: `file://${root.directory}`
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif", "*.bmp", "*.tif", "*.tiff"]
        showDirs: false
        sortField: FolderListModel.Name

        onStatusChanged: {
            if (folder.status === FolderListModel.Ready)
                root.ensureCurrent()
        }
    }

    FileView {
        id: store

        path: root.storePath
        printErrors: false

        onLoaded: {
            const raw = text().trim()
            if (raw !== "")
                root.saved = JSON.parse(raw)
            root.restore()
        }

        onLoadFailed: root.restore()
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
        if (current !== "" && current.startsWith(root.folderPrefix))
            return

        const first = folder.count > 0 ? pathAt(0) : ""

        if (first.startsWith(root.folderPrefix))
            set(first)
    }

    function restore() {
        const path = saved[Theme.name] ?? ""

        current = path.startsWith(root.folderPrefix) ? path : ""
        ensureCurrent()
    }

    function set(path) {
        if (path === "")
            return

        current = path
        saved[Theme.name] = path

        store.setText(JSON.stringify(saved))
    }
}
