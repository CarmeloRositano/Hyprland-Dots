import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls

Item {
    id: root

    property int nodeId: -1
    property bool streamMuted: false
    property real volume: 0.5

    visible: nodeId >= 0
    implicitWidth: visible ? panel.implicitWidth : 0
    implicitHeight: visible ? panel.implicitHeight : 0

    readonly property color textColor: "#ffffff"
    readonly property color mutedColor: "#777777"
    readonly property color borderColor: "#292929"
    readonly property color accentColor: "#d0d0d0"

    function applyVolume(value) {
        volume = Math.max(0, Math.min(1, value));

        const db = volume * 30 - 30;
        setVolume.command = ["dbus-send", "--session", "--type=method_call", "--dest=org.gnome.ShairportSync", "/org/gnome/ShairportSync", "org.freedesktop.DBus.Properties.Set", "string:org.gnome.ShairportSync", "string:Volume", "variant:double:" + db.toFixed(1)];
        setVolume.running = true;
        setAirplayVolume.command = ["dbus-send", "--session", "--type=method_call", "--dest=org.gnome.ShairportSync", "/org/gnome/ShairportSync", "org.gnome.ShairportSync.RemoteControl.SetAirplayVolume", "double:" + db.toFixed(1)];
        setAirplayVolume.running = true;
    }

    function toggleMute() {
        toggleMuteProcess.command = ["dbus-send", "--session", "--type=method_call", "--dest=org.gnome.ShairportSync", "/org/gnome/ShairportSync", "org.gnome.ShairportSync.RemoteControl.ToggleMute"];
        toggleMuteProcess.running = true;
    }

    Row {
        id: panel

        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: "AIRPLAY::"
            color: root.textColor
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.bold: false
        }

        Text {
            id: volumeText

            anchors.verticalCenter: parent.verticalCenter

            text: "[" + (root.streamMuted ? "MUTED" : String(Math.round(root.volume * 100)).padStart(3, " ") + "% ") + "]"

            color: volumeMouse.containsMouse ? root.accentColor : root.textColor

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12

            MouseArea {
                id: volumeMouse

                anchors.fill: parent
                anchors.margins: -5

                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                cursorShape: pressed ? Qt.SizeHorCursor : containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                property real dragStartVolume: 0
                property real dragStartX: 0
                property bool dragging: false

                onWheel: wheel => {
                    const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                    root.applyVolume(root.volume + delta);
                    wheel.accepted = true;
                }

                onPressed: mouse => {
                    dragStartVolume = root.volume;
                    dragStartX = mouse.x;
                    dragging = false;
                }

                onPositionChanged: mouse => {
                    if (!pressed)
                        return;
                    if (Math.abs(mouse.x - dragStartX) > 2)
                        dragging = true;

                    if (dragging) {
                        const delta = (mouse.x - dragStartX) / width * 1.5;

                        root.applyVolume(dragStartVolume + delta);
                    }
                }

                onReleased: {
                    if (!dragging)
                        root.toggleMute();

                    dragging = false;
                }

                onCanceled: {
                    dragging = false;
                }
            }
        }
    }

    Process {
        id: detectStream

        command: ["sh", "-c", "node=$(wpctl status -n | awk '/Streams:/ {s=1;next} s && /^Video/ {s=0} s && /Shairport Sync/ {id=$1; sub(/\\./,\"\",id); in_sh=1; next} s && in_sh && /output_.*\\[active\\]/ {print id; exit} s && in_sh && /^[[:space:]]+[0-9]+[.] [A-Za-z]/ && $0 !~ /output_/ {in_sh=0}'); " + "if [ -n \"$node\" ]; then " + "info=$(wpctl get-volume \"$node\"); " + "vol=$(printf '%s\\n' \"$info\" | awk '{print $2}'); " + "muted=0; printf '%s' \"$info\" | grep -q '\\[MUTED\\]' && muted=1; " + "printf '%s %s %s\\n' \"$node\" \"${vol:-0.5}\" \"$muted\"; " + "else printf '%s\\n' '-1 0.5 0'; fi"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split(/\s+/);
                const id = Number.parseInt(fields[0], 10);
                const detectedVolume = Number.parseFloat(fields[1]);
                const muted = fields[2] === "1";

                root.nodeId = Number.isInteger(id) && id >= 0 ? id : -1;
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true

        onTriggered: {
            if (!detectStream.running)
                detectStream.running = true;
        }
    }

    Process {
        id: setVolume
    }

    Process {
        id: setAirplayVolume
    }

    Process {
        id: toggleMuteProcess

        onExited: {
            if (!detectStream.running)
                detectStream.running = true;
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: {
            if (!readAirplayVolume.running)
                readAirplayVolume.running = true;
        }
    }

    Process {
        id: readAirplayVolume

        command: ["cat", "/home/carmelo/.cache/shairport-volume-db"]

        stdout: StdioCollector {
            onStreamFinished: {
                const db = Number.parseFloat(text.trim());

                if (!Number.isFinite(db))
                    return;

                root.streamMuted = db <= -144;
                root.volume = db <= -144 ? 0 : Math.max(0, Math.min(1, (db + 30) / 30));
            }
        }
    }
}
