@echo off
setlocal enabledelayedexpansion
title Module 2.3 Verify

:: ============================================================
:: MODULE 2.3 VERIFICATION
:: Checks: Services, DraftTemplate schema, templates seeded,
::         draft-it.bat generated, drafting pipeline works
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "TEMP_DIR=%TEMP%\module-2.3-verify"
set "OUTPUT_DIR=%~dp0output"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.3 VERIFICATION
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

:: --- CHECK 3: DraftTemplate schema exists with templates ---
echo  [CHECK 3/%TOTAL_CHECKS%] DraftTemplate class with templates
python -c "import json,urllib.request; req=urllib.request.Request('http://localhost:8080/v1/graphql',data=json.dumps({'query':'{Aggregate{DraftTemplate{meta{count}}}}'}).encode(),headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); count=resp.get('data',{}).get('Aggregate',{}).get('DraftTemplate',[{}])[0].get('meta',{}).get('count',0); print(count)" 2>nul > "%TEMP_DIR%\tmpl_count.txt"
set /p TMPL_COUNT=<"%TEMP_DIR%\tmpl_count.txt"
if %TMPL_COUNT% GEQ 3 (
    echo  [92m   PASS: %TMPL_COUNT% DraftTemplate objects stored[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Only %TMPL_COUNT% templates found (need 3+)[0m
    echo          Fix: Run exercise.bat to create schema and seed templates
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: draft-it.bat exists ---
echo  [CHECK 4/%TOTAL_CHECKS%] Draft It tool generated
if exist "%OUTPUT_DIR%\draft-it.bat" (
    echo  [92m   PASS: draft-it.bat found in output folder[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: draft-it.bat not found[0m
    echo          Fix: Run exercise.bat to generate the tool
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Drafting pipeline produces output ---
echo  [CHECK 5/%TOTAL_CHECKS%] Drafting pipeline produces a message
echo   Running test: "draft a reply about pricing"

python -c "import json,urllib.request; request='draft a reply about our pricing and rates'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':request}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); tq='{Get{DraftTemplate(nearVector:{vector:'+json.dumps(vec)+'},limit:1){title content tone}}}'; t_data=json.dumps({'query':tq}).encode(); t_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=t_data,headers={'Content-Type':'application/json'}); t_resp=json.loads(urllib.request.urlopen(t_req).read()); tmpl=t_resp.get('data',{}).get('Get',{}).get('DraftTemplate',[{}])[0]; bq='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:1){content}}}'; b_data=json.dumps({'query':bq}).encode(); b_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=b_data,headers={'Content-Type':'application/json'}); b_resp=json.loads(urllib.request.urlopen(b_req).read()); biz=b_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[{}])[0]; prompt='Write a professional reply about pricing. Style: '+tmpl.get('content','')+' Facts: '+biz.get('content',''); data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); ans=resp.get('response',''); print('OK' if len(ans)>20 else 'EMPTY')" 2>nul > "%TEMP_DIR%\draft_status.txt"

set /p DRAFT_STATUS=<"%TEMP_DIR%\draft_status.txt"
if "%DRAFT_STATUS%"=="OK" (
    echo  [92m   PASS: Drafting pipeline generated a message[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Drafting pipeline did not produce output[0m
    echo          Fix: Ensure both collections have data and services run
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
    echo  [92m   ✓ MODULE 2.3 COMPLETE[0m
    echo  [92m   You proved: You can draft business messages[0m
    echo  [92m   with templates, tone control, and real data.[0m
    echo.

    set "PROGRESS_FILE=%~dp0..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "2.3", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 2.4 — Sort and Route
    echo   You can write messages. Now learn to triage incoming ones.
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
