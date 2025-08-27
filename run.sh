#!/bin/bash

# OneVoice - Real-time System Audio Transcription
# Uses BlackHole 2ch to capture system audio output for speech recognition

echo "OneVoice System Audio Transcription"
echo "===================================="
echo "Choose English-only model (all use same timing: 10s length, 3s step):"
echo "1. High Accuracy (medium.en model, 769MB)"
echo "2. Good Quality (small.en model, 244MB)"
echo "3. Balanced (base.en model, 74MB)"
echo "4. Ultra Fast (tiny.en model, 39MB)"
echo ""
read -p "Select option (1/2/3/4): " choice

# Function to download model if not exists
download_model() {
    local model_file=$1
    local model_name=$2
    local model_url=$3
    
    if [ ! -f "$model_file" ]; then
        echo "📥 Model not found: $model_file"
        echo "🌐 Downloading $model_name model..."
        if command -v wget >/dev/null 2>&1; then
            wget -O "$model_file" "$model_url"
        elif command -v curl >/dev/null 2>&1; then
            curl -L -o "$model_file" "$model_url"
        else
            echo "❌ Error: Neither wget nor curl is available!"
            echo "Please install wget or curl, or manually download:"
            echo "   $model_url"
            echo "   Save as: $model_file"
            exit 1
        fi
        
        if [ $? -eq 0 ]; then
            echo "✅ Successfully downloaded $model_name model"
        else
            echo "❌ Failed to download $model_name model"
            exit 1
        fi
    fi
}

case $choice in
  1)
    echo "Using medium.en model - High accuracy mode (English only)"
    MODEL="./ggml-medium.en.bin"
    MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.en.bin"
    ;;
  2)
    echo "Using small.en model - Good quality mode (English only)"
    MODEL="./ggml-small.en.bin"
    MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin"
    ;;
  3)
    echo "Using base.en model - Balanced mode (English only)"
    MODEL="./ggml-base.en.bin"
    MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"
    ;;
  4)
    echo "Using tiny.en model - Ultra fast mode (English only)"
    MODEL="./ggml-tiny.en.bin"
    MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin"
    ;;
  *)
    echo "Invalid selection, using default base.en model"
    MODEL="./ggml-base.en.bin"
    MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"
    ;;
esac

# Download model if needed
MODEL_NAME=$(basename "$MODEL" .bin)
download_model "$MODEL" "$MODEL_NAME" "$MODEL_URL"

# List available audio devices and let user choose (with built-in microphone as default)
echo "Detecting available audio devices..."
echo ""
DEVICES_OUTPUT=$(/opt/homebrew/bin/whisper-stream -c -1 2>&1)

# Extract and display available devices
echo "Available audio input devices:"
echo "=============================="
DEVICE_LINES=$(echo "$DEVICES_OUTPUT" | grep "Capture device #" | nl -v0)

if [ -z "$DEVICE_LINES" ]; then
    echo "❌ No audio devices found!"
    echo "Please check your audio setup and try again."
    exit 1
fi

echo "$DEVICE_LINES"
echo ""

# Find built-in microphone for default
RAW_DEVICE_LINES=$(echo "$DEVICES_OUTPUT" | grep "Capture device #")
BUILTIN_MIC_LINE=$(echo "$RAW_DEVICE_LINES" | grep -i -E "(microphone|built-in|macbook|imac|mac mini)" | head -1)

