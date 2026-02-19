@echo off
setlocal enabledelayedexpansion
title Module 1.5 Exercise — Ship It

:: ============================================================
:: MODULE 1.5 EXERCISE: Ship It
:: Goal: Build a complete my-brain.bat launcher, test it,
::       verify it works end-to-end as a daily-use tool
:: Time: ~15 minutes
:: RAM impact: Same as Module 1.3 — pipeline operations only
:: ============================================================

set "MOD_DIR=%~dp0"
set "OUTPUT_DIR=%MOD_DIR%output"
set "LAUNCHER=%OUTPUT_DIR%\my-brain.bat"
set "KNOWLEDGE_DIR=%OUTPUT_DIR%\knowledge"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 1.5 EXERCISE: Ship It
echo  ══════════════════════════════════════════════════════
echo.
echo   This is the capstone. You're building a production
echo   launcher that packages everything from Modules 1.1-1.4
echo   into one double-click tool.
echo.
echo   3 tasks: Generate it. Test it. Verify it.
echo.
echo  ──────────────────────────────────────────────────────
echo.

:: --- PRE-FLIGHT ---
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   ✗ Ollama is not running. Start it: ollama serve[0m
    pause
    exit /b 1
)
echo  [92m   ✓ Ollama running[0m

curl -s http://localhost:8080/v1/.well-known/ready >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [93m   ⚠ Weaviate not running. The launcher will detect this too.[0m
) else (
    echo  [92m   ✓ Weaviate running[0m
)
echo.

:: ============================================================
:: TASK 1: Generate the launcher
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/3] Generating my-brain.bat
echo.

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%KNOWLEDGE_DIR%" mkdir "%KNOWLEDGE_DIR%"

:: Create knowledge docs if they don't exist
if not exist "%KNOWLEDGE_DIR%\mission.txt" (
    echo Angel Cloud is a family-driven, faith-rooted AI platform. Our mission is to make AI literacy accessible to every person. We believe you should own your AI, not rent it. Everything runs local. No cloud dependencies. No subscriptions. Built in Alabama for the world.> "%KNOWLEDGE_DIR%\mission.txt"
)
if not exist "%KNOWLEDGE_DIR%\values.txt" (
    echo The Angel Cloud values are: Faith first. Family always. Sobriety as strength. Every person deserves access to AI. Local-first means you own your data. We build for the 800 million Windows users losing security updates. Legacy matters.> "%KNOWLEDGE_DIR%\values.txt"
)
if not exist "%KNOWLEDGE_DIR%\technical.txt" (
    echo The system runs on Ollama with llama3.2:1b for inference and embeddings. Weaviate provides vector storage and semantic search on localhost:8080. The RAG pipeline connects them. Everything fits in 7.4GB RAM. No cloud. No subscriptions.> "%KNOWLEDGE_DIR%\technical.txt"
)

:: Write the launcher
echo    Writing my-brain.bat...

> "%LAUNCHER%" (
echo @echo off
echo setlocal enabledelayedexpansion
echo chcp 65001 ^>nul 2^>^&1
echo title My Brain — Local AI Assistant
echo.
echo :: ============================================================
echo :: MY BRAIN — Personal Local AI Assistant
echo :: Built with: Ollama + Weaviate + RAG Pipeline
echo :: Architecture: Angel Cloud / ShaneBrain Blueprint
echo :: ============================================================
echo.
echo set "BRAIN_DIR=%%~dp0"
echo set "KNOWLEDGE_DIR=%%BRAIN_DIR%%knowledge"
echo set "MODEL=llama3.2:1b"
echo set "OLLAMA_URL=http://localhost:11434"
echo set "WEAVIATE_URL=http://localhost:8080"
echo set "TEMP_DIR=%%TEMP%%\my-brain"
echo set "SCHEMA_CLASS=MyBrain"
echo.
echo if not exist "%%TEMP_DIR%%" mkdir "%%TEMP_DIR%%"
echo.
echo :: ============================================================
echo :: BANNER
echo :: ============================================================
echo cls
echo echo.
echo echo    ╔══════════════════════════════════════════════╗
echo echo    ║                                              ║
echo echo    ║   ███╗   ███╗██╗   ██╗                       ║
echo echo    ║   ████╗ ████║╚██╗ ██╔╝                       ║
echo echo    ║   ██╔████╔██║ ╚████╔╝                        ║
echo echo    ║   ██║╚██╔╝██║  ╚██╔╝                         ║
echo echo    ║   ██║ ╚═╝ ██║   ██║                          ║
echo echo    ║   ╚═╝     ╚═╝   ╚═╝                          ║
echo echo    ║                                              ║
echo echo    ║   ██████╗ ██████╗  █████╗ ██╗███╗   ██╗      ║
echo echo    ║   ██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║      ║
echo echo    ║   ██████╔╝██████╔╝███████║██║██╔██╗ ██║      ║
echo echo    ║   ██╔══██╗██╔══██╗██╔══██║██║██║╚██╗██║      ║
echo echo    ║   ██████╔╝██║  ██║██║  ██║██║██║ ╚████║      ║
echo echo    ║   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝      ║
echo echo    ║                                              ║
echo echo    ║   Your legacy runs local.                    ║
echo echo    ║                                              ║
echo echo    ╚══════════════════════════════════════════════╝
echo echo.
echo.
echo :: ============================================================
echo :: HEALTH CHECKS
echo :: ============================================================
echo echo  [SYSTEM] Running health checks...
echo echo.
echo.
echo :: RAM Check
echo for /f "tokens=2 delims==" %%%%a in ('wmic os get FreePhysicalMemory /value 2^^^^>nul ^^^^^| find "="'^) do set "FREE_KB=%%%%a"
echo set "FREE_KB=%%FREE_KB: =%%"
echo set /a FREE_MB=%%FREE_KB%% / 1024 2^>nul
echo.
echo if %%FREE_MB%% LSS 2048 (
echo     echo  [91m  ✗ BLOCKED: %%FREE_MB%%MB RAM free. Need 2048MB minimum.[0m
echo     pause
echo     exit /b 1
echo ^)
echo if %%FREE_MB%% LSS 4096 (
echo     echo  [93m  ⚠ RAM: %%FREE_MB%%MB free. Performance may be slow.[0m
echo ^) else (
echo     echo  [92m  ✓ RAM: %%FREE_MB%%MB free[0m
echo ^)
echo.
echo :: Ollama Check
echo curl -s %%OLLAMA_URL%%/api/tags ^>nul 2^>^&1
echo if %%errorlevel%% NEQ 0 (
echo     echo  [93m  ⚠ Starting Ollama...[0m
echo     start "" ollama serve ^>nul 2^>^&1
echo     timeout /t 4 /nobreak ^>nul
echo     curl -s %%OLLAMA_URL%%/api/tags ^>nul 2^>^&1
echo     if ^^!errorlevel^^! NEQ 0 (
echo         echo  [91m  ✗ Cannot start Ollama. Run: ollama serve[0m
echo         pause
echo         exit /b 1
echo     ^)
echo ^)
echo echo  [92m  ✓ Ollama running[0m
echo.
echo :: Model Check
echo curl -s %%OLLAMA_URL%%/api/tags 2^>nul ^| findstr /i "%%MODEL%%" ^>nul 2^>^&1
echo if %%errorlevel%% NEQ 0 (
echo     echo  [93m  ⚠ Model %%MODEL%% not found. Pulling...[0m
echo     ollama pull %%MODEL%%
echo ^)
echo echo  [92m  ✓ Model: %%MODEL%%[0m
echo.
echo :: Weaviate Check
echo curl -s %%WEAVIATE_URL%%/v1/.well-known/ready ^>nul 2^>^&1
echo if %%errorlevel%% NEQ 0 (
echo     echo  [91m  ✗ Weaviate not running on %%WEAVIATE_URL%%[0m
echo     echo     Start it and re-run this launcher.
echo     pause
echo     exit /b 1
echo ^)
echo echo  [92m  ✓ Weaviate running[0m
echo echo.
echo.
echo :: ============================================================
echo :: SCHEMA SETUP (idempotent^)
echo :: ============================================================
echo curl -s %%WEAVIATE_URL%%/v1/schema 2^>nul ^| findstr /i "%%SCHEMA_CLASS%%" ^>nul 2^>^&1
echo if %%errorlevel%% NEQ 0 (
echo     echo  [SETUP] Creating knowledge schema...
echo     curl -s -X POST %%WEAVIATE_URL%%/v1/schema -H "Content-Type: application/json" -d "{\"class\":\"%%SCHEMA_CLASS%%\",\"description\":\"Personal brain knowledge base\",\"vectorizer\":\"none\",\"properties\":[{\"name\":\"title\",\"dataType\":[\"text\"]},{\"name\":\"content\",\"dataType\":[\"text\"]},{\"name\":\"source\",\"dataType\":[\"text\"]}]}" ^>nul 2^>^&1
echo     echo  [92m  ✓ Schema created[0m
echo ^) else (
echo     echo  [92m  ✓ Schema exists[0m
echo ^)
echo echo.
echo.
echo :: ============================================================
echo :: SMART INGESTION
echo :: ============================================================
echo echo  [INGEST] Scanning knowledge folder...
echo set "NEW_COUNT=0"
echo set "SKIP_COUNT=0"
echo.
echo for %%%%f in ("%%KNOWLEDGE_DIR%%\*.txt"^) do (
echo     set "FNAME=%%%%~nxf"
echo     :: Check if already ingested by title match
echo     curl -s "%%WEAVIATE_URL%%/v1/objects?class=%%SCHEMA_CLASS%%&limit=100" 2^>nul ^| findstr /i "^^!FNAME^^!" ^>nul 2^>^&1
echo     if ^^!errorlevel^^! EQU 0 (
echo         set /a SKIP_COUNT+=1
echo     ^) else (
echo         echo    Ingesting: ^^!FNAME^^!
echo         set "FCONTENT="
echo         for /f "usebackq delims=" %%%%l in ("%%%%f"^) do (
echo             if defined FCONTENT (set "FCONTENT=^^!FCONTENT^^! %%%%l"^) else (set "FCONTENT=%%%%l"^)
echo         ^)
echo         python -c "import json,urllib.request; content=r'''^^!FCONTENT^^!'''; emb=json.loads(urllib.request.urlopen(urllib.request.Request('%%OLLAMA_URL%%/api/embeddings',data=json.dumps({'model':'%%MODEL%%','prompt':content}).encode(),headers={'Content-Type':'application/json'})).read()).get('embedding',[]); urllib.request.urlopen(urllib.request.Request('%%WEAVIATE_URL%%/v1/objects',data=json.dumps({'class':'%%SCHEMA_CLASS%%','properties':{'title':'^^!FNAME^^!','content':content,'source':r'%%%%f'},'vector':emb}).encode(),headers={'Content-Type':'application/json'}))" 2^>nul
echo         set /a NEW_COUNT+=1
echo     ^)
echo ^)
echo echo  [92m  ✓ Ingestion: %%NEW_COUNT%% new, %%SKIP_COUNT%% already loaded[0m
echo echo.
echo.
echo :: ============================================================
echo :: INTERACTIVE CHAT
echo :: ============================================================
echo echo  ══════════════════════════════════════════════════
echo echo   MY BRAIN — Ready
echo echo   Ask anything. Type /bye to exit.
echo echo  ══════════════════════════════════════════════════
echo echo.
echo.
echo :chat_loop
echo set "USER_Q="
echo set /p "USER_Q=  YOU ^>^> "
echo.
echo if /i "%%USER_Q%%"=="/bye" goto shutdown
echo if "%%USER_Q%%"=="" goto chat_loop
echo.
echo python -c "import json,urllib.request; q=r'''%%USER_Q%%'''; emb=json.loads(urllib.request.urlopen(urllib.request.Request('%%OLLAMA_URL%%/api/embeddings',data=json.dumps({'model':'%%MODEL%%','prompt':q}).encode(),headers={'Content-Type':'application/json'})).read()).get('embedding',[]); docs=json.loads(urllib.request.urlopen(urllib.request.Request('%%WEAVIATE_URL%%/v1/graphql',data=json.dumps({'query':'{Get{%%SCHEMA_CLASS%%(nearVector:{vector:'+json.dumps(emb)+'},limit:2){title content}}}' }).encode(),headers={'Content-Type':'application/json'})).read()).get('data',{}).get('Get',{}).get('%%SCHEMA_CLASS%%',[]); ctx='\n'.join([d.get('content','') for d in docs]); prompt='You are My Brain, a personal local AI assistant. Answer using ONLY the context below. If the context does not contain the answer, say: I don\'t have that information in my knowledge base.\n\nCONTEXT:\n'+ctx+'\n\nQUESTION:\n'+q+'\n\nANSWER:'; resp=json.loads(urllib.request.urlopen(urllib.request.Request('%%OLLAMA_URL%%/api/generate',data=json.dumps({'model':'%%MODEL%%','prompt':prompt,'stream':False,'options':{'temperature':0.2}}).encode(),headers={'Content-Type':'application/json'})).read()); print('\n  BRAIN ^>^> '+resp.get('response','No response.').strip()+'\n')" 2^>nul
echo.
echo goto chat_loop
echo.
echo :shutdown
echo echo.
echo echo   Your legacy runs local. See you next time.
echo echo.
echo if exist "%%TEMP_DIR%%" rd /s /q "%%TEMP_DIR%%" 2^>nul
echo endlocal
echo exit /b 0
)

echo  [92m   ✓ my-brain.bat generated: %LAUNCHER%[0m
echo.
echo   The launcher is ready. It includes:
echo     • ASCII banner
echo     • RAM / Ollama / Weaviate health checks
echo     • Auto model pull if missing
echo     • Idempotent schema creation
echo     • Smart ingestion (skips duplicates)
echo     • Interactive RAG chat with guardrails
echo.
echo   Press any key to test it...
pause >nul
echo.

:: ============================================================
:: TASK 2: Test the launcher
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/3] Test my-brain.bat
echo.
echo   The launcher is about to run. It will:
echo   1. Show the banner
echo   2. Run health checks
echo   3. Set up schema
echo   4. Ingest knowledge documents
echo   5. Open an interactive chat
echo.
echo   Ask it a question like: "What are the Angel Cloud values?"
echo   Then type /bye to exit back to this exercise.
echo.
echo   Press any key to launch...
pause >nul
echo.

call "%LAUNCHER%"

echo.
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/3] Verify your launcher
echo.
echo   If the chat worked and gave you an answer from your
echo   knowledge documents, your launcher is production-ready.
echo.
echo   Run verify.bat for the final automated check:
echo.
echo       verify.bat
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.

pause
endlocal
exit /b 0
