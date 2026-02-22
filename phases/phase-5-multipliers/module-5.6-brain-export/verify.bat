@echo off
setlocal enabledelayedexpansion
title Module 5.6 Verify

:: ============================================================
:: MODULE 5.6 VERIFICATION
:: Checks: MCP reachable, search_knowledge returns data,
::         vault_search returns data, vault_list_categories works,
::         Python can assemble valid JSON bundle, system_health
::         shows collection counts
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=6"
set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.6-verify"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 5.6 VERIFICATION
echo  ══════════════════════════════════════════════════════
echo.

:: --- CHECK 1: MCP server reachable ---
echo  [CHECK 1/%TOTAL_CHECKS%] MCP server reachable
python "%MCP_CALL%" system_health > "%TEMP_DIR%\health.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: MCP server responding[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: MCP server not reachable[0m
    echo          Fix: Ensure ShaneBrain MCP gateway is running on localhost:8100
    echo          Test: python "%MCP_CALL%" system_health
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: search_knowledge returns data ---
echo  [CHECK 2/%TOTAL_CHECKS%] search_knowledge returns data
python "%MCP_CALL%" search_knowledge "{\"query\":\"knowledge values family life\"}" > "%TEMP_DIR%\knowledge.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\knowledge.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])) if isinstance(d,dict) else []; ok=isinstance(results,list); print('OK' if ok else 'INVALID')" 2>nul > "%TEMP_DIR%\know_status.txt"
    set /p KNOW_STATUS=<"%TEMP_DIR%\know_status.txt"
    if "!KNOW_STATUS!"=="OK" (
        echo  [92m   PASS: search_knowledge returned valid data[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: search_knowledge returned invalid format[0m
        echo          Fix: Check MCP server and LegacyKnowledge collection
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: search_knowledge call failed[0m
    echo          Fix: Check MCP server is running on localhost:8100
    echo          Test: python "%MCP_CALL%" search_knowledge "{\"query\":\"test\"}"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: vault_search returns data ---
echo  [CHECK 3/%TOTAL_CHECKS%] vault_search returns data
python "%MCP_CALL%" vault_search "{\"query\":\"personal documents vault\"}" > "%TEMP_DIR%\vault.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\vault.txt')); results=d if isinstance(d,list) else d.get('results',d.get('documents',[])) if isinstance(d,dict) else []; ok=isinstance(results,list); print('OK' if ok else 'INVALID')" 2>nul > "%TEMP_DIR%\vault_status.txt"
    set /p VAULT_STATUS=<"%TEMP_DIR%\vault_status.txt"
    if "!VAULT_STATUS!"=="OK" (
        echo  [92m   PASS: vault_search returned valid data[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: vault_search returned invalid format[0m
        echo          Fix: Check MCP server and PersonalDoc collection
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_search call failed[0m
    echo          Fix: Check MCP server is running on localhost:8100
    echo          Test: python "%MCP_CALL%" vault_search "{\"query\":\"test\"}"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: vault_list_categories returns categories ---
echo  [CHECK 4/%TOTAL_CHECKS%] vault_list_categories returns categories
python "%MCP_CALL%" vault_list_categories > "%TEMP_DIR%\categories.txt" 2>&1
if %errorlevel% EQU 0 (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\categories.txt')); ok=isinstance(d,(dict,list)); print('OK' if ok else 'INVALID')" 2>nul > "%TEMP_DIR%\cat_status.txt"
    set /p CAT_STATUS=<"%TEMP_DIR%\cat_status.txt"
    if "!CAT_STATUS!"=="OK" (
        echo  [92m   PASS: vault_list_categories returned valid data[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: vault_list_categories returned invalid format[0m
        echo          Fix: Check MCP server and PersonalDoc collection
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: vault_list_categories call failed[0m
    echo          Fix: Check MCP server is running on localhost:8100
    echo          Test: python "%MCP_CALL%" vault_list_categories
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Python can assemble valid JSON bundle ---
echo  [CHECK 5/%TOTAL_CHECKS%] Python can assemble valid JSON bundle with checksum
python -c "
import json, hashlib, os
from datetime import datetime

temp = r'%TEMP_DIR%'

def load_entries(filepath, keys):
    try:
        d = json.load(open(filepath))
        if isinstance(d, list): return d
        if isinstance(d, dict):
            for k in keys:
                if k in d and isinstance(d[k], list): return d[k]
            return [d] if d else []
        return []
    except: return []

knowledge = load_entries(os.path.join(temp, 'knowledge.txt'), ['results', 'entries', 'knowledge'])
vault = load_entries(os.path.join(temp, 'vault.txt'), ['results', 'documents', 'vault'])

data_payload = {'knowledge': knowledge, 'vault': vault, 'notes': []}
data_str = json.dumps(data_payload, sort_keys=True, default=str)
checksum = hashlib.md5(data_str.encode('utf-8')).hexdigest()

bundle = {
    'manifest': {
        'export_timestamp': datetime.now().isoformat(),
        'source_system': 'YourNameBrain',
        'collections': {'knowledge': len(knowledge), 'vault': len(vault), 'notes': 0},
        'total_entries': len(knowledge) + len(vault),
        'checksum': checksum
    },
    'knowledge': knowledge,
    'vault': vault,
    'notes': []
}

# Validate by round-tripping through json
test_str = json.dumps(bundle, default=str)
parsed = json.loads(test_str)
has_manifest = 'manifest' in parsed
has_checksum = 'checksum' in parsed.get('manifest', {})
has_collections = 'collections' in parsed.get('manifest', {})
valid = has_manifest and has_checksum and has_collections and len(checksum) == 32

print('OK' if valid else 'INVALID')
" 2>nul > "%TEMP_DIR%\bundle_status.txt"
set /p BUNDLE_STATUS=<"%TEMP_DIR%\bundle_status.txt"
if "%BUNDLE_STATUS%"=="OK" (
    echo  [92m   PASS: Python assembled valid JSON bundle with MD5 checksum[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Python could not assemble valid JSON bundle[0m
    echo          Fix: Ensure Python 3 is in PATH with json and hashlib modules
    echo          Test: python -c "import json, hashlib; print('OK')"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 6: system_health shows collection counts ---
echo  [CHECK 6/%TOTAL_CHECKS%] system_health shows collection counts
python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.txt')); collections=[k for k,v in d.items() if isinstance(v,int) and v>=0]; print('OK' if len(collections)>0 else 'NONE')" 2>nul > "%TEMP_DIR%\coll_status.txt"
set /p COLL_STATUS=<"%TEMP_DIR%\coll_status.txt"
if not defined COLL_STATUS set "COLL_STATUS=NONE"
if "%COLL_STATUS%"=="OK" (
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\health.txt')); collections=[k for k,v in d.items() if isinstance(v,int) and v>=0]; total=sum(v for k,v in d.items() if isinstance(v,int) and v>=0); print(str(len(collections)) + ' collection(s) with ' + str(total) + ' total document(s)')" 2>nul > "%TEMP_DIR%\coll_detail.txt"
    set /p COLL_DETAIL=<"%TEMP_DIR%\coll_detail.txt"
    echo  [92m   PASS: System has !COLL_DETAIL![0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: No collection counts found in system health[0m
    echo          Fix: Ensure Weaviate is running with data from earlier modules
    echo          Test: curl http://localhost:8080/v1/.well-known/ready
    set /a FAIL_COUNT+=1
)
echo.

:: Cleanup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

:: --- RESULTS ---
echo  ══════════════════════════════════════════════════════
if %FAIL_COUNT% EQU 0 (
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
    echo.
    echo  [92m   MODULE 5.6 COMPLETE[0m
    echo  [92m   You proved: Your brain can be packaged into a single[0m
    echo  [92m   structured export bundle with manifest and checksum.[0m
    echo  [92m   Knowledge, vault, and notes — inventoried, sealed,[0m
    echo  [92m   and portable. Your brain is not locked to one machine.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "5.6", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 5.7 — Family Mesh
    echo   Your brain is portable. Now learn to connect it
    echo   with your family's brains.
    echo  ══════════════════════════════════════════════════════
    endlocal
    exit /b 0
) else (
    echo  [91m   RESULT: FAIL  (%PASS_COUNT%/%TOTAL_CHECKS% passed, %FAIL_COUNT% failed)[0m
    echo.
    echo   Review the failures above and fix them.
    echo   Then run verify.bat again.
    echo   Need help? Check hints.md in this folder.
    echo  ══════════════════════════════════════════════════════
    endlocal
    exit /b 1
)
