#!/bin/bash

# OneVoice GUI Launcher
# Quick launcher for the floating window version

echo "🎤 OneVoice - Floating Window Launcher"
echo "======================================"
echo ""

# Check if GUI script exists
if [ ! -f "./onevoice_gui.py" ]; then
    echo "❌ GUI script not found: ./onevoice_gui.py"
    echo "Please ensure the GUI script is in the same directory."
    exit 1
fi

# Check if main script exists
if [ ! -f "./run.sh" ]; then
    echo "❌ Main script not found: ./run.sh"
    echo "Please ensure run.sh is in the same directory."
    exit 1
fi

echo "🚀 Launching OneVoice with floating GUI..."
echo "   - The main menu will appear in terminal"
echo "   - Choose your preferred AI model"
echo "   - Select audio device (or use built-in microphone default)"
echo "   - Choose option 1 for floating GUI when prompted"
echo ""
echo "Press Enter to continue..."
read

# Run the main script
./run.sh
