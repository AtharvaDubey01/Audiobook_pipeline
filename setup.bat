@echo off
:: ─────────────────────────────────────────────────────────────
::  Audiobook Generator — One-click Windows Setup
::  Run this ONCE before using run.bat
:: ─────────────────────────────────────────────────────────────

title Audiobook Generator Setup

echo.
echo [SETUP] Audiobook Generator - Windows Setup
echo ---------------------------------------------------------
echo.

:: ── Check Python ──────────────────────────────────────────────
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found.
    echo         Install Python 3.10 from https://python.org
    echo         Make sure to check "Add Python to PATH" during installation.
    pause
    exit /b 1
)

echo [INFO] Python found:
python --version
echo.

:: ── Create virtual environment ────────────────────────────────
if not exist "venv" (
    echo [INFO] Creating virtual environment...
    python -m venv venv
) else (
    echo [INFO] Virtual environment already exists. Skipping.
)

call venv\Scripts\activate.bat

echo [INFO] Upgrading pip...
python -m pip install --upgrade pip --quiet

:: ── Install PyTorch (CUDA if available, else CPU) ─────────────
echo.
echo [INFO] Detecting GPU...

:: Check if nvidia-smi is present (reliable indicator of an Nvidia GPU + driver)
where nvidia-smi >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Nvidia GPU detected. Installing PyTorch with CUDA 12.1 support...
    pip install torch torchaudio --index-url https://download.pytorch.org/whl/cu121 --quiet
) else (
    echo [INFO] No Nvidia GPU detected. Installing CPU-only PyTorch...
    pip install torch torchaudio --index-url https://download.pytorch.org/whl/cpu --quiet
)

:: ── Install remaining dependencies ───────────────────────────
echo.
echo [INFO] Installing remaining dependencies...
pip install TTS soundfile numpy tqdm librosa scipy "transformers==4.38.2" torchcodec --quiet

:: ── Pre-download XTTS v2 model ────────────────────────────────
echo.
echo [INFO] Downloading XTTS v2 model weights (~1.8 GB, first run only)...
set COQUI_TOS_AGREED=1
python -c "import torch; import functools; torch.load = functools.partial(torch.load, weights_only=False); from TTS.api import TTS; TTS('tts_models/multilingual/multi-dataset/xtts_v2')"

echo.
echo ---------------------------------------------------------
echo [DONE] Setup complete! Run run.bat to start generating.
echo ---------------------------------------------------------
pause
