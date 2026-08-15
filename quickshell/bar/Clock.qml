import Quickshell
import QtQuick

Text {
    id: root

    property bool alternate: false

    color: "#ffffff"

    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12

    text: alternate
        ? "[" + Qt.formatDateTime(clock.date, "d MMMM dddd") + "]"
        : "[" + Qt.formatDateTime(clock.date, "hh:mm:ss AP") + "]"

    verticalAlignment: Text.AlignVCenter

    y: 1

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }

    MouseArea {
        anchors.fill: parent

        onClicked: root.alternate = !root.alternate
    }
}