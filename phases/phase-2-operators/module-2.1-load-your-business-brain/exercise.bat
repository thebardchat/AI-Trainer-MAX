@echo off
setlocal enabledelayedexpansion
title Module 2.1 Exercise — Load Your Business Brain

:: ============================================================
:: MODULE 2.1 EXERCISE: Load Your Business Brain
:: Goal: Create business docs, build BusinessDoc schema,
::       ingest with category tags, verify semantic search
:: Time: ~15 minutes
:: RAM impact: ~300MB beyond Ollama + Weaviate baseline
:: ============================================================

set "MOD_DIR=%~dp0"
set "BIZ_DIR=%MOD_DIR%business-docs"
set "TEMP_DIR=%TEMP%\module-2.1"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.1 EXERCISE: Load Your Business Brain
echo  ══════════════════════════════════════════════════════
echo.
echo   You're building a searchable knowledge base from real
echo   business documents. Three tasks. Fifteen minutes.
echo.
echo  ──────────────────────────────────────────────────────
echo.

:: --- PRE-FLIGHT: Check services ---
echo  [PRE-FLIGHT] Checking services...
echo.

curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   ✗ Ollama is not running. Start it: ollama serve[0m
    pause
    exit /b 1
)
echo  [92m   ✓ Ollama running[0m

curl -s http://localhost:8080/v1/.well-known/ready >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   ✗ Weaviate is not running. Start it first.[0m
    pause
    exit /b 1
)
echo  [92m   ✓ Weaviate running[0m

curl -s http://localhost:11434/api/tags 2>nul | findstr /i "llama3.2:1b" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   ✗ Model llama3.2:1b not found. Run: ollama pull llama3.2:1b[0m
    pause
    exit /b 1
)
echo  [92m   ✓ Model llama3.2:1b available[0m
echo.

:: Create temp working directory
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: ============================================================
:: TASK 1: Create business documents
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/3] Create your business documents
echo.

if not exist "%BIZ_DIR%" mkdir "%BIZ_DIR%"

:: Create sample business documents if they don't exist
if not exist "%BIZ_DIR%\pricing.txt" (
    echo Our standard rates: Service call fee is $85. Hourly labor rate is $65 per hour. Emergency and after-hours calls are billed at 1.5x the standard rate. Material markup is 15 percent on all parts and supplies. Payment is due upon completion unless credit terms are arranged in advance. We accept cash, check, and all major credit cards. Estimates are free for jobs over $500. Jobs under $500 have a $25 estimate fee applied to the final invoice if you proceed.> "%BIZ_DIR%\pricing.txt"
    echo    Created: pricing.txt
)

if not exist "%BIZ_DIR%\services.txt" (
    echo We provide residential and commercial services within a 50-mile radius. Our core services include: installation, repair, maintenance, and emergency response. We specialize in same-day service for urgent issues. All work comes with a 90-day warranty on labor. We are licensed, bonded, and insured. Our team has over 15 years of experience. We offer scheduled maintenance plans at a 10 percent discount on labor.> "%BIZ_DIR%\services.txt"
    echo    Created: services.txt
)

if not exist "%BIZ_DIR%\policies.txt" (
    echo Cancellation policy: Cancel at least 24 hours before the scheduled appointment for no charge. Cancellations within 24 hours incur a $50 fee. No-shows are billed the full service call fee. Warranty claims must be filed within 90 days of service completion. We do not warranty customer-supplied materials. Complaints should be reported within 7 days. All disputes are handled locally.> "%BIZ_DIR%\policies.txt"
    echo    Created: policies.txt
)

if not exist "%BIZ_DIR%\faq.txt" (
    echo Frequently Asked Questions: Q: Do you offer free estimates? A: Yes, for jobs over $500. Smaller jobs have a $25 estimate fee credited to the final bill. Q: What areas do you serve? A: Anywhere within a 50-mile radius of our main office. Q: Do you work weekends? A: Yes, Saturday service is available at standard rates. Sunday and holidays are billed at the emergency rate. Q: How fast can you get here? A: Same-day service is available for most calls placed before noon. Q: Do you offer financing? A: We offer payment plans on jobs over $1000.> "%BIZ_DIR%\faq.txt"
    echo    Created: faq.txt
)

if not exist "%BIZ_DIR%\procedures.txt" (
    echo Standard job procedure: 1. Customer calls or submits a request. 2. Dispatcher confirms details and schedules the appointment. 3. Technician arrives on site within the scheduled window. 4. Assess the situation and provide a verbal estimate. 5. Get customer approval before starting work. 6. Complete the job and clean up the work area. 7. Collect payment and provide a receipt. 8. Follow up within 48 hours to confirm satisfaction. For emergency calls, skip to step 3 and provide the estimate on arrival.> "%BIZ_DIR%\procedures.txt"
    echo    Created: procedures.txt
)

echo.
echo  [92m   ✓ Business documents ready in: %BIZ_DIR%[0m
echo.
echo   These are sample docs for a general small business.
echo   After completing this module, replace them with YOUR
echo   real business documents for a truly useful knowledge base.
echo.
echo   Press any key to continue to schema setup...
pause >nul
echo.

:: ============================================================
:: TASK 2: Create BusinessDoc schema and ingest documents
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/3] Create schema and ingest documents
echo.

:: Check if BusinessDoc class exists
curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "BusinessDoc" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo   Creating "BusinessDoc" class in Weaviate...
    curl -s -X POST http://localhost:8080/v1/schema -H "Content-Type: application/json" -d "{\"class\":\"BusinessDoc\",\"description\":\"Business knowledge base documents\",\"vectorizer\":\"none\",\"properties\":[{\"name\":\"title\",\"dataType\":[\"text\"],\"description\":\"Document title\"},{\"name\":\"content\",\"dataType\":[\"text\"],\"description\":\"Document text content\"},{\"name\":\"category\",\"dataType\":[\"text\"],\"description\":\"Document category: pricing, services, policies, faq, procedures, general\"},{\"name\":\"source\",\"dataType\":[\"text\"],\"description\":\"Source file path\"}]}" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [92m   ✓ "BusinessDoc" class created[0m
    ) else (
        echo  [91m   ✗ Failed to create schema. Check Weaviate.[0m
        pause
        exit /b 1
    )
) else (
    echo  [92m   ✓ "BusinessDoc" class already exists[0m
)
echo.

:: Ingest documents
echo   Ingesting business documents...
echo.

set "INGEST_COUNT=0"
set "INGEST_FAIL=0"

for %%f in ("%BIZ_DIR%\*.txt") do (
    set "FILENAME=%%~nf"
    set "FULLNAME=%%~nxf"
    echo   Processing: !FULLNAME!

    :: Determine category from filename
    set "CATEGORY=general"
    echo !FILENAME! | findstr /i "pricing price rate cost" >nul 2>&1 && set "CATEGORY=pricing"
    echo !FILENAME! | findstr /i "service" >nul 2>&1 && set "CATEGORY=services"
    echo !FILENAME! | findstr /i "polic" >nul 2>&1 && set "CATEGORY=policies"
    echo !FILENAME! | findstr /i "faq question" >nul 2>&1 && set "CATEGORY=faq"
    echo !FILENAME! | findstr /i "procedure process step" >nul 2>&1 && set "CATEGORY=procedures"

    :: Read file content
    set "CONTENT="
    for /f "usebackq delims=" %%l in ("%%f") do (
        if defined CONTENT (
            set "CONTENT=!CONTENT! %%l"
        ) else (
            set "CONTENT=%%l"
        )
    )

    :: Generate embedding via Ollama
    echo     Generating embedding...
    curl -s http://localhost:11434/api/embeddings -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"!CONTENT!\"}" > "%TEMP_DIR%\embedding.json" 2>&1

    findstr /i "embedding" "%TEMP_DIR%\embedding.json" >nul 2>&1
    if !errorlevel! NEQ 0 (
        echo  [91m     ✗ Failed to get embedding for !FULLNAME![0m
        set /a INGEST_FAIL+=1
    ) else (
        :: Store in Weaviate with category tag
        echo     Storing in Weaviate [category: !CATEGORY!]...

        python -c "import json,sys; e=json.load(open(r'%TEMP_DIR%\embedding.json')); v=e.get('embedding',[]); payload={'class':'BusinessDoc','properties':{'title':'!FILENAME!','content':r'''!CONTENT!''','category':'!CATEGORY!','source':r'%%f'},'vector':v}; open(r'%TEMP_DIR%\payload.json','w').write(json.dumps(payload))" 2>nul

        if exist "%TEMP_DIR%\payload.json" (
            curl -s -o "%TEMP_DIR%\store_result.txt" -w "%%{http_code}" -X POST http://localhost:8080/v1/objects -H "Content-Type: application/json" -d @"%TEMP_DIR%\payload.json" > "%TEMP_DIR%\store_http.txt" 2>&1
            set /p STORE_HTTP=<"%TEMP_DIR%\store_http.txt"

            if "!STORE_HTTP!"=="200" (
                echo  [92m     ✓ Stored: !FULLNAME! [!CATEGORY!][0m
                set /a INGEST_COUNT+=1
            ) else (
                echo  [93m     ⚠ HTTP !STORE_HTTP! — may be duplicate or schema issue[0m
                set /a INGEST_COUNT+=1
            )
        ) else (
            echo  [91m     ✗ Failed to build payload for !FULLNAME![0m
            echo          Note: This step uses Python. Ensure Python is installed.
            set /a INGEST_FAIL+=1
        )
    )
    echo.
)

echo  ──────────────────────────────────────────────────────
echo   Ingestion complete: %INGEST_COUNT% documents stored, %INGEST_FAIL% failed
echo  ──────────────────────────────────────────────────────
echo.

if %INGEST_COUNT% EQU 0 (
    echo  [91m   No documents were ingested. Check errors above.[0m
    echo   Common fix: Make sure Python is installed and in PATH.
    pause
    exit /b 1
)

echo   Press any key to test your knowledge base...
pause >nul
echo.

:: ============================================================
:: TASK 3: Test semantic search on your business docs
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/3] Test your business knowledge base
echo.
echo   Your business documents are loaded. Ask questions about
echo   your business and watch the AI answer from YOUR docs.
echo.

:query_loop
echo  ──────────────────────────────────────────────────────
set /p "USER_QUESTION=  Your question (or Q to quit): "

if /i "%USER_QUESTION%"=="Q" goto exercise_done
if "%USER_QUESTION%"=="" goto query_loop

echo.
echo   [Step 1/3] Searching your business knowledge base...

:: Embed question and search Weaviate
python -c "import json,urllib.request; emb_data=json.dumps({'model':'llama3.2:1b','prompt':r'''%USER_QUESTION%'''}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); query='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:2){title content category source _additional{distance}}}}'; gql_data=json.dumps({'query':query}).encode(); gql_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=gql_data,headers={'Content-Type':'application/json'}); gql_resp=json.loads(urllib.request.urlopen(gql_req).read()); docs=gql_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[]); ctx='\n'.join([d.get('content','') for d in docs]); sources=', '.join([d.get('title','')+' ['+d.get('category','')+']' for d in docs]); print('SOURCES: '+sources); json.dump({'context':ctx,'sources':sources},open(r'%TEMP_DIR%\biz_context.json','w'))" 2>nul

if not exist "%TEMP_DIR%\biz_context.json" (
    echo  [91m   ✗ Failed to search. Check Ollama and Weaviate.[0m
    goto query_loop
)

echo   [Step 2/3] Building answer from your documents...
echo   [Step 3/3] Generating response...
echo.

:: Generate answer with source citation
python -c "import json,urllib.request; d=json.load(open(r'%TEMP_DIR%\biz_context.json')); ctx=d['context']; prompt='You are a business assistant. Answer the question using ONLY the business documents provided below. Be specific with numbers and details. If the documents do not contain the answer, say so.\n\nBUSINESS DOCUMENTS:\n'+ctx+'\n\nQUESTION: %USER_QUESTION%\n\nANSWER:'; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); print(resp.get('response','No response generated.')); print('\n   Source docs: '+d['sources'])" 2>nul

echo.
echo  [92m   ──────────────────────────────────────────────────[0m
echo  [92m   That answer came from YOUR business documents.[0m
echo  [92m   Notice the source citation — you can verify it.[0m
echo  [92m   ──────────────────────────────────────────────────[0m
echo.

goto query_loop

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   Your business knowledge base is live. Five documents
echo   loaded with category tags and source tracking.
echo.
echo   Want to make it YOURS? Replace the sample docs in:
echo     %BIZ_DIR%
echo   with your real business files, then run this again.
echo.
echo   Now run verify.bat to confirm everything passed:
echo.
echo       verify.bat
echo.

:: Cleanup temp files
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
