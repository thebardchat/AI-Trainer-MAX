@echo off
setlocal enabledelayedexpansion
title Module 5.8 Exercise — Under the Hood

:: ============================================================
:: MODULE 5.8 EXERCISE: Under the Hood
:: Goal: Manually construct JSON-RPC requests, send with raw
::       curl, parse SSE responses, then read the mcp-call.py
::       source to see how the abstraction works.
:: Time: ~15 minutes
:: MCP Tools: system_health (called via RAW CURL — no mcp-call.py)
:: ============================================================

set "TEMP_DIR=%TEMP%\module-5.8"
set "MCP_URL=http://localhost:8100/mcp"
set "MCP_CALL_SRC=%~dp0..\..\..\shared\utils\mcp-call.py"

echo.
echo  ======================================================
echo   MODULE 5.8 EXERCISE: Under the Hood
echo  ======================================================
echo.
echo   Every Phase 3-5 module used mcp-call.py as a black box.
echo   Today you open that box. Raw curl. Raw protocol.
echo.
echo  ------------------------------------------------------
echo.

:: --- Setup temp directory ---
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: ============================================================
:: TASK 1: Initialize the MCP session (the handshake)
:: ============================================================
echo  --------------------------------------------------
echo   TASK 1: Initialize the MCP session
echo  --------------------------------------------------
echo.
echo   Sending the JSON-RPC 2.0 initialize request...
echo   This is the handshake — you tell the server who you
echo   are and what protocol version you speak.
echo.

curl -s -D "%TEMP_DIR%\init_headers.txt" -X POST %MCP_URL% -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-03-26\",\"capabilities\":{},\"clientInfo\":{\"name\":\"manual-test\",\"version\":\"1.0\"}}}" > "%TEMP_DIR%\init_response.txt" 2>&1

