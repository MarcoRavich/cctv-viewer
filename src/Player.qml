import QtQml 2.12
import QtQuick 2.12
import QtMultimedia 5.12
import CCTV_Viewer.Multimedia 1.0

FocusScope {
    id: root

    property string color: "black"
    property var avOptions: ({})

    property alias loops: qmlAvPlayer.loops
    property alias source: qmlAvPlayer.source
    property alias muted: qmlAvPlayer.muted
    property alias volume: qmlAvPlayer.volume
    readonly property alias hasAudio: qmlAvPlayer.hasAudio

    onVisibleChanged: {
        if (visible) {
            if (!timer.running) {
                timer.start();
            }
        } else {
            timer.stop();
            qmlAvPlayer.autoPlay = false;
            qmlAvPlayer.stop();
        }
    }
    Component.onCompleted: {
        if (visible) {
            timer.start();
        }
    }

    Timer {
        id: timer
        interval: 50
        onTriggered: {
            if (root.visible) {
                qmlAvPlayer.autoPlay = true;
            }
        }
    }

    Rectangle {
        color: root.color
        border.color: "#101010"
        anchors.fill: parent
        clip: true

        VideoOutput {
            id: videoOutput
            source: qmlAvPlayer
            anchors.fill: parent
        }

        Text {
            id: message
            color: "white"
            visible: qmlAvPlayer.status !== MediaPlayer.Buffered
            anchors.centerIn: parent
        }

        QmlAVPlayer {
            id: qmlAvPlayer
            autoLoad: false

            avOptions: {
                var avOptions = root.avOptions;
                Object.assignDefault(avOptions, layoutsCollectionSettings.toJSValue("defaultAVFormatOptions"));
                return avOptions;
            }

            onStatusChanged: {
                switch (status) {
                case MediaPlayer.NoMedia:
                    message.text = qsTr("No media");
                    break;
                case MediaPlayer.Loading:
                    message.text = qsTr("Loading...");
                    break;
                case MediaPlayer.Loaded:
                    message.text = qsTr("Loaded");
                    break;
                case MediaPlayer.Stalled:
                    message.text = qsTr("Stalled");
                    break;
                case MediaPlayer.EndOfMedia:
                    message.text = qsTr("End of media");
                    break;
                case MediaPlayer.InvalidMedia:
                    message.text = qsTr("Error!");
                    break;
                }
            }

            onBufferProgressChanged: {
                message.text = qsTr("Buffering %1\%").arg(Math.round(bufferProgress * 100));
            }
        }

        // Viewfinder (20% of the main area, gray, centered)
        Rectangle {
            id: viewfinder
            width: parent.width * 0.2
            height: parent.height * 0.2
            color: "transparent"
            border.color: "gray"
            anchors.centerIn: parent
        }

        // EBU recommended Action-safe area (96,5% of the main area, red, centered)
        Rectangle {
            width: parent.width * 0.965
            height: parent.height * 0.965
            color: "transparent"
            border.color: "red"
            anchors.centerIn: parent
        }

        // EBU recommended Graphics-safe area (95% of the main area, green, centered)
        Rectangle {
            width: parent.width * 0.95
            height: parent.height * 0.95
            color: "transparent"
            border.color: "green"
            anchors.centerIn: parent
        }
        
        // Dotted diagonals (grey)
        Canvas {
            id: diagonalsCanvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                var ctx = diagonalsCanvas.getContext("2d")
                ctx.clearRect(0, 0, diagonalsCanvas.width, diagonalsCanvas.height)
                ctx.strokeStyle = "gray"
                ctx.setLineDash([5, 5])
                ctx.lineWidth = 1

                // Coordinates of viewfinder (center rectangle)
                var vfLeft = (diagonalsCanvas.width - viewfinder.width) / 2
                var vfTop = (diagonalsCanvas.height - viewfinder.height) / 2
                var vfRight = vfLeft + viewfinder.width
                var vfBottom = vfTop + viewfinder.height

                // Top left to viewfinder top left
                ctx.beginPath()
                ctx.moveTo(0, 0)
                ctx.lineTo(vfLeft, vfTop)
                ctx.stroke()

                // Top right to viewfinder top right
                ctx.beginPath()
                ctx.moveTo(diagonalsCanvas.width, 0)
                ctx.lineTo(vfRight, vfTop)
                ctx.stroke()

                // Bottom left to viewfinder bottom left
                ctx.beginPath()
                ctx.moveTo(0, diagonalsCanvas.height)
                ctx.lineTo(vfLeft, vfBottom)
                ctx.stroke()

                // Bottom right to viewfinder bottom right
                ctx.beginPath()
                ctx.moveTo(diagonalsCanvas.width, diagonalsCanvas.height)
                ctx.lineTo(vfRight, vfBottom)
                ctx.stroke()
            }
        }
    }

    function play() { qmlAvPlayer.play(); }
    function stop() { qmlAvPlayer.stop(); }
}
