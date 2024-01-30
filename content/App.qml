import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import CLC

Window {
    width: AppSettings.windowWidth
    height: AppSettings.windowHeight
    x: AppSettings.windowX
    y: AppSettings.windowY

    property bool fullscreen: AppSettings.fullscreen
    visibility: fullscreen ? Window.FullScreen : Window.Windowed
    id: mainWindow

    onWidthChanged: {
        AppSettings.windowWidth = mainWindow.width
    }
    onHeightChanged: {
        AppSettings.windowHeight = mainWindow.height
    }

    onXChanged: {
        console.log("Position changed:")
        console.log(mainWindow.x)
        console.log(mainWindow.y)
        AppSettings.windowX = mainWindow.x
    }
    onYChanged: {
        AppSettings.windowY = mainWindow.y
    }

    onVisibilityChanged: {
        console.log("Visibility Changed:")
        console.log(mainWindow.visibility)
        console.log(Window.FullScreen)
        console.log(Window.Windowed)
        if(mainWindow.visibility === Window.FullScreen){
            AppSettings.fullscreen = true
        }
        if(mainWindow.visibility === Window.Windowed){
            AppSettings.fullscreen = false
        }
    }

    visible: true

    SwipeView {
        id: swipeView
        objectName: "swipe_view"
        anchors.top: tabBar.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        currentIndex: tabBar.currentIndex

        Screen04 {
            id: folder_list
            Component.onCompleted:{
                console.log("FolderView Loaded")
                if (AppSettings.lastFolder){
                    check_for_thumbnail_folder(AppSettings.lastFolder)

                }
            }
        }

        Screen02 {
            id: pdf_screen
        }
        Item {
            id: config_screen
            Rectangle {
                width: mainWindow.width
                height: mainWindow.height
                color: Constants.backgroundColor
                Button {
                    text: (menu_bar.hidden) ? qsTr("Show Menu Bar") : qsTr(
                                                  "Hide Menu Bar")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        if (menu_bar.hidden === false) {
                            menu_bar.hidden = true
                            animation_out.start()
                        } else {
                            animation_in.start()
                            menu_bar.hidden = false
                        }
                    }
                }
            }
        }
    }
    SequentialAnimation {
        id: animation_out
        NumberAnimation {
            target: menu_bar
            property: "y"
            to: mainWindow.height
            duration: 500
        }
    }
    SequentialAnimation {
        id: animation_in
        NumberAnimation {
            target: menu_bar
            property: "y"
            to: mainWindow.height - menu_bar.height - 5
            duration: 500
        }
    }

    TabBar {
        anchors.left: parent.left
        anchors.right: parent.right

        id: tabBar
        currentIndex: swipeView.currentIndex

        TabButton {
            text: qsTr("Library")
        }
        TabButton {
            text: qsTr("Book")
        }
        TabButton {
            text: qsTr("Settings")
            width: implicitWidth
        }
        // TabButton{
        //     text: qsTr("FolderList")
        // }
    }

    ToolBar {
        id: menu_bar
        objectName: "menu_bar"
        property bool hidden
        hidden: false
        x: 5
        y: mainWindow.height - height - 5
        width: mainWindow.width - 10
        height: 72
        ToolButton {
            id: add_collection_button
            y: parent.y + (parent.height / 36)
            height: parent.height - (parent.height / 36 * 2)
            objectName: "add_button"
            text: "+"
            font.pixelSize: parent.height / 2
            onClicked: fileDialog.visible = true
        }
        ProgressBar {
            id: progress_bar
            y: parent.y + (parent.height / 36)
            height: parent.height - (parent.height / 36 * 2)
            x: add_collection_button.x + add_collection_button.width + 5
            width: parent.x + parent.width - add_collection_button.width - 10
            objectName: "progress_bar"
            from: 0
            to: 100
            onValueChanged: {
                if (value == to) {
                    animation_out.start()
                    menu_bar.hidden = true
                }
            }
        }
    }
    FolderDialog {
        id: fileDialog
        objectName: "file_dialog"
        visible: false
        title: "Select the data directory"
        //options: FolderDialog.ShowDirsOnly
        //selectFolder: true
        onAccepted: {
            //file_manager.file_url = fileDialog.currentFolder  // <---
            console.log("Selected")
            console.log(fileDialog.selectedFolder)
            console.log(fileDialog.currentFolder)
            console.log(currentFolder)
            AppSettings.lastFolder = fileDialog.selectedFolder
            check_for_thumbnail_folder(fileDialog.selectedFolder)
        }
    }
    function check_for_thumbnail_folder(folder_path) {
        console.log("Opening folder:")
        console.log(folder_path)
        console.log(folder_list.children)
        folder_list.children[0].model.folder = folder_path
        folder_list.children[0].model.rootFolder = folder_path
    }
}
