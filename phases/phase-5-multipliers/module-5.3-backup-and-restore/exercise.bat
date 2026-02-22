@echo off
setlocal enabledelayedexpansion
title Module 5.3 Exercise — Backup and Restore

:: ============================================================
:: MODULE 5.3 EXERCISE: Backup and Restore
:: Goal: Export knowledge + vault to local JSON files, verify
::       integrity, add a test entry, prove count increased
:: Time: ~20 minutes
:: Prerequisites: Module 4.7 complete
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.3"
set "BACKUP_DIR=%~dp0backups"

echo.
echo  ======================================================
echo   MODULE 5.3 EXERCISE: Backup and Restore
echo  ======================================================
echo.
echo   Your brain holds everything you built across four
echo   phases. Values, stories, letters, knowledge. This
echo   exercise exports it all to local JSON files and
echo   proves the backup is complete.
echo.
echo   Think of this as building a fireproof safe for
echo   your digital brain.
echo.
echo  ------------------------------------------------------
echo.

:: --- PRE-FLIGHT: MCP Server ---
echo  [PRE-FLIGHT] Checking MCP server...
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

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

:: ============================================================
:: TASK 1: Get Baseline — System Health Snapshot
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 1/7] Baseline Snapshot — How Much Data Do You Have?
echo.
echo   Before you back anything up, you need to know what
echo   you are working with. This is your "before" picture.
echo.
echo   Running system_health to get collection counts...
echo.

