pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string storePath: Quickshell.statePath("launcher-usage.json")

    readonly property var entries: DesktopEntries.applications.values.filter(a => !a.noDisplay)

    property var usage: ({})

    Process {
        running: true
        command: ["mkdir", "-p", root.storePath.substring(0, root.storePath.lastIndexOf("/"))]
    }

    FileView {
        id: store

        path: root.storePath
        printErrors: false

        onLoaded: {
            try {
                root.usage = JSON.parse(text())
            } catch (e) {
                root.usage = ({})
            }
        }
    }

    function fuzzyScore(app, q) {
        if (q === "")
            return 1

        const name = app.name.toLowerCase()

        if (name === q)
            return 1000
        if (name.startsWith(q))
            return 500 - name.length
        if (name.includes(q))
            return 200 - name.indexOf(q)

        let qi = 0, score = 0, lastMatch = -1
        for (let i = 0; i < name.length && qi < q.length; i++) {
            if (name[i] === q[qi]) {
                score += (i === lastMatch + 1) ? 10 : 3
                if (i === 0 || name[i - 1] === " ")
                    score += 15
                lastMatch = i
                qi++
            }
        }

        if (qi < q.length) {
            const alt = [app.genericName ?? "", app.comment ?? "", (app.keywords ?? []).join(" ")]
                .join(" ").toLowerCase()
            return alt.includes(q) ? 10 : 0
        }

        return score
    }

    function usageBonus(app) {
        return Math.min(usage[app.id] ?? 0, 12) * 8
    }

    function search(q, limit) {
        const needle = q.toLowerCase().trim()
        const out = []

        for (const app of entries) {
            const base = fuzzyScore(app, needle)
            if (base <= 0)
                continue
            out.push({ app: app, score: base + usageBonus(app) })
        }

        out.sort((a, b) => b.score - a.score || a.app.name.localeCompare(b.app.name))
        return out.slice(0, limit)
    }

    function launch(app) {
        if (!app)
            return

        usage = Object.assign({}, usage, { [app.id]: (usage[app.id] ?? 0) + 1 })
        store.setText(JSON.stringify(usage))
        app.execute()
    }

    function run(line) {
        if (line.trim() !== "")
            Quickshell.execDetached(["sh", "-c", line])
    }
}
