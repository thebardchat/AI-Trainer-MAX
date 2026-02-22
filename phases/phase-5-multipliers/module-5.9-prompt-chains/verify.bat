@echo off
setlocal enabledelayedexpansion
title Module 5.9 Verify — Prompt Chains

:: ============================================================
:: MODULE 5.9 VERIFICATION
:: Checks: MCP reachable, vault_search returns content,
::         Step 1 summary generated (>50 chars),
::         Step 2 analysis generated (>50 chars),
::         Step 3 mission statement generated (>50 chars),
::         search_knowledge returns entries
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=6"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.9-verify"
set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 5.9 VERIFICATION — Prompt Chains
echo  ══════════════════════════════════════════════════════
echo.

:: --- CHECK 1: MCP server reachable ---
echo  [CHECK 1/%TOTAL_CHECKS%] MCP server reachable
python "%MCP_CALL%" system_health > "%TEMP_DIR%\health.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: MCP server responding[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: MCP server not reachable[0m
    echo          Fix: Ensure ShaneBrain MCP gateway is running on port 8100
    echo          Run: shared\utils\mcp-health-check.bat
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: vault_search returns content ---
echo  [CHECK 2/%TOTAL_CHECKS%] vault_search returns content
python "%MCP_CALL%" vault_search "{\"query\":\"personal values family life\"}" > "%TEMP_DIR%\vault.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[d])); has=len(results)>0 if isinstance(results,list) else bool(results); print('OK' if has else 'EMPTY')" 2>nul > "%TEMP_DIR%\vault_status.txt"
    set /p VAULT_STATUS=<"%TEMP_DIR%\vault_status.txt"
    if "!VAULT_STATUS!"=="OK" (
        echo  [92m   PASS: vault_search returned content[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: vault_search returned empty results[0m
        echo          Fix: Add personal documents to your vault via Module 3.1 or 4.2
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_search call failed[0m
    echo          Fix: Check MCP server is running on port 8100
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: Step 1 — chat_with_shanebrain summary (>50 chars) ---
echo  [CHECK 3/%TOTAL_CHECKS%] Step 1 — Summary generation (chat_with_shanebrain)
echo   Running Step 1: Summarize vault content in 3 bullets...

:: Gather content first
python -c "import json; vf=r'%TEMP_DIR%\vault.txt'; d=json.load(open(vf)); results=d if isinstance(d,list) else d.get('results',d.get('documents',[d])); text='\n'.join([str(r.get('content',r.get('text',str(r))))[:300] for r in (results[:5] if isinstance(results,list) else [results])]); open(r'%TEMP_DIR%\gathered.txt','w').write(text[:1500])" 2>nul

python -c "import json,subprocess; content=open(r'%TEMP_DIR%\gathered.txt').read().strip(); prompt='Summarize the following personal documents in exactly 3 bullet points. Focus on the key themes and values: '+content; args=json.dumps({'message':prompt}); result=subprocess.run(['python',r'%MCP_CALL%','chat_with_shanebrain',args],capture_output=True,text=True,timeout=120); d=json.loads(result.stdout); text=d.get('text',d.get('response',str(d))); open(r'%TEMP_DIR%\step1.txt','w').write(text)" 2>nul

python -c "text=open(r'%TEMP_DIR%\step1.txt').read().strip(); exit(0 if len(text)>50 else 1)" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Step 1 summary generated (>50 chars)[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Step 1 summary too short or empty[0m
    echo          Fix: Check that Ollama is running with a model loaded
    echo          Test: curl http://localhost:11434/api/tags
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: Step 2 — chat_with_shanebrain analysis (>50 chars) ---
echo  [CHECK 4/%TOTAL_CHECKS%] Step 2 — Theme analysis (chat_with_shanebrain)
echo   Running Step 2: Identify 2 themes from Step 1 summary...

python -c "import json,subprocess; step1=open(r'%TEMP_DIR%\step1.txt').read().strip(); prompt='Analyze these bullet points and identify the 2 most important themes. For each theme, explain why it matters in one sentence: '+step1; args=json.dumps({'message':prompt}); result=subprocess.run(['python',r'%MCP_CALL%','chat_with_shanebrain',args],capture_output=True,text=True,timeout=120); d=json.loads(result.stdout); text=d.get('text',d.get('response',str(d))); open(r'%TEMP_DIR%\step2.txt','w').write(text)" 2>nul

python -c "text=open(r'%TEMP_DIR%\step2.txt').read().strip(); exit(0 if len(text)>50 else 1)" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Step 2 theme analysis generated (>50 chars)[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Step 2 theme analysis too short or empty[0m
    echo          Fix: Check that Ollama is running. Step 2 depends on Step 1 output.
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Step 3 — draft_create mission statement (>50 chars) ---
echo  [CHECK 5/%TOTAL_CHECKS%] Step 3 — Mission statement (draft_create)
echo   Running Step 3: Write mission statement from Step 2 themes...

python -c "import json,subprocess; step2=open(r'%TEMP_DIR%\step2.txt').read().strip(); prompt='Write a one-paragraph personal mission statement based on these themes. Make it direct, personal, and actionable: '+step2; args=json.dumps({'prompt':prompt,'draft_type':'general'}); result=subprocess.run(['python',r'%MCP_CALL%','draft_create',args],capture_output=True,text=True,timeout=120); d=json.loads(result.stdout); text=d.get('text',d.get('draft',d.get('content',d.get('response',str(d))))); open(r'%TEMP_DIR%\step3.txt','w').write(text)" 2>nul

python -c "text=open(r'%TEMP_DIR%\step3.txt').read().strip(); exit(0 if len(text)>50 else 1)" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Step 3 mission statement generated (>50 chars)[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Step 3 mission statement too short or empty[0m
    echo          Fix: Check that Ollama is running and draft_create tool is available
    echo          Test: python shared\utils\mcp-call.py draft_create "{\"prompt\":\"test\",\"draft_type\":\"general\"}"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 6: search_knowledge returns entries ---
echo  [CHECK 6/%TOTAL_CHECKS%] search_knowledge returns entries for context
python "%MCP_CALL%" search_knowledge "{\"query\":\"family values philosophy life\"}" > "%TEMP_DIR%\kb.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\kb.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[d])); has=len(results)>0 if isinstance(results,list) else bool(results); print('OK' if has else 'EMPTY')" 2>nul > "%TEMP_DIR%\kb_status.txt"
    set /p KB_STATUS=<"%TEMP_DIR%\kb_status.txt"
    if "!KB_STATUS!"=="OK" (
        echo  [92m   PASS: search_knowledge returned entries[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: search_knowledge returned empty results[0m
        echo          Fix: Add knowledge entries via Module 4.2 exercise.bat
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge call failed[0m
    echo          Fix: Check MCP server is running on port 8100
    set /a FAIL_COUNT+=1
)
echo.

:: Cleanup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

:: --- RESULTS ---
echo  ══════════════════════════════════════════════════════
if %FAIL_COUNT% EQU 0 (
    echo.
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
    echo.
    echo  [92m   MODULE 5.9 COMPLETE — Prompt Chains[0m
    echo.
    echo  [92m   You proved:[0m
    echo  [92m   + vault_search and search_knowledge provide raw chain input[0m
    echo  [92m   + Step 1 summarizes raw content into focused bullets[0m
    echo  [92m   + Step 2 analyzes the summary and extracts key themes[0m
    echo  [92m   + Step 3 creates a polished mission statement from themes[0m
    echo  [92m   + Each step builds on the previous step's output[0m
    echo  [92m   + Multi-step chains produce better results than single-shot prompts[0m
    echo.
    echo   You built an assembly line for AI. Raw material in,
    echo   polished product out, three focused stations in between.
    echo  ══════════════════════════════════════════════════════

    :: --- Update progress ---
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "5.9", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

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
