import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick

Scope {
    NotificationServer {
        id: notifications

        onNotification: notification => {
            notification.tracked = true;
        }
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

                    // Automatic timeout
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
                        id: mouseArea
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
