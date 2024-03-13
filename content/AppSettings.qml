pragma Singleton

import QtCore
import CLC

Settings {
    property string lastFolder: ""
    property string lastComic: ""
    property int lastComicIndex: 0
    property int lastPage: 0
    property rect windowRect: Qt.rect(0,0, Constants.width, Constants.height)
    property bool fullscreen: false
    property double button_offset: 0
    property string selected_layout: "One Handed"
    property int thumb_width: 200
    property int thumb_height: 200
    property bool recreate_thumbs: true

}
