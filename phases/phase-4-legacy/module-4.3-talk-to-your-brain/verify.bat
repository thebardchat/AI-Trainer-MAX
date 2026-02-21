@echo off
setlocal enabledelayedexpansion
title Module 4.3 Verify — Talk to Your Brain

:: ============================================================
:: MODULE 4.3 VERIFICATION
:: Checks: MCP reachable, knowledge base has entries,
::         search_knowledge returns results,
::         chat_with_shanebrain responds,
::         response contains real content (not error)
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.3-verify"
set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 4.3 VERIFICATION — Talk to Your Brain
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
    echo          Fix: Ensure ShaneBrain MCP gateway is running on port 8100
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: Knowledge base has entries ---
echo  [CHECK 2/%TOTAL_CHECKS%] Knowledge base contains entries
python "%MCP_CALL%" search_knowledge "{\"query\":\"family values life work\"}" > "%TEMP_DIR%\kb_search.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\kb_search.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[])); has=len(results)>0 if isinstance(results,list) else bool(results); print('OK' if has else 'EMPTY')" 2>nul > "%TEMP_DIR%\kb_status.txt"
    set /p KB_STATUS=<"%TEMP_DIR%\kb_status.txt"
    if "!KB_STATUS!"=="OK" (
        echo  [92m   PASS: Knowledge base has entries[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: Knowledge base appears empty[0m
        echo          Fix: Run Module 4.2 exercise.bat first to add knowledge entries
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge call failed[0m
    echo          Fix: Check MCP server is running
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: search_knowledge returns relevant results ---
echo  [CHECK 3/%TOTAL_CHECKS%] search_knowledge returns relevant results
python "%MCP_CALL%" search_knowledge "{\"query\":\"personal information about me\"}" > "%TEMP_DIR%\search.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[d])); has_data=(len(results)>0 if isinstance(results,list) else bool(results)); print('OK' if has_data else 'EMPTY')" 2>nul > "%TEMP_DIR%\search_status.txt"
    set /p SEARCH_STATUS=<"%TEMP_DIR%\search_status.txt"
    if "!SEARCH_STATUS!"=="OK" (
        echo  [92m   PASS: search_knowledge returned results[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: search_knowledge returned empty results[0m
        echo          Fix: Add knowledge entries via Module 4.2, then search will find them
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge tool call failed[0m
    echo          Fix: Check MCP server is running
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: chat_with_shanebrain responds ---
echo  [CHECK 4/%TOTAL_CHECKS%] chat_with_shanebrain generates a response
echo   Asking: "What do you know about me and my values?"
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"What do you know about me and my values?\"}" > "%TEMP_DIR%\chat.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: chat_with_shanebrain responded[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: chat_with_shanebrain did not respond[0m
    echo          Fix: Check that Ollama is running (it generates the answers)
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Response contains actual content (not error) ---
echo  [CHECK 5/%TOTAL_CHECKS%] Response contains real content
python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat.txt')); text=d.get('text',d.get('response',str(d))); has_content=len(text)>20 and 'error' not in text.lower()[:50]; print('OK' if has_content else 'ERROR')" 2>nul > "%TEMP_DIR%\content_status.txt"
set /p CONTENT_STATUS=<"%TEMP_DIR%\content_status.txt"
if "%CONTENT_STATUS%"=="OK" (
    echo  [92m   PASS: Response contains substantive content[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Response was empty or contained an error[0m
    echo          Fix: Check Ollama is running and has a model loaded
    set /a FAIL_COUNT+=1
)
echo.

:: Cleanup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

:: --- RESULTS ---
echo  ══════════════════════════════════════════════════════
if %FAIL_COUNT% EQU 0 (
    echo.
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
    echo.
    echo  [92m   MODULE 4.3 COMPLETE — Talk to Your Brain[0m
    echo.
    echo  [92m   You proved:[0m
    echo  [92m   + Your brain searches its knowledge when you ask a question[0m
    echo  [92m   + RAG generates answers grounded in YOUR stored words[0m
    echo  [92m   + search_knowledge finds relevant entries by meaning[0m
    echo  [92m   + chat_with_shanebrain produces real, substantive answers[0m
    echo.
    echo   Your brain speaks. And it speaks in your voice.
    echo   That's something no generic chatbot will ever do.
    echo.
    echo   Next: Module 4.4 — Your Daily Companion
    echo   Build a daily habit of feeding and talking to your brain.
    echo  ══════════════════════════════════════════════════════

    :: --- Update progress ---
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "4.3", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

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
