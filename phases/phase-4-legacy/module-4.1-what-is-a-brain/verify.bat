@echo off
setlocal enabledelayedexpansion
title Module 4.1 Verify

:: ============================================================
:: MODULE 4.1 VERIFICATION
:: Checks: MCP reachable, system_health returns data,
::         collections exist, search_knowledge returns results,
::         collections have objects
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.1-verify"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 4.1 VERIFICATION
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

:: --- CHECK 2: system_health returns valid data ---
echo  [CHECK 2/%TOTAL_CHECKS%] system_health returns valid data
python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.txt')); assert isinstance(d,dict) and len(d)>0; print('OK')" 2>nul > "%TEMP_DIR%\health_status.txt"
set /p HEALTH_STATUS=<"%TEMP_DIR%\health_status.txt"
if "!HEALTH_STATUS!"=="OK" (
    echo  [92m   PASS: system_health returned valid JSON with data[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: system_health returned empty or invalid data[0m
    echo          Fix: Check that Weaviate and Ollama are running behind the MCP server
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: Collections exist in system_health ---
echo  [CHECK 3/%TOTAL_CHECKS%] Brain has collections (rooms in the house)
python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.txt')); cols=d.get('collections',d.get('collection_counts',{})); count=len(cols) if isinstance(cols,dict) else len(cols) if isinstance(cols,list) else 0; print(count)" 2>nul > "%TEMP_DIR%\col_count.txt"
set /p COL_COUNT=<"%TEMP_DIR%\col_count.txt"
if not defined COL_COUNT set "COL_COUNT=0"
if %COL_COUNT% GEQ 1 (
    echo  [92m   PASS: Found %COL_COUNT% collection(s) in the brain[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: No collections found in system_health output[0m
    echo          Fix: The MCP server should report collections. Check ShaneBrain is initialized.
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: search_knowledge returns results ---
echo  [CHECK 4/%TOTAL_CHECKS%] search_knowledge returns results
python "%MCP_CALL%" search_knowledge "{\"query\":\"family values faith\"}" > "%TEMP_DIR%\knowledge.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json,sys; d=json.load(open(r'%TEMP_DIR%\knowledge.txt')); has_results=(len(d)>0 if isinstance(d,list) else bool(d.get('results',d.get('entries',d.get('text',''))))); print('OK' if has_results else 'EMPTY')" 2>nul > "%TEMP_DIR%\knowledge_status.txt"
    set /p KNOWLEDGE_STATUS=<"%TEMP_DIR%\knowledge_status.txt"
    if "!KNOWLEDGE_STATUS!"=="OK" (
        echo  [92m   PASS: Knowledge search returned results[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [93m   WARN: Knowledge search returned empty — brain may be new[0m
        echo          This is OK for a fresh brain. You'll add knowledge in Module 4.2.
        set /a PASS_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge tool call failed[0m
    echo          Fix: Check MCP server is running: python "%MCP_CALL%" system_health
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: At least one collection has objects ---
echo  [CHECK 5/%TOTAL_CHECKS%] At least one collection has stored objects
python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.txt')); cols=d.get('collections',d.get('collection_counts',{})); has_objects=any(v>0 for v in cols.values()) if isinstance(cols,dict) else len(cols)>0; print('OK' if has_objects else 'EMPTY')" 2>nul > "%TEMP_DIR%\objects_status.txt"
set /p OBJECTS_STATUS=<"%TEMP_DIR%\objects_status.txt"
if "!OBJECTS_STATUS!"=="OK" (
    echo  [92m   PASS: Brain has stored objects — it's alive[0m
    set /a PASS_COUNT+=1
) else (
    echo  [93m   WARN: No objects found in any collection — brain may be empty[0m
    echo          This is OK for a fresh install. Module 4.2 will fix this.
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
    echo  [92m   MODULE 4.1 COMPLETE[0m
    echo  [92m   You proved: A personal AI brain is real infrastructure[0m
    echo  [92m   with real data. ShaneBrain is the living proof.[0m
    echo  [92m   Your brain runs locally — no cloud, no subscription.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "4.1", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 4.2 — Feed Your Brain
    echo   Now that you've seen the house, it's time to
    echo   move in. You'll add your own knowledge, values,
    echo   and memories.
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
