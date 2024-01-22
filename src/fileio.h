#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QCoreApplication>
#include <QPdfDocument>
#include <QUrl>
#include <QFileInfo>
#include <QDir>
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
    bool create_thumbnail_dir(const QUrl& file_path)
    {
        QFileInfo file_info(file_path.toLocalFile());
        QDir thumb_dir = file_info.absoluteDir();
        return thumb_dir.mkpath(file_info.absolutePath());
    }

    bool does_file_exist(const QUrl& file_path)
    {
        QFileInfo file_info(file_path.toLocalFile());
        return file_info.exists();
    }

    bool create_thumbnail(const QUrl& file_path, const QUrl& thumb_image_path, float thumb_max_size){
        QFileInfo file_info(thumb_image_path.toLocalFile());
        if (!file_info.exists()){
            qDebug() << "Creating Thumbnail: " << thumb_image_path.toLocalFile();
            qDebug() << create_thumbnail_dir(thumb_image_path);
            // QFile file(file_path.toLocalFile());
            // if (!file.open(QFile::WriteOnly | QFile::Truncate)){
            //     qDebug() << "Problem Opening!";
            //     return false;
            // }
            QPdfDocument pdf_document;
            pdf_document.load(file_path.toLocalFile());
            float bigger_size = std::max(pdf_document.pagePointSize(0).width(), pdf_document.pagePointSize(0).height());
            float pdf_image_divider = bigger_size / thumb_max_size;
            QSize pdf_size(pdf_document.pagePointSize(0).width() / pdf_image_divider,
                pdf_document.pagePointSize(0).height() / pdf_image_divider);
            QImage page(pdf_document.render(0, pdf_size));
            page = page.scaledToHeight(thumb_max_size, Qt::TransformationMode::SmoothTransformation);
            page.save(thumb_image_path.toLocalFile());
        }
        else{
            qDebug() << "File already Exists!";
        }
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