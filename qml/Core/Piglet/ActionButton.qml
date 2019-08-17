import QtQuick 2.12

Image {
    id: actionButton

    signal clicked()

    MouseArea {
        id:           actionButtonMouseArea
        anchors.fill: parent

        onClicked: {
            actionButton.clicked();
        }
    }
}
