pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

// Serveur de notifications freedesktop + historique
Singleton {
    id: root

    readonly property int historyLimit: 20

    readonly property var history: server.trackedNotifications?.values ?? []
    readonly property int count: history.length

    property Notification latest: null

    signal received(Notification notif)

    NotificationServer {
        id: server

        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true
        persistenceSupported: true

        onNotification: notif => {
            // tracked garde l'objet vivant après le retour du callback
            notif.tracked = true

            root.latest = notif
            root.received(notif)
            root.trim()
        }
    }

    // Les plus anciennes sortent quand l'historique déborde.
    // La copie est nécessaire : dismiss() modifie la liste en cours d'itération.
    function trim() {
        const list = history.slice()
        for (let i = 0; i < list.length - historyLimit; i++)
            list[i].dismiss()
    }

    function dismiss(notif) {
        if (notif) {
            if (root.latest === notif)
                root.latest = null
            notif.dismiss()
        }
    }

    function clearAll() {
        const list = history.slice()
        for (const n of list)
            n.dismiss()
        root.latest = null
    }
}
