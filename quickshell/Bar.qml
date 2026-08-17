import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            color: "#000000"

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30

            // Left
            WorkspaceBar {
                anchors.verticalCenter: parent.verticalCenter
                maxWorkspaces: 10
            }

            // Middle
            ClockWidget {
                anchors.centerIn: parent
            }
        }
    }
}