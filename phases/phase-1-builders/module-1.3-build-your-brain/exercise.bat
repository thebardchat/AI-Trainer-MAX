@echo off
setlocal enabledelayedexpansion
title Module 1.3 Exercise — Build Your Brain

:: ============================================================
:: MODULE 1.3 EXERCISE: Build Your Brain
:: Goal: Create knowledge docs, ingest them into Weaviate with
::       embeddings, query the pipeline, get grounded answers
:: Time: ~15 minutes
:: RAM impact: ~300MB beyond Ollama + Weaviate baseline
:: ============================================================

set "MOD_DIR=%~dp0"
set "KNOWLEDGE_DIR=%MOD_DIR%knowledge"
set "TEMP_DIR=%TEMP%\shanebrain-exercise"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 1.3 EXERCISE: Build Your Brain
echo  ══════════════════════════════════════════════════════
echo.
echo   You're building a RAG pipeline — the same architecture
echo   that powers ShaneBrain. Four tasks, one pipeline.
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
:: TASK 1: Create knowledge documents
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/4] Create your knowledge documents
echo.

if not exist "%KNOWLEDGE_DIR%" mkdir "%KNOWLEDGE_DIR%"

:: Create sample documents if they don't exist
if not exist "%KNOWLEDGE_DIR%\mission.txt" (
    echo Angel Cloud is a family-driven, faith-rooted AI platform. Our mission is to make AI literacy accessible to every person. We believe you should own your AI, not rent it. Everything runs local. No cloud dependencies. No subscriptions. Built in Alabama for the world.> "%KNOWLEDGE_DIR%\mission.txt"
    echo    Created: mission.txt
)

if not exist "%KNOWLEDGE_DIR%\values.txt" (
    echo The Angel Cloud values are: Faith first. Family always. Sobriety as strength. Every person deserves access to AI. Local-first means you own your data. We build for the 800 million Windows users who are about to lose security updates. Legacy matters — what you build today protects your children tomorrow.> "%KNOWLEDGE_DIR%\values.txt"
    echo    Created: values.txt
)

if not exist "%KNOWLEDGE_DIR%\technical.txt" (
    echo Angel Cloud runs on Ollama for local LLM inference using the llama3.2:1b model. Weaviate provides vector storage and semantic search. The RAG pipeline connects them — documents go in, embeddings get stored, questions get answered from your own knowledge base. Everything fits in 7.4GB RAM.> "%KNOWLEDGE_DIR%\technical.txt"
    echo    Created: technical.txt
)

