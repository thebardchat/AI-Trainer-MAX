# Module 5.9 Hints — Prompt Chains

## Level 1 — General Direction

- Three services must be running: MCP server (port 8100), Ollama (port 11434), and Weaviate (port 8080)
- The chain depends on having content in your vault AND knowledge base. Modules 4.2 and 3.1 populate those.
- Each step saves its output to a temp file. The next step reads that file as input. If any step fails, the chain breaks.
- If you get empty or generic outputs, your vault and knowledge base probably need more entries. Go back and add real, personal content.
- The verify script runs the entire chain fresh — it does not reuse exercise outputs

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: The ShaneBrain MCP gateway needs to be running on port 8100. Check with: `python shared\utils\mcp-call.py system_health`
- **"vault_search returned empty results"**: You need personal documents in your vault. Run Module 3.1 or 4.2 to add entries. Test: `python shared\utils\mcp-call.py vault_search "{\"query\":\"personal\"}"`
- **"Step 1 summary too short or empty"**: Ollama is likely not running or not responding. The MCP server handles the search, but Ollama generates the text. Test: `curl http://localhost:11434/api/tags`
- **"Step 2 theme analysis too short"**: Step 2 depends on Step 1 output. If Step 1 failed, Step 2 will also fail. Fix Step 1 first.
- **"Step 3 mission statement too short"**: The `draft_create` tool requires Ollama. If Steps 1 and 2 passed but Step 3 fails, test draft_create directly: `python shared\utils\mcp-call.py draft_create "{\"prompt\":\"Write a test sentence\",\"draft_type\":\"general\"}"`
- **"search_knowledge returned empty"**: Your knowledge base needs entries. Run Module 4.2 to add family, values, and life knowledge. Test: `python shared\utils\mcp-call.py search_knowledge "{\"query\":\"family\"}"`
- **Outputs seem generic or unrelated**: The chain is only as good as its raw material. If your vault has generic sample data, the mission statement will be generic. Replace with real, personal entries.
- **Chain takes a long time**: Each step calls the AI model separately, so the chain takes roughly 3x as long as a single call. On constrained hardware, allow 30-60 seconds per step.

## Level 3 — The Answer

Complete sequence to get the prompt chain working:

**Step 1: Verify all services**
```
python shared\utils\mcp-call.py system_health
```
Look for Weaviate and Ollama both showing healthy.

**Step 2: Verify vault has content**
```
python shared\utils\mcp-call.py vault_search "{\"query\":\"personal values family life\"}"
```
You should see document results. If empty, add content:
```
python shared\utils\mcp-call.py vault_add "{\"content\":\"I believe in hard work, honesty, and putting family first. I'm building a legacy for my five sons.\",\"category\":\"personal\"}"
```

**Step 3: Verify knowledge base has entries**
```
python shared\utils\mcp-call.py search_knowledge "{\"query\":\"family values philosophy\"}"
```
If empty, add entries:
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Family is the foundation. Everything I build is for the next generation.\",\"category\":\"philosophy\"}"
```

**Step 4: Test each chain step manually**

Step 1 — Summarize:
```
python shared\utils\mcp-call.py chat_with_shanebrain "{\"message\":\"Summarize the following in 3 bullet points focusing on themes and values: I believe in hard work, honesty, and putting family first. I am building a legacy for my five sons. Family is the foundation.\"}"
```

Step 2 — Analyze (use the output from Step 1):
```
python shared\utils\mcp-call.py chat_with_shanebrain "{\"message\":\"Identify the 2 most important themes from these bullets and explain why each matters in one sentence: [paste Step 1 output here]\"}"
```

Step 3 — Create (use the output from Step 2):
```
python shared\utils\mcp-call.py draft_create "{\"prompt\":\"Write a one-paragraph personal mission statement based on these themes. Make it direct and personal: [paste Step 2 output here]\",\"draft_type\":\"general\"}"
```

**Step 5: Run the exercise**
```
cd phases\phase-5-multipliers\module-5.9-prompt-chains
exercise.bat
```

**Step 6: Run verification**
```
verify.bat
```

**If Ollama keeps timing out**, test it directly:
```
curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Hello\",\"stream\":false}"
```
If that fails, restart Ollama. If it works but MCP calls fail, restart the MCP server container.
