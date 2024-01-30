
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Pdf
import QtQuick.Layouts
import CLC

Rectangle {
    id: rectangle
    objectName: "pdf_screen_rect"
    property int destinedPage: 0
    property string destinedBook: ""
    width: Constants.width
    height: Constants.height

    color: Constants.backgroundColor

    onDestinedBookChanged: {
        console.log("Changing Book to")
        console.log(destinedBook)
        pdf_document.source = destinedBook
        fade_out_buttons.start()
    }

    onDestinedPageChanged: {
        console.log("page changed")
        console.log(destinedPage)
        page_changer.start()
    }

    PdfMultiPageView {
        objectName: "pdf_view"

        onCurrentPageChanged: {

            /^(file:\/+|qrc:\/+|http:\/+)(?=[A-Z])(?=[^:])|^(file:\/+|qrc:\/+|http:\/+)(?=(\/|$))/
            var big_regex = /^(file:\/+|qrc:\/+|http:\/+)(?=[A-Z])(?=[^:])|^(file:\/+|qrc:\/+|http:\/+)(?=(\/|$))/
            // console.log("Changing Page:")
            // console.log(currentPage)
            // console.log(folder_list)
            // console.log(folder_list.selectedBook.json_data.page)
            // console.log(folder_list.selectedBook.json_data.progress)
            AppSettings.lastPage = currentPage
            if(folder_list.selectedBook){
                folder_list.selectedBook.json_data.page = currentPage
                // console.log(folder_list.selectedBook.json_data.page)
                folder_list.selectedBook.json_data.progress = (currentPage / document.pageCount) * 100
                // console.log(folder_list.selectedBook.json_data.progress)
                // console.log(folder_list.selectedBook.conf_file)
                folder_list.selectedBook.update_progress_bar(
                            (currentPage / document.pageCount) * 100)
                folder_list.write_progress_to_file(
                            folder_list.selectedBook.conf_file,
                            folder_list.selectedBook.json_data)
            }
            // backend.pageChanged(currentPage,
            //                     decodeURIComponent(document.source.toString(
            //                                            ).replace(big_regex,
            //                                                      "")))
        }
        id: pdf_view
        x: 5
        y: 5
        width: parent.width - 10
        height: parent.height - 10

        document: PdfDocument {
            id: pdf_document
            source: "../books/my.pdf"
            objectName: "pdf_document"
        }
    }
    ColumnLayout {
        id: overlay_layout
        x: 5
        y: menu_bar.y - menu_bar.height - height - 5
        width: rectangle.width - 10
        height: 128

        Label {
            Layout.fillWidth: true
            //x: scale_width.x
            //anchors.horizontalCenter: parent.horizontalCenter
            //y: scale_width.y - height
            //anchors.bottom: overlay_layout.top
            //width: overlay_layout.width
            text: pdf_document.pageCount + " / " + pdf_view.currentPage
            horizontalAlignment: Text.AlignHCenter
            // anchors.horizontalCenter: scale_width.anchors.horizontalCenter
            // y: scale_width.y
        }
        // Rectangle{
        //     Layout.fillWidth: true
        //     height: parent.height
        //     width: overlay_layout.width
        //     border.color: "red"

        RowLayout {
            id: button_layout
            // width: overlay_layout.width - 2
            Layout.preferredWidth: overlay_layout.width
            Layout.fillWidth: true

            Button {
                id: prev_page
                text: "←"
                Layout.alignment: Qt.AlignLeft
                // y: menu_bar.y - menu_bar.height - height - 5
                // height: 128
                // width: 128
                // x: 5
                font.pixelSize: parent.height / 2

                Connections {
                    target: prev_page
                    onClicked: {
                        overlay_layout.opacity = 1
                        if (pdf_view.currentPage > 0) {
                            pdf_view.goToPage(pdf_view.currentPage - 1)
                        }
                        fade_out_buttons.start()
                    }
                }
                //opacity: 0.8
            }
            Button {
                id: scale_width
                objectName: "scale_width"
                Layout.alignment: Qt.AlignHCenter
                text: (scale_width.checked) ? "-" : "⛶"
                // y: menu_bar.y - menu_bar.height - height - 5
                // height: 128
                // width: 128
                // // x: (parent.width / 2) - (width / 2)
                // anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 2
                checkable: true
                Connections {
                    target: scale_width
                    onClicked: {
                        overlay_layout.opacity = 1
                        if (scale_width.checked) {
                            pdf_view.scaleToWidth(pdf_view.width - 100,
                                                  pdf_view.height - 100)
                            //scale_width.text = "-"
                        } else {
                            pdf_view.scaleToPage(pdf_view.width - 100,
                                                 pdf_view.height - 100)
                            //scale_width.text = "⛶"
                        }
                        fade_out_buttons.start()
                    }
                }
            }
            Button {
                id: next_page
                text: "→"
                Layout.alignment: Qt.AlignRight
                // y: menu_bar.y - menu_bar.height - height - 5
                // height: 128
                // width: 128
                // x: pdf_view.width - width - 5
                font.pixelSize: parent.height / 2
                Connections {
                    target: next_page
                    onClicked: {
                        overlay_layout.opacity = 1
                        if (pdf_view.currentPage < pdf_document.pageCount - 1) {
                            pdf_view.goToPage(pdf_view.currentPage + 1)
                        }
                        fade_out_buttons.start()
                    }
                }
                //opacity: 0.8
            }
            // }
        }
    }

    //opacity: 0.8

    Timer {
        id: page_changer
        objectName: "page_changer"
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            console.log("using timer to jump")
            console.log(destinedPage)
            while (pdf_view.currentPageRenderingStatus == Image.Null
                   || pdf_view.currentPageRenderingStatus == Image.Loading) {
                fileio.updateUI()
            }
            // pdf_view.goToLocation(destinedPage, Qt.point(0,0), 1)
            pdf_view.goToPage(destinedPage)
            while (pdf_view.currentPage !== destinedPage) {
                fileio.updateUI()
            }
            while (pdf_view.currentPageRenderingStatus == Image.Null
                   || pdf_view.currentPageRenderingStatus == Image.Loading) {
                fileio.updateUI()
            }
        }
    }
    SequentialAnimation {
        id: fade_out_buttons
        NumberAnimation {
            target: overlay_layout
            property: "opacity"
            to: 0.2
            duration: 5000
        }
    }

}