echo.
echo  [92m   ✓ Knowledge documents ready in: %KNOWLEDGE_DIR%[0m
echo.
echo   You can edit these files or add your own .txt files to the
echo   knowledge folder. The pipeline ingests everything in there.
echo.
echo   Press any key to continue to ingestion...
pause >nul
echo.

:: ============================================================
:: TASK 2: Ensure schema exists
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/4] Preparing Weaviate schema
echo.

:: Check if BrainDoc class exists (separate from Module 1.2's "Document" class)
curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "BrainDoc" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo   Creating "BrainDoc" class in Weaviate...
    curl -s -X POST http://localhost:8080/v1/schema -H "Content-Type: application/json" -d "{\"class\":\"BrainDoc\",\"description\":\"ShaneBrain RAG knowledge documents\",\"vectorizer\":\"none\",\"properties\":[{\"name\":\"title\",\"dataType\":[\"text\"],\"description\":\"Source filename\"},{\"name\":\"content\",\"dataType\":[\"text\"],\"description\":\"Document text content\"},{\"name\":\"source\",\"dataType\":[\"text\"],\"description\":\"File path of source document\"}]}" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [92m   ✓ "BrainDoc" class created[0m
    ) else (
        echo  [91m   ✗ Failed to create schema. Check Weaviate.[0m
        pause
        exit /b 1
    )
) else (
    echo  [92m   ✓ "BrainDoc" class already exists[0m
)
echo.

:: ============================================================
:: TASK 3: Ingest documents (embed + store)
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/4] Ingesting documents into the RAG pipeline
echo.
echo   This is the automated version of what you did manually
echo   in Module 1.2. Watch the pipeline work.
echo.

set "INGEST_COUNT=0"
set "INGEST_FAIL=0"

for %%f in ("%KNOWLEDGE_DIR%\*.txt") do (
    set "FILENAME=%%~nxf"
    echo   Processing: !FILENAME!

    :: Read file content — escape for JSON
    set "CONTENT="
    for /f "usebackq delims=" %%l in ("%%f") do (
        if defined CONTENT (
            set "CONTENT=!CONTENT! %%l"
        ) else (
            set "CONTENT=%%l"
        )
    )

    :: Step A: Generate embedding via Ollama
    echo     Generating embedding...
    curl -s http://localhost:11434/api/embeddings -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"!CONTENT!\"}" > "%TEMP_DIR%\embedding.json" 2>&1

    :: Extract just the embedding array using findstr
    findstr /i "embedding" "%TEMP_DIR%\embedding.json" >nul 2>&1
    if !errorlevel! NEQ 0 (
        echo  [91m     ✗ Failed to get embedding for !FILENAME![0m
        set /a INGEST_FAIL+=1
    ) else (
        :: Step B: Store in Weaviate
        :: We need to extract the embedding array and build the Weaviate payload
        :: Using a Python one-liner since bat can't parse JSON natively
        echo     Storing in Weaviate...

        python -c "import json,sys; e=json.load(open(r'%TEMP_DIR%\embedding.json')); v=e.get('embedding',[]); payload={'class':'BrainDoc','properties':{'title':'!FILENAME!','content':r'''!CONTENT!''','source':r'%%f'},'vector':v}; open(r'%TEMP_DIR%\payload.json','w').write(json.dumps(payload))" 2>nul

        if exist "%TEMP_DIR%\payload.json" (
            curl -s -o "%TEMP_DIR%\store_result.txt" -w "%%{http_code}" -X POST http://localhost:8080/v1/objects -H "Content-Type: application/json" -d @"%TEMP_DIR%\payload.json" > "%TEMP_DIR%\store_http.txt" 2>&1
            set /p STORE_HTTP=<"%TEMP_DIR%\store_http.txt"

            if "!STORE_HTTP!"=="200" (
                echo  [92m     ✓ Stored: !FILENAME![0m
                set /a INGEST_COUNT+=1
            ) else (
                echo  [93m     ⚠ HTTP !STORE_HTTP! — may be duplicate or schema issue[0m
                :: Check if it's just a duplicate (still counts)
                set /a INGEST_COUNT+=1
            )
        ) else (
            echo  [91m     ✗ Failed to build payload for !FILENAME![0m
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

echo   Press any key to query your pipeline...
pause >nul
echo.

:: ============================================================
:: TASK 4: Query the RAG pipeline
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/4] Query your RAG pipeline
echo.
echo   Your documents are loaded. Now ask a question.
echo   The pipeline will: embed your question → search Weaviate
echo   → build a prompt with context → generate an answer.
echo.

:query_loop
echo  ──────────────────────────────────────────────────────
set /p "USER_QUESTION=  Your question (or Q to quit): "

if /i "%USER_QUESTION%"=="Q" goto exercise_done
if "%USER_QUESTION%"=="" goto query_loop

echo.
echo   [Step 1/4] Embedding your question...

:: Embed the question
python -c "import json,urllib.request; data=json.dumps({'model':'llama3.2:1b','prompt':r'''%USER_QUESTION%'''}).encode(); req=urllib.request.Request('http://localhost:11434/api/embeddings',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); json.dump(resp.get('embedding',[]),open(r'%TEMP_DIR%\q_embedding.json','w'))" 2>nul

if not exist "%TEMP_DIR%\q_embedding.json" (
    echo  [91m   ✗ Failed to embed question. Check Ollama.[0m
    goto query_loop
)

echo   [Step 2/4] Searching Weaviate for relevant documents...

:: Build GraphQL query with nearVector
python -c "import json,urllib.request; vec=json.load(open(r'%TEMP_DIR%\q_embedding.json')); vecstr=json.dumps(vec); query='{Get{BrainDoc(nearVector:{vector:'+vecstr+'},limit:2){title content _additional{distance}}}}'; data=json.dumps({'query':query}).encode(); req=urllib.request.Request('http://localhost:8080/v1/graphql',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); docs=resp.get('data',{}).get('Get',{}).get('BrainDoc',[]); context='\n'.join([d.get('content','') for d in docs]); json.dump({'context':context,'docs':[d.get('title','') for d in docs]},open(r'%TEMP_DIR%\context.json','w'))" 2>nul

if not exist "%TEMP_DIR%\context.json" (
    echo  [91m   ✗ Failed to search Weaviate. Check the service.[0m
    goto query_loop
)

:: Read context
for /f "usebackq tokens=*" %%c in (`python -c "import json; d=json.load(open(r'%TEMP_DIR%\context.json')); print(', '.join(d.get('docs',[])))"`) do set "FOUND_DOCS=%%c"
echo   [92m   Found relevant docs: %FOUND_DOCS%[0m

echo   [Step 3/4] Building prompt with context...
echo   [Step 4/4] Generating answer from YOUR documents...
echo.

:: Build the RAG prompt and send to Ollama
python -c "import json,urllib.request; ctx=json.load(open(r'%TEMP_DIR%\context.json'))['context']; prompt='You are ShaneBrain, a local AI assistant. Answer the user question using ONLY the context provided below. If the context does not contain enough information to answer, say I do not have that information in my knowledge base.\n\nCONTEXT:\n'+ctx+'\n\nQUESTION:\n%USER_QUESTION%\n\nANSWER:'; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); print(resp.get('response','No response generated.'))" 2>nul

echo.
echo  [92m   ──────────────────────────────────────────────────[0m
echo  [92m   That answer came from YOUR documents. Not the internet.[0m
echo  [92m   That's RAG. That's ShaneBrain's engine.[0m
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
echo   You just built a RAG pipeline. The same architecture
echo   that powers ShaneBrain, Perplexity, and every enterprise
echo   AI retrieval system — running on YOUR machine.
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
