# Module 4.5 Hints — Write Your Story

## Level 1 — General Direction

- The MCP server and Ollama must both be running. MCP handles the vault search; Ollama generates the draft text.
- Earlier modules (especially 4.2) should be completed first so your vault has personal context. Drafts still work without it, but they'll read like generic greeting cards instead of your words.
- `vault_search` shows you what context exists BEFORE you write. Use it to preview what the AI will pull from.
- `draft_create` does the actual writing. The `draft_type` controls the format (letter, message, general). The `prompt` controls what gets said.
- The more specific your prompt, the better the letter. "Write to my kids" is weak. "Write to my five sons about why hard work matters and what I hope they build" is strong.
- Draft generation takes 30-60 seconds — the AI is searching your vault AND writing. Be patient.

## Level 2 — Specific Guidance

- **"Could not generate letter"**: Ollama is likely not running or has no model loaded. Check: `curl http://localhost:11434/api/tags` — you should see at least one model listed.
- **"draft_create returned empty content"**: The model might have timed out. Try again — sometimes the first call after a cold start takes longer. If it keeps failing, check Ollama logs.
- **Letter doesn't include personal details**: Your vault might be empty or the prompt wasn't specific enough. Add vault documents via Module 4.2 (or Module 3.1), then retry with a more targeted prompt.
- **Letter is too short**: Use the "letter" draft type for longer, structured output. "message" type produces short text. Also, a more detailed prompt produces a more detailed letter.
- **"vault_search returned no results"**: Your vault may be empty. Run Module 4.2 first to store family documents, values, and personal information. The vault is what makes the AI personal.
- **Draft reads too generic**: This means the vault lacks context about your specific life. Store more personal documents — family details, daily journal entries, values statements — then try again.
- **Want to save the final version**: After editing the draft, store it back in your vault: `python shared\utils\mcp-call.py vault_add "{\"content\":\"Your edited letter here\",\"category\":\"personal\",\"title\":\"Letter to My Children\"}"`

## Level 3 — The Answer

Complete sequence to get everything working:

**Step 1: Verify prerequisites**
```
:: Check MCP server
python shared\utils\mcp-call.py system_health

:: Check Ollama has a model
curl http://localhost:11434/api/tags

:: Check vault has documents
python shared\utils\mcp-call.py vault_list_categories
```

**Step 2: Run the exercise**
```
cd phases\phase-4-legacy\module-4.5-write-your-story
exercise.bat
```
Watch for green PASS lines on each task. Draft generation takes a moment.

**Step 3: Run verification**
```
verify.bat
```

**If draft_create keeps failing**, test the pieces separately:
```
:: Test Ollama directly
curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Write a short letter to a son.\",\"stream\":false}"

:: Test vault search (for context)
python shared\utils\mcp-call.py vault_search "{\"query\":\"family values\"}"

:: Test draft creation without vault context
python shared\utils\mcp-call.py draft_create "{\"prompt\":\"Write a short thank you note\",\"draft_type\":\"general\",\"use_vault_context\":false}"

:: Test draft creation with vault context
python shared\utils\mcp-call.py draft_create "{\"prompt\":\"Write a letter to my children about hard work and faith\",\"draft_type\":\"letter\",\"use_vault_context\":true}"
```

**Manual letter creation:**
```
python shared\utils\mcp-call.py draft_create "{\"prompt\":\"Write a heartfelt letter to my children about the values I want them to carry forward\",\"draft_type\":\"letter\",\"use_vault_context\":true}"
```
