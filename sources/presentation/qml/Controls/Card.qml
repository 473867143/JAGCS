import QtQuick 2.6

import "./"

Item {
    id: control

    signal deepIn()

    property alias backgroundColor: background.color

    property Item contentItem: Item {}

    implicitWidth: contentItem.implicitWidth + sizings.margins * 2
    implicitHeight: contentItem.implicitHeight + sizings.margins * 2

    Rectangle {
        id: background
        anchors.fill: control
        color: customPalette.backgroundColor
        radius: 2
        z: -1

        Shadow {
            source: parent
        }
    }

//    Button {
//        anchors.top: parent.top
//        anchors.right: parent.right
//        iconSource: "qrc:/ui/dots.svg"
//        flat: true
//        onClicked: more()
//    }

    ColoredIcon {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        source: "qrc:/ui/menu_arrow.svg"
        color: area.pressed ? customPalette.highlightColor : customPalette.buttonColor
        width: sizings.controlBaseSize * 0.75
        height: width

        MouseArea {
            id: area
            anchors.fill: parent
            onClicked: deepIn()
        }
    }
}
