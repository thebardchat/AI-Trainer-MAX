@echo off
setlocal enabledelayedexpansion
title Module 4.5 Exercise — Write Your Story

:: ============================================================
:: MODULE 4.5 EXERCISE: Write Your Story
:: Goal: Search vault for context, draft a letter to your kids,
::       draft a life story, draft a message to someone specific
:: Time: ~15 minutes
:: Prerequisites: Module 4.2 (vault docs for context)
:: MCP Tools: draft_create, vault_search
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.5"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 4.5 EXERCISE: Write Your Story
echo  ══════════════════════════════════════════════════════
echo.
echo   The letters your grandfather never wrote. The stories
echo   your great-grandmother took with her. Today you put
echo   your words down — and your brain helps you say it right.
echo.
echo   Four tasks. Fifteen minutes. Words that outlast you.
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

:: Check vault has documents (for context)
python "%MCP_CALL%" vault_list_categories > "%TEMP_DIR%\categories.txt" 2>&1
python -c "import json; d=json.load(open(r'%TEMP_DIR%\categories.txt')); total=sum(v for v in d.values() if isinstance(v,int)) if isinstance(d,dict) else len(d) if isinstance(d,list) else 0; print(total)" 2>nul > "%TEMP_DIR%\count.txt"
set /p VAULT_COUNT=<"%TEMP_DIR%\count.txt"
if not defined VAULT_COUNT set "VAULT_COUNT=0"

