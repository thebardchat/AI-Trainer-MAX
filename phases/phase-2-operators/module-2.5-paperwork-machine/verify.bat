@echo off
setlocal enabledelayedexpansion
title Module 2.5 Verify

:: ============================================================
:: MODULE 2.5 VERIFICATION
:: Checks: Services, DocTemplate schema, templates seeded,
::         paperwork-machine.bat generated, document generation
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "TEMP_DIR=%TEMP%\module-2.5-verify"
set "OUTPUT_DIR=%~dp0output"
set "DOC_DIR=%~dp0output\documents"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.5 VERIFICATION
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

:: --- CHECK 3: DocTemplate schema with templates ---
echo  [CHECK 3/%TOTAL_CHECKS%] DocTemplate class with templates
python -c "import json,urllib.request; req=urllib.request.Request('http://localhost:8080/v1/graphql',data=json.dumps({'query':'{Aggregate{DocTemplate{meta{count}}}}'}).encode(),headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); count=resp.get('data',{}).get('Aggregate',{}).get('DocTemplate',[{}])[0].get('meta',{}).get('count',0); print(count)" 2>nul > "%TEMP_DIR%\tmpl_count.txt"
set /p TMPL_COUNT=<"%TEMP_DIR%\tmpl_count.txt"
if %TMPL_COUNT% GEQ 3 (
    echo  [92m   PASS: %TMPL_COUNT% DocTemplate objects stored[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Only %TMPL_COUNT% templates (need 3+)[0m
    echo          Fix: Run exercise.bat to create and seed templates
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: paperwork-machine.bat exists ---
echo  [CHECK 4/%TOTAL_CHECKS%] Paperwork Machine tool generated
if exist "%OUTPUT_DIR%\paperwork-machine.bat" (
    echo  [92m   PASS: paperwork-machine.bat found[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: paperwork-machine.bat not found[0m
    echo          Fix: Run exercise.bat to generate the tool
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Document generation works ---
echo  [CHECK 5/%TOTAL_CHECKS%] Document generation pipeline works
echo   Generating test document: "estimate for window repair"

python -c "import json,urllib.request; request='estimate for window repair at 100 Main St for Test Customer'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':request}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); tq='{Get{DocTemplate(nearVector:{vector:'+json.dumps(vec)+'},limit:1){title content docType}}}'; t_data=json.dumps({'query':tq}).encode(); t_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=t_data,headers={'Content-Type':'application/json'}); t_resp=json.loads(urllib.request.urlopen(t_req).read()); tmpl=t_resp.get('data',{}).get('Get',{}).get('DocTemplate',[{}])[0]; bq='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:1){content}}}'; b_data=json.dumps({'query':bq}).encode(); b_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=b_data,headers={'Content-Type':'application/json'}); b_resp=json.loads(urllib.request.urlopen(b_req).read()); biz=b_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[{}])[0]; prompt='Generate a brief estimate document for window repair. Template: '+tmpl.get('content','')+' Business data: '+biz.get('content',''); data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); doc=resp.get('response',''); print('OK' if len(doc)>30 else 'EMPTY')" 2>nul > "%TEMP_DIR%\gen_status.txt"

set /p GEN_STATUS=<"%TEMP_DIR%\gen_status.txt"
if "%GEN_STATUS%"=="OK" (
    echo  [92m   PASS: Document generation pipeline works[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Document generation did not produce output[0m
    echo          Fix: Ensure DocTemplate and BusinessDoc have data
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
    echo  [92m   ✓ MODULE 2.5 COMPLETE[0m
    echo  [92m   You proved: You can generate structured business[0m
    echo  [92m   documents from templates and real business data.[0m
    echo.

    set "PROGRESS_FILE=%~dp0..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "2.5", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 2.6 — Chain Reactions
    echo   You built all the tools. Now chain them together.
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
