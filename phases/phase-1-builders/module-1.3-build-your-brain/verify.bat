@echo off
setlocal enabledelayedexpansion
title Module 1.3 Verify

:: ============================================================
:: MODULE 1.3 VERIFICATION
:: Checks: Both services, BrainDoc schema, documents ingested,
::         embedding works, full RAG query returns grounded answer
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: Pattern: Matches Module 1.1/1.2 verify.bat structure
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=6"
set "TEMP_DIR=%TEMP%\shanebrain-verify"
set "KNOWLEDGE_DIR=%~dp0knowledge"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 1.3 VERIFICATION
echo  ══════════════════════════════════════════════════════
echo.

:: --- CHECK 1: Ollama running ---
echo  [CHECK 1/%TOTAL_CHECKS%] Ollama server running
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Ollama responding on localhost:11434[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Ollama not responding[0m
    echo          Fix: Run "ollama serve" in a separate terminal
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: Weaviate running ---
echo  [CHECK 2/%TOTAL_CHECKS%] Weaviate server running
curl -s http://localhost:8080/v1/.well-known/ready >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Weaviate responding on localhost:8080[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Weaviate not responding[0m
    echo          Fix: Start Weaviate via Docker
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: BrainDoc schema exists ---
echo  [CHECK 3/%TOTAL_CHECKS%] "BrainDoc" class in Weaviate schema
curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "BrainDoc" >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: "BrainDoc" class found in schema[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: "BrainDoc" class not found[0m
    echo          Fix: Run exercise.bat — it creates the schema automatically
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: Knowledge documents exist ---
echo  [CHECK 4/%TOTAL_CHECKS%] Knowledge documents present
set "DOC_COUNT=0"
if exist "%KNOWLEDGE_DIR%" (
    for %%f in ("%KNOWLEDGE_DIR%\*.txt") do set /a DOC_COUNT+=1
)
if %DOC_COUNT% GEQ 1 (
    echo  [92m   PASS: %DOC_COUNT% knowledge document(s) found in knowledge folder[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: No .txt files found in knowledge folder[0m
    echo          Fix: Run exercise.bat — it creates sample documents
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Documents ingested into Weaviate ---
echo  [CHECK 5/%TOTAL_CHECKS%] BrainDoc objects stored in Weaviate
curl -s "http://localhost:8080/v1/objects?class=BrainDoc&limit=1" 2>nul > "%TEMP_DIR%\braindocs.txt"
findstr /i "title" "%TEMP_DIR%\braindocs.txt" >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: BrainDoc objects found in Weaviate[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: No BrainDoc objects found in Weaviate[0m
    echo          Fix: Run exercise.bat to ingest documents
    set /a FAIL_COUNT+=1
)
del "%TEMP_DIR%\braindocs.txt" 2>nul
echo.

:: --- CHECK 6: Full RAG query returns an answer ---
echo  [CHECK 6/%TOTAL_CHECKS%] Full RAG pipeline produces grounded answer
echo   Running end-to-end query: "What is Angel Cloud?"

:: This check runs the full pipeline in one Python call
python -c "import json,urllib.request; emb_data=json.dumps({'model':'llama3.2:1b','prompt':'What is Angel Cloud?'}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); query='{Get{BrainDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:2){title content}}}'; gql_data=json.dumps({'query':query}).encode(); gql_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=gql_data,headers={'Content-Type':'application/json'}); gql_resp=json.loads(urllib.request.urlopen(gql_req).read()); docs=gql_resp.get('data',{}).get('Get',{}).get('BrainDoc',[]); ctx='\n'.join([d.get('content','') for d in docs]); prompt='Answer using ONLY this context:\n'+ctx+'\n\nQuestion: What is Angel Cloud?\nAnswer:'; gen_data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); gen_req=urllib.request.Request('http://localhost:11434/api/generate',data=gen_data,headers={'Content-Type':'application/json'}); gen_resp=json.loads(urllib.request.urlopen(gen_req).read()); answer=gen_resp.get('response',''); open(r'%TEMP_DIR%\rag_answer.txt','w').write(answer); print('OK' if len(answer)>10 else 'EMPTY')" 2>nul > "%TEMP_DIR%\rag_status.txt"

set /p RAG_STATUS=<"%TEMP_DIR%\rag_status.txt"
if "%RAG_STATUS%"=="OK" (
    echo  [92m   PASS: RAG pipeline returned a grounded answer[0m
    echo.
    echo   [92m   Answer preview:[0m
    if exist "%TEMP_DIR%\rag_answer.txt" (
        for /f "usebackq tokens=*" %%a in ("%TEMP_DIR%\rag_answer.txt") do (
            echo    %%a
            goto :answer_shown
        )
        :answer_shown
    )
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: RAG pipeline did not return a usable answer[0m
    echo          Fix: Ensure documents are ingested and both services are running
    echo          Note: This check requires Python in PATH
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
    echo  [92m   ✓ MODULE 1.3 COMPLETE[0m
    echo  [92m   You proved: You can build a RAG pipeline from scratch.[0m
    echo  [92m   Voice + Memory + Pipeline = Your own AI brain.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "1.3", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 1.4 — Prompt Engineering for Local Models
    echo   Your pipeline works. Now make it work WELL.
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
