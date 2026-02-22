@echo off
setlocal enabledelayedexpansion
title Module 5.5 Exercise — Workshop in a Box

:: ============================================================
:: MODULE 5.5 EXERCISE: Workshop in a Box
:: Goal: Generate a workshop script + facilitator checklist,
::       store both as reusable teaching assets in vault
:: Time: ~20 minutes
:: Prerequisites: Module 5.4, Module 3.3
:: MCP Tools: draft_create, vault_add, vault_search, search_knowledge
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.5"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 5.5 EXERCISE: Workshop in a Box
echo  ══════════════════════════════════════════════════════
echo.
echo   You taught one person. Now you package that into a kit
echo   that lets you teach a whole room. One toolbox. Everything
echo   inside. Open it and go.
echo.
echo   Seven tasks. Twenty minutes. A workshop ready to run.
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
    pause
    exit /b 1
)
echo  [92m   PASS: MCP server responding[0m
echo.

:: ============================================================
:: TASK 1: Search knowledge for teaching entries from 5.4
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/7] Gather your teaching context
echo.
echo   Before you build a workshop, check what you already know
echo   about teaching. Module 5.4 stored teaching entries in your
echo   knowledge base. Let's see what's there.
echo.

echo   Searching knowledge base for: "teaching local AI"
python "%MCP_CALL%" search_knowledge "{\"query\":\"teaching local AI\"}" > "%TEMP_DIR%\teaching_context.txt" 2>&1

if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\teaching_context.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); print(str(count))" 2>nul > "%TEMP_DIR%\teach_count.txt"
    set /p TEACH_COUNT=<"%TEMP_DIR%\teach_count.txt"
    if not defined TEACH_COUNT set "TEACH_COUNT=0"
    if !TEACH_COUNT! GEQ 1 (
        echo  [92m   FOUND: !TEACH_COUNT! teaching knowledge entry(ies)[0m
        echo.
        echo   ══════════════════════════════════════════════════
        echo   TEACHING CONTEXT PREVIEW:
        echo   ══════════════════════════════════════════════════
        python -c "import json; d=json.load(open(r'%TEMP_DIR%\teaching_context.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[d])); [print('   - ' + str(r.get('title',r.get('content',str(r))))[:100]) for r in (results[:3] if isinstance(results,list) else [results])]" 2>nul
        echo.
        echo   ══════════════════════════════════════════════════
    ) else (
        echo  [93m   No teaching entries found — that's OK.[0m
        echo          The AI will still generate a workshop, but it won't
        echo          be personalized with your teaching experience.
        echo          For best results, complete Module 5.4 first.
    )
) else (
    echo  [93m   NOTE: Knowledge search completed. Workshop will use general context.[0m
)
echo.
echo   That's your teaching inventory. Now let's build the workshop.
echo.
echo   Press any key to generate the workshop script...
pause >nul
echo.

:: ============================================================
:: TASK 2: Generate the workshop script
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/7] Generate a 30-minute workshop script
echo.
echo   This is the main event. A complete, timed script for
echo   teaching 5 people how to install Ollama and run their
echo   first local AI query. Three sections. Two checkpoints.
echo   Everything a facilitator needs to walk in and teach.
echo.
echo   Generating workshop script...
echo   (This may take 30-60 seconds — the AI is searching your
echo    vault and composing a structured workshop plan)
echo.

python "%MCP_CALL%" draft_create "{\"prompt\":\"Write a 30-minute workshop script for teaching 5 people how to install Ollama and run their first local AI query. Include a materials list, 3 timed sections (10 min each), and 2 checkpoints where participants verify their setup works. Format with clear headings, timing marks, and what the facilitator should say or demonstrate at each step.\",\"draft_type\":\"general\",\"use_vault_context\":true}" > "%TEMP_DIR%\workshop_script.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Workshop script generated[0m
    echo.
    echo   ══════════════════════════════════════════════════
    echo   YOUR WORKSHOP SCRIPT:
    echo   ══════════════════════════════════════════════════
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\workshop_script.txt')); text=d.get('text',d.get('draft',d.get('content',str(d)))); print(text[:1500])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
    echo.
    echo   That's your workshop script. Read it through. Adjust
    echo   the timing if you need to. Add your own examples.
    echo   The structure is there — make it yours.
) else (
    echo  [91m   FAIL: Could not generate workshop script[0m
    echo          Check that Ollama is running for text generation.
)
echo.
echo   Press any key to store the workshop script...
pause >nul
echo.

:: ============================================================
:: TASK 3: Display the full workshop draft
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/7] Review the full workshop draft
echo.

python -c "import json; d=json.load(open(r'%TEMP_DIR%\workshop_script.txt')); text=d.get('text',d.get('draft',d.get('content',str(d)))); print(text)" 2>nul
echo.
echo   That's the complete script. Take a moment to review it.
echo.
echo   Press any key to store it in your vault...
pause >nul
echo.

:: ============================================================
:: TASK 4: Store workshop script in vault
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/7] Store the workshop script as a teaching asset
echo.
echo   Now we store this in your vault under the "teaching"
echo   category. Once stored, it's searchable and available
echo   as context for future drafts.
echo.

:: Read the draft content and store it
python -c "import json,subprocess,sys; d=json.load(open(r'%TEMP_DIR%\workshop_script.txt')); text=str(d.get('text',d.get('draft',d.get('content',str(d))))); payload=json.dumps({'content':text,'category':'teaching','title':'Local AI Workshop Script'}); f=open(r'%TEMP_DIR%\vault_payload.json','w'); f.write(payload); f.close()" 2>nul

:: Load the payload and call vault_add
python -c "import json,urllib.request; payload=json.load(open(r'%TEMP_DIR%\vault_payload.json')); print(json.dumps(payload))" 2>nul > "%TEMP_DIR%\vault_arg.txt"
set /p VAULT_ARG=<"%TEMP_DIR%\vault_arg.txt"

python "%MCP_CALL%" vault_add "%VAULT_ARG%" > "%TEMP_DIR%\vault_store1.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Workshop script stored in vault (category: teaching)[0m
) else (
    echo  [91m   FAIL: Could not store workshop script in vault[0m
    echo          Check MCP server is running on localhost:8100
)
echo.
echo   Press any key to generate the facilitator checklist...
pause >nul
echo.

:: ============================================================
:: TASK 5: Generate the facilitator checklist
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 5/7] Generate a facilitator checklist
echo.
echo   The workshop script tells you what to teach. The checklist
echo   tells you how to prepare and what to do when things go
echo   wrong. It's the safety net for go time.
echo.
echo   Generating facilitator checklist...
echo.

python "%MCP_CALL%" draft_create "{\"prompt\":\"Write a one-page facilitator checklist for running a local AI workshop. Include: pre-workshop setup steps (testing machines, installing prerequisites, downloading models ahead of time), materials needed (laptops, power strips, network access), common problems and solutions (Ollama won't install, model download fails, not enough RAM), and a post-workshop follow-up plan (resource links, practice exercises, group chat setup).\",\"draft_type\":\"general\",\"use_vault_context\":true}" > "%TEMP_DIR%\checklist.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Facilitator checklist generated[0m
    echo.
    echo   ══════════════════════════════════════════════════
    echo   YOUR FACILITATOR CHECKLIST:
    echo   ══════════════════════════════════════════════════
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\checklist.txt')); text=d.get('text',d.get('draft',d.get('content',str(d)))); print(text[:1500])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
) else (
    echo  [91m   FAIL: Could not generate facilitator checklist[0m
    echo          Check that Ollama is running for text generation.
)
echo.
echo   Press any key to store the checklist...
pause >nul
echo.

:: ============================================================
:: TASK 6: Store facilitator checklist in vault
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 6/7] Store the checklist as a teaching asset
echo.

python -c "import json; d=json.load(open(r'%TEMP_DIR%\checklist.txt')); text=str(d.get('text',d.get('draft',d.get('content',str(d))))); payload=json.dumps({'content':text,'category':'teaching','title':'Workshop Facilitator Checklist'}); f=open(r'%TEMP_DIR%\checklist_payload.json','w'); f.write(payload); f.close()" 2>nul

python -c "import json; payload=json.load(open(r'%TEMP_DIR%\checklist_payload.json')); print(json.dumps(payload))" 2>nul > "%TEMP_DIR%\checklist_arg.txt"
set /p CHECKLIST_ARG=<"%TEMP_DIR%\checklist_arg.txt"

python "%MCP_CALL%" vault_add "%CHECKLIST_ARG%" > "%TEMP_DIR%\vault_store2.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Facilitator checklist stored in vault (category: teaching)[0m
) else (
    echo  [91m   FAIL: Could not store checklist in vault[0m
    echo          Check MCP server is running on localhost:8100
)
echo.
echo   Press any key to verify everything stored correctly...
pause >nul
echo.

:: ============================================================
:: TASK 7: Verify both stored — search vault for "workshop"
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 7/7] Verify workshop assets are stored
echo.
echo   Searching vault for "workshop" to confirm both documents
echo   are stored and searchable.
echo.

python "%MCP_CALL%" vault_search "{\"query\":\"workshop\"}" > "%TEMP_DIR%\verify_search.txt" 2>&1

if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\verify_search.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); print(str(count))" 2>nul > "%TEMP_DIR%\verify_count.txt"
    set /p VERIFY_COUNT=<"%TEMP_DIR%\verify_count.txt"
    if not defined VERIFY_COUNT set "VERIFY_COUNT=0"
    if !VERIFY_COUNT! GEQ 2 (
        echo  [92m   PASS: Found !VERIFY_COUNT! workshop-related documents in vault[0m
        echo.
        echo   ══════════════════════════════════════════════════
        echo   STORED TEACHING ASSETS:
        echo   ══════════════════════════════════════════════════
        python -c "import json; d=json.load(open(r'%TEMP_DIR%\verify_search.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[d])); [print('   - ' + str(r.get('title',r.get('content',str(r))))[:100]) for r in (results[:5] if isinstance(results,list) else [results])]" 2>nul
        echo.
        echo   ══════════════════════════════════════════════════
    ) else if !VERIFY_COUNT! GEQ 1 (
        echo  [93m   PARTIAL: Found !VERIFY_COUNT! document(s). Expected 2.[0m
        echo          One of your assets may not have stored correctly.
    ) else (
        echo  [91m   FAIL: No workshop documents found in vault[0m
        echo          The vault_add calls may have failed. Check MCP server.
    )
) else (
    echo  [91m   FAIL: Could not search vault[0m
    echo          Check MCP server is running on localhost:8100
)
echo.

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   You just built a complete teaching kit:
echo     1. Gathered your teaching context from Module 5.4
echo     2. Generated a 30-minute workshop script
echo     3. Generated a facilitator checklist
echo     4. Stored both as reusable teaching assets
echo     5. Verified everything is searchable in your vault
echo.
echo   One toolbox. Everything inside. You can walk into any
echo   room, open the box, and teach 5 people local AI in
echo   30 minutes. That's the multiplier.
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
