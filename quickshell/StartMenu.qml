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

    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut

        onActivated: {
            root.visible = false;
        }
    }

    IpcHandler {
        target: "startmenu"
        function toggle() {
            root.toggle();
        }
        function close() {
            root.visible = false;
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: {
            root.visible = false;
        }
    }

    implicitWidth: 560
    implicitHeight: 640
    color: "transparent"

    property int selectedIndex: 0
    property string mathResult: ""

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

    function evalMath(expr) {
        // Whitelist: only digits, operators, parens, decimal, spaces
        if (!/^[0-9+\-*/^().%\s]+$/.test(expr))
            return null;
        if (!/[0-9]/.test(expr))
            return null;
        var jsExpr = expr.replace(/\^/g, "**");
        try {
            var result = Function("return " + jsExpr)();
            if (typeof result === "number" && isFinite(result))
                return String(result);
        } catch (e) {}
        return null;
    }

    // ── App Model ──
    AppModel {
        id: appModel
        filter: search.text
    }

    // ── Uptime ──
    Process {
        id: uptimeProcess
        command: ["uptime", "-p"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.uptime = text.trim();
            }
        }
    }

    // ── Layout ──
    Rectangle {
        anchors.fill: parent
        color: root.bg
        border.color: root.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Search
            TextField {
                id: search
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                placeholderText: "Search applications..."
                color: root.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                background: Rectangle {
                    color: root.bg2
                    border.color: search.activeFocus ? root.accent : root.border
                    border.width: 1
                }

                onTextChanged: {
                    root.selectedIndex = 0;
                    var result = root.evalMath(text);
                    if (result !== null) {
                        root.mathResult = result;
                    } else {
                        root.mathResult = "";
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.visible = false;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Down) {
                        root.selectedIndex = Math.min(root.selectedIndex + 1, appModel.listModel.count - 1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up) {
                        root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (root.mathResult !== "") {
                            Quickshell.execDetached(["wl-copy", root.mathResult]);
                            root.visible = false;
                        } else if (root.selectedIndex < appModel.listModel.count) {
                            var item = appModel.listModel.get(root.selectedIndex);
                            var id = item.desktopId.replace(/\.desktop$/, "");
                            Quickshell.execDetached(["gtk-launch", id]);
                            root.visible = false;
                        }

                        event.accepted = true;
                    }
                }

                onAccepted: {
                    if (root.mathResult !== "") {
                        Quickshell.execDetached(["wl-copy", root.mathResult]);
                        root.visible = false;
                        return;
                    }
                    if (root.selectedIndex < appModel.listModel.count) {
                        var item = appModel.listModel.get(root.selectedIndex);
                        var id = item.desktopId.replace(/\.desktop$/, "");
                        Quickshell.execDetached(["gtk-launch", id]);
                        root.visible = false;
                    }
                }
            }

            // Math result
            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: root.mathResult ? 28 : 0
                visible: root.mathResult !== ""
                text: "= " + root.mathResult
                color: root.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.bold: true
            }

            // App List
            ListView {
                id: appGrid

                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true
                spacing: 4
                boundsBehavior: Flickable.StopAtBounds

                model: appModel.listModel

                delegate: Rectangle {
                    width: appGrid.width
                    height: 48

                    property bool hovered: appMouse.containsMouse

                    color: (index === root.selectedIndex) || hovered ? "#1c1c1c" : "transparent"
                    border.color: (index === root.selectedIndex) || hovered ? root.accent : "transparent"
                    border.width: 1
                    radius: 3

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 12

                        Image {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32

                            source: icon.length > 0 ? (icon.startsWith("/") ? "file://" + icon : Quickshell.iconPath(icon, "application-x-executable")) : Quickshell.iconPath("application-x-executable")

                            fillMode: Image.PreserveAspectFit
                            sourceSize.width: 48
                            sourceSize.height: 48
                            asynchronous: true
                            smooth: true
                        }

                        Text {
                            Layout.fillWidth: true

                            text: name
                            color: hovered ? root.accent : root.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: appMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            var id = desktopId.replace(/\.desktop$/, "");
                            Quickshell.execDetached(["gtk-launch", id]);
                            root.visible = false;
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.border
            }

            // Power row
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        {
                            label: "Lock",
                            cmd: "hyprctl dispatch lock"
                        },
                        {
                            label: "Suspend",
                            cmd: "systemctl suspend"
                        },
                        {
                            label: "Reboot",
                            cmd: "systemctl reboot"
                        },
                        {
                            label: "Power",
                            cmd: "systemctl poweroff"
                        }
                    ]
                    delegate: Rectangle {
                        Layout.preferredWidth: (root.width / 4) - 12
                        Layout.preferredHeight: 28
                        color: powerMouse.containsMouse ? "#1c1c1c" : "transparent"
                        border.color: powerMouse.containsMouse ? root.accent : root.border
                        border.width: 1
                        radius: 2

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: root.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                        }

                        MouseArea {
                            id: powerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.launch(modelData.cmd)
                        }
                    }
                }
            }

            // Footer
            Text {
                Layout.alignment: Qt.AlignRight
                text: "QUICKSHELL // " + root.uptime
                color: root.muted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 8
            }
        }
    }
}
