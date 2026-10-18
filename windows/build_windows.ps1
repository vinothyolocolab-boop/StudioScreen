# ==============================================================================
# StudioScreen AI - Windows 1-Click Production Build & Package Script
# ==============================================================================
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\windows\build_windows.ps1
# ==============================================================================

param(
    [string]$QtPath = "",
    [string]$BuildType = "Release"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  StudioScreen AI — Windows Production Packaging Engine   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Resolve Project Root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot
Write-Host "[1/6] Project Root: $ProjectRoot" -ForegroundColor Green

# 2. Detect or Validate Qt Installation
if (-not $QtPath) {
    # Check common Qt 6 locations
    $PossiblePaths = @(
        "C:\Qt\6.8.0\msvc2022_64",
        "C:\Qt\6.7.3\msvc2022_64",
        "C:\Qt\6.7.2\msvc2022_64",
        "C:\Qt\6.7.0\msvc2022_64",
        "C:\Qt\6.8.0\mingw_64",
        "C:\Qt\6.7.3\mingw_64",
        "C:\Qt\6.7.2\mingw_64",
        "C:\Qt\6.6.3\msvc2022_64"
    )
    foreach ($p in $PossiblePaths) {
        if (Test-Path "$p\bin\qmake.exe") {
            $QtPath = $p
            break
        }
    }
}

if (-not $QtPath -or -not (Test-Path "$QtPath\bin\qmake.exe")) {
    Write-Host "ERROR: Could not automatically locate Qt 6." -ForegroundColor Red
    Write-Host "Please specify your Qt installation path using -QtPath, for example:" -ForegroundColor Yellow
    Write-Host "  .\windows\build_windows.ps1 -QtPath 'C:\Qt\6.7.3\msvc2022_64'" -ForegroundColor Yellow
    exit 1
}

Write-Host "[2/6] Using Qt at: $QtPath" -ForegroundColor Green
$Windeployqt = "$QtPath\bin\windeployqt.exe"

# 3. Check for CMake
$CMake = Get-Command "cmake" -ErrorAction SilentlyContinue
if (-not $CMake) {
    Write-Host "ERROR: 'cmake' not found in PATH. Install CMake from https://cmake.org or via winget: winget install Kitware.CMake" -ForegroundColor Red
    exit 1
}

# 4. Configure & Build Release Binary
$BuildDir = "$ProjectRoot\build-windows-release"
Write-Host "[3/6] Configuring CMake in: $BuildDir" -ForegroundColor Green

cmake -B $BuildDir -S $ProjectRoot -DCMAKE_PREFIX_PATH="$QtPath" -DCMAKE_BUILD_TYPE="$BuildType"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[4/6] Compiling StudioScreen ($BuildType)..." -ForegroundColor Green
cmake --build $BuildDir --config $BuildType -j 8
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 5. Create Standalone Distribution Folder
$DistDir = "$ProjectRoot\dist\StudioScreen-Windows-x64"
if (Test-Path $DistDir) {
    Remove-Item -Recurse -Force $DistDir
}
New-Item -ItemType Directory -Path $DistDir | Out-Null

Write-Host "[5/6] Copying executable to $DistDir..." -ForegroundColor Green

# Locate built binary (MSVC places in Release/, MinGW directly in root)
$ExeSource = "$BuildDir\$BuildType\appRecorder_App.exe"
if (-not (Test-Path $ExeSource)) {
    $ExeSource = "$BuildDir\appRecorder_App.exe"
}

if (-not (Test-Path $ExeSource)) {
    Write-Host "ERROR: Compiled executable not found at: $ExeSource" -ForegroundColor Red
    exit 1
}

Copy-Item $ExeSource "$DistDir\StudioScreen.exe"

# Copy Icon
if (Test-Path "$ProjectRoot\windows\app.ico") {
    Copy-Item "$ProjectRoot\windows\app.ico" "$DistDir\app.ico"
}

# 6. Run windeployqt to bundle all required Qt DLLs and QML dependencies
Write-Host "[6/6] Deploying Qt runtime libraries & QML dependencies..." -ForegroundColor Green
& $Windeployqt "$DistDir\StudioScreen.exe" --qmldir "$ProjectRoot\qml" --release --no-translations --compiler-runtime

# Bundle FFmpeg if present in PATH or windows/bin
$FfmpegCmd = Get-Command "ffmpeg.exe" -ErrorAction SilentlyContinue
if ($FfmpegCmd) {
    Write-Host "Bundling FFmpeg ($($FfmpegCmd.Source)) directly into distribution..." -ForegroundColor Cyan
    Copy-Item $FfmpegCmd.Source "$DistDir\ffmpeg.exe"
    $FfprobeCmd = Get-Command "ffprobe.exe" -ErrorAction SilentlyContinue
    if ($FfprobeCmd) {
        Copy-Item $FfprobeCmd.Source "$DistDir\ffprobe.exe"
    }
} elseif (Test-Path "$ProjectRoot\windows\bin\ffmpeg.exe") {
    Write-Host "Bundling local FFmpeg from windows\bin..." -ForegroundColor Cyan
    Copy-Item "$ProjectRoot\windows\bin\ffmpeg.exe" "$DistDir\ffmpeg.exe"
    if (Test-Path "$ProjectRoot\windows\bin\ffprobe.exe") {
        Copy-Item "$ProjectRoot\windows\bin\ffprobe.exe" "$DistDir\ffprobe.exe"
    }
} else {
    Write-Host "NOTE: ffmpeg.exe was not found in PATH or windows\bin." -ForegroundColor Yellow
    Write-Host "You can place ffmpeg.exe into '$DistDir' so end users don't need to install FFmpeg." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  BUILD COMPLETE! Standalone App Ready for Delivery at:   " -ForegroundColor Green
Write-Host "  $DistDir\StudioScreen.exe" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
