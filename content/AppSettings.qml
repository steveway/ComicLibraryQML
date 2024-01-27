pragma Singleton

import QtCore
import CLC

Settings {
    property string lastFolder
    property int windowX : 0
    property int windowY : 0
    property int windowHeight: Constants.height
    property int windowWidth: Constants.width
    property bool fullscreen: false

}
