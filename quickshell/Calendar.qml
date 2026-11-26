import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PopupWindow {
    id: root

    // Set this when creating Calendar in the bar:
    // Calendar { parentPanel: barWindow }
    property var parentPanel

    anchor.window: parentPanel
    anchor.rect.x: parentPanel ? (parentPanel.width - width) / 2 : 0
    anchor.rect.y: parentPanel ? parentPanel.height + 5 : 0

    implicitWidth: 420
    implicitHeight: 520
    visible: false
    color: "transparent"

    property date selectedDate: new Date()
    property date displayedMonth: new Date()

    function toggle() {
        visible = !visible;
    }

    function changeMonth(amount) {
        displayedMonth = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth() + amount, 1);
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }

    function isToday(day) {
        return sameDay(day, new Date());
    }

    function isSelected(day) {
        return sameDay(day, selectedDate);
    }

    function monthDay(index) {
        const firstDay = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth(), 1);

        const offset = firstDay.getDay();
        return new Date(displayedMonth.getFullYear(), displayedMonth.getMonth(), index - offset + 1);
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut

        onActivated: {
            root.visible = false;
        }
    }

    Timer {
        id: grabDelay
        interval: 80
        onTriggered: outsideGrab.active = true
    }

    HyprlandFocusGrab {
        id: outsideGrab
        windows: [root]

        onCleared: root.visible = false
    }

    onVisibleChanged: {
        if (visible) {
            grabDelay.restart();
        } else {
            grabDelay.stop();
            outsideGrab.active = false;
        }
    }

    Rectangle {
        anchors.fill: parent

        color: Colors.bg
        border.color: Colors.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "CALENDAR // DATE"
                    color: Colors.accent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "×"
                    color: Colors.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.visible = false
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.border
            }

            // Month navigation
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28

                    color: prevMouse.containsMouse ? "#1c1c1c" : "transparent"
                    border.color: prevMouse.containsMouse ? Colors.accent : Colors.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        color: prevMouse.containsMouse ? Colors.accent : Colors.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.changeMonth(-1)
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: Qt.formatDate(root.displayedMonth, "MMMM yyyy").toUpperCase()
                    color: Colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28

                    color: nextMouse.containsMouse ? "#1c1c1c" : "transparent"
                    border.color: nextMouse.containsMouse ? Colors.accent : Colors.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        color: nextMouse.containsMouse ? Colors.accent : Colors.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.changeMonth(1)
                    }
                }
            }

            // Weekday headings
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 2

                Repeater {
                    model: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

                    Text {
                        required property string modelData
                        Layout.fillWidth: true
                        text: modelData
                        color: Colors.muted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Calendar dates
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                rowSpacing: 2
                columnSpacing: 2

                Repeater {
                    model: 42

                    delegate: Rectangle {
                        required property int index

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        readonly property date day: root.monthDay(index)
                        readonly property bool inMonth: day.getMonth() === root.displayedMonth.getMonth()
                        readonly property bool selected: root.isSelected(day)
                        readonly property bool today: root.isToday(day)
                        readonly property bool hovered: dayMouse.containsMouse

                        color: selected || hovered ? "#1c1c1c" : today ? "#191919" : "transparent"
                        border.width: 1
                        border.color: selected || hovered ? Colors.accent : today ? Colors.border : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: parent.day.getDate()
                            color: parent.selected ? Colors.accent : parent.inMonth ? Colors.text : Colors.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            font.bold: parent.selected || parent.today
                        }

                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.selectedDate = parent.day;
                                if (!parent.inMonth) {
                                    root.displayedMonth = new Date(parent.day.getFullYear(), parent.day.getMonth(), 1);
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.border
            }

            // Footer
            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "SELECTED // " + Qt.formatDate(root.selectedDate, "d MMM yyyy").toUpperCase()
                    color: Colors.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                }

                Text {
                    text: "[ ESC ] CLOSE"
                    color: Colors.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                }

                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 26

                    color: todayMouse.containsMouse ? "#1c1c1c" : "transparent"
                    border.color: todayMouse.containsMouse ? Colors.accent : Colors.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "TODAY"
                        color: todayMouse.containsMouse ? Colors.accent : Colors.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        id: todayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.selectedDate = new Date();
                            root.displayedMonth = new Date();
                        }
                    }
                }
            }
        }
    }
}
