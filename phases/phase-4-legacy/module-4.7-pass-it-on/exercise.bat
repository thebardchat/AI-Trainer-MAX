@echo off
setlocal enabledelayedexpansion
title Module 4.7 Exercise — Pass It On (CAPSTONE)

:: ============================================================
:: MODULE 4.7 EXERCISE: Pass It On (Phase 4 + Training Capstone)
:: Goal: Build a working YourNameBrain from scratch — embed
::       family values, store life stories, write a letter to
::       your children, and prove the brain knows YOU
:: Time: ~20 minutes
:: Prerequisites: Modules 4.1-4.6, Phase 3 complete
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.7"

echo.
echo  ======================================================
echo   MODULE 4.7 EXERCISE: Pass It On
echo   THE FINAL CAPSTONE
echo  ======================================================
echo.
echo   This is the last exercise. Five tasks. When you
echo   finish, you will have a working YourNameBrain —
echo   loaded with your values, your stories, and your
echo   voice. Something that outlasts you.
echo.
echo  ------------------------------------------------------
echo.

:: --- PRE-FLIGHT: MCP Server ---
echo  [PRE-FLIGHT] Checking MCP server...
echo.

python "%MCP_CALL%" system_health > "%TEMP_DIR%\preflight.json" 2>nul
if %errorlevel% NEQ 0 (
    echo  [91m   X MCP server not reachable at localhost:8100[0m
    echo     Fix: Make sure the MCP server container is running.
    echo     Run: shared\utils\mcp-health-check.bat
    pause
    exit /b 1
)
echo  [92m   OK — MCP server responding[0m
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: ============================================================
:: TASK 1: Add Core Family Values to Knowledge Base
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 1/5] Family Values — What Do You Stand For?
echo.
echo   A house built on sand washes away. A house built on
echo   rock stands through the storm. Your values are the
echo   rock. We are putting them into the brain RIGHT NOW.
echo.
echo   Adding three core family values...
echo.

python "%MCP_CALL%" add_knowledge "{\"content\":\"Family always comes first. No job, no project, no amount of money is worth more than the people sitting at your dinner table. When you have to choose between work and family, choose family. The work will still be there tomorrow. Your kids will not be this age again.\",\"category\":\"family\",\"title\":\"Family Comes First\"}" > "%TEMP_DIR%\value1.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Value 1 added: "Family Comes First"[0m
) else (
    echo  [91m   FAIL — Could not add value 1[0m
    echo     Check hints.md for troubleshooting.
)

python "%MCP_CALL%" add_knowledge "{\"content\":\"Hard work is not punishment. It is proof that you care enough to show up and do what needs doing. The man who works with his hands and his mind builds things that last. Teach your children to work — not because the world is hard, but because they are capable of hard things.\",\"category\":\"philosophy\",\"title\":\"The Value of Hard Work\"}" > "%TEMP_DIR%\value2.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Value 2 added: "The Value of Hard Work"[0m
) else (
    echo  [91m   FAIL — Could not add value 2[0m
    echo     Check hints.md for troubleshooting.
)

python "%MCP_CALL%" add_knowledge "{\"content\":\"Tell the truth. Even when it costs you. A man who lies to save himself teaches his children that honesty is optional. It is not. Your word is the only thing you truly own. Guard it. When you make a promise, keep it. When you make a mistake, own it. That is how trust gets built — one honest word at a time.\",\"category\":\"family\",\"title\":\"Truth and Integrity\"}" > "%TEMP_DIR%\value3.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Value 3 added: "Truth and Integrity"[0m
) else (
    echo  [91m   FAIL — Could not add value 3[0m
    echo     Check hints.md for troubleshooting.
)
echo.

:: ============================================================
:: TASK 2: Add Personal Vault Documents — Life Stories
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 2/5] Life Stories — The Memories That Matter
echo.
echo   Values without stories are just bumper stickers.
echo   Stories give your values weight. These go into your
echo   personal vault — searchable, permanent, YOURS.
echo.
echo   Adding three life stories to the vault...
echo.

python "%MCP_CALL%" vault_add "{\"content\":\"The day my first son was born, I understood what my father meant when he said your life is not your own anymore. I held that boy and every plan I ever made rearranged itself around him. That is not a loss. That is a promotion. You go from living for yourself to living for something that matters more than yourself. Every son after that confirmed it — five times over.\",\"category\":\"personal\",\"title\":\"The Day Everything Changed\"}" > "%TEMP_DIR%\story1.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Story 1 stored: "The Day Everything Changed"[0m
) else (
    echo  [91m   FAIL — Could not store story 1[0m
    echo     Check hints.md for troubleshooting.
)

python "%MCP_CALL%" vault_add "{\"content\":\"I learned to build things because nobody was going to build them for me. First it was shelves in the garage. Then it was a chicken coop. Then it was software. Then it was a business. The lesson is always the same — read the instructions, gather the materials, start with the foundation, and do not quit when it gets hard. Everything worth having gets built the same way.\",\"category\":\"personal\",\"title\":\"How I Learned to Build\"}" > "%TEMP_DIR%\story2.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Story 2 stored: "How I Learned to Build"[0m
) else (
    echo  [91m   FAIL — Could not store story 2[0m
    echo     Check hints.md for troubleshooting.
)

python "%MCP_CALL%" vault_add "{\"content\":\"There was a season where I worked two jobs and slept four hours a night. I do not tell you this to brag. I tell you because it taught me something — you can do more than you think you can, but you cannot do it forever. Rest is not weakness. Asking for help is not failure. The strongest thing I ever did was admit I could not carry it alone. That is when things started getting better.\",\"category\":\"personal\",\"title\":\"The Season of Two Jobs\"}" > "%TEMP_DIR%\story3.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Story 3 stored: "The Season of Two Jobs"[0m
) else (
    echo  [91m   FAIL — Could not store story 3[0m
    echo     Check hints.md for troubleshooting.
)
echo.

:: ============================================================
:: TASK 3: Chat With Your Brain — Does It Know You?
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 3/5] First Conversation — Does the Brain Know You?
echo.
echo   You fed it values. You gave it stories. Now ask it
echo   a question and see if it draws from what you taught
echo   it. This is the moment of truth.
echo.
echo   Asking: "What are my core family values?"
echo   Give it a moment — Ollama is thinking...
echo.

python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"What are my core family values? What do I believe about family, hard work, and honesty?\"}" > "%TEMP_DIR%\chat1.json" 2>nul

if %errorlevel% EQU 0 (
    echo  [92m   OK — Your brain responded[0m
    echo.
    echo   +--------------------------------------------------+
    echo   ^|  YOUR BRAIN SAYS:                                ^|
    echo   +--------------------------------------------------+
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat1.json')); text=d.get('response',d.get('text',d.get('message',str(d)))); print('    ',text[:600])" 2>nul
    echo.
    echo   +--------------------------------------------------+
    echo.
    echo   Does that sound like you? If it does, the brain
    echo   is working. If it does not, add more content.
) else (
    echo  [91m   FAIL — Could not chat with your brain[0m
    echo     Ollama may need time to load. Try again in 30 seconds.
    echo     Check hints.md for troubleshooting.
)
echo.

:: ============================================================
:: TASK 4: Write the Letter to Your Children
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 4/5] The Letter — What You Want Them to Know
echo.
echo   Every YourNameBrain needs at least one letter. Not
echo   instructions. Not a manual. Heart. This goes into
echo   both the knowledge base AND the vault — so the brain
echo   can find it from any direction.
echo.
echo   Writing the letter...
echo.

set "LETTER_CONTENT=To my children: If you are reading this, it means I built something and you found it. This is my brain — not the one in my head, but the one I trained. It holds what I believe, what I learned, and what I want you to know. I am not perfect. I made mistakes. But everything I did, I did trying to give you a better starting line than I had. Work hard. Tell the truth. Take care of each other. Love is not a feeling — it is showing up every single day, even when it is hard. Especially when it is hard. I love you more than I know how to say. This brain is my way of saying it anyway."

python "%MCP_CALL%" add_knowledge "{\"content\":\"%LETTER_CONTENT%\",\"category\":\"family\",\"title\":\"Letter to My Children\"}" > "%TEMP_DIR%\letter_know.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Letter added to knowledge base[0m
) else (
    echo  [91m   FAIL — Could not add letter to knowledge base[0m
)

python "%MCP_CALL%" vault_add "{\"content\":\"%LETTER_CONTENT%\",\"category\":\"personal\",\"title\":\"Letter to My Children\"}" > "%TEMP_DIR%\letter_vault.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Letter stored in personal vault[0m
) else (
    echo  [91m   FAIL — Could not store letter in vault[0m
)
echo.

:: ============================================================
:: TASK 5: Final Conversation — The Proof
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 5/5] The Final Proof — What Do You Know About Me?
echo.
echo   This is it. The last question you will ask as a
echo   student of this training. After this, you are the
echo   owner.
echo.
echo   Asking: "What do you know about my family values?"
echo   Give it a moment...
echo.

python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"What do you know about my family values? Tell me what I believe about family, what stories I have shared, and what I want my children to know.\"}" > "%TEMP_DIR%\chat2.json" 2>nul

if %errorlevel% EQU 0 (
    echo  [92m   OK — Your brain knows you[0m
    echo.
    echo   +--------------------------------------------------+
    echo   ^|  YOUR BRAIN SAYS:                                ^|
    echo   +--------------------------------------------------+
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat2.json')); text=d.get('response',d.get('text',d.get('message',str(d)))); print('    ',text[:800])" 2>nul
    echo.
    echo   +--------------------------------------------------+
) else (
    echo  [91m   FAIL — Could not chat with your brain[0m
    echo     Check hints.md for troubleshooting.
)
echo.

:: ============================================================
:: TRAINING COMPLETE BANNER
:: ============================================================
echo.
echo  [92m  ======================================================[0m
echo  [92m  ======================================================[0m
echo.
echo  [92m   ██████╗ ██╗  ██╗ █████╗ ███████╗███████╗    ██╗  ██╗[0m
echo  [92m   ██╔══██╗██║  ██║██╔══██╗██╔════╝██╔════╝    ██║  ██║[0m
echo  [92m   ██████╔╝███████║███████║███████╗█████╗       ███████║[0m
echo  [92m   ██╔═══╝ ██╔══██║██╔══██║╚════██║██╔══╝      ╚════██║[0m
echo  [92m   ██║     ██║  ██║██║  ██║███████║███████╗          ██║[0m
echo  [92m   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝          ╚═╝[0m
echo.
echo  [92m    ██████╗ ██████╗ ███╗   ███╗██████╗ ██╗     ███████╗████████╗███████╗[0m
echo  [92m   ██╔════╝██╔═══██╗████╗ ████║██╔══██╗██║     ██╔════╝╚══██╔══╝██╔════╝[0m
echo  [92m   ██║     ██║   ██║██╔████╔██║██████╔╝██║     █████╗     ██║   █████╗  [0m
echo  [92m   ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝     ██║   ██╔══╝  [0m
echo  [92m   ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║     ███████╗███████╗   ██║   ███████╗[0m
echo  [92m    ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝   ╚═╝   ╚══════╝[0m
echo.
echo  [92m  ======================================================[0m
echo  [92m  ======================================================[0m
echo.
echo.
echo  [93m  ████████╗██████╗  █████╗ ██╗███╗   ██╗██╗███╗   ██╗ ██████╗ [0m
echo  [93m  ╚══██╔══╝██╔══██╗██╔══██╗██║████╗  ██║██║████╗  ██║██╔════╝ [0m
echo  [93m     ██║   ██████╔╝███████║██║██╔██╗ ██║██║██╔██╗ ██║██║  ███╗[0m
echo  [93m     ██║   ██╔══██╗██╔══██║██║██║╚██╗██║██║██║╚██╗██║██║   ██║[0m
echo  [93m     ██║   ██║  ██║██║  ██║██║██║ ╚████║██║██║ ╚████║╚██████╔╝[0m
echo  [93m     ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝ [0m
echo.
echo  [93m    ██████╗ ██████╗ ███╗   ███╗██████╗ ██╗     ███████╗████████╗███████╗[0m
echo  [93m   ██╔════╝██╔═══██╗████╗ ████║██╔══██╗██║     ██╔════╝╚══██╔══╝██╔════╝[0m
echo  [93m   ██║     ██║   ██║██╔████╔██║██████╔╝██║     █████╗     ██║   █████╗  [0m
echo  [93m   ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝     ██║   ██╔══╝  [0m
echo  [93m   ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║     ███████╗███████╗   ██║   ███████╗[0m
echo  [93m    ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝   ╚═╝   ╚══════╝[0m
echo.
echo.
echo   You did not just learn AI. You built something
echo   that outlasts you.
echo.
echo   Here is what you proved across ALL FOUR PHASES:
echo.
echo     [92mPhase 1: BUILDER[0m     — You built the engine
echo     [92mPhase 2: OPERATOR[0m    — You ran a business on it
echo     [92mPhase 3: EVERYDAY[0m    — You used it daily
echo     [92mPhase 4: LEGACY[0m      — You built something that
echo                             outlasts you
echo.
echo   Your brain now holds:
echo.
echo     [92m+[0m Your family values — searchable, permanent
echo     [92m+[0m Your life stories — indexed by meaning
echo     [92m+[0m A letter to your children — stored twice
echo     [92m+[0m A voice — your AI speaks from YOUR content
echo     [92m+[0m A system — running on YOUR hardware
echo.
echo   No cloud. No subscription. No corporation deciding
echo   what happens to your data. This is YOURS.
echo.
echo   Now run verify.bat to lock in your completion.
echo.
echo   [93mYour name. Your brain. Your legacy. Pass it on.[0m
echo.

if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
