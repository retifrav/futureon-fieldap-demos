import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import Qt.labs.folderlistmodel 2.11
//import io.qt.Backend 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 1100
    minimumWidth: 700
    height: 700
    minimumHeight: 500
    title: qsTr("FutureOn FieldAP API example")
    color: root.backgroundColor

    property int fontSize: 16
    property string backgroundColor: "#ECECEC"

    property string fieldAPendpoint: "https://app.backend.fieldap.com/API"
    property string fieldAPapiToken: "YOUR-TOKEN"

    property string ipstackEndpoint: "http://api.ipstack.com/"
    property string ipstackApiToken: "YOUR-TOKEN"


    header: TabBar {
        id: tabBar
        currentIndex: stck.currentIndex
        font.pixelSize: 20

        TabButton { id: tabProjects; text: qsTr("Projects") }
        TabButton { id: tabPhotos; text: qsTr("Logs") }
    }

    StackLayout {
        id: stck
        anchors.fill: parent
        anchors.topMargin: 30
        currentIndex: tabBar.currentIndex

        TabProjects {}
        TabLogs {}
    }

    MessageBox {
        id: dialogError
        title: "Some error"
        textMain: "Some error"
    }

    // HTTP-request to the URL
    function request(url, toFieldAP, method, callback)
    {
        var xhr = new XMLHttpRequest();

        xhr.onreadystatechange = (function(myxhr)
        {
            return function() { if(myxhr.readyState === 4) { callback(myxhr); } }
        })(xhr);

        xhr.open(method, url);
        if (toFieldAP === true) { xhr.setRequestHeader("token", root.fieldAPapiToken); }
        xhr.send();
    }

    function formatDate(dt)
    {
        return dt.replace("T", " ").replace("Z", "");
    }
}
