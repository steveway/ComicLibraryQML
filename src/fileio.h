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
#include <QTimer>
#include <QtWidgets/qgraphicseffect.h>
#include <QtWidgets/QGraphicsScene>
#include <QtWidgets/QGraphicsPixmapItem>
#include <QtGui/QPainter>
#include <QThread>
#include <QtConcurrent>
#include <QFuture>
#include <QFutureWatcher>

class FileIO : public QObject
{
    Q_OBJECT
public slots:
    bool write(const QUrl& source, const QString& data)
    {
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
    };

    QImage applyEffectToPics(QImage src, QGraphicsEffect *effect, int extent = 0)
    {
        if(src.isNull()) return QImage();   //No need to do anything else!
        if(!effect) return src;             //No need to do anything else!
        QGraphicsScene scene;
        QGraphicsPixmapItem item;
        item.setPixmap(QPixmap::fromImage(src));
        item.setGraphicsEffect(effect);
        scene.addItem(&item);
        QImage res(src.size()+QSize(extent*2, extent*2), QImage::Format_ARGB32);
        res.fill(Qt::transparent);
        QPainter ptr(&res);
        scene.render(&ptr, QRectF(), QRectF( -extent, -extent, src.width()+extent*2, src.height()+extent*2 ) );
        return res;
    }

    void create_thumbnail(const QUrl& file_path, const QUrl& thumb_image_path, float thumb_max_size){
        // Run thumbnail generation in a separate thread
        QtConcurrent::run([=]() {
            QFileInfo file_info(thumb_image_path.toLocalFile());
            qDebug() << "Creating Thumbnail (async): " << thumb_image_path.toLocalFile();
            create_thumbnail_dir(thumb_image_path);
            
            QPdfDocument pdf_document;
            pdf_document.load(file_path.toLocalFile());
            
            float bigger_size = std::max(pdf_document.pagePointSize(0).width(), pdf_document.pagePointSize(0).height());
            float pdf_image_divider = bigger_size / thumb_max_size;
            QSize pdf_size(pdf_document.pagePointSize(0).width() / pdf_image_divider,
                           pdf_document.pagePointSize(0).height() / pdf_image_divider);
            
            QImage page(pdf_document.render(0, pdf_size));
            
            // Simple drop shadow without QGraphicsEffect (thread-safe)
            QImage result = addSimpleShadow(page, 10);
            
            result = result.scaledToHeight(thumb_max_size, Qt::TransformationMode::SmoothTransformation);
            
            // Save to temporary file first, then rename atomically
            QString tempPath = thumb_image_path.toLocalFile() + ".tmp";
            QString finalPath = thumb_image_path.toLocalFile();
            
            if (result.save(tempPath, "PNG")) {
                // Atomic rename to avoid partial reads
                QFile::remove(finalPath);  // Remove old file if exists
                QFile::rename(tempPath, finalPath);
                emit thumbnailCreated(thumb_image_path);
            } else {
                qDebug() << "Failed to save thumbnail:" << tempPath;
                QFile::remove(tempPath);  // Clean up failed temp file
            }
        });
    }
    
    // Thread-safe shadow implementation with better blur
    QImage addSimpleShadow(const QImage& src, int shadowSize) {
        if(src.isNull()) return QImage();
        
        int margin = shadowSize * 2;
        QImage result(src.width() + margin, src.height() + margin, QImage::Format_ARGB32);
        result.fill(Qt::transparent);
        
        // Create shadow layer
        QImage shadow(src.size(), QImage::Format_ARGB32);
        shadow.fill(QColor(0, 0, 0, 100)); // Semi-transparent black
        
        // Apply simple box blur to shadow
        QImage blurred = boxBlur(shadow, shadowSize / 2);
        
        QPainter painter(&result);
        painter.setRenderHint(QPainter::Antialiasing);
        painter.setRenderHint(QPainter::SmoothPixmapTransform);
        
        // Draw blurred shadow with offset
        painter.drawImage(shadowSize + 3, shadowSize + 3, blurred);
        
        // Draw original image on top
        painter.drawImage(shadowSize, shadowSize, src);
        
        return result;
    }
    
    // Simple box blur for shadow effect
    QImage boxBlur(const QImage& src, int radius) {
        if(radius < 1) return src;
        
        QImage result = src;
        int w = src.width();
        int h = src.height();
        
        // Horizontal pass
        for(int y = 0; y < h; y++) {
            for(int x = 0; x < w; x++) {
                int r = 0, g = 0, b = 0, a = 0, count = 0;
                for(int dx = -radius; dx <= radius; dx++) {
                    int nx = qBound(0, x + dx, w - 1);
                    QRgb pixel = src.pixel(nx, y);
                    r += qRed(pixel);
                    g += qGreen(pixel);
                    b += qBlue(pixel);
                    a += qAlpha(pixel);
                    count++;
                }
                result.setPixel(x, y, qRgba(r/count, g/count, b/count, a/count));
            }
        }
        
        // Vertical pass
        QImage final = result;
        for(int x = 0; x < w; x++) {
            for(int y = 0; y < h; y++) {
                int r = 0, g = 0, b = 0, a = 0, count = 0;
                for(int dy = -radius; dy <= radius; dy++) {
                    int ny = qBound(0, y + dy, h - 1);
                    QRgb pixel = result.pixel(x, ny);
                    r += qRed(pixel);
                    g += qGreen(pixel);
                    b += qBlue(pixel);
                    a += qAlpha(pixel);
                    count++;
                }
                final.setPixel(x, y, qRgba(r/count, g/count, b/count, a/count));
            }
        }
        
        return final;
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
    void delay(int delay_in_ms){
        QThread::msleep(delay_in_ms);
    }


public:
    explicit FileIO(QObject *parent = nullptr);

signals:
    void thumbnailCreated(const QUrl& thumb_image_path);
};

#endif // FILEIO_H
