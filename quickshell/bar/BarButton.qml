import QtQuick

Item {
    id: root

    property string text: ""
    property int fontSize: 12

    signal clicked()

    implicitWidth: label.implicitWidth
    implicitHeight: 26

    Text {
        id: label

        anchors.centerIn: parent

        text: root.text
        color: "#ffffff"

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: root.fontSize

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
