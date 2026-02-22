@echo off
setlocal enabledelayedexpansion
title Module 5.8 Verify

:: ============================================================
:: MODULE 5.8 VERIFICATION
:: Checks: Raw curl initialize, raw curl tools/call, response
::         has collections, mcp-call.py exists, Python parses
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=5"
set "MCP_URL=http://localhost:8100/mcp"
set "MCP_CALL_SRC=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.8-verify"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ======================================================
echo   MODULE 5.8 VERIFICATION
echo  ======================================================
echo.

:: --- CHECK 1: MCP server responds to raw curl initialize ---
echo  [CHECK 1/%TOTAL_CHECKS%] MCP server responds to raw curl initialize
curl -s -o "%TEMP_DIR%\init_resp.txt" -w "%%{http_code}" -X POST %MCP_URL% -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-03-26\",\"capabilities\":{},\"clientInfo\":{\"name\":\"verify-test\",\"version\":\"1.0\"}}}" > "%TEMP_DIR%\init_status.txt" 2>&1

set /p HTTP_STATUS=<"%TEMP_DIR%\init_status.txt"
if "!HTTP_STATUS!"=="200" (
    echo  [92m   PASS: MCP server returned HTTP 200 on initialize[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: MCP server returned HTTP !HTTP_STATUS! (expected 200)[0m
    echo          Fix: Ensure ShaneBrain MCP gateway is running at %MCP_URL%
    echo          Try: curl -s -X POST %MCP_URL% -H "Content-Type: application/json" -d "{...}"
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: Raw curl tools/call for system_health returns valid JSON ---
echo  [CHECK 2/%TOTAL_CHECKS%] Raw curl tools/call returns valid JSON

:: Send initialized notification first
curl -s -X POST %MCP_URL% -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}" > nul 2>&1

:: Call system_health
curl -s -X POST %MCP_URL% -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"system_health\",\"arguments\":{}}}" > "%TEMP_DIR%\health_resp.txt" 2>&1

:: Check if response is valid JSON (plain or SSE)
python -c "import json;f=open(r'%TEMP_DIR%\health_resp.txt');raw=f.read();f.close();lines=[l for l in raw.splitlines() if l.startswith('data: ')];obj=json.loads(lines[0][6:]) if lines else json.loads(raw);assert 'result' in obj or 'error' in obj;print('OK')" > "%TEMP_DIR%\json_check.txt" 2>&1
set /p JSON_STATUS=<"%TEMP_DIR%\json_check.txt"
if "!JSON_STATUS!"=="OK" (
    echo  [92m   PASS: tools/call response is valid JSON-RPC[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: tools/call response is not valid JSON-RPC[0m
    echo          Fix: Check that the MCP server is running and responding
    echo          Try: curl -s -X POST %MCP_URL% -H "Content-Type: application/json" -d "..."
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 3: Response contains collection data ---
echo  [CHECK 3/%TOTAL_CHECKS%] Response contains collection data
python -c "import json;f=open(r'%TEMP_DIR%\health_resp.txt');raw=f.read();f.close();lines=[l for l in raw.splitlines() if l.startswith('data: ')];obj=json.loads(lines[0][6:]) if lines else json.loads(raw);content=obj.get('result',{}).get('content',[]);text=content[0].get('text','{}') if content else '{}';parsed=json.loads(text);found='collections' in str(parsed).lower() or 'weaviate' in str(parsed).lower() or 'ollama' in str(parsed).lower();print('OK' if found else 'MISSING')" > "%TEMP_DIR%\collections_check.txt" 2>&1
set /p COLL_STATUS=<"%TEMP_DIR%\collections_check.txt"
if "!COLL_STATUS!"=="OK" (
    echo  [92m   PASS: Response contains system health data[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Response missing expected system health data[0m
    echo          Fix: Ensure Weaviate and Ollama services are running
    echo          The system_health tool should report on collections, Weaviate, and Ollama
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 4: mcp-call.py file exists and is readable ---
echo  [CHECK 4/%TOTAL_CHECKS%] mcp-call.py exists and is readable
if exist "%MCP_CALL_SRC%" (
    python -c "f=open(r'%MCP_CALL_SRC%');content=f.read();f.close();assert len(content)>100;assert 'initialize' in content;assert 'parse_sse' in content;print('OK')" > "%TEMP_DIR%\src_check.txt" 2>&1
    set /p SRC_STATUS=<"%TEMP_DIR%\src_check.txt"
    if "!SRC_STATUS!"=="OK" (
        echo  [92m   PASS: mcp-call.py exists and contains expected functions[0m
        set /a PASS_COUNT+=1
    ) else (
        echo  [91m   FAIL: mcp-call.py exists but is missing expected content[0m
        echo          Fix: Ensure mcp-call.py has initialize and parse_sse functions
        set /a FAIL_COUNT+=1
    )
) else (
    echo  [91m   FAIL: mcp-call.py not found at %MCP_CALL_SRC%[0m
    echo          Fix: Ensure shared\utils\mcp-call.py exists in the repo
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Python can parse the raw response with json.loads ---
echo  [CHECK 5/%TOTAL_CHECKS%] Python can parse the raw response
python -c "import json;f=open(r'%TEMP_DIR%\health_resp.txt');raw=f.read();f.close();lines=[l for l in raw.splitlines() if l.startswith('data: ')];obj=json.loads(lines[0][6:]) if lines else json.loads(raw);content=obj.get('result',{}).get('content',[]);text=content[0].get('text','{}') if content else '{}';parsed=json.loads(text);print(json.dumps(parsed,indent=2))" > "%TEMP_DIR%\parse_check.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Python parsed raw response through both JSON layers[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Python could not parse the raw response[0m
    echo          Fix: Check the raw response in %TEMP_DIR%\health_resp.txt
    echo          It should be SSE (data: ...) or plain JSON with a result key
    set /a FAIL_COUNT+=1
)
echo.

:: Cleanup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

:: --- RESULTS ---
echo  ======================================================
if %FAIL_COUNT% EQU 0 (
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
    echo.
    echo  [92m   MODULE 5.8 COMPLETE[0m
    echo  [92m   You proved: MCP is JSON-RPC 2.0 over HTTP.[0m
    echo  [92m   Initialize, notify, call, parse. That is the protocol.[0m
    echo  [92m   mcp-call.py automates exactly what you did by hand.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "5.8", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 5.9 — Prompt Chains
    echo  ======================================================
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
