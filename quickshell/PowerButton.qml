import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import QtQuick.Controls

Item {
    id: root

    width: 26
    height: 26

    Text {
        topPadding: 3
        rightPadding: 5
        anchors.centerIn: parent

        text: "⏻"
        color: "white"
        font.pixelSize: 12
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            powerMenu.visible = !powerMenu.visible
        }
    }

    PanelWindow {
        id: powerMenu

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"
        visible: false
        focusable: true

        // Grey/dim background
        Rectangle {
            anchors.fill: parent
            color: "#A0000000"

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    powerMenu.visible = false
                }
            }
        }

        // Click anywhere outside the menu to close it
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                if (!menu.containsMouse)
                    powerMenu.visible = false
            }
        }

        Rectangle {
            id: menu

            width: 220
            height: 220

            anchors.centerIn: parent

            color: "#000000"
            border.width: 2
            border.color: "#3f0071"

            // Prevent clicks inside the menu
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Column {
                anchors {
                    fill: parent
                    margins: 20
                }

                spacing: 10

                Text {
                    width: parent.width
                    text: "Power"
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    width: parent.width
                    height: 40
                    color: lockArea.containsMouse ? "#333333" : "#252525"

                    Text {
                        anchors.centerIn: parent
                        text: "Lock"
                        color: "white"
                    }

                    MouseArea {
                        id: lockArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            lockProcess.running = true
                            powerMenu.visible = false
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 40
                    color: restartArea.containsMouse ? "#333333" : "#252525"

                    Text {
                        anchors.centerIn: parent
                        text: "Restart"
                        color: "white"
                    }

                    MouseArea {
                        id: restartArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            restartProcess.running = true
                            powerMenu.visible = false
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 40
                    color: shutdownArea.containsMouse ? "#333333" : "#252525"

                    Text {
                        anchors.centerIn: parent
                        text: "Shutdown"
                        color: "white"
                    }

                    MouseArea {
                        id: shutdownArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            shutdownProcess.running = true
                            powerMenu.visible = false
                        }
                    }
                }
            }
        }
    }

    Process {
        id: lockProcess
        command: ["loginctl", "lock-session"]
    }

    Process {
        id: restartProcess
        command: ["systemctl", "reboot"]
    }

    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
    }
}