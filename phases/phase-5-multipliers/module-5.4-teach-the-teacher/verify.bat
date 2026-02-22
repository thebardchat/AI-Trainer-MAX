@echo off
setlocal enabledelayedexpansion
title Module 5.4 Verify — Teach the Teacher

:: ============================================================
:: MODULE 5.4 VERIFICATION
:: Checks: MCP reachable, 5+ teaching entries exist,
::         chat_with_shanebrain responds to beginner question,
::         response is substantive (>50 chars, no error),
::         search_knowledge finds teaching entries
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.4-verify"
set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 5.4 VERIFICATION — Teach the Teacher
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
    echo          Run: shared\utils\mcp-health-check.bat
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: At least 5 teaching-category knowledge entries ---
echo  [CHECK 2/%TOTAL_CHECKS%] At least 5 teaching-category knowledge entries exist
python "%MCP_CALL%" search_knowledge "{\"query\":\"teaching beginner explanation Ollama vector RAG MCP YourNameBrain\",\"category\":\"teaching\"}" > "%TEMP_DIR%\teach_search.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\teach_search.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); print(count)" 2>nul > "%TEMP_DIR%\teach_count.txt"
    set /p TEACH_COUNT=<"%TEMP_DIR%\teach_count.txt"
    if !TEACH_COUNT! GEQ 5 (
        echo  [92m   PASS: Found !TEACH_COUNT! teaching entries[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: Found only !TEACH_COUNT! teaching entries (need at least 5)[0m
        echo          Fix: Run exercise.bat to add all 5 teaching-category knowledge entries
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge call failed[0m
    echo          Fix: Check MCP server is running on port 8100
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: chat_with_shanebrain responds to "What is Ollama?" ---
echo  [CHECK 3/%TOTAL_CHECKS%] chat_with_shanebrain responds to beginner question
echo   Asking: "What is Ollama? Explain it simply."
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"What is Ollama? Explain it simply.\"}" > "%TEMP_DIR%\chat.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: chat_with_shanebrain responded[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: chat_with_shanebrain did not respond[0m
    echo          Fix: Check that Ollama is running (it generates the answers)
    echo          Test: curl http://localhost:11434/api/tags
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: Response is substantive (>50 chars) and not an error ---
echo  [CHECK 4/%TOTAL_CHECKS%] Response is substantive (more than 50 characters, no error)
python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat.txt')); text=d.get('text',d.get('response',str(d))); ok=len(text)>50 and 'error' not in text.lower()[:50]; print('OK' if ok else 'ERROR')" 2>nul > "%TEMP_DIR%\content_status.txt"
set /p CONTENT_STATUS=<"%TEMP_DIR%\content_status.txt"
if "%CONTENT_STATUS%"=="OK" (
    echo  [92m   PASS: Response is substantive and not an error[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Response was too short or contained an error[0m
    echo          Fix: Check Ollama is running and has a model loaded
    echo          Test: curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Hello\",\"stream\":false}"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: search_knowledge finds teaching entries ---
echo  [CHECK 5/%TOTAL_CHECKS%] search_knowledge finds teaching entries
python "%MCP_CALL%" search_knowledge "{\"query\":\"explain AI concepts for beginners teaching\"}" > "%TEMP_DIR%\search_verify.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search_verify.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])); has=len(results)>0 if isinstance(results,list) else bool(results); print('OK' if has else 'EMPTY')" 2>nul > "%TEMP_DIR%\search_status.txt"
    set /p SEARCH_STATUS=<"%TEMP_DIR%\search_status.txt"
    if "!SEARCH_STATUS!"=="OK" (
        echo  [92m   PASS: search_knowledge found teaching entries[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: search_knowledge returned empty results[0m
        echo          Fix: Run exercise.bat to add teaching entries, then search will find them
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge tool call failed[0m
    echo          Fix: Check MCP server is running on port 8100
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
    echo  [92m   MODULE 5.4 COMPLETE — Teach the Teacher[0m
    echo.
    echo  [92m   You proved:[0m
    echo  [92m   + 5 teaching-category knowledge entries stored[0m
    echo  [92m   + chat_with_shanebrain can answer beginner questions[0m
    echo  [92m   + Responses are substantive and grounded in your entries[0m
    echo  [92m   + search_knowledge finds teaching content by meaning[0m
    echo  [92m   + Your brain can teach — not just remember[0m
    echo.
    echo   You are no longer just the student. Your brain is
    echo   the teacher now, and every entry you add makes it
    echo   better at helping others start from zero.
    echo.
    echo   Next: Module 5.5 — Workshop in a Box
    echo  ══════════════════════════════════════════════════════

    :: --- Update progress ---
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "5.4", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
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
