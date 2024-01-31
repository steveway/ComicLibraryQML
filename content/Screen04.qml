
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
import CLC

Rectangle {
    id: folder_rectangle
    property var selectedBook
    property int scrollindex: 0
    property int destinedIndex: 0
    property bool loadingFinished: false
    width: Constants.width
    height: Constants.height
    color: Constants.backgroundColor
    onLoadingFinishedChanged: {
        if (AppSettings.lastComicIndex){
            folder_list_thumbnail_grid.positionViewAtIndex(destinedIndex, GridView.Visible)
            destinedIndex = folderModel.indexOf(AppSettings.lastComic)
        }
    }

    onDestinedIndexChanged: {
        folder_list_thumbnail_grid.positionViewAtBeginning()
        open_book.start()
    }
    Timer {
        id: open_book
        objectName: "open_book"
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            if(AppSettings.lastComic){
                for (var i = 0; i < pdf_screen.children.length; ++i) {
                    if (pdf_screen.children[i].objectName === "pdf_view") {
                        pdf_screen.destinedBook = AppSettings.lastComic
                        swipeView.setCurrentIndex(1)
                        pdf_screen.destinedPage = AppSettings.lastPage
                    }
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
        height: menu_bar.y - menu_bar.height
        visible: true
        objectName: "folder_thumbnail_list"

        model: FolderListModel {
            // Empty model initially
            id: folderModel
            nameFilters: ["*pdf"]
            showDirs: false
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

            Rectangle {
                id: cell_item
                property bool isSelected: false
                color: (isSelected) ? palette.highlight : Constants.backgroundColor

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

                ColumnLayout {
                    //border.color: "black"
                    anchors.fill: cell_item


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
                        if(destinedIndex === index){
                            if(AppSettings.lastComic === cell_item.pdf_file ){
                                selectedBook = cell_item
                            }

                            if(selectedBook === cell_item){
                                cell_item.isSelected = true
                            }
                        }
                        thumbnail_generator.start()
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
                            // fileio.updateUI()
                        }
                        else{
                            folder_list_thumbnail_grid.enabled = true
                            grey_overlay.enabled = false
                            grey_overlay.visible = false
                            loadingFinished = true
                        }
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
                                if(selectedBook){
                                    selectedBook.isSelected = false
                                }
                                selectedBook = cell_item
                                cell_item.isSelected = true
                                var temp_index = folder_list_thumbnail_grid.indexAt(cell_item.x, cell_item.y)
                                AppSettings.lastComicIndex = temp_index
                                AppSettings.lastComic = pdf_file
                                for (var i = 0; i < pdf_screen.children.length; ++i) {
                                    if (pdf_screen.children[i].objectName === "pdf_view") {
                                        pdf_screen.destinedBook = fileUrl
                                        swipeView.setCurrentIndex(1)
                                        pdf_screen.destinedPage = (json_data.page) ? json_data.page : 0
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: background_rect
                        gradient: Gradient.HeavyRain
                        Layout.preferredHeight: thumb_image / 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 2

                        ColumnLayout{
                            width: background_rect.width
                            ProgressBar {
                                id: book_progress
                                objectName: "progress_" + fileName
                                Layout.preferredHeight: 12
                                to: 100.0
                                from: 0.0
                                value: (typeof json_data !== 'undefined') ? json_data.progress : 0.0
                                //Material.accent: Material.DeepOrange
                            }
                            Item{
                                Layout.fillHeight: true
                                Layout.preferredHeight: background_rect.height - book_progress.height
                                Layout.fillWidth: true
                                Text {
                                    id: thumb_label
                                    width: parent.width
                                    height: parent.height
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
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
                }
            }
        }

        cellHeight: 200
        cellWidth: 200
        delegate: fileDelegate

        ScrollBar.vertical: ScrollBar {
            id: scrollbar_thumbs
            objectName: "scrollbar_thumbs"
            parent: folder_list_thumbnail_grid
            anchors.right: folder_list_thumbnail_grid.right
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
        // Convert the modified data to JSON string
        var jsonString = JSON.stringify(modified_data)

        // Call the write function from FileIO
        fileio.write(file_path, jsonString)
    }
}
