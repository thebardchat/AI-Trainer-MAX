@echo off
setlocal enabledelayedexpansion
title Module 5.1 Exercise — Lock the Gates

:: ============================================================
:: MODULE 5.1 EXERCISE: Lock the Gates
:: Goal: Port scanning, firewall verification, LAN exposure
::       testing, and hardening report generation
:: Time: ~15 minutes
:: Prerequisites: Module 3.4
:: MCP Tools: system_health, security_log_search
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.1"

echo.
echo  ======================================================
echo   MODULE 5.1 EXERCISE: Lock the Gates
echo  ======================================================
echo.
echo   You're going beyond log reading. This time you walk
echo   the fence line — scanning ports, checking bindings,
echo   verifying the firewall, and writing a hardening report.
echo.
echo   You are a multiplier now. Secure your system, then
echo   teach someone else to do the same.
echo.
echo  ------------------------------------------------------
echo.

:: --- PRE-FLIGHT: Check MCP server ---
echo  [PRE-FLIGHT] Checking MCP server...
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

python "%MCP_CALL%" system_health > "%TEMP_DIR%\preflight.txt" 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   X MCP server not reachable. Is ShaneBrain running?[0m
    echo       Check: python "%MCP_CALL%" system_health
    pause
    exit /b 1
)
echo  [92m   PASS: MCP server responding[0m
echo.

:: ============================================================
:: TASK 1: Scan listening ports with netstat
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 1/5] Port scan — what doors are open?
echo.
echo   Running netstat to find all listening ports.
echo   Think of this as walking every loading dock at the
echo   warehouse and checking which doors are unlocked.
echo.

netstat -an > "%TEMP_DIR%\netstat_full.txt" 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   FAIL: netstat command failed[0m
    echo       This command is built into Windows. If it failed,
    echo       try running this script as Administrator.
    pause
    exit /b 1
)

:: Filter for LISTENING ports only
findstr /i "LISTENING" "%TEMP_DIR%\netstat_full.txt" > "%TEMP_DIR%\listening.txt" 2>nul

echo   ======================================================
echo   LISTENING PORTS ON THIS MACHINE:
echo   ======================================================
echo.
type "%TEMP_DIR%\listening.txt" 2>nul
echo.
echo   ======================================================
echo.

:: Count total listening ports
set "LISTEN_COUNT=0"
for /f %%a in ('findstr /c:"LISTENING" "%TEMP_DIR%\netstat_full.txt" ^| find /c /v ""') do set "LISTEN_COUNT=%%a"
echo  [92m   Found %LISTEN_COUNT% listening ports on this machine[0m
echo.
echo   Press any key to check AI service bindings...
pause >nul
echo.

:: ============================================================
:: TASK 2: Check AI service binding addresses
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 2/5] Binding check — who can reach your AI?
echo.
echo   Checking if Ollama (11434), Weaviate (8080), and
echo   MCP (8100) are bound to localhost or the network.
echo.
echo   127.0.0.1 = local only (good — locked to this machine)
echo   0.0.0.0   = network exposed (check if intentional)
echo.

set "EXPOSED_COUNT=0"
set "LOCAL_COUNT=0"
set "MISSING_COUNT=0"

:: Check port 11434 (Ollama)
findstr /c:":11434" "%TEMP_DIR%\listening.txt" > "%TEMP_DIR%\port_11434.txt" 2>nul
if %errorlevel% EQU 0 (
    findstr /c:"0.0.0.0:11434" "%TEMP_DIR%\listening.txt" > nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [93m   Ollama (11434): LISTENING on 0.0.0.0 — NETWORK EXPOSED[0m
        set /a EXPOSED_COUNT+=1
    ) else (
        findstr /c:"127.0.0.1:11434" "%TEMP_DIR%\listening.txt" > nul 2>&1
        if !errorlevel! EQU 0 (
            echo  [92m   Ollama (11434): LISTENING on 127.0.0.1 — LOCAL ONLY[0m
            set /a LOCAL_COUNT+=1
        ) else (
            echo  [92m   Ollama (11434): LISTENING — bound address varies[0m
            set /a LOCAL_COUNT+=1
        )
    )
) else (
    echo  [93m   Ollama (11434): NOT LISTENING — service may be stopped[0m
    set /a MISSING_COUNT+=1
)

:: Check port 8080 (Weaviate)
findstr /c:":8080" "%TEMP_DIR%\listening.txt" > "%TEMP_DIR%\port_8080.txt" 2>nul
if %errorlevel% EQU 0 (
    findstr /c:"0.0.0.0:8080" "%TEMP_DIR%\listening.txt" > nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [93m   Weaviate (8080): LISTENING on 0.0.0.0 — NETWORK EXPOSED[0m
        set /a EXPOSED_COUNT+=1
    ) else (
        findstr /c:"127.0.0.1:8080" "%TEMP_DIR%\listening.txt" > nul 2>&1
        if !errorlevel! EQU 0 (
            echo  [92m   Weaviate (8080): LISTENING on 127.0.0.1 — LOCAL ONLY[0m
            set /a LOCAL_COUNT+=1
        ) else (
            echo  [92m   Weaviate (8080): LISTENING — bound address varies[0m
            set /a LOCAL_COUNT+=1
        )
    )
) else (
    echo  [93m   Weaviate (8080): NOT LISTENING — service may be stopped[0m
    set /a MISSING_COUNT+=1
)

:: Check port 8100 (MCP Server)
findstr /c:":8100" "%TEMP_DIR%\listening.txt" > "%TEMP_DIR%\port_8100.txt" 2>nul
if %errorlevel% EQU 0 (
    findstr /c:"0.0.0.0:8100" "%TEMP_DIR%\listening.txt" > nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [93m   MCP Server (8100): LISTENING on 0.0.0.0 — NETWORK EXPOSED[0m
        set /a EXPOSED_COUNT+=1
    ) else (
        findstr /c:"127.0.0.1:8100" "%TEMP_DIR%\listening.txt" > nul 2>&1
        if !errorlevel! EQU 0 (
            echo  [92m   MCP Server (8100): LISTENING on 127.0.0.1 — LOCAL ONLY[0m
            set /a LOCAL_COUNT+=1
        ) else (
            echo  [92m   MCP Server (8100): LISTENING — bound address varies[0m
            set /a LOCAL_COUNT+=1
        )
    )
) else (
    echo  [93m   MCP Server (8100): NOT LISTENING — service may be stopped[0m
    set /a MISSING_COUNT+=1
)

echo.
echo   Summary: !LOCAL_COUNT! local-only, !EXPOSED_COUNT! network-exposed, !MISSING_COUNT! not found
echo.

if !EXPOSED_COUNT! GTR 0 (
    echo  [93m   WARNING: !EXPOSED_COUNT! service(s) exposed to your network.[0m
    echo   This may be intentional (multi-device setup) or a risk.
    echo   The firewall check next will tell you more.
) else if !LOCAL_COUNT! GTR 0 (
    echo  [92m   All detected services are bound to localhost. Solid.[0m
)
echo.
echo   Press any key to check the firewall...
pause >nul
echo.

:: ============================================================
:: TASK 3: Check Windows Firewall status
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 3/5] Firewall check — is the fence up?
echo.
echo   Even if a service is exposed, the firewall can block
echo   outside connections. This is your second line of defense.
echo.

netsh advfirewall show currentprofile > "%TEMP_DIR%\firewall.txt" 2>&1
if %errorlevel% EQU 0 (
    echo   ======================================================
    echo   FIREWALL STATUS:
    echo   ======================================================
    echo.
    type "%TEMP_DIR%\firewall.txt"
    echo.
    echo   ======================================================
    echo.

    :: Check if firewall is ON
    findstr /i /c:"State" "%TEMP_DIR%\firewall.txt" | findstr /i /c:"ON" > nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [92m   Firewall State: ON[0m

        :: Check inbound policy
        findstr /i /c:"BlockInbound" "%TEMP_DIR%\firewall.txt" > nul 2>&1
        if !errorlevel! EQU 0 (
            echo  [92m   Inbound Policy: BLOCK (default deny — correct)[0m
        ) else (
            echo  [93m   Inbound Policy: Check the output above for policy details[0m
        )
    ) else (
        findstr /i /c:"State" "%TEMP_DIR%\firewall.txt" | findstr /i /c:"OFF" > nul 2>&1
        if !errorlevel! EQU 0 (
            echo  [91m   Firewall State: OFF — YOUR MACHINE IS UNPROTECTED[0m
            echo.
            echo   Fix this immediately:
            echo     netsh advfirewall set currentprofile state on
            echo.
            echo   This enables the firewall for your current network profile.
        ) else (
            echo  [93m   Firewall State: Could not determine — review output above[0m
        )
    )
) else (
    echo  [93m   Could not query firewall. You may need to run as Administrator.[0m
    echo   Try: netsh advfirewall show currentprofile
)
echo.
echo   Press any key to generate the hardening report...
pause >nul
echo.

:: ============================================================
:: TASK 4: Generate hardening report
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 4/5] Hardening report — document what you found
echo.

:: Build the report file
echo ====================================================== > "%TEMP_DIR%\hardening-report.txt"
echo  HARDENING REPORT — Module 5.1 Lock the Gates >> "%TEMP_DIR%\hardening-report.txt"
echo  Generated: %date% %time% >> "%TEMP_DIR%\hardening-report.txt"
echo ====================================================== >> "%TEMP_DIR%\hardening-report.txt"
echo. >> "%TEMP_DIR%\hardening-report.txt"
echo --- PORT SCAN RESULTS --- >> "%TEMP_DIR%\hardening-report.txt"
echo Total listening ports: %LISTEN_COUNT% >> "%TEMP_DIR%\hardening-report.txt"
echo. >> "%TEMP_DIR%\hardening-report.txt"
echo AI Service Bindings: >> "%TEMP_DIR%\hardening-report.txt"
echo   Local-only services: !LOCAL_COUNT! >> "%TEMP_DIR%\hardening-report.txt"
echo   Network-exposed services: !EXPOSED_COUNT! >> "%TEMP_DIR%\hardening-report.txt"
echo   Services not found: !MISSING_COUNT! >> "%TEMP_DIR%\hardening-report.txt"
echo. >> "%TEMP_DIR%\hardening-report.txt"
echo --- FIREWALL STATUS --- >> "%TEMP_DIR%\hardening-report.txt"
type "%TEMP_DIR%\firewall.txt" >> "%TEMP_DIR%\hardening-report.txt" 2>nul
echo. >> "%TEMP_DIR%\hardening-report.txt"
echo --- AI SERVICE PORTS --- >> "%TEMP_DIR%\hardening-report.txt"
findstr /c:":11434 " "%TEMP_DIR%\listening.txt" >> "%TEMP_DIR%\hardening-report.txt" 2>nul
findstr /c:":8080 " "%TEMP_DIR%\listening.txt" >> "%TEMP_DIR%\hardening-report.txt" 2>nul
findstr /c:":8100 " "%TEMP_DIR%\listening.txt" >> "%TEMP_DIR%\hardening-report.txt" 2>nul
echo. >> "%TEMP_DIR%\hardening-report.txt"
echo ====================================================== >> "%TEMP_DIR%\hardening-report.txt"

echo   Report saved to: %TEMP_DIR%\hardening-report.txt
echo.
echo   ======================================================
echo   HARDENING REPORT SUMMARY:
echo   ======================================================
echo.
type "%TEMP_DIR%\hardening-report.txt"
echo.

if !EXPOSED_COUNT! GTR 0 (
    echo  [93m   RECOMMENDATION: Review exposed services.[0m
    echo   If you don't need network access, rebind them to 127.0.0.1.
    echo   Check the Docker compose or service config for each one.
) else (
    echo  [92m   ASSESSMENT: Your AI services look properly locked down.[0m
)
echo.
echo   Press any key to log the security check...
pause >nul
echo.

:: ============================================================
:: TASK 5: Log the security check via MCP
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 5/5] Log the audit — leave a trail
echo.
echo   Recording this security check via MCP so there's a
echo   record you audited the system on this date.
echo.

:: Run system_health to confirm and log
python "%MCP_CALL%" system_health > "%TEMP_DIR%\final_health.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: System health logged[0m
) else (
    echo  [93m   WARN: Could not log final health check[0m
)

:: Search security logs for any recent events
python "%MCP_CALL%" security_log_search "{\"query\":\"port scan firewall audit\"}" > "%TEMP_DIR%\sec_log.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Security log search completed[0m
) else (
    echo  [93m   WARN: Security log search returned an error (may be empty — that's OK)[0m
)
echo.

:: ============================================================
:exercise_done
echo.
echo  ======================================================
echo   EXERCISE COMPLETE
echo  ======================================================
echo.
echo   You walked the fence line. You know:
echo.
echo     - Which ports are open on your machine
echo     - Whether your AI services face the network or stay local
echo     - Whether the firewall is up and blocking
echo     - How to generate and read a hardening report
echo.
echo   This is what defenders do. Not once — regularly.
echo   Teach someone else to run these same checks.
echo.
echo   Your hardening report is at:
echo     %TEMP_DIR%\hardening-report.txt
echo.
echo   Now run verify.bat to confirm everything passed:
echo.
echo       verify.bat
echo.

:: Cleanup temp files (keep hardening report for verify)
:: Full cleanup happens in verify or on next run

pause
endlocal
exit /b 0
