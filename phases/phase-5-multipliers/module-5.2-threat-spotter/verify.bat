@echo off
setlocal enabledelayedexpansion
title Module 5.2 Verify — Threat Spotter

:: ============================================================
:: MODULE 5.2 VERIFICATION
:: Checks: MCP reachable, 5+ security knowledge entries,
::         chat_with_shanebrain responds, response has severity
::         keywords, security_log_search executes
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.2-verify"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 5.2 VERIFICATION
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

:: --- CHECK 2: At least 5 security-category knowledge entries exist ---
echo  [CHECK 2/%TOTAL_CHECKS%] At least 5 security-category knowledge entries
python "%MCP_CALL%" search_knowledge "{\"query\":\"threat severity phishing social engineering unpatched passwords shoulder surfing\",\"category\":\"security\"}" > "%TEMP_DIR%\security_entries.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\security_entries.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])); count=len(results) if isinstance(results,list) else 0; print('OK' if count>=5 else 'LOW'); print(count)" 2>nul > "%TEMP_DIR%\sec_status.txt"
    set /p SEC_STATUS=<"%TEMP_DIR%\sec_status.txt"
    if "!SEC_STATUS!"=="OK" (
        echo  [92m   PASS: Found 5+ security knowledge entries[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: Found fewer than 5 security knowledge entries[0m
        echo          Fix: Run exercise.bat first to add all 5 threat definitions
        echo          Fix: Or add manually: python "%MCP_CALL%" add_knowledge "{\"content\":\"THREAT: ... SEVERITY: ...\",\"category\":\"security\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge tool call failed[0m
    echo          Fix: Check MCP server is running: python "%MCP_CALL%" system_health
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: chat_with_shanebrain responds to a threat scenario ---
echo  [CHECK 3/%TOTAL_CHECKS%] chat_with_shanebrain responds to threat scenario
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"Classify this security scenario using threat definitions in the security knowledge category. What threat type and severity? Scenario: I received an email asking me to click a link to verify my account credentials.\"}" > "%TEMP_DIR%\chat_response.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat_response.txt')); text=d.get('response',d.get('text',d.get('result',str(d)))); print('OK' if len(str(text).strip())>10 else 'EMPTY')" 2>nul > "%TEMP_DIR%\chat_status.txt"
    set /p CHAT_STATUS=<"%TEMP_DIR%\chat_status.txt"
    if "!CHAT_STATUS!"=="OK" (
        echo  [92m   PASS: chat_with_shanebrain returned a classification[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: chat_with_shanebrain returned empty response[0m
        echo          Fix: Check Ollama is running: curl http://localhost:11434/api/tags
        echo          Fix: Check model is loaded: ollama list
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: chat_with_shanebrain tool call failed[0m
    echo          Fix: Check MCP server and Ollama are both running
    echo          Fix: python "%MCP_CALL%" system_health
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: Response contains severity-related keywords ---
echo  [CHECK 4/%TOTAL_CHECKS%] Classification response contains severity keywords
if exist "%TEMP_DIR%\chat_response.txt" (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat_response.txt')); text=str(d).lower(); keywords=['high','medium','low','risk','threat','critical','severity','phishing','social engineering']; found=[k for k in keywords if k in text]; print('OK' if len(found)>=2 else 'MISSING')" 2>nul > "%TEMP_DIR%\keyword_status.txt"
    set /p KW_STATUS=<"%TEMP_DIR%\keyword_status.txt"
    if "!KW_STATUS!"=="OK" (
        echo  [92m   PASS: Response contains severity/threat keywords[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: Response missing severity keywords (high, medium, low, risk, threat, critical)[0m
        echo          Fix: Run exercise.bat to load threat definitions, then run verify.bat again
        echo          Fix: The AI needs threat definitions in the knowledge base to classify properly
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: No chat response file to check — Check 3 must pass first[0m
    echo          Fix: Resolve Check 3 failures first, then run verify.bat again
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: security_log_search executes ---
echo  [CHECK 5/%TOTAL_CHECKS%] security_log_search executes successfully
python "%MCP_CALL%" security_log_search "{\"query\":\"unauthorized access security threat\"}" > "%TEMP_DIR%\seclog.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: security_log_search executed successfully[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: security_log_search tool call failed[0m
    echo          Fix: Check MCP server is running: python "%MCP_CALL%" system_health
    echo          Fix: Try manually: python "%MCP_CALL%" security_log_search "{\"query\":\"test\"}"
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
    echo  [92m   MODULE 5.2 COMPLETE[0m
    echo  [92m   You proved: You can build a threat taxonomy and[0m
    echo  [92m   use AI to classify security scenarios against it.[0m
    echo  [92m   Your knowledge base is now a security advisor.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "5.2", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 5.3 — Backup and Restore
    echo   You've built the defenses. Now you'll learn to
    echo   protect the data behind them.
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
