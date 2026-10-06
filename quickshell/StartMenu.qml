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

    // Current Uptime
    Process {
        id: uptimeProcess

        command: ["sh", "-c", "cat /proc/uptime"]

        stdout: StdioCollector {
            onStreamFinished: {
                var seconds = Math.floor(parseFloat(text.trim().split(" ")[0]));

                var days = Math.floor(seconds / 86400);
                seconds %= 86400;

                var hours = Math.floor(seconds / 3600);
                seconds %= 3600;

                var minutes = Math.floor(seconds / 60);

                root.uptime = days > 0 ? days + "D " + hours + "H " + minutes + "M" : hours + "H " + minutes + "M";
            }
        }
    }

    Timer {
        interval: 60000
        running: root.visible
        repeat: true

        onTriggered: uptimeProcess.running = true
    }

    anchors {
        right: true
        top: true
    }

    property int menuOffset: 30

    margins {
        top: menuOffset
        right: 10
    }

    implicitWidth: 620
    implicitHeight: 720

    color: "transparent"

    property string accent: "#d0d0d0"
    property string bg: "#0e0e0e"
    property string bg2: "#151515"
    property string border: "#292929"
    property string text: "#e0e0e0"
    property string muted: "#777777"
    property string uptime: "..."

    function toggle() {
        visible = !visible;

        if (visible) {
            search.text = "";
            search.forceActiveFocus();
            uptimeProcess.running = true;
        }
    }

    function launch(command) {
        Quickshell.execDetached(["sh", "-c", command]);
        visible = false;
    }

    function isPinned(app) {
        return pinnedNames.indexOf(app.name) !== -1;
    }

    function togglePin(app) {
        console.log('app: ' + app);
        var pins = pinnedNames.slice();
        var index = pins.indexOf(app.name);

        if (index === -1)
            pins.push(app.name);
        else
            pins.splice(index, 1);

        pinnedNames = pins;

        pinFile.setText(JSON.stringify(pins, null, 2));
    }

    Rectangle {
        anchors.fill: parent
        z: 1

        color: root.bg
        border.color: root.border
        border.width: 1

        // Subtle TUI grid
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
                    text: "SYSTEM // START"
                    color: root.accent
                    font.family: "monospace"
                    font.pixelSize: 18
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    spacing: 1
                    Layout.alignment: Qt.AlignRight

                    Text {
                        text: "● ONLINE"
                        color: root.accent
                        font.family: "monospace"
                        font.pixelSize: 11
                    }

                    Text {
                        text: "UP " + root.uptime
                        color: root.muted
                        font.family: "monospace"
                        font.pixelSize: 10
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.border
            }

            // Search
            Rectangle {
                Layout.fillWidth: true
                height: 48

                color: root.bg2
                border.color: search.activeFocus ? root.accent : root.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14

                    Text {
                        text: ">"
                        color: root.accent
                        font.family: "monospace"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    TextField {
                        id: search

                        Layout.fillWidth: true

                        placeholderText: "SEARCH APPLICATIONS..."
                        placeholderTextColor: root.muted

                        color: root.text
                        font.family: "monospace"
                        font.pixelSize: 14

                        background: null

                        selectByMouse: true

                        Keys.onEscapePressed: {
                            root.visible = false;
                        }

                        Keys.onReturnPressed: {
                            if (filteredApps.length > 0)
                                root.launch(filteredApps[0].command);
                        }
                    }

                    Text {
                        text: "ESC"
                        color: root.muted
                        font.family: "monospace"
                        font.pixelSize: 10
                    }
                }
            }

            // Pinned
            Text {
                text: "// PINNED"
                color: root.accent
                font.family: "monospace"
                font.pixelSize: 11
                font.bold: true
            }

            GridLayout {
                Layout.fillWidth: true

                columns: 3
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: pinnedApps

                    Rectangle {
                        Layout.fillWidth: true
                        height: 72

                        property bool hovered: mouse.containsMouse || pinMouse.containsMouse

                        color: hovered ? "#1c1c1c" : root.bg2
                        border.color: hovered ? root.accent : root.border
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Image {
                                source: Quickshell.iconPath(modelData.icon)

                                Layout.preferredWidth: 18
                                Layout.preferredHeight: 18
                                Layout.minimumWidth: 18
                                Layout.minimumHeight: 18
                                Layout.maximumWidth: 18
                                Layout.maximumHeight: 18

                                fillMode: Image.PreserveAspectFit
                            }

                            ColumnLayout {
                                spacing: 2

                                Text {
                                    text: modelData.name
                                    color: root.text
                                    font.family: "monospace"
                                    font.pixelSize: 12
                                }
                            }
                        }

                        Text {
                            id: pinButton

                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter

                            text: "★"
                            color: root.accent

                            opacity: parent.hovered ? 1.0 : 0.0

                            font.family: "monospace"
                            font.pixelSize: 17

                            width: 44
                            height: 44

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                id: pinMouse

                                anchors.fill: parent

                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    console.log("Unpinning: " + modelData.name);
                                    togglePin(modelData);
                                }
                            }
                        }

                        MouseArea {
                            id: mouse

                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.rightMargin: 44

                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.launch(modelData.command);
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.border
            }

            // Applications
            Text {
                text: "// APPLICATIONS"
                color: root.accent
                font.family: "monospace"
                font.pixelSize: 11
                font.bold: true
            }

            // Application list
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true

                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ColumnLayout {
                    width: parent.width
                    spacing: 2

                    Repeater {
                        model: filteredApps

                        Rectangle {
                            Layout.fillWidth: true
                            height: 38

                            property bool rowHovered: appMouse.containsMouse || pinMouse.containsMouse

                            color: rowHovered ? "#1c1c1c" : "transparent"
                            border.color: rowHovered ? root.accent : "transparent"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                Text {
                                    text: rowHovered ? ">" : " "
                                    color: root.accent
                                    font.family: "monospace"
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                Image {
                                    source: Quickshell.iconPath(modelData.icon)

                                    Layout.preferredWidth: 18
                                    Layout.preferredHeight: 18
                                    Layout.minimumWidth: 18
                                    Layout.minimumHeight: 18
                                    Layout.maximumWidth: 18
                                    Layout.maximumHeight: 18

                                    fillMode: Image.PreserveAspectFit
                                }

                                Text {
                                    Layout.leftMargin: 15

                                    text: modelData.name
                                    color: root.text
                                    font.family: "monospace"
                                    font.pixelSize: 12
                                }

                                Text {
                                    text: ' - ' + modelData.icon
                                    color: root.accent
                                    font.family: "monospace"
                                    font.pixelSize: 15
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    id: pinButton

                                    text: isPinned(modelData) ? "★" : "☆"
                                    color: isPinned(modelData) ? root.accent : root.muted

                                    opacity: appMouse.containsMouse || pinMouse.containsMouse ? 1.0 : 0.0

                                    font.family: "monospace"
                                    font.pixelSize: 17

                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24

                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter

                                    MouseArea {
                                        id: pinMouse

                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        anchors.right: parent.right
                                        width: 44

                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            console.log('Pin button clicked for app: ' + modelData.name);
                                            togglePin(modelData);
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: appMouse

                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.rightMargin: 44

                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    modelData.execute();
                                    root.visible = false;
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.border
            }

            // Bottom controls
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        {
                            label: "[ LOCK ]",
                            command: "loginctl lock-session"
                        },
                        {
                            label: "[ LOGOUT ]",
                            command: "hyprctl dispatch exit"
                        },
                        {
                            label: "[ RESTART ]",
                            command: "systemctl reboot"
                        },
                        {
                            label: "[ POWER ]",
                            command: "systemctl poweroff"
                        }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        height: 34

                        color: powerMouse.containsMouse ? "#1c1c1c" : root.bg2

                        border.color: powerMouse.containsMouse ? root.accent : root.border

                        border.width: 1

                        Text {
                            anchors.centerIn: parent

                            text: modelData.label
                            color: powerMouse.containsMouse ? root.accent : root.muted

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.bold: true
                        }

                        MouseArea {
                            id: powerMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: root.launch(modelData.command)
                        }
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignRight

                text: "QUICKSHELL // READY"
                color: root.muted
                font.family: "monospace"
                font.pixelSize: 8
            }
        }
    }

    // ------------------------------------------------------------
    // APPLICATION DATA
    // ------------------------------------------------------------

    property var pinnedNames: []

    FileView {
        id: pinFile

        path: Quickshell.env("HOME") + "/.config/quickshell/startmenu-pins.json"

        onLoaded: {
            try {
                console.log('Loading pin file...');
                var saved = JSON.parse(text());

                console.log('saved: ' + saved);

                if (Array.isArray(saved))
                    root.pinnedNames = saved;
            } catch (e) {
                console.log("StartMenu: Failed to parse pin file:", e);
            }
        }
    }

    property var pinnedApps: {
        return applications.filter(function (app) {
            return pinnedNames.indexOf(app.name) !== -1;
        });
    }

    property var applications: DesktopEntries.applications.values

    property var filteredApps: {
        var q = search.text.toLowerCase().trim();

        var sortedApps = applications.slice().sort(function (a, b) {
            return a.name.localeCompare(b.name);
        });

        if (q === "")
            return sortedApps;

        return sortedApps.filter(function (app) {
            return (app.name || "").toLowerCase().indexOf(q) !== -1 || (app.genericName || "").toLowerCase().indexOf(q) !== -1 || (app.categories || []).join(" ").toLowerCase().indexOf(q) !== -1;
        });
    }
}
