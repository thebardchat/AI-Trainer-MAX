@echo off
setlocal enabledelayedexpansion
title Module 2.4 Exercise — Sort and Route

:: ============================================================
:: MODULE 2.4 EXERCISE: Sort and Route
:: Goal: Create MessageLog schema, classify sample messages,
::       build interactive triage tool
:: Time: ~15 minutes
:: RAM impact: ~300MB beyond Ollama + Weaviate baseline
:: Prerequisite: Module 2.1 (BusinessDoc)
:: ============================================================

set "MOD_DIR=%~dp0"
set "OUTPUT_DIR=%MOD_DIR%output"
set "TEMP_DIR=%TEMP%\module-2.4"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.4 EXERCISE: Sort and Route
echo  ══════════════════════════════════════════════════════
echo.
echo   Build a message triage tool. Classify, prioritize,
echo   and route messages automatically. Three tasks.
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

curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "BusinessDoc" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   ✗ BusinessDoc not found. Complete Module 2.1 first.[0m
    pause
    exit /b 1
)
echo  [92m   ✓ BusinessDoc exists (Module 2.1 complete)[0m
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: ============================================================
:: TASK 1: Create MessageLog schema
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/3] Create MessageLog schema
echo.

curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "MessageLog" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo   Creating "MessageLog" class...
    curl -s -X POST http://localhost:8080/v1/schema -H "Content-Type: application/json" -d "{\"class\":\"MessageLog\",\"description\":\"Classified business messages\",\"vectorizer\":\"none\",\"properties\":[{\"name\":\"content\",\"dataType\":[\"text\"],\"description\":\"Original message text\"},{\"name\":\"category\",\"dataType\":[\"text\"],\"description\":\"Category: quote_request, complaint, scheduling, payment, general\"},{\"name\":\"priority\",\"dataType\":[\"text\"],\"description\":\"Priority: HIGH, MEDIUM, LOW\"},{\"name\":\"suggestedAction\",\"dataType\":[\"text\"],\"description\":\"Recommended next step\"},{\"name\":\"timestamp\",\"dataType\":[\"text\"],\"description\":\"Classification timestamp\"}]}" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [92m   ✓ "MessageLog" class created[0m
    ) else (
        echo  [91m   ✗ Failed to create MessageLog schema[0m
        pause
        exit /b 1
    )
) else (
    echo  [92m   ✓ "MessageLog" class already exists[0m
)
echo.
echo   Press any key to classify sample messages...
pause >nul
echo.

:: ============================================================
:: TASK 2: Classify sample messages
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/3] Classify sample messages
echo.
echo   Feeding 5 sample messages through the triage pipeline.
echo   Watch the AI classify, prioritize, and suggest actions.
echo.

:: Sample messages to classify
set "MSG1=Hi, I need a quote for replacing the HVAC unit in my office. It is about 2000 square feet. When can someone come look at it?"
set "MSG2=I am very unhappy with the work done last Tuesday. The technician left a mess and the problem is not fixed. I want this resolved immediately."
set "MSG3=Can we reschedule our Thursday appointment to next Monday morning? Something came up at work."
set "MSG4=I sent a check two weeks ago but have not received a receipt. Can you confirm you received payment for invoice 1045?"
set "MSG5=Just wanted to say thanks for the great work yesterday. Your team was professional and finished ahead of schedule."

set "MSG_NUM=0"
for %%m in ("!MSG1!" "!MSG2!" "!MSG3!" "!MSG4!" "!MSG5!") do (
    set /a MSG_NUM+=1
    echo   ── Message !MSG_NUM!/5 ──────────────────────────────
    echo   %%~m
    echo.
    echo   Classifying...

    python -c "import json,urllib.request,datetime; msg=r'''%%~m'''; prompt='Classify this business message. Respond with EXACTLY three lines, nothing else:\nCATEGORY: (one of: quote_request, complaint, scheduling, payment, general)\nPRIORITY: (one of: HIGH, MEDIUM, LOW)\nACTION: (one specific action to take)\n\nMessage: '+msg; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); answer=resp.get('response',''); lines=answer.strip().split('\n'); cat='general'; pri='MEDIUM'; act='Review manually'; [exec('') for l in lines]; parts={l.split(':',1)[0].strip().upper():l.split(':',1)[1].strip() for l in lines if ':' in l}; cat=parts.get('CATEGORY',cat).lower().strip(); pri=parts.get('PRIORITY',pri).upper().strip(); act=parts.get('ACTION',act).strip(); ts=datetime.datetime.now().strftime('%%Y-%%m-%%d %%H:%%M:%%S'); print('CATEGORY: '+cat); print('PRIORITY: '+pri); print('ACTION: '+act); emb_data=json.dumps({'model':'llama3.2:1b','prompt':msg}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); payload={'class':'MessageLog','properties':{'content':msg,'category':cat,'priority':pri,'suggestedAction':act,'timestamp':ts},'vector':vec}; store_data=json.dumps(payload).encode(); store_req=urllib.request.Request('http://localhost:8080/v1/objects',data=store_data,headers={'Content-Type':'application/json'}); urllib.request.urlopen(store_req); print('LOGGED: Yes')" 2>nul

    echo.
)

echo  [92m   ✓ 5 messages classified and logged to MessageLog[0m
echo.
echo   Press any key to build the interactive triage tool...
pause >nul
echo.

:: ============================================================
:: TASK 3: Generate Sort and Route tool and test it
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/3] Build and test the Sort and Route tool
echo.

:: Generate the tool
> "%OUTPUT_DIR%\sort-and-route.bat" (
echo @echo off
echo setlocal enabledelayedexpansion
echo title Sort and Route — Message Triage
echo.
echo echo.
echo echo  ══════════════════════════════════════════════════════
echo echo   SORT AND ROUTE — Message Triage
echo echo   Paste a message. Get category, priority, and action.
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
echo echo  [92m   Systems online. Paste messages to classify.[0m
echo echo.
echo.
echo :triage_loop
echo echo  ──────────────────────────────────────────────────────
echo set /p "MSG=  Message to classify (Q to quit^): "
echo if /i "%%MSG%%"=="Q" goto triage_done
echo if "%%MSG%%"=="" goto triage_loop
echo echo.
echo echo   Classifying...
echo.
echo python -c "import json,urllib.request,datetime; msg=r'''%%MSG%%'''; prompt='Classify this business message. Respond with EXACTLY three lines:\nCATEGORY: (quote_request, complaint, scheduling, payment, or general)\nPRIORITY: (HIGH, MEDIUM, or LOW)\nACTION: (one specific next step)\n\nMessage: '+msg; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); answer=resp.get('response',''); lines=answer.strip().split(chr(10)); parts={l.split(':',1)[0].strip().upper():l.split(':',1)[1].strip() for l in lines if ':' in l}; cat=parts.get('CATEGORY','general').lower().strip(); pri=parts.get('PRIORITY','MEDIUM').upper().strip(); act=parts.get('ACTION','Review manually').strip(); ts=datetime.datetime.now().strftime('%%%%Y-%%%%m-%%%%d %%%%H:%%%%M:%%%%S'); print(); print('   ┌─────────────────────────────────────┐'); print('   │ Category:  '+cat); print('   │ Priority:  '+pri); print('   │ Action:    '+act); print('   └─────────────────────────────────────┘'); emb_data=json.dumps({'model':'llama3.2:1b','prompt':msg}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); payload={'class':'MessageLog','properties':{'content':msg,'category':cat,'priority':pri,'suggestedAction':act,'timestamp':ts},'vector':vec}; store_data=json.dumps(payload).encode(); store_req=urllib.request.Request('http://localhost:8080/v1/objects',data=store_data,headers={'Content-Type':'application/json'}); urllib.request.urlopen(store_req); print('   Logged to MessageLog')" 2^>nul
echo.
echo echo.
echo goto triage_loop
echo.
echo :triage_done
echo echo.
echo echo   Triage session closed. All messages logged.
echo endlocal
echo exit /b 0
)

if exist "%OUTPUT_DIR%\sort-and-route.bat" (
    echo  [92m   ✓ sort-and-route.bat created in output folder[0m
) else (
    echo  [91m   ✗ Failed to create sort-and-route.bat[0m
    pause
    exit /b 1
)

echo.
echo   Try classifying your own messages. Examples:
echo     - "I need a quote for a bathroom remodel"
echo     - "Your technician never showed up and nobody called"
echo     - "Can we move our Tuesday appointment?"
echo.

:test_loop
echo  ──────────────────────────────────────────────────────
set /p "TEST_MSG=  Message to classify (Q to quit): "

if /i "%TEST_MSG%"=="Q" goto exercise_done
if "%TEST_MSG%"=="" goto test_loop

echo.
echo   Classifying...

python -c "import json,urllib.request,datetime; msg=r'''%TEST_MSG%'''; prompt='Classify this business message. Respond with EXACTLY three lines:\nCATEGORY: (quote_request, complaint, scheduling, payment, or general)\nPRIORITY: (HIGH, MEDIUM, or LOW)\nACTION: (one specific next step)\n\nMessage: '+msg; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); answer=resp.get('response',''); lines=answer.strip().split(chr(10)); parts={l.split(':',1)[0].strip().upper():l.split(':',1)[1].strip() for l in lines if ':' in l}; cat=parts.get('CATEGORY','general').lower().strip(); pri=parts.get('PRIORITY','MEDIUM').upper().strip(); act=parts.get('ACTION','Review manually').strip(); print(); print('   Category:  '+cat); print('   Priority:  '+pri); print('   Action:    '+act)" 2>nul

echo.
goto test_loop

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   Your Sort and Route tool is built. It lives at:
echo     %OUTPUT_DIR%\sort-and-route.bat
echo.
echo   Messages are logged in Weaviate for pattern tracking.
echo   Now run verify.bat to confirm everything passed.
echo.

if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
