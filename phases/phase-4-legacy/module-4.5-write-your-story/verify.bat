@echo off
setlocal enabledelayedexpansion
title Module 4.5 Verify

:: ============================================================
:: MODULE 4.5 VERIFICATION
:: Checks: MCP reachable, draft_create generates content,
::         vault_search returns context, drafts contain real text
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=4"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.5-verify"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 4.5 VERIFICATION
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

:: --- CHECK 2: draft_create generates a letter with content ---
echo  [CHECK 2/%TOTAL_CHECKS%] draft_create generates a legacy letter
echo   Creating test letter draft...
python "%MCP_CALL%" draft_create "{\"prompt\":\"Write a short letter to my family about what matters most in life — faith, hard work, and loving each other.\",\"draft_type\":\"letter\",\"use_vault_context\":true}" > "%TEMP_DIR%\draft.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\draft.txt')); text=d.get('text',d.get('draft',d.get('content',str(d)))); has_draft=len(str(text))>20; print('OK' if has_draft else 'EMPTY')" 2>nul > "%TEMP_DIR%\draft_status.txt"
    set /p DRAFT_STATUS=<"%TEMP_DIR%\draft_status.txt"
    if "!DRAFT_STATUS!"=="OK" (
        echo  [92m   PASS: draft_create generated a letter with real content[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: draft_create returned empty content[0m
        echo          Fix: Check that Ollama is running with a model loaded
        echo          Test: curl http://localhost:11434/api/tags
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: draft_create tool call failed[0m
    echo          Fix: Check MCP server and Ollama are both running
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: vault_search returns context ---
echo  [CHECK 3/%TOTAL_CHECKS%] vault_search returns context for drafting
python "%MCP_CALL%" vault_search "{\"query\":\"family values legacy\"}" > "%TEMP_DIR%\vault.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault.txt')); has_data=(len(d)>0 if isinstance(d,list) else bool(d.get('results',d.get('documents',d.get('text',''))))); print('OK' if has_data else 'EMPTY')" 2>nul > "%TEMP_DIR%\vault_status.txt"
    set /p VAULT_STATUS=<"%TEMP_DIR%\vault_status.txt"
    if "!VAULT_STATUS!"=="OK" (
        echo  [92m   PASS: vault_search found context documents[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [93m   WARN: vault_search returned no results[0m
        echo          Vault may be empty. Drafts still work but are less personal.
        echo          For richer drafts, store documents via Module 4.2 first.
        set /a PASS_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_search tool call failed[0m
    echo          Fix: Check MCP server is running on localhost:8100
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: Draft contains substantial text (not just error or stub) ---
echo  [CHECK 4/%TOTAL_CHECKS%] Draft contains real, substantial text
python -c "import json; d=json.load(open(r'%TEMP_DIR%\draft.txt')); text=str(d.get('text',d.get('draft',d.get('content',str(d))))); words=len(text.split()); print('OK' if words>15 else 'SHORT')" 2>nul > "%TEMP_DIR%\length_status.txt"
set /p LENGTH_STATUS=<"%TEMP_DIR%\length_status.txt"
if "%LENGTH_STATUS%"=="OK" (
    echo  [92m   PASS: Draft contains substantial text (ready to edit and keep)[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Draft is too short — may be an error response[0m
    echo          Fix: Ensure Ollama has a model loaded and MCP server is healthy
    echo          Test: python "%MCP_CALL%" system_health
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
    echo  [92m   MODULE 4.5 COMPLETE[0m
    echo  [92m   You proved: Your AI brain can help you write the[0m
    echo  [92m   words that matter most. Letters to your children.[0m
    echo  [92m   Your life story. Messages to the people you love.[0m
    echo  [92m   The AI finds the words — you make them yours.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "4.5", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 4.6 — Guard Your Legacy
    echo   You built something worth protecting. Now lock the doors.
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
