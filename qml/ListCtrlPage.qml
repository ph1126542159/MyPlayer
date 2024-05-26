import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts 2.15
import QtQuick.Dialogs
import QtMultimedia
import ThemeEngine
Rectangle{
    id:cfgWnd
    property int pageWidth: 280
    property alias shValue:shengyingvalue.value
    property alias currentIndex: listView.currentIndex
    property alias currentItem: listView.currentItem
    property int currentSelection: swaitbtn.currentSelection
    property alias modelList: myModel
    width: pageWidth
    color: Theme.colorSuccess
    radius: 4
    border.width: 2
    border.color: Theme.colorHeaderHighlight
    PopupChoice {
        id: selectbet
    }
    FileDialog {
        id: fileDialog
        title: "Open File"
        nameFilters: ["Text Files (*.MP3)"]
        onAccepted: {
            myModel.append({url:fileDialog.selectedFile.toString(),imgUrl:"",name:extractFileName(fileDialog.selectedFile),author:"未知",timesetr:"00:00",totalNum:0,geCi:""})
            if(1===modelList.count){
                playeAuto();
            }
        }
    }
    Connections{
        target: downDtrl
        function onDlowndNewMusic(data){
            var urlStr=data[0]+data[4]+"/"+data[5];
            var imgStr=data[0]+data[4]+"/"+data[7];
            var timesetr=formatTime(parseInt(data[3])*1000)
            var nameStr=data[1]
            var authorStr=data[2]
            var geciStr=data[0]+data[4]+"/"+data[6];
            myModel.append({url:urlStr,imgUrl:imgStr,name:nameStr,author:authorStr,timesetr:timesetr,totalNum:data[3]*1000,geCi:geciStr})
            if(1===modelList.count){
                playeAuto();
            }
        }
    }

    RowLayout {
        id:sbntnsd
        anchors.horizontalCenter: parent.horizontalCenter
        height: 48
        spacing: 16
        Item {
            Layout.preferredWidth:120
            Layout.fillWidth: true
        }
        RoundButtonIcon {
            source: "qrc:/windows/24gf-folderShare.svg"
            highlightMode: "circle"
            tooltipText:qsTr("添加网络文件")
            onClicked:{
                selectbet.open()
            }
        }
        RoundButtonIcon {
            source: "qrc:/windows/24gf-folderPlus.svg"
            highlightMode: "circle"
            tooltipText:qsTr("添加本地文件")
            onClicked:{
                fileDialog.open()
            }
        }
    }
    Item {
        anchors.left:parent.left
        anchors.right: parent.right
        anchors.top:sbntnsd.bottom
        anchors.bottom: spliter3.top
        anchors.margins: 9
        // 表头部分
        RowLayout {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: -4
            Rectangle {
                Layout.fillWidth: parent.width / 4
                height: 40
                color: "lightgray"
                radius: 4
                Text {
                    anchors.centerIn: parent
                    text: "歌名"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                Layout.fillWidth: parent.width / 4
                height: 40
                color: "lightgray"
                Text {
                    anchors.centerIn: parent
                    text: "作者"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                Layout.fillWidth: parent.width / 4
                height: 40
                color: "lightgray"
                radius: 4
                Text {
                    anchors.centerIn: parent
                    text: "时长"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Rectangle {
                Layout.fillWidth: parent.width / 4
                height: 40
                color: "lightgray"
                radius: 4
                Text {
                    anchors.centerIn: parent
                    text: "操作"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // 列表视图部分
        ListView {
            id: listView
            model: myModel
            anchors.left: parent.left
            anchors.right: header.right
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            clip: true
            delegate:Item
            {
                property var url: model.url
                property var imgUrl: model.imgUrl
                property var geci: model.geCi
                property var totalNum: model.totalNum
                width: parent.width
                height: 32
                Rectangle{
                    anchors.fill: parent
                    radius: 4
                    color:listView.currentIndex===index?"lightgray":"transparent"
                    opacity:listView.currentIndex===index?0.38:1.0
                }
                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Text {
                        Layout.fillWidth: parent.width / 4
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: "   "+model.name
                        font.pixelSize: 10
                        elide: Text.ElideMiddle
                    }

                    Text {
                        Layout.fillWidth: parent.width / 4
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: model.author
                        font.pixelSize: 10
                        elide: Text.ElideMiddle
                    }

                    Text {
                        Layout.fillWidth: parent.width / 4
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: model.timesetr
                        font.pixelSize: 10
                        elide: Text.ElideMiddle
                    }
                    ButtonImage {
                        width: 16
                        height: 16
                        source: "qrc:/windows/删除.svg"
                        sourceSize: 16
                    }
                }

            }

        }
    }

    // 模型数据
    ListModel {
        id: myModel
    }
    Rectangle {
        id:spliter3
        y:parent.height*(4/5)
        height: 2
        color: Theme.colorSeparator
        anchors.left: parent.left
        anchors.leftMargin:25
        anchors.right: parent.right
        anchors.rightMargin:25
    }
    SelectorMenuThemed {
        id:swaitbtn
        height: 40
        anchors.top: spliter3.bottom
        anchors.topMargin: 25
        anchors.horizontalCenter: parent.horizontalCenter
        model: ListModel {
            id: lmSelectorMenuImg1
            ListElement { idx: 1; txt:"单曲";src: "qrc:/windows/单曲循环.svg"; sz: 24; }
            ListElement { idx: 2; txt:"随机";src: "qrc:/windows/随机播放.svg"; sz: 24; }
            ListElement { idx: 3; txt:"循环";src: "qrc:/windows/循环播放.svg"; sz: 24; }
        }

        onMenuSelected: (index) => {
                           currentSelection = index
                        }
    }
    ButtonImage{
        id:shengying
        property bool nosound: false
        width: 25
        height: 25
        anchors.top: swaitbtn.bottom
        anchors.topMargin: 25
        anchors.left:parent.left
        anchors.leftMargin: 12
        source: nosound?"qrc:/windows/静音.svg":"qrc:/windows/声音.svg"
        sourceSize: 25
        onClicked:{
            if(nosound){
                shengyingvalue.value=1
            }else{
                shengyingvalue.value=0
            }
            nosound=!nosound
        }
    }
    SliderThemed {
        id:shengyingvalue
        anchors.top: shengying.top
        anchors.topMargin: -6
        anchors.left: shengying.right
        anchors.leftMargin:8
        anchors.right: parent.right
        anchors.rightMargin: 25
        value:1.0
        stepSize: 0.1
    }
    function extractFileName(url) {
        // 使用正则表达式从 URL 中提取文件名
        var pattern = /\/([^\/?#]+)$/i;
        var matches = pattern.exec(url.toString());
        if (matches && matches.length > 1) {
            return matches[1];
        } else {
            return "Unknown"; // 如果无法提取文件名，则返回 "Unknown"
        }
    }
}
