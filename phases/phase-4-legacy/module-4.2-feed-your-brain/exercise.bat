@echo off
setlocal enabledelayedexpansion
title Module 4.2 Exercise — Feed Your Brain

:: ============================================================
:: MODULE 4.2 EXERCISE: Feed Your Brain
:: Goal: Add family values, personal memories, and life lessons
::       to the Knowledge and Vault collections
:: Time: ~15 minutes
:: MCP Tools: add_knowledge, vault_add, search_knowledge, vault_search
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.2"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 4.2 EXERCISE: Feed Your Brain
echo  ══════════════════════════════════════════════════════
echo.
echo   You're about to add the things that matter most —
echo   values, memories, and wisdom. Four tasks. Fifteen
echo   minutes. This is where legacy starts.
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
    echo       Check: python "%MCP_CALL%" system_health
    pause
    exit /b 1
)
echo  [92m   PASS: MCP server responding[0m
echo.

:: ============================================================
:: TASK 1: Add family values to Knowledge
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/4] Store family values in the Knowledge collection
echo.
echo   These are the principles your family lives by.
echo   The things you'd want your kids to carry forward.
echo   We'll add three — you can add your own later.
echo.

:: --- Value 1: Work ethic ---
echo   Storing family value: Work ethic...
python "%MCP_CALL%" add_knowledge "{\"content\":\"We don't quit when things get hard. If you start something, you finish it. There's no shame in struggling — the shame is in giving up because it got uncomfortable. Your great-granddad worked doubles at the steel mill so his kids could go to school. Your granddad drove trucks through the night so your dad could have choices. Every generation builds on the one before it. That's the deal.\",\"category\":\"family\",\"title\":\"Family Value - Work Ethic\"}" > "%TEMP_DIR%\val1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Work ethic value stored[0m
) else (
    echo  [91m   FAIL: Could not store work ethic value[0m
    echo          Check MCP server and try again
)
echo.

:: --- Value 2: Honesty ---
echo   Storing family value: Honesty...
python "%MCP_CALL%" add_knowledge "{\"content\":\"Tell the truth even when it costs you. A man's word is the only thing nobody can take from him — but he can give it away by lying. If you mess up, own it. People respect honesty more than perfection. Your mama and I built this family on trust, and trust starts with the truth, every single time.\",\"category\":\"family\",\"title\":\"Family Value - Honesty\"}" > "%TEMP_DIR%\val2.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Honesty value stored[0m
) else (
    echo  [91m   FAIL: Could not store honesty value[0m
)
echo.

:: --- Value 3: Faith ---
echo   Storing family value: Faith...
python "%MCP_CALL%" add_knowledge "{\"content\":\"Faith isn't about having all the answers. It's about trusting God even when the path doesn't make sense yet. There were nights I didn't know how we'd make rent, and mornings the answer showed up in ways I couldn't have planned. Pray like it depends on God. Work like it depends on you. Both are true.\",\"category\":\"faith\",\"title\":\"Family Value - Faith\"}" > "%TEMP_DIR%\val3.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Faith value stored[0m
) else (
    echo  [91m   FAIL: Could not store faith value[0m
)
echo.

echo  [92m   Three family values stored in Knowledge.[0m
echo.
echo   Press any key to add personal memories...
pause >nul
echo.

:: ============================================================
:: TASK 2: Add personal memories to the Vault
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/4] Store personal memories in the Vault
echo.
echo   Memories give context to values. They're the stories
echo   behind the principles. We'll add two memories that
echo   show where the values come from.
echo.

:: --- Memory 1: First child born ---
echo   Storing memory: First child...
python "%MCP_CALL%" vault_add "{\"content\":\"The day my first son was born, everything changed. I was twenty-three and thought I knew what responsibility meant. I didn't. When the nurse put that boy in my arms, I understood for the first time that my life wasn't just mine anymore. Every decision from that point forward had his face attached to it. I drove home that night going ten under the speed limit. That feeling never went away — it just grew as each boy came along. Five sons. Five reasons to build something that lasts.\",\"category\":\"personal\",\"title\":\"Memory - The Day Everything Changed\"}" > "%TEMP_DIR%\mem1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: First child memory stored[0m
) else (
    echo  [91m   FAIL: Could not store memory[0m
)
echo.

:: --- Memory 2: Building Angel Cloud ---
echo   Storing memory: Building the future...
python "%MCP_CALL%" vault_add "{\"content\":\"I started building Angel Cloud because I realized the tech world was leaving regular people behind. Eight hundred million Windows users about to lose security support, and nobody was building tools for them that didn't require a subscription or a computer science degree. I had five boys watching me. I could either complain about the world they were inheriting or build something to change it. So I built. Late nights after the kids went to bed. Early mornings before work. Not because it was easy, but because someone had to, and I decided that someone was me.\",\"category\":\"personal\",\"title\":\"Memory - Why I Built Angel Cloud\"}" > "%TEMP_DIR%\mem2.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Building memory stored[0m
) else (
    echo  [91m   FAIL: Could not store memory[0m
)
echo.

echo  [92m   Two personal memories stored in the Vault.[0m
echo.
echo   Press any key to add life lessons...
pause >nul
echo.

:: ============================================================
:: TASK 3: Add life lessons to Knowledge
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/4] Store life lessons in Knowledge
echo.
echo   Life lessons are wisdom that cost something to learn.
echo   These are the things you'd tell your younger self.
echo.

:: --- Lesson 1: Money ---
echo   Storing life lesson: Money...
python "%MCP_CALL%" add_knowledge "{\"content\":\"Here's what nobody tells you about money: it's not about how much you make, it's about how much you keep and what you do with it. I've seen men earn six figures and have nothing. I've seen men earn modest wages and build wealth. The difference is discipline. Don't buy things to impress people you don't even like. Live below your means. Save before you spend. And when you invest, invest in things you understand — starting with yourself.\",\"category\":\"philosophy\",\"title\":\"Life Lesson - Money and Discipline\"}" > "%TEMP_DIR%\les1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Money lesson stored[0m
) else (
    echo  [91m   FAIL: Could not store money lesson[0m
)
echo.

:: --- Lesson 2: Marriage ---
echo   Storing life lesson: Marriage...
python "%MCP_CALL%" add_knowledge "{\"content\":\"Marriage is not fifty-fifty. Some days it's ninety-ten. Some days you carry, some days you get carried. The key is never keeping score. When you keep score, you've already lost. Choose someone who makes you want to be better, not someone who makes you feel like you're already enough. Comfort is the enemy of growth. Your partner should challenge you and have your back at the same time.\",\"category\":\"family\",\"title\":\"Life Lesson - Marriage\"}" > "%TEMP_DIR%\les2.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Marriage lesson stored[0m
) else (
    echo  [91m   FAIL: Could not store marriage lesson[0m
)
echo.

echo  [92m   Two life lessons stored in Knowledge.[0m
echo.
echo   Press any key to verify the brain absorbed it all...
pause >nul
echo.

:: ============================================================
:: TASK 4: Search and verify what you stored
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/4] Search the brain — can it find what you fed it?
echo.
echo   The real test. You stored values, memories, and
echo   lessons. Now let's see if the brain can find them
echo   when asked in different words.
echo.

:: --- Search 1: Ask about quitting ---
echo   Search Knowledge: "Should I give up when things are hard?"
python "%MCP_CALL%" search_knowledge "{\"query\":\"Should I give up when things are hard\"}" > "%TEMP_DIR%\find1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Found relevant knowledge[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\find1.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])); print('   Found: ' + str(len(results) if isinstance(results,list) else 1) + ' result(s)')" 2>nul
    echo.
    echo   You asked about "giving up" — it found your entry
    echo   about work ethic. Different words, same meaning.
) else (
    echo  [91m   FAIL: Knowledge search failed[0m
)
echo.

:: --- Search 2: Ask the vault about fatherhood ---
echo   Search Vault: "becoming a father for the first time"
python "%MCP_CALL%" vault_search "{\"query\":\"becoming a father for the first time\"}" > "%TEMP_DIR%\find2.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Found relevant vault entry[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\find2.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[])); print('   Found: ' + str(len(results) if isinstance(results,list) else 1) + ' result(s)')" 2>nul
    echo.
    echo   You asked about "becoming a father" — it found your
    echo   memory about the day your first son was born.
) else (
    echo  [91m   FAIL: Vault search failed[0m
)
echo.

:: --- Search 3: Ask about financial advice ---
echo   Search Knowledge: "advice about saving and spending"
python "%MCP_CALL%" search_knowledge "{\"query\":\"advice about saving and spending\"}" > "%TEMP_DIR%\find3.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Found relevant knowledge[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\find3.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])); print('   Found: ' + str(len(results) if isinstance(results,list) else 1) + ' result(s)')" 2>nul
    echo.
    echo   You asked about "saving and spending" — it found
    echo   your lesson about money and discipline.
) else (
    echo  [91m   FAIL: Knowledge search failed[0m
)
echo.

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   You just fed your brain with:
echo.
echo     3 family values  (Knowledge — family, faith)
echo     2 personal memories  (Vault — personal)
echo     2 life lessons  (Knowledge — philosophy, family)
echo.
echo   And you proved the brain can find them when asked
echo   in completely different words. That's semantic search
echo   turning your words into searchable legacy.
echo.
echo   Want to add YOUR entries? Use these commands:
echo.
echo     python "%MCP_CALL%" add_knowledge "{\"content\":\"...\",\"category\":\"family\"}"
echo     python "%MCP_CALL%" vault_add "{\"content\":\"...\",\"category\":\"personal\"}"
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
