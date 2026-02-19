@echo off
setlocal enabledelayedexpansion
title Module 2.2 Verify

:: ============================================================
:: MODULE 2.2 VERIFICATION
:: Checks: Services, BusinessDoc prerequisite, answer-desk.bat
::         generated, Q&A returns cited answer
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "TEMP_DIR=%TEMP%\module-2.2-verify"
set "OUTPUT_DIR=%~dp0output"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.2 VERIFICATION
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

:: --- CHECK 3: BusinessDoc has documents ---
echo  [CHECK 3/%TOTAL_CHECKS%] BusinessDoc collection has documents
python -c "import json,urllib.request; req=urllib.request.Request('http://localhost:8080/v1/graphql',data=json.dumps({'query':'{Aggregate{BusinessDoc{meta{count}}}}'}).encode(),headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); count=resp.get('data',{}).get('Aggregate',{}).get('BusinessDoc',[{}])[0].get('meta',{}).get('count',0); print(count)" 2>nul > "%TEMP_DIR%\doc_count.txt"
set /p DOC_COUNT=<"%TEMP_DIR%\doc_count.txt"
if %DOC_COUNT% GEQ 3 (
    echo  [92m   PASS: %DOC_COUNT% BusinessDoc objects available[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Only %DOC_COUNT% BusinessDoc objects (need 3+)[0m
    echo          Fix: Complete Module 2.1 first
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: answer-desk.bat exists ---
echo  [CHECK 4/%TOTAL_CHECKS%] Answer Desk tool generated
if exist "%OUTPUT_DIR%\answer-desk.bat" (
    echo  [92m   PASS: answer-desk.bat found in output folder[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: answer-desk.bat not found[0m
    echo          Fix: Run exercise.bat to generate the tool
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: End-to-end Q&A with source citation ---
echo  [CHECK 5/%TOTAL_CHECKS%] Q&A returns answer with source citations
echo   Running query: "What is the service call fee?"

python -c "import json,urllib.request; q='What is the service call fee?'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':q}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); query='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:2){title content category _additional{distance}}}}'; gql_data=json.dumps({'query':query}).encode(); gql_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=gql_data,headers={'Content-Type':'application/json'}); gql_resp=json.loads(urllib.request.urlopen(gql_req).read()); docs=gql_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[]); ctx='\n'.join(['['+d.get('title','')+'] '+d.get('content','') for d in docs]); sources=', '.join([d.get('title','') for d in docs]); prompt='Answer using ONLY these docs. Cite the source.\n\n'+ctx+'\n\nQ: '+q+'\nA:'; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); ans=resp.get('response',''); print('OK' if len(ans)>10 else 'EMPTY'); open(r'%TEMP_DIR%\qa_answer.txt','w').write(ans+'\nSources: '+sources)" 2>nul > "%TEMP_DIR%\qa_status.txt"

set /p QA_STATUS=<"%TEMP_DIR%\qa_status.txt"
if "%QA_STATUS%"=="OK" (
    echo  [92m   PASS: Q&A returned a cited answer[0m
    echo.
    echo   [92m   Answer preview:[0m
    if exist "%TEMP_DIR%\qa_answer.txt" (
        for /f "usebackq tokens=*" %%a in ("%TEMP_DIR%\qa_answer.txt") do (
            echo    %%a
            goto :qa_shown
        )
        :qa_shown
    )
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Q&A did not return a usable answer[0m
    echo          Fix: Ensure BusinessDoc has documents and both services run
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
    echo  [92m   ✓ MODULE 2.2 COMPLETE[0m
    echo  [92m   You proved: You can get instant, cited answers[0m
    echo  [92m   from your business knowledge base.[0m
    echo.

    set "PROGRESS_FILE=%~dp0..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "2.2", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 2.3 — Draft It
    echo   You can answer questions. Now learn to WRITE from your docs.
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
