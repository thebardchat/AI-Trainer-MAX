# Module 5.8 Hints — Under the Hood

## Level 1 — General Direction

- The MCP server must be running at `localhost:8100` before any of this works. The exercise uses raw `curl` instead of `mcp-call.py` — same server, different client.
- Every request goes to the same endpoint: `http://localhost:8100/mcp` as an HTTP POST.
- The protocol has a strict order: initialize first, then notify, then call tools. Skipping the handshake may cause errors.
- If `curl` returns nothing or an error, the server is not running. Start the ShaneBrain Docker container first.
- SSE responses have a `data: ` prefix on each line. Strip that prefix before parsing the JSON.

## Level 2 — Specific Guidance

- **"curl failed" or no response**: The MCP server is not running. Start it with `docker start shanebrain-mcp` or however your ShaneBrain gateway launches.
- **"HTTP 405 Method Not Allowed"**: You may be using GET instead of POST. All MCP requests must be POST.
- **"Invalid JSON" errors**: Check your escaping. In Windows CMD, double quotes inside the JSON payload need backslash escaping: `\"jsonrpc\"` not `"jsonrpc"`.
- **No session ID found**: Some MCP server versions do not require session IDs for simple tool calls. The exercise handles this — it proceeds without one.
- **Response looks like `data: {...}` instead of clean JSON**: That is SSE format. The Python parsing step strips the `data: ` prefix. This is normal.
- **"mcp-call.py not found"**: The file should be at `shared\utils\mcp-call.py` relative to the repo root. If you moved it, update the path.
- **Python parse fails**: The response might be plain JSON (no `data:` prefix) or the server returned an error. Check the raw response file in `%TEMP%\module-5.8\`.

## Level 3 — The Answer

Here are the exact commands to run manually. Open a terminal and try each one.

**Step 1: Initialize the MCP session**
```
curl -s -X POST http://localhost:8100/mcp -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-03-26\",\"capabilities\":{},\"clientInfo\":{\"name\":\"manual-test\",\"version\":\"1.0\"}}}"
```
You should see a JSON response with `protocolVersion` and server capabilities.

**Step 2: Send the initialized notification**
```
curl -s -X POST http://localhost:8100/mcp -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}"
```
No response expected — notifications are fire-and-forget.

**Step 3: Call system_health**
```
curl -s -X POST http://localhost:8100/mcp -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"system_health\",\"arguments\":{}}}"
```
You should see a response containing Weaviate status, Ollama status, and collection counts.

**Step 4: Parse the response with Python**
Save the response from Step 3 to a file (e.g., `response.txt`), then:
```
python -c "import json; f=open('response.txt'); raw=f.read(); f.close(); lines=[l for l in raw.splitlines() if l.startswith('data: ')]; obj=json.loads(lines[0][6:]) if lines else json.loads(raw); content=obj['result']['content'][0]['text']; print(json.dumps(json.loads(content), indent=2))"
```

**Step 5: Read mcp-call.py**
```
type shared\utils\mcp-call.py
```
Map each function to what you did:
- `mcp_post` = your curl command
- `parse_sse` = your Python one-liner stripping `data:`
- `initialize` = Step 1 above
- `call_tool` = Steps 1 + 2 + 3 combined
- `main` = reading tool name from command line

**Run verification:**
```
cd phases\phase-5-multipliers\module-5.8-under-the-hood
verify.bat
```
All 5 checks should pass.
