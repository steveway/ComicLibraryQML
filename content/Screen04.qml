
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
import QtQuick.Layouts
// import QtQuick.Effects
import CLC

Rectangle {
    id: folder_rectangle
    //id: rectangle
    //objectName: "pdf_screen_rect"
    // property int destinedPage: 0
    property var selectedBook
    property int scrollindex: 0
    property int destinedIndex: 0
    property bool loadingFinished: false
    width: Constants.width
    height: Constants.height
    //anchors.bottom: menu_bar.top
    color: Constants.backgroundColor
    onDestinedIndexChanged: {
        console.log("Moving Index to:")
        console.log(destinedIndex)
        while(!loadingFinished){
            fileio.updateUI()
        }
        folder_list_thumbnail_grid.positionViewAtIndex(destinedIndex, GridView.Visible)

        selectedBook = folder_list_thumbnail_grid.itemAtIndex(destinedIndex)
        console.log("Selected Book:")
        console.log(selectedBook)

        if(AppSettings.lastComic){
            for (var i = 0; i < pdf_screen.children.length; ++i) {
                console.log(pdf_screen.children[i].objectName)
                if (pdf_screen.children[i].objectName === "pdf_view") {
                    pdf_screen.children[i].document.source = AppSettings.lastComic
                    swipeView.setCurrentIndex(1)
                    pdf_screen.destinedPage = AppSettings.lastPage
                }
            }
        }
    }

    GridView {
        id: folder_list_thumbnail_grid
        enabled: false
        x: parent.width / 400
        y: parent.height / 400
        width: parent.width - (parent.width / 200)
        //flow: GridView.FlowTopToBottom
        height: menu_bar.y - menu_bar.height
        visible: true
        objectName: "folder_thumbnail_list"

        model: FolderListModel {
            // Empty model initially
            id: folderModel
            nameFilters: ["*pdf"]
            showDirs: false
            // onStatusChanged:{
            //     if (folderModel.status == FolderListModel.Ready){
            //         scroll_through_list.start()
            //     }
            // }
        }

        SequentialAnimation {
            id: scroll_through_list
            NumberAnimation {
                target: scrollbar_thumbs
                property: "position"
                from: 0.0
                to: 1.0
                duration: 500
            }
            NumberAnimation {
                target: scrollbar_thumbs
                property: "position"
                from: 1.0
                to: 0.0
                duration: 500
            }
        }


        Component {
            id: fileDelegate
            ColumnLayout {
                //border.color: "black"
                id: cell_item

                width: folder_list_thumbnail_grid.cellWidth
                height: folder_list_thumbnail_grid.cellHeight
                objectName: fileName
                property string thumb_folder: folderModel.folder + "/thumbnails/"
                property string conf_file: thumb_folder + fileName.slice(
                                               0, fileName.lastIndexOf(
                                                   ".")) + ".json"
                property string pdf_file: fileUrl
                property string thumbnail_path: folderModel.folder
                                                + "/thumbnails/" + fileName.slice(
                                                    0, fileName.lastIndexOf(
                                                        ".")) + ".png"
                property var json_data: null
                function update_progress_bar(progress) {
                    book_progress.value = progress
                }
                Timer {
                    id: thumbnail_generator
                    objectName: "thumbnail_generator"
                    interval: 0
                    running: false
                    repeat: false
                    onTriggered: {
                        if (!fileio.does_file_exist(thumbnail_path)) {
                            fileio.create_thumbnail(pdf_file, thumbnail_path,
                                                    thumb_image.height)
                        }
                        // thumb_image.source = thumbnail_path
                        // json_data = read_progress_from_file(conf_file)
                        progress_bar.to = folderModel.count
                        progress_bar.value = progress_bar.value + 1
                    }
                }

                Timer {
                    id: set_thumb_path
                    interval: 250
                    running: false
                    repeat: true
                    onTriggered: {
                        if(fileio.does_file_exist(thumbnail_path)){
                            thumb_image.source = thumbnail_path
                            set_thumb_path.stop()
                        }
                    }
                }

                Component.onCompleted: {
                    thumbnail_generator.start()
                    // thumb_image.source = thumbnail_path
                    // set_thumb_path.start()
                    json_data = read_progress_from_file(conf_file)
                    progress_bar.to = folderModel.count
                    progress_bar.value = progress_bar.value + 1
                    if (!fileio.does_file_exist(thumbnail_path)) {
                        fileio.create_thumbnail(pdf_file, thumbnail_path,
                                                thumb_image.height)
                    }
                    thumb_image.source = thumbnail_path
                    //fileio.updateUI()
                    if (scrollindex < folder_list_thumbnail_grid.count){
                        scrollindex = scrollindex + 1
                        folder_list_thumbnail_grid.positionViewAtIndex(scrollindex, GridView.Visible)
                    }
                    else{
                        folder_list_thumbnail_grid.enabled = true
                        grey_overlay.enabled = false
                        grey_overlay.visible = false
                        loadingFinished = true
                    }

                    // cpp.create_thumbnail(pdf_file, thumbnail_path,
                    //                         thumb_image.height)

                }
                Image {
                    id: thumb_image
                    Layout.preferredHeight: cell_item.height / (cell_item.height / 128)// 1.5625
                    //width: cell_item.width
                    // y: 0
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    //anchors.horizontalCenter: parent.horizontalCenter
                    Layout.alignment: Qt.AlignHCenter
                    //source: thumbnail_path
                    MouseArea {
                        id: thumb_click
                        anchors.fill: parent
                        onClicked: {
                            selectedBook = cell_item
                            //selectedBook = model.pdf_file
                            //backend.openComic(model.pdf_file)
                            //console.log(mainWindow)
                            console.log(thumb_image)
                            console.log(thumb_image.source)
                            console.log(fileName)
                            console.log(pdf_file)
                            console.log("Selected Book")
                            var temp_index = folder_list_thumbnail_grid.indexAt(cell_item.x, cell_item.y)
                            console.log(temp_index)
                            AppSettings.lastComicIndex = temp_index
                            AppSettings.lastComic = pdf_file
                            for (var i = 0; i < pdf_screen.children.length; ++i) {
                                console.log(pdf_screen.children[i].objectName)
                                if (pdf_screen.children[i].objectName === "pdf_view") {
                                    console.log(pdf_screen.children[i].document)
                                    pdf_screen.children[i].document.source = fileUrl


                                    console.log(parent)
                                    swipeView.setCurrentIndex(1)
                                    pdf_screen.destinedPage = (json_data.page) ? json_data.page : 0
                                    //pdf_screen.children[i].goToPage(json_data.page)
                                    //pdf_screen.destinedPage = json_data.page
                                    // console.log(pdf_screen.children[i])
                                    // pdf_screen.children[i].page_changer.start()
                                }
                            }
                        }
                    }
                }
                    Rectangle {
                        id: background_rect
                        //y: thumb_image.y + thumb_image.height + 5
                        //x: thumb_label.x
                        //width: thumb_label.width
                        //height: thumb_label.height
                        //anchors.horizontalCenter: parent.horizontalCenter
                        //color: Material.background
                        gradient: Gradient.HeavyRain
                        Layout.preferredHeight: thumb_image / 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        //opacity: 0.5
                        //border.color: "black"
                        //border.width: 5
                        radius: 2

                    ColumnLayout{
                    ProgressBar {
                        id: book_progress
                        objectName: "progress_" + fileName
                        Layout.preferredHeight: 12
                        //y: thumb_image.y + thumb_image.height
                        //width: parent.width - (parent.width / 15)
                        //height: (cell_item.height - y) / 3
                        //anchors.horizontalCenter: parent.horizontalCenter
                        to: 100.0
                        from: 0.0
                        value: (json_data.progress !== undefined) ? json_data.progress : 0.0
                        //Material.accent: Material.DeepOrange
                    }
                    Item{
                        Layout.fillHeight: true
                        Layout.preferredHeight: background_rect.height - book_progress.height
                        Layout.fillWidth: true
                        //visible: false
                        //color: "red"
                    // }
                    Text {
                        id: thumb_label

                        //x : parent.x - width / 1.5
                        //y: background_rect.y //+ book_progress.height
                        //width: cell_item.width - (cell_item.width / 20)
                        //height: (cell_item.height - thumb_image.height
                        //         - book_progress.height) //+ book_progress.height))
                        width: parent.width
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        //Layout.preferredHeight: 128
                        //Layout.fillHeight: true
                        //Layout.fillWidth: true
                        text: fileBaseName
                        fontSizeMode: Text.Fit
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    }


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
                // MultiEffect {
                //     source: thumb_image
                //     anchors.fill: thumb_image
                //     //autoPaddingEnabled: false
                //     //paddingRect: Qt.rect(cell_item.x, cell_item.y, cell_item.width - 1, cell_item.height - 1)
                //     shadowBlur: 0.7
                //     shadowEnabled: true
                //     shadowColor: "#80000000"
                //     shadowVerticalOffset: 3
                //     shadowHorizontalOffset: 3
                // }
            }
        }

        cellHeight: 200
        cellWidth: 200
        delegate: fileDelegate

        ScrollBar.vertical: ScrollBar {
            id: scrollbar_thumbs
            parent: folder_list_thumbnail_grid
            anchors.right: folder_list_thumbnail_grid.right
            //anchors.bottom: menu_bar.top
            //height: folder_list_thumbnail_grid.height - menu_bar.height
            //y: library_thumbnails.visibleArea.yPosition * library_thumbnails.height
            //width: 10
            //height: library_thumbnails.visibleArea.heightRatio * library_thumbnails.height
            //color: Material.accent
        }
        Rectangle {
            id: grey_overlay
            width: folder_rectangle.width
            height: folder_rectangle.height
            x: folder_rectangle.x
            y: folder_rectangle.y
            color: "grey"
            opacity: 0.5
        }
    }

    function read_progress_from_file(file_path) {
        //console.log(file_path)
        return fileio.read_json(file_path)
    }

    function write_progress_to_file(file_path, modified_data) {
        console.log(file_path)
        console.log(modified_data)

        // Convert the modified data to JSON string
        var jsonString = JSON.stringify(modified_data)

        // Call the write function from FileIO
        fileio.write(file_path, jsonString)
    }
}
