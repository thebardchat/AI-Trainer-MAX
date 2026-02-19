@echo off
setlocal enabledelayedexpansion
title Module 1.1 Verify

:: ============================================================
:: MODULE 1.1 VERIFICATION
:: Checks: Ollama running, model available, API responds
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=3"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 1.1 VERIFICATION
echo  ══════════════════════════════════════════════════════
echo.

:: --- CHECK 1: Ollama server ---
echo  [CHECK 1/%TOTAL_CHECKS%] Ollama server running
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Ollama responding on localhost:11434[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Ollama not responding[0m
    echo          Fix: Run "ollama serve" in a separate terminal
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: Model pulled ---
echo  [CHECK 2/%TOTAL_CHECKS%] Model llama3.2:1b available
curl -s http://localhost:11434/api/tags 2>nul | findstr /i "llama3.2:1b" >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: llama3.2:1b found in local models[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: llama3.2:1b not found[0m
    echo          Fix: Run "ollama pull llama3.2:1b"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: API inference works ---
echo  [CHECK 3/%TOTAL_CHECKS%] API inference functional
curl -s -o "%TEMP%\verify_response.txt" -w "%%{http_code}" http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Reply with only the word VERIFIED\",\"stream\":false}" > "%TEMP%\verify_http.txt" 2>&1
set /p HTTP_CODE=<"%TEMP%\verify_http.txt"
del "%TEMP%\verify_http.txt" 2>nul
del "%TEMP%\verify_response.txt" 2>nul

if "%HTTP_CODE%"=="200" (
    echo  [92m   PASS: API returned HTTP 200 — inference working[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: API returned HTTP %HTTP_CODE%[0m
    echo          Fix: Ensure Ollama is running and model is pulled
    set /a FAIL_COUNT+=1
)
echo.

:: --- RESULTS ---
echo  ══════════════════════════════════════════════════════
if %FAIL_COUNT% EQU 0 (
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
    echo.
    echo  [92m   ✓ MODULE 1.1 COMPLETE[0m
    echo  [92m   You proved: Local AI runs on YOUR machine.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        :: Append completion marker
        echo   {"module": "1.1", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 1.2 — Vectors Made Simple
    echo   Your AI has a voice. Now let's give it a memory.
    echo  ══════════════════════════════════════════════════════
    endlocal
    exit /b 0
) else (
    echo  [91m   RESULT: FAIL  (%PASS_COUNT%/%TOTAL_CHECKS% passed, %FAIL_COUNT% failed)[0m
    echo.
    echo   Review the failures above and fix them.
    echo   Then run verify.bat again.
    echo   Need help? Check hints.md in this folder.
    echo  ══════════════════════════════════════════════════════
    endlocal
    exit /b 1
)
