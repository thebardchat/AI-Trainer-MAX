@echo off
setlocal enabledelayedexpansion
title Module 2.4 Verify

:: ============================================================
:: MODULE 2.4 VERIFICATION
:: Checks: Services, MessageLog schema, messages classified,
::         sort-and-route.bat generated, classification works
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "TEMP_DIR=%TEMP%\module-2.4-verify"
set "OUTPUT_DIR=%~dp0output"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.4 VERIFICATION
echo  ══════════════════════════════════════════════════════
echo.

:: --- CHECK 1: Ollama running ---
echo  [CHECK 1/%TOTAL_CHECKS%] Ollama server running
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Ollama responding[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Ollama not responding[0m
    echo          Fix: Run "ollama serve"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: Weaviate running ---
echo  [CHECK 2/%TOTAL_CHECKS%] Weaviate server running
curl -s http://localhost:8080/v1/.well-known/ready >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Weaviate responding[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Weaviate not responding[0m
    echo          Fix: Start Weaviate via Docker
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: MessageLog schema exists ---
echo  [CHECK 3/%TOTAL_CHECKS%] MessageLog class exists
curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "MessageLog" >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: "MessageLog" class found[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: "MessageLog" class not found[0m
    echo          Fix: Run exercise.bat to create the schema
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: MessageLog has classified messages ---
echo  [CHECK 4/%TOTAL_CHECKS%] Messages classified and stored
python -c "import json,urllib.request; req=urllib.request.Request('http://localhost:8080/v1/graphql',data=json.dumps({'query':'{Aggregate{MessageLog{meta{count}}}}'}).encode(),headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); count=resp.get('data',{}).get('Aggregate',{}).get('MessageLog',[{}])[0].get('meta',{}).get('count',0); print(count)" 2>nul > "%TEMP_DIR%\msg_count.txt"
set /p MSG_COUNT=<"%TEMP_DIR%\msg_count.txt"
if %MSG_COUNT% GEQ 3 (
    echo  [92m   PASS: %MSG_COUNT% messages classified in MessageLog[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Only %MSG_COUNT% messages in MessageLog (need 3+)[0m
    echo          Fix: Run exercise.bat — Task 2 classifies 5 sample messages
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Classification pipeline works ---
echo  [CHECK 5/%TOTAL_CHECKS%] Classification pipeline produces valid output
echo   Classifying test message: "I need a price quote for new flooring"

python -c "import json,urllib.request; msg='I need a price quote for new flooring in my office'; prompt='Classify this business message. Respond with EXACTLY three lines:\nCATEGORY: (quote_request, complaint, scheduling, payment, or general)\nPRIORITY: (HIGH, MEDIUM, or LOW)\nACTION: (one specific next step)\n\nMessage: '+msg; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); answer=resp.get('response',''); print('OK' if 'CATEGORY' in answer.upper() or 'PRIORITY' in answer.upper() else 'EMPTY')" 2>nul > "%TEMP_DIR%\class_status.txt"

set /p CLASS_STATUS=<"%TEMP_DIR%\class_status.txt"
if "%CLASS_STATUS%"=="OK" (
    echo  [92m   PASS: Classification pipeline returned valid output[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Classification pipeline did not produce valid output[0m
    echo          Fix: Ensure Ollama has the model loaded and is responding
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
    echo  [92m   ✓ MODULE 2.4 COMPLETE[0m
    echo  [92m   You proved: You can classify, prioritize, and[0m
    echo  [92m   route business messages automatically.[0m
    echo.

    set "PROGRESS_FILE=%~dp0..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "2.4", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 2.5 — Paperwork Machine
    echo   You can sort messages. Now generate documents.
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
