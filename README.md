# OneVoice - Real-time System Audio Transcription

OneVoice captures and transcribes system audio in real-time using Whisper models. It now supports both terminal output and a beautiful floating GUI window for macOS.

## Features

### 🪟 Floating Window GUI (New!)

- **Always-on-top floating window** that stays visible over other applications
- **Semi-transparent design** with adjustable opacity
- **Real-time transcription display** with timestamps
- **Modern dark theme** optimized for macOS
- **Resizable and draggable** window positioned at top-right by default
- **Auto-scrolling** to show latest transcriptions
- **Clear button** to reset transcription history
- **Toggle always-on-top** functionality

### 🎙️ Audio Processing

- **Multiple Whisper models** (tiny, base, small, medium) for different accuracy/speed needs
- **English-only optimized models** for better performance
- **BlackHole 2ch support** for system audio capture
- **Microphone input support** for voice transcription
- **Real-time processing** with configurable timing parameters

## Installation

### Prerequisites

1. **Whisper.cpp** - Install via Homebrew:

   ```bash
   brew install whisper-cpp
   ```

2. **BlackHole 2ch** (Optional, for system audio):

   - Download from [BlackHole website](https://existential.audio/blackhole/)
   - Install and configure as system audio output

3. **Python 3** (comes with macOS)

### Setup

1. Clone or download this repository
2. The required Whisper models will be automatically downloaded on first use

## Usage

### Option 1: Main Script (Recommended)

```bash
./run.sh
```

Choose option 1 for floating GUI window when prompted.

### Option 2: Terminal Output Only

Choose option 2 for terminal output when prompted.

**Script Options:**

- Select your preferred Whisper model (1-4)
- Choose audio input device
- Pick display mode: **1** for floating GUI window, **2** for terminal output

### Option 3: GUI Only (for testing)

```bash
echo "Test transcription" | python3 onevoice_gui.py
```

## GUI Controls

- **🗑️ Clear**: Remove all transcription text
- **📌 Always On Top**: Toggle window staying on top
- **Opacity Slider**: Adjust window transparency (30%-100%)
- **Window Resize**: Drag corners to resize
- **Window Move**: Drag title bar to reposition

## Audio Device Setup

### For System Audio (Applications, Music, Videos)

1. Install BlackHole 2ch
2. Set BlackHole 2ch as your system audio output
3. Select BlackHole 2ch as input device in OneVoice
4. Use Audio MIDI Setup to create Multi-Output Device if you want to hear audio too

### For Microphone Input

1. Select your built-in microphone or external microphone
2. Speak normally - OneVoice will transcribe your voice

## Model Selection Guide

| Model  | Size  | Speed   | Accuracy  | Best For                   |
| ------ | ----- | ------- | --------- | -------------------------- |
| Tiny   | 39MB  | Fastest | Good      | Real-time, low resources   |
| Base   | 74MB  | Fast    | Better    | Balanced performance       |
| Small  | 244MB | Medium  | Great     | High quality transcription |
| Medium | 769MB | Slower  | Excellent | Maximum accuracy           |

## Troubleshooting

### GUI Window Not Appearing

- Ensure Python 3 is installed: `python3 --version`
- Check if tkinter is available: `python3 -c "import tkinter"`
- Try running GUI script directly: `python3 onevoice_gui.py`

### No Audio Devices Found

- Check audio device connections
- Restart audio applications
- Verify BlackHole installation (for system audio)

### Performance Issues

- Try a smaller model (tiny or base)
- Close unnecessary applications
- Check system resources (Activity Monitor)

### Permission Issues

- Make scripts executable: `chmod +x *.sh *.py`
- Grant microphone permissions in System Preferences > Security & Privacy

## Files

- `run.sh` - Main script with model selection, device setup, and display options
- `onevoice_gui.py` - Floating window GUI application
- `ggml-*.bin` - Whisper model files (downloaded automatically)

## Technical Details

- **GUI Framework**: tkinter (Python standard library)
- **Audio Processing**: whisper-stream (whisper.cpp)
- **Input/Output**: Unix pipes for real-time data streaming
- **Threading**: Separate thread for audio input processing
- **Platform**: macOS optimized (cross-platform compatible)

## Keyboard Shortcuts

- **Ctrl+C**: Stop transcription and close application
- **Window close button**: Safely shutdown GUI and audio processing

Enjoy real-time transcription with OneVoice! 🎤✨
