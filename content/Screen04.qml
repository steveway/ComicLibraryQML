/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Pdf
import Qt.labs.folderlistmodel
import QtQuick.Effects
import CLC

Rectangle {
    id: folder_rectangle
    //id: rectangle
    //objectName: "pdf_screen_rect"
    // property int destinedPage: 0
    width: Constants.width
    height: Constants.height

    color: Constants.backgroundColor
    GridView {
        id: folder_list_thumbnail_grid
        x: 5
        y: 5
        width: parent.width - 10
        //flow: GridView.FlowTopToBottom
        height: menu_bar.y - 5
        visible: true
        objectName: "folder_thumbnail_list"
        model: FolderListModel {// Empty model initially
            id: folderModel
            nameFilters: ["*pdf"]
            showDirs: false
            onStatusChanged: {

                if (folderModel.status == FolderListModel.Ready) {
                    console.log('Loaded')
                    console.log(folderModel.folder)
                }
            }
        }
        delegate: Item {
            //border.color: "black"
            id: cell_item

            width: folder_list_thumbnail_grid.cellWidth
            height: folder_list_thumbnail_grid.cellHeight
            objectName: fileName
            Image {
                id: thumb_image
                height: cell_item.height / 1.5625
                width: cell_item.width
                y: 0
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                anchors.horizontalCenter: parent.horizontalCenter
                source: folderModel.folder + "/thumbnails/" + fileName.slice(0, -4) + ".png"
                MouseArea {
                    id: thumb_click
                    anchors.fill: parent
                    // onClicked :App {
                    //     selectedBook = model.pdf_file
                    //     backend.openComic(model.pdf_file)
                    // }
                }
                Rectangle {
                    id: background_rect
                    y: thumb_image.y + thumb_image.height + 5
                    x: thumb_label.x
                    width: thumb_label.width
                    height: thumb_label.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    //color: Material.background
                    gradient: Gradient.HeavyRain
                    //opacity: 0.5
                    //border.color: "black"
                    //border.width: 5
                    radius: 2
                }

                // ProgressBar {
                //     id: book_progress
                //     objectName: "book_progress"
                //     y: thumb_image.y + thumb_image.height
                //     width: parent.width - (parent.width / 15)
                //     height: (cell_item.height - y) / 3
                //     anchors.horizontalCenter: parent.horizontalCenter
                //     to: 100.0
                //     from: 0.0
                //     value: model.progress
                //     //Material.accent: Material.DeepOrange
                // }
                Text {
                    id: thumb_label
                    //x : parent.x - width / 1.5
                    y: background_rect.y //+ book_progress.height
                    width: cell_item.width - (cell_item.width / 20)
                    height: (cell_item.height - (thumb_image.height)) //+ book_progress.height))
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: background_rect.verticalCenter
                    text: fileBaseName
                    fontSizeMode: Text.HorizontalFit
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            //                DropShadowApp {
            //                        anchors.fill: thumb_image
            //                        horizontalOffset: 3
            //                        verticalOffset: 3
            //                        radius: 8.0
            //                        samples: 17
            //                        color: "#80000000"
            //                        source: thumb_image
            //                        cached: true
            //                }
            MultiEffect {
                source: thumb_image
                anchors.fill: thumb_image
                //autoPaddingEnabled: false
                //paddingRect: Qt.rect(cell_item.x, cell_item.y, cell_item.width - 1, cell_item.height - 1)
                shadowBlur: 0.7
                shadowEnabled: true
                shadowColor: "#80000000"
                shadowVerticalOffset: 3
                shadowHorizontalOffset: 3
            }
        }


        cellHeight: 200
        cellWidth: 200
    }


}
