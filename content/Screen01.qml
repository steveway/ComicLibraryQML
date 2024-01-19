import QtQuick 6.6
import QtQuick.Controls 6.6
import QtQuick.Pdf
//import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import CLC

Rectangle {
    id: main_content
    objectName: "main_content"
    width: Constants.width
    height: Constants.height
    property var selectedBook
    color: Constants.backgroundColor
    GridView {
        id: library_thumbnails
        x: 5
        y: 5
        width: main_content.width - 10
        //flow: GridView.FlowTopToBottom
        height: menu_bar.y - 5
        visible: true
        objectName: "thumbnail_list"
        model: ListModel {// Empty model initially
        }
        cellHeight: 200
        cellWidth: 200
        delegate: Item {
            //border.color: "black"
            id: cell_item

            width: library_thumbnails.cellWidth
            height: library_thumbnails.cellHeight
            objectName: model.pdf_file
            Image {
                id: thumb_image
                height: cell_item.height / 1.5625
                width: cell_item.width
                y: 0
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                anchors.horizontalCenter: parent.horizontalCenter
                source: model.thumbnail
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

                ProgressBar {
                    id: book_progress
                    objectName: "book_progress"
                    y: thumb_image.y + thumb_image.height
                    width: parent.width - (parent.width / 15)
                    height: (cell_item.height - y) / 3
                    anchors.horizontalCenter: parent.horizontalCenter
                    to: 100.0
                    from: 0.0
                    value: model.progress
                    //Material.accent: Material.DeepOrange
                }
                Text {
                    id: thumb_label
                    //x : parent.x - width / 1.5
                    y: background_rect.y + book_progress.height
                    width: cell_item.width - (cell_item.width / 20)
                    height: (cell_item.height - (thumb_image.height + book_progress.height))
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: background_rect.verticalCenter
                    text: model.name
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
        ScrollBar.vertical: ScrollBar {
            id: scrollbar_thumbs
            parent: library_thumbnails
            anchors.right: library_thumbnails.right
            //anchors.bottom:library_thumbnails.bottom - 20
            //y: library_thumbnails.visibleArea.yPosition * library_thumbnails.height
            //width: 10
            //height: library_thumbnails.visibleArea.heightRatio * library_thumbnails.height
            //color: Material.accent
        }
    }
}
