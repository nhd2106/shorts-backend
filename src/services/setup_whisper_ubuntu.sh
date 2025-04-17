#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if Python 3.11 is installed
if ! command -v python3.11 &> /dev/null; then
    echo "Python 3.11 is not installed. Installing Python 3.11..."
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install -y python3.11 python3.11-venv python3.11-dev
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "pip3 is not installed. Installing pip3..."
    sudo apt install -y python3-pip
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg is not installed. Installing ffmpeg..."
    sudo apt install -y ffmpeg
fi

echo "Installing Python dependencies..."

# Remove existing virtual environment if it exists
if [ -d "$SCRIPT_DIR/venv" ]; then
    rm -rf "$SCRIPT_DIR/venv"
fi

# Create and activate virtual environment with Python 3.11
python3.11 -m venv "$SCRIPT_DIR/venv"
source "$SCRIPT_DIR/venv/bin/activate"

# Ensure the site-packages directory exists with correct permissions
SITE_PACKAGES="$SCRIPT_DIR/venv/lib/python3.11/site-packages"
mkdir -p "$SITE_PACKAGES"
chmod 755 "$SITE_PACKAGES"

# Upgrade pip
pip3 install --upgrade pip

# Install dependencies from requirements.txt
pip3 install -r "$SCRIPT_DIR/requirements.txt"

# Make the Python script executable
chmod +x "$SCRIPT_DIR/whisper_transcribe.py"

echo "Setup completed successfully!"
echo "Virtual environment created at: $SCRIPT_DIR/venv" 