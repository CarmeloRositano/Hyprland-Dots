import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool updatesAvailable: false

    implicitWidth: updateText.implicitWidth + 10
    implicitHeight: 26

    Process {
        id: updateCheck

        command: ["sh", "-c", "n=$(checkupdates 2>/dev/null | wc -l); [ \"$n\" -gt 0 ] && echo 1 || echo 0"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.updatesAvailable = this.text.trim() === "1";
            }
        }

    }

    Timer {
        interval: 3.6e+06
        repeat: true
        running: true
        onTriggered: {
            updateCheck.running = true;
        }
    }

    Text {
        id: updateText

        anchors.verticalCenter: parent.verticalCenter
        text: root.updatesAvailable ? "●" : " "
        color: "#ff0000"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.updatesAvailable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (!root.updatesAvailable)
                return ;

            Quickshell.execDetached(["kitty", "--class", "updates", "--title", "updates", "--override", "remember_window_size=no", "--override", "initial_window_width=100c", "--override", "initial_window_height=30c", "-e", "/home/carmelo/.config/quickshell/pentagon-update.sh"]);
        }
    }

}