if %VAULT_COUNT% GEQ 1 (
    echo  [92m   PASS: Vault has %VAULT_COUNT% document(s) for context[0m
) else (
    echo  [93m   NOTE: Vault is empty. Drafts will work but won't pull personal context.[0m
    echo          For best results, run Module 4.2 first to feed your brain.
)
echo.

:: ============================================================
:: TASK 1: Search vault for family context
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/4] Search your vault — see what your brain knows
echo.
echo   Before you write, check what's there. This is like
echo   opening the family photo album before sitting down to
echo   write a letter. You need to see the raw material.
echo.

echo   Searching vault for: "family children values"
python "%MCP_CALL%" vault_search "{\"query\":\"family children values\"}" > "%TEMP_DIR%\vault_family.txt" 2>&1

if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault_family.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); print(str(count))" 2>nul > "%TEMP_DIR%\family_count.txt"
    set /p FAMILY_COUNT=<"%TEMP_DIR%\family_count.txt"
    if not defined FAMILY_COUNT set "FAMILY_COUNT=0"
    if !FAMILY_COUNT! GEQ 1 (
        echo  [92m   FOUND: !FAMILY_COUNT! document(s) about family[0m
        echo.
        echo   ══════════════════════════════════════════════════
        echo   VAULT CONTEXT PREVIEW:
        echo   ══════════════════════════════════════════════════
        python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault_family.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[d])); [print('   - ' + str(r.get('title',r.get('content',str(r))))[:100]) for r in (results[:3] if isinstance(results,list) else [results])]" 2>nul
        echo.
        echo   ══════════════════════════════════════════════════
    ) else (
        echo  [93m   No family documents found — that's OK.[0m
        echo          The AI will still draft, but with less personal detail.
    )
) else (
    echo  [93m   NOTE: Vault search returned no results. Drafts will be more generic.[0m
)
echo.

echo   Searching vault for: "work faith journey"
python "%MCP_CALL%" vault_search "{\"query\":\"work faith journey\"}" > "%TEMP_DIR%\vault_faith.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault_faith.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[])); count=len(results) if isinstance(results,list) else (1 if results else 0); print(str(count))" 2>nul > "%TEMP_DIR%\faith_count.txt"
    set /p FAITH_COUNT=<"%TEMP_DIR%\faith_count.txt"
    if not defined FAITH_COUNT set "FAITH_COUNT=0"
    if !FAITH_COUNT! GEQ 1 (
        echo  [92m   FOUND: !FAITH_COUNT! document(s) about work and faith[0m
    ) else (
        echo  [93m   No work/faith documents found.[0m
    )
) else (
    echo  [93m   NOTE: Vault search completed.[0m
)
echo.
echo   That's your context inventory. The more you've stored,
echo   the more personal your letters will be.
echo.
echo   Press any key to write a letter to your kids...
pause >nul
echo.

:: ============================================================
:: TASK 2: Draft a letter to your children
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/4] Write a letter to your children
echo.
echo   This is the one that matters. A letter from you to
echo   the people who carry your name forward. The AI will
echo   search your vault and use what it finds to make this
echo   personal — not a template, but YOUR words shaped up.
echo.
echo   Prompt: "Write a heartfelt letter to my children about
echo   the values I want them to carry forward — hard work,
echo   faith, taking care of family, and never giving up.
echo   Include any personal details from my life and story."
echo.

echo   Generating your letter...
echo   (This may take 30-60 seconds — the AI is searching
echo    your vault and composing from your own words)
echo.

python "%MCP_CALL%" draft_create "{\"prompt\":\"Write a heartfelt letter to my children about the values I want them to carry forward — hard work, faith, taking care of family, and never giving up. Include any personal details from my life and story. This letter is meant to be kept and read years from now.\",\"draft_type\":\"letter\",\"use_vault_context\":true}" > "%TEMP_DIR%\letter_kids.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Letter to your children generated[0m
    echo.
    echo   ══════════════════════════════════════════════════
    echo   YOUR LETTER TO YOUR CHILDREN:
    echo   ══════════════════════════════════════════════════
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\letter_kids.txt')); text=d.get('text',d.get('draft',d.get('content',str(d)))); print(text[:1200])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
    echo.
    echo   Read that. Fix what's wrong. Add what's missing.
    echo   The AI gave you a starting point — make it yours.
) else (
    echo  [91m   FAIL: Could not generate letter[0m
    echo          Check that Ollama is running for text generation
)
echo.
echo   Press any key to write your life story...
pause >nul
echo.

:: ============================================================
:: TASK 3: Draft a life story
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/4] Write a short life story
echo.
echo   This pulls from everything in your vault — daily notes,
echo   documents, knowledge entries. The AI organizes your
echo   scattered pieces into a narrative. Think of it as a
echo   rough draft of the story you'd tell at the family table.
echo.

echo   Generating life story draft...
echo.

python "%MCP_CALL%" draft_create "{\"prompt\":\"Write a short life story about my journey — the work I've done, the family I've built, the faith that carried me through hard times, and the legacy I'm trying to leave behind. Pull from everything you know about me. Write it in first person as if I'm telling my story to my grandchildren.\",\"draft_type\":\"general\",\"use_vault_context\":true}" > "%TEMP_DIR%\life_story.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Life story draft generated[0m
    echo.
    echo   ══════════════════════════════════════════════════
    echo   YOUR LIFE STORY (DRAFT):
    echo   ══════════════════════════════════════════════════
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\life_story.txt')); text=d.get('text',d.get('draft',d.get('content',str(d)))); print(text[:1200])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
    echo.
    echo   That's a first draft pulled from YOUR vault data.
    echo   The more you've stored, the more detail it includes.
    echo   Save it. Edit it. Run it again with different prompts.
) else (
    echo  [91m   FAIL: Could not generate life story draft[0m
    echo          Check that Ollama is running for text generation
)
echo.
echo   Press any key to write a message to someone specific...
pause >nul
echo.

:: ============================================================
:: TASK 4: Draft a message to a specific person
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/4] Write a message to someone who matters
echo.
echo   A short message to a specific person. This could be
echo   a friend who stood by you, a mentor who shaped you,
echo   or someone you never thanked properly. The AI keeps
echo   it brief and real — message style, not formal.
echo.

echo   Generating personal message...
echo.

python "%MCP_CALL%" draft_create "{\"prompt\":\"Write a short personal message to a close friend or family member thanking them for standing by me during difficult times. Mention specific things from my life if you can find them. Keep it brief and genuine — like a text message from the heart.\",\"draft_type\":\"message\",\"use_vault_context\":true}" > "%TEMP_DIR%\message_person.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Personal message generated[0m
    echo.
    echo   ══════════════════════════════════════════════════
    echo   YOUR PERSONAL MESSAGE:
    echo   ══════════════════════════════════════════════════
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\message_person.txt')); text=d.get('text',d.get('draft',d.get('content',str(d)))); print(text[:600])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
    echo.
    echo   Short. Real. From the heart. That's the power of
    echo   vault context in a message — it's not a greeting
    echo   card, it's something only YOU could have written.
) else (
    echo  [91m   FAIL: Could not generate personal message[0m
)
echo.

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   You just wrote three things most people never get around to:
echo     1. A letter to your children
echo     2. A draft of your life story
echo     3. A message to someone who matters
echo.
echo   These aren't finished products — they're starting points.
echo   Read them. Edit them. Make them yours. Then store the
echo   final versions back in your vault for safekeeping.
echo.
echo   Your brain helped you find the words. The words are yours.
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
