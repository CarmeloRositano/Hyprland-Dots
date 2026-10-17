import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    implicitWidth: audioText.implicitWidth
    implicitHeight: audioText.implicitHeight

    // Read from shared state — updates instantly when AudioMenu writes to it
    readonly property int volume: AudioState.volume
    readonly property bool muted: AudioState.muted

    Process {
        id: volumeCheck
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim();
                var muted = out.indexOf("[MUTED]") !== -1;
                var m = out.match(/Volume:\s+([0-9.]+)/);
                var vol = m ? Math.round(parseFloat(m[1]) * 100) : 0;
                // Only write if something actually changed (avoids needless repaints)
                if (muted !== AudioState.muted)
                    AudioState.muted = muted;
                if (vol !== AudioState.volume)
                    AudioState.volume = vol;
            }
        }
    }

    Timer {
        interval: 2000
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
