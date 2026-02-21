@echo off
setlocal enabledelayedexpansion
title Module 4.4 Exercise — Your Daily Companion

:: ============================================================
:: MODULE 4.4 EXERCISE: Your Daily Companion
:: Goal: Build a journaling habit — add journal entry with mood,
::       add reflection, add todo, search notes, generate briefing
:: Time: ~15 minutes
:: Prerequisites: MCP server running (Modules 4.1-4.3 recommended)
:: MCP Tools: daily_note_add, daily_note_search, daily_briefing
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.4"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 4.4 EXERCISE: Your Daily Companion
echo  ══════════════════════════════════════════════════════
echo.
echo   This is the module where your brain becomes a habit.
echo   Not a project. Not a tool. A companion. Something you
echo   sit down with for five minutes a day and tell the truth.
echo.
echo   Like sitting on the porch at the end of the day.
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
:: TASK 1: Add a Journal Entry with Mood Tag
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/5] Add a Journal Entry with Mood
echo.
echo   A journal entry captures the day. Not the highlight
echo   reel — the real version. The one where you got the
echo   kids fed and the work done and maybe had a minute
echo   to yourself. That's worth recording.
echo.
echo   This entry carries a mood tag: "grateful"
echo.

python "%MCP_CALL%" daily_note_add "{\"content\":\"Long day but a good one. Got the boys to their practices on time, finished the project estimate I have been putting off, and sat on the porch for ten minutes before bed. Sometimes the small wins are the ones that matter. The family is healthy, the bills are paid, and tomorrow is a new shot at it.\",\"note_type\":\"journal\",\"mood\":\"grateful\"}" > "%TEMP_DIR%\journal_result.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Journal entry added — mood: grateful[0m
    echo.
    echo   Your entry is stored, embedded, and searchable.
    echo   Fifty years from now, someone can search "what was
    echo   he grateful for?" and find this moment.
) else (
    echo  [91m   FAIL: Could not add journal entry[0m
    echo     Check hints.md for troubleshooting.
)
echo.
echo   Press any key to continue...
pause >nul
echo.

:: ============================================================
:: TASK 2: Add a Reflection
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/5] Add a Reflection
echo.
echo   Reflections are the deeper thoughts. Not what happened
echo   today, but what it means. The lessons you're learning.
echo   The things you'd tell yourself ten years ago if you
echo   could. This is the porch conversation that matters most.
echo.

python "%MCP_CALL%" daily_note_add "{\"content\":\"Been thinking about what I want my boys to remember about these years. Not the hard work — they will see that. I want them to remember that I was present. That when they talked, I listened. That I chose dinner at the table over overtime when it mattered. You cannot get the years back. The money comes and goes but the time with your kids only flows one direction.\",\"note_type\":\"reflection\",\"mood\":\"focused\"}" > "%TEMP_DIR%\reflection_result.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Reflection added — mood: focused[0m
    echo.
    echo   That reflection is now part of your legacy. When your
    echo   grandkids read it, they'll know what you were thinking
    echo   about during these years. Not just what you were doing.
) else (
    echo  [91m   FAIL: Could not add reflection[0m
    echo     Check hints.md for troubleshooting.
)
echo.
echo   Press any key to continue...
pause >nul
echo.

:: ============================================================
:: TASK 3: Add a Todo
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/5] Add a Todo
echo.
echo   Todos are the practical side. Things that need doing.
echo   Your AI stores them and includes them in your daily
echo   briefing. Like writing on the job board before you
echo   leave the shop — except this board never gets erased.
echo.

python "%MCP_CALL%" daily_note_add "{\"content\":\"Schedule the boys annual checkups before the end of the month. Call Dr. Williams office in the morning — they book up fast in spring. Also need to update the emergency contact list at the school since we changed phone numbers.\",\"note_type\":\"todo\"}" > "%TEMP_DIR%\todo_result.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Todo added[0m
    echo.
    echo   Your AI will remember this even when you're buried
    echo   in work tomorrow. That's the point.
) else (
    echo  [91m   FAIL: Could not add todo[0m
    echo     Check hints.md for troubleshooting.
)
echo.
echo   Press any key to continue...
pause >nul
echo.

:: ============================================================
:: TASK 4: Search Your Notes
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/5] Search Your Notes — Find What You Wrote
echo.
echo   Now let's prove the search works. We'll look for notes
echo   about family — even though you may not have used that
echo   exact word in every entry. Semantic search finds meaning,
echo   not just keywords.
echo.

echo   Searching for: "family and kids"
echo.
python "%MCP_CALL%" daily_note_search "{\"query\":\"family and kids\"}" > "%TEMP_DIR%\search_result.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Note search returned results[0m
    echo.
    echo   Notes found:
    echo   ──────────────────────────────────────────────────
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search_result.txt')); results=d.get('results',d.get('notes',d)) if isinstance(d,dict) else d; [print('   [' + str(r.get('note_type','note')) + '] ' + str(r.get('content',''))[:80]) for r in (results[:5] if isinstance(results,list) else [results])]" 2>nul
    echo   ──────────────────────────────────────────────────
) else (
    echo  [91m   FAIL: Note search failed[0m
    echo     Check hints.md for troubleshooting.
)
echo.

echo   Now searching for: "things I need to do"
echo.
python "%MCP_CALL%" daily_note_search "{\"query\":\"things I need to do\",\"note_type\":\"todo\"}" > "%TEMP_DIR%\search_todo.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Todo search returned results[0m
    echo.
    echo   Todos found:
    echo   ──────────────────────────────────────────────────
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search_todo.txt')); results=d.get('results',d.get('notes',d)) if isinstance(d,dict) else d; [print('   - ' + str(r.get('content',''))[:80]) for r in (results[:5] if isinstance(results,list) else [results])]" 2>nul
    echo   ──────────────────────────────────────────────────
) else (
    echo  [93m   WARN: Todo search returned no results (may need more entries)[0m
)
echo.
echo   Press any key to generate your daily briefing...
pause >nul
echo.

:: ============================================================
:: TASK 5: Generate Your Daily Briefing
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 5/5] Generate Your Daily Briefing
echo.
echo   Now the payoff. Your AI reads everything you just
echo   wrote — the journal, the reflection, the todo — and
echo   pulls it all together into a briefing. Like a foreman
echo   reading the board and giving you the morning rundown.
echo.
echo   This calls Ollama, so give it a moment...
echo.

python "%MCP_CALL%" daily_briefing > "%TEMP_DIR%\briefing_result.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Daily briefing generated[0m
    echo.
    echo   ══════════════════════════════════════════════════
    echo   YOUR DAILY BRIEFING
    echo   ══════════════════════════════════════════════════
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\briefing_result.txt')); text=d.get('briefing',d.get('text',d.get('response',str(d)))); print(text[:1200])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
    echo.
    echo   That briefing was written from YOUR notes. Your day,
    echo   your priorities, your reflections — summarized by an
    echo   AI that works for you and nobody else.
) else (
    echo  [91m   FAIL: Could not generate briefing[0m
    echo     Ollama may need time to load. Try again in 30 seconds.
    echo     Check hints.md for troubleshooting.
)
echo.

:: ============================================================
:: EXERCISE COMPLETE
:: ============================================================
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   You just:
echo     1. Logged a journal entry with a mood tag
echo     2. Wrote a reflection about what matters to you
echo     3. Added a todo your AI will remember
echo     4. Searched your notes by meaning
echo     5. Got an AI-generated daily briefing
echo.
echo   That took about ten minutes. Tomorrow it'll take five.
echo   The day after that, three. And every entry you add makes
echo   the briefing smarter, the searches richer, and the
echo   record of your life more complete.
echo.
echo   This is the porch conversation that never gets lost.
echo   Your grandkids will read these entries and know you —
echo   not as a name on a family tree, but as a person who
echo   showed up every day and did the work.
echo.
echo   Now run verify.bat to confirm everything stuck:
echo.
echo       verify.bat
echo.

:: Cleanup temp files
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
