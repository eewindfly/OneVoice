#!/bin/bash

# OneVoice - Real-time System Audio Transcription
# Uses BlackHole 2ch to capture system audio output for speech recognition

echo "OneVoice System Audio Transcription"
echo "===================================="
echo "Choose model (all use same timing: 10s length, 3s step):"
echo "1. High Accuracy (medium model, 1.5GB)"
echo "2. Good Quality (small model, 450MB)"
echo "3. Balanced (base model, 140MB)"
echo "4. Ultra Fast (tiny model, 75MB)"
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
    echo "Using medium model - High accuracy mode"
    MODEL="./ggml-medium.bin"
    MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin"
    ;;
  2)
    echo "Using small model - Good quality mode"
    MODEL="./ggml-small.bin"
    MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin"
    ;;
  3)
    echo "Using base model - Balanced mode"
    MODEL="./ggml-base.bin"
    MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin"
    ;;
  4)
    echo "Using tiny model - Ultra fast mode"
    MODEL="./ggml-tiny.bin"
    MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin"
    ;;
  *)
    echo "Invalid selection, using default base model"
    MODEL="./ggml-base.bin"
    MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin"
    ;;
esac

# Download model if needed
MODEL_NAME=$(basename "$MODEL" .bin)
download_model "$MODEL" "$MODEL_NAME" "$MODEL_URL"

# Auto-detect BlackHole device ID
echo "Detecting audio devices..."
BLACKHOLE_LINE=$(/opt/homebrew/bin/whisper-stream -c -1 2>&1 | grep "BlackHole")

if [ -z "$BLACKHOLE_LINE" ]; then
    echo "❌ BlackHole not found! Available devices:"
    /opt/homebrew/bin/whisper-stream -c -1 2>&1 | grep "Capture device"
    echo ""
    echo "Please install BlackHole from: https://existential.audio/blackhole/"
    echo "Or manually specify device ID by editing this script."
    exit 1
fi

# Extract device ID from the line (e.g., "Capture device #1:" -> "1")
DEVICE_ID=$(echo "$BLACKHOLE_LINE" | grep -o "#[0-9]*" | cut -d# -f2)

echo "----------------------------------------"
echo "✅ Found BlackHole 2ch (Device ID: $DEVICE_ID)"
echo "Language: English (en)"
echo "Model: $MODEL"
echo "Using default timing: 10s length, 3s step, 200ms keep"
echo "Press Ctrl+C to stop"
echo "----------------------------------------"

# Run whisper-stream with default parameters
/opt/homebrew/bin/whisper-stream \
  -m "$MODEL" \
  -l en \
  -c "$DEVICE_ID"
