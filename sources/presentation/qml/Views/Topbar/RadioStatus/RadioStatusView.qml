import QtQuick 2.6
import QtQuick.Layouts 1.3
import JAGCS 1.0

import "qrc:/Controls" as Controls
import "qrc:/Indicators" as Indicators

GridLayout {
    id: radioStatus

    property alias rssi: rssiItem.rssi
    property alias remoteRssi: remoteRssiItem.rssi

    columns: 3
    rowSpacing: 0
    columnSpacing: sizings.spacing

    RadioStatusPresenter {
        id: presenter
        view: radioStatus
        Component.onCompleted: updateParameters()
    }

    Indicators.RssiIndicator {
        id: rssiItem
        Layout.rowSpan: 2
    }

    Indicators.RssiIndicator {
        id: remoteRssiItem
        Layout.rowSpan: 2
    }

    Controls.Label {
        text: qsTr("RSSI: ") + rssi.toFixed(1) + qsTr(" dBm")
        font.pixelSize: sizings.fontPixelSize * 0.5
        font.bold: true
    }

    Controls.Label {
        text: qsTr("Rem. RSSI: ") + remoteRssi.toFixed(1) + qsTr(" dBm")
        font.pixelSize: sizings.fontPixelSize * 0.5
        font.bold: true
    }
}
