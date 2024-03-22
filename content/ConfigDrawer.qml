import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import CLC

Drawer {
    id: configDrawer
    // width: mainWindow.width / 2
    height: mainWindow.height
    background: Rectangle {
        color: Constants.backgroundColor
    }
    // property bool menuBar;
    //property Animation animationInDrawer;
    //property Animation animationOutDrawer;

    ColumnLayout {
        spacing: 10
        height: configDrawer.height

        Button {
            id: showMenuButton
            text: (menu_bar.not_hidden === 0) ? qsTr("Show Menu Bar") : qsTr("Hide Menu Bar")
            onClicked: {
                if (menu_bar.not_hidden === 1) {
                    animationOut.start()
                } else {
                    animationIn.start()
                }
            }
        }

        Button {
            text: AppSettings.selected_layout
            onClicked: {
                if(AppSettings.selected_layout === "Right Handed"){
                    AppSettings.selected_layout = "Left Handed"
                }
                else if(AppSettings.selected_layout === "Left Handed"){
                    AppSettings.selected_layout = "Normal"
                }
                else {
                    AppSettings.selected_layout = "Right Handed"
                }
            }
        }

        SpinBox {
            id: thumbWidthSpin
            value: AppSettings.thumb_width
            stepSize: 50
            from: 10
            to: 4096
            onValueModified: {
                AppSettings.thumb_width = value
                AppSettings.recreate_thumbs = true
            }
        }

        SpinBox {
            id: thumbHeightSpin
            value: AppSettings.thumb_height
            stepSize: 50
            from: 10
            to: 4096
            onValueModified: {
                AppSettings.thumb_height = value
                AppSettings.recreate_thumbs = true
            }
        }
        Slider {
            id: buttonOffsetSlider
            Layout.fillHeight: true
            Layout.fillWidth: true
            orientation: Qt.Vertical
            from: 0.0
            to: 0.8

            value: AppSettings.button_offset
            onValueChanged: {
                AppSettings.button_offset = value
            }
        }
        Rectangle{
            height: parent.height / 25
        }
    }
}
