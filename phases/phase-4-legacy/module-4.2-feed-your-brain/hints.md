# Module 4.2 Hints — Feed Your Brain

## Level 1 — General Direction

- The MCP server must be running before you start. Both `add_knowledge` and `vault_add` talk to ShaneBrain through MCP.
- The exercise adds sample entries automatically — values, memories, and life lessons. You don't need to write anything yourself for the exercise.
- Two different tools store to two different places: `add_knowledge` goes to the Knowledge collection, `vault_add` goes to the PersonalDoc collection (the vault).
- After storing entries, the exercise searches for them using different words to prove semantic search works.
- If searches return empty right after adding, the embeddings may need a moment. Try running verify.bat a second time.

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: The ShaneBrain gateway needs to be running. Check with: `python shared\utils\mcp-call.py system_health`
- **"Could not store work ethic value"** (or any add_knowledge failure): The Knowledge collection may not exist yet. The MCP server should create it on first write. Check that Weaviate is running: `curl http://localhost:8080/v1/.well-known/ready`
- **"Could not store memory"** (or any vault_add failure): Same as above but for the PersonalDoc collection. Check MCP server logs for details.
- **"search_knowledge returned empty results"**: Entries were stored but search found nothing. This can happen if the embedding model isn't loaded yet. Run: `python shared\utils\mcp-call.py search_knowledge "{\"query\":\"family values\"}"` — if it returns empty, wait 30 seconds and try again.
- **"vault_search returned empty results"**: Same issue but for the vault. Verify entries exist: `python shared\utils\mcp-call.py vault_list_categories` — if it shows counts, the data is there and search should find it.
- **JSON errors in the exercise**: If you see Python JSON errors, a previous MCP call may have returned non-JSON output. Check that the MCP server is healthy first.

## Level 3 — The Answer

Complete sequence to get everything working:

**Step 1: Verify services are running**
```
curl http://localhost:11434/api/tags
curl http://localhost:8080/v1/.well-known/ready
python shared\utils\mcp-call.py system_health
```
All three should respond. If any fail, start the missing service.

**Step 2: Run the exercise**
```
cd phases\phase-4-legacy\module-4.2-feed-your-brain
exercise.bat
```
Watch for green PASS lines during each task:
- TASK 1: Three family values added to Knowledge
- TASK 2: Two personal memories added to Vault
- TASK 3: Two life lessons added to Knowledge
- TASK 4: Three searches that find what was stored

**Step 3: Run verification**
```
verify.bat
```
All 5 checks should pass.

**If add_knowledge fails**, try manually:
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Test entry about family\",\"category\":\"family\",\"title\":\"Test\"}"
```

**If vault_add fails**, try manually:
```
python shared\utils\mcp-call.py vault_add "{\"content\":\"Test memory about life\",\"category\":\"personal\",\"title\":\"Test\"}"
```

**If searches return empty after adding**, the embedding model may be cold. Wait 30 seconds and run verify.bat again. The second attempt usually works.

**To add your own real entries after the exercise:**
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Your real value or lesson here\",\"category\":\"family\",\"title\":\"Your Title\"}"
python shared\utils\mcp-call.py vault_add "{\"content\":\"Your real memory or record here\",\"category\":\"personal\",\"title\":\"Your Title\"}"
```

Categories for add_knowledge: family, faith, technical, philosophy, general, wellness
Categories for vault_add: medical, legal, financial, personal, work
