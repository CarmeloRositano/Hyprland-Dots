import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Hyprland
import QtQuick

Scope {
    NotificationServer {
        id: notifications

        onNotification: notification => {
            notification.tracked = true;
        }
    }

    // Find the application and activate its workspace.
    function openNotificationWorkspace(notification) {
        const appName = String(notification.appName || "").toLowerCase().trim().replace(/[^a-z0-9]/g, "");

        if (!appName) {
            console.warn("Notification has no app name");
            return;
        }

        Hyprland.refreshToplevels();
        const windows = Hyprland.toplevels.values;

        for (const win of windows) {
            if (!win || !win.title)
                continue;

            const ipc = win.lastIpcObject || {};
            const initialTitle = win.initialTitle || "";

            const labels = [
                String(win.title).toLowerCase(),
                String(initialTitle).toLowerCase(),
                String(ipc.class || "").toLowerCase(),
                String(ipc.initial_class || "").toLowerCase(),
                String(ipc.stableId || "").toLowerCase(),
            ].filter(s => s);

            for (const label of labels) {
                if (label === appName || label.includes(appName) || appName.includes(label)) {
                    if (win.workspace)
                        win.workspace.activate();

                    const ws = win.workspace;
                    console.log("Opening workspace", ws && ws.name, "for", notification.appName);
                    return;
                }
            }
        }

        console.warn("Could not find workspace for notification from:", notification.appName);
    }

    PanelWindow {
        id: notificationWindow

        anchors {
            top: true
            right: true
        }

        margins {
            right: 10
            top: 24
        }

        width: 500
        height: 700

        color: "transparent"
        aboveWindows: true
        focusable: false

        mask: Region {
            item: notificationContainer
        }

        Column {
            id: notificationContainer

            width: parent.width
            height: childrenRect.height
            spacing: 10

            Repeater {
                model: notifications.trackedNotifications

                delegate: Rectangle {
                    property Notification notification: modelData

                    width: notificationContainer.width
                    height: 120

                    radius: 8
                    color: mouseArea.containsMouse ? "#202020" : "#0e0e0e"

                    Timer {
                        id: timeoutTimer
                        interval: 8000
                        repeat: false
                        running: true

                        onTriggered: {
                            notification.expire();
                        }
                    }

                    Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 7

                    Image {
                    id: notifyIcon
                    source: notification.image || notification.appIcon
                    visible: (notification.image || notification.appIcon) !== ""
                    fillType: Image.PreserveAspectFit
                    width: 28
                    height: 28
                    radius: 6
                    clip: true
                    }

                    Text {
                    anchors.leftEdge: parent.left
                    text: notification.appName or ""
                    color: "#ffffff"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    bold: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    }

                    Text {
                    anchors.leftEdge: parent.left
                    text: notification.body || notification.summary or ""
                    color: "#bbbbcc"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 3
                    }
                    }
                        anchors.fill: parent
                        hoverEnabled: true

                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onEntered: {
                            timeoutTimer.interval = 5000;
                            timeoutTimer.restart();
                        }

                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton || mouse.button === Qt.RightButton) {
                                notification.dismiss();
                            }
                        }
                    }
                }
            }
        }
    }

    Bar {}
}
