@echo off
setlocal enabledelayedexpansion
title Module 2.7 Exercise — Your Operator Dashboard

:: ============================================================
:: MODULE 2.7 EXERCISE: Your Operator Dashboard
:: Goal: Generate a single-launcher dashboard that provides
::       access to all Phase 2 tools with health and stats
:: Time: ~15 minutes
:: RAM impact: ~200MB for dashboard itself (tools add their own)
:: Prerequisites: Modules 2.1-2.6 (all Phase 2)
:: ============================================================

set "MOD_DIR=%~dp0"
set "PHASE_DIR=%MOD_DIR%.."
set "OUTPUT_DIR=%MOD_DIR%output"
set "TEMP_DIR=%TEMP%\module-2.7"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.7 EXERCISE: Your Operator Dashboard
echo  ══════════════════════════════════════════════════════
echo.
echo   Package all Phase 2 tools into one dashboard.
echo   Two tasks.
echo.
echo  ──────────────────────────────────────────────────────
echo.

:: --- PRE-FLIGHT ---
echo  [PRE-FLIGHT] Checking services and all prerequisites...
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

:: Check all classes
set "ALL_OK=1"
for %%c in (BusinessDoc DraftTemplate MessageLog DocTemplate WorkflowLog) do (
    curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "%%c" >nul 2>&1
    if !errorlevel! NEQ 0 (
        echo  [91m   ✗ %%c not found. Complete its module first.[0m
        set "ALL_OK=0"
    ) else (
        echo  [92m   ✓ %%c exists[0m
    )
)
if "%ALL_OK%"=="0" (
    echo.
    echo  [91m   Complete Modules 2.1-2.6 before this capstone.[0m
    pause
    exit /b 1
)
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: ============================================================
:: TASK 1: Generate the Operator Dashboard
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/2] Generate the Operator Dashboard
echo.
echo   Building operator-dashboard.bat — your daily command center.
echo.

> "%OUTPUT_DIR%\operator-dashboard.bat" (
echo @echo off
echo setlocal enabledelayedexpansion
echo chcp 65001 ^>nul 2^>^&1
echo title Operator Dashboard — Business AI Toolkit
echo.
echo set "BASE_DIR=%%~dp0"
echo set "TEMP_DIR=%%TEMP%%\operator-dashboard"
echo if not exist "%%TEMP_DIR%%" mkdir "%%TEMP_DIR%%"
echo.
echo :: ════════════════════════════════════════════════════
echo :: BANNER
echo :: ════════════════════════════════════════════════════
echo :dashboard
echo cls
echo echo.
echo echo    ╔══════════════════════════════════════════════════╗
echo echo    ║                                                  ║
echo echo    ║       OPERATOR DASHBOARD                        ║
echo echo    ║       Business AI Toolkit                       ║
echo echo    ║                                                  ║
echo echo    ║       Local AI. Your data. Your tools.          ║
echo echo    ║                                                  ║
echo echo    ╚══════════════════════════════════════════════════╝
echo echo.
echo.
echo :: ════════════════════════════════════════════════════
echo :: HEALTH CHECK
echo :: ════════════════════════════════════════════════════
echo echo   [SYSTEM STATUS]
echo echo.
echo.
echo :: RAM check
echo for /f "tokens=2 delims==" %%%%a in ('wmic os get FreePhysicalMemory /value 2^^^^>nul ^^^^^| find "="'^) do set "FREE_KB=%%%%a"
echo set "FREE_KB=%%FREE_KB: =%%"
echo set /a FREE_MB=%%FREE_KB%% / 1024 2^>nul
echo if %%FREE_MB%% LSS 2048 (
echo     echo  [91m   ✗ RAM: %%FREE_MB%%MB free — LOW. Close apps.[0m
echo ^) else (
echo     echo  [92m   ✓ RAM: %%FREE_MB%%MB free[0m
echo ^)
echo.
echo :: Ollama check
echo curl -s http://localhost:11434/api/tags ^>nul 2^>^&1
echo if %%errorlevel%% NEQ 0 (
echo     echo  [91m   ✗ Ollama: Not running[0m
echo     echo     Start with: ollama serve
echo ^) else (
echo     echo  [92m   ✓ Ollama: Running[0m
echo ^)
echo.
echo :: Weaviate check
echo curl -s http://localhost:8080/v1/.well-known/ready ^>nul 2^>^&1
echo if %%errorlevel%% NEQ 0 (
echo     echo  [91m   ✗ Weaviate: Not running[0m
echo     echo     Start with: docker start weaviate
echo ^) else (
echo     echo  [92m   ✓ Weaviate: Running[0m
echo ^)
echo echo.
echo.
echo :: ════════════════════════════════════════════════════
echo :: KNOWLEDGE BASE STATS
echo :: ════════════════════════════════════════════════════
echo echo   [KNOWLEDGE BASE]
echo echo.
echo python -c "import json,urllib.request; classes=['BusinessDoc','DraftTemplate','MessageLog','DocTemplate','WorkflowLog']; labels=['Business Docs','Draft Templates','Messages Triaged','Doc Templates','Workflows Logged'];" ^
" " ^
"for cls,lbl in zip(classes,labels):" ^
"    try:" ^
"        req=urllib.request.Request('http://localhost:8080/v1/graphql',data=json.dumps({'query':'{Aggregate{'+cls+'{meta{count}}}}'}).encode(),headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); count=resp.get('data',{}).get('Aggregate',{}).get(cls,[{}])[0].get('meta',{}).get('count',0); print(f'     {lbl}: {count}')" ^
"    except: print(f'     {lbl}: unavailable')" 2^>nul
echo echo.
echo.
echo :: ════════════════════════════════════════════════════
echo :: TOOL MENU
echo :: ════════════════════════════════════════════════════
echo echo   [TOOLS]
echo echo   ─────────────────────────────────────
echo echo     1.  Answer Desk        (Q^&A with citations^)
echo echo     2.  Draft It           (Message drafting^)
echo echo     3.  Sort and Route     (Message triage^)
echo echo     4.  Paperwork Machine  (Document generator^)
echo echo     5.  Chain Reactions    (Workflow automation^)
echo echo.
echo echo   ─────────────────────────────────────
echo echo     H.  Full Health Check
echo echo     Q.  Quit
echo echo.
echo set /p "CHOICE=  Select tool (1-5^) or option: "
echo.
echo if "%%CHOICE%%"=="1" goto tool_answer
echo if "%%CHOICE%%"=="2" goto tool_draft
echo if "%%CHOICE%%"=="3" goto tool_sort
echo if "%%CHOICE%%"=="4" goto tool_paper
echo if "%%CHOICE%%"=="5" goto tool_chain
echo if /i "%%CHOICE%%"=="H" goto full_health
echo if /i "%%CHOICE%%"=="Q" goto dash_quit
echo echo  [91m   Invalid selection.[0m
echo timeout /t 2 /nobreak ^>nul
echo goto dashboard
echo.
echo :: ════════════════════════════════════════════════════
echo :: TOOL LAUNCHERS — Inline implementations
echo :: ════════════════════════════════════════════════════
echo.
echo :tool_answer
echo cls
echo echo.
echo echo  ══════════════════════════════════════════════════
echo echo   ANSWER DESK — Business Q^&A
echo echo  ══════════════════════════════════════════════════
echo echo.
echo :ans_loop
echo set /p "AQ=  Question (B to go back^): "
echo if /i "%%AQ%%"=="B" goto dashboard
echo if "%%AQ%%"=="" goto ans_loop
echo python -c "import json,urllib.request; q=r'''%%AQ%%'''; emb=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/embeddings',json.dumps({'model':'llama3.2:1b','prompt':q}).encode(),{'Content-Type':'application/json'})).read()).get('embedding',[]); docs=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:8080/v1/graphql',json.dumps({'query':'{Get{BusinessDoc(nearVector:{vector:'+json.dumps(emb)+'},limit:2){title content category}}}'}).encode(),{'Content-Type':'application/json'})).read()).get('data',{}).get('Get',{}).get('BusinessDoc',[]); ctx=chr(10).join(['['+d['title']+'] '+d['content'] for d in docs]); ans=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/generate',json.dumps({'model':'llama3.2:1b','prompt':'Answer from docs only. Cite sources.'+chr(10)+ctx+chr(10)+'Q: '+q+chr(10)+'A:','stream':False}).encode(),{'Content-Type':'application/json'})).read()).get('response',''); print(ans); print(chr(10)+'Sources: '+', '.join([d['title']+'['+d['category']+']' for d in docs]))" 2^>nul
echo echo.
echo goto ans_loop
echo.
echo :tool_draft
echo cls
echo echo.
echo echo  ══════════════════════════════════════════════════
echo echo   DRAFT IT — Message Drafter
echo echo  ══════════════════════════════════════════════════
echo echo.
echo :dft_loop
echo set /p "DR=  What to write? (B to go back^): "
echo if /i "%%DR%%"=="B" goto dashboard
echo if "%%DR%%"=="" goto dft_loop
echo set "DT=professional"
echo set /p "DT=  Tone (professional/friendly/firm^) [professional]: "
echo if "%%DT%%"=="" set "DT=professional"
echo python -c "import json,urllib.request; r=r'''%%DR%%'''; t='%%DT%%'; emb=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/embeddings',json.dumps({'model':'llama3.2:1b','prompt':r}).encode(),{'Content-Type':'application/json'})).read()).get('embedding',[]); tmpl=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:8080/v1/graphql',json.dumps({'query':'{Get{DraftTemplate(nearVector:{vector:'+json.dumps(emb)+'},limit:1){title content}}}'}).encode(),{'Content-Type':'application/json'})).read()).get('data',{}).get('Get',{}).get('DraftTemplate',[{}])[0]; biz=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:8080/v1/graphql',json.dumps({'query':'{Get{BusinessDoc(nearVector:{vector:'+json.dumps(emb)+'},limit:2){content}}}'}).encode(),{'Content-Type':'application/json'})).read()).get('data',{}).get('Get',{}).get('BusinessDoc',[]); ctx=chr(10).join([d['content'] for d in biz]); ans=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/generate',json.dumps({'model':'llama3.2:1b','prompt':'Write a '+t+' message for: '+r+chr(10)+'Style: '+tmpl.get('content','')+chr(10)+'Facts: '+ctx,'stream':False}).encode(),{'Content-Type':'application/json'})).read()).get('response',''); print(ans)" 2^>nul
echo echo.
echo goto dft_loop
echo.
echo :tool_sort
echo cls
echo echo.
echo echo  ══════════════════════════════════════════════════
echo echo   SORT AND ROUTE — Message Triage
echo echo  ══════════════════════════════════════════════════
echo echo.
echo :srt_loop
echo set /p "SM=  Message to classify (B to go back^): "
echo if /i "%%SM%%"=="B" goto dashboard
echo if "%%SM%%"=="" goto srt_loop
echo python -c "import json,urllib.request,datetime; m=r'''%%SM%%'''; ans=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/generate',json.dumps({'model':'llama3.2:1b','prompt':'Classify: CATEGORY (quote_request/complaint/scheduling/payment/general), PRIORITY (HIGH/MEDIUM/LOW), ACTION (next step). Three lines only.'+chr(10)+m,'stream':False}).encode(),{'Content-Type':'application/json'})).read()).get('response',''); print(ans); emb=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/embeddings',json.dumps({'model':'llama3.2:1b','prompt':m}).encode(),{'Content-Type':'application/json'})).read()).get('embedding',[]); urllib.request.urlopen(urllib.request.Request('http://localhost:8080/v1/objects',json.dumps({'class':'MessageLog','properties':{'content':m,'category':'classified','priority':'see above','suggestedAction':'see above','timestamp':datetime.datetime.now().strftime('%%Y-%%m-%%d %%H:%%M:%%S')},'vector':emb}).encode(),{'Content-Type':'application/json'}))" 2^>nul
echo echo.
echo goto srt_loop
echo.
echo :tool_paper
echo cls
echo echo.
echo echo  ══════════════════════════════════════════════════
echo echo   PAPERWORK MACHINE — Document Generator
echo echo  ══════════════════════════════════════════════════
echo echo.
echo echo   Types: estimate, report, checklist, letter
echo echo.
echo :ppr_loop
echo set /p "PD=  Describe the document (B to go back^): "
echo if /i "%%PD%%"=="B" goto dashboard
echo if "%%PD%%"=="" goto ppr_loop
echo python -c "import json,urllib.request,datetime; r=r'''%%PD%%'''; emb=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/embeddings',json.dumps({'model':'llama3.2:1b','prompt':r}).encode(),{'Content-Type':'application/json'})).read()).get('embedding',[]); tmpl=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:8080/v1/graphql',json.dumps({'query':'{Get{DocTemplate(nearVector:{vector:'+json.dumps(emb)+'},limit:1){title content docType}}}'}).encode(),{'Content-Type':'application/json'})).read()).get('data',{}).get('Get',{}).get('DocTemplate',[{}])[0]; biz=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:8080/v1/graphql',json.dumps({'query':'{Get{BusinessDoc(nearVector:{vector:'+json.dumps(emb)+'},limit:2){content}}}'}).encode(),{'Content-Type':'application/json'})).read()).get('data',{}).get('Get',{}).get('BusinessDoc',[]); ctx=chr(10).join([d['content'] for d in biz]); doc=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/generate',json.dumps({'model':'llama3.2:1b','prompt':'Generate document for: '+r+chr(10)+'Template: '+tmpl.get('content','')+chr(10)+'Business data: '+ctx+chr(10)+'Fill all placeholders.','stream':False}).encode(),{'Content-Type':'application/json'})).read()).get('response',''); print(doc); print(chr(10)+'Template: '+tmpl.get('title',''))" 2^>nul
echo echo.
echo goto ppr_loop
echo.
echo :tool_chain
echo cls
echo echo.
echo echo  ══════════════════════════════════════════════════
echo echo   CHAIN REACTIONS — Workflow Automation
echo echo  ══════════════════════════════════════════════════
echo echo.
echo echo   1. Complaint Response  2. New Lead  3. Job Complete
echo echo.
echo :chn_loop
echo set /p "CW=  Workflow (1/2/3, B to go back^): "
echo if /i "%%CW%%"=="B" goto dashboard
echo if "%%CW%%"=="" goto chn_loop
echo set /p "CI=  Message or description: "
echo if "%%CI%%"=="" goto chn_loop
echo python -c "import json,urllib.request,datetime; wf='%%CW%%'; inp=r'''%%CI%%'''; emb=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/embeddings',json.dumps({'model':'llama3.2:1b','prompt':inp}).encode(),{'Content-Type':'application/json'})).read()).get('embedding',[]); biz=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:8080/v1/graphql',json.dumps({'query':'{Get{BusinessDoc(nearVector:{vector:'+json.dumps(emb)+'},limit:2){content}}}'}).encode(),{'Content-Type':'application/json'})).read()).get('data',{}).get('Get',{}).get('BusinessDoc',[]); ctx=chr(10).join([d['content'] for d in biz]); ps={'1':'Complaint: '+inp+chr(10)+'1.Classify 2.Find policy from: '+ctx+chr(10)+'3.Draft response. Label steps.','2':'Lead: '+inp+chr(10)+'1.Classify 2.Pricing from: '+ctx+chr(10)+'3.Welcome msg 4.Estimate. Label steps.','3':'Job done: '+inp+chr(10)+'1.Report 2.Follow-up using: '+ctx+chr(10)+'Label steps.'}; out=json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/generate',json.dumps({'model':'llama3.2:1b','prompt':ps.get(wf,ps['1']),'stream':False}).encode(),{'Content-Type':'application/json'})).read()).get('response',''); print(out); wn={'1':'complaint-response','2':'new-lead','3':'job-complete'}; ts=datetime.datetime.now().strftime('%%%%Y-%%%%m-%%%%d %%%%H:%%%%M:%%%%S'); urllib.request.urlopen(urllib.request.Request('http://localhost:8080/v1/objects',json.dumps({'class':'WorkflowLog','properties':{'workflowName':wn.get(wf,'custom'),'input':inp,'steps':'chain','finalOutput':out[:500],'timestamp':ts},'vector':emb}).encode(),{'Content-Type':'application/json'})); print(chr(10)+'Logged: '+wn.get(wf,'custom'))" 2^>nul
echo echo.
echo goto chn_loop
echo.
echo :full_health
echo cls
echo echo.
echo echo  ══════════════════════════════════════════════════
echo echo   FULL HEALTH CHECK
echo echo  ══════════════════════════════════════════════════
echo echo.
echo for /f "tokens=2 delims==" %%%%a in ('wmic os get FreePhysicalMemory /value 2^^^^>nul ^^^^^| find "="'^) do set "FK=%%%%a"
echo set "FK=%%FK: =%%"
echo set /a FM=%%FK%% / 1024 2^>nul
echo echo   RAM Free: %%FM%%MB
echo curl -s http://localhost:11434/api/tags ^>nul 2^>^&1 ^&^& (echo   Ollama: [92mRunning[0m^) ^|^| (echo   Ollama: [91mDown[0m^)
echo curl -s http://localhost:8080/v1/.well-known/ready ^>nul 2^>^&1 ^&^& (echo   Weaviate: [92mRunning[0m^) ^|^| (echo   Weaviate: [91mDown[0m^)
echo curl -s http://localhost:11434/api/tags 2^>nul ^| findstr /i "llama3.2:1b" ^>nul 2^>^&1 ^&^& (echo   Model: [92mllama3.2:1b loaded[0m^) ^|^| (echo   Model: [91mllama3.2:1b not found[0m^)
echo echo.
echo echo   Weaviate Classes:
echo for %%%%c in (BusinessDoc DraftTemplate MessageLog DocTemplate WorkflowLog^) do (
echo     curl -s http://localhost:8080/v1/schema 2^>nul ^| findstr /i "%%%%c" ^>nul 2^>^&1 ^&^& (echo     [92m✓[0m %%%%c^) ^|^| (echo     [91m✗[0m %%%%c^)
echo ^)
echo echo.
echo pause
echo goto dashboard
echo.
echo :dash_quit
echo echo.
echo echo   ╔══════════════════════════════════════════════════╗
echo echo   ║   Keep operating. Your business runs smarter    ║
echo echo   ║   because your AI runs local.                   ║
echo echo   ╚══════════════════════════════════════════════════╝
echo echo.
echo if exist "%%TEMP_DIR%%" rd /s /q "%%TEMP_DIR%%" 2^>nul
echo endlocal
echo exit /b 0
)

if exist "%OUTPUT_DIR%\operator-dashboard.bat" (
    echo  [92m   ✓ operator-dashboard.bat created[0m
) else (
    echo  [91m   ✗ Failed to create operator-dashboard.bat[0m
    pause
    exit /b 1
)

echo.
echo   Your Operator Dashboard is built. This is your daily
echo   command center — every Phase 2 tool in one place.
echo.
echo   Press any key to test it...
pause >nul
echo.

:: ============================================================
:: TASK 2: Launch and test the dashboard
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/2] Test your Operator Dashboard
echo.
echo   The dashboard will launch now. Test each tool:
echo     1 — Ask "What are our rates?"
echo     2 — Draft a friendly pricing reply
echo     3 — Classify "I need a quote for a kitchen remodel"
echo     4 — Generate "estimate for plumbing repair"
echo     5 — Run a complaint chain
echo     H — Check full system health
echo     Q — Quit back to exercise
echo.
echo   Press any key to launch the dashboard...
pause >nul

call "%OUTPUT_DIR%\operator-dashboard.bat"

echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   Your Operator Dashboard lives at:
echo     %OUTPUT_DIR%\operator-dashboard.bat
echo.
echo   Copy it to your desktop for daily use.
echo   Now run verify.bat to complete Phase 2.
echo.

if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
