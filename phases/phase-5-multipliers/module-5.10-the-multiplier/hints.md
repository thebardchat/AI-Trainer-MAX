# Module 5.10 Hints — The Multiplier (Capstone)

## Level 1 — General Direction

- This capstone has four sections, one per Phase 5 theme: DEFENDERS, TEACHERS, CONNECTORS, BUILDERS v2
- Prerequisites: All of Modules 5.1-5.9 complete
- The exercise runs eight tasks across the four sections
- MCP server must be running on port 8100 for all sections
- Ollama must be running with a model loaded for the TEACHERS section (Tasks 3-4)
- Section 4 uses raw curl — no mcp-call.py wrapper — so curl must be in your PATH
- Verification checks eight things: MCP connectivity, populated collections, security log search, chat response, teaching draft in vault, vault categories, knowledge entries, and raw MCP curl
- If Ollama is slow on the chat call, wait 30-60 seconds and retry

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: The server must be running on port 8100. Run `shared\utils\mcp-health-check.bat` to diagnose. If the Docker container is stopped, start it with `docker start shanebrain-mcp`
- **"Collections not populated"**: You need at least 2 collections with data and 6+ total entries. If you completed Phase 4, you should already have these. If not, run Phase 4 modules first or add data manually
- **"security_log_search failed"**: This tool searches the SecurityLog collection. It should execute even if there are zero entries — a successful empty search still passes. If the call itself fails, the MCP server may be down
- **"chat_with_shanebrain empty"**: Ollama needs a model loaded. Check with `curl http://localhost:11434/api/tags`. If no model is listed, pull one: `ollama pull llama3.2:1b`. Give the first chat call up to 60 seconds
- **"Teaching draft not in vault"**: The exercise stores a Quick Start Guide via vault_add with category "teaching". If it did not stick, add it manually (see Level 3)
- **"vault_list_categories empty"**: You need at least one document in the vault. Run exercise.bat or add one manually
- **"search_knowledge empty"**: You need at least one knowledge entry. If you ran Phase 4 modules, you should have several. If not, add one manually
- **"Raw MCP curl failed"**: This calls localhost:8100/mcp directly with a JSON-RPC initialize message. Make sure curl is in PATH and the MCP server is running. The check passes if either HTTP 200 is returned or the response file contains data

## Level 3 — The Answer

Complete sequence to pass all 8 verification checks:

**Step 1: Verify MCP server is running**
```
python shared\utils\mcp-call.py system_health
```
If this fails, start the MCP server container.

**Step 2: Check that collections are populated**
```
python shared\utils\mcp-call.py system_health
```
Look at the collections in the output. You need at least 2 with entries and 6+ total. If they are empty, add data:
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Family always comes first.\",\"category\":\"family\",\"title\":\"Core Value\"}"
python shared\utils\mcp-call.py vault_add "{\"content\":\"A test document for the vault.\",\"category\":\"personal\",\"title\":\"Test Entry\"}"
```

**Step 3: Run a security log search**
```
python shared\utils\mcp-call.py security_log_search "{\"query\":\"activity\"}"
```
This should succeed even if there are no security events logged.

**Step 4: Test chat_with_shanebrain**
```
python shared\utils\mcp-call.py chat_with_shanebrain "{\"message\":\"What is local AI?\"}"
```
If Ollama is slow, warm it up first:
```
curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"hello\",\"stream\":false}"
```

**Step 5: Store a teaching draft in the vault**
```
python shared\utils\mcp-call.py vault_add "{\"content\":\"Quick Start Guide: Step 1 Install Ollama. Step 2 Pull a model. Step 3 Run ollama run llama3.2:1b. Step 4 Ask a question. Step 5 Build from there.\",\"category\":\"teaching\",\"title\":\"Quick Start Guide\"}"
```

**Step 6: Check vault categories**
```
python shared\utils\mcp-call.py vault_list_categories
```
Should return at least one category with entries.

**Step 7: Check knowledge entries**
```
python shared\utils\mcp-call.py search_knowledge "{\"query\":\"values knowledge family\"}"
```
Should return at least one entry. If not, add one:
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Hard work builds things that last.\",\"category\":\"philosophy\",\"title\":\"Work Ethic\"}"
```

**Step 8: Test raw MCP curl**
```
curl -s -X POST http://localhost:8100/mcp -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-03-26\",\"capabilities\":{},\"clientInfo\":{\"name\":\"multiplier-test\",\"version\":\"1.0\"}}}"
```
You should see a JSON response with serverInfo and protocolVersion.

**Step 9: Run verification**
```
cd phases\phase-5-multipliers\module-5.10-the-multiplier
verify.bat
```

**After completing this module:**
You have finished the entire AI-Trainer-MAX training — all five phases. You are a multiplier now. You can defend your system, teach someone else from zero, connect and export brains, and build at the protocol level. The next step is not another module. The next step is finding someone who needs what you know and teaching them. One becomes two. Two becomes four. That is how 800 million people learn to own their own AI.