:: Check if curl succeeded
if %errorlevel% NEQ 0 (
    echo  [91m   X curl failed. Is the MCP server running at %MCP_URL%?[0m
    echo     Fix: Start the ShaneBrain MCP gateway first.
    pause
    goto :cleanup
)

echo   Raw response:
echo   -------
type "%TEMP_DIR%\init_response.txt"
echo.
echo   -------
echo.

:: Extract session ID from response headers
set "SESSION_ID="
for /f "tokens=2 delims= " %%a in ('findstr /i "mcp-session-id" "%TEMP_DIR%\init_headers.txt" 2^>nul') do (
    set "SESSION_ID=%%a"
)

:: Also try to get session ID from response body via Python
if not defined SESSION_ID (
    python -c "import json;f=open(r'%TEMP_DIR%\init_response.txt');data=f.read();f.close();lines=[l for l in data.splitlines() if l.startswith('data: ')];obj=json.loads(lines[0][6:]) if lines else json.loads(data);sid=obj.get('result',{}).get('sessionId','');print(sid if sid else '')" 2>nul > "%TEMP_DIR%\session_id.txt"
    set /p SESSION_ID=<"%TEMP_DIR%\session_id.txt"
)

:: Strip trailing whitespace / carriage returns from SESSION_ID
if defined SESSION_ID (
    for /f "tokens=* delims= " %%s in ("!SESSION_ID!") do set "SESSION_ID=%%s"
)

echo  [92m   PASS: Initialize handshake sent[0m
if defined SESSION_ID (
    echo   Session ID: !SESSION_ID!
) else (
    echo   [93m   Note: No session ID found in headers — server may not require it[0m
)
echo.

:: ============================================================
:: TASK 2: Send the initialized notification
:: ============================================================
echo  --------------------------------------------------
echo   TASK 2: Send the initialized notification
echo  --------------------------------------------------
echo.
echo   This is a JSON-RPC notification — no "id" field.
echo   It tells the server: "I got your init, we are good."
echo.

if defined SESSION_ID (
    curl -s -X POST %MCP_URL% -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -H "Mcp-Session-Id: !SESSION_ID!" -d "{\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}" > "%TEMP_DIR%\notify_response.txt" 2>&1
) else (
    curl -s -X POST %MCP_URL% -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}" > "%TEMP_DIR%\notify_response.txt" 2>&1
)

echo  [92m   PASS: Initialized notification sent[0m
echo   (Notifications have no response — that is by design)
echo.

:: ============================================================
:: TASK 3: Call system_health with raw curl
:: ============================================================
echo  --------------------------------------------------
echo   TASK 3: Call system_health via tools/call
echo  --------------------------------------------------
echo.
echo   Now the real work — calling a tool. Same endpoint,
echo   different method: "tools/call" instead of "initialize".
echo.

if defined SESSION_ID (
    curl -s -X POST %MCP_URL% -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -H "Mcp-Session-Id: !SESSION_ID!" -d "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"system_health\",\"arguments\":{}}}" > "%TEMP_DIR%\health_response.txt" 2>&1
) else (
    curl -s -X POST %MCP_URL% -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"system_health\",\"arguments\":{}}}" > "%TEMP_DIR%\health_response.txt" 2>&1
)

echo   Raw response from server:
echo   -------
type "%TEMP_DIR%\health_response.txt"
echo.
echo   -------
echo.

:: Parse the response with Python
echo   Parsing SSE response with Python...
echo.
python -c "import json,sys;f=open(r'%TEMP_DIR%\health_response.txt');raw=f.read();f.close();lines=[l for l in raw.splitlines() if l.startswith('data: ')];obj=json.loads(lines[0][6:]) if lines else json.loads(raw);content=obj.get('result',{}).get('content',[]);text=content[0].get('text','{}') if content else '{}';parsed=json.loads(text);print(json.dumps(parsed,indent=2))" > "%TEMP_DIR%\health_parsed.txt" 2>&1

if %errorlevel% EQU 0 (
    echo  [92m   PASS: system_health response parsed successfully[0m
    echo.
    echo   Parsed result:
    echo   -------
    type "%TEMP_DIR%\health_parsed.txt"
    echo.
    echo   -------
) else (
    echo  [93m   WARN: Could not fully parse response — showing raw output[0m
    echo   This may mean the server returned plain JSON instead of SSE.
    echo   Check the raw response above.
)
echo.

:: ============================================================
:: TASK 4: Read mcp-call.py source code
:: ============================================================
echo  --------------------------------------------------
echo   TASK 4: Read the mcp-call.py abstraction
echo  --------------------------------------------------
echo.
echo   Now see how the script does what you just did by hand.
echo.

if exist "%MCP_CALL_SRC%" (
    echo   Source file: %MCP_CALL_SRC%
    echo.
    echo  -------  mcp-call.py source  -------
    echo.
    type "%MCP_CALL_SRC%"
    echo.
    echo  -------  end of source  -------
    echo.
    echo   Key sections to notice:
    echo.
    echo   Lines 35-44  ^(mcp_post^):    HTTP engine — builds request, adds headers, sends POST
    echo   Lines 47-56  ^(parse_sse^):   SSE parser — strips "data: " prefix, falls back to JSON
    echo   Lines 59-75  ^(initialize^):  The handshake — same payload you built in TASK 1
    echo   Lines 78-111 ^(call_tool^):   Tool caller — init + build payload + parse result
    echo   Lines 114-143 ^(main^):       CLI wrapper — reads args, calls call_tool, prints JSON
    echo.
    echo  [92m   PASS: mcp-call.py source displayed[0m
) else (
    echo  [91m   FAIL: mcp-call.py not found at %MCP_CALL_SRC%[0m
    echo     Fix: Ensure shared\utils\mcp-call.py exists in the repo root
)
echo.

:: ============================================================
:: TASK 5: Summary
:: ============================================================
echo  --------------------------------------------------
echo   TASK 5: What you just did
echo  --------------------------------------------------
echo.
echo   1. Sent an "initialize" handshake with JSON-RPC 2.0
echo   2. Sent a "notifications/initialized" notification
echo   3. Called "tools/call" for system_health
echo   4. Parsed SSE "data:" lines into usable JSON
echo   5. Read mcp-call.py and mapped each function to a step
echo.
echo   Every Phase 3-5 module did these same 5 steps.
echo   mcp-call.py just did them for you.
echo.
echo   Now you know what the abstraction does for you.
echo.
echo  [92m   EXERCISE COMPLETE[0m
echo.
echo  ======================================================
echo   Run verify.bat to confirm everything checks out.
echo  ======================================================
echo.

:cleanup
:: --- Cleanup ---
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

endlocal
exit /b 0
