@echo off
setlocal enabledelayedexpansion
title Module 1.5 Verify — Ship It

:: ============================================================
:: MODULE 1.5 VERIFICATION (PHASE 1 CAPSTONE)
:: Checks: Launcher file exists, services running, MyBrain
::         schema, documents ingested, full RAG query works,
::         knowledge folder has documents
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: Pattern: Matches Module 1.1-1.4 verify.bat structure
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=7"
set "TEMP_DIR=%TEMP%\ship-it-verify"
set "OUTPUT_DIR=%~dp0output"
set "LAUNCHER=%OUTPUT_DIR%\my-brain.bat"
set "KNOWLEDGE_DIR=%OUTPUT_DIR%\knowledge"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 1.5 VERIFICATION — PHASE 1 CAPSTONE
echo  ══════════════════════════════════════════════════════
echo.

:: --- CHECK 1: Launcher file exists ---
echo  [CHECK 1/%TOTAL_CHECKS%] Launcher file exists
if exist "%LAUNCHER%" (
    echo  [92m   PASS: my-brain.bat found at %OUTPUT_DIR%[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: my-brain.bat not found[0m
    echo          Fix: Run exercise.bat first — it generates the launcher
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: Launcher contains key components ---
echo  [CHECK 2/%TOTAL_CHECKS%] Launcher has required components
if exist "%LAUNCHER%" (
    set "HAS_HEALTH=0"
    set "HAS_SCHEMA=0"
    set "HAS_INGEST=0"
    set "HAS_CHAT=0"

    findstr /i "FreePhysicalMemory" "%LAUNCHER%" >nul 2>&1 && set "HAS_HEALTH=1"
    findstr /i "v1/schema" "%LAUNCHER%" >nul 2>&1 && set "HAS_SCHEMA=1"
    findstr /i "embeddings" "%LAUNCHER%" >nul 2>&1 && set "HAS_INGEST=1"
    findstr /i "chat_loop" "%LAUNCHER%" >nul 2>&1 && set "HAS_CHAT=1"

    set /a COMPONENT_COUNT=!HAS_HEALTH! + !HAS_SCHEMA! + !HAS_INGEST! + !HAS_CHAT!

    if !COMPONENT_COUNT! GEQ 4 (
        echo  [92m   PASS: Launcher contains health checks, schema setup, ingestion, chat loop[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: Launcher missing components (!COMPONENT_COUNT!/4 found^)[0m
        echo          Expected: health check, schema setup, ingestion, chat loop
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: Cannot check components — launcher file missing[0m
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: Knowledge folder has documents ---
echo  [CHECK 3/%TOTAL_CHECKS%] Knowledge documents present
set "KDOC_COUNT=0"
if exist "%KNOWLEDGE_DIR%" (
    for %%f in ("%KNOWLEDGE_DIR%\*.txt") do set /a KDOC_COUNT+=1
)
if %KDOC_COUNT% GEQ 1 (
    echo  [92m   PASS: %KDOC_COUNT% knowledge document(s) in output/knowledge[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: No .txt files in output/knowledge[0m
    echo          Fix: Run exercise.bat — it creates sample documents
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: Ollama running ---
echo  [CHECK 4/%TOTAL_CHECKS%] Ollama server running
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Ollama responding[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Ollama not responding[0m
    echo          Fix: ollama serve
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Weaviate running ---
echo  [CHECK 5/%TOTAL_CHECKS%] Weaviate server running
curl -s http://localhost:8080/v1/.well-known/ready >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Weaviate responding[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Weaviate not responding[0m
    echo          Fix: Start via Docker
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 6: MyBrain schema exists ---
echo  [CHECK 6/%TOTAL_CHECKS%] "MyBrain" class in Weaviate schema
curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "MyBrain" >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: "MyBrain" class found[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: "MyBrain" class not found[0m
    echo          Fix: Run my-brain.bat once — it creates the schema
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 7: Full RAG pipeline via MyBrain class ---
echo  [CHECK 7/%TOTAL_CHECKS%] End-to-end RAG query via MyBrain
echo   Running: "What is the mission?"

python -c "import json,urllib.request; emb=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/embeddings',data=json.dumps({'model':'llama3.2:1b','prompt':'What is the mission?'}).encode(),headers={'Content-Type':'application/json'})).read()).get('embedding',[]); docs=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:8080/v1/graphql',data=json.dumps({'query':'{Get{MyBrain(nearVector:{vector:'+json.dumps(emb)+'},limit:2){title content}}}' }).encode(),headers={'Content-Type':'application/json'})).read()).get('data',{}).get('Get',{}).get('MyBrain',[]); ctx='\n'.join([d.get('content','') for d in docs]); resp=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/generate',data=json.dumps({'model':'llama3.2:1b','prompt':'Answer using ONLY this context:\n'+ctx+'\n\nQuestion: What is the mission?\nAnswer:','stream':False,'options':{'temperature':0.2}}).encode(),headers={'Content-Type':'application/json'})).read()); answer=resp.get('response',''); open(r'%TEMP_DIR%\final_answer.txt','w').write(answer); print('OK' if len(answer)>10 else 'EMPTY')" 2>nul > "%TEMP_DIR%\final_status.txt"

set /p FINAL_STATUS=<"%TEMP_DIR%\final_status.txt"
if "%FINAL_STATUS%"=="OK" (
    echo  [92m   PASS: Full RAG pipeline returned a grounded answer[0m
    set /a PASS_COUNT+=1
    echo.
    echo   [92m   Answer preview:[0m
    if exist "%TEMP_DIR%\final_answer.txt" (
        for /f "usebackq tokens=*" %%a in ("%TEMP_DIR%\final_answer.txt") do (
            echo    %%a
            goto :final_shown
        )
        :final_shown
    )
) else (
    echo  [91m   FAIL: RAG pipeline did not return a usable answer[0m
    echo          Fix: Run my-brain.bat first to ingest documents
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
    echo  [92m  ╔══════════════════════════════════════════════╗[0m
    echo  [92m  ║                                              ║[0m
    echo  [92m  ║   ✓ MODULE 1.5 COMPLETE                      ║[0m
    echo  [92m  ║   ✓ PHASE 1 COMPLETE                         ║[0m
    echo  [92m  ║                                              ║[0m
    echo  [92m  ║   You proved:                                ║[0m
    echo  [92m  ║   You can build, package, and ship a local   ║[0m
    echo  [92m  ║   AI system from scratch. No cloud. No       ║[0m
    echo  [92m  ║   subscription. No permission needed.        ║[0m
    echo  [92m  ║                                              ║[0m
    echo  [92m  ║   You are a BUILDER.                         ║[0m
    echo  [92m  ║                                              ║[0m
    echo  [92m  ║   Your legacy runs local.                    ║[0m
    echo  [92m  ║                                              ║[0m
    echo  [92m  ╚══════════════════════════════════════════════╝[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "1.5", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
        echo   {"phase": "1", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Phase 2 — OPERATORS — is next.
    echo   You'll teach your AI to do real business work:
    echo   invoices, schedules, customer responses, document Q^&A.
    echo.
    echo   But first: go add YOUR documents to the knowledge folder.
    echo   Make this brain YOURS.
    echo  ══════════════════════════════════════════════════════
    endlocal
    exit /b 0
) else (
    echo  [91m   RESULT: FAIL  (%PASS_COUNT%/%TOTAL_CHECKS% passed, %FAIL_COUNT% failed)[0m
    echo.
    echo   Review the failures above and fix them.
    echo   Most common fix: Run exercise.bat first, then my-brain.bat,
    echo   then verify.bat.
    echo   Need help? Check hints.md in this folder.
    echo  ══════════════════════════════════════════════════════
    endlocal
    exit /b 1
)
