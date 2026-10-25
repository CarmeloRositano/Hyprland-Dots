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
    property bool changingVolume: false

    function setVolume(value) {
        AudioState.volume = Math.round(Math.max(0, Math.min(150, value)));
        changingVolume = true;
        volumeDebounce.restart();
    }

    Timer {
        id: volumeDebounce
        interval: 100
        repeat: false

        onTriggered: {
            if (volumeSet.running) {
                restart();
                return;
            }

            volumeSet.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (AudioState.volume / 100).toFixed(2)];
            volumeSet.running = true;
        }
    }

    Timer {
        id: volumeSettle
        interval: 400
        repeat: false

        onTriggered: {
            if (volumeDebounce.running || volumeSet.running)
                return;
            changingVolume = false;

            if (!volumeCheck.running)
                volumeCheck.running = true;
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: false

        onTriggered: {
            if (!volumeCheck.running)
                volumeCheck.running = true;
        }
    }

    Process {
        id: volumeCheck
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var out = text.trim();
                var muted = out.indexOf("[MUTED]") !== -1;
                var m = out.match(/Volume:\s+([0-9.]+)/);

                if (!m)
                    return;
                var vol = Math.round(parseFloat(m[1]) * 100);

                if (!root.changingVolume) {
                    AudioState.volume = vol;
                    AudioState.muted = muted;
                }
            }
        }
    }

    Process {
        id: volumeSet

        onExited: {
            if (volumeDebounce.running) {
                volumeDebounce.restart();
            } else {
                volumeSettle.restart();
            }
        }
    }

    Text {
        id: audioText

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        text: "AUDIO::" + "[" + String(root.volume).padStart(3, " ") + "%]"
        color: volumeMouse.containsMouse ? "#d0d0d0" : "#ffffff"

        MouseArea {
            id: volumeMouse

            anchors.fill: parent
            anchors.margins: -5
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: pressed ? Qt.SizeHorCursor : Qt.PointingHandCursor

            property real startVolume: 0
            property real startX: 0
            property bool dragging: false

            onWheel: wheel => {
                root.setVolume(root.volume + (wheel.angleDelta.y > 0 ? 5 : -5));
                wheel.accepted = true;
            }

            onPressed: mouse => {
                startVolume = root.volume;
                startX = mouse.x;
                dragging = false;
            }

            onPositionChanged: mouse => {
                if (!pressed)
                    return;
                if (Math.abs(mouse.x - startX) > 2)
                    dragging = true;

                if (dragging) {
                    root.setVolume(startVolume + (mouse.x - startX) / width * 150);
                }
            }

            onReleased: {
                if (!dragging)
                    AudioMenu.visible = !AudioMenu.visible;

                dragging = false;
            }

            onCanceled: dragging = false
        }
    }
}
