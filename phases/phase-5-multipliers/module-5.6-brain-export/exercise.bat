@echo off
setlocal enabledelayedexpansion
title Module 5.6 Exercise — Brain Export

:: ============================================================
:: MODULE 5.6 EXERCISE: Brain Export
:: Goal: Create a structured JSON export bundle with manifest
::       and MD5 checksum from knowledge, vault, and daily notes
:: Time: ~15 minutes
:: Prerequisites: Module 5.3 (Backup and Restore)
:: MCP Tools: system_health, vault_list_categories, search_knowledge,
::            vault_search, daily_note_search
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.6"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 5.6 EXERCISE: Brain Export
echo  ══════════════════════════════════════════════════════
echo.
echo   Module 5.3 taught you to back up. This module teaches
echo   you to PACK. Like loading a moving truck — everything
echo   labeled, inventoried, and sealed for the road.
echo.
echo   Seven tasks. One export bundle. Your brain, portable.
echo.
echo  ──────────────────────────────────────────────────────
echo.

:: --- PRE-FLIGHT: Check MCP server ---
echo  [PRE-FLIGHT] Checking MCP server...
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

python "%MCP_CALL%" system_health > "%TEMP_DIR%\preflight.txt" 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   X MCP server not reachable. Is ShaneBrain running?[0m
    echo       Check: python "%MCP_CALL%" system_health
    pause
    exit /b 1
)
echo  [92m   PASS: MCP server responding[0m
echo.

:: ============================================================
:: TASK 1: Get system health and collection counts
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/7] System health — inventory before packing
echo.
echo   Before you pack the truck, you walk through the house
echo   and count what needs to go. system_health gives you
echo   the collection counts — your starting inventory.
echo.

python "%MCP_CALL%" system_health > "%TEMP_DIR%\health.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: System health retrieved[0m
    echo.
    echo   ══════════════════════════════════════════════════
    echo   COLLECTION COUNTS:
    echo   ══════════════════════════════════════════════════
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.txt')); [print('   ' + str(k) + ': ' + str(v)) for k,v in (d.items() if isinstance(d,dict) else [('status',str(d))])]" 2>nul
    echo.
    echo   ══════════════════════════════════════════════════
) else (
    echo  [91m   FAIL: Could not retrieve system health[0m
    echo          Fix: Check that Weaviate and Ollama are running
)
echo.
echo   Press any key to discover vault categories...
pause >nul
echo.

:: ============================================================
:: TASK 2: Discover vault categories
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/7] Vault categories — what's in the house?
echo.
echo   Before you label boxes, you need to know what rooms
echo   have stuff. vault_list_categories shows you every
echo   category of document in your personal vault.
echo.

python "%MCP_CALL%" vault_list_categories > "%TEMP_DIR%\categories.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: Vault categories retrieved[0m
    echo.
    echo   Categories found:
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\categories.txt')); cats=d if isinstance(d,list) else (d.get('categories',d.get('results',[])) if isinstance(d,dict) else []); [print('     - ' + str(c)) for c in (cats if isinstance(cats,list) else [cats])] if cats else print('     (none yet — add vault docs in earlier modules)')" 2>nul
) else (
    echo  [93m   WARN: Could not retrieve vault categories[0m
    echo          This is OK if your vault is empty.
)
echo.
echo   Press any key to export knowledge entries...
pause >nul
echo.

:: ============================================================
:: TASK 3: Export knowledge entries
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/7] Export knowledge — family values, lessons, philosophy
echo.
echo   Packing the first room. Your knowledge base holds
echo   everything you taught your brain about who you are
echo   and what you believe.
echo.

python "%MCP_CALL%" search_knowledge "{\"query\":\"knowledge values family life lessons\"}" > "%TEMP_DIR%\knowledge_raw.txt" 2>&1

if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\knowledge_raw.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])) if isinstance(d,dict) else []; print(len(results) if isinstance(results,list) else 0)" 2>nul > "%TEMP_DIR%\knowledge_count.txt"
    set /p KNOW_COUNT=<"%TEMP_DIR%\knowledge_count.txt"
    if not defined KNOW_COUNT set "KNOW_COUNT=0"
    echo  [92m   PASS: Knowledge exported — !KNOW_COUNT! entries[0m
) else (
    echo  [93m   WARN: Knowledge search returned no data[0m
    echo          This is OK if you haven't added knowledge entries.
    set "KNOW_COUNT=0"
)
echo.
echo   Press any key to export vault entries...
pause >nul
echo.

:: ============================================================
:: TASK 4: Export vault entries
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/7] Export vault — letters, stories, documents
echo.
echo   Second room. Your personal vault holds the letters
echo   to your children, your life story, anything you
echo   stored for safekeeping.
echo.

python "%MCP_CALL%" vault_search "{\"query\":\"personal documents letters stories family\"}" > "%TEMP_DIR%\vault_raw.txt" 2>&1

if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault_raw.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[])) if isinstance(d,dict) else []; print(len(results) if isinstance(results,list) else 0)" 2>nul > "%TEMP_DIR%\vault_count.txt"
    set /p VAULT_COUNT=<"%TEMP_DIR%\vault_count.txt"
    if not defined VAULT_COUNT set "VAULT_COUNT=0"
    echo  [92m   PASS: Vault exported — !VAULT_COUNT! entries[0m
) else (
    echo  [93m   WARN: Vault search returned no data[0m
    echo          This is OK if your vault is empty.
    set "VAULT_COUNT=0"
)
echo.
echo   Press any key to export daily notes...
pause >nul
echo.

:: ============================================================
:: TASK 5: Export daily notes
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 5/7] Export notes — journals, reflections, reminders
echo.
echo   Third room. Your daily notes capture what you thought,
echo   what you did, and what you want to remember.
echo.

python "%MCP_CALL%" daily_note_search "{\"query\":\"journal reflection notes daily\"}" > "%TEMP_DIR%\notes_raw.txt" 2>&1

if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\notes_raw.txt')); results=d if isinstance(d,list) else d.get('results',d.get('notes',[])) if isinstance(d,dict) else []; print(len(results) if isinstance(results,list) else 0)" 2>nul > "%TEMP_DIR%\notes_count.txt"
    set /p NOTES_COUNT=<"%TEMP_DIR%\notes_count.txt"
    if not defined NOTES_COUNT set "NOTES_COUNT=0"
    echo  [92m   PASS: Notes exported — !NOTES_COUNT! entries[0m
) else (
    echo  [93m   WARN: Daily note search returned no data[0m
    echo          This is OK if you haven't added daily notes.
    set "NOTES_COUNT=0"
)
echo.
echo   Press any key to assemble the export bundle...
pause >nul
echo.

:: ============================================================
:: TASK 6: Assemble the structured export bundle with checksum
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 6/7] Assemble export bundle — pack the truck
echo.
echo   This is the big step. Python reads all three exports,
echo   combines them into one structured JSON file, calculates
echo   an MD5 checksum, and writes the manifest.
echo.
echo   Like sealing the moving truck and taping the inventory
echo   sheet to the door.
echo.

python -c "
import json, hashlib, os
from datetime import datetime

temp = r'%TEMP_DIR%'

# Load raw exports — handle various response formats
def load_entries(filepath, keys):
    try:
        d = json.load(open(filepath))
        if isinstance(d, list):
            return d
        if isinstance(d, dict):
            for k in keys:
                if k in d and isinstance(d[k], list):
                    return d[k]
            # If dict has no known list key, wrap it
            return [d] if d else []
        return []
    except:
        return []

knowledge = load_entries(os.path.join(temp, 'knowledge_raw.txt'), ['results', 'entries', 'knowledge'])
vault = load_entries(os.path.join(temp, 'vault_raw.txt'), ['results', 'documents', 'vault'])
notes = load_entries(os.path.join(temp, 'notes_raw.txt'), ['results', 'notes', 'daily_notes'])

# Build data payload (without manifest) for checksumming
data_payload = {
    'knowledge': knowledge,
    'vault': vault,
    'notes': notes
}
data_str = json.dumps(data_payload, sort_keys=True, default=str)
checksum = hashlib.md5(data_str.encode('utf-8')).hexdigest()

# Build full export bundle
bundle = {
    'manifest': {
        'export_timestamp': datetime.now().isoformat(),
        'source_system': 'YourNameBrain',
        'collections': {
            'knowledge': len(knowledge),
            'vault': len(vault),
            'notes': len(notes)
        },
        'total_entries': len(knowledge) + len(vault) + len(notes),
        'checksum': checksum
    },
    'knowledge': knowledge,
    'vault': vault,
    'notes': notes
}

# Write the bundle
outpath = os.path.join(temp, 'brain-export.json')
with open(outpath, 'w', encoding='utf-8') as f:
    json.dump(bundle, f, indent=2, default=str)

# Report
size = os.path.getsize(outpath)
print('BUNDLE_OK')
print(f'KNOWLEDGE={len(knowledge)}')
print(f'VAULT={len(vault)}')
print(f'NOTES={len(notes)}')
print(f'TOTAL={bundle[\"manifest\"][\"total_entries\"]}')
print(f'CHECKSUM={checksum}')
print(f'SIZE={size}')
" > "%TEMP_DIR%\bundle_result.txt" 2>&1

:: Check if bundle was created successfully
python -c "f=open(r'%TEMP_DIR%\bundle_result.txt'); lines=f.read().strip().split('\n'); print(lines[0] if lines else 'FAIL')" 2>nul > "%TEMP_DIR%\bundle_status.txt"
set /p BUNDLE_STATUS=<"%TEMP_DIR%\bundle_status.txt"

if "%BUNDLE_STATUS%"=="BUNDLE_OK" (
    echo  [92m   PASS: Export bundle assembled[0m
    echo.

    :: Parse individual values from result
    for /f "tokens=1,* delims==" %%a in ('type "%TEMP_DIR%\bundle_result.txt"') do (
        if "%%a"=="KNOWLEDGE" set "EXP_KNOWLEDGE=%%b"
        if "%%a"=="VAULT" set "EXP_VAULT=%%b"
        if "%%a"=="NOTES" set "EXP_NOTES=%%b"
        if "%%a"=="TOTAL" set "EXP_TOTAL=%%b"
        if "%%a"=="CHECKSUM" set "EXP_CHECKSUM=%%b"
        if "%%a"=="SIZE" set "EXP_SIZE=%%b"
    )
) else (
    echo  [91m   FAIL: Could not assemble export bundle[0m
    echo          Check Python output:
    type "%TEMP_DIR%\bundle_result.txt"
    echo.
    echo          Fix: Ensure Python 3 is in PATH and temp files exist
    pause
    exit /b 1
)
echo.
echo   Press any key to see the manifest summary...
pause >nul
echo.

:: ============================================================
:: TASK 7: Display manifest summary
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 7/7] Manifest summary — the packing list
echo.

echo   ══════════════════════════════════════════════════════
echo   BRAIN EXPORT MANIFEST
echo   ══════════════════════════════════════════════════════
echo.
echo     Source System:    YourNameBrain
echo     Knowledge:        !EXP_KNOWLEDGE! entries
echo     Vault:            !EXP_VAULT! entries
echo     Notes:            !EXP_NOTES! entries
echo     Total Entries:    !EXP_TOTAL!
echo     MD5 Checksum:     !EXP_CHECKSUM!
echo     File Size:        !EXP_SIZE! bytes
echo     Location:         %TEMP_DIR%\brain-export.json
echo.
echo   ══════════════════════════════════════════════════════
echo.
echo   That checksum is your seal. If anyone changes even one
echo   character in the data, the checksum will not match. When
echo   you hand this file to your son, he can verify it himself.
echo.
echo   TO VERIFY LATER:
echo     python -c "import json,hashlib; b=json.load(open(r'brain-export.json')); d={'knowledge':b['knowledge'],'vault':b['vault'],'notes':b['notes']}; print(hashlib.md5(json.dumps(d,sort_keys=True,default=str).encode()).hexdigest())"
echo.
echo   If the output matches the checksum above, the data is intact.
echo.

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   You packed your brain into a structured, portable bundle.
echo   One file. Manifest. Checksum. Ready to move.
echo.
echo   Your export is at:
echo     %TEMP_DIR%\brain-export.json
echo.
echo   Copy it to a USB drive, another machine, or a safe
echo   location. Your brain travels with you now.
echo.
echo   Now run verify.bat to confirm everything passed:
echo.
echo       verify.bat
echo.

:: Cleanup temp files (but NOT the export — user may want it)
if exist "%TEMP_DIR%\preflight.txt" del "%TEMP_DIR%\preflight.txt" 2>nul
if exist "%TEMP_DIR%\health.txt" del "%TEMP_DIR%\health.txt" 2>nul
if exist "%TEMP_DIR%\categories.txt" del "%TEMP_DIR%\categories.txt" 2>nul
if exist "%TEMP_DIR%\knowledge_raw.txt" del "%TEMP_DIR%\knowledge_raw.txt" 2>nul
if exist "%TEMP_DIR%\vault_raw.txt" del "%TEMP_DIR%\vault_raw.txt" 2>nul
if exist "%TEMP_DIR%\notes_raw.txt" del "%TEMP_DIR%\notes_raw.txt" 2>nul
if exist "%TEMP_DIR%\knowledge_count.txt" del "%TEMP_DIR%\knowledge_count.txt" 2>nul
if exist "%TEMP_DIR%\vault_count.txt" del "%TEMP_DIR%\vault_count.txt" 2>nul
if exist "%TEMP_DIR%\notes_count.txt" del "%TEMP_DIR%\notes_count.txt" 2>nul
if exist "%TEMP_DIR%\bundle_result.txt" del "%TEMP_DIR%\bundle_result.txt" 2>nul
if exist "%TEMP_DIR%\bundle_status.txt" del "%TEMP_DIR%\bundle_status.txt" 2>nul

pause
endlocal
exit /b 0
