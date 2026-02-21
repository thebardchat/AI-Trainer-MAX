@echo off
setlocal enabledelayedexpansion
title Module 4.2 Verify

:: ============================================================
:: MODULE 4.2 VERIFICATION
:: Checks: MCP reachable, add_knowledge works, vault_add works,
::         search_knowledge finds entries, vault_search finds entries
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.2-verify"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 4.2 VERIFICATION
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

:: --- CHECK 2: add_knowledge works ---
echo  [CHECK 2/%TOTAL_CHECKS%] add_knowledge tool works
python "%MCP_CALL%" add_knowledge "{\"content\":\"Verification entry — the ability to learn from mistakes is the foundation of all growth. Every failure carries a lesson if you're honest enough to find it.\",\"category\":\"general\",\"title\":\"Verify - Growth Through Failure\"}" > "%TEMP_DIR%\add_knowledge.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: add_knowledge stored an entry successfully[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: add_knowledge tool call failed[0m
    echo          Fix: Check MCP server is running: python "%MCP_CALL%" system_health
    echo          Fix: Try manually: python "%MCP_CALL%" add_knowledge "{\"content\":\"test\",\"category\":\"general\"}"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: vault_add works ---
echo  [CHECK 3/%TOTAL_CHECKS%] vault_add tool works
python "%MCP_CALL%" vault_add "{\"content\":\"Verification entry — family dinner tradition. Every Sunday we eat together, no phones at the table. Started when the oldest was three and never stopped. Some weeks it's the only hour all seven of us sit in the same room.\",\"category\":\"personal\",\"title\":\"Verify - Sunday Dinner Tradition\"}" > "%TEMP_DIR%\vault_add.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: vault_add stored a document successfully[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: vault_add tool call failed[0m
    echo          Fix: Check MCP server is running: python "%MCP_CALL%" system_health
    echo          Fix: Try manually: python "%MCP_CALL%" vault_add "{\"content\":\"test\",\"category\":\"personal\"}"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: search_knowledge finds entries ---
echo  [CHECK 4/%TOTAL_CHECKS%] search_knowledge finds stored entries
python "%MCP_CALL%" search_knowledge "{\"query\":\"family values hard work honesty\"}" > "%TEMP_DIR%\search_knowledge.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json,sys; d=json.load(open(r'%TEMP_DIR%\search_knowledge.txt')); has_results=(len(d)>0 if isinstance(d,list) else bool(d.get('results',d.get('entries',d.get('text',''))))); print('OK' if has_results else 'EMPTY')" 2>nul > "%TEMP_DIR%\sk_status.txt"
    set /p SK_STATUS=<"%TEMP_DIR%\sk_status.txt"
    if "!SK_STATUS!"=="OK" (
        echo  [92m   PASS: search_knowledge found relevant entries[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: search_knowledge returned empty results[0m
        echo          Fix: Run exercise.bat first to add knowledge entries, then verify again
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge tool call failed[0m
    echo          Fix: Check MCP server is running: python "%MCP_CALL%" system_health
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: vault_search finds entries ---
echo  [CHECK 5/%TOTAL_CHECKS%] vault_search finds stored entries
python "%MCP_CALL%" vault_search "{\"query\":\"family memories fatherhood children\"}" > "%TEMP_DIR%\search_vault.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json,sys; d=json.load(open(r'%TEMP_DIR%\search_vault.txt')); has_results=(len(d)>0 if isinstance(d,list) else bool(d.get('results',d.get('documents',d.get('text',''))))); print('OK' if has_results else 'EMPTY')" 2>nul > "%TEMP_DIR%\vs_status.txt"
    set /p VS_STATUS=<"%TEMP_DIR%\vs_status.txt"
    if "!VS_STATUS!"=="OK" (
        echo  [92m   PASS: vault_search found relevant entries[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: vault_search returned empty results[0m
        echo          Fix: Run exercise.bat first to add vault entries, then verify again
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_search tool call failed[0m
    echo          Fix: Check MCP server is running: python "%MCP_CALL%" system_health
    set /a FAIL_COUNT+=1
)
echo.

:: Cleanup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

:: --- RESULTS ---
echo  ══════════════════════════════════════════════════════
if %FAIL_COUNT% EQU 0 (
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
    echo.
    echo  [92m   MODULE 4.2 COMPLETE[0m
    echo  [92m   You proved: You can feed a brain with values,[0m
    echo  [92m   memories, and wisdom — and find them by meaning.[0m
    echo  [92m   Your legacy is searchable. Your voice persists.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "4.2", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 4.3 — Talk to Your Brain
    echo   You've stored your knowledge. Now you'll have
    echo   a conversation with it — ask questions and get
    echo   answers grounded in YOUR words.
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
