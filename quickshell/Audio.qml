import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    implicitWidth: audioText.implicitWidth
    implicitHeight: audioText.implicitHeight

    property int volume: 0
    property bool muted: false

    Process {
        id: volumeCheck

        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim();

                root.muted = output.indexOf("[MUTED]") !== -1;

                var match = output.match(/Volume:\s+([0-9.]+)/);

                if (match)
                    root.volume = Math.round(parseFloat(match[1]) * 100);
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true

        onTriggered: {
            if (!volumeCheck.running)
                volumeCheck.running = true;
        }
    }

    Text {
        id: audioText

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12

        text: "AUDIO::" + "[" + String(root.volume).padStart(3, " ") + "%]"

        color: "#ffffff"
    }
}
