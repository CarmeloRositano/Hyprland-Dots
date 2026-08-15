import Quickshell
import Quickshell.Io

Scope {
    Bar {
    }

    Notifications {
    }

    Launcher {
        id: launcher
    }

    IpcHandler {
        function toggle() {
            launcher.visible = !launcher.visible;
        }

        function open() {
            launcher.visible = true;
        }

        function close() {
            launcher.visible = false;
        }

        target: "launcher"
    }

}
