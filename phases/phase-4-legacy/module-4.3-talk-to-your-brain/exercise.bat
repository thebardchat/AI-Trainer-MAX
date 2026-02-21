@echo off
setlocal enabledelayedexpansion
title Module 4.3 Exercise — Talk to Your Brain

:: ============================================================
:: MODULE 4.3 EXERCISE: Talk to Your Brain
:: Goal: First real conversation with your AI brain — ask about
::       family, values, work. See RAG search + generate in action.
:: Time: ~15 minutes
:: Prerequisites: Module 4.2 (brain must have knowledge entries)
:: MCP Tools: chat_with_shanebrain, search_knowledge
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.3"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 4.3 EXERCISE: Talk to Your Brain
echo  ══════════════════════════════════════════════════════
echo.
echo   You fed your brain in Module 4.2. Now it's time to
echo   sit down and have a conversation with it. Ask about
echo   your life, your family, your values — and listen to
echo   what comes back. Your words, through your AI's voice.
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

:: Check knowledge base has entries (prerequisite from 4.2)
python "%MCP_CALL%" search_knowledge "{\"query\":\"family values life\"}" > "%TEMP_DIR%\kb_check.txt" 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   X Knowledge base appears empty. Run Module 4.2 first.[0m
    echo     Your brain needs knowledge entries before you can talk to it.
    pause
    exit /b 1
)
echo  [92m   PASS: Knowledge base has entries[0m
echo.

:: ============================================================
:: TASK 1: Search your knowledge base — see what the brain knows
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/4] Search your knowledge — see what the brain finds
echo.
echo   Before asking a full question, let's peek behind the
echo   curtain. This is the RETRIEVAL step of RAG — the brain
echo   searches for documents that match a topic.
echo.
echo   Think of it like pulling files from a cabinet before
echo   writing a report. The brain reads these files, then
echo   builds its answer from what it found.
echo.

echo   Searching knowledge base for: "family and values"
echo.
python "%MCP_CALL%" search_knowledge "{\"query\":\"family and values\"}" > "%TEMP_DIR%\search1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Knowledge search returned results[0m
    echo.
    echo   What your brain found (raw search results):
    echo   ──────────────────────────────────────────────────
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search1.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[d])); [print('   - ' + str(r.get('title',r.get('content','')[:80]))) for r in (results[:5] if isinstance(results,list) else [results])]" 2>nul
    echo   ──────────────────────────────────────────────────
) else (
    echo  [91m   FAIL: Knowledge search failed[0m
    echo          Make sure Module 4.2 completed successfully
)
echo.
echo   Those are the documents the brain pulls when you ask
echo   about family values. Next, watch it turn those raw
echo   documents into a real, conversational answer.
echo.
echo   Press any key to ask your brain a question...
pause >nul
echo.

:: ============================================================
:: TASK 2: Ask your brain about family
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/4] Ask your brain: "What matters most to my family?"
echo.
echo   Same source documents. But now the AI reads them and
echo   speaks back to you — not as a search engine, but as
echo   something that understands your story.
echo.

echo   Thinking...
echo.
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"What matters most to my family? What are the core values I want to pass down?\"}" > "%TEMP_DIR%\chat1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Your brain responded[0m
    echo.
    echo   Your Brain Says:
    echo   ══════════════════════════════════════════════════
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat1.txt')); text=d.get('text',d.get('response',str(d))); print('   ' + text[:600])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
    echo.
    echo   Notice how that answer came from YOUR words, YOUR
    echo   knowledge entries — not some generic internet response.
) else (
    echo  [91m   FAIL: chat_with_shanebrain did not respond[0m
    echo          Check that Ollama is running for answer generation
)
echo.
echo   Press any key to ask about work and purpose...
pause >nul
echo.

:: ============================================================
:: TASK 3: Ask your brain about work and purpose
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/4] Ask your brain: "What have I learned about hard work?"
echo.
echo   This tests whether your brain can pull from different
echo   knowledge areas and weave them together. Like asking
echo   a grandparent to tell you what they learned over a
echo   lifetime of building things.
echo.

echo   Thinking...
echo.
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"What have I learned about hard work? What would I tell my sons about building something that lasts?\"}" > "%TEMP_DIR%\chat2.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Your brain responded[0m
    echo.
    echo   Your Brain Says:
    echo   ══════════════════════════════════════════════════
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat2.txt')); text=d.get('text',d.get('response',str(d))); print('   ' + text[:600])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
) else (
    echo  [91m   FAIL: chat_with_shanebrain did not respond[0m
    echo          Check that Ollama is running
)
echo.
echo   Press any key for the interactive conversation...
pause >nul
echo.

:: ============================================================
:: TASK 4: Interactive conversation — ask anything
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/4] Your turn — talk to your brain
echo.
echo   Type any question. Your brain will search its knowledge
echo   and give you an answer grounded in your own words.
echo.
echo   Try questions like:
echo     - "What kind of person am I?"
echo     - "What should my grandkids know about our family?"
echo     - "What's the hardest lesson I ever learned?"
echo     - "What do I believe about faith?"
echo     - "What would I say to my sons on their wedding day?"
echo.
echo   This is your legacy speaking. Ask it anything.
echo.

:qa_loop
echo  ──────────────────────────────────────────────────────
set /p "USER_QUESTION=  Your question (or Q to quit): "

if /i "%USER_QUESTION%"=="Q" goto exercise_done
if "%USER_QUESTION%"=="" goto qa_loop

echo.
echo   [Step 1/2] Searching your knowledge base...
python "%MCP_CALL%" search_knowledge "{\"query\":\"%USER_QUESTION%\"}" > "%TEMP_DIR%\qa_search.txt" 2>&1

echo   [Step 2/2] Generating answer from your knowledge...
echo.
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"%USER_QUESTION%\"}" > "%TEMP_DIR%\qa_answer.txt" 2>&1

if %errorlevel% EQU 0 (
    echo   ══════════════════════════════════════════════════
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\qa_answer.txt')); text=d.get('text',d.get('response',str(d))); print('   ' + text[:600])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
    echo  [92m   Answer generated from your knowledge base[0m
) else (
    echo  [91m   Could not generate answer. Check services.[0m
)
echo.
goto qa_loop

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   You just had a conversation with your own AI brain.
echo   Not a chatbot that knows everything about nothing.
echo   A brain that knows YOUR life, YOUR values, YOUR story.
echo.
echo   Every answer came from knowledge you stored. The more
echo   you feed it, the deeper the conversations get. Like
echo   building a house — the more rooms you add, the more
echo   there is to explore.
echo.
echo   Fifty years from now, your grandkids can sit down and
echo   ask this brain: "What was Grandpa really like?" And
echo   it'll answer in your words. That's legacy.
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
