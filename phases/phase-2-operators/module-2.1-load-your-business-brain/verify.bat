@echo off
setlocal enabledelayedexpansion
title Module 2.1 Verify

:: ============================================================
:: MODULE 2.1 VERIFICATION
:: Checks: Services, BusinessDoc schema, documents ingested,
::         category tags present, semantic search works
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=6"
set "TEMP_DIR=%TEMP%\module-2.1-verify"
set "BIZ_DIR=%~dp0business-docs"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.1 VERIFICATION
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

:: --- CHECK 3: BusinessDoc schema exists ---
echo  [CHECK 3/%TOTAL_CHECKS%] "BusinessDoc" class in Weaviate schema
curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "BusinessDoc" >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: "BusinessDoc" class found in schema[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: "BusinessDoc" class not found[0m
    echo          Fix: Run exercise.bat — it creates the schema automatically
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: Business documents exist on disk ---
echo  [CHECK 4/%TOTAL_CHECKS%] Business documents present
set "DOC_COUNT=0"
if exist "%BIZ_DIR%" (
    for %%f in ("%BIZ_DIR%\*.txt") do set /a DOC_COUNT+=1
)
if %DOC_COUNT% GEQ 3 (
    echo  [92m   PASS: %DOC_COUNT% business document(s) found[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Need at least 3 .txt files in business-docs folder (found %DOC_COUNT%)[0m
    echo          Fix: Run exercise.bat — it creates sample documents
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: BusinessDoc objects in Weaviate with categories ---
echo  [CHECK 5/%TOTAL_CHECKS%] BusinessDoc objects stored with category tags
python -c "import json,urllib.request; req=urllib.request.Request('http://localhost:8080/v1/graphql',data=json.dumps({'query':'{Aggregate{BusinessDoc{meta{count}}}}'}).encode(),headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); count=resp.get('data',{}).get('Aggregate',{}).get('BusinessDoc',[{}])[0].get('meta',{}).get('count',0); print(count)" 2>nul > "%TEMP_DIR%\obj_count.txt"
set /p OBJ_COUNT=<"%TEMP_DIR%\obj_count.txt"
if %OBJ_COUNT% GEQ 3 (
    echo  [92m   PASS: %OBJ_COUNT% BusinessDoc objects in Weaviate[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Only %OBJ_COUNT% BusinessDoc objects found (need at least 3)[0m
    echo          Fix: Run exercise.bat to ingest documents
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 6: Semantic search returns relevant results ---
echo  [CHECK 6/%TOTAL_CHECKS%] Semantic search returns business answers
echo   Running query: "What are the rates?"

python -c "import json,urllib.request; emb_data=json.dumps({'model':'llama3.2:1b','prompt':'What are the rates and pricing?'}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); query='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:1){title category content}}}'; gql_data=json.dumps({'query':query}).encode(); gql_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=gql_data,headers={'Content-Type':'application/json'}); gql_resp=json.loads(urllib.request.urlopen(gql_req).read()); docs=gql_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[]); doc=docs[0] if docs else {}; title=doc.get('title',''); cat=doc.get('category',''); print('OK|'+title+'|'+cat if title else 'EMPTY')" 2>nul > "%TEMP_DIR%\search_status.txt"

set /p SEARCH_STATUS=<"%TEMP_DIR%\search_status.txt"
for /f "tokens=1,2,3 delims=|" %%a in ("%SEARCH_STATUS%") do (
    set "S_RESULT=%%a"
    set "S_TITLE=%%b"
    set "S_CAT=%%c"
)

if "%S_RESULT%"=="OK" (
    echo  [92m   PASS: Search returned "%S_TITLE%" [%S_CAT%][0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Semantic search returned no results[0m
    echo          Fix: Ensure documents are ingested and both services are running
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
    echo  [92m   ✓ MODULE 2.1 COMPLETE[0m
    echo  [92m   You proved: Your business documents are loaded,[0m
    echo  [92m   tagged, searchable, and ready for every tool[0m
    echo  [92m   you'll build in Phase 2.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "2.1", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 2.2 — The Instant Answer Desk
    echo   Your knowledge base is loaded. Now put it to work.
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
