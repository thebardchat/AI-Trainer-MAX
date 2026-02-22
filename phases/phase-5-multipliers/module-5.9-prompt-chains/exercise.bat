@echo off
setlocal enabledelayedexpansion
title Module 5.9 Exercise — Prompt Chains

:: ============================================================
:: MODULE 5.9 EXERCISE: Prompt Chains
:: Goal: Build a 3-step prompt pipeline where each AI response
::       feeds the next. Raw vault content in, personal mission
::       statement out.
:: Time: ~20 minutes
:: Prerequisites: Module 1.4, Module 4.3
:: MCP Tools: chat_with_shanebrain, search_knowledge, vault_search, draft_create
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.9"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 5.9 EXERCISE: Prompt Chains
echo  ══════════════════════════════════════════════════════
echo.
echo   You're about to build a 3-step prompt pipeline.
echo   Each step does one focused job and passes its output
echo   to the next — like an assembly line for AI.
echo.
echo   Raw vault content goes in one end.
echo   A personal mission statement comes out the other.
echo.
echo  ──────────────────────────────────────────────────────
echo.

:: --- PRE-FLIGHT: Check MCP server ---
echo  [PRE-FLIGHT] Checking MCP server...
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

python "%MCP_CALL%" system_health > "%TEMP_DIR%\health.txt" 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   X MCP server not reachable. Is ShaneBrain running?[0m
    echo     Fix: Make sure the MCP server is running on port 8100
    echo     Run: shared\utils\mcp-health-check.bat
    pause
    exit /b 1
)
echo  [92m   PASS: MCP server responding[0m
echo.

:: ============================================================
:: TASK 1: GATHER — Pull raw content from vault and knowledge base
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/6] GATHER — Pull raw content from your vault and knowledge base
echo.
echo   Before the assembly line starts, you need raw material.
echo   We'll search two sources:
echo     - vault_search for personal documents
echo     - search_knowledge for family and philosophy entries
echo.
echo   This is the input that feeds the entire chain.
echo.

echo   Searching vault for personal documents...
python "%MCP_CALL%" vault_search "{\"query\":\"personal values family life work\"}" > "%TEMP_DIR%\vault_raw.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: vault_search returned results[0m
) else (
    echo  [93m   WARN: vault_search returned no results — chain will use knowledge base only[0m
)

echo   Searching knowledge base for family and philosophy entries...
python "%MCP_CALL%" search_knowledge "{\"query\":\"family values philosophy life lessons\"}" > "%TEMP_DIR%\knowledge_raw.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: search_knowledge returned results[0m
) else (
    echo  [91m   FAIL: search_knowledge returned nothing[0m
    echo          Your brain needs knowledge entries. Run Module 4.2 first.
    pause
    exit /b 1
)

:: Combine vault and knowledge results into one raw input file
echo.
echo   Combining raw content from both sources...
python -c "import json, os; vault_text=''; kb_text=''; vf=r'%TEMP_DIR%\vault_raw.txt'; kf=r'%TEMP_DIR%\knowledge_raw.txt'; exec(\"\"\"try:\n d=json.load(open(vf)); results=d if isinstance(d,list) else d.get('results',d.get('documents',[d])); vault_text='\\n'.join([str(r.get('content',r.get('text',str(r))))[:300] for r in (results[:5] if isinstance(results,list) else [results])])\nexcept: pass\"\"\"); exec(\"\"\"try:\n d=json.load(open(kf)); results=d if isinstance(d,list) else d.get('results',d.get('documents',[d])); kb_text='\\n'.join([str(r.get('content',r.get('text',str(r))))[:300] for r in (results[:5] if isinstance(results,list) else [results])])\nexcept: pass\"\"\"); combined=vault_text+'\\n'+kb_text if vault_text else kb_text; open(r'%TEMP_DIR%\gathered.txt','w').write(combined[:1500]); print('   Combined content: '+str(len(combined))+' chars (capped at 1500)')" 2>nul

echo  [92m   Raw material gathered and saved[0m
echo.
echo   Press any key to start the chain...
pause >nul
echo.

:: ============================================================
:: TASK 2: STEP 1 — SUMMARIZE
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/6] STEP 1 — SUMMARIZE
echo.
echo   First station on the assembly line. The AI reads all
echo   your raw content and condenses it into exactly 3 bullet
echo   points. Focus: key themes and values.
echo.
echo   One job. Full attention. Best possible summary.
echo.

:: Read gathered content and build the Step 1 prompt
python -c "import json, subprocess, sys, os; content=open(r'%TEMP_DIR%\gathered.txt').read().strip(); prompt='Summarize the following personal documents in exactly 3 bullet points. Focus on the key themes and values. Be specific, not generic. Here are the documents: '+content; args=json.dumps({'message':prompt}); cmd=['python',r'%MCP_CALL%','chat_with_shanebrain',args]; result=subprocess.run(cmd,capture_output=True,text=True,timeout=120); open(r'%TEMP_DIR%\step1_raw.txt','w').write(result.stdout); d=json.loads(result.stdout); text=d.get('text',d.get('response',str(d))); open(r'%TEMP_DIR%\step1.txt','w').write(text); print(text[:500])" 2>nul > "%TEMP_DIR%\step1_display.txt"

:: Check if step 1 produced output
python -c "text=open(r'%TEMP_DIR%\step1.txt').read().strip(); exit(0 if len(text)>50 else 1)" 2>nul
if %errorlevel% EQU 0 (
    echo.
    echo   STEP 1 OUTPUT — SUMMARY:
    echo   ══════════════════════════════════════════════════
    type "%TEMP_DIR%\step1_display.txt"
    echo.
    echo   ══════════════════════════════════════════════════
    echo  [92m   PASS: Step 1 summary generated[0m
) else (
    echo  [91m   FAIL: Step 1 did not produce a summary[0m
    echo          Check that Ollama is running and has a model loaded
    pause
    exit /b 1
)
echo.
echo   The raw material is now 3 focused bullets.
echo   Press any key to feed them to Step 2...
pause >nul
echo.

:: ============================================================
:: TASK 3: STEP 2 — ANALYZE
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/6] STEP 2 — ANALYZE
echo.
echo   Second station. The AI reads the 3-bullet summary from
echo   Step 1 and identifies the 2 most important themes.
echo   For each theme, it explains why it matters in one sentence.
echo.
echo   Notice: Step 2 never sees the raw vault content.
echo   It only sees what Step 1 produced. That's the chain.
echo.

:: Read step1 output and build the Step 2 prompt
python -c "import json, subprocess, sys; step1=open(r'%TEMP_DIR%\step1.txt').read().strip(); prompt='Analyze these bullet points and identify the 2 most important themes. For each theme, explain why it matters in one sentence. Here are the bullet points: '+step1; args=json.dumps({'message':prompt}); cmd=['python',r'%MCP_CALL%','chat_with_shanebrain',args]; result=subprocess.run(cmd,capture_output=True,text=True,timeout=120); open(r'%TEMP_DIR%\step2_raw.txt','w').write(result.stdout); d=json.loads(result.stdout); text=d.get('text',d.get('response',str(d))); open(r'%TEMP_DIR%\step2.txt','w').write(text); print(text[:500])" 2>nul > "%TEMP_DIR%\step2_display.txt"

:: Check if step 2 produced output
python -c "text=open(r'%TEMP_DIR%\step2.txt').read().strip(); exit(0 if len(text)>50 else 1)" 2>nul
if %errorlevel% EQU 0 (
    echo.
    echo   STEP 2 OUTPUT — ANALYSIS:
    echo   ══════════════════════════════════════════════════
    type "%TEMP_DIR%\step2_display.txt"
    echo.
    echo   ══════════════════════════════════════════════════
    echo  [92m   PASS: Step 2 theme analysis generated[0m
) else (
    echo  [91m   FAIL: Step 2 did not produce a theme analysis[0m
    echo          Check that Ollama is running
    pause
    exit /b 1
)
echo.
echo   Three bullets are now 2 clear themes.
echo   Press any key to feed them to the final step...
pause >nul
echo.

:: ============================================================
:: TASK 4: STEP 3 — CREATE
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/6] STEP 3 — CREATE
echo.
echo   Final station. The theme analysis from Step 2 goes to
echo   draft_create, which writes a one-paragraph personal
echo   mission statement. Direct, personal, actionable.
echo.
echo   This is the polished product at the end of the line.
echo.

:: Read step2 output and build the Step 3 prompt
python -c "import json, subprocess, sys; step2=open(r'%TEMP_DIR%\step2.txt').read().strip(); prompt='Write a one-paragraph personal mission statement based on these themes. Make it direct, personal, and actionable. Do not use generic platitudes. Here are the themes: '+step2; args=json.dumps({'prompt':prompt,'draft_type':'general'}); cmd=['python',r'%MCP_CALL%','draft_create',args]; result=subprocess.run(cmd,capture_output=True,text=True,timeout=120); open(r'%TEMP_DIR%\step3_raw.txt','w').write(result.stdout); d=json.loads(result.stdout); text=d.get('text',d.get('draft',d.get('content',d.get('response',str(d))))); open(r'%TEMP_DIR%\step3.txt','w').write(text); print(text[:600])" 2>nul > "%TEMP_DIR%\step3_display.txt"

:: Check if step 3 produced output
python -c "text=open(r'%TEMP_DIR%\step3.txt').read().strip(); exit(0 if len(text)>50 else 1)" 2>nul
if %errorlevel% EQU 0 (
    echo.
    echo   STEP 3 OUTPUT — MISSION STATEMENT:
    echo   ══════════════════════════════════════════════════
    type "%TEMP_DIR%\step3_display.txt"
    echo.
    echo   ══════════════════════════════════════════════════
    echo  [92m   PASS: Step 3 mission statement generated[0m
) else (
    echo  [91m   FAIL: Step 3 did not produce a mission statement[0m
    echo          Check that Ollama is running and draft_create is available
    pause
    exit /b 1
)
echo.
echo   Press any key to see the full chain side by side...
pause >nul
echo.

:: ============================================================
:: TASK 5: DISPLAY — Show the full chain
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 5/6] THE COMPLETE CHAIN — All 3 steps side by side
echo.
echo   Watch how raw content transforms at each station:
echo.
echo   ┌─────────────────────────────────────────────────┐
echo   │  STEP 1 — SUMMARY (raw content → 3 bullets)    │
echo   └─────────────────────────────────────────────────┘
echo.
type "%TEMP_DIR%\step1_display.txt"
echo.
echo.
echo   ┌─────────────────────────────────────────────────┐
echo   │  STEP 2 — ANALYSIS (3 bullets → 2 themes)      │
echo   └─────────────────────────────────────────────────┘
echo.
type "%TEMP_DIR%\step2_display.txt"
echo.
echo.
echo   ┌─────────────────────────────────────────────────┐
echo   │  STEP 3 — MISSION STATEMENT (themes → output)  │
echo   └─────────────────────────────────────────────────┘
echo.
type "%TEMP_DIR%\step3_display.txt"
echo.
echo.

:: ============================================================
:: TASK 6: Show how each step built on the last
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 6/6] HOW THE CHAIN WORKS
echo.
echo   Here's what just happened:
echo.
echo     RAW VAULT CONTENT (many documents, hundreds of words)
echo          │
echo          ▼
echo     STEP 1: chat_with_shanebrain
echo          "Summarize in 3 bullets"
echo          Output: 3 focused bullet points
echo          │
echo          ▼
echo     STEP 2: chat_with_shanebrain
echo          "Find 2 themes from these bullets"
echo          Output: 2 themes with explanations
echo          │
echo          ▼
echo     STEP 3: draft_create
echo          "Write a mission statement from these themes"
echo          Output: 1 polished paragraph
echo.
echo   Each step saw ONLY the output of the previous step.
echo   No step tried to do everything at once.
echo   That's why the final result is focused and personal.
echo.
echo   You just built a prompt chain. The same pattern works
echo   for research, writing, analysis — any task where
echo   breaking it into steps beats doing it all at once.
echo.

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   You built a 3-step prompt chain that turned raw vault
echo   content into a personal mission statement. Each step
echo   did one job and passed its output forward.
echo.
echo   This is how real AI pipelines work — not one giant
echo   prompt, but a series of focused steps that build on
echo   each other. You can extend this pattern to any task.
echo.
echo   Now run verify.bat to confirm everything passed:
echo.
echo       verify.bat
echo.

:: Cleanup temp files
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
