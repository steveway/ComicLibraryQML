/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Pdf
import CLC

Rectangle {
    id: rectangle
    objectName: "pdf_screen_rect"
    property int destinedPage: 0
    width: Constants.width
    height: Constants.height

    color: Constants.backgroundColor

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
            console.log("Changing Page:")
            console.log(currentPage)
            console.log(folder_list)
            console.log(folder_list.selectedBook.json_data.page)
            console.log(folder_list.selectedBook.json_data.progress)
            folder_list.selectedBook.json_data.page = currentPage
            console.log(folder_list.selectedBook.json_data.page)
            folder_list.selectedBook.json_data.progress = (currentPage / document.pageCount) * 100
            console.log(folder_list.selectedBook.json_data.progress)
            console.log(folder_list.selectedBook.conf_file)
            folder_list.selectedBook.update_progress_bar((currentPage / document.pageCount) * 100)
            folder_list.write_progress_to_file(folder_list.selectedBook.conf_file, folder_list.selectedBook.json_data)

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



    Button {
        id: next_page
        text: "→"
        y: menu_bar.y - menu_bar.height - height - 5
        height: 128
        width: 128
        x: pdf_view.width - width - 5
        font.pixelSize: height / 2
        Connections {
            target: next_page
            onClicked: if (pdf_view.currentPage < pdf_document.pageCount - 1) {
                           pdf_view.goToPage(pdf_view.currentPage + 1)
                       }
        }
        //opacity: 0.8
    }
    Button {
        id: prev_page
        text: "←"
        y: menu_bar.y - menu_bar.height - height - 5
        height: 128
        width: 128
        x: 5
        font.pixelSize: height / 2

        Connections {
            target: prev_page
            onClicked: if (pdf_view.currentPage > 0) {
                           pdf_view.goToPage(pdf_view.currentPage - 1)
                       }
        }
        //opacity: 0.8
    }
    Button {
        id: scale_width
        objectName: "scale_width"
        text: (scale_width.checked) ? "-" : "⛶"
        y: menu_bar.y - menu_bar.height - height - 5
        height: 128
        width: 128
        // x: (parent.width / 2) - (width / 2)
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: height / 2
        checkable: true
        Connections {
            target: scale_width
            onClicked: if (scale_width.checked) {
                       pdf_view.scaleToWidth(pdf_view.width - 100,
                                             pdf_view.height - 100)
                       //scale_width.text = "-"
                   } else {
                       pdf_view.scaleToPage(pdf_view.width - 100,
                                            pdf_view.height - 100)
                       //scale_width.text = "⛶"
                   }
               }

        }
        //opacity: 0.8

    Label {
        //x: scale_width.x
        anchors.horizontalCenter: parent.horizontalCenter
        //y: scale_width.y - height
        anchors.bottom: scale_width.top
        width: scale_width.width
        text: pdf_document.pageCount + " / " + pdf_view.currentPage
        horizontalAlignment: Text.AlignHCenter
        // anchors.horizontalCenter: scale_width.anchors.horizontalCenter
        // y: scale_width.y
    }
    Timer {
        id: page_changer
        objectName: "page_changer"
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            console.log("using timer to jump")
            console.log(destinedPage)
            while (pdf_view.currentPageRenderingStatus == Image.Null
                   || pdf_view.currentPageRenderingStatus == Image.Loading) {
                fileio.updateUI()
            }
            pdf_view.goToLocation(destinedPage, Qt.point(0,0), 1)
            pdf_view.goToPage(destinedPage)
            fileio.updateUI()
            while (pdf_view.currentPageRenderingStatus == Image.Null
                   || pdf_view.currentPageRenderingStatus == Image.Loading) {
                fileio.updateUI()
            }
        }
    }


    // Connections {
    //     target: backend
    //     function onManualPageChange(arg1) {
    //         while (pdf_document.status == PdfDocument.Null
    //                || pdf_document.status == PdfDocument.Loading
    //                || pdf_document.status == PdfDocument.Unloading) {
    //             backend.updateUI()
    //         }
    //         while (pdf_view.currentPageRenderingStatus == Image.Null
    //                || pdf_view.currentPageRenderingStatus == Image.Loading) {
    //             backend.updateUI()
    //         }
    //         destinedPage = arg1
    //         page_changer.start()
    //         console.log(pdf_view.currentPage)
    //         console.log("page changed?")
    //     }
    //     function onChangeDocument(arg1) {
    //         console.log("change doc")
    //         console.log(arg1)
    //         pdf_document.source = arg1
    //     }
    // }
}
