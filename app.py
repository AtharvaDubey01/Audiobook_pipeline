import functools
import torch
import warnings
import sys
import io
import os
import glob
import re
import tempfile
import shutil
import numpy as np
import soundfile as sf
from tqdm import tqdm
from TTS.api import TTS

# Force UTF-8 output on Windows (avoids UnicodeEncodeError in CMD / PowerShell)
if sys.stdout.encoding is None or sys.stdout.encoding.lower() != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

# Suppress PyTorch warnings that break the terminal progress bar
warnings.filterwarnings("ignore")

# Fix for PyTorch 2.6 security restriction
torch.load = functools.partial(torch.load, weights_only=False)


def get_natural_sort_key(s):
    """Sort filenames naturally so Chapter 2 comes before Chapter 10."""
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r'(\d+)', s)]


def main():
    INPUT_DIR     = "Chapters_Text"
    OUTPUT_DIR    = "Chapters_Audio"
    REFERENCE_WAV = "reference.wav"
    SAMPLE_RATE   = 24000

    # Ensure directories exist
    os.makedirs(INPUT_DIR, exist_ok=True)
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Check if reference wav exists
    if not os.path.exists(REFERENCE_WAV):
        print(f"ERROR: Cannot find '{REFERENCE_WAV}'. Please ensure it is in the same directory.")
        sys.exit(1)

    # Collect and sort chapter text files
    txt_files = glob.glob(os.path.join(INPUT_DIR, "*.txt"))
    if not txt_files:
        print(f"No .txt files found in '{INPUT_DIR}'. Please add your chapter files and run again.")
        sys.exit(0)

    txt_files.sort(key=get_natural_sort_key)
    print(f"Found {len(txt_files)} chapters to process.")

    # ── Device selection: prefer GPU, fall back to CPU ────────
    print("\n[1/2] Initializing XTTS v2 Model...")
    if torch.cuda.is_available():
        device = "cuda"
        gpu_name = torch.cuda.get_device_name(0)
        print(f" -> Hardware Acceleration: CUDA ({gpu_name})")
    elif torch.backends.mps.is_available():
        device = "mps"
        print(" -> Hardware Acceleration: MPS (Apple Silicon GPU)")
    else:
        device = "cpu"
        print(" -> Hardware Acceleration: CPU (no GPU detected — generation will be slower)")

    try:
        tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2").to(device)
    except Exception as e:
        print(f"ERROR loading model: {e}")
        sys.exit(1)

    print("[2/2] Model loaded successfully! Starting Chapter Generation.\n")

    # ── Main generation loop ──────────────────────────────────
    for file_path in tqdm(txt_files, desc="Overall Progress", position=0):
        filename  = os.path.basename(file_path)
        base_name = os.path.splitext(filename)[0]
        output_wav_path = os.path.join(OUTPUT_DIR, f"{base_name}.wav")

        # Skip chapters that are already done (safe to resume after interruption)
        if os.path.exists(output_wav_path):
            tqdm.write(f"Skipping '{filename}' — already generated.")
            continue

        with open(file_path, 'r', encoding='utf-8') as f:
            text = f.read()

        paragraphs = [p.strip() for p in text.split('\n') if p.strip()]
        if not paragraphs:
            continue

        audio_chunks = []
        silence_2s   = np.zeros(int(SAMPLE_RATE * 2.0), dtype=np.float32)
        silence_0_5s = np.zeros(int(SAMPLE_RATE * 0.5), dtype=np.float32)

        temp_dir = tempfile.mkdtemp()

        try:
            for i, para in enumerate(tqdm(paragraphs, desc=f"  {base_name}", position=1, leave=False)):

                # Scene break → insert 2 s of silence
                if "________________" in para:
                    audio_chunks.append(silence_2s)
                    continue

                chunk_file = os.path.join(temp_dir, f"chunk_{i}.wav")

                # Redirect stdout to suppress TTS internal prints
                original_stdout = sys.stdout
                sys.stdout = open(os.devnull, 'w')
                try:
                    tts.tts_to_file(
                        text=para,
                        speaker_wav=REFERENCE_WAV,
                        language="en",
                        file_path=chunk_file
                    )
                finally:
                    sys.stdout.close()
                    sys.stdout = original_stdout

                chunk_data, _ = sf.read(chunk_file)
                audio_chunks.append(chunk_data)
                audio_chunks.append(silence_0_5s)

        finally:
            shutil.rmtree(temp_dir)

        if audio_chunks:
            final_audio = np.concatenate(audio_chunks)
            sf.write(output_wav_path, final_audio, SAMPLE_RATE)
            tqdm.write(f"[done] Saved: {output_wav_path}")

    print("\n[DONE] All chapters generated successfully!")
    print(f"Audio files are in the '{OUTPUT_DIR}' folder.")


if __name__ == "__main__":
    tqdm.write('\n')
    main()
