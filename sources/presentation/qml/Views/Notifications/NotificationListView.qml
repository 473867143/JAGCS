import QtQuick 2.6
import QtQuick.Layouts 1.3
import JAGCS 1.0

import "qrc:/Controls" as Controls

Item {
    id: notificationsList

    function addLog(message) {
        messages.append({ "msg": message });
        list.positionViewAtEnd();
    }

    NotificationsPresenter {
        id: presenter
        view: notificationsList
    }

    ListView {
        id: list
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: Math.min(sizings.controlBaseSize * 11, notificationsList.width)
        height: Math.min(contentHeight, parent.height)
        spacing: sizings.spacing
        model: ListModel { id: messages }
        verticalLayoutDirection: ListView.BottomToTop
        flickableDirection: Flickable.AutoFlickIfNeeded
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Controls.ScrollBar.vertical: Controls.ScrollBar {
            visible: parent.contentHeight > parent.height
        }

        delegate: NotificationView {
            message: msg
            width: parent.width
            onDropped: messages.remove(index, 1)
        }
    }
}