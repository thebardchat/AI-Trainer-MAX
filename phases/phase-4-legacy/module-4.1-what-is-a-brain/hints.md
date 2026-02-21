# Module 4.1 Hints — What Is a Brain?

## Level 1 — General Direction

- The MCP server must be running before you start. Everything in this module talks to ShaneBrain through MCP.
- This module is read-only — you're exploring, not changing anything. Nothing you do here will break the brain.
- The exercise uses two tools: `system_health` (check infrastructure) and `search_knowledge` (search the knowledge base)
- If searches return empty, that's fine — the brain might be new. The infrastructure check is what matters most here.
- The collections shown in system_health are the "rooms" of the brain. Each one stores a different type of data.

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: The ShaneBrain gateway needs to be running on localhost:8100. Check with: `python shared\utils\mcp-call.py system_health`
- **"system_health returned empty or invalid data"**: The MCP server responded but returned unexpected data. Check that Weaviate (localhost:8080) and Ollama (localhost:11434) are both running. The MCP server needs both services behind it.
- **"No collections found"**: Weaviate may not have been initialized with the ShaneBrain schema. The MCP server usually creates collections on first use. Try running a simple search to trigger initialization: `python shared\utils\mcp-call.py search_knowledge "{\"query\":\"test\"}"`
- **"Knowledge search returned empty"**: The Knowledge collection may not have entries yet. This is normal for a fresh brain. Module 4.2 will fill it with your knowledge. The verify.bat gives you a pass either way.
- **"No objects in any collection"**: The brain exists but has nothing stored. This means the infrastructure is working — it just needs feeding. Module 4.2 handles that.

## Level 3 — The Answer

Complete sequence to get everything working:

**Step 1: Verify services are running**
```
curl http://localhost:11434/api/tags
curl http://localhost:8080/v1/.well-known/ready
```
Both should return valid responses. If not, start Ollama and Weaviate first.

**Step 2: Verify the MCP server**
```
python shared\utils\mcp-call.py system_health
```
You should see JSON with service status and collection counts. If you get a connection error, start the ShaneBrain MCP server.

**Step 3: Run the exercise**
```
cd phases\phase-4-legacy\module-4.1-what-is-a-brain
exercise.bat
```
Watch for green PASS lines. The exercise has three tasks — vital signs, knowledge search, and collection exploration.

**Step 4: Run verification**
```
verify.bat
```
All 5 checks should pass. Checks 4 and 5 are lenient — they pass even if the brain is empty, because Module 4.2 is where you add content.

**If system_health fails entirely:**
1. Is Weaviate running? `docker start weaviate` or check `docker ps`
2. Is Ollama running? `ollama serve` in another terminal
3. Is the MCP server running? Check localhost:8100
4. Try: `python shared\utils\mcp-call.py system_health` directly to see the error
