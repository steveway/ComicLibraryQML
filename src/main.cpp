// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "app_environment.h"
#include "import_qml_components_plugins.h"
#include "import_qml_plugins.h"
#include "fileio.h"
#include <./singleapplication/singleapplication.h>
// #include "worker.h"
// #include <QThread>

int main(int argc, char *argv[])
{
    set_qt_environment();

    SingleApplication app(argc, argv);
    app.setOrganizationName("Steveway");
    app.setOrganizationDomain("steveway.pythonanywhere.org");
    app.setApplicationName("ComicLibrary");
    FileIO fileIO;
    // Worker cpp;
    // QThread cpp_thread;
    // cpp.moveToThread(&cpp_thread);
    // cpp_thread.start();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("fileio", &fileIO);
    // engine.rootContext()->setContextProperty("cpp", &cpp);
    const QUrl url(u"qrc:/qt/qml/Main/main.qml"_qs);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(":/");

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
