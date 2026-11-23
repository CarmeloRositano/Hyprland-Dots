import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PopupWindow {
    id: root

    // Set this when creating Calendar in the bar:
    // Calendar { parentPanel: barWindow }
    property var parentPanel

    anchor.window: parentPanel
    anchor.rect.x: parentPanel ? (parentPanel.width - width) / 2 : 0
    anchor.rect.y: parentPanel ? parentPanel.height + 5 : 0

    implicitWidth: 340
    implicitHeight: 390
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
        radius: 12
        color: Colors.bg
        border.color: Colors.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // Month navigation
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ToolButton {
                    text: "‹"
                    onClicked: root.changeMonth(-1)

                    contentItem: Text {
                        text: parent.text
                        color: Colors.text
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Colors.bg2 : "transparent"
                        radius: 6
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: Qt.formatDate(root.displayedMonth, "MMMM yyyy")
                    color: Colors.text
                    font.pixelSize: 17
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                ToolButton {
                    text: "›"
                    onClicked: root.changeMonth(1)

                    contentItem: Text {
                        text: parent.text
                        color: Colors.text
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Colors.bg2 : "transparent"
                        radius: 6
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
                    model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                    Text {
                        required property string modelData
                        Layout.fillWidth: true
                        text: modelData
                        color: Colors.muted
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Calendar dates
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                rowSpacing: 4
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

                        radius: 6
                        color: selected ? Colors.selected : today ? Colors.bg3 : dayMouse.containsMouse ? Colors.bg2 : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: parent.day.getDate()
                            color: parent.selected ? "#111111" : parent.inMonth ? Colors.text : Colors.muted
                            font.pixelSize: 13
                            font.bold: parent.selected || parent.today
                        }

                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            hoverEnabled: true

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

            // Footer
            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: Qt.formatDate(root.selectedDate, "dddd, d MMMM yyyy")
                    color: Colors.muted
                    font.pixelSize: 11
                }

                Button {
                    text: "Today"
                    onClicked: {
                        root.selectedDate = new Date();
                        root.displayedMonth = new Date();
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Colors.selected
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Colors.bg2 : "transparent"
                        radius: 5
                    }
                }
            }
        }
    }
}
