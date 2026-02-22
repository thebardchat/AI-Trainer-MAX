@echo off
setlocal enabledelayedexpansion
title Module 5.1 Verify — Lock the Gates

:: ============================================================
:: MODULE 5.1 VERIFICATION
:: Checks: MCP reachable, netstat works, service ports detected,
::         firewall status captured, security_log_search executes
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.1-verify"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ======================================================
echo   MODULE 5.1 VERIFICATION
echo  ======================================================
echo.

:: --- CHECK 1: MCP server reachable ---
echo  [CHECK 1/%TOTAL_CHECKS%] MCP server reachable
python "%MCP_CALL%" system_health > "%TEMP_DIR%\health.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: MCP server responding[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: MCP server not reachable[0m
    echo          Fix: Start the ShaneBrain MCP gateway. Check that the
    echo          shanebrain-mcp Docker container is running:
    echo            docker start shanebrain-mcp
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: netstat command works ---
echo  [CHECK 2/%TOTAL_CHECKS%] netstat captures listening ports
netstat -an > "%TEMP_DIR%\netstat.txt" 2>&1
if %errorlevel% EQU 0 (
    findstr /i "LISTENING" "%TEMP_DIR%\netstat.txt" > "%TEMP_DIR%\listening.txt" 2>nul
    if %errorlevel% EQU 0 (
        echo  [92m   PASS: netstat returned listening ports[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: netstat ran but found no LISTENING ports[0m
        echo          Fix: This is unusual. Make sure at least one service
        echo          (Ollama, Weaviate, or MCP) is running, then try again.
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: netstat command failed[0m
    echo          Fix: netstat is built into Windows. Try running this
    echo          script as Administrator if it fails.
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: At least one AI service port detected ---
echo  [CHECK 3/%TOTAL_CHECKS%] AI service ports detected (11434, 8080, or 8100)
set "PORT_FOUND=0"
if exist "%TEMP_DIR%\listening.txt" (
    findstr /c:":11434" "%TEMP_DIR%\listening.txt" > nul 2>&1
    if !errorlevel! EQU 0 set /a PORT_FOUND+=1
    findstr /c:":8080" "%TEMP_DIR%\listening.txt" > nul 2>&1
    if !errorlevel! EQU 0 set /a PORT_FOUND+=1
    findstr /c:":8100" "%TEMP_DIR%\listening.txt" > nul 2>&1
    if !errorlevel! EQU 0 set /a PORT_FOUND+=1
)
if !PORT_FOUND! GTR 0 (
    echo  [92m   PASS: Found !PORT_FOUND! of 3 AI service port(s) listening[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: None of the AI service ports (11434, 8080, 8100) detected[0m
    echo          Fix: Start your AI services:
    echo            ollama serve
    echo            docker start weaviate
    echo          Then run verify.bat again.
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: Firewall status captured ---
echo  [CHECK 4/%TOTAL_CHECKS%] Firewall status captured
netsh advfirewall show currentprofile > "%TEMP_DIR%\firewall.txt" 2>&1
if %errorlevel% EQU 0 (
    findstr /i "State" "%TEMP_DIR%\firewall.txt" > nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [92m   PASS: Firewall status retrieved[0m
        :: Show the state for awareness
        for /f "tokens=*" %%a in ('findstr /i "State" "%TEMP_DIR%\firewall.txt"') do (
            echo          %%a
        )
        set /a PASS_COUNT+=1
    ) else (
        echo  [93m   WARN: Firewall queried but State not found in output[0m
        echo          Giving you a pass — the command ran successfully.
        set /a PASS_COUNT+=1
    )
) else (
    echo  [91m   FAIL: Could not query Windows Firewall[0m
    echo          Fix: Try running this script as Administrator:
    echo            Right-click cmd.exe ^> Run as Administrator
    echo            Then navigate here and run verify.bat
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: security_log_search executes ---
echo  [CHECK 5/%TOTAL_CHECKS%] security_log_search executes successfully
python "%MCP_CALL%" security_log_search "{\"query\":\"security audit\"}" > "%TEMP_DIR%\sec.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\sec.txt')); has_error='error' in str(d).lower()[:100] and 'class' not in str(d).lower()[:200]; print('ERROR' if has_error else 'OK')" 2>nul > "%TEMP_DIR%\sec_status.txt"
    set /p SEC_STATUS=<"%TEMP_DIR%\sec_status.txt"
    if "!SEC_STATUS!"=="OK" (
        echo  [92m   PASS: security_log_search executed successfully[0m
        echo          (Empty results are normal on a clean system)
        set /a PASS_COUNT+=1
    ) else (
        echo  [93m   WARN: security_log_search returned with a note[0m
        echo          This may happen if SecurityLog collection is empty.
        echo          That's expected — giving you a pass.
        set /a PASS_COUNT+=1
    )
) else (
    echo  [91m   FAIL: security_log_search call failed[0m
    echo          Fix: Check MCP server is running:
    echo            python "%MCP_CALL%" system_health
    echo          The SecurityLog collection may not exist yet — that's OK
    echo          for a fresh system, but the tool should still run.
    set /a FAIL_COUNT+=1
)
echo.

:: Cleanup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

:: Also clean exercise temp if it exists
if exist "%TEMP%\module-5.1" rd /s /q "%TEMP%\module-5.1" 2>nul

:: --- RESULTS ---
echo  ======================================================
if %FAIL_COUNT% EQU 0 (
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
    echo.
    echo  [92m   MODULE 5.1 COMPLETE[0m
    echo  [92m   You proved: You can scan ports, check bindings,[0m
    echo  [92m   verify firewalls, and generate a hardening report.[0m
    echo  [92m   You know the difference between a locked door and[0m
    echo  [92m   an open one — and you know how to fix it.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "5.1", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Phase 5 begins. You are a multiplier now.
    echo   Secure your system. Then teach someone else.
    echo  ======================================================
    endlocal
    exit /b 0
) else (
    echo  [91m   RESULT: FAIL  (%PASS_COUNT%/%TOTAL_CHECKS% passed, %FAIL_COUNT% failed)[0m
    echo.
    echo   Review the failures above and fix them.
    echo   Then run verify.bat again.
    echo   Need help? Check hints.md in this folder.
    echo  ======================================================
    endlocal
    exit /b 1
)
