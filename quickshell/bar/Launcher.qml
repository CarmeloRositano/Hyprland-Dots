import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

Window {
    id: launcher

    property string query: ""

    function launchSelected() {
        if (list.currentItem && list.currentItem.modelData) {
            list.currentItem.modelData.execute();
            launcher.visible = false;
        }
    }

    title: "qs-launcher"
    visible: false
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    width: 600
    height: 500
    onVisibleChanged: {
        if (visible) {
            input.text = "";
            input.forceActiveFocus();
            list.currentIndex = filtered.values.length > 0 ? 0 : -1;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        border.width: 2
        border.color: "#b026ff"
        radius: 12

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            // =====================================================
            // SEARCH
            // =====================================================
            TextField {
                id: input

                Layout.fillWidth: true
                Layout.preferredHeight: 42
                placeholderText: "Search"
                placeholderTextColor: "#888888"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                color: "#ffffff"
                padding: 10
                focus: true
                onTextChanged: {
                    launcher.query = text;
                    list.currentIndex = filtered.values.length > 0 ? 0 : -1;
                }
                Keys.onEscapePressed: {
                    launcher.visible = false;
                }
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Down) {
                        event.accepted = true;
                        if (list.currentIndex < list.count - 1)
                            list.currentIndex++;

                    }
                    if (event.key === Qt.Key_Up) {
                        event.accepted = true;
                        if (list.currentIndex > 0)
                            list.currentIndex--;

                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        event.accepted = true;
                        launcher.launchSelected();
                    }
                }

                background: Rectangle {
                    color: "#000000"
                    radius: 8
                }

            }

            // =====================================================
            // APPLICATION FILTER
            // =====================================================
            ScriptModel {
                id: filtered

                values: {
                    const allEntries = Array.from(DesktopEntries.applications.values).sort(function(a, b) {
                        return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
                    });
                    const q = launcher.query.trim().toLowerCase();
                    if (q === "")
                        return allEntries;

                    return allEntries.filter(function(d) {
                        return d.name && d.name.toLowerCase().includes(q);
                    });
                }
            }

            // =====================================================
            // APPLICATION LIST
            // =====================================================
            ListView {
                id: list

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: filtered.values
                currentIndex: filtered.values.length > 0 ? 0 : -1
                keyNavigationWraps: true
                highlightRangeMode: ListView.ApplyRange
                highlightMoveDuration: 80
                Keys.onReturnPressed: {
                    launcher.launchSelected();
                }

                highlight: Rectangle {
                    radius: 8
                    color: "#2a003d"
                }

                delegate: Item {
                    id: entry

                    required property var modelData
                    required property int index

                    width: ListView.view.width
                    height: 50

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            list.currentIndex = entry.index;
                        }
                        onDoubleClicked: {
                            launcher.launchSelected();
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        IconImage {
                            source: Quickshell.iconPath(modelData.icon, true)
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: "#ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                    }

                }

            }

        }

    }

}
