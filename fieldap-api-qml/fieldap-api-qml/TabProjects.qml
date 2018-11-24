import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4

Item {
    ColumnLayout {
        anchors.fill: parent
        //spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.20
            color: root.backgroundColor

            RowLayout {
                anchors.fill: parent

                Text {
                    Layout.leftMargin: 10
                    horizontalAlignment: Text.AlignRight
                    text: "Total projects:"
                    font.pixelSize: root.fontSize * 1.2
                }
                Text {
                    id: projectCount
                    Layout.rightMargin: 10
                    text: "0"
                    font.pixelSize: root.fontSize * 1.2
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                    border.width: 1

                    ListView {
                        id: projects
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true

                        ListModel {
                            id: projectsModel;
                            onCountChanged: {
                                projectCount.text = count
                            }
                        }

                        model: projectsModel
                        delegate: ItemDelegate {
                            width: parent.width
                            text: model.name
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
                            onClicked: { projects.currentIndex = model.index; }
                        }

                        onCurrentItemChanged: {
                            txt_startDate.text = formatDate(projectsModel.get(projects.currentIndex).startDate);
                            txt_endDate.text = formatDate(projectsModel.get(projects.currentIndex).endDate);
                            txt_subProjects.text = projectsModel.get(projects.currentIndex).subProjects;
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

                        projectsModel.clear();

                        request(root.fieldAPendpoint + "/v1/", true, "GET", function (o)
                        {
                            btn_getProjects.enabled = true;
                            progressBar.visible = false;

                            if (o.status === 200)
                            {
                                var projs = JSON.parse(o.responseText)["projects"];
                                for (var p in projs)
                                {
                                    // count subprojects
                                    var subprojs = 0;
                                    for (var sp in projs[p]["subProjects"])
                                    {
                                        //console.log(sp);
                                        subprojs++;
                                    }

                                    // add data to model
                                    projectsModel.append(
                                                {
                                                    "name": projs[p]["name"],
                                                    "startDate": projs[p]["startDate"],
                                                    "endDate": projs[p]["endDate"],
                                                    "subProjects": subprojs
                                                });
                                }
                            }
                            else
                            {
                                //console.log();
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
                text: "Start date:"
                font.pixelSize: root.fontSize
                font.bold: true
            }
            TextValue {
                id: txt_startDate
                text: "-"
            }

            Text {
                Layout.alignment: Qt.AlignRight
                text: "End date:"
                font.pixelSize: root.fontSize
                font.bold: true
            }
            TextValue {
                id: txt_endDate
                text: "-"
            }

            Text {
                Layout.alignment: Qt.AlignRight
                text: "Subprojects:"
                font.pixelSize: root.fontSize
                font.bold: true
            }
            TextValue {
                id: txt_subProjects
                text: "-"
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
