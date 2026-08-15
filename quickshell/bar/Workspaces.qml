import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    id: root

    property var monitor

    spacing: 6

    Repeater {
        model: 10

        delegate: Item {
            required property int index
            property int workspaceId: index + 1
            property bool active: Hyprland.focusedMonitor !== null && Hyprland.focusedMonitor.activeWorkspace !== null && Hyprland.focusedMonitor.activeWorkspace.id === workspaceId

            implicitWidth: label.implicitWidth
            implicitHeight: 26

            Text {
                id: label

                anchors.verticalCenter: parent.verticalCenter
                text: active ? "[" + workspaceId + "]" : " " + workspaceId.toString() + " "
                color: "#ffffff"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspaceId} })`);
                }
            }

        }

    }

}
