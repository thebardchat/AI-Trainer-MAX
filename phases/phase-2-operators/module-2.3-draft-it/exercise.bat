@echo off
setlocal enabledelayedexpansion
title Module 2.3 Exercise — Draft It

:: ============================================================
:: MODULE 2.3 EXERCISE: Draft It
:: Goal: Create DraftTemplate schema, seed templates, build
::       a message drafting tool with tone control & context
:: Time: ~20 minutes
:: RAM impact: ~300MB beyond Ollama + Weaviate baseline
:: Prerequisites: Module 2.1 (BusinessDoc), Module 2.2
:: ============================================================

set "MOD_DIR=%~dp0"
set "OUTPUT_DIR=%MOD_DIR%output"
set "TEMP_DIR=%TEMP%\module-2.3"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.3 EXERCISE: Draft It
echo  ══════════════════════════════════════════════════════
echo.
echo   Build a message drafting tool with templates and
echo   tone control. Three tasks.
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
    echo  [91m   ✗ BusinessDoc class not found. Complete Module 2.1 first.[0m
    pause
    exit /b 1
)
echo  [92m   ✓ BusinessDoc exists (Module 2.1 complete)[0m
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: ============================================================
:: TASK 1: Create DraftTemplate schema and seed templates
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/3] Create DraftTemplate schema and seed templates
echo.

:: Create schema
curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "DraftTemplate" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo   Creating "DraftTemplate" class...
    curl -s -X POST http://localhost:8080/v1/schema -H "Content-Type: application/json" -d "{\"class\":\"DraftTemplate\",\"description\":\"Reusable business message templates\",\"vectorizer\":\"none\",\"properties\":[{\"name\":\"title\",\"dataType\":[\"text\"],\"description\":\"Template name\"},{\"name\":\"content\",\"dataType\":[\"text\"],\"description\":\"Template text\"},{\"name\":\"messageType\",\"dataType\":[\"text\"],\"description\":\"Message type: email, text, letter, memo\"},{\"name\":\"tone\",\"dataType\":[\"text\"],\"description\":\"Tone: professional, friendly, firm\"}]}" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [92m   ✓ "DraftTemplate" class created[0m
    ) else (
        echo  [91m   ✗ Failed to create DraftTemplate schema[0m
        pause
        exit /b 1
    )
) else (
    echo  [92m   ✓ "DraftTemplate" class already exists[0m
)
echo.

:: Seed templates
echo   Seeding starter templates...
echo.

:: Template 1: Customer Welcome
python -c "import json,urllib.request; content='Hi [NAME], welcome! We are glad you chose us. Here is what to expect: we will schedule your appointment, our technician will arrive on time, and we will follow up after the job to make sure everything is right. If you have any questions, just call or text us anytime. Looking forward to working with you.'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':content}).encode(); req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); vec=resp.get('embedding',[]); payload={'class':'DraftTemplate','properties':{'title':'Customer Welcome','content':content,'messageType':'email','tone':'friendly'},'vector':vec}; data=json.dumps(payload).encode(); store_req=urllib.request.Request('http://localhost:8080/v1/objects',data=data,headers={'Content-Type':'application/json'}); urllib.request.urlopen(store_req); print('OK')" 2>nul > "%TEMP_DIR%\t1.txt"
set /p T1=<"%TEMP_DIR%\t1.txt"
if "%T1%"=="OK" ( echo  [92m   ✓ Template: Customer Welcome [friendly][0m ) else ( echo  [93m   ⚠ Customer Welcome — may be duplicate[0m )

:: Template 2: Quote Follow-Up
python -c "import json,urllib.request; content='Hi [NAME], I wanted to follow up on the estimate we provided on [DATE]. The total was [AMOUNT] which includes all labor and materials. This estimate is valid for 30 days. If you have any questions about the scope of work or pricing, I am happy to walk through it. Ready to get started? Just let me know and we will get you on the schedule.'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':content}).encode(); req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); vec=resp.get('embedding',[]); payload={'class':'DraftTemplate','properties':{'title':'Quote Follow-Up','content':content,'messageType':'email','tone':'professional'},'vector':vec}; data=json.dumps(payload).encode(); store_req=urllib.request.Request('http://localhost:8080/v1/objects',data=data,headers={'Content-Type':'application/json'}); urllib.request.urlopen(store_req); print('OK')" 2>nul > "%TEMP_DIR%\t2.txt"
set /p T2=<"%TEMP_DIR%\t2.txt"
if "%T2%"=="OK" ( echo  [92m   ✓ Template: Quote Follow-Up [professional][0m ) else ( echo  [93m   ⚠ Quote Follow-Up — may be duplicate[0m )

:: Template 3: Complaint Response
python -c "import json,urllib.request; content='Dear [NAME], thank you for letting us know about this issue. I take every complaint seriously. Here is what I am going to do: I will review the details of your case, contact you within 24 hours with a resolution plan, and make sure this is handled to your satisfaction. We stand behind our work and want to make this right.'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':content}).encode(); req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); vec=resp.get('embedding',[]); payload={'class':'DraftTemplate','properties':{'title':'Complaint Response','content':content,'messageType':'email','tone':'professional'},'vector':vec}; data=json.dumps(payload).encode(); store_req=urllib.request.Request('http://localhost:8080/v1/objects',data=data,headers={'Content-Type':'application/json'}); urllib.request.urlopen(store_req); print('OK')" 2>nul > "%TEMP_DIR%\t3.txt"
set /p T3=<"%TEMP_DIR%\t3.txt"
if "%T3%"=="OK" ( echo  [92m   ✓ Template: Complaint Response [professional][0m ) else ( echo  [93m   ⚠ Complaint Response — may be duplicate[0m )

:: Template 4: Payment Reminder
python -c "import json,urllib.request; content='Hi [NAME], this is a friendly reminder that invoice [NUMBER] for [AMOUNT] is now past due. Payment was due on [DATE]. We accept cash, check, and all major credit cards. Please submit payment at your earliest convenience. If you have already sent payment, please disregard this notice. If you need to discuss a payment plan, call us directly.'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':content}).encode(); req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); vec=resp.get('embedding',[]); payload={'class':'DraftTemplate','properties':{'title':'Payment Reminder','content':content,'messageType':'email','tone':'firm'},'vector':vec}; data=json.dumps(payload).encode(); store_req=urllib.request.Request('http://localhost:8080/v1/objects',data=data,headers={'Content-Type':'application/json'}); urllib.request.urlopen(store_req); print('OK')" 2>nul > "%TEMP_DIR%\t4.txt"
set /p T4=<"%TEMP_DIR%\t4.txt"
if "%T4%"=="OK" ( echo  [92m   ✓ Template: Payment Reminder [firm][0m ) else ( echo  [93m   ⚠ Payment Reminder — may be duplicate[0m )

:: Template 5: Job Completion
python -c "import json,urllib.request; content='Hi [NAME], good news — the job at [ADDRESS] is complete. Here is a summary of what we did: [WORK_SUMMARY]. The total comes to [AMOUNT]. Payment is due upon completion. Thank you for choosing us. We will follow up in 48 hours to make sure everything is working properly. Our work comes with a 90-day warranty on labor.'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':content}).encode(); req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); vec=resp.get('embedding',[]); payload={'class':'DraftTemplate','properties':{'title':'Job Completion','content':content,'messageType':'email','tone':'professional'},'vector':vec}; data=json.dumps(payload).encode(); store_req=urllib.request.Request('http://localhost:8080/v1/objects',data=data,headers={'Content-Type':'application/json'}); urllib.request.urlopen(store_req); print('OK')" 2>nul > "%TEMP_DIR%\t5.txt"
set /p T5=<"%TEMP_DIR%\t5.txt"
if "%T5%"=="OK" ( echo  [92m   ✓ Template: Job Completion [professional][0m ) else ( echo  [93m   ⚠ Job Completion — may be duplicate[0m )

echo.
echo   Five templates loaded. Press any key to build the drafting tool...
pause >nul
echo.

:: ============================================================
:: TASK 2: Generate the Draft It tool
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/3] Generate the Draft It tool
echo.

> "%OUTPUT_DIR%\draft-it.bat" (
echo @echo off
echo setlocal enabledelayedexpansion
echo title Draft It — Business Message Drafter
echo.
echo set "TEMP_DIR=%%TEMP%%\draft-it"
echo if not exist "%%TEMP_DIR%%" mkdir "%%TEMP_DIR%%"
echo.
echo echo.
echo echo  ══════════════════════════════════════════════════════
echo echo   DRAFT IT — Business Message Drafter
echo echo   Describe what you need. Get a draft with your data.
echo echo  ══════════════════════════════════════════════════════
echo echo.
echo echo   Tone options: professional, friendly, firm
echo echo   Type examples: email, text, letter, memo
echo echo.
echo.
echo :draft_loop
echo echo  ──────────────────────────────────────────────────────
echo set /p "REQUEST=  What do you need to write? (Q to quit^): "
echo if /i "%%REQUEST%%"=="Q" goto draft_done
echo if "%%REQUEST%%"=="" goto draft_loop
echo.
echo set "TONE=professional"
echo set /p "TONE=  Tone (professional/friendly/firm^) [professional]: "
echo if "%%TONE%%"=="" set "TONE=professional"
echo.
echo echo   Finding templates and business context...
echo.
echo :: Find matching template and business context, then draft
echo python -c "import json,urllib.request; request=r'''%%REQUEST%%'''; tone='%%TONE%%'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':request}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); tq='{Get{DraftTemplate(nearVector:{vector:'+json.dumps(vec)+'},limit:1){title content messageType tone}}}'; t_data=json.dumps({'query':tq}).encode(); t_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=t_data,headers={'Content-Type':'application/json'}); t_resp=json.loads(urllib.request.urlopen(t_req).read()); templates=t_resp.get('data',{}).get('Get',{}).get('DraftTemplate',[]); tmpl=templates[0] if templates else {}; bq='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:2){title content category}}}'; b_data=json.dumps({'query':bq}).encode(); b_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=b_data,headers={'Content-Type':'application/json'}); b_resp=json.loads(urllib.request.urlopen(b_req).read()); biz_docs=b_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[]); biz_ctx=chr(10).join([d.get('content','') for d in biz_docs]); tmpl_text=tmpl.get('content','No template found.'); prompt='You are a business message drafter. Write a '+tone+' message based on this request: '+request+chr(10)+chr(10)+'Use this template as a style guide:'+chr(10)+tmpl_text+chr(10)+chr(10)+'Use these business facts (include real numbers):'+chr(10)+biz_ctx+chr(10)+chr(10)+'Write a complete, ready-to-send message. Replace any [PLACEHOLDER] with reasonable defaults. Keep it concise.'; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); print(resp.get('response','No draft generated.')); print(chr(10)+'   Template used: '+tmpl.get('title','none')); print('   Business docs: '+', '.join([d.get('title','') for d in biz_docs]))" 2^>nul
echo.
echo echo.
echo echo   [92m   Edit the draft as needed, then send it.[0m
echo echo.
echo goto draft_loop
echo.
echo :draft_done
echo echo.
echo echo   Drafting session closed.
echo if exist "%%TEMP_DIR%%" rd /s /q "%%TEMP_DIR%%" 2^>nul
echo endlocal
echo exit /b 0
)

if exist "%OUTPUT_DIR%\draft-it.bat" (
    echo  [92m   ✓ draft-it.bat created in output folder[0m
) else (
    echo  [91m   ✗ Failed to create draft-it.bat[0m
    pause
    exit /b 1
)

echo.
echo   Press any key to test the drafting tool...
pause >nul
echo.

:: ============================================================
:: TASK 3: Test the Draft It tool
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/3] Test your Draft It tool
echo.
echo   Try these drafting requests:
echo     - "reply to a customer asking about our rates" (friendly)
echo     - "follow up on a quote from last week" (professional)
echo     - "respond to a complaint about late arrival" (professional)
echo     - "remind a customer about overdue payment" (firm)
echo.

:test_loop
echo  ──────────────────────────────────────────────────────
set /p "TEST_REQ=  What do you need to write? (Q to quit): "

if /i "%TEST_REQ%"=="Q" goto exercise_done
if "%TEST_REQ%"=="" goto test_loop

set "TEST_TONE=professional"
set /p "TEST_TONE=  Tone (professional/friendly/firm) [professional]: "
if "%TEST_TONE%"=="" set "TEST_TONE=professional"

echo.
echo   Finding templates and business context...
echo.

python -c "import json,urllib.request; request=r'''%TEST_REQ%'''; tone='%TEST_TONE%'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':request}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); tq='{Get{DraftTemplate(nearVector:{vector:'+json.dumps(vec)+'},limit:1){title content tone}}}'; t_data=json.dumps({'query':tq}).encode(); t_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=t_data,headers={'Content-Type':'application/json'}); t_resp=json.loads(urllib.request.urlopen(t_req).read()); templates=t_resp.get('data',{}).get('Get',{}).get('DraftTemplate',[]); tmpl=templates[0] if templates else {}; bq='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:2){title content category}}}'; b_data=json.dumps({'query':bq}).encode(); b_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=b_data,headers={'Content-Type':'application/json'}); b_resp=json.loads(urllib.request.urlopen(b_req).read()); biz_docs=b_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[]); biz_ctx=chr(10).join([d.get('content','') for d in biz_docs]); tmpl_text=tmpl.get('content','No template found.'); prompt='You are a business message drafter. Write a '+tone+' message based on this request: '+request+chr(10)+chr(10)+'Style guide:'+chr(10)+tmpl_text+chr(10)+chr(10)+'Business facts:'+chr(10)+biz_ctx+chr(10)+chr(10)+'Write a complete, ready-to-send message. Replace placeholders with reasonable defaults. Keep it concise.'; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); print(resp.get('response','No draft.')); print(); print('   Template: '+tmpl.get('title','none')+' ['+tmpl.get('tone','')+']'); print('   Biz docs: '+', '.join([d.get('title','') for d in biz_docs]))" 2>nul

echo.
goto test_loop

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   Your Draft It tool is built and tested. It lives at:
echo     %OUTPUT_DIR%\draft-it.bat
echo.
echo   To make it better: save your best real messages as
echo   templates in the DraftTemplate collection.
echo.
echo   Now run verify.bat to confirm everything passed.
echo.

if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
