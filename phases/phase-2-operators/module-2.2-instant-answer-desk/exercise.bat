@echo off
setlocal enabledelayedexpansion
title Module 2.2 Exercise — The Instant Answer Desk

:: ============================================================
:: MODULE 2.2 EXERCISE: The Instant Answer Desk
:: Goal: Build an interactive Q&A tool with source citations
::       and confidence scoring using BusinessDoc collection
:: Time: ~15 minutes
:: RAM impact: ~300MB beyond Ollama + Weaviate baseline
:: Prerequisite: Module 2.1 (BusinessDoc class with documents)
:: ============================================================

set "MOD_DIR=%~dp0"
set "OUTPUT_DIR=%MOD_DIR%output"
set "TEMP_DIR=%TEMP%\module-2.2"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.2 EXERCISE: The Instant Answer Desk
echo  ══════════════════════════════════════════════════════
echo.
echo   Build a Q&A tool with source citations. Two tasks.
echo.
echo  ──────────────────────────────────────────────────────
echo.

:: --- PRE-FLIGHT ---
echo  [PRE-FLIGHT] Checking services and prerequisites...
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

:: Check BusinessDoc exists (prerequisite from 2.1)
curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "BusinessDoc" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   ✗ BusinessDoc class not found. Complete Module 2.1 first.[0m
    pause
    exit /b 1
)
echo  [92m   ✓ BusinessDoc class exists (Module 2.1 complete)[0m
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: ============================================================
:: TASK 1: Generate the Answer Desk tool
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/2] Generate the Answer Desk launcher
echo.
echo   Creating answer-desk.bat — your business Q&A tool...
echo.

:: Write the answer-desk.bat tool
> "%OUTPUT_DIR%\answer-desk.bat" (
echo @echo off
echo setlocal enabledelayedexpansion
echo title Answer Desk — Business Q^&A
echo.
echo set "TEMP_DIR=%%TEMP%%\answer-desk"
echo if not exist "%%TEMP_DIR%%" mkdir "%%TEMP_DIR%%"
echo.
echo echo.
echo echo  ══════════════════════════════════════════════════════
echo echo   THE INSTANT ANSWER DESK
echo echo   Ask anything about your business. Get cited answers.
echo echo  ══════════════════════════════════════════════════════
echo echo.
echo.
echo :: Health checks
echo curl -s http://localhost:11434/api/tags ^>nul 2^>^&1
echo if %%errorlevel%% NEQ 0 (
echo     echo  [91m   Ollama not running. Start it: ollama serve[0m
echo     pause
echo     exit /b 1
echo ^)
echo curl -s http://localhost:8080/v1/.well-known/ready ^>nul 2^>^&1
echo if %%errorlevel%% NEQ 0 (
echo     echo  [91m   Weaviate not running. Start Docker.[0m
echo     pause
echo     exit /b 1
echo ^)
echo echo  [92m   Systems online. Ready for questions.[0m
echo echo.
echo.
echo :ask_loop
echo echo  ──────────────────────────────────────────────────────
echo set /p "Q=  Question (Q to quit^): "
echo if /i "%%Q%%"=="Q" goto desk_done
echo if "%%Q%%"=="" goto ask_loop
echo echo.
echo.
echo :: Search and answer with citations
echo python -c "import json,urllib.request,sys; q=r'''%%Q%%'''; emb_data=json.dumps({'model':'llama3.2:1b','prompt':q}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); query='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:3){title content category _additional{distance}}}}'; gql_data=json.dumps({'query':query}).encode(); gql_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=gql_data,headers={'Content-Type':'application/json'}); gql_resp=json.loads(urllib.request.urlopen(gql_req).read()); docs=gql_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[]); ctx_parts=[]; src_parts=[]; conf='HIGH';" ^
"for i,d in enumerate(docs):" ^
"    dist=float(d.get('_additional',{}).get('distance',1.0));" ^
"    ctx_parts.append('[Document '+str(i+1)+': '+d.get('title','')+' ('+d.get('category','')+')]\\n'+d.get('content',''));" ^
"    src_parts.append(d.get('title','')+'['+d.get('category','')+'] dist='+str(round(dist,3)));" ^
"    if dist>0.8: conf='LOW';" ^
"    elif dist>0.5 and conf!='LOW': conf='MODERATE';" ^
"ctx='\\n\\n'.join(ctx_parts); prompt='You are a business assistant. Answer using ONLY the documents below. Cite which document(s) you used. If the answer is not in the documents, say: I do not have that information.\\n\\n'+ctx+'\\n\\nQUESTION: '+q+'\\nANSWER:'; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); ans=resp.get('response','No response.'); print(ans); print(); print('   --- Sources ---'); [print('   '+s) for s in src_parts]; print('   Confidence: '+conf)" 2^>nul
echo.
echo echo.
echo goto ask_loop
echo.
echo :desk_done
echo echo.
echo echo   Answer Desk closed. Keep your docs updated.
echo if exist "%%TEMP_DIR%%" rd /s /q "%%TEMP_DIR%%" 2^>nul
echo endlocal
echo exit /b 0
)

if exist "%OUTPUT_DIR%\answer-desk.bat" (
    echo  [92m   ✓ answer-desk.bat created in output folder[0m
) else (
    echo  [91m   ✗ Failed to create answer-desk.bat[0m
    pause
    exit /b 1
)

echo.
echo   The Answer Desk is a standalone tool you can use daily.
echo   Double-click answer-desk.bat anytime you need quick answers.
echo.
echo   Press any key to test it now...
pause >nul
echo.

:: ============================================================
:: TASK 2: Test the Answer Desk
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/2] Test your Answer Desk
echo.
echo   Try these questions to test source citations:
echo     - "What do we charge per hour?"
echo     - "What's the cancellation policy?"
echo     - "Do we work weekends?"
echo     - "How do we handle a new job?"
echo.
echo   Notice: Each answer shows source documents and confidence.
echo   Type Q when done testing.
echo.

:: Run the Answer Desk directly (inline version for testing)
:test_loop
echo  ──────────────────────────────────────────────────────
set /p "USER_Q=  Question (Q to quit): "

if /i "%USER_Q%"=="Q" goto exercise_done
if "%USER_Q%"=="" goto test_loop

echo.
echo   Searching business documents...

python -c "import json,urllib.request; q=r'''%USER_Q%'''; emb_data=json.dumps({'model':'llama3.2:1b','prompt':q}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); query='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:3){title content category _additional{distance}}}}'; gql_data=json.dumps({'query':query}).encode(); gql_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=gql_data,headers={'Content-Type':'application/json'}); gql_resp=json.loads(urllib.request.urlopen(gql_req).read()); docs=gql_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[]); ctx_parts=[]; src_parts=[]; conf='HIGH'; [( ctx_parts.append('[Doc '+str(i+1)+': '+d.get('title','')+' ('+d.get('category','')+')]\n'+d.get('content','')), src_parts.append(d.get('title','')+'['+d.get('category','')+'] dist='+str(round(float(d.get('_additional',{}).get('distance',1.0)),3))) ) for i,d in enumerate(docs)]; [exec('') for d in docs if float(d.get('_additional',{}).get('distance',1.0))>0.8]; ctx='\n\n'.join(ctx_parts); prompt='You are a business assistant. Answer using ONLY the documents below. Cite which document you used. If the answer is not in the documents, say so.\n\n'+ctx+'\n\nQUESTION: '+q+'\nANSWER:'; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); print(resp.get('response','No response.')); print(); print('   --- Sources ---'); [print('   '+s) for s in src_parts]" 2>nul

echo.
goto test_loop

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   Your Answer Desk is built and tested. It lives at:
echo     %OUTPUT_DIR%\answer-desk.bat
echo.
echo   Use it daily. Add more docs to your business-docs
echo   folder in Module 2.1 to make it smarter.
echo.
echo   Now run verify.bat to confirm everything passed.
echo.

:: Cleanup temp files
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
