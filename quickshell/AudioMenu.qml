import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PanelWindow {
    id: root

    visible: false
    focusable: true

    HyprlandFocusGrab {
        windows: [root]
        active: root.visible

        onCleared: {
            root.visible = false;
        }
    }

    anchors {
        top: true
        right: true
    }

    margins {
        top: 30
        right: 10
    }

    implicitWidth: 420
    implicitHeight: 520
    color: "transparent"

    property int tab: 0
    property var outputDevices: []
    property var inputDevices: []
    property string pendingDefaultId: ""
    property bool sliderActive: false

    readonly property var devices: tab === 0 ? outputDevices : inputDevices
    readonly property color bg: "#0e0e0e"
    readonly property color bg2: "#151515"
    readonly property color border: "#292929"
    readonly property color textColor: "#e0e0e0"
    readonly property color muted: "#777777"
    readonly property color accent: "#d0d0d0"

    function refresh() {
        if (!statusProcess.running)
            statusProcess.running = true;
    }

    function parseStatus(output) {
        let outputs = [];
        let inputs = [];
        let section = "";

        // Split into lines once and cache
        const lines = output.split("\n");

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];

            // Early exit for empty lines
            if (!line.trim())
                continue;

            // Section detection
            if (line.includes("Sinks:")) {
                section = "output";
                continue;
            }

            if (line.includes("Sources:")) {
                section = "input";
                continue;
            }

            if (line.includes("Filters:") || line.includes("Streams:") || line.includes("Devices:")) {
                section = "";
                continue;
            }

            // Skip non-device lines
            if (section === "")
                continue;

            // Match device pattern
            const match = line.match(/(\*)?\s*(\d+)\.\s+(.+)/);
            if (!match)
                continue;

            // Extract device properties
            const id = match[2];
            const name = match[3].trim();

            // Extract volume and muted status in one pass
            const volumeMatch = name.match(/\[vol:\s*([\d.]+)\]/);
            const muted = /\[MUTED\]/i.test(name);
            const volume = volumeMatch ? Math.round(Number(volumeMatch[1]) * 100) : -1;

            // Clean up name (remove volume/muted indicators)
            const cleanName = name.replace(/\s*\[vol:\s*[\d.]+\]/, "").replace(/\s*\[MUTED\]/i, "").trim();

            // Create device object
            const device = {
                id: id,
                name: cleanName,
                isDefault: match[1] === "*",
                volume: volume,
                muted: muted
            };

            // Add to appropriate array
            if (section === "output") {
                outputs.push(device);
            } else {
                inputs.push(device);
            }
        }

        outputDevices = outputs;
        inputDevices = inputs;
    }

    function setDeviceVolume(deviceId, percentage) {
        var value = percentage / 100;
        volumeProcess.command = ["wpctl", "set-volume", deviceId.toString(), value.toFixed(2)];
        volumeProcess.running = true;
    }

    // Click anywhere outside the menu to close it
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            if (!menu.containsMouse)
                root.visible = false;
        }
    }

    Process {
        id: statusProcess
        command: ["wpctl", "status"]

        stdout: StdioCollector {
            onStreamFinished: root.parseStatus(text)
        }
    }

    Process {
        id: setDefaultProcess
        command: ["wpctl", "set-default", root.pendingDefaultId]

        onExited: {
            refreshTimer.restart();
        }
    }

    Process {
        id: volumeProcess
    }

    Timer {
        id: refreshTimer
        interval: 1000
        repeat: true
        onTriggered: {
            if (root.sliderActive)
                return;
            root.refresh();
        }
    }

    onVisibleChanged: {
        if (visible) {
            root.refresh();
            refreshTimer.restart();
        } else {
            refreshTimer.stop();
        }
    }

    Rectangle {
        id: menu

        anchors.fill: parent
        color: root.bg
        border.color: root.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "AUDIO // DEVICES"
                    color: root.textColor
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "● LIVE"
                    color: root.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                }

                Text {
                    text: "×"
                    color: root.muted
                    font.pixelSize: 20

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.visible = false
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.border
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: ["OUTPUT DEVICES", "INPUT DEVICES"]

                    delegate: Rectangle {
                        required property int index
                        required property string modelData
                        Layout.fillWidth: true
                        height: 36
                        color: root.tab === index ? root.bg2 : "transparent"
                        border.color: root.tab === index ? root.accent : root.border

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: root.tab === index ? root.textColor : root.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.tab = index
                        }
                    }
                }
            }

            Text {
                text: root.tab === 0 ? "AVAILABLE OUTPUTS" : "AVAILABLE INPUTS"
                color: root.muted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
            }

            ListView {
                id: deviceList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: root.devices

                delegate: Rectangle {
                    id: deviceRow

                    required property var modelData

                    width: deviceList.width
                    height: 92

                    color: modelData.isDefault ? "#191919" : rowMouse.containsMouse ? "#171717" : "transparent"

                    border.width: 1
                    border.color: modelData.isDefault ? root.accent : root.border

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: modelData.isDefault ? "●" : "○"
                                color: modelData.isDefault ? root.accent : root.muted
                                font.pixelSize: 13
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: root.textColor
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.isDefault ? "ACTIVE" : "SET >"
                                color: modelData.isDefault ? root.accent : root.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Slider {
                                id: deviceVolumeSlider

                                Layout.fillWidth: true

                                from: 0
                                to: 100
                                value: modelData.volume >= 0 ? modelData.volume : 0

                                onPressedChanged: root.sliderActive = pressed

                                onValueChanged: {
                                    if (modelData.isDefault)
                                        root.activeSlider = volSlider;
                                }

                                onMoved: {
                                    root.setDeviceVolume(modelData.id, value);
                                    modelData.volume = value;
                                }

                                background: Rectangle {
                                    x: deviceVolumeSlider.leftPadding
                                    y: deviceVolumeSlider.topPadding + (deviceVolumeSlider.availableHeight - height) / 2
                                    width: deviceVolumeSlider.availableWidth
                                    height: 4
                                    radius: 1
                                    color: root.border

                                    Rectangle {
                                        width: parent.width * deviceVolumeSlider.visualPosition
                                        height: parent.height
                                        radius: 1
                                        color: root.accent
                                    }
                                }
                            }

                            // Volume Percentage
                            Text {
                                Layout.preferredWidth: 40
                                text: Math.round(deviceVolumeSlider.value) + "%"
                                color: root.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }

                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        z: -1
                        hoverEnabled: true
                        cursorShape: modelData.isDefault ? Qt.ArrowCursor : Qt.PointingHandCursor

                        onClicked: {
                            if (!deviceRow.modelData.isDefault) {
                                root.pendingDefaultId = deviceRow.modelData.id;
                                setDefaultProcess.running = true;
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: deviceList.count === 0
                    text: "NO DEVICES FOUND"
                    color: root.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.border
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "WPCTL // PIPEWIRE"
                    color: root.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
