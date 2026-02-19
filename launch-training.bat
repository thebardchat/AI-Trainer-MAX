@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
title Angel Cloud AI Training Tools

:: ============================================================
:: ANGEL CLOUD AI TRAINING TOOLS — Main Launcher
:: Path: D:\Angel_Cloud\shanebrain-core\training-tools\
:: RAM Ceiling: 7.4GB — modules capped at 3GB peak
:: ============================================================

set "BASE_DIR=%~dp0"
set "PROGRESS_FILE=%BASE_DIR%progress\user-progress.json"
set "CONFIG_FILE=%BASE_DIR%config.json"
set "HEALTH_CHECK=%BASE_DIR%shared\utils\health-check.bat"

:: ============================================================
:: ASCII BANNER
:: ============================================================
:banner
cls
echo.
echo    ╔══════════════════════════════════════════════════════════╗
echo    ║                                                          ║
echo    ║     █████╗ ███╗   ██╗ ██████╗ ███████╗██╗                ║
echo    ║    ██╔══██╗████╗  ██║██╔════╝ ██╔════╝██║                ║
echo    ║    ███████║██╔██╗ ██║██║  ███╗█████╗  ██║                ║
echo    ║    ██╔══██║██║╚██╗██║██║   ██║██╔══╝  ██║                ║
echo    ║    ██║  ██║██║ ╚████║╚██████╔╝███████╗███████╗           ║
echo    ║    ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝           ║
echo    ║                                                          ║
echo    ║          ██████╗██╗      ██████╗ ██╗   ██╗██████╗        ║
echo    ║         ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗       ║
echo    ║         ██║     ██║     ██║   ██║██║   ██║██║  ██║       ║
echo    ║         ██║     ██║     ██║   ██║██║   ██║██║  ██║       ║
echo    ║         ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝      ║
echo    ║          ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝       ║
echo    ║                                                          ║
echo    ║          AI TRAINING TOOLS                               ║
echo    ║          Local AI literacy for every person.             ║
echo    ║                                                          ║
echo    ╚══════════════════════════════════════════════════════════╝
echo.

:: ============================================================
:: HEALTH CHECKS
:: ============================================================
echo  [SYSTEM CHECK] Running pre-flight diagnostics...
echo.

:: --- RAM CHECK ---
for /f "tokens=2 delims==" %%a in ('wmic os get FreePhysicalMemory /value 2^>nul ^| find "="') do set "FREE_RAM_KB=%%a"
:: Remove carriage returns
set "FREE_RAM_KB=%FREE_RAM_KB: =%"
set /a FREE_RAM_MB=%FREE_RAM_KB% / 1024 2>nul

