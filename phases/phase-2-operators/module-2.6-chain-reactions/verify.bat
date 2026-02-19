@echo off
setlocal enabledelayedexpansion
title Module 2.6 Verify

:: ============================================================
:: MODULE 2.6 VERIFICATION
:: Checks: Services, all prerequisite classes, WorkflowLog,
::         chain-reactions.bat generated, workflow logged
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=6"
set "TEMP_DIR=%TEMP%\module-2.6-verify"
set "OUTPUT_DIR=%~dp0output"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.6 VERIFICATION
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

:: --- CHECK 3: All prerequisite classes exist ---
echo  [CHECK 3/%TOTAL_CHECKS%] All Phase 2 Weaviate classes present
set "CLASS_COUNT=0"
for %%c in (BusinessDoc DraftTemplate MessageLog DocTemplate WorkflowLog) do (
    curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "%%c" >nul 2>&1
    if !errorlevel! EQU 0 set /a CLASS_COUNT+=1
)
if %CLASS_COUNT% GEQ 5 (
    echo  [92m   PASS: All 5 Phase 2 classes found[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Only %CLASS_COUNT%/5 classes found[0m
    echo          Fix: Complete Modules 2.1-2.5, then run this exercise
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: WorkflowLog has entries ---
echo  [CHECK 4/%TOTAL_CHECKS%] WorkflowLog has workflow records
python -c "import json,urllib.request; req=urllib.request.Request('http://localhost:8080/v1/graphql',data=json.dumps({'query':'{Aggregate{WorkflowLog{meta{count}}}}'}).encode(),headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); count=resp.get('data',{}).get('Aggregate',{}).get('WorkflowLog',[{}])[0].get('meta',{}).get('count',0); print(count)" 2>nul > "%TEMP_DIR%\wf_count.txt"
set /p WF_COUNT=<"%TEMP_DIR%\wf_count.txt"
if %WF_COUNT% GEQ 1 (
    echo  [92m   PASS: %WF_COUNT% workflow(s) logged[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: No workflows logged[0m
    echo          Fix: Run exercise.bat — Task 2 runs a demo workflow
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: chain-reactions.bat exists ---
echo  [CHECK 5/%TOTAL_CHECKS%] Chain Reactions tool generated
if exist "%OUTPUT_DIR%\chain-reactions.bat" (
    echo  [92m   PASS: chain-reactions.bat found[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: chain-reactions.bat not found[0m
    echo          Fix: Run exercise.bat to generate the tool
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 6: End-to-end chain works ---
echo  [CHECK 6/%TOTAL_CHECKS%] Workflow chain produces output
echo   Running test chain on: "I need a quote for painting"

python -c "import json,urllib.request; inp='I need a quote for painting my office lobby'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':inp}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); bq='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:1){content}}}'; b_data=json.dumps({'query':bq}).encode(); b_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=b_data,headers={'Content-Type':'application/json'}); b_resp=json.loads(urllib.request.urlopen(b_req).read()); biz=b_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[{}])[0]; prompt='Lead: '+inp+' Pricing: '+biz.get('content','')+' 1. Classify. 2. Draft welcome with pricing.'; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); out=resp.get('response',''); print('OK' if len(out)>20 else 'EMPTY')" 2>nul > "%TEMP_DIR%\chain_status.txt"

set /p CHAIN_STATUS=<"%TEMP_DIR%\chain_status.txt"
if "%CHAIN_STATUS%"=="OK" (
    echo  [92m   PASS: Workflow chain produced output[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Workflow chain did not produce output[0m
    echo          Fix: Ensure all services and collections are populated
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
    echo  [92m   ✓ MODULE 2.6 COMPLETE[0m
    echo  [92m   You proved: You can chain multiple AI tools[0m
    echo  [92m   into automated workflows with full logging.[0m
    echo.

    set "PROGRESS_FILE=%~dp0..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "2.6", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 2.7 — Your Operator Dashboard
    echo   Package everything into one tool. The capstone.
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
