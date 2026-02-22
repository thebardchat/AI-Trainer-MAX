# Module 5.4 Hints — Teach the Teacher

## Level 1 — General Direction

- Modules 4.2 and 4.3 must be completed first — your brain needs to already have knowledge entries and the ability to chat
- Three services need to be running: MCP server (port 8100), Ollama (port 11434), and Weaviate (port 8080)
- This module adds 5 entries with `category: "teaching"` — these are separate from your family/faith/philosophy entries
- `add_knowledge` stores entries. `search_knowledge` finds them. `chat_with_shanebrain` uses them to generate answers.
- If the brain's teaching answers sound generic, your teaching entries might not be getting retrieved. Check that they stored correctly.

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: The ShaneBrain MCP gateway must be running on port 8100. Check with: `python shared\utils\mcp-call.py system_health`
- **"Found only X teaching entries (need at least 5)"**: The exercise adds 5 entries with `category: "teaching"`. If some failed to store, run the exercise again — `add_knowledge` will add new entries (it does not deduplicate). You can also add entries manually with: `python shared\utils\mcp-call.py add_knowledge "{\"content\":\"...\",\"category\":\"teaching\",\"title\":\"...\"}"`
- **"chat_with_shanebrain did not respond"**: Ollama generates the answer text. If the MCP server is healthy but chat fails, Ollama is likely not running. Check: `curl http://localhost:11434/api/tags`
- **"Response was too short or contained an error"**: The model may still be loading into RAM. Wait 30 seconds and try again. On constrained hardware (under 4GB free), the first response can be slow.
- **"search_knowledge returned empty results"**: Try a broader query. If searching for "teaching" returns nothing, try "explain" or "beginner." The entries use words like "beginner," "explanation," "plain English" — semantic search should match those.
- **Teaching answers don't use your analogies**: The AI generates freely from retrieved context. It may rephrase your analogies. That's normal. What matters is that the answer is grounded in your entries, not pulled from generic training data.

## Level 3 — The Answer

Complete sequence to get everything working:

**Step 1: Verify prerequisites**
```
cd phases\phase-4-legacy\module-4.2-feed-your-brain
verify.bat
cd ..\module-4.3-talk-to-your-brain
verify.bat
```
Both should pass. If not, run those exercises first.

**Step 2: Verify all services**
```
python shared\utils\mcp-call.py system_health
```
Look for Weaviate and Ollama both showing healthy.

**Step 3: Run the exercise**
```
cd phases\phase-5-multipliers\module-5.4-teach-the-teacher
exercise.bat
```
This adds all 5 teaching entries and tests the brain.

**Step 4: If exercise had failures, add entries manually**
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Ollama is a free program that runs AI on your own computer with no internet needed. Like a calculator for words that stays completely private.\",\"category\":\"teaching\",\"title\":\"What is Ollama — Beginner Explanation\"}"
```
Repeat for each concept: Vector, RAG, MCP, YourNameBrain.

**Step 5: Verify teaching entries stored**
```
python shared\utils\mcp-call.py search_knowledge "{\"query\":\"teaching beginner explanation\"}"
```
You should see 5 or more results with teaching-related titles.

**Step 6: Test the brain as teacher**
```
python shared\utils\mcp-call.py chat_with_shanebrain "{\"message\":\"What is Ollama? Explain it simply.\"}"
```
You should get a substantive paragraph grounded in your teaching entry.

**Step 7: Run verification**
```
verify.bat
```

**If chat_with_shanebrain keeps failing**, test Ollama directly:
```
curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Hello\",\"stream\":false}"
```
If that fails, Ollama needs attention. If it works, restart the MCP server.