if %FREE_RAM_MB% LSS 2048 (
    echo  [91m  ✗ BLOCKED: Only %FREE_RAM_MB%MB RAM free. Need at least 2048MB.[0m
    echo    Close some applications and try again.
    echo.
    pause
    exit /b 1
)
if %FREE_RAM_MB% LSS 4096 (
    echo  [93m  ⚠ WARNING: Only %FREE_RAM_MB%MB RAM free. Recommended: 4096MB+[0m
    echo    Training will run, but performance may be slow.
) else (
    echo  [92m  ✓ RAM: %FREE_RAM_MB%MB free — good to go[0m
)

:: --- OLLAMA CHECK ---
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [93m  ⚠ Ollama is not running.[0m
    echo    Starting Ollama...
    start "" ollama serve >nul 2>&1
    timeout /t 3 /nobreak >nul
    curl -s http://localhost:11434/api/tags >nul 2>&1
    if !errorlevel! NEQ 0 (
        echo  [91m  ✗ Could not start Ollama. Please start it manually.[0m
        echo    Run: ollama serve
        pause
        exit /b 1
    )
)
echo  [92m  ✓ Ollama: Running[0m

:: --- WEAVIATE CHECK ---
curl -s http://localhost:8080/v1/.well-known/ready >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [93m  ⚠ Weaviate not detected at localhost:8080[0m
    echo    Some modules require Weaviate. Start it if needed.
) else (
    echo  [92m  ✓ Weaviate: Running[0m
)

:: --- MODEL CHECK ---
curl -s http://localhost:11434/api/tags 2>nul | findstr /i "llama3.2:1b" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [93m  ⚠ Model llama3.2:1b not found. Module 1.1 will help you pull it.[0m
) else (
    echo  [92m  ✓ Model: llama3.2:1b loaded[0m
)

echo.
echo  ──────────────────────────────────────────────────────────
echo.

:: ============================================================
:: PROGRESS LOADING
:: ============================================================
:: Initialize progress file if it doesn't exist
if not exist "%PROGRESS_FILE%" (
    echo { > "%PROGRESS_FILE%"
    echo   "user": "default", >> "%PROGRESS_FILE%"
    echo   "started": "%date% %time%", >> "%PROGRESS_FILE%"
    echo   "modules_completed": [], >> "%PROGRESS_FILE%"
    echo   "current_module": "1.1" >> "%PROGRESS_FILE%"
    echo } >> "%PROGRESS_FILE%"
)

:: Check completed modules (simple findstr-based check)
set "M11=[ ]" & set "M12=[ ]" & set "M13=[ ]" & set "M14=[ ]" & set "M15=[ ]"
findstr /c:"1.1" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M11=[✓]"
findstr /c:"1.2" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M12=[✓]"
findstr /c:"1.3" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M13=[✓]"
findstr /c:"1.4" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M14=[✓]"
findstr /c:"1.5" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M15=[✓]"

:: ============================================================
:: MAIN MENU
:: ============================================================
:menu
echo   PHASE 1 — BUILDERS  [92m[UNLOCKED][0m
echo   ─────────────────────────────────────
echo     %M11% 1.1  Your First Local LLM         (15 min)
echo     %M12% 1.2  Vectors Made Simple           (15 min)
echo     %M13% 1.3  Build Your Brain              (15 min)
echo     %M14% 1.4  Prompt Engineering for Local   (15 min)
echo     %M15% 1.5  Ship It                        (15 min)
echo.
echo   PHASE 2 — OPERATORS  [93m[COMING SOON][0m
echo   PHASE 3 — EVERYDAY   [93m[COMING SOON][0m
echo   PHASE 4 — LEGACY     [93m[COMING SOON][0m
echo.
echo   ─────────────────────────────────────
echo     H  Health Check     R  Reset Progress
echo     Q  Quit
echo.
set /p "CHOICE=  Select module (1.1-1.5) or option: "

if "%CHOICE%"=="1.1" goto mod11
if "%CHOICE%"=="1.2" goto mod12
if "%CHOICE%"=="1.3" goto mod13
if "%CHOICE%"=="1.4" goto mod14
if "%CHOICE%"=="1.5" goto mod15
if /i "%CHOICE%"=="H" goto healthcheck
if /i "%CHOICE%"=="R" goto resetprogress
if /i "%CHOICE%"=="Q" goto quit
echo  [91m  Invalid selection. Try again.[0m
echo.
goto menu

:: ============================================================
:: MODULE LAUNCHERS
:: ============================================================
:mod11
set "MOD_DIR=%BASE_DIR%phases\phase-1-builders\module-1.1-first-local-llm"
goto run_module

:mod12
set "MOD_DIR=%BASE_DIR%phases\phase-1-builders\module-1.2-vectors"
goto run_module

:mod13
set "MOD_DIR=%BASE_DIR%phases\phase-1-builders\module-1.3-build-your-brain"
goto run_module

:mod14
set "MOD_DIR=%BASE_DIR%phases\phase-1-builders\module-1.4-prompt-engineering"
goto run_module

:mod15
set "MOD_DIR=%BASE_DIR%phases\phase-1-builders\module-1.5-ship-it"
goto run_module

:run_module
cls
echo.
echo  ══════════════════════════════════════════════════════
echo   LESSON
echo  ══════════════════════════════════════════════════════
echo.
if exist "%MOD_DIR%\lesson.md" (
    type "%MOD_DIR%\lesson.md"
) else (
    echo  [91m  Module not yet built. Check back soon.[0m
    pause
    goto banner
)
echo.
echo  ══════════════════════════════════════════════════════
echo.
set /p "CONTINUE=  Press E to start EXERCISE, H for HINTS, B to go back: "
if /i "%CONTINUE%"=="E" (
    if exist "%MOD_DIR%\exercise.bat" (
        call "%MOD_DIR%\exercise.bat"
    ) else (
        echo  [91m  Exercise not found.[0m
    )
) else if /i "%CONTINUE%"=="H" (
    if exist "%MOD_DIR%\hints.md" (
        type "%MOD_DIR%\hints.md"
    ) else (
        echo  [93m  No hints available for this module.[0m
    )
    pause
    goto run_module
) else if /i "%CONTINUE%"=="B" (
    goto banner
)

echo.
echo  ──────────────────────────────────────────────────────
set /p "VERIFY=  Press V to VERIFY your exercise, B to go back: "
if /i "%VERIFY%"=="V" (
    if exist "%MOD_DIR%\verify.bat" (
        call "%MOD_DIR%\verify.bat"
        if !errorlevel! EQU 0 (
            echo.
            echo  [92m  ══════════════════════════════════════════[0m
            echo  [92m   ✓ MODULE COMPLETE — Nice work.          [0m
            echo  [92m  ══════════════════════════════════════════[0m
        ) else (
            echo.
            echo  [91m  ✗ Not quite. Review the hints and try again.[0m
        )
    ) else (
        echo  [91m  Verify script not found.[0m
    )
)

echo.
pause
goto banner

:: ============================================================
:: UTILITIES
:: ============================================================
:healthcheck
cls
if exist "%HEALTH_CHECK%" (
    call "%HEALTH_CHECK%"
) else (
    echo  Health check script not found at: %HEALTH_CHECK%
)
pause
goto banner

:resetprogress
echo.
set /p "CONFIRM=  Reset all progress? This cannot be undone. (Y/N): "
if /i "%CONFIRM%"=="Y" (
    echo { > "%PROGRESS_FILE%"
    echo   "user": "default", >> "%PROGRESS_FILE%"
    echo   "started": "%date% %time%", >> "%PROGRESS_FILE%"
    echo   "modules_completed": [], >> "%PROGRESS_FILE%"
    echo   "current_module": "1.1" >> "%PROGRESS_FILE%"
    echo } >> "%PROGRESS_FILE%"
    echo  [92m  Progress reset.[0m
)
pause
goto banner

:quit
echo.
echo   Keep building. Your legacy runs local.
echo.
endlocal
exit /b 0
