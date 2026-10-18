# StudioScreen AI — Windows Delivery & Packaging Guide

This guide details how to build, package, and distribute **StudioScreen AI** as a standalone, production-ready desktop application for **Windows 10 and 11 (64-bit)**.

---

## 🚀 1-Click Automated Build & Packaging

We have included automated packaging scripts that build the binary, bundle all Qt runtime libraries and QML plugins, bundle FFmpeg, and produce a ready-to-deliver standalone folder.

### Prerequisites (Installed once on the build PC):
1. **Qt 6.7+ (MSVC 2022 or MinGW 64-bit)**:
   - Install via the [Qt Online Installer](https://www.qt.io/download-qt-installer).
   - Ensure `Qt Quick`, `Qt Multimedia`, `Qt Network`, and `Qt Svg` modules are checked.
2. **CMake 3.16+**:
   - `winget install Kitware.CMake`
3. **FFmpeg**:
   - `winget install Gyan.FFmpeg`
4. **Visual Studio 2022 C++ Build Tools** (or MinGW).

---

### Run 1-Click Packager:
Open PowerShell in the project directory and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\build_windows.ps1
```
*(Or simply double-click `windows\package_windows.bat`).*

### What this produces:
A 100% self-contained folder at:
```
dist\StudioScreen-Windows-x64\
  ├── StudioScreen.exe           (Main application with embedded icon & version metadata)
  ├── ffmpeg.exe                 (Bundled screen capture & export engine)
  ├── ffprobe.exe                (Media inspector)
  ├── app.ico                    (High-resolution multi-size branded icon)
  ├── Qt6Core.dll, Qt6Quick.dll  (All required Qt DLLs via windeployqt)
  └── qml\                       (Bundled QML runtime modules)
```
**This folder can be zipped and delivered directly to any end-user!** It runs immediately on any Windows machine without requiring them to install Qt or compilers.

---

## 📦 Creating an Installer (.exe Setup Wizard)

To create a single setup file (`StudioScreen_Setup_v1.0.exe`) with desktop shortcuts and uninstaller:
1. Install [Inno Setup 6](https://jrsoftware.org/isdl.php).
2. Right-click [`windows\installer_inno.iss`](file:///home/vinoth/Recorder_App/windows/installer_inno.iss) and select **Compile**.
3. Your installer will be generated in `dist\StudioScreen_Setup_v1.0.exe`.

---

## ⌨️ Windows Global Hotkeys
The app includes native Windows background hotkeys via `RegisterHotKey`:
- **`Ctrl + Shift + R`**: Toggle Record / Stop from ANY window.
- **`Ctrl + Shift + P`**: Toggle Pause / Resume.

---

## 🖥️ Screen & Audio Recording Architecture on Windows
- **Display Capture**: Uses Windows GDI capture (`-f gdigrab -i desktop`) with multi-monitor offset calculations, fully supporting multi-display setups.
- **GPU Acceleration**: Automatically probes and leverages NVIDIA NVENC (`h264_nvenc`) when an NVIDIA GPU is present.
- **Audio Recording**: Captures internal PC sound via **WASAPI loopback** (`-f wasapi -i default`) and microphone input via **DirectShow** (`-f dshow -i audio="Microphone"`).
- **Fast Startup**: Zero-delay recording with fast moov atom packing (`+faststart`) for instant web playback and sharing.
