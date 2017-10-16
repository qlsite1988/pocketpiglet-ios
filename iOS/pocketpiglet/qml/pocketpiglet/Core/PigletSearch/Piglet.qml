import QtQuick 2.9

Rectangle {
    id:     piglet
    width:  pigletImage.sourceSize.width
    height: pigletImage.sourceSize.height
    color:  "transparent"

    property bool valid:    true

    property int waitTime:  0

    property real distance: 500.0
    property real azimuth:  0.0

    signal pigletFound()
    signal pigletMissed()

    function updatePosition(device_azimuth) {
        x = distance * Math.cos((device_azimuth - azimuth) * Math.PI / 180.0);
    }

    MouseArea {
        id:           pigletMouseArea
        anchors.fill: parent

        onClicked: {
            pigletMouseArea.enabled  = false;
            pigletImage.visible      = false;
            pigletFoundImage.visible = true;

            pigletFoundTimer.start();

            if (piglet.valid) {
                piglet.valid = false;

                piglet.pigletFound();
            }
        }

        Image {
            id:           pigletImage
            anchors.fill: parent
            source:       "qrc:/resources/images/piglet_search/piglet_1.png"
            fillMode:     Image.PreserveAspectFit
            smooth:       true
        }

        Image {
            id:           pigletFoundImage
            anchors.fill: parent
            source:       "qrc:/resources/images/piglet_search/piglet_found.png"
            fillMode:     Image.PreserveAspectFit
            smooth:       true
            visible:      false
        }
    }

    Timer {
        id:       pigletWaitTimer
        interval: piglet.waitTime

        onTriggered: {
            if (piglet.valid) {
                piglet.valid = false;

                piglet.pigletMissed();
            }

            piglet.destroy();
        }
    }

    Timer {
        id:       pigletFoundTimer
        interval: 100

        onTriggered: {
            piglet.destroy();
        }
    }

    Component.onCompleted: {
        var rand = Math.random();

        if (rand < 0.33) {
            pigletImage.source = "qrc:/resources/images/piglet_search/piglet_1.png";
        } else if (rand < 0.66) {
            pigletImage.source = "qrc:/resources/images/piglet_search/piglet_2.png";
        } else {
            pigletImage.source = "qrc:/resources/images/piglet_search/piglet_3.png";
        }

        pigletWaitTimer.start();
    }
}
