@echo off
setlocal enabledelayedexpansion
title Module 1.2 Exercise — Vectors Made Simple

:: ============================================================
:: MODULE 1.2 EXERCISE: Vectors Made Simple
:: Goal: Weaviate running, schema created, document stored with
::       embedding, semantic search returns results
:: Time: ~12 minutes
:: RAM impact: ~200MB for Weaviate + Ollama embedding call
:: ============================================================

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 1.2 EXERCISE: Vectors Made Simple
echo  ══════════════════════════════════════════════════════
echo.
echo   Complete these 4 tasks. Each one builds on the last.
echo   When you're done, run verify.bat to check your work.
echo.
echo  ──────────────────────────────────────────────────────
echo.

:: --- TASK 1: Verify Weaviate is running ---
echo  [TASK 1/4] Verify Weaviate is running on port 8080
echo.
echo   If Weaviate is already running, press any key.
echo   If not, start it with Docker:
echo.
echo       docker run -d --name weaviate -p 8080:8080 -p 50051:50051 ^
echo         -e QUERY_DEFAULTS_LIMIT=25 ^
echo         -e AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED=true ^
echo         -e PERSISTENCE_DATA_PATH=/var/lib/weaviate ^
echo         -e DEFAULT_VECTORIZER_MODULE=none ^
echo         -e CLUSTER_HOSTNAME=node1 ^
echo         cr.weaviate.io/semitechnologies/weaviate:1.28.4
echo.
echo   Press any key when Weaviate is running...
pause >nul

echo   Checking Weaviate...
curl -s http://localhost:8080/v1/.well-known/ready >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   ✗ Weaviate is not responding on localhost:8080[0m
    echo     Start it and re-run this exercise.
    pause
    exit /b 1
)
echo  [92m   ✓ Weaviate is running.[0m
echo.

:: --- Also verify Ollama for embeddings ---
echo   Checking Ollama (needed for embeddings)...
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   ✗ Ollama is not running. Start it: ollama serve[0m
    pause
    exit /b 1
)
echo  [92m   ✓ Ollama is running.[0m
echo.

:: --- TASK 2: Create the Document schema ---
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/4] Create the "Document" schema in Weaviate
echo.
echo   Run this command in your terminal (copy-paste the whole thing):
echo.
echo   curl -X POST http://localhost:8080/v1/schema -H "Content-Type: application/json" -d "{\"class\":\"Document\",\"description\":\"Training documents for ShaneBrain\",\"vectorizer\":\"none\",\"properties\":[{\"name\":\"title\",\"dataType\":[\"text\"],\"description\":\"Document title\"},{\"name\":\"content\",\"dataType\":[\"text\"],\"description\":\"Document body text\"}]}"
echo.
echo   You should see a JSON response with "class": "Document"
echo.
echo   NOTE: If you get "class name Document already exists" that's fine.
echo   It means you already created it. Move on.
echo.
echo   Press any key when done...
pause >nul

echo   Checking schema...
curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "Document" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   ✗ "Document" class not found in Weaviate schema.[0m
    echo     Run the curl command above and try again.
    pause
    exit /b 1
)
echo  [92m   ✓ "Document" class exists in schema.[0m
echo.

:: --- TASK 3: Store a document with an embedding ---
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/4] Store a document with a vector embedding
echo.
echo   This task has two parts:
echo.
echo   PART A — Generate an embedding. Run:
echo.
echo   curl http://localhost:11434/api/embeddings -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Angel Cloud is a local-first AI platform built for families.\"}"
echo.
echo   Copy the entire "embedding" array from the response.
echo.
echo   PART B — Store the document in Weaviate. Run:
echo.
echo   curl -X POST http://localhost:8080/v1/objects -H "Content-Type: application/json" -d "{\"class\":\"Document\",\"properties\":{\"title\":\"About Angel Cloud\",\"content\":\"Angel Cloud is a local-first AI platform built for families.\"},\"vector\":[PASTE_EMBEDDING_HERE]}"
echo.
echo   Replace [PASTE_EMBEDDING_HERE] with the numbers from Part A.
echo.
echo   You should get back a JSON object with an "id" field.
echo.
echo   Press any key when you've stored the document...
pause >nul

echo   Checking for stored documents...
curl -s "http://localhost:8080/v1/objects?class=Document&limit=1" 2>nul | findstr /i "Angel Cloud" >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   ✓ Document found in Weaviate with Angel Cloud content.[0m
) else (
    :: Check if ANY document exists
    curl -s "http://localhost:8080/v1/objects?class=Document&limit=1" 2>nul | findstr /i "title" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [92m   ✓ Document found in Weaviate.[0m
    ) else (
        echo  [93m   ⚠ No documents detected yet. Make sure you completed both Part A and Part B.[0m
        echo     The verify step will do a deeper check.
    )
)
echo.

:: --- TASK 4: Semantic search ---
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/4] Perform a semantic search
echo.
echo   PART A — Generate an embedding for a QUESTION:
echo.
echo   curl http://localhost:11434/api/embeddings -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"What platform works offline for families?\"}"
echo.
echo   PART B — Search Weaviate with that vector:
echo.
echo   curl -X POST http://localhost:8080/v1/graphql -H "Content-Type: application/json" -d "{\"query\":\"{Get{Document(nearVector:{vector:[PASTE_QUESTION_EMBEDDING]},limit:1){title content _additional{distance}}}}\"}"
echo.
echo   Replace [PASTE_QUESTION_EMBEDDING] with the numbers from Part A.
echo.
echo   You should get back the "About Angel Cloud" document — even though
echo   your question used completely different words.
echo.
echo   That's semantic search. Your AI now finds things by MEANING.
echo.
echo   Press any key when done...
pause >nul

echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   Now run verify.bat to confirm everything passed.
echo   From this module's folder, run:
echo.
echo       verify.bat
echo.
pause
endlocal
exit /b 0
