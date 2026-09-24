# Audiobook Generator

A simple, robust, cross-platform Python pipeline for generating realistic audiobooks from text using Coqui TTS (XTTS v2).

This pipeline has been stripped down to only the essential components and is designed to run seamlessly on **Windows, macOS (Apple Silicon supported), and Linux**.

## 📁 Repository Structure
- `app.py` - The core generation script.
- `reference.wav` & `reference_female.wav` - The voice reference files used to clone the desired voice (Male and Female options).
- `Chapters_Text/` - Drop your `.txt` files in here! (e.g., `Chapter 1.txt`, `Chapter 2.txt`)
- `Chapters_Audio/` - Your finished `.wav` files will appear here.

## 🚀 How to use

### Windows
1. **First-time Setup:** Double-click on `setup.bat`. This will automatically set up the virtual environment, install PyTorch (with CUDA support if an NVIDIA GPU is detected), install all other requirements, and pre-download the TTS model.
2. **Add your text:** Place your `.txt` chapter files in the `Chapters_Text/` folder.
3. **Generate:** Double-click on `run.bat`. The generated audio files will be saved in `Chapters_Audio/`.

### macOS / Linux
1. **First-time Setup:** Open a terminal in the folder and run:
   ```bash
   chmod +x setup.sh run.sh
   ./setup.sh
   ```
   This will configure Python, set up the virtual environment, install PyTorch (with MPS support on Apple Silicon), and download the TTS models.
2. **Add your text:** Place your `.txt` chapter files in the `Chapters_Text/` folder.
3. **Generate:** Run the generator:
   ```bash
   ./run.sh
   ```

## ⚙️ Features
- **Smart Resumption:** If generation is interrupted, just run it again! It automatically skips chapters that already exist in `Chapters_Audio/`.
- **Natural Sorting:** Chapters will be processed in numerical order (e.g. Chapter 2 comes before Chapter 10).
- **Scene Breaks:** If your text contains `________________`, the model will insert exactly 2 seconds of silence, perfect for scene transitions.
- **Voice Selection:** You can easily switch between a male or female narrator! Just open `app.py`, find the line `REFERENCE_WAV = "reference.wav"` (around line 38), and change it to `"reference_female.wav"`.

## 📝 Requirements
- Python 3.10+
- (Optional but highly recommended) NVIDIA GPU for Windows/Linux or Apple Silicon (M1/M2/M3) on Mac for accelerated audio generation.
