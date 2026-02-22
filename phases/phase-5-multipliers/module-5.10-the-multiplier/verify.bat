@echo off
setlocal enabledelayedexpansion
title Module 5.10 Verify — The Multiplier (CAPSTONE)

:: ============================================================
:: MODULE 5.10 VERIFICATION — PHASE 5 CAPSTONE
:: Checks: MCP reachable, system health populated, security logs,
::         chat responds, teaching draft in vault, vault categories,
::         knowledge entries, raw MCP curl
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=8"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.10-verify"
set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ======================================================
echo   MODULE 5.10 VERIFICATION — PHASE 5 CAPSTONE
echo  ======================================================
echo.

:: --- CHECK 1: MCP Server Reachable ---
echo  [CHECK 1/%TOTAL_CHECKS%] MCP server reachable (system_health)
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

:: --- CHECK 2: System Health Shows Populated Collections ---
echo  [CHECK 2/%TOTAL_CHECKS%] System health shows populated collections
python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.json')); cols=d.get('collections',{}); total=sum(v for v in cols.values() if isinstance(v,int)); populated=sum(1 for v in cols.values() if isinstance(v,int) and v>0); print('OK' if populated>=2 and total>=6 else 'EMPTY')" > "%TEMP_DIR%\health_status.txt" 2>nul
set /p HEALTH_STATUS=<"%TEMP_DIR%\health_status.txt"
if "!HEALTH_STATUS!"=="OK" (
    echo  [92m   PASS: Multiple collections populated with data[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Collections not sufficiently populated[0m
    echo          Fix: Run exercise.bat first, or add data via earlier modules
    echo          Need at least 2 populated collections with 6+ total entries
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: Security Log Search Executes ---
echo  [CHECK 3/%TOTAL_CHECKS%] security_log_search executes
python "%MCP_CALL%" security_log_search "{\"query\":\"activity\"}" > "%TEMP_DIR%\security.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   PASS: security_log_search executed successfully[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: security_log_search call failed[0m
    echo          Fix: Check MCP server status — the security_log_search tool must be available
    echo          Run: python shared\utils\mcp-call.py security_log_search "{\"query\":\"test\"}"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: chat_with_shanebrain Responds ---
echo  [CHECK 4/%TOTAL_CHECKS%] chat_with_shanebrain responds to beginner question
echo   Talking to your brain... (this may take a moment)
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"What is local AI?\"}" > "%TEMP_DIR%\chat.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\chat.json')); text=d.get('response',d.get('text',d.get('message',''))); has=len(str(text).strip())>20; err='error' in str(d).lower()[:100]; print('OK' if has and not err else 'EMPTY')" > "%TEMP_DIR%\chat_status.txt" 2>nul
    set /p CHAT_STATUS=<"%TEMP_DIR%\chat_status.txt"
    if "!CHAT_STATUS!"=="OK" (
        echo  [92m   PASS: Brain responded about local AI[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: chat_with_shanebrain returned empty or error[0m
        echo          Fix: Ollama may need time to load. Wait 30 seconds and retry
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: chat_with_shanebrain call failed[0m
    echo          Fix: Make sure Ollama is running and has a model loaded
    echo          Run: curl http://localhost:11434/api/tags
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Teaching Draft Stored in Vault ---
echo  [CHECK 5/%TOTAL_CHECKS%] Teaching draft stored in vault
python "%MCP_CALL%" vault_search "{\"query\":\"Quick Start Guide getting started Ollama install\"}" > "%TEMP_DIR%\vault_check.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault_check.json')); results=d.get('results',d.get('documents',[])); entries=results if isinstance(results,list) else [results]; count=len(entries); print('OK' if count>=1 else 'EMPTY')" > "%TEMP_DIR%\vault_status.txt" 2>nul
    set /p VAULT_STATUS=<"%TEMP_DIR%\vault_status.txt"
    if "!VAULT_STATUS!"=="OK" (
        echo  [92m   PASS: Teaching draft found in vault[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: No teaching draft found in vault[0m
        echo          Fix: Run exercise.bat — Task 5 stores the Quick Start Guide
        echo          Or: python shared\utils\mcp-call.py vault_add "{\"content\":\"guide content\",\"category\":\"teaching\",\"title\":\"Quick Start Guide\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_search call failed[0m
    echo          Fix: Check MCP server status
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 6: vault_list_categories Returns Data ---
echo  [CHECK 6/%TOTAL_CHECKS%] vault_list_categories returns data
python "%MCP_CALL%" vault_list_categories > "%TEMP_DIR%\categories.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\categories.json')); ok=isinstance(d,dict) and len(d)>0; print('OK' if ok else 'EMPTY')" > "%TEMP_DIR%\cat_status.txt" 2>nul
    set /p CAT_STATUS=<"%TEMP_DIR%\cat_status.txt"
    if "!CAT_STATUS!"=="OK" (
        echo  [92m   PASS: Vault categories returned[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: vault_list_categories returned empty[0m
        echo          Fix: Add documents to the vault first — run exercise.bat
        echo          Or: python shared\utils\mcp-call.py vault_add "{\"content\":\"test\",\"category\":\"teaching\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_list_categories call failed[0m
    echo          Fix: Check MCP server status
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 7: search_knowledge Returns Entries ---
echo  [CHECK 7/%TOTAL_CHECKS%] search_knowledge returns entries
python "%MCP_CALL%" search_knowledge "{\"query\":\"values knowledge family teaching\"}" > "%TEMP_DIR%\knowledge.json" 2>nul
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\knowledge.json')); results=d.get('results',d.get('knowledge',[])); entries=results if isinstance(results,list) else [results]; count=len(entries); print('OK' if count>=1 else 'EMPTY')" > "%TEMP_DIR%\know_status.txt" 2>nul
    set /p KNOW_STATUS=<"%TEMP_DIR%\know_status.txt"
    if "!KNOW_STATUS!"=="OK" (
        echo  [92m   PASS: Knowledge entries found[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: No knowledge entries found[0m
        echo          Fix: Add knowledge via earlier modules or exercise.bat
        echo          Or: python shared\utils\mcp-call.py add_knowledge "{\"content\":\"test value\",\"category\":\"family\"}"
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge call failed[0m
    echo          Fix: Check MCP server status
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 8: Raw MCP Curl Call Succeeds ---
echo  [CHECK 8/%TOTAL_CHECKS%] Raw MCP curl call succeeds (HTTP 200)
curl -s -o "%TEMP_DIR%\raw_mcp.txt" -w "%%{http_code}" -X POST http://localhost:8100/mcp -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-03-26\",\"capabilities\":{},\"clientInfo\":{\"name\":\"multiplier-verify\",\"version\":\"1.0\"}}}" > "%TEMP_DIR%\raw_status.txt" 2>nul
set /p RAW_STATUS=<"%TEMP_DIR%\raw_status.txt"
if "!RAW_STATUS!"=="200" (
    echo  [92m   PASS: Raw MCP curl returned HTTP 200[0m
    set /a PASS_COUNT+=1
) else (
    :: Check if we got any response at all (some servers return data without standard HTTP code capture)
    if exist "%TEMP_DIR%\raw_mcp.txt" (
        for %%A in ("%TEMP_DIR%\raw_mcp.txt") do set RAW_SIZE=%%~zA
        if !RAW_SIZE! GTR 10 (
            echo  [92m   PASS: Raw MCP curl returned data[0m
            set /a PASS_COUNT+=1
        ) else (
            echo  [91m   FAIL: Raw MCP curl returned no data[0m
            echo          Fix: Make sure MCP server is running on localhost:8100
            echo          Test: curl -s -X POST http://localhost:8100/mcp -H "Content-Type: application/json" -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-03-26\",\"capabilities\":{},\"clientInfo\":{\"name\":\"test\",\"version\":\"1.0\"}}}"
            set /a FAIL_COUNT+=1
        )
    ) else (
        echo  [91m   FAIL: Raw MCP curl failed — no response file[0m
        echo          Fix: Make sure MCP server is running on localhost:8100
        echo          Run: shared\utils\mcp-health-check.bat
        set /a FAIL_COUNT+=1
    )
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
    echo  [92m   ██████╗ ██╗  ██╗ █████╗ ███████╗███████╗    ███████╗[0m
    echo  [92m   ██╔══██╗██║  ██║██╔══██╗██╔════╝██╔════╝    ██╔════╝[0m
    echo  [92m   ██████╔╝███████║███████║███████╗█████╗      ███████╗[0m
    echo  [92m   ██╔═══╝ ██╔══██║██╔══██║╚════██║██╔══╝      ╚════██║[0m
    echo  [92m   ██║     ██║  ██║██║  ██║███████║███████╗    ███████║[0m
    echo  [92m   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝    ╚══════╝[0m
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
    echo  [93m   ███╗   ███╗██╗   ██╗██╗  ████████╗██╗██████╗ ██╗     ██╗███████╗██████╗ [0m
    echo  [93m   ████╗ ████║██║   ██║██║  ╚══██╔══╝██║██╔══██╗██║     ██║██╔════╝██╔══██╗[0m
    echo  [93m   ██╔████╔██║██║   ██║██║     ██║   ██║██████╔╝██║     ██║█████╗  ██████╔╝[0m
    echo  [93m   ██║╚██╔╝██║██║   ██║██║     ██║   ██║██╔═══╝ ██║     ██║██╔══╝  ██╔══██╗[0m
    echo  [93m   ██║ ╚═╝ ██║╚██████╔╝███████╗██║   ██║██║     ███████╗██║███████╗██║  ██║[0m
    echo  [93m   ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝[0m
    echo.
    echo  [93m    ██████╗███████╗██████╗ ████████╗██╗███████╗██╗███████╗██████╗ [0m
    echo  [93m   ██╔════╝██╔════╝██╔══██╗╚══██╔══╝██║██╔════╝██║██╔════╝██╔══██╗[0m
    echo  [93m   ██║     █████╗  ██████╔╝   ██║   ██║█████╗  ██║█████╗  ██║  ██║[0m
    echo  [93m   ██║     ██╔══╝  ██╔══██╗   ██║   ██║██╔══╝  ██║██╔══╝  ██║  ██║[0m
    echo  [93m   ╚██████╗███████╗██║  ██║   ██║   ██║██║     ██║███████╗██████╔╝[0m
    echo  [93m    ╚═════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚═════╝ [0m
    echo.
    echo  [93m  ======================================================[0m
    echo.
    echo.
    echo   ALL FIVE PHASES COMPLETE. Here is your record:
    echo.
    echo     [92mPhase 1: BUILDER[0m      — You built the engine
    echo       + Installed Ollama and ran your first local LLM
    echo       + Created vector databases in Weaviate
    echo       + Built a RAG brain from scratch
    echo       + Mastered prompt engineering
    echo       + Shipped a working AI system
    echo.
    echo     [92mPhase 2: OPERATOR[0m     — You ran a business on it
    echo       + Loaded a business knowledge base
    echo       + Built an instant answer desk
    echo       + Created AI-powered drafting
    echo       + Sorted and routed messages
    echo       + Automated paperwork
    echo       + Chained workflows together
    echo       + Ran an operator dashboard
    echo.
    echo     [92mPhase 3: EVERYDAY[0m     — You used it daily
    echo       + Built a private document vault
    echo       + Asked questions and got real answers
    echo       + Drafted writing with AI context
    echo       + Locked it down with security
    echo       + Journaled with daily AI briefings
    echo       + Audited your digital footprint
    echo       + Viewed your full AI dashboard
    echo.
    echo     [92mPhase 4: LEGACY[0m       — You built something that
    echo                              outlasts you
    echo       + Understood what a YourNameBrain is
    echo       + Fed it your knowledge
    echo       + Had real conversations with your brain
    echo       + Made it part of your daily life
    echo       + Wrote your story through it
    echo       + Guarded your legacy with security
    echo       + Passed it on with values and a letter
    echo.
    echo     [92mPhase 5: MULTIPLIER[0m   — You can defend, teach,
    echo                              connect, and build
    echo       + Locked gates and spotted threats
    echo       + Backed up and restored data
    echo       + Taught teachers and built workshops
    echo       + Exported brains and meshed families
    echo       + Went under the hood and chained prompts
    echo       + Proved all four themes in one capstone
    echo.
    echo  [92m  ======================================================[0m
    echo.
    echo   You are the multiplier now. Every person you teach
    echo   becomes one. Go multiply.
    echo.
    echo  [93m   Your skills. Your system. Your mission. Multiply.[0m
    echo.
    echo  [92m  ======================================================[0m

    :: --- Update progress ---
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "5.10", "status": "completed", "phase": "5", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
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
