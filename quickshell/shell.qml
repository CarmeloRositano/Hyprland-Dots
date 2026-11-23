import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Hyprland
import QtQuick
import "."

Scope {
    NotificationServer {
        id: notifications

        imageSupported: false
        bodyImagesSupported: false
        bodyMarkupSupported: true

        onNotification: notification => {
            console.log("NOTIFICATION RECEIVED:", notification.appName, "|", notification.summary, "|", notification.body);

            notification.tracked = true;

            console.log("Notification tracked:", notification.tracked);
        }
    }

    // Resolve the application's icon (not notification image attachments).
    function notificationIconSource(notification) {
        const icon = notification.appIcon || "";

        if (icon === "")
            return Quickshell.iconPath("application-x-executable");

        if (icon.startsWith("/") || icon.startsWith("file:") || icon.includes("://"))
            return icon;

        return Quickshell.iconPath(icon, "application-x-executable");
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
            const labels = [String(win.title).toLowerCase(), String(initialTitle).toLowerCase(), String(ipc.class || "").toLowerCase(), String(ipc.initial_class || "").toLowerCase(), String(ipc.stableId || "").toLowerCase()].filter(s => s);

            for (const label of labels) {
                const normalized = label.replace(/[^a-z0-9]/g, "");

                if (normalized === appName || normalized.includes(appName) || appName.includes(normalized)) {
                    if (win.workspace)
                        win.workspace.activate();

                    console.log("Opening workspace", win.workspace && win.workspace.name, "for", notification.appName);
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

        // Pin to the main monitor (falls back to the first connected screen if
        // DP-3 is missing) so reloads/focus changes can't move the window around.
        readonly property ShellScreen targetScreen: {
            for (const scr of Quickshell.screens) {
                if (scr.name === "DP-3")
                    return scr;
            }
            return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
        }

        screen: targetScreen

        implicitWidth: 500
        // Keep the surface non-zero even when empty, otherwise the compositor
        // closes the layer surface during a lock/DPMS cycle and it never re-maps
        // (mirrors the bar's barMin:1 trick, which is why the bar survives locks).
        readonly property int minNotificationHeight: 1
        implicitHeight: Math.max(minNotificationHeight, notificationContainer.implicitHeight)

        color: "transparent"
        aboveWindows: true
        focusable: false

        mask: Region {
            item: notificationContainer
        }

        Column {
            id: notificationContainer

            width: parent.width
            spacing: 10
            height: childrenRect.height

            Repeater {
                model: notifications.trackedNotifications

                delegate: Rectangle {
                    id: notificationCard

                    property Notification notification: modelData

                    width: notificationContainer.width
                    height: cardContent.implicitHeight + 24

                    radius: 8
                    color: mouseArea.containsMouse ? "#202020" : "#0e0e0e"

                    // Automatic dismissal.
                    Timer {
                        id: timeoutTimer

                        interval: 8000
                        repeat: false
                        running: true

                        onTriggered: notification.expire()
                    }

                    // Notification content.
                    Column {
                        id: cardContent

                        width: parent.width - 24
                        x: 12
                        y: 12
                        spacing: 10

                        Row {
                            id: headerRow

                            width: parent.width
                            height: Math.max(64, textColumn.implicitHeight)
                            spacing: 12

                            // Application icon.
                            Rectangle {
                                width: 64
                                height: 64
                                radius: 8
                                color: "transparent"
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 3

                                    source: notificationIconSource(notification)
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    asynchronous: true
                                }
                            }

                            // Notification text.
                            Column {
                                id: textColumn

                                width: parent.width - 76
                                spacing: 5

                                Text {
                                    width: parent.width
                                    text: notification.appName || notification.desktopEntry || "Notification"
                                    color: "#999999"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                Text {
                                    width: parent.width
                                    text: notification.summary || notification.body || "Notification"
                                    color: "#ffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    font.bold: true
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                }

                                Text {
                                    width: parent.width
                                    text: notification.summary ? (notification.body || "") : ""
                                    color: "#bbbbbb"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                }
                            }
                        }
                    }

                    // Mouse interaction.
                    MouseArea {
                        id: mouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onEntered: {
                            timeoutTimer.interval = 5000;
                            timeoutTimer.restart();
                        }

                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                openNotificationWorkspace(notification);
                                notification.dismiss();
                            } else if (mouse.button === Qt.RightButton) {
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
