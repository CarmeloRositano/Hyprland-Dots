import Quickshell
import QtQuick

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            readonly property int barMax: 30
            readonly property int barMin: 1

            implicitHeight: barWindow.barVisible ? barWindow.barMax : barWindow.barMin
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

            property bool barVisible: false
            property bool expand: false

            // Check if anything above or in the bar is hovered
            HoverHandler {
                id: barHover
                enabled: barWindow.expand

                onHoveredChanged: {
                    if (hovered)
                        hideTimer.stop();
                    else
                        hideTimer.restart();
                }
            }

            // Detect hovering over the top edge without blocking mouse input
            HoverHandler {
                id: edgeHover

                onHoveredChanged: {
                    if (hovered) {
                        barWindow.barVisible = true;
                        barWindow.expand = true;
                        hideTimer.stop();
                    } else {
                        hideTimer.restart();
                    }
                }
            }

            // Timer for when the bar should close
            Timer {
                id: hideTimer
                interval: 50
                repeat: false

                onTriggered: {
                    if (!barHover.hovered && !edgeHover.hovered && !startMenu.visible && !networkMenu.visible && !audioMenu.visible && !calendarMenu.visible) {
                        barWindow.expand = false;
                    }
                }
            }

            Rectangle {
                id: contentRoot

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                color: "transparent"

                states: [
                    State {
                        name: "expand"
                        when: barWindow.expand

                        PropertyChanges {
                            target: contentRoot
                            width: parent.width
                            height: barWindow.barMax
                            opacity: 1
                        }
                    },
                    State {
                        name: "collapsed"
                        when: !barWindow.expand

                        PropertyChanges {
                            target: contentRoot
                            width: 12
                            height: 12
                            opacity: 0
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: "collapsed"
                        to: "expand"

                        ParallelAnimation {
                            NumberAnimation {
                                target: contentRoot
                                property: "width"
                                duration: 300
                                easing.type: Easing.OutCubic
                            }

                            NumberAnimation {
                                target: contentRoot
                                property: "height"
                                duration: 300
                                easing.type: Easing.OutCubic
                            }

                            NumberAnimation {
                                target: contentRoot
                                property: "opacity"
                                to: 1
                                duration: 180
                                easing.type: Easing.OutQuad
                            }
                        }
                    },
                    Transition {
                        from: "expand"
                        to: "collapsed"

                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation {
                                    target: contentRoot
                                    property: "width"
                                    duration: 100
                                    easing.type: Easing.InCubic
                                }

                                NumberAnimation {
                                    target: contentRoot
                                    property: "height"
                                    duration: 100
                                    easing.type: Easing.InCubic
                                }

                                NumberAnimation {
                                    target: contentRoot
                                    property: "opacity"
                                    to: 0
                                    duration: 100
                                }
                            }

                            ScriptAction {
                                script: barWindow.barVisible = false
                            }
                        }
                    }
                ]

                Rectangle {
                    id: barContent

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: 5
                        leftMargin: 10
                        rightMargin: 10
                    }

                    height: parent.height - barContent.anchors.topMargin
                    color: '#0e0e0e'

                    // Left
                    WorkspaceBar {
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 10
                        }

                        maxWorkspaces: 10
                        z: 100
                    }

                    // Middle
                    ClockWidget {
                        anchors.centerIn: parent

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: calendarMenu.toggle()
                        }
                    }

                    // Right
                    Row {
                        id: systemTray

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 10
                        }

                        spacing: 10

                        AirPlay {
                            id: airplayWidget
                        }

                        Text {
                            text: airplayWidget.visible ? "│" : ""
                            color: "#ffffff"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Audio {
                            id: audioWidget

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: audioMenu.visible = !audioMenu.visible
                            }
                        }

                        Text {
                            text: "│"
                            color: "#ffffff"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Network {
                            id: networkWidget

                            MouseArea {
                                id: networkMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: networkMenu.toggle()
                            }
                        }

                        Text {
                            text: "│"
                            color: "#ffffff"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: startMenuIcon
                            text: "≡"
                            color: "#ffffff"
                            font.pixelSize: 12

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: startMenu.toggle()
                            }
                        }
                    }

                    // Popup Menus
                    NetworkMenu {
                        id: networkMenu

                        wifiDevice: networkWidget.wifiDevice

                        onVisibleChanged: {
                            if (!visible)
                                hideTimer.restart();
                        }
                    }

                    AudioMenu {
                        id: audioMenu

                        onVisibleChanged: {
                            if (!visible)
                                hideTimer.restart();
                        }
                    }

                    StartMenu {
                        id: startMenu

                        onVisibleChanged: {
                            if (!visible)
                                hideTimer.restart();
                        }
                    }

                    Calendar {
                        id: calendarMenu

                        parentPanel: barWindow

                        onVisibleChanged: {
                            if (!visible)
                                hideTimer.restart();
                        }
                    }
                }
            }
        }
    }
}
