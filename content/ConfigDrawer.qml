import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import CLC

Drawer {
    id: configDrawer
    width: Math.min(400, mainWindow.width * 0.8)
    height: mainWindow.height
    edge: Qt.RightEdge
    background: Rectangle {
        color: Constants.backgroundColor
    }
    // property bool menuBar;
    //property Animation animationInDrawer;
    //property Animation animationOutDrawer;

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        
        ColumnLayout {
            width: parent.width
            spacing: 15
            
            // Header
            Label {
                text: qsTr("Settings")
                font.pixelSize: 24
                font.bold: true
                Layout.topMargin: 20
                Layout.leftMargin: 15
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 15
                Layout.rightMargin: 15
                height: 1
                color: "lightgray"
            }
            
            // View Section
            Label {
                text: qsTr("View")
                font.pixelSize: 18
                font.bold: true
                Layout.topMargin: 10
                Layout.leftMargin: 15
            }

            Button {
                id: showMenuButton
                Layout.fillWidth: true
                Layout.leftMargin: 15
                Layout.rightMargin: 15
                text: (menu_bar.not_hidden === 0) ? qsTr("Show Menu Bar") : qsTr("Hide Menu Bar")
                onClicked: {
                    if (menu_bar.not_hidden === 1) {
                        animationOut.start()
                    } else {
                        animationIn.start()
                    }
                }
            }
            
            // Layout Section
            Label {
                text: qsTr("Reading Layout")
                font.pixelSize: 18
                font.bold: true
                Layout.topMargin: 10
                Layout.leftMargin: 15
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: 15
                Layout.rightMargin: 15
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
            
            // Thumbnails Section
            Label {
                text: qsTr("Thumbnails")
                font.pixelSize: 18
                font.bold: true
                Layout.topMargin: 10
                Layout.leftMargin: 15
            }

            Label {
                text: qsTr("Thumbnail Width")
                Layout.leftMargin: 15
            }
            
            SpinBox {
                id: thumbWidthSpin
                Layout.fillWidth: true
                Layout.leftMargin: 15
                Layout.rightMargin: 15
                value: AppSettings.thumb_width
                stepSize: 50
                from: 100
                to: 800
                editable: true
                onValueModified: {
                    AppSettings.thumb_width = value
                    AppSettings.thumb_height = value  // Keep aspect ratio
                    AppSettings.recreate_thumbs = true
                    regenerateTimer.restart()
                }
            }
            
            Label {
                text: qsTr("Thumbnail Size (maintains aspect ratio)")
                Layout.leftMargin: 15
                font.pixelSize: 12
                color: "gray"
            }

            SpinBox {
                id: thumbHeightSpin
                Layout.fillWidth: true
                Layout.leftMargin: 15
                Layout.rightMargin: 15
                value: AppSettings.thumb_height
                stepSize: 50
                from: 100
                to: 800
                editable: true
                enabled: false  // Disabled to maintain aspect ratio
                opacity: 0.6
            }
            
            Label {
                id: regenerateLabel
                text: qsTr("Thumbnails will regenerate...")
                Layout.leftMargin: 15
                font.pixelSize: 12
                color: "orange"
                visible: false
            }
            
            Timer {
                id: regenerateTimer
                interval: 2000
                running: false
                onTriggered: {
                    regenerateLabel.visible = false
                }
            }
            
            Connections {
                target: regenerateTimer
                onRunningChanged: {
                    if (regenerateTimer.running) {
                        regenerateLabel.visible = true
                    }
                }
            }
            
            // Controls Section
            Label {
                text: qsTr("Controls")
                font.pixelSize: 18
                font.bold: true
                Layout.topMargin: 10
                Layout.leftMargin: 15
            }
            
            Label {
                text: qsTr("Button Offset")
                Layout.leftMargin: 15
            }
            
            Slider {
                id: buttonOffsetSlider
                Layout.fillWidth: true
                Layout.leftMargin: 15
                Layout.rightMargin: 15
                Layout.preferredHeight: 40
                orientation: Qt.Horizontal
                from: 0.0
                to: 0.8
                stepSize: 0.05
                snapMode: Slider.SnapOnRelease
                value: AppSettings.button_offset
                onValueChanged: {
                    AppSettings.button_offset = value
                }
            }
            
            Label {
                text: Math.round(buttonOffsetSlider.value * 100) + "%"
                Layout.leftMargin: 15
                font.pixelSize: 14
                color: "gray"
            }
            
            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 20
            }
        }
    }
}
