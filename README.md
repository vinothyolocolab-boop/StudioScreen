# StudioScreen AI — Screen Studio for Windows, Linux, macOS & Android

> **Next-generation cross-platform screen recording and AI video customization studio inspired by Screen Studio & OpenScreen 2.**

Built with **Qt 6 (C++ & QML)**, hardware-accelerated rendering, real-time cursor telemetry, dual-audio loopback capture, and **Supabase** cloud authentication, database, and instant storage sharing.

---

## ✨ Features

### 1. High-Performance Screen Capture (Zero Lag)
- Multi-threaded capture engine (60 FPS, ultra-low latency, 1080p/4K).
- Multi-display enumeration and selection.
- Fullscreen, custom region, and countdown timer (3-2-1-GO!).
- Extremely lightweight (native C++ binary: ~1.8 MB vs 250 MB+ Electron alternatives).

### 2. Dual-Track Audio Capture
- **Microphone recording**: Input device selection, live VU meters, volume gain, mute toggle.
- **Computer System Audio (Desktop Loopback)**:
  - **Windows (Priority 1)**: Native WASAPI loopback (`AUDCLNT_STREAMFLAGS_LOOPBACK`).
  - **Linux**: PulseAudio / PipeWire `.monitor` capture.
  - **macOS**: CoreAudio / ScreenCaptureKit audio.
  - **Android**: AudioRecord / MediaProjection loopback.

### 3. Screen Studio Visual Aesthetics & Dynamic Zooms
- **Seamless Auto-Zoom**:
  - Automatically identifies mouse clicks and dwell points.
  - Smooth camera panning with cubic Hermite easing (`InOutCubic`).
  - Adjustable zoom depth (1.2x – 2.8x) and ease durations.
  - Multi-track timeline markers for tweaking, trimming, or adding zooms.
- **Custom Cursor Engine**:
  - 60Hz telemetry tracking saved to `.cursor.json`.
  - Scalable cursor sizes (1.0x to 3.0x).
  - Styles: macOS Black Pointer, Modern Violet Glow, Cyber Neon Cyan, Highlight Circle Halo.
  - Expanding click ripple pulse rings with customizable colors.
- **Backdrop Canvas & Window Framing**:
  - Inset canvas padding slider (0 – 160px).
  - Anti-aliased window corner rounding (0 – 48px).
  - Multi-layer blurred drop shadows.
  - Presets: Sonoma, Sunset Glow, Midnight, Cyberpunk, Aurora Borealis, Dark Slate.
  - Multiple aspect ratios: 16:9 (Desktop/YouTube), 9:16 (Shorts/TikTok/Reels), 1:1 (Square), 4:3.

### 4. AI Video Customization (In-App)
- **AI One-Click Auto-Frame**: Intelligently plans cinematic zooms around user interactions.
- **AI Speech-to-Text & Captions**: Transcribes speech with word-level highlight timings (modern animated Hormozi/Reels style).
- **AI Dead-Air & Silence Trimmer**: Automatically flags long pauses (>1.0s) for instant trimming.
- **AI Prompt-to-Edit**: Type natural language commands like:
  - `"Create a vertical 9:16 reel with sunset background and animated captions"`
  - `"Zoom in 2.2x on all button clicks with cyber neon cursor"`

### 5. Supabase Cloud Integration & Instant Sharing
- **Authentication**: Sign up, Sign in, token persistence via `QSettings`.
- **Cloud Storage**: Direct upload of rendered recordings to Supabase Storage bucket (`recordings`) with real-time progress.
- **Database Metadata**: Synchronizes title, duration, aspect ratio, public URL, and thumbnail in PostgreSQL.
- **Instant Sharing**: One-click public link generation with instant clipboard copy and QR code.
- **One-Click Demo Mode**: Works out-of-the-box for testing even before entering Supabase credentials!
- **Includes SQL Schema**: Pre-built [`supabase_schema.sql`](file:///home/vinoth/Recorder_App/supabase_schema.sql) for 1-click database & storage configuration.

---

## 🚀 Building the Application

### 🪟 Windows (Priority 1)

#### Prerequisites
1. **Qt 6.5+** (e.g. Qt 6.7 or 6.8) with MinGW or MSVC 2019/2022.
2. **CMake 3.16+** and **Ninja** (or Visual Studio).
3. **FFmpeg** on `PATH`.

#### Build Commands (PowerShell / Command Prompt)
```powershell
# Configure
cmake -B build -S . -DCMAKE_PREFIX_PATH="C:/Qt/6.7.3/msvc2019_64"

# Compile Release binary
cmake --build build --config Release

# Deploy Qt dependencies and QML modules
windeployqt build/Release/appRecorder_App.exe --qmldir qml
```
Run `build/Release/appRecorder_App.exe`.

---

### 🐧 Linux (Ubuntu / Debian / Fedora)

#### Prerequisites
```bash
sudo apt install cmake ninja-build build-essential libgl1-mesa-dev ffmpeg
```

#### Build Commands
```bash
cmake -B build -S . -DCMAKE_PREFIX_PATH="/home/vinoth/Qt/6.7.3/gcc_64"
cmake --build build
```
Run `./build/appRecorder_App`.

---

### 🍏 macOS

#### Build Commands
```bash
cmake -B build -S . -DCMAKE_PREFIX_PATH="$(brew --prefix qt@6)"
cmake --build build
macdeployqt build/appRecorder_App.app -qmldir=qml
```

---

### 📱 Android

Qt 6 supports compiling this exact QML and C++ architecture to Android APKs using the installed Android kit (`android_arm64_v8a` / `android_x86_64`):
```bash
cmake -B build-android -S . \
  -DCMAKE_TOOLCHAIN_FILE="/home/vinoth/Qt/6.7.3/android_arm64_v8a/lib/cmake/Qt6/qt.toolchain.cmake" \
  -DANDROID_SDK_ROOT="/path/to/android-sdk" \
  -DANDROID_NDK_ROOT="/path/to/android-ndk"
cmake --build build-android --target apk
```

---

## 🗄️ Supabase Cloud Configuration

1. Create a free project at [supabase.com](https://supabase.com).
2. Open the **SQL Editor** in your Supabase dashboard.
3. Open [`supabase_schema.sql`](file:///home/vinoth/Recorder_App/supabase_schema.sql) in this repository and run it.
4. In StudioScreen AI, click **⚙️ Settings** in the top navigation bar:
   - Enter your **Project URL** (e.g. `https://xyzcompany.supabase.co`)
   - Enter your **Anon Key**
   - Click **Save Settings**
5. All future recordings can now be instantly shared to the cloud with one click!
