import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 6
    x: 20

    property int maxWorkspaces: 10

    implicitHeight: 20

    Repeater {
        model: root.maxWorkspaces

        delegate: Rectangle {
            required property int index
            readonly property int wsId: index + 1

            readonly property var wsData: Hyprland.workspaces.values.find(w => w.id === wsId)
            readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId

            width: 15
            color: "transparent"
            height: parent.height

            Text {
                anchors.centerIn: parent
                font.family: "JetBrainsMono Nerd Font"
                text: (parent.isFocused ? "[" : " ") + parent.wsId + (parent.isFocused ? "]" : " ")
                color: "#ffffff"
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
                z: 100

                onClicked: {
                    Hyprland.dispatch(`hl.dsp.focus({ workspace = ${wsId} })`);
                }
            }
        }
    }
}
