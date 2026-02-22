@echo off
setlocal enabledelayedexpansion
title Module 5.5 Verify — Workshop in a Box

:: ============================================================
:: MODULE 5.5 VERIFICATION
:: Checks: MCP reachable, workshop script in vault, checklist
::         in vault, draft content substantive, teaching
::         knowledge entries exist
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.5-verify"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 5.5 VERIFICATION
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
    echo          Test: python "%MCP_CALL%" system_health
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: Workshop script found in vault ---
echo  [CHECK 2/%TOTAL_CHECKS%] Workshop script stored in vault
python "%MCP_CALL%" vault_search "{\"query\":\"workshop script install Ollama\"}" > "%TEMP_DIR%\vault_workshop.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault_workshop.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); found=count>=1; print('OK' if found else 'EMPTY')" 2>nul > "%TEMP_DIR%\ws_status.txt"
    set /p WS_STATUS=<"%TEMP_DIR%\ws_status.txt"
    if "!WS_STATUS!"=="OK" (
        echo  [92m   PASS: Workshop script found in vault[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: No workshop script found in vault[0m
        echo          Fix: Run exercise.bat to generate and store the workshop script
        echo          Manual: python "%MCP_CALL%" vault_add "{\"content\":\"...\",\"category\":\"teaching\",\"title\":\"Local AI Workshop Script\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_search tool call failed[0m
    echo          Fix: Check MCP server is running on localhost:8100
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: Facilitator checklist found in vault ---
echo  [CHECK 3/%TOTAL_CHECKS%] Facilitator checklist stored in vault
python "%MCP_CALL%" vault_search "{\"query\":\"facilitator checklist workshop\"}" > "%TEMP_DIR%\vault_checklist.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault_checklist.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); found=count>=1; print('OK' if found else 'EMPTY')" 2>nul > "%TEMP_DIR%\cl_status.txt"
    set /p CL_STATUS=<"%TEMP_DIR%\cl_status.txt"
    if "!CL_STATUS!"=="OK" (
        echo  [92m   PASS: Facilitator checklist found in vault[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: No facilitator checklist found in vault[0m
        echo          Fix: Run exercise.bat to generate and store the checklist
        echo          Manual: python "%MCP_CALL%" vault_add "{\"content\":\"...\",\"category\":\"teaching\",\"title\":\"Workshop Facilitator Checklist\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_search tool call failed[0m
    echo          Fix: Check MCP server is running on localhost:8100
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: Draft content is substantive (>200 chars) ---
echo  [CHECK 4/%TOTAL_CHECKS%] Workshop draft content is substantive
python "%MCP_CALL%" draft_create "{\"prompt\":\"Write a brief workshop outline for teaching local AI basics in 30 minutes.\",\"draft_type\":\"general\",\"use_vault_context\":true}" > "%TEMP_DIR%\test_draft.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\test_draft.txt')); text=str(d.get('text',d.get('draft',d.get('content',str(d))))); print('OK' if len(text)>200 else 'SHORT')" 2>nul > "%TEMP_DIR%\draft_status.txt"
    set /p DRAFT_STATUS=<"%TEMP_DIR%\draft_status.txt"
    if "!DRAFT_STATUS!"=="OK" (
        echo  [92m   PASS: Draft content is substantive (over 200 characters)[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: Draft content is too short (under 200 characters)[0m
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

:: --- CHECK 5: Teaching knowledge entries from 5.4 exist ---
echo  [CHECK 5/%TOTAL_CHECKS%] Teaching knowledge entries exist
python "%MCP_CALL%" search_knowledge "{\"query\":\"teaching AI workshop\"}" > "%TEMP_DIR%\knowledge.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\knowledge.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); print('OK' if count>=1 else 'EMPTY')" 2>nul > "%TEMP_DIR%\know_status.txt"
    set /p KNOW_STATUS=<"%TEMP_DIR%\know_status.txt"
    if "!KNOW_STATUS!"=="OK" (
        echo  [92m   PASS: Teaching knowledge entries found in knowledge base[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [93m   WARN: No teaching knowledge entries found[0m
        echo          This means Module 5.4 may not have been completed.
        echo          Workshop still works, but with less personal context.
        echo          Fix: Complete Module 5.4 first, or add a teaching entry manually:
        echo          python "%MCP_CALL%" add_knowledge "{\"content\":\"Teaching tips for local AI\",\"category\":\"technical\"}"
        :: Count as pass with warning — workshop can still function
        set /a PASS_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge tool call failed[0m
    echo          Fix: Check MCP server is running on localhost:8100
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
    echo  [92m   MODULE 5.5 COMPLETE[0m
    echo  [92m   You proved: You can generate a complete workshop kit[0m
    echo  [92m   and store it as reusable teaching assets. One toolbox.[0m
    echo  [92m   Everything inside. Open the box and teach a room.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "5.5", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 5.6
    echo   You built the kit. Now keep multiplying.
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
