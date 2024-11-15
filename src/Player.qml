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

        // Quadrato centrato con dimensioni percentuali
        Rectangle {
            width: parent.width * 0.2  // 20% della larghezza del rettangolo principale
            height: parent.height * 0.2  // 20% dell'altezza del rettangolo principale
            color: "transparent"
            border.color: "gray"
            anchors.centerIn: parent  // Centra il quadrato all'interno del rettangolo principale
        }

        // Rettangolo rosso, 3,5% più piccolo del contenitore principale
        Rectangle {
            width: parent.width * 0.965  // 96,5% della larghezza del rettangolo principale
            height: parent.height * 0.965  // 96,5% dell'altezza del rettangolo principale
            color: "transparent"
            border.color: "red"
            anchors.centerIn: parent  // Centra il rettangolo all'interno del rettangolo principale
        }

        // Rettangolo verde, 5% più piccolo del contenitore principale
        Rectangle {
            width: parent.width * 0.95  // 95% della larghezza del rettangolo principale
            height: parent.height * 0.95  // 95% dell'altezza del rettangolo principale
            color: "transparent"
            border.color: "green"
            anchors.centerIn: parent  // Centra il rettangolo all'interno del rettangolo principale
        }

        // Diagonali tratteggiate
        Canvas {
            id: diagonalsCanvas
            anchors.fill: parent  // Riempi tutto il rettangolo
            antialiasing: true

            onPaint: {
                var ctx = diagonalsCanvas.getContext("2d")
                ctx.clearRect(0, 0, diagonalsCanvas.width, diagonalsCanvas.height)
                ctx.strokeStyle = "gray"
                ctx.setLineDash([5, 5])  // Pattern tratteggiato: 5 pixel disegno, 5 pixel spazio
                ctx.lineWidth = 1

                // Prima diagonale dall'angolo in alto a sinistra all'angolo in basso a destra
                ctx.beginPath()
                ctx.moveTo(0, 0)
                ctx.lineTo(diagonalsCanvas.width, diagonalsCanvas.height)
                ctx.stroke()

                // Seconda diagonale dall'angolo in alto a destra all'angolo in basso a sinistra
                ctx.beginPath()
                ctx.moveTo(diagonalsCanvas.width, 0)
                ctx.lineTo(0, diagonalsCanvas.height)
                ctx.stroke()
            }
        }
    }

    function play() { qmlAvPlayer.play(); }
    function stop() { qmlAvPlayer.stop(); }
}