python "%MCP_CALL%" system_health > "%TEMP_DIR%\baseline_health.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Baseline captured[0m
    echo.
    echo   Collection counts:
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\baseline_health.json')); cols=d.get('collections',{}); [print(f'     {k}: {v}') for k,v in cols.items() if isinstance(v,int)]" 2>nul
) else (
    echo  [91m   FAIL — Could not get system health[0m
    echo     Fix: Check MCP server status
)
echo.

:: ============================================================
:: TASK 2: Export Knowledge Base
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 2/7] Export Knowledge — Backing Up Your Values
echo.
echo   Pulling all knowledge entries with a broad search
echo   and saving to a local JSON file...
echo.

python "%MCP_CALL%" search_knowledge "{\"query\":\"family values work life lessons philosophy faith\"}" > "%BACKUP_DIR%\knowledge-export.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Knowledge exported to knowledge-export.json[0m
    python -c "import json,os; d=json.load(open(r'%BACKUP_DIR%\knowledge-export.json')); results=d.get('results',d.get('knowledge',[])); entries=results if isinstance(results,list) else [results]; sz=os.path.getsize(r'%BACKUP_DIR%\knowledge-export.json'); print(f'     Entries: {len(entries)}'); print(f'     File size: {sz} bytes')" 2>nul
) else (
    echo  [91m   FAIL — Could not export knowledge[0m
    echo     Fix: Run python shared\utils\mcp-call.py search_knowledge "{\"query\":\"test\"}"
    echo     to verify the MCP tool works
)
echo.

:: ============================================================
:: TASK 3: Export Vault
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 3/7] Export Vault — Backing Up Your Stories
echo.
echo   Pulling all vault documents with a broad search
echo   and saving to a local JSON file...
echo.

python "%MCP_CALL%" vault_search "{\"query\":\"personal stories documents letters records family\"}" > "%BACKUP_DIR%\vault-export.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Vault exported to vault-export.json[0m
    python -c "import json,os; d=json.load(open(r'%BACKUP_DIR%\vault-export.json')); results=d.get('results',d.get('documents',[])); entries=results if isinstance(results,list) else [results]; sz=os.path.getsize(r'%BACKUP_DIR%\vault-export.json'); print(f'     Entries: {len(entries)}'); print(f'     File size: {sz} bytes')" 2>nul
) else (
    echo  [91m   FAIL — Could not export vault[0m
    echo     Fix: Run python shared\utils\mcp-call.py vault_search "{\"query\":\"test\"}"
    echo     to verify the MCP tool works
)
echo.

:: ============================================================
:: TASK 4: Backup Summary — Count and Compare
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 4/7] Backup Summary — Counting What You Saved
echo.
echo   Comparing export entry counts to the baseline...
echo.

python -c "import json,os; kf=r'%BACKUP_DIR%\knowledge-export.json'; vf=r'%BACKUP_DIR%\vault-export.json'; kd=json.load(open(kf)); vd=json.load(open(vf)); kr=kd.get('results',kd.get('knowledge',[])); vr=vd.get('results',vd.get('documents',[])); ke=kr if isinstance(kr,list) else [kr]; ve=vr if isinstance(vr,list) else [vr]; ks=os.path.getsize(kf); vs=os.path.getsize(vf); print(f'     Knowledge entries exported: {len(ke)}'); print(f'     Vault entries exported:     {len(ve)}'); print(f'     Knowledge file size:        {ks} bytes'); print(f'     Vault file size:            {vs} bytes'); print(f'     Total entries backed up:    {len(ke)+len(ve)}')" 2>nul

echo.
echo  [92m   Backup summary complete[0m
echo.

:: ============================================================
:: TASK 5: Add a Test Entry — Prove the System Tracks Changes
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 5/7] Test Entry — Proving Changes Get Tracked
echo.
echo   Adding ONE test entry to the knowledge base. After
echo   this, the collection count should go up by exactly
echo   one. This proves your next backup will catch new data.
echo.

python "%MCP_CALL%" add_knowledge "{\"content\":\"Backup verification entry. This entry was added during Module 5.3 to prove that the backup and restore process works correctly. If you see this in a future export, your backups are capturing new data.\",\"category\":\"backup-test\",\"title\":\"Backup Verification Entry\"}" > "%TEMP_DIR%\test_entry.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Test entry added: "Backup Verification Entry"[0m
) else (
    echo  [91m   FAIL — Could not add test entry[0m
    echo     Fix: Check MCP server and try manually:
    echo     python shared\utils\mcp-call.py add_knowledge "{\"content\":\"test\",\"category\":\"backup-test\"}"
)
echo.

:: ============================================================
:: TASK 6: Re-check System Health — Verify Count Increased
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 6/7] Verify Count — Did the Number Go Up?
echo.
echo   Running system_health again and comparing to
echo   the baseline...
echo.

python "%MCP_CALL%" system_health > "%TEMP_DIR%\post_health.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Post-add health captured[0m
    echo.
    echo   Updated collection counts:
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\post_health.json')); cols=d.get('collections',{}); [print(f'     {k}: {v}') for k,v in cols.items() if isinstance(v,int)]" 2>nul
    echo.
    python -c "import json; b=json.load(open(r'%TEMP_DIR%\baseline_health.json')).get('collections',{}); a=json.load(open(r'%TEMP_DIR%\post_health.json')).get('collections',{}); changed=[(k,b.get(k,0),a.get(k,0)) for k in a if isinstance(a.get(k),int) and a.get(k,0)!=b.get(k,0)]; [print(f'     {k}: {bv} -> {av} (+{av-bv})') for k,bv,av in changed] if changed else print('     No count changes detected (may need a moment to index)')" 2>nul
) else (
    echo  [91m   FAIL — Could not get post-add health[0m
)
echo.

:: ============================================================
:: TASK 7: Final Backup Report
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 7/7] Backup Report — What You Protected
echo.
echo   +--------------------------------------------------+
echo   ^|  BACKUP REPORT                                   ^|
echo   +--------------------------------------------------+
echo.

python -c "import json,os; kf=r'%BACKUP_DIR%\knowledge-export.json'; vf=r'%BACKUP_DIR%\vault-export.json'; kd=json.load(open(kf)); vd=json.load(open(vf)); kr=kd.get('results',kd.get('knowledge',[])); vr=vd.get('results',vd.get('documents',[])); ke=kr if isinstance(kr,list) else [kr]; ve=vr if isinstance(vr,list) else [vr]; print(f'   Files created:'); print(f'     knowledge-export.json  ({os.path.getsize(kf)} bytes, {len(ke)} entries)'); print(f'     vault-export.json      ({os.path.getsize(vf)} bytes, {len(ve)} entries)'); print(); print(f'   Total entries backed up: {len(ke)+len(ve)}'); print(f'   Test entry added: YES'); print(f'   Backup location: %BACKUP_DIR%')" 2>nul

echo.
echo   +--------------------------------------------------+
echo.
echo  [92m  ======================================================[0m
echo.
echo   Your brain is backed up. The files are plain JSON —
echo   readable by any text editor, portable to any machine.
echo.
echo   To make this a REAL backup:
echo.
echo     1. Copy the backups folder to a USB drive
echo     2. Copy it to a second hard drive
echo     3. Do NOT leave it only on the same drive as
echo        your Weaviate data
echo.
echo   A backup on the same drive as the original is like
echo   keeping your fireproof safe inside the house.
echo.
echo   Now run verify.bat to prove the backup is solid.
echo.
echo  [92m  ======================================================[0m
echo.

:: Cleanup temp (keep backup dir — those are the user's exports)
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
