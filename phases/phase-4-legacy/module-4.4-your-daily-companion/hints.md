# Module 4.4 Hints — Your Daily Companion

## Level 1 — General Direction

- The MCP server, Ollama, and Weaviate all need to be running. MCP talks to both.
- This module has no hard prerequisite — you can journal without completing earlier modules. But completing 4.1-4.3 first gives the briefing more context to work with.
- `daily_note_add` stores notes. `daily_note_search` finds them. `daily_briefing` summarizes them. Three tools, one habit.
- Mood tags are optional but valuable. They build an emotional map over time.
- If the briefing seems thin, add more notes. The AI can only summarize what exists.

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: The ShaneBrain MCP server must be running on port 8100. Check with: `python shared\utils\mcp-call.py system_health`
- **"Could not add journal entry"**: The MCP server handles note storage through Weaviate. If Weaviate is down, notes can't be stored. Check: `curl http://localhost:8080/v1/.well-known/ready`
- **"DailyNote has only X entries (need at least 3)"**: The exercise adds a journal entry, a reflection, and a todo — that's 3 entries minimum. Run exercise.bat to completion before running verify.bat.
- **"daily_note_search returned no results"**: Try a broader query. If "family" returns nothing, the notes may not have been stored successfully. Re-run exercise.bat or add notes manually.
- **"daily_briefing call failed"**: The briefing tool needs Ollama to generate the summary. If Ollama isn't running or has no model loaded, the briefing fails. Check: `curl http://localhost:11434/api/tags`
- **"Briefing is empty or contains an error"**: Ollama may be loading the model into RAM. On constrained hardware this takes 20-30 seconds. Wait and try again.
- **Briefing is too generic**: Add more varied notes. A briefing from three entries will be short. A briefing from twenty entries across a week will be detailed and useful.

## Level 3 — The Answer

Complete sequence to get everything working:

**Step 1: Verify services**
```
python shared\utils\mcp-call.py system_health
```
Look for Weaviate and Ollama both showing healthy. Check that the DailyNote collection exists.

**Step 2: Run the exercise**
```
cd phases\phase-4-legacy\module-4.4-your-daily-companion
exercise.bat
```
This adds three notes (journal, reflection, todo) and generates a briefing.

**Step 3: Run verification**
```
verify.bat
```

**If daily_note_add keeps failing**, test manually:
```
python shared\utils\mcp-call.py daily_note_add "{\"content\":\"Test note\",\"note_type\":\"journal\",\"mood\":\"focused\"}"
```
If that returns an error, check Weaviate. If it succeeds, the exercise script should work too.

**If daily_briefing keeps failing**, test Ollama directly:
```
curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Hello\",\"stream\":false}"
```
If that fails, Ollama needs attention. If it works, the MCP server might need a restart.

**Manual note search:**
```
python shared\utils\mcp-call.py daily_note_search "{\"query\":\"grateful family\"}"
```

**Manual briefing:**
```
python shared\utils\mcp-call.py daily_briefing
```
