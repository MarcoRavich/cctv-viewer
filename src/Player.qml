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

        // Viewfinder (70% of the main area, trasparent, centered)
        Rectangle {
            id: viewfinder
            width: parent.width * 0.70
            height: parent.height * 0.70
            color: "transparent"
			border.width: 0
            anchors.centerIn: parent
        }
		
		// Center
		Canvas {
			id: centralCrossCanvas
			anchors.fill: parent

			onPaint: {
			var ctx = centralCrossCanvas.getContext("2d");
			ctx.clearRect(0, 0, centralCrossCanvas.width, centralCrossCanvas.height);

			// Set color and type of center cross
			ctx.strokeStyle = "white";
			ctx.setLineDash([3, 3])
			ctx.lineWidth = 1;

			// Center
			var centerX = centralCrossCanvas.width / 2;
			var centerY = centralCrossCanvas.height / 2;

			// Cross arm size
			var armLength = centralCrossCanvas.height * 0.05;

			// Draw "+"
			ctx.beginPath();

			// Vertical
			ctx.moveTo(centerX, centerY - armLength);
			ctx.lineTo(centerX, centerY + armLength);

			// Horizontal
			ctx.moveTo(centerX - armLength, centerY);
			ctx.lineTo(centerX + armLength, centerY);

			// Print
			ctx.stroke();
			}
		}
     
        // Perpendicular lines
		Canvas {
			id: perpendicularCanvas
			anchors.fill: parent
			antialiasing: true

			onPaint: {
				var ctx = perpendicularCanvas.getContext("2d");
				ctx.clearRect(0, 0, perpendicularCanvas.width, perpendicularCanvas.height);
				ctx.strokeStyle = "white";
				ctx.setLineDash([]);
				ctx.lineWidth = 1;

				// Coordinates of viewfinder (center rectangle)
				var vfLeft = (perpendicularCanvas.width - viewfinder.width) / 2;
				var vfTop = (perpendicularCanvas.height - viewfinder.height) / 2;
				var vfRight = vfLeft + viewfinder.width;
				var vfBottom = vfTop + viewfinder.height;
				var vfCenterX = vfLeft + viewfinder.width / 2;
				var vfCenterY = vfTop + viewfinder.height / 2;

				// Draw vertical line (centered horizontally)
				ctx.beginPath();
				ctx.moveTo(vfCenterX, 0); // From top to above the viewfinder
				ctx.lineTo(vfCenterX, vfTop);
				ctx.moveTo(vfCenterX, vfBottom); // From below the viewfinder to bottom
				ctx.lineTo(vfCenterX, perpendicularCanvas.height);
				ctx.stroke();

				// Draw horizontal line (centered vertically)
				ctx.beginPath();
				ctx.moveTo(0, vfCenterY); // From left to left of the viewfinder
				ctx.lineTo(vfLeft, vfCenterY);
				ctx.moveTo(vfRight, vfCenterY); // From right of the viewfinder to right
				ctx.lineTo(perpendicularCanvas.width, vfCenterY);
				ctx.stroke();
			}
		}
    
		// EBU recommended Action-safe area (96.5% of the main area, red transparent)
		Canvas {
			id: actionSafeOverlay
			anchors.fill: parent

			onPaint: {
				var ctx = actionSafeOverlay.getContext("2d");
				ctx.clearRect(0, 0, actionSafeOverlay.width, actionSafeOverlay.height);

				// Colore rosso trasparente
				ctx.fillStyle = "rgba(255, 0, 0, 0.3)";
        
				// Disegna l'area principale
				ctx.fillRect(0, 0, actionSafeOverlay.width, actionSafeOverlay.height);

				// Calcola il rettangolo centrale per l'Action-safe area
				var actionSafeWidth = parent.width * 0.95;
				var actionSafeHeight = parent.height * 0.95;
				var actionSafeLeft = (actionSafeOverlay.width - actionSafeWidth) / 2;
				var actionSafeTop = (actionSafeOverlay.height - actionSafeHeight) / 2;

				// Ritaglia l'Action-safe area dal rosso trasparente
				ctx.clearRect(actionSafeLeft, actionSafeTop, actionSafeWidth, actionSafeHeight);
			}
		}
	
	}

    function play() { qmlAvPlayer.play(); }
    function stop() { qmlAvPlayer.stop(); }
}
