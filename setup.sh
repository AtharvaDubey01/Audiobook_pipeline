#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Audiobook Generator — One-click Mac/Linux Setup
# ─────────────────────────────────────────────────────────────

echo ""
echo "[SETUP] Audiobook Generator - Mac/Linux Setup"
echo "---------------------------------------------------------"
echo ""

PYTHON_CMD=""
for cmd in python3.11 python3.10 python3.9 python3; do
    if command -v $cmd &> /dev/null; then
        # Check if the python version is < 3.12 (TTS requirement)
        version=$($cmd -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
        if [[ $(echo "$version < 3.12" | bc -l) -eq 1 ]]; then
            PYTHON_CMD=$cmd
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "[ERROR] Compatible Python (>=3.9, <3.12) not found."
    echo "        Please install Python 3.9, 3.10, or 3.11."
    exit 1
fi

echo "[INFO] Python found:"
$PYTHON_CMD --version
echo ""

if [ ! -d "venv" ]; then
    echo "[INFO] Creating virtual environment..."
    $PYTHON_CMD -m venv venv
else
    echo "[INFO] Virtual environment already exists. Skipping."
fi

source venv/bin/activate

echo "[INFO] Upgrading pip..."
pip install --upgrade pip --quiet

echo "[INFO] Installing dependencies (this may take a while)..."
# The default PyTorch on PyPI supports MPS on Mac and CPU on Linux. 
# Linux users with Nvidia GPU might want to install CUDA version manually.
pip install torch torchaudio torchcodec TTS soundfile numpy tqdm librosa scipy "transformers==4.38.2" --quiet

echo ""
echo "[INFO] Downloading XTTS v2 model weights (~1.8 GB, first run only)..."
export COQUI_TOS_AGREED=1
$PYTHON_CMD -c "import torch; import functools; torch.load = functools.partial(torch.load, weights_only=False); from TTS.api import TTS; TTS('tts_models/multilingual/multi-dataset/xtts_v2')"

echo ""
echo "---------------------------------------------------------"
echo "[DONE] Setup complete! Run ./run.sh to start generating."
echo "---------------------------------------------------------"
