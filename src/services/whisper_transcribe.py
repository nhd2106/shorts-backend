#!/usr/bin/env python3
import sys
import json
import os
import site

def setup_environment():
    # Get the directory where the script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Add virtual environment site-packages to Python path
    # Look for any Python 3.x version in the venv directory
    for py_ver in os.listdir(os.path.join(script_dir, "venv", "lib")):
        if py_ver.startswith("python3"):
            venv_site_packages = os.path.join(script_dir, "venv", "lib", py_ver, "site-packages")
            if os.path.exists(venv_site_packages):
                site.addsitedir(venv_site_packages)
                print(f"Added {venv_site_packages} to Python path", file=sys.stderr)
                break

def transcribe_audio(audio_path, language="vi"):
    try:
        setup_environment()
        import whisper
        import torch
    except ImportError as e:
        print(json.dumps({
            "error": f"Failed to import required modules: {str(e)}",
            "text": "",
            "segments": []
        }, ensure_ascii=False))
        sys.exit(1)

    try:
        if not os.path.exists(audio_path):
            raise FileNotFoundError(f"Audio file not found: {audio_path}")

        # Check if CPU-only mode is forced via environment variable
        cpu_only = os.environ.get("WHISPER_CPU_ONLY", "0") == "1"
        
        # Determine device
        if cpu_only:
            device = "cpu"
        else:
            device = "cuda" if torch.cuda.is_available() else "cpu"
            
        print(f"Using device: {device}", file=sys.stderr)
        
        # Load the Whisper model
        model = whisper.load_model("small", device=device)
        
        # Transcribe with word-level timestamps
        result = model.transcribe(
            audio_path,
            language=language,
            word_timestamps=True,
            verbose=False,
            fp16=False
        )
        
        # Convert segments to our desired format
        segments = []
        for segment in result["segments"]:
            words = []
            if "words" in segment:
                for word in segment["words"]:
                    words.append({
                        "text": word.get("text", "").strip(),
                        "start": str(word.get("start", 0)),
                        "end": str(word.get("end", 0))
                    })
            
            segments.append({
                "text": segment.get("text", "").strip(),
                "start": segment.get("start", 0),
                "end": segment.get("end", 0),
                "words": words
            })
        
        output = {
            "text": result.get("text", "").strip(),
            "segments": segments
        }
        
        print(json.dumps(output, ensure_ascii=False))
        sys.stdout.flush()
        
    except Exception as e:
        print(json.dumps({
            "error": str(e),
            "text": "",
            "segments": []
        }, ensure_ascii=False))
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({
            "error": "No audio file provided",
            "text": "",
            "segments": []
        }, ensure_ascii=False))
        sys.exit(1)
    else:
        audio_path = sys.argv[1]
        language = sys.argv[2] if len(sys.argv) > 2 else "vi"
        transcribe_audio(audio_path, language)