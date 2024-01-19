#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QCoreApplication>
#include <QUrl>
#include <QDebug>

class FileIO : public QObject
{
    Q_OBJECT
public slots:
    bool write(const QUrl& source, const QString& data)
    {
        qInfo() << "Write out file";
        qInfo() << source;
        qInfo() << data;
        if(source.isEmpty()){
            qDebug() << "Source is Empty!";
            return false;
        }
        QFile file(source.toLocalFile());
        if (!file.open(QFile::WriteOnly | QFile::Truncate)){
            qDebug() << "Problem Opening!";
            return false;
        }
        QTextStream out(&file);
        out << data;
        file.close();
        return true;
    }
    QByteArray read(const QUrl& filename)
    {
        //qInfo() << "Trying to Open:";
        //qInfo() << filename.toLocalFile();
        QFile file(filename.toLocalFile());
        if (!file.open(QIODevice::ReadOnly))
            return QByteArray();
        QByteArray fileContent = file.readAll();
        file.close();

        //qInfo() << "File was opened.";
        return fileContent;
    }
    QVariantMap read_json(const QUrl& filename)
    {
        //qInfo() << "Trying to Open:";
        //qInfo() << filename.toLocalFile();
        QFile file(filename.toLocalFile());
        if (!file.open(QIODevice::ReadOnly))
            return QVariantMap();

        // Read the content of the JSON file
        QByteArray jsonData = file.readAll();

        // Close the file
        file.close();

        // Parse the JSON data into a QJsonDocument
        QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData);

        // Check if the document is valid
        if (jsonDoc.isNull()) {
            qDebug() << "Failed to create JSON document";
            return QVariantMap();
        }

        // Check if the document is an array
        // if (!jsonDoc.isArray()) {
        //     qDebug() << "JSON document is not an array";
        //     return QJsonArray();
        // }


        // Extract the array from the document
        QVariantMap out_array = jsonDoc.object().toVariantMap();
        // qInfo() << out_array.toStdMap();

        return out_array;
    }
    void updateUI(){
        QCoreApplication::processEvents();
    }

public:
    explicit FileIO(QObject *parent = nullptr);

signals:
};

#endif // FILEIO_H
