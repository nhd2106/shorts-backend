#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Script directory: $SCRIPT_DIR"

# Check if running in Docker (the script may be called from different locations)
if [ -f /.dockerenv ]; then
    echo "Running in Docker environment"
    # In Docker we can just install without checking
    SKIP_CHECKS=1
else
    SKIP_CHECKS=0
fi

# Skip system checks if in Docker
if [ "$SKIP_CHECKS" -eq 0 ]; then
    # Check if Python is installed
    if ! command -v python3 &> /dev/null; then
        echo "Python 3 is not installed. Installing Python 3..."
        sudo apt update
        sudo apt install -y python3 python3-venv python3-dev
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
fi

echo "Python version:"
python3 --version

echo "Installing Python dependencies..."

# Create venv directory if it doesn't exist
mkdir -p "$SCRIPT_DIR/venv"

# Remove existing virtual environment if it exists
if [ -d "$SCRIPT_DIR/venv/bin" ]; then
    echo "Removing existing virtual environment..."
    rm -rf "$SCRIPT_DIR/venv"
fi

# Check if venv module is available
if ! python3 -m venv --help &> /dev/null; then
    echo "The venv module is not available. Installing python3-venv..."
    if [ -f /.dockerenv ]; then
        apt-get update && apt-get install -y python3-venv
    else
        sudo apt-get update && sudo apt-get install -y python3-venv
    fi
fi

# Create and activate virtual environment with Python 3
echo "Creating virtual environment with Python 3..."
python3 -m venv "$SCRIPT_DIR/venv" || { 
    echo "Failed to create virtual environment. Detailed error:"
    python3 -m venv "$SCRIPT_DIR/venv" --verbose
    exit 1 
}

# Check if venv was created successfully
if [ ! -f "$SCRIPT_DIR/venv/bin/activate" ]; then
    echo "Virtual environment creation failed. Check Python installation."
    exit 1
fi

# Activate virtual environment
echo "Activating virtual environment..."
source "$SCRIPT_DIR/venv/bin/activate" || { echo "Failed to activate virtual environment"; exit 1; }

# Show Python version in venv
echo "Python version in virtual environment:"
python --version

# Ensure the site-packages directory exists with correct permissions
SITE_PACKAGES="$SCRIPT_DIR/venv/lib/python3.*/site-packages"
mkdir -p $SITE_PACKAGES
chmod 755 $SITE_PACKAGES

# Upgrade pip
echo "Upgrading pip..."
pip3 install --upgrade pip || { echo "Failed to upgrade pip"; exit 1; }

# Install dependencies from requirements.txt
echo "Installing requirements..."
pip3 install -r "$SCRIPT_DIR/requirements.txt" || { echo "Failed to install requirements"; exit 1; }

# Make the Python script executable
chmod +x "$SCRIPT_DIR/whisper_transcribe.py"

echo "Setup completed successfully!"
echo "Virtual environment created at: $SCRIPT_DIR/venv" 