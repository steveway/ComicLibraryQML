
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
        pdf_document.source = destinedBook
        fade_out_buttons.start()
        fade_out_buttons_one.start()
    }

    onDestinedPageChanged: {
        page_changer.start()
    }

    PdfMultiPageView {
        objectName: "pdf_view"

        onCurrentPageChanged: {

            /^(file:\/+|qrc:\/+|http:\/+)(?=[A-Z])(?=[^:])|^(file:\/+|qrc:\/+|http:\/+)(?=(\/|$))/
            var big_regex = /^(file:\/+|qrc:\/+|http:\/+)(?=[A-Z])(?=[^:])|^(file:\/+|qrc:\/+|http:\/+)(?=(\/|$))/
            AppSettings.lastPage = currentPage
            if(folder_list.selectedBook){
                folder_list.selectedBook.json_data.page = currentPage
                folder_list.selectedBook.json_data.progress = (currentPage / document.pageCount) * 100
                folder_list.selectedBook.update_progress_bar(
                            (currentPage / document.pageCount) * 100)
                folder_list.write_progress_to_file(
                            folder_list.selectedBook.conf_file,
                            folder_list.selectedBook.json_data)
            }
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
    Column {
        id: overlay_layout
        x: 5
        visible: (AppSettings.selected_layout === "Normal")
        y: (menu_bar.y - menu_bar.height - height - 5) - (menu_bar.y * AppSettings.button_offset)
        width: rectangle.width - 10
        height: 128
        spacing: 0

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            width: overlay_layout.width
            text: pdf_document.pageCount + " / " + pdf_view.currentPage
            horizontalAlignment: Text.AlignHCenter
        }


        Item {
            id: button_layout
            width: overlay_layout.width
            height: overlay_layout.height


            Button {
                id: prev_page
                text: "←"
                anchors.left: button_layout.left
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
            }
            Button {
                id: scale_width
                objectName: "scale_width"
                anchors.horizontalCenter: parent.horizontalCenter
                text: (scale_width.checked) ? "-" : "⛶"
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
                anchors.right: button_layout.right
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
            }
        }
    }

    Column {
        id: one_handed_layout
        visible: (AppSettings.selected_layout === "One Handed")
        x: 5
        y: (menu_bar.y - menu_bar.height - height - 5) - (menu_bar.y * AppSettings.button_offset)
        width: rectangle.width - 10
        height: 128 * 2
        spacing: 0

        Item {
            id: button_layout_one
            width: one_handed_layout.width
            height: one_handed_layout.height
            Button {
                id: prev_page_one
                text: "←"
                anchors.right: button_layout_one.right
                anchors.top: button_layout_one.top
                // anchors.bottom: next_page_one.top
                font.pixelSize: parent.height / 4

                Connections {
                    target: prev_page_one
                    onClicked: {
                        one_handed_layout.opacity = 1
                        if (pdf_view.currentPage > 0) {
                            pdf_view.goToPage(pdf_view.currentPage - 1)
                        }
                        fade_out_buttons_one.start()
                    }
                }
            }
            Button {
                id: scale_width_one
                objectName: "scale_width_one"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: button_layout_one.bottom
                text: (scale_width_one.checked) ? "-" : "⛶"
                font.pixelSize: parent.height / 4
                checkable: true
                Connections {
                    target: scale_width_one
                    onClicked: {
                        one_handed_layout.opacity = 1
                        if (scale_width_one.checked) {
                            pdf_view.scaleToWidth(pdf_view.width - 100,
                                pdf_view.height - 100)
                            //scale_width.text = "-"
                        } else {
                            pdf_view.scaleToPage(pdf_view.width - 100,
                                pdf_view.height - 100)
                            //scale_width.text = "⛶"
                        }
                        fade_out_buttons_one.start()
                    }
                }
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: scale_width_one.top
                width: one_handed_layout.width
                text: pdf_document.pageCount + " / " + pdf_view.currentPage
                horizontalAlignment: Text.AlignHCenter
            }
            Button {
                id: next_page_one
                text: "→"
                anchors.right: button_layout_one.right
                anchors.bottom: button_layout_one.bottom
                font.pixelSize: parent.height / 4
                Connections {
                    target: next_page_one
                    onClicked: {
                        one_handed_layout.opacity = 1
                        if (pdf_view.currentPage < pdf_document.pageCount - 1) {
                            pdf_view.goToPage(pdf_view.currentPage + 1)
                        }
                        fade_out_buttons_one.start()
                    }
                }
            }
        }
    }

    Timer {
        id: page_changer
        objectName: "page_changer"
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            while (pdf_view.currentPageRenderingStatus === Image.Null
                   || pdf_view.currentPageRenderingStatus === Image.Loading) {
                fileio.updateUI()
            }
            pdf_view.goToPage(destinedPage)
            while (pdf_view.currentPage !== destinedPage) {
                fileio.updateUI()
            }
            while (pdf_view.currentPageRenderingStatus === Image.Null
                   || pdf_view.currentPageRenderingStatus === Image.Loading) {
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
    SequentialAnimation {
        id: fade_out_buttons_one
        NumberAnimation {
            target: one_handed_layout
            property: "opacity"
            to: 0.2
            duration: 5000
        }
    }

}