if [ -n "$BUILTIN_MIC_LINE" ]; then
    DEFAULT_DEVICE_ID=$(echo "$BUILTIN_MIC_LINE" | grep -o "#[0-9]*" | cut -d# -f2)
    DEFAULT_DEVICE_NAME=$(echo "$BUILTIN_MIC_LINE" | sed 's/.*Capture device #[0-9]*: //' | sed "s/'//g")
    # Find the index in the numbered list
    DEFAULT_INDEX=$(echo "$DEVICE_LINES" | grep "#$DEFAULT_DEVICE_ID:" | cut -f1 | tr -d ' ')
    
    echo "💡 Default: Built-in microphone ($DEFAULT_DEVICE_NAME) - Index $DEFAULT_INDEX"
else
    DEFAULT_INDEX="0"
    DEFAULT_DEVICE_NAME="First available device"
    echo "💡 Default: Index 0 (first device)"
fi

echo ""
echo "Device recommendations:"
echo "  - For system audio: Choose BlackHole 2ch (if installed)"
echo "  - For microphone: Choose your built-in microphone"
echo "  - For external: Choose your external microphone/interface"
echo ""

# Get total number of devices
DEVICE_COUNT=$(echo "$DEVICE_LINES" | wc -l | tr -d ' ')
MAX_INDEX=$((DEVICE_COUNT - 1))

# Let user select device or use default
read -p "Select device (0-$MAX_INDEX) or press Enter for default [$DEFAULT_INDEX]: " DEVICE_CHOICE

# Handle empty input - use default
if [ -z "$DEVICE_CHOICE" ]; then
    DEVICE_CHOICE="$DEFAULT_INDEX"
    echo "✅ Using default device (Index $DEFAULT_INDEX): $DEFAULT_DEVICE_NAME"
fi

# Validate input - if invalid, use default
if ! [[ "$DEVICE_CHOICE" =~ ^[0-9]+$ ]] || [ "$DEVICE_CHOICE" -lt 0 ] || [ "$DEVICE_CHOICE" -gt "$MAX_INDEX" ]; then
    echo "❌ Invalid selection '$DEVICE_CHOICE'. Using default device (Index $DEFAULT_INDEX): $DEFAULT_DEVICE_NAME"
    DEVICE_CHOICE="$DEFAULT_INDEX"
fi

# Get the actual device ID from the selected line
SELECTED_LINE=$(echo "$DEVICE_LINES" | sed -n "$((DEVICE_CHOICE + 1))p")
DEVICE_ID=$(echo "$SELECTED_LINE" | grep -o "#[0-9]*" | cut -d# -f2)
DEVICE_NAME=$(echo "$SELECTED_LINE" | sed 's/.*Capture device #[0-9]*: //' | sed "s/'//g")

# Validate device ID was extracted
if [ -z "$DEVICE_ID" ]; then
    echo "❌ Failed to extract device ID. Please try again."
    exit 1
fi

echo "----------------------------------------"
echo "✅ Selected: $DEVICE_NAME (Device ID: $DEVICE_ID)"
echo "Language: English (en)"
echo "Model: $MODEL"
echo "Using default timing: 10s length, 3s step, 200ms keep"
echo ""
echo "Choose display mode:"
echo "1. Floating GUI Window (default)"
echo "2. Terminal output only"
echo ""
read -p "Select display mode (1/2) or press Enter for GUI [1]: " display_choice

# Handle empty input - use GUI as default
if [ -z "$display_choice" ]; then
    display_choice="1"
    echo "✅ Using default: Floating GUI Window"
fi

case $display_choice in
  1)
    echo "🚀 Starting OneVoice with floating GUI window..."
    echo "Press Ctrl+C to stop"
    echo "----------------------------------------"
    
    # Check if Python GUI script exists
    if [ ! -f "./onevoice_gui.py" ]; then
        echo "❌ GUI script not found: ./onevoice_gui.py"
        echo "Please ensure the GUI script is in the same directory."
        exit 1
    fi
    
    # Make sure GUI script is executable
    chmod +x "./onevoice_gui.py"
    
    # Run whisper-stream and pipe output to GUI
    /opt/homebrew/bin/whisper-stream \
      -m "$MODEL" \
      -l en \
      -c "$DEVICE_ID" 2>/dev/null | python3 "./onevoice_gui.py"
    ;;
  2)
    echo "📟 Starting OneVoice with terminal output..."
    echo "Press Ctrl+C to stop"
    echo "----------------------------------------"
    
    # Run whisper-stream with default parameters (terminal output)
    /opt/homebrew/bin/whisper-stream \
      -m "$MODEL" \
      -l en \
      -c "$DEVICE_ID"
    ;;
  *)
    echo "Invalid selection, defaulting to floating GUI window..."
    echo "🚀 Starting OneVoice with floating GUI window..."
    echo "Press Ctrl+C to stop"
    echo "----------------------------------------"
    
    # Check if Python GUI script exists
    if [ ! -f "./onevoice_gui.py" ]; then
        echo "❌ GUI script not found: ./onevoice_gui.py"
        echo "Please ensure the GUI script is in the same directory."
        exit 1
    fi
    
    # Make sure GUI script is executable
    chmod +x "./onevoice_gui.py"
    
    # Run whisper-stream and pipe output to GUI
    /opt/homebrew/bin/whisper-stream \
      -m "$MODEL" \
      -l en \
      -c "$DEVICE_ID" 2>/dev/null | python3 "./onevoice_gui.py"
    ;;
esac
