#include "downloaderCtrl.h"
#include <atomic>
#include <QQueue>
#include <mutex>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QEventLoop>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>
#include <QDebug>
bool downloadFile(const QString &urlStr, QByteArray& bt) {
    QNetworkAccessManager manager;
    QUrl url(urlStr);
    QUrl encodedUrl = QUrl::fromEncoded(url.toEncoded());
    qDebug() << "Encoded URL:" <<encodedUrl;
    QNetworkRequest request(encodedUrl);

    QNetworkReply *reply = manager.get(request);

    // 使用事件循环来阻塞直到下载完成
    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    // 检查下载是否成功
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Error:" << reply->errorString();
        reply->deleteLater();
        return false;
    }

    bt.clear();
    bt=reply->readAll();
    reply->deleteLater();
    return true;
}
QJsonObject byteArrayToJsonObject(const QByteArray &byteArray) {
    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(byteArray, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "Failed to parse JSON:" << parseError.errorString();
        return QJsonObject();
    }

    if (!jsonDoc.isObject()) {
        qWarning() << "JSON is not an object.";
        return QJsonObject();
    }

    return jsonDoc.object();
}
struct DownLoaderHttpThread::DownLoaderHttpThreadPrivate{
    std::atomic_bool _stop{false};
    QQueue<QStringList> _listDown;
    std::mutex _mtx;
};
DownLoaderHttpThread::DownLoaderHttpThread(QObject *parent)
{
    _ptrivate=new DownLoaderHttpThreadPrivate();
}

void DownLoaderHttpThread::append(const QStringList &header)
{
    std::unique_lock<std::mutex> lock(_ptrivate->_mtx);
    _ptrivate->_listDown.enqueue(header);
}

void DownLoaderHttpThread::run()
{
    while (!_ptrivate->_stop) {
        QThread::msleep(100);
        QStringList strHeader;
        {
            std::unique_lock<std::mutex> lock(_ptrivate->_mtx);
            if(!_ptrivate->_listDown.isEmpty()){
                strHeader=_ptrivate->_listDown.takeFirst();
            }
        }

        if(strHeader.isEmpty()){
            QThread::msleep(1000);
            continue;
        }
        QByteArray bt;
        downloadFile(strHeader[0]+"/"+strHeader[1]+"/music.json",bt);
        QJsonObject listObj=byteArrayToJsonObject(bt);
        if(listObj.isEmpty()) continue;

        QJsonArray arr=listObj["list"].toArray();

        foreach(auto& it,arr){

            QStringList listStr;
            QString ciStr;

            QJsonObject obj=it.toObject();
            listStr<<strHeader[0];
            listStr<<obj["musicName"].toString();
            listStr<<obj["albumName"].toString();
            listStr<<QString::number(obj["duration"].toInt());
            listStr<<obj["path"].toString();
            listStr<<obj["mp3"].toString();
            listStr<<obj["lyric"].toString();
            listStr<<obj["img"].toString();


            // ciStr=strHeader[0]+obj["path"].toString()+"/"+obj["lyric"].toString();

            // if(downloadFile(ciStr,bt)){
            //     QString temp = QString(bt).replace("\\r\\n","^");
            //     listStr<<temp;

            // }

            Q_EMIT dlowndNewMusic(listStr);
        }


    }
}

struct DownLoaderCtrl::DownLoaderCtrlPrivate
{
    DownLoaderHttpThread _thread;
};


DownLoaderCtrl::DownLoaderCtrl(QObject *parent)
{
    _ptrPrivate=new DownLoaderCtrlPrivate();
    QObject::connect(&_ptrPrivate->_thread,&DownLoaderHttpThread::dlowndNewMusic,this,&DownLoaderCtrl::dlowndNewMusic);
    _ptrPrivate->_thread.start();
}

void DownLoaderCtrl::addpendNew(const QString &header1, const QString &header2)
{
    QStringList list;
    list<<header1;
    list<<header2;
    _ptrPrivate->_thread.append(list);
}
