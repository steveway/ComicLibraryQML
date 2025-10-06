#!/bin/bash

# Cross-platform build validation script for ComicLibraryQML
# This script helps validate that the project can be built on different platforms

set -e

echo "=== ComicLibraryQML Cross-Platform Validation ==="
echo

# Check if we're on Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Platform: Linux"
    
    # Check for required tools
    echo "Checking dependencies..."
    
    if ! command -v cmake &> /dev/null; then
        echo "❌ CMake not found. Please install cmake."
        exit 1
    fi
    
    if ! command -v make &> /dev/null; then
        echo "❌ Make not found. Please install build-essential."
        exit 1
    fi
    
    # Check for Qt6
    if ! pkg-config --exists Qt6Core; then
        echo "❌ Qt6 not found. Please install Qt6 development packages."
        echo "   On Ubuntu/Debian: sudo apt install qt6-base-dev qt6-declarative-dev libqt6pdf6-dev"
        exit 1
    fi
    
    echo "✅ All dependencies found"
    
    # Test CMake configuration
    echo "Testing CMake configuration..."
    if [ ! -d "build" ]; then
        mkdir build
    fi
    
    cd build
    if cmake ..; then
        echo "✅ CMake configuration successful"
    else
        echo "❌ CMake configuration failed"
        exit 1
    fi
    
    # Test build (only if requested)
    if [[ "$1" == "--build" ]]; then
        echo "Testing build..."
        if make -j$(nproc); then
            echo "✅ Build successful"
        else
            echo "❌ Build failed"
            exit 1
        fi
        
        # Test deployment
        if make deploy; then
            echo "✅ Deployment successful"
        else
            echo "❌ Deployment failed"
            exit 1
        fi
    fi
    
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "Platform: Windows"
    echo "Please run the validation on Windows using PowerShell or CMD with cmake --build ."
    exit 0
else
    echo "❌ Unsupported platform: $OSTYPE"
    exit 1
fi

echo
echo "=== Validation Complete ==="
echo "The project is ready for cross-platform development!"
