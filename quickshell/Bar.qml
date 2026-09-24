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

            // Check if the top 1px is hovered if so open the bar on exist close the bar
            MouseArea {
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width
                height: 1
                hoverEnabled: true

                onEntered: {
                    barWindow.barVisible = true;
                    barWindow.expand = true;
                    hideTimer.stop();
                }

                onExited: {
                    hideTimer.restart();
                }
            }

            // Timer for when the bar should close
            Timer {
                id: hideTimer
                interval: 50
                repeat: false

                onTriggered: {
                    if (!barHover.hovered)
                        barWindow.expand = false;
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

                    // StartMenu {
                    //     id: startMenu
                    //     anchors {
                    //         right: parent.right
                    //         verticalCenter: parent.verticalCenter
                    //     }
                    //     visible: barWindow.expandPowerbutton
                    // }
                }
            }
        }
    }
}
