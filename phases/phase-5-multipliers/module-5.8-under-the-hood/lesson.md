# Module 5.8 — Under the Hood

## WHAT YOU'LL BUILD

Every module since Phase 3 used `mcp-call.py` to talk to the MCP server. You typed a tool name, got back JSON, and moved on. That script was your car dashboard — it hid the engine so you could focus on driving.

This module opens the hood.

You will manually construct JSON-RPC 2.0 requests, fire them at the MCP server with raw `curl`, capture session IDs, and parse SSE (Server-Sent Events) responses by hand. Then you will read through `mcp-call.py` line by line and see exactly how every step maps to what the abstraction does for you.

By the end, the protocol is not magic. It is a handshake, a request, and a response.

---

## KEY TERMS

- **JSON-RPC 2.0**: A protocol for calling remote functions over HTTP. Every request is a JSON object with four fields: `jsonrpc` (always "2.0"), `id` (a number to match responses), `method` (the function name), and `params` (the arguments). The response comes back with the same `id` so you know which request it answers.

- **MCP (Model Context Protocol)**: The wrapper protocol that ShaneBrain uses on top of JSON-RPC 2.0. It adds session management, tool discovery, and structured responses. Runs at `localhost:8100/mcp`.

- **Initialize Handshake**: Before you can call any tools, you must send an `initialize` request. This tells the server who you are, what protocol version you speak, and what capabilities you have. The server responds with its own capabilities and a session ID.

- **Session ID (Mcp-Session-Id)**: A header the server sends back after initialization. You include it in every subsequent request so the server knows you are the same client. Like a wristband at a concert — flash it and you get in.

- **SSE (Server-Sent Events)**: A response format where the server sends data in lines prefixed with `data:`. Instead of plain JSON, you get `data: {"jsonrpc":"2.0",...}`. Your code strips the `data: ` prefix and parses the rest as JSON.

- **Notification**: A JSON-RPC message with no `id` field. The client sends it to tell the server something without expecting a response. The `notifications/initialized` message tells the server "I received your init response, we are good to go."

---

## THE LESSON

### Step 1: The protocol stack

Here is what happens every time `mcp-call.py` runs a tool:

```
1. CLIENT sends POST to http://localhost:8100/mcp
   Headers: Content-Type: application/json
            Accept: application/json, text/event-stream

2. CLIENT sends "initialize" method
   Server responds with capabilities + Mcp-Session-Id header

3. CLIENT sends "notifications/initialized" (no id — it's a notification)

4. CLIENT sends "tools/call" with tool name + arguments
   Includes Mcp-Session-Id header from step 2

5. SERVER responds (possibly as SSE)
   Client strips "data: " prefix, parses JSON, extracts result
```

Five steps. That is the entire protocol. Everything else is details.

### Step 2: The initialize handshake

The first request looks like this:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-03-26",
    "capabilities": {},
    "clientInfo": {
      "name": "manual-test",
      "version": "1.0"
    }
  }
}
```

Breaking it down:
- `jsonrpc: "2.0"` — required by spec, never changes
- `id: 1` — your request number, server echoes it back
- `method: "initialize"` — the handshake method
- `protocolVersion` — which MCP version you speak
- `clientInfo` — who you are (name and version)

The server responds with its own capabilities and sends `Mcp-Session-Id` in the response headers.

### Step 3: The tool call

Once initialized, calling a tool is straightforward:

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "system_health",
    "arguments": {}
  }
}
```

The `params.name` is the tool you want. The `params.arguments` is whatever that tool expects — for `system_health`, it is an empty object.

### Step 4: Parsing SSE responses

The server might respond as plain JSON or as SSE. An SSE response looks like:

```
data: {"jsonrpc":"2.0","id":2,"result":{"content":[{"type":"text","text":"{...}"}]}}
```

Your job: find lines starting with `data: `, strip that prefix, and parse the rest. The actual tool output is nested inside `result.content[0].text` as a JSON string — so you parse it twice (once for the envelope, once for the payload).

### Step 5: Read the abstraction

Open `shared\utils\mcp-call.py` and trace the flow:

- **Lines 35-44 (`mcp_post`)**: The HTTP engine. Builds a request, adds headers, sends it, returns the body and session ID.
- **Lines 47-56 (`parse_sse`)**: The SSE parser. Looks for `data: ` lines, falls back to plain JSON.
- **Lines 59-75 (`initialize`)**: The handshake. Builds the init payload, sends it, extracts the session ID.
- **Lines 78-111 (`call_tool`)**: The tool caller. Initializes if needed, builds the tool call payload, sends it with the session ID, parses the response, extracts the text content.
- **Lines 114-143 (`main`)**: The CLI wrapper. Reads tool name and arguments from command line, calls `call_tool`, prints the result.

Every line maps to one of the five protocol steps. The abstraction handles error cases, retries, and edge cases — but the core flow is exactly what you did by hand.

---

## THE PATTERN

```
INITIALIZE  ->  NOTIFY  ->  CALL TOOL  ->  PARSE SSE  ->  EXTRACT RESULT
 (handshake)   (confirm)   (the work)    (strip data:)   (nested JSON)
```

This is the same pattern every MCP client uses, regardless of language. Python, JavaScript, Rust — the protocol is the protocol. Now you know it.

---

## WHAT YOU PROVED

- JSON-RPC 2.0 is a request-response protocol with numbered IDs
- MCP adds session management and tool calling on top of JSON-RPC
- The initialize handshake must happen before any tool calls
- SSE responses wrap JSON in `data:` lines that need stripping
- `mcp-call.py` automates exactly five steps you can do by hand
- Understanding the protocol means you can debug any MCP failure by dropping to raw curl

**Next:** Run `exercise.bat`
