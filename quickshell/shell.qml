import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick

Scope {
    NotificationServer {
        id: notifications
    }

    PanelWindow {
        anchors.right: parent.right
        top: parent.top
        margins {
            right: 10
            top: 24
        }
        width: 500
        height: 700
        color: "transparent"
        aboveWindows: true
        focusable: false
        hoverable: false

        Repeater {
            model: notifications.trackedNotifications

            delegate: Rectangle {
                property Notification notification: modelData
                width: 500
                height: 120
                radius: 8
                color: "#0e0e0e"
                z: 9999

                Column {
                    anchors.fill: parent
                    spacing: 7
                    Text {
                        text: notification.summary || ""
                        color: "#ffffff"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                    Text {
                        text: notification.body || ""
                        color: "#bbbbcc"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 3
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onEntered: started = false
                    onExited: started = false
                }
            }
        }
    }

    Bar {}
}
