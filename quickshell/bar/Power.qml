import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

Window {
    id: power

    property int selectedIndex: 0

    function execute() {
        switch (selectedIndex) {
        case 0:
            lockProcess.running = true;
            break;
        case 1:
            suspendProcess.running = true;
            break;
        case 2:
            rebootProcess.running = true;
            break;
        case 3:
            poweroffProcess.running = true;
            break;
        }
        power.visible = false;
    }

    function moveSelection(direction) {
        selectedIndex += direction;
        if (selectedIndex < 0)
            selectedIndex = 3;

        if (selectedIndex > 3)
            selectedIndex = 0;

    }

    title: "qs-power"
    visible: false
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    width: 200
    height: 250
    onVisibleChanged: {
        if (visible) {
            selectedIndex = 0;
            power.requestActivate();
            power.raise();
        }
    }

    FocusScope {
        id: keyHandler

        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: {
            power.visible = false;
        }
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                power.visible = false;
            } else if (event.key === Qt.Key_Up) {
                event.accepted = true;
                power.moveSelection(-1);
            } else if (event.key === Qt.Key_Down) {
                event.accepted = true;
                power.moveSelection(1);
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true;
                power.execute();
            }
        }
    }

    Process {
        id: lockProcess

        command: ["hyprlock"]
    }

    Process {
        id: suspendProcess

        command: ["systemctl", "suspend"]
    }

    Process {
        id: rebootProcess

        command: ["systemctl", "reboot"]
    }

    Process {
        id: poweroffProcess

        command: ["systemctl", "poweroff"]
    }

    IpcHandler {
        function toggle() {
            power.visible = !power.visible;
            if (power.visible)
                power.selectedIndex = 0;

        }

        target: "power"
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        border.width: 2
        border.color: "#b026ff"
        radius: 12

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 4

            Text {
                text: "Power"
                color: "#ffffff"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                Layout.fillWidth: true
                Layout.leftMargin: 5
                Layout.bottomMargin: 5
            }

            Repeater {
                model: [["", "Lock"], ["󰤄", "Suspend"], ["󰜉", "Reboot"], ["", "Power Off"]]

                delegate: Rectangle {
                    required property int index
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    radius: 8
                    color: power.selectedIndex === index ? "#2a003d" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Text {
                            text: modelData[0]
                            color: "#ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            Layout.preferredWidth: 25
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: modelData[1]
                            color: "#ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            Layout.fillWidth: true
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        focus: false
                        onEntered: {
                            power.selectedIndex = index;
                        }
                        onClicked: {
                            power.execute();
                        }
                    }

                }

            }

        }

    }

}
