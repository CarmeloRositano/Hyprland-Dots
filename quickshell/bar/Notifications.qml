import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications

Scope {
    id: root

    NotificationServer {
        id: server

        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        onNotification: function(notification) {
            notification.tracked = true;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            color: "transparent"
            implicitWidth: 400
            implicitHeight: 120

            anchors {
                top: true
                right: true
            }

            Item {
                anchors.fill: parent
                visible: server.trackedNotifications.values.length > 0

                Rectangle {
                    width: 380
                    height: 80
                    color: "#000000"
                    border.color: "#3f0071"
                    border.width: 1

                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: 10
                    }

                    Timer {
                        interval: 10000
                        running: true
                        repeat: false
                        onTriggered: {
                            var list = server.trackedNotifications.values;
                            if (list.length > 0)
                                list[list.length - 1].dismiss();

                        }
                    }

                    Row {
                        spacing: 10

                        anchors {
                            fill: parent
                            margins: 10
                        }

                        // Notification icon
                        Image {
                            id: appIcon

                            width: 58
                            height: 58
                            anchors.top: parent.top
                            fillMode: Image.PreserveAspectFit
                            source: {
                                var list = server.trackedNotifications.values;
                                if (list.length === 0)
                                    return "";

                                var notification = list[list.length - 1];
                                return notification.image || notification.appIcon || "";
                            }
                        }

                        Column {
                            width: parent.width - 58
                            spacing: 1

                            // Sender / summary
                            Text {
                                width: parent.width
                                text: {
                                    var list = server.trackedNotifications.values;
                                    if (list.length === 0)
                                        return "";

                                    return list[list.length - 1].summary;
                                }
                                color: "#ffffff"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 15
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            // Application name
                            Text {
                                width: parent.width
                                text: {
                                    var list = server.trackedNotifications.values;
                                    if (list.length === 0)
                                        return "";

                                    var app = list[list.length - 1].appName || list[list.length - 1].desktopEntry || "Unknown";
                                    return app.split(".").pop();
                                }
                                color: "#888888"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }

                            // Message
                            Text {
                                width: parent.width
                                text: {
                                    var list = server.trackedNotifications.values;
                                    if (list.length === 0)
                                        return "";

                                    return list[list.length - 1].body;
                                }
                                color: "#dddddd"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var list = server.trackedNotifications.values;
                            if (list.length === 0)
                                return ;

                            var notification = list[list.length - 1];
                            notification.dismiss();
                            var app = notification.desktopEntry || notification.appName || "";
                            app = app.toLowerCase();
                            if (app === "com.discordapp.discord")
                                app = "discord";

                            var clients = Hyprland.toplevels.values;
                            for (var i = 0; i < clients.length; i++) {
                                var client = clients[i];
                                if (client.class && client.class.toLowerCase() === app) {
                                    Hyprland.dispatch(`hl.dsp.focus({ workspace = ${client.workspace.id} })`);
                                    break;
                                }
                            }
                        }
                    }

                }

            }

        }

    }

}
