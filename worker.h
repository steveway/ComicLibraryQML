#include <QObject>
#include <QDebug>
#include <QPdfDocument>
#include <QUrl>
#include <QFileInfo>
#include <QDir>
#include <QTimer>
#include <QCoreApplication>

class Worker : public QObject {
    Q_OBJECT


public:

    explicit Worker(QObject* parent = nullptr): QObject(parent){
        timer.setInterval(100);
        connect(&timer, &QTimer::timeout, [=]() {
            QCoreApplication::processEvents();
        });
    }
    ~Worker(){}

    Q_INVOKABLE void doSomeWork() { // modify this to accommodate your params
        //do something here
        timer.setSingleShot(true);
        timer.start();
    }

    Q_INVOKABLE void create_thumbnail(const QUrl& file_path_temp, const QUrl& thumb_image_path_temp, float thumb_max_size_temp){
        file_path = file_path_temp;
        thumb_image_path = thumb_image_path_temp;
        thumb_max_size = thumb_max_size_temp;
        timer.start();
        QFileInfo file_info(thumb_image_path.toLocalFile());
        if (!file_info.exists()){
            qDebug() << "Creating Thumbnail: " << thumb_image_path.toLocalFile();
            QFileInfo file_info(file_path.toLocalFile());
            QDir thumb_dir = file_info.absoluteDir();
            thumb_dir.mkpath(file_info.absolutePath());
            // qDebug() << create_thumbnail_dir(thumb_image_path);
            // QFile file(file_path.toLocalFile());
            // if (!file.open(QFile::WriteOnly | QFile::Truncate)){
            //     qDebug() << "Problem Opening!";
            //     return false;
            // }
            QPdfDocument pdf_document;
            //updateUI();
            pdf_document.load(file_path.toLocalFile());
            //updateUI();
            float bigger_size = std::max(pdf_document.pagePointSize(0).width(), pdf_document.pagePointSize(0).height());
            float pdf_image_divider = bigger_size / thumb_max_size;
            QSize pdf_size(pdf_document.pagePointSize(0).width() / pdf_image_divider,
                           pdf_document.pagePointSize(0).height() / pdf_image_divider);
            //updateUI();
            QImage page(pdf_document.render(0, pdf_size));
            //updateUI();
            page = page.scaledToHeight(thumb_max_size, Qt::TransformationMode::SmoothTransformation);
            //updateUI();
            page.save(thumb_image_path.toLocalFile());
        }
        else{
            qDebug() << "File already Exists!";
        }

        //return true;
    }

private:
    QTimer timer;
    QUrl file_path;
    QUrl thumb_image_path;
    float thumb_max_size;

};
