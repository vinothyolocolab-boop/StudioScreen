param(
    [string]$QtPath = "",
    [string]$BuildType = "Release"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  StudioScreen AI - Windows Production Packaging Engine   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot
Write-Host "[1/6] Project Root: $ProjectRoot" -ForegroundColor Green

if (-not $QtPath -and $env:QT_ROOT -and (Test-Path "$env:QT_ROOT\bin\qmake.exe")) {
    $QtPath = $env:QT_ROOT
}
if (-not $QtPath -and $env:Qt6_DIR -and (Test-Path "$env:Qt6_DIR\bin\qmake.exe")) {
    $QtPath = $env:Qt6_DIR
}

if (-not $QtPath) {
    $PossiblePaths = @(
        "C:\Qt\6.8.0\msvc2022_64",
        "C:\Qt\6.7.3\msvc2022_64",
        "C:\Qt\6.7.2\msvc2022_64",
        "C:\Qt\6.7.2\msvc2019_64",
        "C:\Qt\6.7.0\msvc2022_64",
        "C:\Qt\6.8.0\mingw_64",
        "C:\Qt\6.7.3\mingw_64",
        "C:\Qt\6.7.2\mingw_64",
        "C:\Qt\6.6.3\msvc2022_64",
        "D:\a\StudioScreen\Qt\6.7.2\msvc2019_64"
    )
    foreach ($p in $PossiblePaths) {
        if (Test-Path "$p\bin\qmake.exe") {
            $QtPath = $p
            break
        }
    }
}

if (-not $QtPath -or -not (Test-Path "$QtPath\bin\qmake.exe")) {
    Write-Host "ERROR: Could not locate Qt 6 installation." -ForegroundColor Red
    exit 1
}

Write-Host "[2/6] Using Qt at: $QtPath" -ForegroundColor Green
$Windeployqt = "$QtPath\bin\windeployqt.exe"

$BuildDir = "$ProjectRoot\build-windows-release"
Write-Host "[3/6] Configuring CMake in: $BuildDir" -ForegroundColor Green

cmake -B $BuildDir -S $ProjectRoot -DCMAKE_PREFIX_PATH="$QtPath" -DCMAKE_BUILD_TYPE="$BuildType"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[4/6] Compiling StudioScreen in $BuildType mode..." -ForegroundColor Green
cmake --build $BuildDir --config $BuildType -j 8
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$DistDir = "$ProjectRoot\dist\StudioScreen-Windows-x64"
if (Test-Path $DistDir) {
    Remove-Item -Recurse -Force $DistDir
}
New-Item -ItemType Directory -Path $DistDir | Out-Null

Write-Host "[5/6] Copying executable to $DistDir..." -ForegroundColor Green

$ExeSource = "$BuildDir\$BuildType\appRecorder_App.exe"
if (-not (Test-Path $ExeSource)) {
    $ExeSource = "$BuildDir\appRecorder_App.exe"
}

if (-not (Test-Path $ExeSource)) {
    Write-Host "ERROR: Compiled executable not found at: $ExeSource" -ForegroundColor Red
    exit 1
}

Copy-Item $ExeSource "$DistDir\StudioScreen.exe"

if (Test-Path "$ProjectRoot\windows\app.ico") {
    Copy-Item "$ProjectRoot\windows\app.ico" "$DistDir\app.ico"
}

Write-Host "[6/6] Deploying Qt runtime libraries and QML dependencies..." -ForegroundColor Green
& "$Windeployqt" "$DistDir\StudioScreen.exe" --qmldir "$ProjectRoot\qml" --release --no-translations --compiler-runtime

$FfmpegCmd = Get-Command "ffmpeg.exe" -ErrorAction SilentlyContinue
if ($FfmpegCmd) {
    Write-Host "Bundling FFmpeg directly into distribution..." -ForegroundColor Cyan
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
}

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  BUILD COMPLETE! Standalone folder ready in: $DistDir" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
