pragma Singleton

import QtCore
import CLC

Settings {
    property string lastFolder: ""
    property string lastComic: ""
    property int lastComicIndex: 0
    property int lastPage: 0
    property int windowX : 0
    property int windowY : 0
    property int windowHeight: Constants.height
    property int windowWidth: Constants.width
    property bool fullscreen: false

}
