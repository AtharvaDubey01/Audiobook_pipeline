@echo off
:: ─────────────────────────────────────────────────────────────
::  Audiobook Generator — Windows Launcher
::  Run this file to start audiobook generation.
:: ─────────────────────────────────────────────────────────────

title Audiobook Generator

echo.
echo  ████████╗██████╗ ██╗   ██╗████████╗██╗  ██╗████████╗ █████╗ ██╗     ██╗  ██╗
echo  ╚══██╔══╝██╔══██╗██║   ██║╚══██╔══╝██║  ██║╚══██╔══╝██╔══██╗██║     ██║ ██╔╝
echo     ██║   ██████╔╝██║   ██║   ██║   ███████║   ██║   ███████║██║     █████╔╝
echo     ██║   ██╔══██╗██║   ██║   ██║   ██╔══██║   ██║   ██╔══██║██║     ██╔═██╗
echo     ██║   ██║  ██║╚██████╔╝   ██║   ██║  ██║   ██║   ██║  ██║███████╗██║  ██╗
echo     ╚═╝   ╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
echo.
echo  Audiobook Generator  ^|  XTTS v2 Voice Cloning
echo  ─────────────────────────────────────────────────────────────
echo.

:: ── Check Python is installed ──────────────────────────────────
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found. Please install Python 3.10+ and add it to PATH.
    pause
    exit /b 1
)

:: ── Set Coqui TTS ToS flag ────────────────────────────────────
set COQUI_TOS_AGREED=1

:: ── Activate virtual environment if it exists ─────────────────
if exist "venv\Scripts\activate.bat" (
    echo [INFO] Activating virtual environment...
    call venv\Scripts\activate.bat
) else (
    echo [WARN] No virtual environment found. Using system Python.
    echo        Run setup.bat first to create the environment.
)

echo [INFO] Starting generation... (this will take a LONG time)
echo.

:: ── Launch the app ────────────────────────────────────────────
python app.py

echo.
echo [DONE] Generation finished. Check the Chapters_Audio folder.
pause
