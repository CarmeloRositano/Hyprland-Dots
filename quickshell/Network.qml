import Quickshell
import Quickshell.Networking
import Quickshell.Io
import QtQuick

Item {
    id: root

    implicitWidth: 260
    implicitHeight: networkText.implicitHeight

    readonly property var devices: Networking.devices.values

    readonly property var wifiDevice: devices.find(d => d.name === "wlan0")
    readonly property bool wifiConnected: wifiDevice ? wifiDevice.connected : false

    readonly property int wifiStrength: wifiDevice && wifiDevice.connected ? Math.round(Number(wifiDevice.signalStrength)) : 0

    property string ethernetState: ""
    readonly property bool wiredConnected: ethernetState === "1"

    // Network speed
    property real rxMbps: 0
    property real txMbps: 0

    property double lastRxBytes: 0
    property double lastTxBytes: 0
    property double lastSampleTime: 0

    readonly property string networkInterface: {
        if (root.wiredConnected)
            return "enp7s0";

        if (root.wifiConnected)
            return "wlan0";

        return "";
    }

    function formatSpeed(mbps) {
        if (mbps >= 1000)
            return (mbps / 1000).toFixed(2).padStart(7, ".") + "G";

        if (mbps >= 1)
            return mbps.toFixed(2).padStart(7, ".") + "M";

        return (mbps * 1000).toFixed(1).padStart(7, ".") + "K";
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

                var rx = parseInt(values[0]);
                var tx = parseInt(values[1]);
                var now = Date.now();

                if (root.lastSampleTime > 0) {
                    var seconds = (now - root.lastSampleTime) / 1000;

                    if (seconds > 0) {
                        root.rxMbps = ((rx - root.lastRxBytes) * 8) / seconds / 1000000;

                        root.txMbps = ((tx - root.lastTxBytes) * 8) / seconds / 1000000;
                    }
                }

                root.lastRxBytes = rx;
                root.lastTxBytes = tx;
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
            var icon = root.wiredConnected ? "󰈀" : root.wifiConnected ? root.wifiIcon(root.wifiStrength) : "󰤭";
            return "NET::" + icon + (root.wifiConnected ? " [" + root.wifiStrength + "%]" : "") + "  RX::[" + root.formatSpeed(root.rxMbps) + "]" + " TX::[" + root.formatSpeed(root.txMbps) + "]";
        }
    }
}
