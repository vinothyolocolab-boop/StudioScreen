@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo   StudioScreen AI - Windows 1-Click Packager
echo ============================================================

cd /d "%~dp0.."

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_windows.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Build failed with exit code %ERRORLEVEL%.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Packaging completed successfully!
pause
