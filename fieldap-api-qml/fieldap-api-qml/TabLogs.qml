import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4

Item {
    ColumnLayout {
        anchors.fill: parent
        //spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.4
            color: root.backgroundColor

            RowLayout {
                anchors.fill: parent

                Text {
                    Layout.leftMargin: 10
                    horizontalAlignment: Text.AlignRight
                    text: "Total actions:"
                    font.pixelSize: root.fontSize * 1.2
                }
                Text {
                    id: actionsCount
                    Layout.rightMargin: 10
                    text: "0"
                    font.pixelSize: root.fontSize * 1.2
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                    border.width: 1

                    ListView {
                        id: actions
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true

                        ListModel {
                            id: actionsModel;
                            onCountChanged: {
                                actionsCount.text = count
                            }
                        }

                        model: actionsModel
                        delegate: ItemDelegate {
                            width: parent.width
                            text: model.timeStamp + " | " + model.action
                            font.pixelSize: root.fontSize
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.Wrap
                            }
                            highlighted: ListView.isCurrentItem
                            onClicked: { actions.currentIndex = model.index; }
                        }

                        onCurrentItemChanged: {
                            var ipAddress = actionsModel.get(actions.currentIndex).ipAddress;
                            var ipstackURL =
                                    root.ipstackEndpoint
                                    + ipAddress
                                    + "?access_key="
                                    + root.ipstackApiToken
                                    + "&fields=country_name,city,location";
                            request(ipstackURL, false, "GET", function (o)
                            {
                                if (o.status === 200)
                                {
                                    var geo = JSON.parse(o.responseText);
                                    txt_ipAddress.text = ipAddress + " ("
                                            + geo["location"]["country_flag_emoji"] + " "
                                            + geo["country_name"] + ", "
                                            + geo["city"]
                                            + ")"
                                }
                                else
                                {
                                    //dialogError.textMain = "Some error has occurred\n" + o.responseText;
                                    //dialogError.show();
                                    txt_ipAddress.text = ipAddress;
                                }
                            });

                            txt_category.text = actionsModel.get(actions.currentIndex).category;
                            txt_userId.text = actionsModel.get(actions.currentIndex).userId;
                            txt_userMail.text = actionsModel.get(actions.currentIndex).userMail;
                        }
                    }
                }

                Button {
                    id: btn_getProjects
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    text: "get"
                    font.pixelSize: root.fontSize
                    onClicked: {
                        btn_getProjects.enabled = false;
                        progressBar.visible = true;

                        actionsModel.clear();

                        request(root.fieldAPendpoint + "/v1.2/logs", true, "GET", function (o)
                        {
                            btn_getProjects.enabled = true;
                            progressBar.visible = false;

                            if (o.status === 200)
                            {
                                var acts = JSON.parse(o.responseText);
                                for (var a in acts)
                                {
                                    // add data to model
                                    actionsModel.append(
                                                {
                                                    "action": acts[a]["action"],
                                                    "timeStamp": new Date(acts[a].timeStamp),
                                                    "category": acts[a]["category"],
                                                    "ipAddress": acts[a]["ipAddress"],
                                                    "userId": acts[a]["userId"],
                                                    "userMail": acts[a]["userMail"]
                                                });
                                }
                            }
                            else
                            {
                                dialogError.textMain = "Some error has occurred\n" + o.responseText;
                                dialogError.show();
                            }
                        });
                    }
                }
            }

            Rectangle {
                id: progressBar
                anchors.fill: parent
                color: root.backgroundColor
                border.width: 1
                ProgressBar {
                    anchors.fill: parent
                    anchors.margins: 1
                    indeterminate: true
                }
                visible: false
            }
        }

        GridLayout {
            Layout.topMargin: 30
            Layout.leftMargin: 50
            Layout.rightMargin: Layout.leftMargin
            rows: 3
            columns: 2
            rowSpacing: 20

            Text {
                Layout.alignment: Qt.AlignRight
                text: "Category:"
                font.pixelSize: root.fontSize
                font.bold: true
            }
            TextValue {
                id: txt_category
                text: "-"
            }

            Text {
                Layout.alignment: Qt.AlignRight
                text: "IP address:"
                font.pixelSize: root.fontSize
                font.bold: true
            }
            TextValue {
                id: txt_ipAddress
                text: "-"
            }

            Text {
                Layout.alignment: Qt.AlignRight
                text: "User ID:"
                font.pixelSize: root.fontSize
                font.bold: true
            }
            TextValue {
                id: txt_userId
                text: "-"
            }

            Text {
                Layout.alignment: Qt.AlignRight
                text: "User e-mail:"
                font.pixelSize: root.fontSize
                font.bold: true
            }
            TextValue {
                id: txt_userMail
                text: "-"
                onTextChanged: {
                    if (text.length !== 0) { this.color = "blue"; }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
