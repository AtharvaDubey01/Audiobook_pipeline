#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Audiobook Generator — Mac/Linux Runner
# ─────────────────────────────────────────────────────────────

# Accept Coqui TTS terms of service automatically
export COQUI_TOS_AGREED=1

# Ensure venv exists
if [ ! -d "venv" ]; then
    echo "[ERROR] Virtual environment not found. Please run ./setup.sh first."
    exit 1
fi

echo "Starting Audiobook Generator..."
./venv/bin/python app.py
