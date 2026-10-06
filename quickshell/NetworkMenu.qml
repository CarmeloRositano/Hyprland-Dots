import Quickshell
import Quickshell.Networking
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    visible: false
    focusable: true

    anchors {
        right: true
        top: true
    }

    property int menuOffset: 30

    margins {
        top: menuOffset
        right: 10
    }

    implicitWidth: 420
    implicitHeight: 520

    color: "transparent"

    property string accent: "#d0d0d0"
    property string bg: "#0e0e0e"
    property string bg2: "#151515"
    property string border: "#292929"
    property string text: "#e0e0e0"
    property string muted: "#777777"

    required property var wifiDevice

    readonly property bool wifiConnected: wifiDevice ? wifiDevice.connected : false

    readonly property bool ethernetConnected: ethernetState === "1"

    property string ethernetState: ""

    property int scanDots: 1
    property bool scanning: false

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

    Timer {
        interval: 2000
        running: root.visible
        repeat: true

        onTriggered: {
            ethernetCheck.running = true;
        }
    }

    Timer {
        interval: 400
        running: root.visible && root.scanning
        repeat: true

        onTriggered: {
            root.scanDots++;

            if (root.scanDots > 3)
                root.scanDots = 1;
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.visible

        onCleared: {
            root.visible = false;
        }
    }

    function toggle() {
        root.visible = !root.visible;

        if (root.visible) {
            ethernetCheck.running = true;

            if (root.wifiDevice)
                root.scan();
        }
    }

    function scan() {
        if (!root.wifiDevice)
            return;

        root.scanDots = 1;
        root.scanning = true;

        root.wifiDevice.scannerEnabled = false;

        Qt.callLater(function () {
            if (root.wifiDevice)
                root.wifiDevice.scannerEnabled = true;
        });
    }

    Rectangle {
        anchors.fill: parent

        color: root.bg

        border.color: root.border
        border.width: 1

        // TUI grid
        Repeater {
            model: Math.floor(width / 40)

            Rectangle {
                x: index * 40
                y: 0

                width: 1
                height: parent.height

                color: root.border
                opacity: 0.12
            }
        }

        Repeater {
            model: Math.floor(height / 40)

            Rectangle {
                x: 0
                y: index * 40

                width: parent.width
                height: 1

                color: root.border
                opacity: 0.12
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24

            spacing: 14

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "NETWORK // STATUS"

                    color: root.accent

                    font.family: "monospace"
                    font.pixelSize: 18
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: root.ethernetConnected || root.wifiConnected ? "● ONLINE" : "○ OFFLINE"

                    color: root.ethernetConnected || root.wifiConnected ? root.accent : root.muted

                    font.family: "monospace"
                    font.pixelSize: 11
                }
            }

            Rectangle {
                Layout.fillWidth: true

                height: 1

                color: root.border
            }

            // Active connection
            Text {
                text: "// ACTIVE CONNECTION"

                color: root.accent

                font.family: "monospace"
                font.pixelSize: 11
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true

                height: 64

                color: root.bg2

                border.color: root.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 14
                    anchors.rightMargin: 14

                    spacing: 12

                    Text {
                        text: root.ethernetConnected ? "󰈀" : root.wifiConnected ? "󰤨" : "󰤭"

                        color: root.accent

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 22
                    }

                    ColumnLayout {
                        Layout.fillWidth: true

                        spacing: 2

                        Text {
                            text: root.ethernetConnected ? "ETHERNET" : root.wifiConnected ? "WI-FI" : "DISCONNECTED"

                            color: root.text

                            font.family: "monospace"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Text {
                            text: root.ethernetConnected ? "enp7s0 // CONNECTED" : root.wifiConnected ? root.wifiDevice.name + " // CONNECTED" : "NO ACTIVE CONNECTION"

                            color: root.muted

                            font.family: "monospace"
                            font.pixelSize: 10
                        }
                    }

                    Text {
                        text: root.ethernetConnected || root.wifiConnected ? "●" : "○"

                        color: root.accent

                        font.family: "monospace"
                        font.pixelSize: 12
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true

                height: 1

                color: root.border
            }

            // Wi-Fi
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "// AVAILABLE WI-FI"

                    color: root.accent

                    font.family: "monospace"
                    font.pixelSize: 11
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    id: scanStatus

                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignRight

                    text: root.scanning ? "SCANNING" + ".".repeat(root.scanDots) : "SCAN"

                    color: root.scanning ? root.accent : root.muted
                    font.family: "monospace"
                    font.pixelSize: 9

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.scan();
                        }
                    }
                }
            }

            // Wi-Fi network list
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                color: root.bg2
                border.color: root.border
                border.width: 1
                clip: true

                ListView {
                    id: wifiList

                    anchors.fill: parent

                    spacing: 2
                    clip: true

                    model: root.wifiDevice ? root.wifiDevice.networks : null

                    delegate: Rectangle {
                        width: wifiList.width
                        height: 42

                        property bool hovered: networkMouse.containsMouse

                        color: hovered ? "#1c1c1c" : modelData && modelData.connected ? "#191919" : "transparent"

                        border.color: modelData && modelData.connected || hovered ? root.accent : "transparent"

                        border.width: 1

                        // Connection marker
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter

                            width: 12

                            text: modelData.connected ? ">" : " "

                            color: root.accent
                            font.family: "monospace"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        // Wi-Fi icon
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter

                            text: {
                                var strength = Number(modelData.signalStrength) * 100;

                                if (isNaN(strength))
                                    return "󰤯";

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
                            color: root.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 17
                        }

                        // Network name
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 66
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            text: modelData.name

                            color: root.text
                            font.family: "monospace"
                            font.pixelSize: 11

                            elide: Text.ElideRight
                        }

                        // Status
                        Text {
                            id: status

                            anchors.right: parent.right
                            anchors.rightMargin: 14
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: signal

                                anchors.right: status.left
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter

                                text: {
                                    var strength = Number(modelData.signalStrength) * 100;

                                    return isNaN(strength) ? "--%" : Math.round(strength) + "%";
                                }

                                color: root.muted
                                font.family: "monospace"
                                font.pixelSize: 9
                            }

                            text: modelData.connected ? "●" : "○"

                            color: modelData.connected ? root.accent : root.muted

                            font.family: "monospace"
                            font.pixelSize: 10
                        }

                        // Status text
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 66
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 5

                            text: modelData.connected ? "CONNECTED" : modelData.known ? "KNOWN NETWORK" : "AVAILABLE"

                            color: modelData.connected ? root.accent : root.muted

                            font.family: "monospace"
                            font.pixelSize: 8
                        }

                        MouseArea {
                            id: networkMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (!modelData.connected)
                                    modelData.connect();
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent

                        visible: !root.wifiDevice || root.wifiDevice.networks.count === 0

                        text: root.wifiDevice ? "NO NETWORKS FOUND" : "WI-FI DEVICE NOT FOUND"

                        color: root.muted

                        font.family: "monospace"
                        font.pixelSize: 10
                    }
                }
            }

            // Footer
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "[ ESC ] CLOSE"

                    color: root.muted

                    font.family: "monospace"
                    font.pixelSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "[ CLICK NETWORK TO CONNECT ]"

                    color: root.muted

                    font.family: "monospace"
                    font.pixelSize: 8
                }
            }
        }
    }

    Keys.onEscapePressed: {
        root.visible = false;
    }
}
