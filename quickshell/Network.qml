import Quickshell
import Quickshell.Networking
import Quickshell.Io
import QtQuick

Item {
    id: root

    implicitWidth: 270
    implicitHeight: networkText.implicitHeight

    readonly property var devices: Networking.devices.values

    readonly property var wifiDevice: devices.find(d => d.name === "wlan0")
    readonly property bool wifiConnected: wifiDevice ? wifiDevice.connected : false

    readonly property int wifiStrength: wifiDevice && wifiDevice.connected ? Math.round(Number(wifiDevice.signalStrength)) : 0

    property string ethernetState: ""
    readonly property bool wiredConnected: ethernetState === "1"

    // Network speed
    property real download: 0
    property real upload: 0

    property double lastDownload: 0
    property double lastUpload: 0
    property double lastSampleTime: 0

    readonly property string networkInterface: {
        if (root.wiredConnected)
            return "enp7s0";

        if (root.wifiConnected)
            return "wlan0";

        return "";
    }

    function formatSpeed(mbps) {
        return mbps.toFixed(2).padStart(7, " ") + "Mbps";
    }

    function wifiIcon(strength) {
        if (strength >= 80)
            return "󰤨";

        if (strength >= 60)
            return "󰤥";

        if (strength >= 40)
            return "󰤢";

        if (strength >= 20)
            return "󰤟";

        return "󰤯";
    }

    // Ethernet link state
    Process {
        id: ethernetCheck

        command: ["cat", "/sys/class/net/enp7s0/carrier"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.ethernetState = this.text.trim();
            }
        }
    }

    // Network statistics
    Process {
        id: networkStats

        command: root.networkInterface !== "" ? ["cat", "/sys/class/net/" + root.networkInterface + "/statistics/rx_bytes", "/sys/class/net/" + root.networkInterface + "/statistics/tx_bytes"] : ["true"]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.networkInterface === "")
                    return;

                var values = this.text.trim().split("\n");

                if (values.length < 2)
                    return;

                var download = parseInt(values[0]);
                var upload = parseInt(values[1]);
                var now = Date.now();

                if (root.lastSampleTime > 0) {
                    var seconds = (now - root.lastSampleTime) / 1000;

                    if (seconds > 0) {
                        root.download = ((download - root.lastDownload) * 8) / seconds / 1000000;

                        root.upload = ((upload - root.lastUpload) * 8) / seconds / 1000000;
                    }
                }

                root.lastDownload = download;
                root.lastUpload = upload;
                root.lastSampleTime = now;
            }
        }
    }

    // Refresh Ethernet state
    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: {
            if (!ethernetCheck.running)
                ethernetCheck.running = true;
        }
    }

    // Refresh network statistics
    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            if (!networkStats.running)
                networkStats.running = true;
        }
    }

    Text {
        id: networkText

        width: parent.width
        horizontalAlignment: Text.AlignLeft

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        color: "#ffffff"

        text: {
            return "UP/DWN::[ " + root.formatSpeed(root.upload) + " | " + root.formatSpeed(root.download) + " ]";
        }
    }
}
