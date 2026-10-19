import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property string filter: ""
    property string status: "Loading applications..."
    property var allApps: []

    ListModel {
        id: appsModel
    }

    property alias listModel: appsModel

    function applyFilter() {
        appsModel.clear();

        var searchText = filter.trim().toLowerCase();

        for (var i = 0; i < allApps.length; i++) {
            var app = allApps[i];

            if (searchText === "" || app.name.toLowerCase().indexOf(searchText) !== -1) {
                appsModel.append(app);
            }
        }

        status = appsModel.count + " applications shown";
    }

    onFilterChanged: applyFilter()

    Process {
        id: loadProcess

        command: ["python", "-c", "import configparser, glob, os\n" + "files = sorted(set(glob.glob('/usr/share/applications/*.desktop') + glob.glob(os.path.expanduser('~/.local/share/applications/*.desktop')) + glob.glob('/var/lib/flatpak/exports/share/applications/*.desktop') + glob.glob(os.path.expanduser('~/.local/share/flatpak/exports/share/applications/*.desktop'))))\n" + "apps = {}\n" + "for f in files:\n" + " c = configparser.ConfigParser(interpolation=None, strict=False)\n" + " c.optionxform = str\n" + " try: c.read(f, encoding='utf-8')\n" + " except Exception: continue\n" + " if not c.has_section('Desktop Entry'): continue\n" + " d = c['Desktop Entry']\n" + " if d.get('Type', 'Application') != 'Application' or d.get('NoDisplay', 'false').lower() == 'true' or d.get('Hidden', 'false').lower() == 'true': continue\n" + " name = d.get('Name', '').strip()\n" + " if not name or not d.get('Exec', '').strip(): continue\n" + " icon = d.get('Icon', '').strip()\n" + " apps[name.lower()] = (name, os.path.basename(f), icon)\n" + "for name, desktop_id, icon in sorted(apps.values(), key=lambda a: a[0].lower()):\n" + " print(name.replace('\\t',' ') + '\\t' + desktop_id + '\\t' + icon)\n"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim();
                var apps = [];

                if (output.length > 0) {
                    var lines = output.split("\n");

                    for (var i = 0; i < lines.length; i++) {
                        var parts = lines[i].split("\t");

                        if (parts.length < 2 || !parts[0].trim())
                            continue;
                        apps.push({
                            name: parts[0].trim(),
                            desktopId: parts[1].trim(),
                            icon: parts.length > 2 ? parts.slice(2).join("\t").trim() : ""
                        });
                    }
                }

                root.allApps = apps;
                root.applyFilter();
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    console.warn("AppModel:", text);
            }
        }
    }
}
