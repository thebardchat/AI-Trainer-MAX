@echo off
setlocal enabledelayedexpansion
title Module 1.2 Verify

:: ============================================================
:: MODULE 1.2 VERIFICATION
:: Checks: Weaviate running, schema exists, document stored,
::         embedding API works, GraphQL search responds
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: Pattern: Matches Module 1.1 verify.bat structure
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 1.2 VERIFICATION
echo  ══════════════════════════════════════════════════════
echo.

:: --- CHECK 1: Weaviate server running ---
echo  [CHECK 1/%TOTAL_CHECKS%] Weaviate server running
curl -s http://localhost:8080/v1/.well-known/ready >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Weaviate responding on localhost:8080[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Weaviate not responding[0m
    echo          Fix: Start Weaviate via Docker or binary
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: Document class exists in schema ---
echo  [CHECK 2/%TOTAL_CHECKS%] "Document" class in schema
curl -s http://localhost:8080/v1/schema 2>nul > "%TEMP%\wv_schema.txt"
findstr /i "Document" "%TEMP%\wv_schema.txt" >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: "Document" class found in Weaviate schema[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: "Document" class not found[0m
    echo          Fix: Create schema with the curl command from the lesson
    set /a FAIL_COUNT+=1
)
del "%TEMP%\wv_schema.txt" 2>nul
echo.

:: --- CHECK 3: At least one document stored ---
echo  [CHECK 3/%TOTAL_CHECKS%] Document objects stored in Weaviate
curl -s "http://localhost:8080/v1/objects?class=Document&limit=1" 2>nul > "%TEMP%\wv_objects.txt"
findstr /i "title" "%TEMP%\wv_objects.txt" >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: At least one Document object stored[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: No Document objects found in Weaviate[0m
    echo          Fix: Store a document with an embedding (Task 3 in exercise)
    set /a FAIL_COUNT+=1
)
del "%TEMP%\wv_objects.txt" 2>nul
echo.

:: --- CHECK 4: Ollama embedding API responds ---
echo  [CHECK 4/%TOTAL_CHECKS%] Ollama embedding API functional
curl -s -o "%TEMP%\emb_response.txt" -w "%%{http_code}" http://localhost:11434/api/embeddings -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"test\"}" > "%TEMP%\emb_http.txt" 2>&1
set /p EMB_HTTP=<"%TEMP%\emb_http.txt"
del "%TEMP%\emb_http.txt" 2>nul

if "%EMB_HTTP%"=="200" (
    :: Verify we actually got an embedding back
    findstr /i "embedding" "%TEMP%\emb_response.txt" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [92m   PASS: Ollama returned embedding vector (HTTP 200)[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: Ollama returned 200 but no embedding data[0m
        echo          Fix: Ensure llama3.2:1b supports embeddings
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: Ollama embedding API returned HTTP %EMB_HTTP%[0m
    echo          Fix: Ensure Ollama is running and model is pulled
    set /a FAIL_COUNT+=1
)
del "%TEMP%\emb_response.txt" 2>nul
echo.

:: --- CHECK 5: GraphQL search endpoint responds ---
echo  [CHECK 5/%TOTAL_CHECKS%] Weaviate GraphQL search endpoint
curl -s -o "%TEMP%\gql_response.txt" -w "%%{http_code}" -X POST http://localhost:8080/v1/graphql -H "Content-Type: application/json" -d "{\"query\":\"{Get{Document(limit:1){title content}}}\"}" > "%TEMP%\gql_http.txt" 2>&1
set /p GQL_HTTP=<"%TEMP%\gql_http.txt"
del "%TEMP%\gql_http.txt" 2>nul

if "%GQL_HTTP%"=="200" (
    echo  [92m   PASS: GraphQL endpoint responding (HTTP 200)[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: GraphQL endpoint returned HTTP %GQL_HTTP%[0m
    echo          Fix: Weaviate may need restart, or schema may be missing
    set /a FAIL_COUNT+=1
)
del "%TEMP%\gql_response.txt" 2>nul
echo.

:: --- RESULTS ---
echo  ══════════════════════════════════════════════════════
if %FAIL_COUNT% EQU 0 (
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
    echo.
    echo  [92m   ✓ MODULE 1.2 COMPLETE[0m
    echo  [92m   You proved: Your AI has a memory.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "1.2", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 1.3 — Build Your Brain
    echo   Voice + Memory = RAG pipeline. Let's connect them.
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
