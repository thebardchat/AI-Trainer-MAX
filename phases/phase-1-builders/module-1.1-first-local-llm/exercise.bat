@echo off
setlocal enabledelayedexpansion
title Module 1.1 Exercise — Your First Local LLM

:: ============================================================
:: MODULE 1.1 EXERCISE: Your First Local LLM
:: Goal: Confirm Ollama works, model is pulled, and API responds
:: Time: ~10 minutes
:: RAM impact: Minimal — just Ollama inference on 1b model
:: ============================================================

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 1.1 EXERCISE: Your First Local LLM
echo  ══════════════════════════════════════════════════════
echo.
echo   Complete these 3 tasks. Each one builds on the last.
echo   When you're done, run verify.bat to check your work.
echo.
echo  ──────────────────────────────────────────────────────
echo.

:: --- TASK 1: Verify Ollama is running ---
echo  [TASK 1/3] Verify Ollama is running
echo.
echo   Open a separate terminal and run:
echo.
echo       ollama serve
echo.
echo   (Skip this if Ollama is already running.)
echo   Then come back here and press any key.
echo.
pause >nul
echo   Checking Ollama...
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   ✗ Ollama is not responding on localhost:11434[0m
    echo     Start it with: ollama serve
    echo     Then re-run this exercise.
    pause
    exit /b 1
)
echo  [92m   ✓ Ollama is running.[0m
echo.

:: --- TASK 2: Pull the model ---
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/3] Pull llama3.2:1b
echo.
echo   Run this command in your terminal:
echo.
echo       ollama pull llama3.2:1b
echo.
echo   Wait for "success" then press any key here.
echo.
pause >nul
echo   Checking for model...
curl -s http://localhost:11434/api/tags 2>nul | findstr /i "llama3.2:1b" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   ✗ Model llama3.2:1b not found.[0m
    echo     Run: ollama pull llama3.2:1b
    echo     Then come back and press any key.
    pause >nul
    curl -s http://localhost:11434/api/tags 2>nul | findstr /i "llama3.2:1b" >nul 2>&1
    if !errorlevel! NEQ 0 (
        echo  [91m   ✗ Still not found. Review the lesson and try again.[0m
        pause
        exit /b 1
    )
)
echo  [92m   ✓ Model llama3.2:1b is available.[0m
echo.

:: --- TASK 3: Make an API call ---
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/3] Make your first API inference
echo.
echo   Run this exact command (copy-paste it):
echo.
echo       curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Say hello in exactly 5 words\",\"stream\":false}"
echo.
echo   You should see a JSON response with the model's answer.
echo   Press any key when you've done it.
echo.
pause >nul

:: Quick validation — we make the call ourselves to confirm the pipeline works
echo   Verifying API is responsive...
curl -s -o nul -w "%%{http_code}" http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"test\",\"stream\":false}" > "%TEMP%\ollama_test.txt" 2>&1
set /p HTTP_CODE=<"%TEMP%\ollama_test.txt"
del "%TEMP%\ollama_test.txt" 2>nul

if "%HTTP_CODE%"=="200" (
    echo  [92m   ✓ API inference working. Your local AI is live.[0m
) else (
    echo  [93m   ⚠ Got HTTP %HTTP_CODE%. The API might be busy. Try again in a moment.[0m
)

echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   Now run verify.bat to confirm everything passed.
echo   From this module's folder, run:
echo.
echo       verify.bat
echo.
pause
endlocal
exit /b 0
