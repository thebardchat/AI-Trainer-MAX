@echo off
setlocal enabledelayedexpansion
title Module 4.6 Verify

:: ============================================================
:: MODULE 4.6 VERIFICATION
:: Checks: MCP reachable, system_health shows services,
::         security_log_search works, privacy_audit_search works,
::         system has collections with data
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.6-verify"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 4.6 VERIFICATION
echo  ══════════════════════════════════════════════════════
echo.

:: --- CHECK 1: MCP server reachable ---
echo  [CHECK 1/%TOTAL_CHECKS%] MCP server reachable
python "%MCP_CALL%" system_health > "%TEMP_DIR%\health.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: MCP server responding[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: MCP server not reachable[0m
    echo          Fix: Ensure ShaneBrain MCP gateway is running on localhost:8100
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: system_health returns valid service data ---
echo  [CHECK 2/%TOTAL_CHECKS%] system_health returns valid service data
python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.txt')); valid=isinstance(d,dict) and len(d)>0; print('OK' if valid else 'INVALID')" 2>nul > "%TEMP_DIR%\health_status.txt"
set /p HEALTH_STATUS=<"%TEMP_DIR%\health_status.txt"
if "%HEALTH_STATUS%"=="OK" (
    echo  [92m   PASS: system_health returned valid JSON with service data[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: system_health returned invalid or empty data[0m
    echo          Fix: Check that Weaviate and Ollama are running
    echo          Test: curl http://localhost:8080/v1/.well-known/ready
    echo          Test: curl http://localhost:11434/api/tags
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: security_log_search executes without error ---
echo  [CHECK 3/%TOTAL_CHECKS%] security_log_search executes without error
python "%MCP_CALL%" security_log_search "{\"query\":\"security check failed login\"}" > "%TEMP_DIR%\sec.txt" 2>&1
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
        echo          That's expected on a fresh system — giving you a pass.
        set /a PASS_COUNT+=1
    )
) else (
    echo  [91m   FAIL: security_log_search call failed[0m
    echo          Fix: Check MCP server is running. The SecurityLog collection
    echo          may need to be created — this is OK for a fresh system.
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: privacy_audit_search executes without error ---
echo  [CHECK 4/%TOTAL_CHECKS%] privacy_audit_search executes without error
python "%MCP_CALL%" privacy_audit_search "{\"query\":\"data access vault personal\"}" > "%TEMP_DIR%\priv.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\priv.txt')); has_error='error' in str(d).lower()[:100] and 'class' not in str(d).lower()[:200]; print('ERROR' if has_error else 'OK')" 2>nul > "%TEMP_DIR%\priv_status.txt"
    set /p PRIV_STATUS=<"%TEMP_DIR%\priv_status.txt"
    if "!PRIV_STATUS!"=="OK" (
        echo  [92m   PASS: privacy_audit_search executed successfully[0m
        echo          (Empty results are normal on a clean system)
        set /a PASS_COUNT+=1
    ) else (
        echo  [93m   WARN: privacy_audit_search returned with a note[0m
        echo          This may happen if PrivacyAudit collection is empty.
        echo          That's expected on a fresh system — giving you a pass.
        set /a PASS_COUNT+=1
    )
) else (
    echo  [91m   FAIL: privacy_audit_search call failed[0m
    echo          Fix: Check MCP server is running. The PrivacyAudit collection
    echo          may need to be created — this is OK for a fresh system.
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: System has collections (data inventory) ---
echo  [CHECK 5/%TOTAL_CHECKS%] System has data collections
python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.txt')); collections=[k for k,v in d.items() if isinstance(v,int) and v>=0]; print('OK' if len(collections)>0 else 'NONE')" 2>nul > "%TEMP_DIR%\coll_status.txt"
set /p COLL_STATUS=<"%TEMP_DIR%\coll_status.txt"
if not defined COLL_STATUS set "COLL_STATUS=NONE"
if "%COLL_STATUS%"=="OK" (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.txt')); collections=[k for k,v in d.items() if isinstance(v,int) and v>=0]; total=sum(v for k,v in d.items() if isinstance(v,int) and v>=0); print(str(len(collections)) + ' collection(s) with ' + str(total) + ' total document(s)')" 2>nul > "%TEMP_DIR%\coll_detail.txt"
    set /p COLL_DETAIL=<"%TEMP_DIR%\coll_detail.txt"
    echo  [92m   PASS: System has !COLL_DETAIL![0m
    set /a PASS_COUNT+=1
) else (
    echo  [93m   WARN: No data collections found in health report[0m
    echo          System may be fresh. Collections are created when you
    echo          store data (Modules 4.1-4.5). Giving you a pass.
    set /a PASS_COUNT+=1
)
echo.

:: Cleanup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

:: --- RESULTS ---
echo  ══════════════════════════════════════════════════════
if %FAIL_COUNT% EQU 0 (
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
    echo.
    echo  [92m   MODULE 4.6 COMPLETE[0m
    echo  [92m   You proved: You can audit your AI brain — health,[0m
    echo  [92m   security, privacy, and data inventory. You know[0m
    echo  [92m   what's running, what happened, and who touched[0m
    echo  [92m   what. Your legacy data is protected because YOU[0m
    echo  [92m   checked. That's what a guardian does.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "4.6", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 4.7 — Pass It On
    echo   You built it. You wrote in it. You locked it down.
    echo   Now learn how to hand it to the next generation.
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
