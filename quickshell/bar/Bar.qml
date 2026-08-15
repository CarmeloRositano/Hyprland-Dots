import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Scope {
    PanelWindow {
        id: panel

        // Dynamic height bindings (26px visible, 0px completely hidden)
        property int visibleHeight: 26
        property int hiddenHeight: 0
        property bool isHovered: false

        screen: Quickshell.screens[1] // Pin to your second monitor
        implicitHeight: isHovered ? visibleHeight : hiddenHeight
        color: "#000000"

        anchors {
            top: true
            left: true
            right: true
        }

        // Timer prevents accidental hiding if the cursor briefly slips away
        Timer {
            id: hideTimer

            interval: 250
            repeat: false
            onTriggered: panel.isHovered = false
        }

        // Invisible tracking hit-box target boundary (Moved above UI elements)
        MouseArea {
            id: hotEdge

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            // Evaluates to a 3px slip-zone when hidden, collapses out of the way when visible
            height: panel.isHovered ? 0 : 3
            z: 999 // Places it on top exclusively when the bar is closed
            hoverEnabled: true
            onEntered: {
                hideTimer.stop();
                panel.isHovered = true;
            }
        }

        // Component visibility container
        Item {
            id: contentContainer

            anchors.fill: parent
            opacity: panel.isHovered ? 1 : 0
            visible: panel.height > 0

            // Global escape hatch tracking to know when mouse leaves the expanded window bounds
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true // ALLOWS clicks to pass directly to modules
                onEntered: hideTimer.stop()
                onExited: hideTimer.start()
                // Block clicks from accidentally closing the bar manually
                onClicked: (mouse) => {
                    return mouse.accepted = false;
                }
                onPressed: (mouse) => {
                    return mouse.accepted = false;
                }
            }

            // =====================================================
            // LEFT
            // =====================================================
            Workspaces {
                id: workspaces

                monitor: Hyprland.monitorFor(Quickshell.screens[1])

                anchors {
                    left: parent.left
                    leftMargin: 8
                    verticalCenter: parent.verticalCenter
                }

            }

            Music {
                anchors {
                    left: workspaces.right
                    leftMargin: 50
                    verticalCenter: parent.verticalCenter
                }

            }

            // =====================================================
            // CENTER
            // =====================================================
            RowLayout {
                spacing: 6

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                Clock {
                    Layout.alignment: Qt.AlignVCenter
                }

                Updates {
                    Layout.alignment: Qt.AlignVCenter
                }

            }

            // =====================================================
            // RIGHT
            // =====================================================
            Row {
                spacing: 20

                anchors {
                    right: parent.right
                    rightMargin: 20
                    verticalCenter: parent.verticalCenter
                }

                // Wiremix
                BarButton {
                    text: "󰕾"
                    fontSize: 24
                    onClicked: Quickshell.execDetached(["kitty", "--class", "wiremix", "--override", "remember_window_size=no", "--override", "initial_window_width=900", "--override", "initial_window_height=600", "wiremix"])
                }

                // Network
                BarButton {
                    text: "󰤨"
                    fontSize: 24
                    onClicked: Quickshell.execDetached(["kitty", "--class", "impala", "--override", "remember_window_size=no", "--override", "initial_window_width=100c", "--override", "initial_window_height=30c", "-e", "impala"])
                }

                // Bluetooth
                BarButton {
                    text: "󰂯"
                    fontSize: 18
                    onClicked: Quickshell.execDetached(["kitty", "--class", "bluetui", "--override", "remember_window_size=no", "--override", "initial_window_width=100c", "--override", "initial_window_height=30c", "-e", "bluetui"])
                }

                // btop
                BarButton {
                    text: ""
                    fontSize: 20
                    onClicked: Quickshell.execDetached(["kitty", "--class", "btop", "--override", "remember_window_size=no", "--override", "initial_window_width=180c", "--override", "initial_window_height=50c", "-e", "btop"])
                }

                // Power
                BarButton {
                    text: ""
                    fontSize: 18
                    onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "bar", "call", "power", "toggle"])
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutQuad
                }

            }

        }

        // =====================================================
        // ULTRA-SMOOTH SPRING MOTION ENGINE
        // =====================================================
        Behavior on height {
            SpringAnimation {
                spring: 3.5
                damping: 0.85
                mass: 0.8
                epsilon: 0.25
            }

        }

    }

}
