import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            implicitHeight: barWindow.barVisible ? 45 : 1
            implicitWidth: 300
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            aboveWindows: true

            anchors {
                top: true
            }

            margins {
                left: (screen.width - 300) / 2
            }

            property bool barVisible: false
            property bool expandClock: false
            property bool expandWorkspace: false
            property bool expandPowerbutton: false

            // Check if anything above or in the bar is hovered
            HoverHandler {
                id: barHover
                enabled: barWindow.expandClock

                onHoveredChanged: {
                    if (hovered)
                        hideTimer.stop()
                    else
                        hideTimer.restart()
                }
            }

            // Check if the top 1px is hovered if so open the bar on exist close the bar
            MouseArea {
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                width: 300
                height: 1
                hoverEnabled: true

                onEntered: {
                    barWindow.barVisible = true
                    barWindow.expandClock = true
                    hideTimer.stop()
                }

                onExited: {
                    hideTimer.restart()
                }
            }

            // Timer for when the bar should close
            Timer {
                id: hideTimer
                interval: 50
                repeat: false

                onTriggered: {
                    if (!barHover.hovered)
                        barWindow.expandClock = false
                }
            }

            // Bar
            Rectangle {
                id: contentRoot
                anchors.horizontalCenter: parent.horizontalCenter
                y: (parent.height - height) / 2
                
                width: 284
                color: "#000000"
                radius: 20
                clip: true

                states: [
                    State {
                        name: "expandClock"
                        when: barWindow.expandClock

                        PropertyChanges {
                            target: contentRoot
                            width: 284
                            height: 40
                            opacity: 1
                        }
                    },
                    State {
                        name: "collapsed"
                        when: !barWindow.expandClock

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
                        to: "expandClock"

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
                        from: "expandClock"
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

                // Left
                WorkspaceBar {
                    anchors.verticalCenter: parent.verticalCenter
                    maxWorkspaces: 10
                    visible: barWindow.expandWorkspace
                }

                // Middle
                ClockWidget {
                    anchors.centerIn: parent
                }

                // Right
                PowerButton {
                    id: powerButton
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    visible: barWindow.expandPowerbutton
                }
            }
        }
    }
}
