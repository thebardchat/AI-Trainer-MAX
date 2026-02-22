# Module 5.5 Hints — Workshop in a Box

## Level 1 — General Direction

- Both the MCP server (localhost:8100) and Ollama (localhost:11434) must be running. MCP handles vault storage and knowledge search. Ollama generates the draft text.
- Module 5.4 should be completed first so your knowledge base has teaching entries. The workshop script still generates without them, but it won't pull from your personal teaching experience.
- `draft_create` does the heavy lifting — it generates both the workshop script and the facilitator checklist. The quality depends on your prompt specificity and what's in your vault.
- `vault_add` stores the generated documents under the "teaching" category. Once stored, `vault_search` can find them by keyword or meaning.
- If drafts are generating but not storing, the issue is likely with `vault_add`, not `draft_create`. Test them separately.
- Draft generation takes 30-60 seconds. The AI is searching vault context AND composing. Be patient on first calls after a cold start.

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: The ShaneBrain MCP gateway is not running. Start it: `docker start shanebrain-mcp` or check that the container is up: `docker ps | findstr shanebrain`
- **"Could not generate workshop script"**: Ollama is likely not running or has no model loaded. Check: `curl http://localhost:11434/api/tags` — you should see at least one model listed.
- **"Could not store in vault"**: The `vault_add` call failed. Test it directly: `python shared\utils\mcp-call.py vault_add "{\"content\":\"test\",\"category\":\"teaching\",\"title\":\"test\"}"` — if this fails, the MCP server or Weaviate may be down.
- **"No workshop documents found in vault"**: The vault_add calls during the exercise may have failed silently. Re-run exercise.bat or store manually (see Level 3).
- **"No teaching knowledge entries found"**: Module 5.4 was not completed. Either complete it first, or add a knowledge entry manually: `python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Tips for teaching local AI to beginners\",\"category\":\"technical\"}"`
- **"Draft content is too short"**: The model may have timed out or returned an error. Check Ollama logs and try again. If the model is too small, responses may be brief — this is normal with llama3.2:1b.
- **Vault search finds 1 document but not 2**: One of the two vault_add calls failed. Check which one by searching for "workshop script" and "facilitator checklist" separately.

## Level 3 — The Answer

Complete sequence to get everything working:

**Step 1: Verify prerequisites**
```
:: Check MCP server
python shared\utils\mcp-call.py system_health

:: Check Ollama has a model
curl http://localhost:11434/api/tags

:: Check for teaching knowledge (from Module 5.4)
python shared\utils\mcp-call.py search_knowledge "{\"query\":\"teaching\"}"
```

**Step 2: Run the exercise**
```
cd phases\phase-5-multipliers\module-5.5-workshop-in-a-box
exercise.bat
```
Watch for green PASS lines on each task. Draft generation takes a moment.

**Step 3: Run verification**
```
verify.bat
```

**If vault_add keeps failing**, store the documents manually:
```
:: Store a workshop script
python shared\utils\mcp-call.py draft_create "{\"prompt\":\"Write a 30-minute workshop script for teaching 5 people how to install Ollama and run their first local AI query. Include a materials list, 3 timed sections, and 2 checkpoints.\",\"draft_type\":\"general\",\"use_vault_context\":true}"

:: Copy the output text, then store it:
python shared\utils\mcp-call.py vault_add "{\"content\":\"[paste workshop script here]\",\"category\":\"teaching\",\"title\":\"Local AI Workshop Script\"}"

:: Generate and store the checklist
python shared\utils\mcp-call.py draft_create "{\"prompt\":\"Write a one-page facilitator checklist for running a local AI workshop. Include pre-workshop setup, materials needed, common problems and solutions, and a post-workshop follow-up plan.\",\"draft_type\":\"general\",\"use_vault_context\":true}"

python shared\utils\mcp-call.py vault_add "{\"content\":\"[paste checklist here]\",\"category\":\"teaching\",\"title\":\"Workshop Facilitator Checklist\"}"
```

**Verify storage worked:**
```
python shared\utils\mcp-call.py vault_search "{\"query\":\"workshop\"}"
```
You should see both documents returned.
