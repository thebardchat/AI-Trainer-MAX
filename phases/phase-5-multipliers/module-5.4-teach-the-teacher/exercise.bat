@echo off
setlocal enabledelayedexpansion
title Module 5.4 Exercise — Teach the Teacher

:: ============================================================
:: MODULE 5.4 EXERCISE: Teach the Teacher
:: Goal: Add 5 teaching-category knowledge entries explaining
::       core concepts, then test the brain as a teaching assistant
:: Time: ~15 minutes
:: Prerequisites: Module 4.3, Module 4.2
:: MCP Tools: add_knowledge, search_knowledge, chat_with_shanebrain
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.4"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 5.4 EXERCISE: Teach the Teacher
echo  ══════════════════════════════════════════════════════
echo.
echo   You've been the student long enough. Now you're going
echo   to teach your brain how to teach others. Five concepts.
echo   Plain English. Clear enough for someone starting from
echo   zero. Then we test whether the brain can actually teach.
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
:: TASK 1: Add 5 teaching-category knowledge entries
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/6] Store 5 teaching entries in the knowledge base
echo.
echo   These are beginner-friendly explanations of the five
echo   core concepts that power everything you've built.
echo   Written so clearly that someone who has never opened
echo   a terminal could understand them.
echo.

:: --- Teaching Entry 1: What is Ollama ---
echo   Storing teaching entry: What is Ollama...
python "%MCP_CALL%" add_knowledge "{\"content\":\"Ollama is a free program that lets you run an AI on your own computer — no internet required, no monthly subscription, no sending your data to a company's server. Think of it like a calculator app, but instead of doing math, it works with words. You type a question or instruction, and Ollama runs a language model right on your machine to give you an answer. The key thing: everything stays on YOUR computer. Your questions, your data, your answers — none of it leaves your house. That's what 'local AI' means. You own it. You control it. It works even if the internet goes down.\",\"category\":\"teaching\",\"title\":\"What is Ollama — Beginner Explanation\"}" > "%TEMP_DIR%\teach1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Ollama teaching entry stored[0m
) else (
    echo  [91m   FAIL: Could not store Ollama entry[0m
    echo          Check MCP server and try again
)
echo.

:: --- Teaching Entry 2: What is a Vector ---
echo   Storing teaching entry: What is a Vector...
python "%MCP_CALL%" add_knowledge "{\"content\":\"A vector is how a computer understands the meaning of words. Imagine a filing cabinet — but instead of filing documents alphabetically, this cabinet files them by what they MEAN. A document about 'raising kids with strong values' would end up next to a document about 'teaching children right from wrong' even though those sentences use completely different words. That's because vectors turn words into numbers that capture meaning. When you store something in your AI brain, it gets turned into a vector — a list of numbers that represents what the content is about. Later, when you search for something, the brain doesn't look for matching words. It looks for matching meaning. That's why you can ask about 'becoming a dad' and find your entry about 'the day my first son was born.'\",\"category\":\"teaching\",\"title\":\"What is a Vector — Beginner Explanation\"}" > "%TEMP_DIR%\teach2.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Vector teaching entry stored[0m
) else (
    echo  [91m   FAIL: Could not store Vector entry[0m
)
echo.

:: --- Teaching Entry 3: What is RAG ---
echo   Storing teaching entry: What is RAG...
python "%MCP_CALL%" add_knowledge "{\"content\":\"RAG stands for Retrieval-Augmented Generation. Here's what that means in plain English: when you ask your AI brain a question, it does two things. First, it RETRIEVES — it searches through everything you've stored and pulls out the pieces that relate to your question. Like a librarian who hears your question, walks into the stacks, and comes back with the three most relevant books. Second, it GENERATES — it reads those pieces and writes you an answer based on what it found. Not from the internet. Not from generic training data. From YOUR documents. The 'augmented' part just means the AI's answer is boosted by real information instead of guessing. Without RAG, AI makes things up. With RAG, AI reads your actual data first and answers from that. That's the difference between a know-it-all who guesses and a librarian who checks the books before speaking.\",\"category\":\"teaching\",\"title\":\"What is RAG — Beginner Explanation\"}" > "%TEMP_DIR%\teach3.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: RAG teaching entry stored[0m
) else (
    echo  [91m   FAIL: Could not store RAG entry[0m
)
echo.

:: --- Teaching Entry 4: What is MCP ---
echo   Storing teaching entry: What is MCP...
python "%MCP_CALL%" add_knowledge "{\"content\":\"MCP stands for Model Context Protocol. Think of it like a universal adapter — the way USB-C lets you plug any device into any port, MCP lets any AI tool connect to any AI model in a standard way. Before MCP, every AI tool had its own custom way of connecting. If you built a journaling tool, a search tool, and a drafting tool, each one needed its own special wiring to talk to the AI. MCP changes that. It creates one standard way for tools to connect. Your vault, your journal, your search, your drafts — they all plug into the AI through the same universal connector. This means you can add new tools without rewiring everything. It also means your tools work together because they all speak the same language. MCP is the plumbing that makes your whole AI brain work as one system instead of a bunch of disconnected pieces.\",\"category\":\"teaching\",\"title\":\"What is MCP — Beginner Explanation\"}" > "%TEMP_DIR%\teach4.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: MCP teaching entry stored[0m
) else (
    echo  [91m   FAIL: Could not store MCP entry[0m
)
echo.

:: --- Teaching Entry 5: What is YourNameBrain ---
echo   Storing teaching entry: What is YourNameBrain...
python "%MCP_CALL%" add_knowledge "{\"content\":\"YourNameBrain is a personal AI brain that knows YOU — your values, your memories, your life lessons, your way of thinking. It's like a journal that can talk back. You feed it everything that matters: what you believe, what you've learned, stories about your family, advice you'd give your kids. Then anyone can sit down and have a conversation with it — and hear YOUR voice, YOUR wisdom, YOUR perspective. The 'YourName' part is literal. Shane built ShaneBrain. You build YourNameBrain. It runs on your own computer, so nobody else controls it. No company can shut it down or read your data. And here's the legacy piece: fifty years from now, your grandchildren can ask your brain what kind of person you were, what you believed in, what advice you'd give them — and it answers from everything you stored. It's not immortality. It's making sure the things that mattered to you don't disappear when you're gone.\",\"category\":\"teaching\",\"title\":\"What is YourNameBrain — Beginner Explanation\"}" > "%TEMP_DIR%\teach5.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: YourNameBrain teaching entry stored[0m
) else (
    echo  [91m   FAIL: Could not store YourNameBrain entry[0m
)
echo.

echo  [92m   Five teaching entries stored in the knowledge base.[0m
echo.
echo   Press any key to verify they're searchable...
pause >nul
echo.

:: ============================================================
:: TASK 2: Search knowledge for teaching entries
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/6] Search knowledge base for teaching entries
echo.
echo   Let's make sure the brain can find what you just stored.
echo   We'll search for "teaching" and see what comes back.
echo.

python "%MCP_CALL%" search_knowledge "{\"query\":\"teaching beginner explanation of AI concepts\"}" > "%TEMP_DIR%\search_teach.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Teaching entries found in knowledge base[0m
    echo.
    echo   Search results:
    echo   ──────────────────────────────────────────────────
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search_teach.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[d])); [print('   - ' + str(r.get('title',r.get('content','')[:80]))) for r in (results[:5] if isinstance(results,list) else [results])]" 2>nul
    echo   ──────────────────────────────────────────────────
) else (
    echo  [91m   FAIL: Could not search teaching entries[0m
    echo          Check MCP server is running
)
echo.
echo   Press any key to test the brain as a teaching assistant...
pause >nul
echo.

:: ============================================================
:: TASK 3: Ask brain to explain Ollama to a complete beginner
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/6] Test: "Explain Ollama to someone who has never used a terminal"
echo.
echo   This is the real test. Can your brain teach? Let's see
echo   if it pulls from your teaching entry and gives a clear,
echo   beginner-friendly answer.
echo.
echo   Thinking...
echo.

python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"Explain what Ollama is to someone who has never used a computer terminal before. Keep it simple and friendly.\"}" > "%TEMP_DIR%\chat1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Brain responded[0m
    echo.
    echo   Your Brain Teaches:
    echo   ══════════════════════════════════════════════════
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat1.txt')); text=d.get('text',d.get('response',str(d))); print('   ' + text[:600])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
) else (
    echo  [91m   FAIL: chat_with_shanebrain did not respond[0m
    echo          Check that Ollama is running for answer generation
)
echo.
echo   Press any key for the next teaching test...
pause >nul
echo.

:: ============================================================
:: TASK 4: Ask brain to explain RAG like the user is 12
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/6] Test: "How does RAG work? Explain it like I am 12 years old"
echo.
echo   A harder test. The brain needs to simplify a technical
echo   concept using the analogy you stored. Watch whether the
echo   librarian analogy shows up.
echo.
echo   Thinking...
echo.

python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"How does RAG work? Explain it like I am 12 years old.\"}" > "%TEMP_DIR%\chat2.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Brain responded[0m
    echo.
    echo   Your Brain Teaches:
    echo   ══════════════════════════════════════════════════
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat2.txt')); text=d.get('text',d.get('response',str(d))); print('   ' + text[:600])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
) else (
    echo  [91m   FAIL: chat_with_shanebrain did not respond[0m
    echo          Check that Ollama is running
)
echo.
echo   Press any key for the final teaching test...
pause >nul
echo.

:: ============================================================
:: TASK 5: Ask brain what you need to build a YourNameBrain
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 5/6] Test: "What do I need to build my own YourNameBrain?"
echo.
echo   This one tests whether the brain can pull from multiple
echo   teaching entries — YourNameBrain, Ollama, vectors, MCP —
echo   and weave them into practical guidance.
echo.
echo   Thinking...
echo.

python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"What do I need to build my own YourNameBrain? Explain it to someone just getting started.\"}" > "%TEMP_DIR%\chat3.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Brain responded[0m
    echo.
    echo   Your Brain Teaches:
    echo   ══════════════════════════════════════════════════
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat3.txt')); text=d.get('text',d.get('response',str(d))); print('   ' + text[:600])" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
) else (
    echo  [91m   FAIL: chat_with_shanebrain did not respond[0m
    echo          Check that Ollama is running
)
echo.
echo   Press any key to see the summary...
pause >nul
echo.

:: ============================================================
:: TASK 6: Display all three responses together
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 6/6] Teaching Summary — All Three Responses
echo.
echo   Here's what your brain taught in this session:
echo.

echo   [Question 1] Explain Ollama to a complete beginner:
echo   ──────────────────────────────────────────────────
python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat1.txt')); text=d.get('text',d.get('response',str(d))); print('   ' + text[:400])" 2>nul
echo.
echo   ──────────────────────────────────────────────────
echo.

echo   [Question 2] Explain RAG like I am 12:
echo   ──────────────────────────────────────────────────
python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat2.txt')); text=d.get('text',d.get('response',str(d))); print('   ' + text[:400])" 2>nul
echo.
echo   ──────────────────────────────────────────────────
echo.

echo   [Question 3] How to build my own YourNameBrain:
echo   ──────────────────────────────────────────────────
python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat3.txt')); text=d.get('text',d.get('response',str(d))); print('   ' + text[:400])" 2>nul
echo.
echo   ──────────────────────────────────────────────────
echo.

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   You just shifted from learner to teacher.
echo.
echo   Five teaching entries stored. Three beginner questions
echo   answered by YOUR brain, using YOUR explanations. Not
echo   a generic chatbot answer — a grounded response pulled
echo   from knowledge you wrote.
echo.
echo   This is the multiplier effect. You learned these
echo   concepts over weeks of hands-on work. Now your brain
echo   can teach them in minutes. One person's understanding
echo   becomes everyone's starting point.
echo.
echo   Want to add more teaching entries? Use:
echo.
echo     python "%MCP_CALL%" add_knowledge "{\"content\":\"...\",\"category\":\"teaching\",\"title\":\"...\"}"
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
