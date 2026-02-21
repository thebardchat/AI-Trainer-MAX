@echo off
setlocal enabledelayedexpansion
title Module 4.1 Exercise — What Is a Brain?

:: ============================================================
:: MODULE 4.1 EXERCISE: What Is a Brain?
:: Goal: Explore ShaneBrain infrastructure, search knowledge,
::       understand collections that make up a digital brain
:: Time: ~15 minutes
:: MCP Tools: system_health, search_knowledge
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.1"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 4.1 EXERCISE: What Is a Brain?
echo  ══════════════════════════════════════════════════════
echo.
echo   You're about to walk through a living AI brain.
echo   Three tasks. Fifteen minutes. Nothing gets changed —
echo   you're just looking around the house.
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
:: TASK 1: Check the brain's vital signs
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/3] Check the brain's vital signs
echo.
echo   Every brain runs on infrastructure — an LLM for
echo   thinking, a vector database for memory, and an MCP
echo   server for communication. Let's see what's running.
echo.

echo   Running system_health...
echo.
python "%MCP_CALL%" system_health > "%TEMP_DIR%\health_full.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: System health retrieved[0m
    echo.
    echo   Brain Infrastructure Status:
    echo   ────────────────────────────
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\health_full.txt')); [print('   ' + str(k) + ': ' + str(v)) for k,v in d.items() if not isinstance(v,dict)]" 2>nul
    echo.
    echo   Collection Counts (the rooms in the house):
    echo   ────────────────────────────────────────────
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\health_full.txt')); cols=d.get('collections',d.get('collection_counts',{})); [print('   ' + str(k) + ': ' + str(v) + ' objects') for k,v in cols.items()] if isinstance(cols,dict) else print('   ' + str(cols))" 2>nul
) else (
    echo  [91m   FAIL: Could not retrieve system health[0m
    echo          Check that ShaneBrain MCP server is running
)
echo.

echo   That's the foundation. Every number above represents
echo   something real — knowledge entries, personal documents,
echo   daily journal notes, security logs.
echo.
echo   Press any key to search the brain's knowledge...
pause >nul
echo.

:: ============================================================
:: TASK 2: Search what the brain knows
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/3] Search the brain's knowledge
echo.
echo   A brain isn't useful if you can't ask it questions.
echo   Let's search ShaneBrain's knowledge base on three
echo   different topics and see what comes back.
echo.

:: --- Search 1: Family ---
echo   Search: "family values and fatherhood"
python "%MCP_CALL%" search_knowledge "{\"query\":\"family values and fatherhood\"}" > "%TEMP_DIR%\search1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Knowledge search returned results[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search1.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])); print('   Found: ' + str(len(results) if isinstance(results,list) else 1) + ' result(s)')" 2>nul
) else (
    echo  [93m   NOTE: No results for this query — that's OK if the brain is new[0m
)
echo.

:: --- Search 2: Faith ---
echo   Search: "faith and purpose"
python "%MCP_CALL%" search_knowledge "{\"query\":\"faith and purpose\"}" > "%TEMP_DIR%\search2.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Knowledge search returned results[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search2.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])); print('   Found: ' + str(len(results) if isinstance(results,list) else 1) + ' result(s)')" 2>nul
) else (
    echo  [93m   NOTE: No results for this query[0m
)
echo.

:: --- Search 3: Technical ---
echo   Search: "building local AI systems"
python "%MCP_CALL%" search_knowledge "{\"query\":\"building local AI systems\"}" > "%TEMP_DIR%\search3.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Knowledge search returned results[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search3.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])); print('   Found: ' + str(len(results) if isinstance(results,list) else 1) + ' result(s)')" 2>nul
    echo.
    echo   Notice: Three different topics — family, faith, technology.
    echo   The brain found relevant entries for each one because
    echo   it searches by MEANING, not keywords.
) else (
    echo  [93m   NOTE: No results for this query[0m
)
echo.

echo   Press any key to explore the collections...
pause >nul
echo.

:: ============================================================
:: TASK 3: Explore the collections
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/3] Understand the brain's collections
echo.
echo   A brain is organized into collections — like rooms in
echo   a house. Each room has a purpose. Let's see them.
echo.

echo   Retrieving collection details...
echo.
python "%MCP_CALL%" system_health > "%TEMP_DIR%\collections.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Collection data retrieved[0m
    echo.
    echo   ┌─────────────────────────────────────────────┐
    echo   │  THE ROOMS IN YOUR BRAIN                    │
    echo   ├─────────────────────────────────────────────┤
    echo   │  Knowledge     = Values, beliefs, lessons   │
    echo   │  PersonalDoc   = Private vault documents    │
    echo   │  DailyNote     = Journals, todos, reminders │
    echo   │  PersonalDraft = AI-written drafts          │
    echo   │  SecurityLog   = Access and security events │
    echo   │  PrivacyAudit  = Privacy trail records      │
    echo   │  FriendProfile = People and relationships   │
    echo   └─────────────────────────────────────────────┘
    echo.
    echo   Each collection stores vectors — numbers that
    echo   represent meaning. That's how the brain "thinks."
    echo   When you ask a question, it matches your question's
    echo   meaning against every entry in the right collection.
) else (
    echo  [91m   FAIL: Could not retrieve collection data[0m
)
echo.

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   You just walked through a living AI brain. You saw:
echo.
echo   1. The infrastructure keeping it alive
echo   2. The knowledge it holds — searchable by meaning
echo   3. The collections that organize everything
echo.
echo   This is what a digital legacy looks like on the
echo   inside. In the next module, you'll start feeding
echo   YOUR brain with YOUR knowledge.
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
