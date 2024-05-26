import QtQuick
import QtQuick.Controls
import QtQuick.Window
import ThemeEngine
import QtMultimedia 6.0

ApplicationWindow {
    id: appWindow
    flags: settingsManager.appThemeCSD ? Qt.Window | Qt.FramelessWindowHint : Qt.Window
    color: settingsManager.appThemeCSD ? "transparent" : Theme.colorBackground

    property bool isHdpi: (utilsScreen.screenDpi >= 128 || utilsScreen.screenPar >= 2.0)
    property bool isDesktop: true
    property bool isMobile: false
    property bool isPhone: false
    property bool isTablet: false

    // Desktop stuff ///////////////////////////////////////////////////////////

    minimumWidth: 800
    minimumHeight: 560

    width: {
        if (settingsManager.initialSize.width > 0)
            return settingsManager.initialSize.width
        else
            return isHdpi ? 800 : 1280
    }
    height: {
        if (settingsManager.initialSize.height > 0)
            return settingsManager.initialSize.height
        else
            return isHdpi ? 560 : 720
    }
    x: settingsManager.initialPosition.width
    y: settingsManager.initialPosition.height
    visible: true

    WindowGeometrySaver {
        windowInstance: appWindow
        Component.onCompleted: {
            // Make sure we handle window visibility correctly
            visibility = settingsManager.initialVisibility
        }
    }


    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation

    property int screenPaddingStatusbar: 0
    property int screenPaddingNavbar: 0
    property int screenPaddingTop: 0
    property int screenPaddingLeft: 0
    property int screenPaddingRight: 0
    property int screenPaddingBottom: 0


    Connections {
        target: Qt.application
        function onStateChanged() {
            switch (Qt.application.state) {
            case Qt.ApplicationActive:
                Theme.loadTheme(settingsManager.appTheme)
                break
            }
        }
    }

    onActiveFocusItemChanged: {

    }

    onClosing: (close) =>  {
                   if (Qt.platform.os === "osx") {
                       close.accepted = false
                       appWindow.hide()
                   }
               }


    MouseArea {
        anchors.fill: parent
        z: 99
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        onClicked: (mouse) => {
                       if (mouse.button === Qt.BackButton) {
                           backAction()
                       } else if (mouse.button === Qt.ForwardButton) {
                           forwardAction()
                       }
                   }
    }





    property bool singleColumn: {
        if (isMobile) {
            if (screenOrientation === Qt.PortraitOrientation ||
                    (isTablet && width < 480)) { // can be a 2/3 split screen on tablet
                return true
            } else {
                return false
            }
        } else {
            return (appWindow.width < appWindow.height)
        }
    }

    property bool wideMode: (isDesktop && width >= 560) || (isTablet && width >= 480)
    property bool wideWideMode: (width >= 640)
    Rectangle {
        id: appContent

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        color: Theme.colorBackground
        Item{
            id:bnasoifo
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 100
            width: 400
            height:400
            Image {
                id: bkimage
                anchors.fill: parent
                anchors.margins:74
                source: "qrc:/windows/icon.png"
            }
            Canvas {
                id: canvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, canvas.width, canvas.height);

                    // Draw outer circle
                    ctx.beginPath();
                    ctx.arc(canvas.width / 2, canvas.height / 2, canvas.width / 2-55, 0, 2 * Math.PI, false);
                    ctx.lineWidth = 40;
                    ctx.strokeStyle = "gray";
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.arc(canvas.width / 2, canvas.height / 2, canvas.width / 2-40, 0, 2 * Math.PI, false);
                    ctx.lineWidth = 0;
                    ctx.strokeStyle = "lightgray";
                    ctx.stroke();
                }
            }
        }


        Rectangle { //
            id:separator
            width: 2
            color: Theme.colorSeparator
            anchors.left: bnasoifo.right
            anchors.leftMargin: 100
            height: 600
            anchors.verticalCenter: parent.verticalCenter
        }
        ListView {
            id: lyricsView
            anchors.left: separator.right
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 500
            model: lyricsModel
            delegate: Item {
                width: lyricsView.width
                height: 30
                Text {
                    text: model.text
                    color: model.highlight ? "red" : "black"
                    anchors.centerIn: parent
                    font.pointSize: 16
                }
            }
        }
        ListModel {
            id: lyricsModel
        }
        ButtonImage{
            id:lastbtn
            width: 64
            height: 64
            anchors.left:parent.left
            anchors.bottom:parent.bottom
            anchors.margins: 6
            source: "qrc:/windows/voice_last.svg"
            sourceSize: 40
            onClicked:{
                if(cfgWnd.currentIndex<0) return;
                cfgWnd.currentIndex--;
                if(cfgWnd.currentIndex<0)cfgWnd.currentIndex=0;
                mediaPlayer.stop()
                mediaPlayer.source=""
                mediaPlayer.source=cfgWnd.currentItem.url
                delayedAction.start()
            }
        }
        ButtonImage{
            id:player
            width: lastbtn.width
            height: lastbtn.height
            anchors.left:lastbtn.right
            anchors.bottom:parent.bottom
            anchors.top:lastbtn.top
            source: mediaPlayer.playing?"qrc:/windows/pause.svg":"qrc:/windows/player.svg"
            sourceSize: lastbtn.sourceSize
            onClicked:{
                if(mediaPlayer.playing)
                    mediaPlayer.pause()
                else {
                    delayedAction.start()
                }
            }
        }

        ButtonImage{
            id:nextBtn
            width: lastbtn.width
            height: lastbtn.height
            anchors.top:lastbtn.top
            anchors.left:player.right
            anchors.bottom:parent.bottom
            source: "qrc:/windows/voice_last.svg"
            sourceSize: lastbtn.sourceSize
            rotation: 180
            onClicked:{
                if(cfgWnd.modelList.count<0) return;
                var index=cfgWnd.currentIndex
                index++;
                if(index===cfgWnd.modelList.count) return;
                cfgWnd.currentIndex=index
                mediaPlayer.stop()
                mediaPlayer.source=""
                mediaPlayer.source=cfgWnd.currentItem.url

                delayedAction.start()
            }
        }
        SliderThemed {
            id:parogress
            anchors.top:lastbtn.top
            anchors.left:nextBtn.right
            anchors.right:parent.right
            anchors.topMargin: 20
            anchors.rightMargin: 180
            from: 0
            to: mediaPlayer.duration
            value: mediaPlayer.position
            stepSize: 1000 // 1 second steps
            onMoved: {
                mediaPlayer.position = value
            }
        }
        Text {
            id:playerTime
            anchors.top:lastbtn.top
            anchors.left:parogress.right
            anchors.right:parent.right
            anchors.topMargin: 23
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            textFormat: Text.PlainText
            color: Theme.colorText
            font.bold: true
            font.pixelSize: 20
            font.capitalization: Font.AllUppercase
        }
        DesktopSidebarItem {
            anchors.top:lastbtn.top
            anchors.right:parent.right
            anchors.topMargin: 15
            anchors.rightMargin: 12
            width:40
            height:40
            source: "qrc:/assets/icons_material/duotone-tune-24px.svg"
            sourceSize: 40
            highlightMode: "indicator"
            onClicked:{
                colorAnimation.from=cfgWnd.x
                if(colorAnimation.isScale){
                    colorAnimation.to=appWindow.width
                }else{
                    colorAnimation.to=appWindow.width-cfgWnd.pageWidth
                }
                colorAnimation.isScale=!colorAnimation.isScale
                colorAnimation.start()
            }
        }
        MediaPlayer {
            id: mediaPlayer
            autoPlay:true
            audioOutput: AudioOutput {
                volume: cfgWnd.shValue
            }
            onMediaStatusChanged: {
                if(MediaPlayer.EndOfMedia===mediaPlayer.mediaStatus){
                    if(1===cfgWnd.currentSelection){
                    }else  if(2===cfgWnd.currentSelection){
                        let randomNumber = Math.floor(Math.random() * cfgWnd.modelList.count);
                        if(randomNumber<0) randomNumber=0;
                        cfgWnd.currentIndex=randomNumber
                        mediaPlayer.stop()
                        mediaPlayer.source=""
                        mediaPlayer.source=cfgWnd.currentItem.url
                    }else  if(3===cfgWnd.currentSelection){
                        cfgWnd.currentIndex++;
                        if(cfgWnd.modelList.count<=cfgWnd.currentIndex){
                            return;
                        }
                        mediaPlayer.stop()
                        mediaPlayer.source=""
                        mediaPlayer.source=cfgWnd.currentItem.url
                    }

                    delayedAction.start()
                }

            }

            onPositionChanged: {
                parogress.value = mediaPlayer.position
                var totalNum=mediaPlayer.duration
                if(0===mediaPlayer.duration){
                    totalNum=cfgWnd.currentItem.totalNum
                }
                playerTime.text=formatTime(totalNum - mediaPlayer.position)
                updateLyrics(mediaPlayer.position)
            }

            onDurationChanged: parogress.to = mediaPlayer.duration
        }


        ListCtrlPage{
            id:cfgWnd
            anchors.top:parent.top
            anchors.bottom:lastbtn.top
            anchors.margins: 6
            x:appWindow.width
            PropertyAnimation {
                property bool isScale: false
                id: colorAnimation
                target: cfgWnd
                property: "x"
                from: appWindow.width-cfgWnd.pageWidth
                to: appWindow.width
                duration: 150
                running: false
            }
        }
    }
    Timer {
        id: delayedAction
        interval: 1000
        repeat: false
        onTriggered: {
            playMusic()
        }
    }
    function playeAuto(){
        cfgWnd.currentIndex=0;
        mediaPlayer.source=cfgWnd.currentItem.url
        delayedAction.start()
    }

    function playMusic(){
        bkimage.source=cfgWnd.currentItem.imgUrl===""?"qrc:/windows/icon.png":cfgWnd.currentItem.imgUrl
        mediaPlayer.play()
        lyricsModel.clear()
        loadGeci(cfgWnd.currentItem.geci);
    }
    function parseLyrics(lyrics) {
        var lines = lyrics.split("\\r\\n");
        for (var i = 0; i < lines.length; i++) {
            var match = lines[i].match(/\[(\d+):(\d+).(\d+)\](.*)/);
            if (match) {
                var minutes = parseInt(match[1]);
                var seconds = parseInt(match[2]);
                var milliseconds = parseInt(match[3]) * 10;
                var text = match[4].trim();
                var time = minutes * 60000 + seconds * 1000 + milliseconds;
                lyricsModel.append({"time": time, "text": text, "highlight": false});
            }
        }
    }
    function updateLyrics(position) {
        for (var i = 0; i < lyricsModel.count; i++) {
            var item = lyricsModel.get(i);
            if (position >= item.time) {
                if (i > 0) {
                    lyricsModel.setProperty(i - 1, "highlight", false);
                }
                lyricsModel.setProperty(i, "highlight", true);
                lyricsView.positionViewAtIndex(i, ListView.Center);
            }
        }
    }
    function formatTime(milliseconds) {
        var totalSeconds = Math.floor(milliseconds / 1000);
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        var hundredths = Math.floor((milliseconds % 1000) / 10);

        return (minutes < 10 ? "0" + minutes : minutes) + ":"
                + (seconds < 10 ? "0" + seconds : seconds) + "."
                + (hundredths < 10 ? "0" + hundredths : hundredths);
    }
    function loadGeci(geciurl){
        var xhr = new XMLHttpRequest();
        xhr.open("GET", geciurl);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                parseLyrics(xhr.responseText);
            }
        }
        xhr.send();
    }
}
