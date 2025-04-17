#!/bin/bash

# This script tests if the Whisper transcription functionality is working in the combined container

# Check if an audio file argument was provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <audio_file_path>"
    echo "Example: $0 test.mp3"
    exit 1
fi

AUDIO_FILE=$1

# Verify the audio file exists
if [ ! -f "$AUDIO_FILE" ]; then
    echo "Error: Audio file '$AUDIO_FILE' not found."
    exit 1
fi

# Create contents/audio directory if it doesn't exist
mkdir -p contents/audio

# Copy the audio file to contents/audio
cp "$AUDIO_FILE" contents/audio/test_input.wav

echo "Testing Whisper transcription..."
echo "Audio file: $AUDIO_FILE"

# Run docker command to execute the whisper_transcribe.py script
docker-compose exec app bash -c "cd /app/src/services && . venv/bin/activate && python whisper_transcribe.py /app/contents/audio/test_input.wav"

# Check if the command succeeded
if [ $? -eq 0 ]; then
    echo -e "\n✅ Whisper transcription test completed successfully."
else
    echo -e "\n❌ Whisper transcription test failed."
fi 