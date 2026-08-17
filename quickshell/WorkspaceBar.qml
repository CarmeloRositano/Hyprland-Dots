import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: root
    spacing: 10

    // Expose properties for easy customisation when importing
    property int maxWorkspaces: 10

    Repeater {
        model: root.maxWorkspaces
        
        delegate: Rectangle {
            required property int index
            readonly property int wsId: index + 1
            
            // Query live workspace state from the global Hyprland singleton
            readonly property var wsData: Hyprland.workspaces.values.find(w => w.id === wsId)
            readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId

            implicitWidth: 15

            Text {
                anchors.centerIn: parent
                font.family: "JetBrainsMono Nerd Font"
                text: (parent.isFocused ? "[" : " ") + parent.wsId + (parent.isFocused ? "]" : " ")
                color: '#ffffff'
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Hyprland.dispatch(`hl.dsp.focus({ workspace = ${parent.wsId} })`)                }
            }
        }
    }
}
