# ComicLibraryQML
![Program Icon, currently the same as for Peruse](/content/peruse.ico)

ComicLibraryQML is a lightweight program designed for reading comics efficiently, with minimal RAM and storage space requirements. It is built using the QT/QML framework and C++, making it fast and resource-efficient.

## Features

- **Thumbnail Generation:** Automatically generates thumbnails for each comic in your library, enhancing the browsing experience.
- **Bookmarking:** Automatically saves the last opened comic and the page where you left off, allowing you to resume reading from where you stopped.
- **Comic Information Management:** Stores comic metadata, including the number of pages and reading progress, in JSON format for easy retrieval and management.
- **Low Resource Usage:** Designed to consume minimal RAM and storage space, ensuring smooth performance even on low-spec devices.

## Usage

1. **Select Comic Folder:** Choose the folder containing your comic collection within the program.
2. **Thumbnail Generation:** The program will automatically generate thumbnails for comics in the selected folder if they haven't been created yet.
3. **Thumbnail View:** Browse through your comics using the thumbnail view, which displays the contents of the selected folder.
4. **Comic Selection:** Click on a thumbnail to select a comic for reading.
5. **Bookmarking:** The program automatically saves your progress for each comic, allowing you to resume reading from where you left off.

## Requirements

- QT framework
- C++ compiler
- Minimal RAM and storage space

## Installation

1. **Clone the Repository:**

>git clone https://github.com/steveway/ComicLibraryQML.git

2. **Navigate to the Project Directory:**

>cd ComicLibraryQML

3. **Build the Program using CMake:**

>mkdir build
>
>cd build
>
>cmake ..
>
>make

This will configure the project using CMake and then build the program using the generated makefiles.

4. **Run the Executable:**

>./ComicLibraryQML

Once the build process is complete, you can run the executable file to launch the ComicLibraryQML program.

## Contributing

Contributions to Comic Library Reader are welcome!

## License

This project is licensed under the GNU General Public License version 2 or later (GPL-2.0+).

## Support

For any questions or issues, please [open an issue](https://github.com/steveway/ComicLibraryQML/issues) on GitHub.

