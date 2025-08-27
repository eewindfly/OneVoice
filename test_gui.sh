#!/bin/bash

# Test script to simulate whisper-stream output for GUI testing

echo "🧪 Testing OneVoice GUI with simulated output..."
echo "This will show how the floating window displays transcription."
echo ""
echo "Starting GUI in 3 seconds..."
sleep 1
echo "3..."
sleep 1
echo "2..."
sleep 1
echo "1..."
echo ""

# Simulate whisper-stream output
{
    echo "whisper_init_from_file: loading model from './ggml-base.en.bin'"
    sleep 2
    echo "Hello, this is a test transcription."
    sleep 3
    echo "The floating window should display this text."
    sleep 3
    echo "You can adjust the transparency and position."
    sleep 3
    echo "This is real-time speech recognition simulation."
    sleep 3
    echo "Thank you for testing OneVoice!"
    sleep 2
} | python3 onevoice_gui.py

echo ""
echo "✅ GUI test completed!"
