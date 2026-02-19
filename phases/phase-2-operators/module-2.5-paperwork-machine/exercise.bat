@echo off
setlocal enabledelayedexpansion
title Module 2.5 Exercise — Paperwork Machine

:: ============================================================
:: MODULE 2.5 EXERCISE: Paperwork Machine
:: Goal: Create DocTemplate schema, seed templates, build
::       document generator that outputs to files
:: Time: ~20 minutes
:: RAM impact: ~300MB beyond Ollama + Weaviate baseline
:: Prerequisites: Module 2.1 (BusinessDoc), Module 2.3
:: ============================================================

set "MOD_DIR=%~dp0"
set "OUTPUT_DIR=%MOD_DIR%output"
set "DOC_DIR=%MOD_DIR%output\documents"
set "TEMP_DIR=%TEMP%\module-2.5"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 2.5 EXERCISE: Paperwork Machine
echo  ══════════════════════════════════════════════════════
echo.
echo   Build a document generator with templates and real
echo   business data. Three tasks.
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
echo  [92m   ✓ BusinessDoc exists[0m
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%DOC_DIR%" mkdir "%DOC_DIR%"

:: ============================================================
:: TASK 1: Create DocTemplate schema and seed templates
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/3] Create DocTemplate schema and seed templates
echo.

:: Create schema
curl -s http://localhost:8080/v1/schema 2>nul | findstr /i "DocTemplate" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo   Creating "DocTemplate" class...
    curl -s -X POST http://localhost:8080/v1/schema -H "Content-Type: application/json" -d "{\"class\":\"DocTemplate\",\"description\":\"Business document templates\",\"vectorizer\":\"none\",\"properties\":[{\"name\":\"title\",\"dataType\":[\"text\"],\"description\":\"Template name\"},{\"name\":\"content\",\"dataType\":[\"text\"],\"description\":\"Template structure\"},{\"name\":\"docType\",\"dataType\":[\"text\"],\"description\":\"Document type: estimate, report, checklist, letter\"},{\"name\":\"requiredFields\",\"dataType\":[\"text\"],\"description\":\"Comma-separated required fields\"}]}" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo  [92m   ✓ "DocTemplate" class created[0m
    ) else (
        echo  [91m   ✗ Failed to create DocTemplate schema[0m
        pause
        exit /b 1
    )
) else (
    echo  [92m   ✓ "DocTemplate" class already exists[0m
)
echo.

:: Seed templates
echo   Seeding document templates...
echo.

:: Template 1: Standard Estimate
python -c "import json,urllib.request; content='ESTIMATE\nDate: [DATE]\nCustomer: [CUSTOMER_NAME]\nAddress: [ADDRESS]\n\nSERVICE DESCRIPTION:\n[DESCRIPTION]\n\nLINE ITEMS:\n  Labor: [HOURS] hours @ [RATE]/hour = [LABOR_TOTAL]\n  Materials: [MATERIALS] (15%% markup) = [MATERIALS_TOTAL]\n  Service call fee: $85.00\n  ─────────────────\n  ESTIMATED TOTAL: [TOTAL]\n\nTERMS:\n- Estimate valid for 30 days\n- Payment due upon completion\n- 90-day warranty on labor\n- We accept cash, check, and all major credit cards'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':content}).encode(); req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); vec=resp.get('embedding',[]); payload={'class':'DocTemplate','properties':{'title':'Standard Estimate','content':content,'docType':'estimate','requiredFields':'customer_name, address, description, hours, materials'},'vector':vec}; data=json.dumps(payload).encode(); store_req=urllib.request.Request('http://localhost:8080/v1/objects',data=data,headers={'Content-Type':'application/json'}); urllib.request.urlopen(store_req); print('OK')" 2>nul > "%TEMP_DIR%\dt1.txt"
set /p DT1=<"%TEMP_DIR%\dt1.txt"
if "%DT1%"=="OK" ( echo  [92m   ✓ Template: Standard Estimate[0m ) else ( echo  [93m   ⚠ Standard Estimate — may be duplicate[0m )

:: Template 2: Daily Job Report
python -c "import json,urllib.request; content='DAILY JOB REPORT\nDate: [DATE]\nSite: [ADDRESS]\nJob: [JOB_NAME]\nCrew: [CREW_MEMBERS]\n\nWORK PERFORMED:\n[WORK_DETAILS]\n\nMATERIALS USED:\n[MATERIALS_LIST]\n\nISSUES/NOTES:\n[ISSUES]\n\nNEXT STEPS:\n[NEXT_STEPS]\n\nHours on site: [HOURS]\nReport submitted by: [SUBMITTED_BY]'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':content}).encode(); req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); vec=resp.get('embedding',[]); payload={'class':'DocTemplate','properties':{'title':'Daily Job Report','content':content,'docType':'report','requiredFields':'date, address, job_name, work_details, hours'},'vector':vec}; data=json.dumps(payload).encode(); store_req=urllib.request.Request('http://localhost:8080/v1/objects',data=data,headers={'Content-Type':'application/json'}); urllib.request.urlopen(store_req); print('OK')" 2>nul > "%TEMP_DIR%\dt2.txt"
set /p DT2=<"%TEMP_DIR%\dt2.txt"
if "%DT2%"=="OK" ( echo  [92m   ✓ Template: Daily Job Report[0m ) else ( echo  [93m   ⚠ Daily Job Report — may be duplicate[0m )

:: Template 3: Job Checklist
python -c "import json,urllib.request; content='JOB CHECKLIST\nJob: [JOB_NAME]\nDate: [DATE]\nTechnician: [TECH_NAME]\n\nPRE-ARRIVAL:\n[ ] Review job details and customer notes\n[ ] Load required tools and materials\n[ ] Confirm appointment with customer\n[ ] Check route and estimated travel time\n\nON-SITE:\n[ ] Introduce yourself and confirm scope of work\n[ ] Protect work area (drop cloths, shoe covers)\n[ ] Complete the work per specifications\n[ ] Test and verify the repair or installation\n\nCOMPLETION:\n[ ] Clean up work area thoroughly\n[ ] Walk customer through completed work\n[ ] Collect payment or confirm billing\n[ ] Provide receipt and warranty information\n\nFOLLOW-UP:\n[ ] Submit job report\n[ ] Schedule 48-hour follow-up call\n[ ] Update customer file with job details'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':content}).encode(); req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); vec=resp.get('embedding',[]); payload={'class':'DocTemplate','properties':{'title':'Job Checklist','content':content,'docType':'checklist','requiredFields':'job_name, date, tech_name'},'vector':vec}; data=json.dumps(payload).encode(); store_req=urllib.request.Request('http://localhost:8080/v1/objects',data=data,headers={'Content-Type':'application/json'}); urllib.request.urlopen(store_req); print('OK')" 2>nul > "%TEMP_DIR%\dt3.txt"
set /p DT3=<"%TEMP_DIR%\dt3.txt"
if "%DT3%"=="OK" ( echo  [92m   ✓ Template: Job Checklist[0m ) else ( echo  [93m   ⚠ Job Checklist — may be duplicate[0m )

:: Template 4: Customer Letter
python -c "import json,urllib.request; content='[COMPANY_NAME]\n[DATE]\n\nDear [CUSTOMER_NAME],\n\n[BODY]\n\nIf you have any questions, please do not hesitate to contact us.\n\nSincerely,\n[SENDER_NAME]\n[COMPANY_NAME]\n[PHONE]'; emb_data=json.dumps({'model':'llama3.2:1b','prompt':content}).encode(); req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); vec=resp.get('embedding',[]); payload={'class':'DocTemplate','properties':{'title':'Customer Letter','content':content,'docType':'letter','requiredFields':'customer_name, body, sender_name'},'vector':vec}; data=json.dumps(payload).encode(); store_req=urllib.request.Request('http://localhost:8080/v1/objects',data=data,headers={'Content-Type':'application/json'}); urllib.request.urlopen(store_req); print('OK')" 2>nul > "%TEMP_DIR%\dt4.txt"
set /p DT4=<"%TEMP_DIR%\dt4.txt"
if "%DT4%"=="OK" ( echo  [92m   ✓ Template: Customer Letter[0m ) else ( echo  [93m   ⚠ Customer Letter — may be duplicate[0m )

echo.
echo   Press any key to build the document generator...
pause >nul
echo.

:: ============================================================
:: TASK 2: Generate the Paperwork Machine tool
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/3] Generate the Paperwork Machine tool
echo.

> "%OUTPUT_DIR%\paperwork-machine.bat" (
echo @echo off
echo setlocal enabledelayedexpansion
echo title Paperwork Machine — Document Generator
echo.
echo set "DOC_DIR=%%~dp0documents"
echo set "TEMP_DIR=%%TEMP%%\paperwork-machine"
echo if not exist "%%DOC_DIR%%" mkdir "%%DOC_DIR%%"
echo if not exist "%%TEMP_DIR%%" mkdir "%%TEMP_DIR%%"
echo.
echo echo.
echo echo  ══════════════════════════════════════════════════════
echo echo   PAPERWORK MACHINE — Document Generator
echo echo   Describe what you need. Get a formatted document.
echo echo  ══════════════════════════════════════════════════════
echo echo.
echo echo   Document types: estimate, report, checklist, letter
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
echo echo  [92m   Systems online. Ready to generate documents.[0m
echo echo.
echo.
echo :gen_loop
echo echo  ──────────────────────────────────────────────────────
echo set /p "REQUEST=  Describe the document you need (Q to quit^): "
echo if /i "%%REQUEST%%"=="Q" goto gen_done
echo if "%%REQUEST%%"=="" goto gen_loop
echo echo.
echo echo   Finding template and business data...
echo echo   Generating document...
echo.
echo python -c "import json,urllib.request,datetime; request=r'''%%REQUEST%%'''; emb_data=json.dumps({'model':'llama3.2:1b','prompt':request}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); tq='{Get{DocTemplate(nearVector:{vector:'+json.dumps(vec)+'},limit:1){title content docType requiredFields}}}'; t_data=json.dumps({'query':tq}).encode(); t_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=t_data,headers={'Content-Type':'application/json'}); t_resp=json.loads(urllib.request.urlopen(t_req).read()); tmpl=t_resp.get('data',{}).get('Get',{}).get('DocTemplate',[{}])[0]; bq='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:2){title content category}}}'; b_data=json.dumps({'query':bq}).encode(); b_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=b_data,headers={'Content-Type':'application/json'}); b_resp=json.loads(urllib.request.urlopen(b_req).read()); biz_docs=b_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[]); biz_ctx=chr(10).join([d.get('content','') for d in biz_docs]); prompt='Generate a business document based on this request: '+request+chr(10)+chr(10)+'Use this template structure:'+chr(10)+tmpl.get('content','')+chr(10)+chr(10)+'Use these real business details (rates, terms, policies):'+chr(10)+biz_ctx+chr(10)+chr(10)+'Fill in all placeholders with realistic values based on the request. Output the complete document ready to use.'; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); doc=resp.get('response','No document generated.'); print(doc); ts=datetime.datetime.now().strftime('%%%%Y%%%%m%%%%d-%%%%H%%%%M%%%%S'); fname=tmpl.get('docType','doc')+'-'+ts+'.txt'; fpath=r'%%DOC_DIR%%'+'\\\\'+fname; open(fpath,'w').write(doc); print(chr(10)+'   Template: '+tmpl.get('title','')+' ['+tmpl.get('docType','')+']'); print('   Saved to: '+fname)" 2^>nul
echo.
echo echo.
echo goto gen_loop
echo.
echo :gen_done
echo echo.
echo echo   Documents saved in: %%DOC_DIR%%
echo if exist "%%TEMP_DIR%%" rd /s /q "%%TEMP_DIR%%" 2^>nul
echo endlocal
echo exit /b 0
)

if exist "%OUTPUT_DIR%\paperwork-machine.bat" (
    echo  [92m   ✓ paperwork-machine.bat created in output folder[0m
) else (
    echo  [91m   ✗ Failed to create paperwork-machine.bat[0m
    pause
    exit /b 1
)

echo.
echo   Press any key to test the document generator...
pause >nul
echo.

:: ============================================================
:: TASK 3: Test the Paperwork Machine
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/3] Test the Paperwork Machine
echo.
echo   Try generating these documents:
echo     - "estimate for fixing a leaky roof at 789 Pine St for Sarah Johnson"
echo     - "daily report for the Smith renovation project"
echo     - "checklist for a new installation job"
echo     - "letter to customer about warranty extension"
echo.

:test_loop
echo  ──────────────────────────────────────────────────────
set /p "TEST_REQ=  Describe the document (Q to quit): "

if /i "%TEST_REQ%"=="Q" goto exercise_done
if "%TEST_REQ%"=="" goto test_loop

echo.
echo   Finding template and generating...
echo.

python -c "import json,urllib.request,datetime; request=r'''%TEST_REQ%'''; emb_data=json.dumps({'model':'llama3.2:1b','prompt':request}).encode(); emb_req=urllib.request.Request('http://localhost:11434/api/embeddings',data=emb_data,headers={'Content-Type':'application/json'}); emb_resp=json.loads(urllib.request.urlopen(emb_req).read()); vec=emb_resp.get('embedding',[]); tq='{Get{DocTemplate(nearVector:{vector:'+json.dumps(vec)+'},limit:1){title content docType}}}'; t_data=json.dumps({'query':tq}).encode(); t_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=t_data,headers={'Content-Type':'application/json'}); t_resp=json.loads(urllib.request.urlopen(t_req).read()); tmpl=t_resp.get('data',{}).get('Get',{}).get('DocTemplate',[{}])[0]; bq='{Get{BusinessDoc(nearVector:{vector:'+json.dumps(vec)+'},limit:2){content}}}'; b_data=json.dumps({'query':bq}).encode(); b_req=urllib.request.Request('http://localhost:8080/v1/graphql',data=b_data,headers={'Content-Type':'application/json'}); b_resp=json.loads(urllib.request.urlopen(b_req).read()); biz=b_resp.get('data',{}).get('Get',{}).get('BusinessDoc',[]); biz_ctx=chr(10).join([d.get('content','') for d in biz]); prompt='Generate a business document for: '+request+chr(10)+'Template:'+chr(10)+tmpl.get('content','')+chr(10)+'Business data:'+chr(10)+biz_ctx+chr(10)+'Fill in all placeholders. Output the complete document.'; data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(); req=urllib.request.Request('http://localhost:11434/api/generate',data=data,headers={'Content-Type':'application/json'}); resp=json.loads(urllib.request.urlopen(req).read()); doc=resp.get('response',''); print(doc); ts=datetime.datetime.now().strftime('%Y%m%d-%H%M%S'); fname=tmpl.get('docType','doc')+'-'+ts+'.txt'; fpath=r'%DOC_DIR%\\'+fname; open(fpath,'w').write(doc); print(); print('   Template: '+tmpl.get('title','')); print('   Saved to: '+fname)" 2>nul

echo.
goto test_loop

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   Your Paperwork Machine is built. It lives at:
echo     %OUTPUT_DIR%\paperwork-machine.bat
echo.
echo   Generated documents are saved in:
echo     %DOC_DIR%
echo.
echo   Now run verify.bat to confirm everything passed.
echo.

if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
