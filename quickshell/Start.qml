import Quickshell
import Quickshell.Networking
import Quickshell.Io
import QtQuick

Rectangle {
    id: startButton

    anchors {
        right: parent.right
        verticalCenter: parent.verticalCenter
    }

    width: 65
    height: parent.height

    color: "transparent"

    Text {
        anchors.centerIn: parent
        text: "[ MENU ]"
        color: "#ffffff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
    }

    MouseArea {
        id: startMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: startMenu.toggle()
    }

    visible: barWindow.expand
}
