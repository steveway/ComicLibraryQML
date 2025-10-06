
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

    onVisibleChanged: {
        if (visible && loadingFinished && selectedBook) {
            ensureSelectedBookVisible.start()
        }
    }

    onLoadingFinishedChanged: {
        if (loadingFinished) {
            // Hide menu bar when loading is complete
            animationOut.start()
        }
        if (AppSettings.lastComicIndex){
            //folder_list_thumbnail_grid.positionViewAtIndex(destinedIndex, GridView.Visible)
            destinedIndex = folderModel.indexOf(AppSettings.lastComic)
        }
    }
    
    // Reset recreate_thumbs flag after a delay to allow visible items to regenerate
    Timer {
        id: resetRegenerateFlag
        interval: 1000
        running: false
        onTriggered: {
            AppSettings.recreate_thumbs = false
        }
    }
    
    Connections {
        target: AppSettings
        function onRecreate_thumbsChanged() {
            if (AppSettings.recreate_thumbs) {
                resetRegenerateFlag.restart()
            }
        }
    }

    Timer {
        id: ensureSelectedBookVisible
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            if (selectedBook && AppSettings.lastComicIndex !== undefined) {
                folder_list_thumbnail_grid.positionViewAtIndex(AppSettings.lastComicIndex, GridView.Center)
            }
        }
    }

    onDestinedIndexChanged: {
        //folder_list_thumbnail_grid.positionViewAtIndex(destinedIndex, GridView.Visible)
        //folder_list_thumbnail_grid.positionViewAtBeginning()
        open_book.start()
        move_to_page.start()
    }

    Timer {
        id: move_to_page
        objectName: "move_to_page"
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            folder_list_thumbnail_grid.positionViewAtIndex(destinedIndex, GridView.Visible)
        }
    }

    Timer {
        id: open_book
        objectName: "open_book"
        interval: 100
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
        x: parent.width / (AppSettings.thumb_width * 2)
        y: parent.height / (AppSettings.thumb_height * 2)
        width: parent.width - (parent.width / AppSettings.thumb_width)
        height: menu_bar.y - menu_bar.height
        visible: true
        objectName: "folder_thumbnail_list"
        
        // Performance optimizations
        cacheBuffer: cellHeight * 3
        reuseItems: loadingFinished  // Only reuse items after initial load
        
        // Update layout when thumbnail size changes
        onCellWidthChanged: Qt.callLater(folder_list_thumbnail_grid.forceLayout)
        onCellHeightChanged: Qt.callLater(folder_list_thumbnail_grid.forceLayout)

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
                property bool isHovered: false
                property bool needsRegeneration: false
                property bool isRegenerating: false
                color: (isSelected) ? palette.accent : Constants.backgroundColor
                border.width: isHovered ? 2 : (isRegenerating ? 3 : 0)
                border.color: isRegenerating ? "orange" : palette.highlight
                
                Behavior on border.width {
                    NumberAnimation { duration: 150 }
                }
                
                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }

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
                    
                    Connections {
                        target: AppSettings
                        function onRecreate_thumbsChanged() {
                            if (AppSettings.recreate_thumbs) {
                                cell_item.needsRegeneration = true
                                // Regenerate all items in view
                                thumbnail_generator.restart()
                            }
                        }
                    }
                    
                    // Regenerate when item becomes visible
                    Connections {
                        target: cell_item
                        function onVisibleChanged() {
                            if (cell_item.visible && cell_item.needsRegeneration) {
                                thumbnail_generator.restart()
                            }
                        }
                    }

                    Timer {
                        id: thumbnail_generator
                        objectName: "thumbnail_generator"
                        interval: 50  // Small delay to let UI update
                        running: false
                        repeat: false
                        onTriggered: {
                            if (!fileio.does_file_exist(thumbnail_path) || cell_item.needsRegeneration) {
                                cell_item.isRegenerating = true
                                thumb_image.opacity = 0.5
                                fileio.create_thumbnail(pdf_file, thumbnail_path,
                                                        thumb_image.height)
                                set_thumb_path.start()
                                cell_item.needsRegeneration = false
                            }
                        }
                    }

                    Timer {
                        id: set_thumb_path
                        interval: 250
                        running: false
                        repeat: true
                        property int retryCount: 0
                        onTriggered: {
                            if(fileio.does_file_exist(thumbnail_path)){
                                // Force complete reload by clearing source and waiting
                                thumb_image.source = ""
                                reloadTimer.start()
                                set_thumb_path.stop()
                                retryCount = 0
                            } else {
                                retryCount++
                                if (retryCount > 20) {  // Stop after 5 seconds
                                    set_thumb_path.stop()
                                    cell_item.isRegenerating = false
                                    retryCount = 0
                                }
                            }
                        }
                    }
                    
                    Timer {
                        id: reloadTimer
                        interval: 100
                        running: false
                        repeat: false
                        onTriggered: {
                            // Force Qt to reload the image from disk
                            var path = thumbnail_path
                            thumb_image.source = path
                            // Trigger layout recalculation
                            thumb_image.sourceSize.width = 0
                            thumb_image.sourceSize.height = 0
                            thumb_image.opacity = 1.0
                            cell_item.isRegenerating = false
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
                        json_data = read_progress_from_file(conf_file)
                        thumbnail_generator.start()
                        thumb_image.source = thumbnail_path
                        
                        if (scrollindex < folder_list_thumbnail_grid.count){
                            scrollindex = scrollindex + 1
                            folder_list_thumbnail_grid.positionViewAtIndex(scrollindex, GridView.Visible)
                        }
                        else{
                            folder_list_thumbnail_grid.enabled = true
                            loadingFinished = true
                            AppSettings.recreate_thumbs = false
                        }
                    }
                    Image {
                        id: thumb_image
                        Layout.preferredHeight: cell_item.height /  1.5625
                        Layout.preferredWidth: cell_item.width
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: false  // Disable cache to allow reload
                        smooth: true
                        opacity: cell_item.isRegenerating ? 0.5 : (thumb_click.containsMouse ? 0.8 : 1.0)
                        Layout.alignment: Qt.AlignHCenter
                        
                        // Force image to use source size when available
                        sourceSize.width: 0
                        sourceSize.height: 0
                        
                        Behavior on opacity {
                            NumberAnimation { duration: 300 }
                        }
                        
                        MouseArea {
                            id: thumb_click
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: cell_item.isHovered = true
                            onExited: cell_item.isHovered = false
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
                                value: (typeof json_data !== 'undefined') & (typeof json_data.progress !== 'undefined') ? json_data.progress : 0.0
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

        cellHeight: AppSettings.thumb_height
        cellWidth: AppSettings.thumb_width
        delegate: fileDelegate

        ScrollBar.vertical: ScrollBar {
            id: scrollbar_thumbs
            objectName: "scrollbar_thumbs"
            parent: folder_list_thumbnail_grid
            anchors.right: folder_list_thumbnail_grid.right
        }
        BusyIndicator {
            id: loading_indicator
            anchors.centerIn: parent
            running: !loadingFinished
            visible: !loadingFinished
            width: 64
            height: 64
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
