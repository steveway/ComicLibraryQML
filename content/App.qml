import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import CLC

Window {
    width: Constants.width
    height: Constants.height
/*
    width: AppSettings.windowWidth
    height: AppSettings.windowHeight
    x: AppSettings.windowX
    y: AppSettings.windowY*/
    property Animation animationIn: SequentialAnimation {
        // Define your animationIn here
        id: animation_in
        // NumberAnimation {
        //     target: menu_bar
        //     property: "y"
        //     to: mainWindow.height - menu_bar.height - 5
        //     duration: 500
        // }
        NumberAnimation {
            target: menu_bar
            property: "not_hidden"
            to: 1
            duration: 500
        }
    }

    property Animation animationOut: SequentialAnimation {
        // Define your animationOut here
        id: animation_out
        // NumberAnimation {
        //     target: menu_bar
        //     property: "y"
        //     to: mainWindow.height
        //     duration: 500
        // }
        NumberAnimation {
            target: menu_bar
            property: "not_hidden"
            to: 0
            duration: 500
        }
    }

    property bool fullscreen: AppSettings.fullscreen
    visibility: fullscreen ? Window.FullScreen : Window.Windowed
    id: mainWindow

    onWidthChanged: {
        changeWindowRectSettings()
    }
    onHeightChanged: {
        changeWindowRectSettings()
    }

    onXChanged: {
        changeWindowRectSettings()
    }
    onYChanged: {
        changeWindowRectSettings()
    }
    function changeWindowRectSettings(){
        AppSettings.windowX = mainWindow.x
        AppSettings.windowY = mainWindow.y
        AppSettings.windowWidth = mainWindow.width
        AppSettings.windowHeight = mainWindow.height
        AppSettings.windowRect = Qt.rect(mainWindow.x, mainWindow.y, mainWindow.width, mainWindow.height)
    }

    onVisibilityChanged: {
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
                if (AppSettings.lastFolder){
                    check_for_thumbnail_folder(AppSettings.lastFolder)

                }
            }
        }

        Screen02 {
            id: pdf_screen
        }
        ConfigDrawer {
            id: configDrawer
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
            onClicked: {
                if (configDrawer.opened){
                    configDrawer.close()
                }
                else{
                    configDrawer.open()
                }
            }
        }
        // TabButton{
        //     text: qsTr("FolderList")
        // }
    }

    ToolBar {
        id: menu_bar
        objectName: "menu_bar"
        property double not_hidden: 1
        x: 5
        y: mainWindow.height - (height + 5) * not_hidden
        width: mainWindow.width - 10
        height: 72
        background: Rectangle {gradient: Gradient.FlyHigh}
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
                if (value === to) {
                    animation_out.start()
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
            AppSettings.lastFolder = fileDialog.selectedFolder
            check_for_thumbnail_folder(fileDialog.selectedFolder)
        }
    }
    function check_for_thumbnail_folder(folder_path) {
        folder_list.children[0].model.folder = folder_path
        folder_list.children[0].model.rootFolder = folder_path
    }
}
