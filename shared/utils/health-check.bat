@echo off
setlocal enabledelayedexpansion
title Angel Cloud — System Health Check

:: ============================================================
:: ANGEL CLOUD HEALTH CHECK
:: Checks: RAM, Ollama, Weaviate, Model availability
:: Safe to run anytime — read-only, changes nothing
:: ============================================================

echo.
echo  ══════════════════════════════════════════════════════
echo   ANGEL CLOUD — SYSTEM HEALTH CHECK
echo  ══════════════════════════════════════════════════════
echo.
echo   Hardware ceiling: 7.4GB RAM
echo   Module budget:    3.0GB max per module
echo   Timestamp:        %date% %time%
echo.
echo  ──────────────────────────────────────────────────────
echo.

:: === RAM CHECK ===
echo  [RAM]
for /f "tokens=2 delims==" %%a in ('wmic os get FreePhysicalMemory /value 2^>nul ^| find "="') do set "FREE_RAM_KB=%%a"
set "FREE_RAM_KB=%FREE_RAM_KB: =%"
set /a FREE_RAM_MB=%FREE_RAM_KB% / 1024 2>nul

for /f "tokens=2 delims==" %%a in ('wmic os get TotalVisibleMemorySize /value 2^>nul ^| find "="') do set "TOTAL_RAM_KB=%%a"
set "TOTAL_RAM_KB=%TOTAL_RAM_KB: =%"
set /a TOTAL_RAM_MB=%TOTAL_RAM_KB% / 1024 2>nul

set /a USED_RAM_MB=%TOTAL_RAM_MB% - %FREE_RAM_MB%

echo    Total:     %TOTAL_RAM_MB% MB
echo    Used:      %USED_RAM_MB% MB
echo    Free:      %FREE_RAM_MB% MB

if %FREE_RAM_MB% LSS 2048 (
    echo  [91m   STATUS: CRITICAL — Below 2GB free. Cannot run modules safely.[0m
) else if %FREE_RAM_MB% LSS 4096 (
    echo  [93m   STATUS: WARNING — Below 4GB free. May be slow.[0m
) else (
    echo  [92m   STATUS: GOOD[0m
)
echo.

:: === OLLAMA CHECK ===
echo  [OLLAMA]
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   Server:  Running on localhost:11434[0m

    :: Check for specific model
    curl -s http://localhost:11434/api/tags 2>nul | findstr /i "llama3.2:1b" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [92m   Model:   llama3.2:1b available[0m
    ) else (
        echo  [93m   Model:   llama3.2:1b NOT found — run: ollama pull llama3.2:1b[0m
    )

    :: List all models
    echo    Models installed:
    for /f "tokens=1" %%m in ('curl -s http://localhost:11434/api/tags 2^>nul ^| findstr /i "name"') do (
        echo      %%m
    )
) else (
    echo  [91m   Server:  NOT RUNNING[0m
    echo            Fix: Run "ollama serve" in a separate terminal
)
echo.

:: === WEAVIATE CHECK ===
echo  [WEAVIATE]
curl -s http://localhost:8080/v1/.well-known/ready >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   Server:  Running on localhost:8080[0m

    :: Check for schema/classes
    curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "class" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [92m   Schema:  Classes detected[0m
    ) else (
        echo  [93m   Schema:  No classes found (empty database)[0m
    )
) else (
    echo  [91m   Server:  NOT RUNNING[0m
    echo            Weaviate is needed for Modules 1.2+
    echo            Check your Docker/Weaviate service
)
echo.

:: === DISK CHECK ===
echo  [DISK]
for /f "tokens=3" %%a in ('dir D:\ 2^>nul ^| findstr /i "bytes free"') do set "FREE_DISK=%%a"
echo    D: drive free space: %FREE_DISK% bytes
echo.

:: === SUMMARY ===
echo  ══════════════════════════════════════════════════════
echo   Health check complete. Review any warnings above.
echo  ══════════════════════════════════════════════════════
echo.

endlocal
exit /b 0
