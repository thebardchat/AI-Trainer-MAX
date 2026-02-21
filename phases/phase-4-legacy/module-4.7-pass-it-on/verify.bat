@echo off
setlocal enabledelayedexpansion
title Module 4.7 Verify — Pass It On (CAPSTONE)

:: ============================================================
:: MODULE 4.7 VERIFICATION — TRAINING CAPSTONE
:: Checks: MCP reachable, knowledge entries exist, vault entries
::         exist, chat responds, response contains personal
::         content, system health shows populated collections
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=6"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-4.7-verify"
set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ======================================================
echo   MODULE 4.7 VERIFICATION — TRAINING CAPSTONE
echo  ======================================================
echo.

:: --- CHECK 1: MCP Server Reachable ---
echo  [CHECK 1/%TOTAL_CHECKS%] MCP server reachable
python "%MCP_CALL%" system_health > "%TEMP_DIR%\health.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   PASS: MCP server responding[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: MCP server not reachable[0m
    echo          Fix: Make sure the MCP server is running on port 8100
    echo          Run: shared\utils\mcp-health-check.bat
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: Knowledge entries exist (family values) ---
echo  [CHECK 2/%TOTAL_CHECKS%] Knowledge base has family/philosophy entries
python "%MCP_CALL%" search_knowledge "{\"query\":\"family values hard work honesty\"}" > "%TEMP_DIR%\knowledge.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\knowledge.json')); results=d.get('results',d.get('knowledge',[])); entries=results if isinstance(results,list) else [results]; count=len(entries); print(count)" > "%TEMP_DIR%\know_count.txt" 2>nul
    set /p KNOW_COUNT=<"%TEMP_DIR%\know_count.txt"
    if !KNOW_COUNT! GEQ 3 (
        echo  [92m   PASS: Found !KNOW_COUNT! knowledge entries about family values[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: Found only !KNOW_COUNT! knowledge entries (need 3+)[0m
        echo          Fix: Run exercise.bat to add family values to knowledge base
        echo          Or: python shared\utils\mcp-call.py add_knowledge "{\"content\":\"your value\",\"category\":\"family\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge call failed[0m
    echo          Fix: Check MCP server status
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: Vault entries exist (life stories) ---
echo  [CHECK 3/%TOTAL_CHECKS%] Personal vault has life story entries
python "%MCP_CALL%" vault_search "{\"query\":\"life stories memories lessons children\"}" > "%TEMP_DIR%\vault.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault.json')); results=d.get('results',d.get('documents',[])); entries=results if isinstance(results,list) else [results]; count=len(entries); print(count)" > "%TEMP_DIR%\vault_count.txt" 2>nul
    set /p VAULT_COUNT=<"%TEMP_DIR%\vault_count.txt"
    if !VAULT_COUNT! GEQ 3 (
        echo  [92m   PASS: Found !VAULT_COUNT! vault documents[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: Found only !VAULT_COUNT! vault documents (need 3+)[0m
        echo          Fix: Run exercise.bat to add life stories to the vault
        echo          Or: python shared\utils\mcp-call.py vault_add "{\"content\":\"your story\",\"category\":\"personal\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_search call failed[0m
    echo          Fix: Check MCP server status
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: Chat responds ---
echo  [CHECK 4/%TOTAL_CHECKS%] chat_with_shanebrain generates a response
echo   Talking to your brain... (this may take a moment)
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"What do you know about my family values?\"}" > "%TEMP_DIR%\chat.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat.json')); text=d.get('response',d.get('text',d.get('message',''))); has=len(str(text).strip())>20; err='error' in str(d).lower()[:100]; print('OK' if has and not err else 'EMPTY')" > "%TEMP_DIR%\chat_status.txt" 2>nul
    set /p CHAT_STATUS=<"%TEMP_DIR%\chat_status.txt"
    if "!CHAT_STATUS!"=="OK" (
        echo  [92m   PASS: Your brain responded about family values[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: chat_with_shanebrain returned empty or error[0m
        echo          Fix: Ollama may need time to load. Wait 30 seconds and retry
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: chat_with_shanebrain call failed[0m
    echo          Fix: Make sure Ollama is running and has a model loaded
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Response contains personal content ---
echo  [CHECK 5/%TOTAL_CHECKS%] Brain response references YOUR content
python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat.json')); text=str(d.get('response',d.get('text',d.get('message','')))).lower(); keywords=['family','work','truth','honest','children','values','hard']; matches=[k for k in keywords if k in text]; print('OK' if len(matches)>=2 else 'EMPTY')" > "%TEMP_DIR%\personal_status.txt" 2>nul
set /p PERSONAL_STATUS=<"%TEMP_DIR%\personal_status.txt"
if "!PERSONAL_STATUS!"=="OK" (
    echo  [92m   PASS: Response contains personal value keywords[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Response does not reference your personal content[0m
    echo          Fix: Add more family values via add_knowledge, then re-run
    echo          The brain needs enough content to draw from
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 6: System health shows populated collections ---
echo  [CHECK 6/%TOTAL_CHECKS%] System health shows populated collections
python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.json')); cols=d.get('collections',{}); total=sum(v for v in cols.values() if isinstance(v,int)); populated=sum(1 for v in cols.values() if isinstance(v,int) and v>0); print('OK' if populated>=2 and total>=6 else 'EMPTY')" > "%TEMP_DIR%\collections_status.txt" 2>nul
set /p COLLECTIONS_STATUS=<"%TEMP_DIR%\collections_status.txt"
if "!COLLECTIONS_STATUS!"=="OK" (
    echo  [92m   PASS: Multiple collections populated with data[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Collections are not sufficiently populated[0m
    echo          Fix: Run exercise.bat to populate knowledge and vault
    set /a FAIL_COUNT+=1
)
echo.

:: Cleanup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

:: --- RESULTS ---
echo  ======================================================
if %FAIL_COUNT% EQU 0 (
    echo.
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
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
    echo  [93m   ALL PHASES DONE[0m
    echo.
    echo  [92m  ======================================================[0m
    echo.
    echo   You proved it. All of it. Here is your record:
    echo.
    echo     [92mPhase 1: BUILDER[0m     — You built the engine
    echo       + Installed Ollama and ran your first local LLM
    echo       + Created vector databases in Weaviate
    echo       + Built a RAG brain from scratch
    echo       + Mastered prompt engineering
    echo       + Shipped a working AI system
    echo.
    echo     [92mPhase 2: OPERATOR[0m    — You ran a business on it
    echo       + Loaded a business knowledge base
    echo       + Built an instant answer desk
    echo       + Created AI-powered drafting
    echo       + Sorted and routed messages
    echo       + Automated paperwork
    echo       + Chained workflows together
    echo       + Ran an operator dashboard
    echo.
    echo     [92mPhase 3: EVERYDAY[0m    — You used it daily
    echo       + Built a private document vault
    echo       + Asked questions and got real answers
    echo       + Drafted writing with AI context
    echo       + Locked it down with security
    echo       + Journaled with daily AI briefings
    echo       + Audited your digital footprint
    echo       + Viewed your full AI dashboard
    echo.
    echo     [92mPhase 4: LEGACY[0m      — You built something that
    echo                              outlasts you
    echo       + Understood what a YourNameBrain is
    echo       + Fed it your knowledge
    echo       + Had real conversations with your brain
    echo       + Made it part of your daily life
    echo       + Wrote your story through it
    echo       + Guarded your legacy with security
    echo       + Passed it on with values and a letter
    echo.
    echo  [92m  ======================================================[0m
    echo.
    echo   [93mYour name. Your brain. Your legacy. Pass it on.[0m
    echo.
    echo  [92m  ======================================================[0m

    :: --- Update progress ---
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "4.7", "status": "completed", "phase": "4", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    endlocal
    exit /b 0
) else (
    echo  [91m   RESULT: FAIL  (%PASS_COUNT%/%TOTAL_CHECKS% passed, %FAIL_COUNT% failed)[0m
    echo.
    echo   Review the failures above and fix them.
    echo   Then run verify.bat again.
    echo   Need help? Check hints.md in this folder.
    echo  ======================================================
    endlocal
    exit /b 1
)
