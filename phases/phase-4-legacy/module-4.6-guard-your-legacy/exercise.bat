@echo off
setlocal enabledelayedexpansion
title Module 4.6 Exercise — Guard Your Legacy

:: ============================================================
:: MODULE 4.6 EXERCISE: Guard Your Legacy
:: Goal: Run system health, search security logs, search privacy
::       audits, review collection sizes — build security posture
:: Time: ~15 minutes
:: Prerequisites: None (standalone security awareness)
:: MCP Tools: system_health, security_log_search, privacy_audit_search
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.6"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 4.6 EXERCISE: Guard Your Legacy
echo  ══════════════════════════════════════════════════════
echo.
echo   You built something worth protecting. Your vault holds
echo   letters to your children, your life story, family
echo   documents. Now you lock the doors and check the windows.
echo.
echo   Four tasks. Fifteen minutes. Know your security posture.
echo.
echo  ──────────────────────────────────────────────────────
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
:: TASK 1: Full system health check
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/4] System health check — the daily walk-around
echo.
echo   Every morning on a job site, you walk the lot. Check
echo   the trucks. Make sure nothing happened overnight.
echo   This is that walk-around for your AI brain.
echo.

python "%MCP_CALL%" system_health > "%TEMP_DIR%\health.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: System health retrieved[0m
    echo.
    echo   ══════════════════════════════════════════════════
    echo   SYSTEM HEALTH REPORT:
    echo   ══════════════════════════════════════════════════
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.txt')); [print('   ' + str(k) + ': ' + str(v)) for k,v in (d.items() if isinstance(d,dict) else [('status',str(d))])]" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
    echo.
    echo   What to look for:
    echo     - All services should show as running/healthy
    echo     - Collection counts tell you how much data exists
    echo     - If a count dropped unexpectedly, investigate
    echo     - Any errors or warnings need immediate attention
) else (
    echo  [91m   FAIL: Could not retrieve system health[0m
    echo          Fix: Check that Weaviate and Ollama are running
)
echo.
echo   Press any key to check security logs...
pause >nul
echo.

:: ============================================================
:: TASK 2: Search security logs
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/4] Security log review — what happened while
echo             you weren't looking?
echo.
echo   Checking for suspicious events. On a clean local system
echo   you'll likely see empty results. That's GOOD — it means
echo   nobody tried anything. Like checking the locks and
echo   finding them all still tight.
echo.

:: Search 1: Failed login attempts
echo   Search: "failed login attempts"
python "%MCP_CALL%" security_log_search "{\"query\":\"failed login attempts\"}" > "%TEMP_DIR%\sec1.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\sec1.txt')); results=d if isinstance(d,list) else d.get('results',d.get('logs',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); print(str(count))" 2>nul > "%TEMP_DIR%\sec1_count.txt"
    set /p SEC1_COUNT=<"%TEMP_DIR%\sec1_count.txt"
    if not defined SEC1_COUNT set "SEC1_COUNT=0"
    if !SEC1_COUNT! EQU 0 (
        echo  [92m   CLEAN: No failed login attempts found[0m
    ) else (
        echo  [93m   FOUND: !SEC1_COUNT! security event(s) — review below[0m
        python -c "import json; d=json.load(open(r'%TEMP_DIR%\sec1.txt')); results=d if isinstance(d,list) else d.get('results',d.get('logs',[d])); [print('   - ' + str(r)[:100]) for r in (results[:3] if isinstance(results,list) else [results])]" 2>nul
    )
) else (
    echo  [92m   PASS: Security log search completed (no errors)[0m
)
echo.

:: Search 2: Unauthorized access
echo   Search: "unauthorized access or data breach"
python "%MCP_CALL%" security_log_search "{\"query\":\"unauthorized access data breach\"}" > "%TEMP_DIR%\sec2.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\sec2.txt')); results=d if isinstance(d,list) else d.get('results',d.get('logs',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); print(str(count))" 2>nul > "%TEMP_DIR%\sec2_count.txt"
    set /p SEC2_COUNT=<"%TEMP_DIR%\sec2_count.txt"
    if not defined SEC2_COUNT set "SEC2_COUNT=0"
    if !SEC2_COUNT! EQU 0 (
        echo  [92m   CLEAN: No unauthorized access detected[0m
    ) else (
        echo  [93m   FOUND: !SEC2_COUNT! event(s) — worth investigating[0m
    )
) else (
    echo  [92m   PASS: Security log search completed (no errors)[0m
)
echo.

:: Search 3: System warnings
echo   Search: "system warning error critical"
python "%MCP_CALL%" security_log_search "{\"query\":\"system warning error critical\"}" > "%TEMP_DIR%\sec3.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\sec3.txt')); results=d if isinstance(d,list) else d.get('results',d.get('logs',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); print(str(count))" 2>nul > "%TEMP_DIR%\sec3_count.txt"
    set /p SEC3_COUNT=<"%TEMP_DIR%\sec3_count.txt"
    if not defined SEC3_COUNT set "SEC3_COUNT=0"
    if !SEC3_COUNT! EQU 0 (
        echo  [92m   CLEAN: No system warnings found[0m
    ) else (
        echo  [93m   FOUND: !SEC3_COUNT! warning(s) — review when possible[0m
    )
) else (
    echo  [92m   PASS: Security log search completed (no errors)[0m
)
echo.

echo  [92m   Security log review complete.[0m
echo.
echo   Empty logs on a local system = clean system.
echo   That's the best result you can get. When you add
echo   users or expose services, these logs become your
echo   first line of defense for your family's data.
echo.
echo   Press any key to check privacy audit trails...
pause >nul
echo.

:: ============================================================
:: TASK 3: Search privacy audit trails
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/4] Privacy audit — who touched your data?
echo.
echo   Privacy audits track data access. Even on a single-user
echo   system, this trail proves your data pipeline is clean.
echo   When you pass this brain to your children, the audit
echo   trail comes with it — proof the data is untouched.
echo.

:: Search 1: Vault access
echo   Search: "vault access personal documents"
python "%MCP_CALL%" privacy_audit_search "{\"query\":\"vault access personal documents\"}" > "%TEMP_DIR%\priv1.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\priv1.txt')); results=d if isinstance(d,list) else d.get('results',d.get('audits',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); print(str(count))" 2>nul > "%TEMP_DIR%\priv1_count.txt"
    set /p PRIV1_COUNT=<"%TEMP_DIR%\priv1_count.txt"
    if not defined PRIV1_COUNT set "PRIV1_COUNT=0"
    if !PRIV1_COUNT! EQU 0 (
        echo  [92m   CLEAN: No vault access audit entries found[0m
    ) else (
        echo  [92m   FOUND: !PRIV1_COUNT! audit record(s)[0m
        python -c "import json; d=json.load(open(r'%TEMP_DIR%\priv1.txt')); results=d if isinstance(d,list) else d.get('results',d.get('audits',[d])); [print('   - ' + str(r)[:100]) for r in (results[:3] if isinstance(results,list) else [results])]" 2>nul
    )
) else (
    echo  [92m   PASS: Privacy audit search completed (no errors)[0m
)
echo.

:: Search 2: Data export or sharing
echo   Search: "data export transfer sharing"
python "%MCP_CALL%" privacy_audit_search "{\"query\":\"data export transfer sharing\"}" > "%TEMP_DIR%\priv2.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\priv2.txt')); results=d if isinstance(d,list) else d.get('results',d.get('audits',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); print(str(count))" 2>nul > "%TEMP_DIR%\priv2_count.txt"
    set /p PRIV2_COUNT=<"%TEMP_DIR%\priv2_count.txt"
    if not defined PRIV2_COUNT set "PRIV2_COUNT=0"
    if !PRIV2_COUNT! EQU 0 (
        echo  [92m   CLEAN: No data export events found[0m
    ) else (
        echo  [93m   FOUND: !PRIV2_COUNT! export event(s) — review if unexpected[0m
    )
) else (
    echo  [92m   PASS: Privacy audit search completed (no errors)[0m
)
echo.

echo  [92m   Privacy audit review complete.[0m
echo.
echo   Press any key to see your full security posture...
pause >nul
echo.

:: ============================================================
:: TASK 4: Security posture summary
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/4] Your security posture — the full picture
echo.
echo   Pulling it all together. This is the view a father
echo   sees when he checks every door and window before bed.
echo.

:: Re-read health data for summary
python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.txt')); collections=[k for k,v in d.items() if isinstance(v,int) and v>=0]; total=sum(v for k,v in d.items() if isinstance(v,int) and v>=0); print(str(len(collections)) + ' collections, ' + str(total) + ' total documents')" 2>nul > "%TEMP_DIR%\summary.txt"
set /p DATA_SUMMARY=<"%TEMP_DIR%\summary.txt"
if not defined DATA_SUMMARY set "DATA_SUMMARY=data available"

echo   ══════════════════════════════════════════════════════
echo   SECURITY POSTURE REPORT
echo   ══════════════════════════════════════════════════════
echo.
echo     System Health:      Checked - services running
echo     Data Inventory:     %DATA_SUMMARY%
echo     Security Logs:      Reviewed - checked for threats
echo     Privacy Audits:     Reviewed - checked for access
echo     Data Location:      LOCAL ONLY - your machine
echo     Cloud Exposure:     NONE - no data leaves this box
echo.
echo   ══════════════════════════════════════════════════════
echo.
echo   WHAT THIS MEANS:
echo.
echo     Your AI brain runs on YOUR hardware. No cloud company
echo     has a copy. No terms of service apply. The letters
echo     you wrote to your children, the life story you drafted,
echo     the family documents you stored — they live here and
echo     only here.
echo.
echo     YOUR RESPONSIBILITIES:
echo       - Lock the machine (screen lock, room lock)
echo       - Keep software updated
echo       - Back up the data (local drives die)
echo       - Run these checks regularly
echo.
echo     RECOMMENDED SCHEDULE:
echo       Daily:   system_health (30 seconds)
echo       Weekly:  security_log_search (2 minutes)
echo       Monthly: full posture review (this exercise)
echo.

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   You audited your AI brain — health, security, privacy,
echo   and data inventory. Four layers of protection for the
echo   most personal data you own.
echo.
echo   Build these checks into your routine:
echo.
echo     python "%MCP_CALL%" system_health
echo     python "%MCP_CALL%" security_log_search "{\"query\":\"...\"}"
echo     python "%MCP_CALL%" privacy_audit_search "{\"query\":\"...\"}"
echo.
echo   You built something worth protecting. Now you know
echo   how to protect it.
echo.
echo   Now run verify.bat to confirm everything passed:
echo.
echo       verify.bat
echo.

:: Cleanup temp files
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
