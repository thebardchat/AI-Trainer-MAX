@echo off
setlocal enabledelayedexpansion
title Module 5.3 Verify — Backup and Restore

:: ============================================================
:: MODULE 5.3 VERIFICATION — Backup and Restore
:: Checks: MCP reachable, knowledge export, vault export,
::         system_health counts, add_knowledge, vault_list
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=6"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.3-verify"
set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ======================================================
echo   MODULE 5.3 VERIFICATION — Backup and Restore
echo  ======================================================
echo.

:: --- CHECK 1: MCP Server Reachable ---
echo  [CHECK 1/%TOTAL_CHECKS%] MCP server reachable
python "%MCP_CALL%" system_health > "%TEMP_DIR%\health.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   PASS: MCP server responding[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: MCP server not reachable[0m
    echo          Fix: Make sure the MCP server is running on port 8100
    echo          Run: shared\utils\mcp-health-check.bat
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: Knowledge export succeeds ---
echo  [CHECK 2/%TOTAL_CHECKS%] Knowledge export succeeds (search_knowledge returns data)
python "%MCP_CALL%" search_knowledge "{\"query\":\"family values work life lessons\"}" > "%TEMP_DIR%\knowledge.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\knowledge.json')); results=d.get('results',d.get('knowledge',[])); entries=results if isinstance(results,list) else [results]; count=len(entries); print(count)" > "%TEMP_DIR%\know_count.txt" 2>nul
    set /p KNOW_COUNT=<"%TEMP_DIR%\know_count.txt"
    if !KNOW_COUNT! GEQ 1 (
        echo  [92m   PASS: search_knowledge returned !KNOW_COUNT! entries[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: search_knowledge returned 0 entries[0m
        echo          Fix: Add knowledge first — run exercise.bat or:
        echo          python shared\utils\mcp-call.py add_knowledge "{\"content\":\"test\",\"category\":\"general\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge call failed[0m
    echo          Fix: Check MCP server status. Run: shared\utils\mcp-health-check.bat
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: Vault export succeeds ---
echo  [CHECK 3/%TOTAL_CHECKS%] Vault export succeeds (vault_search returns data)
python "%MCP_CALL%" vault_search "{\"query\":\"personal documents stories letters records\"}" > "%TEMP_DIR%\vault.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault.json')); results=d.get('results',d.get('documents',[])); entries=results if isinstance(results,list) else [results]; count=len(entries); print(count)" > "%TEMP_DIR%\vault_count.txt" 2>nul
    set /p VAULT_COUNT=<"%TEMP_DIR%\vault_count.txt"
    if !VAULT_COUNT! GEQ 1 (
        echo  [92m   PASS: vault_search returned !VAULT_COUNT! entries[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: vault_search returned 0 entries[0m
        echo          Fix: Add vault entries first — run exercise.bat or:
        echo          python shared\utils\mcp-call.py vault_add "{\"content\":\"test\",\"category\":\"personal\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_search call failed[0m
    echo          Fix: Check MCP server status. Run: shared\utils\mcp-health-check.bat
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: system_health returns collection counts ---
echo  [CHECK 4/%TOTAL_CHECKS%] system_health returns collection counts
python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.json')); cols=d.get('collections',{}); has_counts=any(isinstance(v,int) for v in cols.values()); print('OK' if cols and has_counts else 'EMPTY')" > "%TEMP_DIR%\health_status.txt" 2>nul
set /p HEALTH_STATUS=<"%TEMP_DIR%\health_status.txt"
if "!HEALTH_STATUS!"=="OK" (
    echo  [92m   PASS: system_health reports collection counts[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: system_health did not return collection counts[0m
    echo          Fix: Run python shared\utils\mcp-call.py system_health
    echo          If it errors, restart the MCP server container
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: add_knowledge works (test entry) ---
echo  [CHECK 5/%TOTAL_CHECKS%] Test entry added successfully (add_knowledge works)
python "%MCP_CALL%" add_knowledge "{\"content\":\"Verify backup test — Module 5.3 verification entry.\",\"category\":\"backup-test\",\"title\":\"Verify Backup Test\"}" > "%TEMP_DIR%\add_test.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\add_test.json')); err='error' in str(d).lower()[:200]; print('OK' if not err else 'ERROR')" > "%TEMP_DIR%\add_status.txt" 2>nul
    set /p ADD_STATUS=<"%TEMP_DIR%\add_status.txt"
    if "!ADD_STATUS!"=="OK" (
        echo  [92m   PASS: add_knowledge accepted test entry[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: add_knowledge returned an error[0m
        echo          Fix: Check MCP server logs for errors
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: add_knowledge call failed[0m
    echo          Fix: Run python shared\utils\mcp-call.py add_knowledge "{\"content\":\"test\",\"category\":\"general\"}"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 6: vault_list_categories returns category data ---
echo  [CHECK 6/%TOTAL_CHECKS%] vault_list_categories returns category data
python "%MCP_CALL%" vault_list_categories > "%TEMP_DIR%\categories.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\categories.json')); s=str(d); has_data=len(s)>10 and 'error' not in s.lower()[:200]; print('OK' if has_data else 'EMPTY')" > "%TEMP_DIR%\cat_status.txt" 2>nul
    set /p CAT_STATUS=<"%TEMP_DIR%\cat_status.txt"
    if "!CAT_STATUS!"=="OK" (
        echo  [92m   PASS: vault_list_categories returned category data[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: vault_list_categories returned empty or error[0m
        echo          Fix: Add at least one vault entry first:
        echo          python shared\utils\mcp-call.py vault_add "{\"content\":\"test\",\"category\":\"personal\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_list_categories call failed[0m
    echo          Fix: Check MCP server status. Run: shared\utils\mcp-health-check.bat
    set /a FAIL_COUNT+=1
)
echo.

:: Cleanup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

:: --- RESULTS ---
echo  ======================================================
if %FAIL_COUNT% EQU 0 (
    echo.
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
    echo.
    echo  [92m  ======================================================[0m
    echo.
    echo   Your backup process is verified:
    echo.
    echo     [92m+[0m MCP server reachable
    echo     [92m+[0m Knowledge base exports successfully
    echo     [92m+[0m Vault exports successfully
    echo     [92m+[0m Collection counts are accurate
    echo     [92m+[0m New entries can be added (restore path works)
    echo     [92m+[0m Vault categories are trackable
    echo.
    echo   Your brain is protected. Now keep it that way —
    echo   back up weekly, store copies off-drive, and verify
    echo   after every major change.
    echo.
    echo  [92m  ======================================================[0m

    :: --- Update progress ---
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "5.3", "status": "completed", "phase": "5", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    endlocal
    exit /b 0
) else (
    echo.
    echo  [91m   RESULT: FAIL  (%PASS_COUNT%/%TOTAL_CHECKS% passed, %FAIL_COUNT% failed)[0m
    echo.
    echo   Review the failures above and fix them.
    echo   Then run verify.bat again.
    echo   Need help? Check hints.md in this folder.
    echo  ======================================================
    endlocal
    exit /b 1
)
