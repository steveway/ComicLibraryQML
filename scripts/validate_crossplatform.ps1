# Cross-platform build validation script for ComicLibraryQML - Windows version
# This script helps validate that the project can be built on Windows

Write-Host "=== ComicLibraryQML Cross-Platform Validation ===" -ForegroundColor Green
Write-Host ""

Write-Host "Platform: Windows" -ForegroundColor Yellow

# Check if we're in the right directory
if (-not (Test-Path "CMakeLists.txt")) {
    Write-Host "❌ CMakeLists.txt not found. Please run this script from the project root." -ForegroundColor Red
    exit 1
}

# Check for required tools
Write-Host "Checking dependencies..." -ForegroundColor Cyan

try {
    $cmakeVersion = cmake --version
    if ($cmakeVersion -match "cmake version") {
        Write-Host "✅ CMake found" -ForegroundColor Green
    } else {
        throw "CMake not found"
    }
} catch {
    Write-Host "❌ CMake not found. Please install CMake from https://cmake.org/" -ForegroundColor Red
    exit 1
}

# Check for Visual Studio
try {
    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vsWhere) {
        $vsPath = & $vsWhere -latest -property installationPath
        if ($vsPath) {
            Write-Host "✅ Visual Studio found" -ForegroundColor Green
        } else {
            throw "Visual Studio not found"
        }
    } else {
        throw "Visual Studio not found"
    }
} catch {
    Write-Host "❌ Visual Studio not found. Please install Visual Studio 2019 or later with C++ development tools." -ForegroundColor Red
    exit 1
}

# Check for Qt
if (Test-Path "E:\Qt\6.9.1\msvc2022_64") {
    Write-Host "✅ Qt 6.9.1 found at E:\Qt\6.9.1\msvc2022_64" -ForegroundColor Green
} elseif ($env:Qt6_DIR) {
    Write-Host "✅ Qt found via Qt6_DIR environment variable" -ForegroundColor Green
} elseif ($env:QT_PREFIX_PATH) {
    Write-Host "✅ Qt found via QT_PREFIX_PATH environment variable" -ForegroundColor Green
} else {
    Write-Host "⚠️  Qt not found in default location. Make sure Qt is installed and Qt6_DIR or QT_PREFIX_PATH is set." -ForegroundColor Yellow
}

# Check git submodules
Write-Host "Checking git submodules..." -ForegroundColor Cyan
try {
    git submodule status | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $submoduleStatus = git submodule status
        if ($submoduleStatus -match "^-") {
            Write-Host "❌ Git submodules not initialized. Run: git submodule update --init --recursive" -ForegroundColor Red
            exit 1
        } else {
            Write-Host "✅ Git submodules initialized" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "⚠️  Git not available or not a git repository" -ForegroundColor Yellow
}

# Test CMake configuration
Write-Host "Testing CMake configuration..." -ForegroundColor Cyan
if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

Push-Location "build"
try {
    $cmakeOutput = cmake .. -G "Visual Studio 17 2022" -A x64 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ CMake configuration successful" -ForegroundColor Green
    } else {
        Write-Host "❌ CMake configuration failed" -ForegroundColor Red
        Write-Host $cmakeOutput
        exit 1
    }
} finally {
    Pop-Location
}

# Test build (only if requested)
if ($args -contains "--build") {
    Write-Host "Testing build..." -ForegroundColor Cyan
    Push-Location "build"
    try {
        $buildOutput = cmake --build . --config Release 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Build successful" -ForegroundColor Green
        } else {
            Write-Host "❌ Build failed" -ForegroundColor Red
            Write-Host $buildOutput
            exit 1
        }
        
        # Test deployment
        Write-Host "Testing deployment..." -ForegroundColor Cyan
        $deployOutput = cmake --build . --target deploy 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Deployment successful" -ForegroundColor Green
        } else {
            Write-Host "❌ Deployment failed" -ForegroundColor Red
            Write-Host $deployOutput
            exit 1
        }
    } finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "=== Validation Complete ===" -ForegroundColor Green
Write-Host "The project is ready for cross-platform development!" -ForegroundColor Green

# Show next steps
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Build the project: cmake --build . --config Release" -ForegroundColor White
Write-Host "2. Deploy: cmake --build . --target deploy" -ForegroundColor White
Write-Host "3. Run the application from build/deploy/CLCApp.exe" -ForegroundColor White
