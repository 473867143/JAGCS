import QtQuick 2.6
import "qrc:/JS/helper.js" as Helper

import "../Shaders" as Shaders

Item {
    id: pitchScale

    property real roll: 0.0
    property real minPitch: -25.0
    property real maxPitch: 25.0
    property real pitchStep: 10
    property color color: customPalette.textColor
    property real fontPixelSize: Math.max(height * 0.1, 9)

    onMinPitchChanged: canvas.requestPaint()
    onMaxPitchChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Shaders.OpacityBorder {
        anchors.fill: parent
        sourceItem: canvas
        rotation: -roll
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = canvas.getContext('2d');

            ctx.clearRect(0, 0, width, height);

            ctx.strokeStyle = color;
            ctx.fillStyle = color;
            ctx.font = 'bold ' + fontPixelSize + 'px "Open Sans"';
            ctx.textBaseline = 'middle';

            ctx.save();

            for (var pitch = minPitch - (minPitch % (pitchStep * 2)); pitch <= maxPitch;
                 pitch += pitchStep) {
                if (pitch == 0) continue;

                var major = (pitch % (pitchStep * 2)) == 0;
                var yPos = height - Helper.mapToRange(pitch, minPitch, maxPitch, height);

                ctx.lineWidth = major ? 2 : 1;
                ctx.beginPath();
                ctx.save();
                ctx.translate(width / 2, yPos);

                var tickLength = major ? Math.min(width / 14 + Math.abs(pitch) * 2, width / 4) :
                                         width / 16
                ctx.moveTo(-tickLength, 0);
                ctx.lineTo(+tickLength, 0);
                ctx.stroke();

                if (major) {
                    ctx.textAlign = 'left';
                    ctx.fillText(pitch, tickLength + 2, 2);
                    ctx.textAlign = 'right';
                    ctx.fillText(pitch, -tickLength - 2, 2);
                }

                ctx.restore();
            }
            ctx.restore();
        }
    }
}
