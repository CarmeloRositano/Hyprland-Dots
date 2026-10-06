import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    property bool launcherVisible: false

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            launcherVisible = !launcherVisible;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            implicitWidth: launcherVisible ? 500 : 0
            implicitHeight: launcherVisible ? 45 : 0
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            aboveWindows: true

            anchors {
                top: true
            }

            margins {
                left: (screen.width - 300) / 2
            }

            Rectangle {
                id: contentRoot
                anchors.horizontalCenter: parent.horizontalCenter
                width: 500
                height: 40
                y: (parent.height - height) / 2
                color: "#000000"
                radius: 20
                clip: true

                states: [
                    State {
                        name: "expandClock"

                        PropertyChanges {
                            target: contentRoot
                            width: 284
                            height: 40
                            opacity: 1
                        }
                    },
                    State {
                        name: "collapsed"

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
            }
        }
    }
}
