pragma Singleton

import QtCore
import CLC

Settings {
    property string lastFolder: ""
    property string lastComic: ""
    property int lastComicIndex: 0
    property int lastPage: 0
    property int windowX: 100
    property int windowY: 100
    property int windowWidth: Constants.width
    property int windowHeight: Constants.height
    property rect windowRect: Qt.rect(0,0, Constants.width, Constants.height)
    property bool fullscreen: false
    property double button_offset: 0
    property string selected_layout: "Right Handed"
    property int thumb_width: 200
    property int thumb_height: 200
    property bool recreate_thumbs: false  // Don't recreate on startup

}
