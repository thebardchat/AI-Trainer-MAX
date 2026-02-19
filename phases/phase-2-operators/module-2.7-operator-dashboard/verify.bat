@echo off
setlocal enabledelayedexpansion
title Module 2.7 Verify

:: ============================================================
:: MODULE 2.7 VERIFICATION — PHASE 2 CAPSTONE
:: Checks: Services, all classes, all tools, dashboard exists,
::         end-to-end functionality
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=7"
set "TEMP_DIR=%TEMP%\module-2.7-verify"
set "OUTPUT_DIR=%~dp0output"
set "PHASE_DIR=%~dp0.."

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.7 VERIFICATION — PHASE 2 CAPSTONE
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

:: --- CHECK 3: All 5 Weaviate classes exist ---
echo  [CHECK 3/%TOTAL_CHECKS%] All Phase 2 Weaviate classes present
set "CLASS_COUNT=0"
for %%c in (BusinessDoc DraftTemplate MessageLog DocTemplate WorkflowLog) do (
    curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "%%c" >nul 2>&1
    if !errorlevel! EQU 0 (
        set /a CLASS_COUNT+=1
        echo     [92m✓[0m %%c
    ) else (
        echo     [91m✗[0m %%c
    )
)
if %CLASS_COUNT% GEQ 5 (
    echo  [92m   PASS: All 5 classes present[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Only %CLASS_COUNT%/5 classes found[0m
    echo          Fix: Complete all modules 2.1-2.6
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: All collections have data ---
echo  [CHECK 4/%TOTAL_CHECKS%] All collections populated with data
python -c "import json,urllib.request; classes=['BusinessDoc','DraftTemplate','MessageLog','DocTemplate','WorkflowLog']; ok=0; total=5; " ^
"for cls in classes:" ^
"    try:" ^
"        req=urllib.request.Request('http://localhost:8080/v1/graphql',data=json.dumps({'query':'{Aggregate{'+cls+'{meta{count}}}}'}).encode(),headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); count=resp.get('data',{}).get('Aggregate',{}).get(cls,[{}])[0].get('meta',{}).get('count',0);" ^
"        if count>0: ok+=1; print(f'     {cls}: {count} objects')" ^
"        else: print(f'     {cls}: EMPTY')" ^
"    except: print(f'     {cls}: ERROR')" ^
"print(f'COUNT:{ok}')" 2>nul > "%TEMP_DIR%\data_check.txt"
type "%TEMP_DIR%\data_check.txt" | findstr /v "COUNT:" 2>nul
for /f "tokens=2 delims=:" %%a in ('findstr "COUNT:" "%TEMP_DIR%\data_check.txt"') do set "DATA_OK=%%a"
if %DATA_OK% GEQ 4 (
    echo  [92m   PASS: %DATA_OK%/5 collections have data[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Only %DATA_OK%/5 collections have data[0m
    echo          Fix: Run exercises for modules with empty collections
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Operator Dashboard exists ---
echo  [CHECK 5/%TOTAL_CHECKS%] Operator Dashboard generated
if exist "%OUTPUT_DIR%\operator-dashboard.bat" (
    echo  [92m   PASS: operator-dashboard.bat found[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: operator-dashboard.bat not found[0m
    echo          Fix: Run exercise.bat to generate the dashboard
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 6: Dashboard has required components ---
echo  [CHECK 6/%TOTAL_CHECKS%] Dashboard has all required sections
if exist "%OUTPUT_DIR%\operator-dashboard.bat" (
    set "COMP_COUNT=0"
    findstr /i "OPERATOR DASHBOARD" "%OUTPUT_DIR%\operator-dashboard.bat" >nul 2>&1 && set /a COMP_COUNT+=1
    findstr /i "Answer Desk" "%OUTPUT_DIR%\operator-dashboard.bat" >nul 2>&1 && set /a COMP_COUNT+=1
    findstr /i "Draft It" "%OUTPUT_DIR%\operator-dashboard.bat" >nul 2>&1 && set /a COMP_COUNT+=1
    findstr /i "Sort and Route" "%OUTPUT_DIR%\operator-dashboard.bat" >nul 2>&1 && set /a COMP_COUNT+=1
    findstr /i "Chain Reactions" "%OUTPUT_DIR%\operator-dashboard.bat" >nul 2>&1 && set /a COMP_COUNT+=1
    if !COMP_COUNT! GEQ 5 (
        echo  [92m   PASS: Dashboard contains all 5 tools[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: Dashboard missing components (!COMP_COUNT!/5 found)[0m
        echo          Fix: Run exercise.bat to regenerate
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: Dashboard file not found[0m
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 7: End-to-end pipeline still works ---
echo  [CHECK 7/%TOTAL_CHECKS%] End-to-end business pipeline functional
echo   Running quick Q&A test...

python -c "import json,urllib.request; q='What services do we offer?'; emb=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/embeddings',json.dumps({'model':'llama3.2:1b','prompt':q}).encode(),{'Content-Type':'application/json'})).read()).get('embedding',[]); docs=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:8080/v1/graphql',json.dumps({'query':'{Get{BusinessDoc(nearVector:{vector:'+json.dumps(emb)+'},limit:1){title content}}}'}).encode(),{'Content-Type':'application/json'})).read()).get('data',{}).get('Get',{}).get('BusinessDoc',[]); ctx=docs[0].get('content','') if docs else ''; ans=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/generate',json.dumps({'model':'llama3.2:1b','prompt':'Answer from docs: '+ctx+chr(10)+'Q: '+q+chr(10)+'A:','stream':False}).encode(),{'Content-Type':'application/json'})).read()).get('response',''); print('OK' if len(ans)>10 else 'EMPTY')" 2>nul > "%TEMP_DIR%\e2e_status.txt"

set /p E2E_STATUS=<"%TEMP_DIR%\e2e_status.txt"
if "%E2E_STATUS%"=="OK" (
    echo  [92m   PASS: Full pipeline operational[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Pipeline not producing results[0m
    echo          Fix: Check services and collection data
    set /a FAIL_COUNT+=1
)
echo.

:: Cleanup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

:: --- RESULTS ---
echo  ══════════════════════════════════════════════════════
if %FAIL_COUNT% EQU 0 (
    echo.
    echo  [92m   ╔══════════════════════════════════════════════╗[0m
    echo  [92m   ║                                              ║[0m
    echo  [92m   ║   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)          ║[0m
    echo  [92m   ║                                              ║[0m
    echo  [92m   ║   ██████╗ ██████╗ ███████╗██████╗            ║[0m
    echo  [92m   ║  ██╔═══██╗██╔══██╗██╔════╝██╔══██╗           ║[0m
    echo  [92m   ║  ██║   ██║██████╔╝█████╗  ██████╔╝           ║[0m
    echo  [92m   ║  ██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗           ║[0m
    echo  [92m   ║  ╚██████╔╝██║     ███████╗██║  ██║           ║[0m
    echo  [92m   ║   ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝           ║[0m
    echo  [92m   ║                                              ║[0m
    echo  [92m   ║   PHASE 2 COMPLETE                          ║[0m
    echo  [92m   ║   STATUS: OPERATOR                          ║[0m
    echo  [92m   ║                                              ║[0m
    echo  [92m   ╚══════════════════════════════════════════════╝[0m
    echo.
    echo  [92m   You proved:[0m
    echo  [92m   ✓ Load business documents into searchable AI[0m
    echo  [92m   ✓ Get instant answers with source citations[0m
    echo  [92m   ✓ Draft business messages with real data[0m
    echo  [92m   ✓ Classify and triage incoming messages[0m
    echo  [92m   ✓ Generate structured business documents[0m
    echo  [92m   ✓ Chain tools into automated workflows[0m
    echo  [92m   ✓ Package everything into a daily dashboard[0m
    echo.
    echo   You built a complete business AI toolkit that runs
    echo   locally, uses YOUR data, and needs no internet.
    echo.
    echo   Phase 1 made you a BUILDER.
    echo   Phase 2 made you an OPERATOR.
    echo.
    echo   Your Operator Dashboard: operator-dashboard.bat
    echo   Use it every day. Add your real documents.
    echo   Make it yours.
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "2.7", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Phase 3 — EVERYDAY USERS — coming soon.
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
