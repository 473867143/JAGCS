import QtQuick 2.6
import JAGCS 1.0

import "qrc:/Controls" as Controls
import "qrc:/Indicators" as Indicators

Controls.Pane {
    id: root

    property real scalingFactor: 2.7
    property int minSpeed: -dashboard.speedStep * scalingFactor
    property int maxSpeed: dashboard.speedStep * scalingFactor

    property int minAltitude: -dashboard.altitudeStep * scalingFactor
    property int maxAltitude: dashboard.altitudeStep * scalingFactor

    implicitHeight: width * 0.75

    Indicators.BarIndicator {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: speedLadder.right
        width: speedLadder.majorTickSize + 1
        height: parent.height * 0.6 // TODO: ladder dynamic width calculation
        value: vehicle.powerSystem.throttle
    }

    Indicators.LadderPicker {
        id: speedLadder
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        height: parent.height * 0.6
        value: units.convertSpeedTo(speedUnits, vehicle.pitot.present ?
                                      vehicle.pitot.indicatedAirspeed :
                                      vehicle.satellite.groundSpeed)
        errorVisible: vehicle.guided && vehicle.pitot.present
        error: units.convertSpeedTo(speedUnits, vehicle.flightControl.airspeedError)
        minValue: value + minSpeed
        maxValue: value + maxSpeed
        valueStep: speedStep
        enabled: vehicle.pitot.present ? vehicle.pitot.enabled : vehicle.satellite.enabled
        operational: vehicle.pitot.present ? vehicle.pitot.operational : vehicle.satellite.operational
        prefix: (vehicle.pitot.present ? qsTr("IAS") : qsTr("GS")) + ", " + speedSuffix
        inputEnabled: manual.enabled
        onAddValue: manual.addImpact(ManualController.Throttle, value)
    }

    Indicators.ValueLabel2 {
        anchors.top: parent.top
        anchors.horizontalCenter: speedLadder.horizontalCenter
        digits: 1
        value: units.convertSpeedTo(speedUnits, vehicle.satellite.groundspeed)
        enabled: vehicle.satellite.enabled
        operational: vehicle.satellite.operational
        width: speedLadder.width
        prefix: qsTr("GS") + ", " + speedSuffix
        visible: vehicle.pitot.present
    }

    Indicators.ValueLabel2 {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: speedLadder.horizontalCenter
        digits: 1
        value: units.convertSpeedTo(speedUnits, vehicle.pitot.trueAirspeed)
        enabled: vehicle.pitot.enabled
        operational: vehicle.pitot.operational
        width: speedLadder.width
        prefix: qsTr("TAS") + ", " + speedSuffix
        visible: vehicle.pitot.present
    }

    Indicators.AttitudeDirectorIndicator {
        id: fd
        anchors.left: speedLadder.right
        anchors.right: altitudeLadder.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        enabled: vehicle.online && vehicle.ahrs.enabled
        operational: vehicle.ahrs.operational
        armed: vehicle.armed
        pitch: vehicle.ahrs.pitch
        roll: vehicle.ahrs.roll
        yawspeed: vehicle.ahrs.yawspeed
        desiredVisible: vehicle.stab
        desiredPitch: vehicle.flightControl.desiredPitch
        desiredRoll: vehicle.flightControl.desiredRoll
        rollInverted: dashboard.rollInverted
        inputEnabled: manual.enabled
        onAddPitch: manual.addImpact(ManualController.Pitch, value)
        onAddRoll: manual.addImpact(ManualController.Roll, value)
    }

    Indicators.BarIndicator {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: altitudeLadder.left
        width: altitudeLadder.majorTickSize + 1
        height: parent.height * 0.6
        value: vehicle.barometric.climb
        fillColor: vehicle.barometric.climb > 0 ? customPalette.skyColor : customPalette.groundColor
        minValue: -10
        maxValue: 10
    }

    Indicators.Ladder {
        id: altitudeLadder
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        height: parent.height * 0.6
        value: units.convertDistanceTo(altitudeUnits, vehicle.barometric.displayedAltitude)
        errorVisible: vehicle.guided
        error: units.convertDistanceTo(altitudeUnits, vehicle.flightControl.altitudeError)
        minValue: value + minAltitude
        maxValue: value + maxAltitude
        warningValue: altitudeRelative ?
                          0 : units.convertDistanceTo(altitudeUnits, vehicle.homeAltitude)
        warningColor: customPalette.groundColor
        valueStep: dashboard.altitudeStep
        enabled: vehicle.barometric.enabled
        operational: vehicle.barometric.operational
        mirrored: true
        prefix: qsTr("ALT") + ", " + altitudeSuffix
    }

    Indicators.ValueLabel2 {
        anchors.top: parent.top
        anchors.horizontalCenter: altitudeLadder.horizontalCenter
        value: units.convertDistanceTo(altitudeUnits, vehicle.satellite.altitude)
        enabled: vehicle.satellite.enabled
        operational: vehicle.satellite.operational
        width: altitudeLadder.width
        prefix: qsTr("SAT") + ", " + altitudeSuffix
    }

    Indicators.ValueLabel2 {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: altitudeLadder.horizontalCenter
        value: units.convertDistanceTo(altitudeUnits, vehicle.radalt.altitude)
        digits: 2
        enabled: vehicle.radalt.enabled
        operational: vehicle.radalt.operational
        visible: vehicle.radalt.present
        width: altitudeLadder.width
        prefix: qsTr("RAD") + ", " + altitudeSuffix
    }
}
