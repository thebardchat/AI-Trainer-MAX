@echo off
setlocal enabledelayedexpansion
title Module 5.7 Verify — Family Mesh

:: ============================================================
:: MODULE 5.7 VERIFICATION — Family Mesh
:: Checks: MCP reachable, brain-dad entries, brain-mom entries,
::         brain-kid entries, cross-brain chat, social graph
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=6"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.7-verify"
set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ======================================================
echo   MODULE 5.7 VERIFICATION — Family Mesh
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

:: --- CHECK 2: brain-dad entries exist ---
echo  [CHECK 2/%TOTAL_CHECKS%] brain-dad namespace has knowledge entries
python "%MCP_CALL%" search_knowledge "{\"query\":\"plumbing car maintenance budget\",\"category\":\"brain-dad\"}" > "%TEMP_DIR%\dad.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\dad.json')); results=d.get('results',d.get('knowledge',[])); entries=results if isinstance(results,list) else [results]; count=len(entries); print(count)" > "%TEMP_DIR%\dad_count.txt" 2>nul
    set /p DAD_COUNT=<"%TEMP_DIR%\dad_count.txt"
    if !DAD_COUNT! GEQ 1 (
        echo  [92m   PASS: Found !DAD_COUNT! entries in brain-dad[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: No entries found in brain-dad namespace[0m
        echo          Fix: Run exercise.bat to load brain-dad entries
        echo          Or: python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Plumbing basics...\",\"category\":\"brain-dad\",\"title\":\"Plumbing\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge call failed for brain-dad[0m
    echo          Fix: Check MCP server status
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: brain-mom entries exist ---
echo  [CHECK 3/%TOTAL_CHECKS%] brain-mom namespace has knowledge entries
python "%MCP_CALL%" search_knowledge "{\"query\":\"recipe schedule first aid\",\"category\":\"brain-mom\"}" > "%TEMP_DIR%\mom.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\mom.json')); results=d.get('results',d.get('knowledge',[])); entries=results if isinstance(results,list) else [results]; count=len(entries); print(count)" > "%TEMP_DIR%\mom_count.txt" 2>nul
    set /p MOM_COUNT=<"%TEMP_DIR%\mom_count.txt"
    if !MOM_COUNT! GEQ 1 (
        echo  [92m   PASS: Found !MOM_COUNT! entries in brain-mom[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: No entries found in brain-mom namespace[0m
        echo          Fix: Run exercise.bat to load brain-mom entries
        echo          Or: python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Family recipe...\",\"category\":\"brain-mom\",\"title\":\"Recipe\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge call failed for brain-mom[0m
    echo          Fix: Check MCP server status
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: brain-kid entries exist ---
echo  [CHECK 4/%TOTAL_CHECKS%] brain-kid namespace has knowledge entries
python "%MCP_CALL%" search_knowledge "{\"query\":\"homework games friends\",\"category\":\"brain-kid\"}" > "%TEMP_DIR%\kid.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\kid.json')); results=d.get('results',d.get('knowledge',[])); entries=results if isinstance(results,list) else [results]; count=len(entries); print(count)" > "%TEMP_DIR%\kid_count.txt" 2>nul
    set /p KID_COUNT=<"%TEMP_DIR%\kid_count.txt"
    if !KID_COUNT! GEQ 1 (
        echo  [92m   PASS: Found !KID_COUNT! entries in brain-kid[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: No entries found in brain-kid namespace[0m
        echo          Fix: Run exercise.bat to load brain-kid entries
        echo          Or: python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Math homework...\",\"category\":\"brain-kid\",\"title\":\"Math\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge call failed for brain-kid[0m
    echo          Fix: Check MCP server status
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Cross-brain chat responds ---
echo  [CHECK 5/%TOTAL_CHECKS%] Cross-brain query via chat_with_shanebrain
echo   Asking the mesh a cross-brain question... (may take a moment)
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"Based on the brain-dad, brain-mom, and brain-kid knowledge, who knows about fixing things around the house?\"}" > "%TEMP_DIR%\chat.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat.json')); text=d.get('response',d.get('text',d.get('message',''))); has=len(str(text).strip())>20; err='error' in str(d).lower()[:100]; print('OK' if has and not err else 'EMPTY')" > "%TEMP_DIR%\chat_status.txt" 2>nul
    set /p CHAT_STATUS=<"%TEMP_DIR%\chat_status.txt"
    if "!CHAT_STATUS!"=="OK" (
        echo  [92m   PASS: Cross-brain query returned a response[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: chat_with_shanebrain returned empty or error[0m
        echo          Fix: Ollama may need time to load. Wait 30 seconds and retry
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: chat_with_shanebrain call failed[0m
    echo          Fix: Make sure Ollama is running and has a model loaded
    echo          Check: curl http://localhost:11434/api/tags
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 6: Social graph returns results ---
echo  [CHECK 6/%TOTAL_CHECKS%] Social graph accessible (get_top_friends or search_friends)
python "%MCP_CALL%" get_top_friends "{\"limit\":5}" > "%TEMP_DIR%\friends.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Social graph tool responded[0m
    set /a PASS_COUNT+=1
) else (
    :: Fallback to search_friends
    python "%MCP_CALL%" search_friends "{\"query\":\"family\"}" > "%TEMP_DIR%\friends2.json" 2>nul
    if !errorlevel! EQU 0 (
        echo  [92m   PASS: Social graph tool responded (via search_friends)[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: Neither get_top_friends nor search_friends responded[0m
        echo          Fix: Check MCP server status — social graph tools must be available
        echo          Run: python shared\utils\mcp-call.py system_health
        set /a FAIL_COUNT+=1
    )
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
    echo   [92mFamily Mesh — VERIFIED[0m
    echo.
    echo     [92m+[0m 3 brain namespaces created (dad, mom, kid)
    echo     [92m+[0m 9 knowledge entries loaded across 3 brains
    echo     [92m+[0m Cross-brain queries working
    echo     [92m+[0m Social graph accessible
    echo.
    echo   You proved that one MCP server can simulate a
    echo   multi-brain family network using category namespaces.
    echo   The concept scales — from categories to containers
    echo   to separate machines on a home network.
    echo.
    echo  [92m  ======================================================[0m

    :: --- Update progress ---
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "5.7", "status": "completed", "phase": "5", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

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
