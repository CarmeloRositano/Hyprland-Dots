import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Item {
    id: root

    property var player: Mpris.players.values.length > 0
        ? Mpris.players.values[0]
        : null

    implicitWidth: musicText.implicitWidth
    implicitHeight: 26

    Text {
        id: musicText

        anchors.verticalCenter: parent.verticalCenter

        color: "#ffffff"

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12

        text: {
            if (!root.player)
                return ""

            var title = root.player.trackTitle || ""
            var artist = root.player.trackArtist || ""

            if (title !== "" && artist !== "")
                return artist + " - " + title

            return title || artist
        }

        elide: Text.ElideRight
        maximumLineCount: 1
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            if (root.player && root.player.canTogglePlaying)
                root.player.togglePlaying()
        }
    }
}
