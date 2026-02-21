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
set "M21=[ ]" & set "M22=[ ]" & set "M23=[ ]" & set "M24=[ ]" & set "M25=[ ]" & set "M26=[ ]" & set "M27=[ ]"
set "M31=[ ]" & set "M32=[ ]" & set "M33=[ ]" & set "M34=[ ]" & set "M35=[ ]" & set "M36=[ ]" & set "M37=[ ]"
set "M41=[ ]" & set "M42=[ ]" & set "M43=[ ]" & set "M44=[ ]" & set "M45=[ ]" & set "M46=[ ]" & set "M47=[ ]"
findstr /c:"1.1" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M11=[✓]"
findstr /c:"1.2" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M12=[✓]"
findstr /c:"1.3" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M13=[✓]"
findstr /c:"1.4" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M14=[✓]"
findstr /c:"1.5" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M15=[✓]"
findstr /c:"2.1" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M21=[✓]"
findstr /c:"2.2" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M22=[✓]"
findstr /c:"2.3" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M23=[✓]"
findstr /c:"2.4" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M24=[✓]"
findstr /c:"2.5" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M25=[✓]"
findstr /c:"2.6" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M26=[✓]"
findstr /c:"2.7" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M27=[✓]"
findstr /c:"3.1" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M31=[✓]"
findstr /c:"3.2" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M32=[✓]"
findstr /c:"3.3" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M33=[✓]"
findstr /c:"3.4" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M34=[✓]"
findstr /c:"3.5" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M35=[✓]"
findstr /c:"3.6" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M36=[✓]"
findstr /c:"3.7" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M37=[✓]"
findstr /c:"4.1" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M41=[✓]"
findstr /c:"4.2" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M42=[✓]"
findstr /c:"4.3" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M43=[✓]"
findstr /c:"4.4" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M44=[✓]"
findstr /c:"4.5" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M45=[✓]"
findstr /c:"4.6" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M46=[✓]"
findstr /c:"4.7" "%PROGRESS_FILE%" | findstr /c:"completed" >nul 2>&1 && set "M47=[✓]"

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
echo.
echo   PHASE 2 — OPERATORS  [92m[UNLOCKED][0m
echo   ─────────────────────────────────────
echo     %M21% 2.1  Load Your Business Brain     (15 min)
echo     %M22% 2.2  The Instant Answer Desk      (15 min)
echo     %M23% 2.3  Draft It                      (20 min)
echo     %M24% 2.4  Sort and Route                (15 min)
echo     %M25% 2.5  Paperwork Machine             (20 min)
echo     %M26% 2.6  Chain Reactions                (20 min)
echo     %M27% 2.7  Your Operator Dashboard        (15 min)
echo.
echo   PHASE 3 — EVERYDAY  [92m[UNLOCKED — MCP][0m
echo   ─────────────────────────────────────
echo     %M31% 3.1  Your Private Vault         (15 min)
echo     %M32% 3.2  Ask Your Vault             (15 min)
echo     %M33% 3.3  Write It Right             (15 min)
echo     %M34% 3.4  Lock It Down               (15 min)
echo     %M35% 3.5  Daily Briefing             (15 min)
echo     %M36% 3.6  Digital Footprint          (15 min)
echo     %M37% 3.7  Family Dashboard           (20 min)
echo.
echo   PHASE 4 — LEGACY  [92m[UNLOCKED — MCP][0m
echo   ─────────────────────────────────────
echo     %M41% 4.1  What Is a Brain?          (15 min)
echo     %M42% 4.2  Feed Your Brain           (15 min)
echo     %M43% 4.3  Talk to Your Brain        (15 min)
echo     %M44% 4.4  Your Daily Companion      (15 min)
echo     %M45% 4.5  Write Your Story          (15 min)
echo     %M46% 4.6  Guard Your Legacy         (15 min)
echo     %M47% 4.7  Pass It On (Capstone)     (20 min)
echo.
echo   ─────────────────────────────────────
echo     H  Health Check     R  Reset Progress
echo     Q  Quit
echo.
set /p "CHOICE=  Select module (1.1-4.7) or option: "

if "%CHOICE%"=="1.1" goto mod11
if "%CHOICE%"=="1.2" goto mod12
if "%CHOICE%"=="1.3" goto mod13
if "%CHOICE%"=="1.4" goto mod14
if "%CHOICE%"=="1.5" goto mod15
if "%CHOICE%"=="2.1" goto mod21
if "%CHOICE%"=="2.2" goto mod22
if "%CHOICE%"=="2.3" goto mod23
if "%CHOICE%"=="2.4" goto mod24
if "%CHOICE%"=="2.5" goto mod25
if "%CHOICE%"=="2.6" goto mod26
if "%CHOICE%"=="2.7" goto mod27
if "%CHOICE%"=="3.1" goto mod31
if "%CHOICE%"=="3.2" goto mod32
if "%CHOICE%"=="3.3" goto mod33
if "%CHOICE%"=="3.4" goto mod34
if "%CHOICE%"=="3.5" goto mod35
if "%CHOICE%"=="3.6" goto mod36
if "%CHOICE%"=="3.7" goto mod37
if "%CHOICE%"=="4.1" goto mod41
if "%CHOICE%"=="4.2" goto mod42
if "%CHOICE%"=="4.3" goto mod43
if "%CHOICE%"=="4.4" goto mod44
if "%CHOICE%"=="4.5" goto mod45
if "%CHOICE%"=="4.6" goto mod46
if "%CHOICE%"=="4.7" goto mod47
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

:mod21
set "MOD_DIR=%BASE_DIR%phases\phase-2-operators\module-2.1-load-your-business-brain"
goto run_module

:mod22
set "MOD_DIR=%BASE_DIR%phases\phase-2-operators\module-2.2-instant-answer-desk"
goto run_module

:mod23
set "MOD_DIR=%BASE_DIR%phases\phase-2-operators\module-2.3-draft-it"
goto run_module

:mod24
set "MOD_DIR=%BASE_DIR%phases\phase-2-operators\module-2.4-sort-and-route"
goto run_module

:mod25
set "MOD_DIR=%BASE_DIR%phases\phase-2-operators\module-2.5-paperwork-machine"
goto run_module

:mod26
set "MOD_DIR=%BASE_DIR%phases\phase-2-operators\module-2.6-chain-reactions"
goto run_module

:mod27
set "MOD_DIR=%BASE_DIR%phases\phase-2-operators\module-2.7-operator-dashboard"
goto run_module

:mod31
set "MOD_DIR=%BASE_DIR%phases\phase-3-everyday\module-3.1-your-private-vault"
goto run_module

:mod32
set "MOD_DIR=%BASE_DIR%phases\phase-3-everyday\module-3.2-ask-your-vault"
goto run_module

:mod33
set "MOD_DIR=%BASE_DIR%phases\phase-3-everyday\module-3.3-write-it-right"
goto run_module

:mod34
set "MOD_DIR=%BASE_DIR%phases\phase-3-everyday\module-3.4-lock-it-down"
goto run_module

:mod35
set "MOD_DIR=%BASE_DIR%phases\phase-3-everyday\module-3.5-daily-briefing"
goto run_module

:mod36
set "MOD_DIR=%BASE_DIR%phases\phase-3-everyday\module-3.6-digital-footprint"
goto run_module

:mod37
set "MOD_DIR=%BASE_DIR%phases\phase-3-everyday\module-3.7-family-dashboard"
goto run_module

:mod41
set "MOD_DIR=%BASE_DIR%phases\phase-4-legacy\module-4.1-what-is-a-brain"
goto run_module

:mod42
set "MOD_DIR=%BASE_DIR%phases\phase-4-legacy\module-4.2-feed-your-brain"
goto run_module

:mod43
set "MOD_DIR=%BASE_DIR%phases\phase-4-legacy\module-4.3-talk-to-your-brain"
goto run_module

:mod44
set "MOD_DIR=%BASE_DIR%phases\phase-4-legacy\module-4.4-your-daily-companion"
goto run_module

:mod45
set "MOD_DIR=%BASE_DIR%phases\phase-4-legacy\module-4.5-write-your-story"
goto run_module

:mod46
set "MOD_DIR=%BASE_DIR%phases\phase-4-legacy\module-4.6-guard-your-legacy"
goto run_module

:mod47
set "MOD_DIR=%BASE_DIR%phases\phase-4-legacy\module-4.7-pass-it-on"
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
