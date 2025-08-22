#!/bin/bash

# OneVoice - Real-time System Audio Transcription
# Uses BlackHole 2ch to capture system audio output for speech recognition

echo "OneVoice System Audio Transcription"
echo "===================================="
echo "Choose latency mode:"
echo "1. High Accuracy (medium model, ~3-5s latency)"
echo "2. Balanced (base model, ~1-2s latency)"
echo "3. Ultra Low Latency (tiny model, ~0.5-1s latency)"
echo ""
read -p "Select option (1/2/3): " choice

case $choice in
  1)
    echo "Using medium model - High accuracy mode"
    MODEL="./ggml-medium.bin"
    LENGTH="5000"
    STEP="2000"
    KEEP="200"
    ;;
  2)
    echo "Using base model - Balanced mode"
    MODEL="./ggml-base.bin"
    LENGTH="3000"
    STEP="1000"
    KEEP="200"
    ;;
  3)
    echo "Using tiny model - Ultra low latency mode"
    MODEL="./ggml-tiny.bin"
    LENGTH="2000"
    STEP="500"
    KEEP="200"
    ;;
  *)
    echo "Invalid selection, using default balanced mode"
    MODEL="./ggml-base.bin"
    LENGTH="3000"
    STEP="1000"
    KEEP="200"
    ;;
esac

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
echo "Latency settings: length=$LENGTH, step=$STEP"
echo "Press Ctrl+C to stop"
echo "----------------------------------------"

# Run whisper-stream
/opt/homebrew/bin/whisper-stream \
  -m "$MODEL" \
  -l en \
  --length "$LENGTH" \
  --step "$STEP" \
  --keep "$KEEP" \
  -c "$DEVICE_ID"
