cmake_minimum_required(VERSION 3.21.1)

option(LINK_INSIGHT "Link Qt Insight Tracker library" ON)
option(BUILD_QDS_COMPONENTS "Build design studio components" ON)

project(CLCApp LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

# Find Qt6 - let CMake find it automatically on most systems
# Only set CMAKE_PREFIX_PATH if explicitly provided
if(DEFINED ENV{Qt6_DIR})
    set(CMAKE_PREFIX_PATH $ENV{Qt6_DIR})
elseif(DEFINED ENV{QT_PREFIX_PATH})
    set(CMAKE_PREFIX_PATH $ENV{QT_PREFIX_PATH})
endif()

find_package(Qt6 6.9.1 REQUIRED COMPONENTS Core Gui Qml Quick Pdf Widgets Concurrent)

if (Qt6_VERSION VERSION_GREATER_EQUAL 6.3)
    qt_standard_project_setup()
endif()

# Platform-specific source files
set(PLATFORM_SOURCES)
set(PLATFORM_HEADERS)

if(WIN32)
    list(APPEND PLATFORM_SOURCES content/myapp.rc)
    list(APPEND PLATFORM_HEADERS content/peruse.ico)
endif()

qt_add_executable(CLCApp src/main.cpp
    src/fileio.h src/fileio.cpp
    ${PLATFORM_SOURCES}
    ${PLATFORM_HEADERS}
    worker.h)

qt_add_resources(CLCApp "configuration"
    PREFIX "/"
    FILES
        qtquickcontrols2.conf
)

set(QAPPLICATION_CLASS QApplication CACHE STRING "Inheritance class for SingleApplication")
add_subdirectory(./singleapplication/)

target_link_libraries(CLCApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Pdf
    Qt6::Widgets
    Qt6::Concurrent
    SingleApplication::SingleApplication
)

set_source_files_properties(AppSettings.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

if (BUILD_QDS_COMPONENTS)
    include(${CMAKE_CURRENT_SOURCE_DIR}/qmlcomponents)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/qmlmodules)

if (LINK_INSIGHT)
    include(${CMAKE_CURRENT_SOURCE_DIR}/insight)
endif ()

include(GNUInstallDirs)
install(TARGETS CLCApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# make IDEs aware of the QML import path
set(QML_IMPORT_PATH ${PROJECT_BINARY_DIR}/qml CACHE PATH
    "Path to the custom QML components defined by the project")

# Automatic deployment of Qt dependencies
if(WIN32)
    # Deploy Qt dependencies automatically for Windows
    if(CMAKE_PREFIX_PATH)
        set(Qt6_DIR "${CMAKE_PREFIX_PATH}/lib/cmake/Qt6")
        find_package(Qt6 COMPONENTS CoreTools REQUIRED)
        
        # Add deployment target
        add_custom_target(deploy
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/deploy
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:CLCApp>
                ${CMAKE_BINARY_DIR}/deploy/
            COMMAND ${CMAKE_PREFIX_PATH}/bin/windeployqt.exe --qmldir ${CMAKE_SOURCE_DIR}
                ${CMAKE_BINARY_DIR}/deploy/$<TARGET_FILE_NAME:CLCApp>
            COMMENT "Deploying Qt dependencies..."
            VERBATIM
        )
        
        # Make deploy depend on the main executable
        add_dependencies(deploy CLCApp)
    endif()
elseif(UNIX AND NOT APPLE)
    # Deploy Qt dependencies automatically for Linux
    add_custom_target(deploy
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/deploy
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:CLCApp>
            ${CMAKE_BINARY_DIR}/deploy/
        COMMAND ${CMAKE_COMMAND} -E create_symlink
            $<TARGET_FILE:CLCApp>
            ${CMAKE_BINARY_DIR}/deploy/ComicLibraryQML
        COMMENT "Creating Linux deployment package..."
        VERBATIM
    )
    
    # Make deploy depend on the main executable
    add_dependencies(deploy CLCApp)
endif()
