import QtQuick
import QtQuick.Controls

import ThemeEngine

Popup {
    id: popupChoice

    x: singleColumn ? 0 : (appWindow.width / 2) - (width / 2)
    y: singleColumn ? (appWindow.height - height)
                    : ((appWindow.height / 2) - (height / 2))

    width: singleColumn ? appWindow.width : 640
    height: columnContent.height + padding*2 + screenPaddingNavbar + screenPaddingBottom
    padding: Theme.componentMarginXL

    dim: true
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    signal confirmed()

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: singleColumn ? 0 : Theme.componentBorderWidth
        radius: singleColumn ? 0 : Theme.componentRadius

        Rectangle {
            width: parent.width
            height: Theme.componentBorderWidth
            visible: singleColumn
            color: Theme.colorSeparator
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        width: parent.width
        Column {
            id: columnContent
            width: parent.width
            spacing: Theme.componentMarginXL

            ////////

            Text {
                width: parent.width

                text: qsTr("从网络下载文件?")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }
            AndroidTextField {
                id:downHeader1
                width: parent.width
                title: "下载地址头部"
                text: "https://gitee.com/MarkYangUp/music/raw/master"
                placeholderText: "http前缀"
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
                height:140
            }
            ////////
            AndroidTextField {
                id:downHeader2
                width: parent.width
                title: "下载地址头部"
                text: "风雨无阻"
                placeholderText: "子集"
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
                height:60
            }

            ////////

            Row {
                width: parent.width
                spacing: Theme.componentMargin
                property var btnSize: singleColumn ? width : ((width-spacing*2) / 3)

                Item{
                    width: parent.btnSize
                    height: 40
                }

                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("Cancel")
                    primaryColor: Theme.colorSubText
                    secondaryColor: Theme.colorForeground

                    onClicked: popupChoice.close()
                }

                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("OK")
                    primaryColor: Theme.colorSuccess
                    fullColor: true

                    onClicked: {
                        if(downHeader1.text===""||downHeader2.text==="") return;
                        downDtrl.addpendNew(downHeader1.text,downHeader2.text)
                        popupChoice.close()
                    }
                }

            }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
