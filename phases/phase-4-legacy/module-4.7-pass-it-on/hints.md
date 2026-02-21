# Module 4.7 Hints — Pass It On (Capstone)

## Level 1 — General Direction

- This capstone uses three MCP tools: `add_knowledge`, `vault_add`, and `chat_with_shanebrain`
- Prerequisites: Phases 1-3 complete, Modules 4.1-4.6 complete
- The exercise runs five tasks that build a complete YourNameBrain
- Tasks 3 and 5 call Ollama for RAG chat — these need processing time (30-60 seconds)
- Verification checks six things: MCP connectivity, knowledge entries, vault entries, chat response, personal content in the response, and populated collections
- If Ollama is slow, wait and retry — do not assume it failed

## Level 2 — Specific Guidance

- **"Cannot reach MCP server"**: MCP server must be running on port 8100. Run `shared\utils\mcp-health-check.bat`
- **"Knowledge entries not found"**: The exercise adds 4 knowledge entries (3 values + 1 letter). If they did not stick, add them manually using the commands below
- **"Vault entries not found"**: The exercise adds 4 vault documents (3 stories + 1 letter). If they did not stick, add them manually
- **"Chat does not respond"**: Ollama must be running with a model loaded. Check with `curl http://localhost:11434/api/tags`. Give the first chat call up to 60 seconds — Ollama may need to load the model into memory
- **"Response does not reference personal content"**: The brain needs enough content to draw from. If your knowledge base only has 1-2 entries, the AI may not connect them. Add more values and stories, then re-chat
- **"Collections not populated"**: Run `python shared\utils\mcp-call.py system_health` and check the collection counts. LegacyKnowledge and PersonalDoc should both have entries
- **"Letter not stored"**: The letter goes into BOTH knowledge (add_knowledge) AND vault (vault_add). If one fails, run the other manually

## Level 3 — The Answer

Complete sequence to pass verification:

**Step 1: Verify MCP server is running**
```
python shared\utils\mcp-call.py system_health
```

**Step 2: Add family values to knowledge base (3 minimum)**
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Family always comes first. No job is worth more than the people at your dinner table.\",\"category\":\"family\",\"title\":\"Family Comes First\"}"

python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Hard work is not punishment. It is proof that you care enough to show up.\",\"category\":\"philosophy\",\"title\":\"The Value of Hard Work\"}"

python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Tell the truth. Even when it costs you. Your word is the only thing you truly own.\",\"category\":\"family\",\"title\":\"Truth and Integrity\"}"
```

**Step 3: Add life stories to the vault (3 minimum)**
```
python shared\utils\mcp-call.py vault_add "{\"content\":\"The day my first child was born, every plan I ever made rearranged itself. That is not a loss. That is a promotion.\",\"category\":\"personal\",\"title\":\"The Day Everything Changed\"}"

python shared\utils\mcp-call.py vault_add "{\"content\":\"I learned to build things because nobody was going to build them for me. The lesson is always the same — start with the foundation and do not quit.\",\"category\":\"personal\",\"title\":\"How I Learned to Build\"}"

python shared\utils\mcp-call.py vault_add "{\"content\":\"There was a season where I worked two jobs and slept four hours. It taught me you can do more than you think, but you cannot do it forever. Rest is not weakness.\",\"category\":\"personal\",\"title\":\"The Season of Two Jobs\"}"
```

**Step 4: Add the letter to your children (both knowledge AND vault)**
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"To my children: This is my brain. It holds what I believe and what I want you to know. Work hard. Tell the truth. Take care of each other. I love you more than I know how to say.\",\"category\":\"family\",\"title\":\"Letter to My Children\"}"

python shared\utils\mcp-call.py vault_add "{\"content\":\"To my children: This is my brain. It holds what I believe and what I want you to know. Work hard. Tell the truth. Take care of each other. I love you more than I know how to say.\",\"category\":\"personal\",\"title\":\"Letter to My Children\"}"
```

**Step 5: Test the chat**
```
python shared\utils\mcp-call.py chat_with_shanebrain "{\"message\":\"What do you know about my family values?\"}"
```

The response should mention family, hard work, truth, or children — drawn from the entries you just added.

**Step 6: Run verification**
```
cd phases\phase-4-legacy\module-4.7-pass-it-on
verify.bat
```

**If chat_with_shanebrain times out:**
Ollama may need the model loaded first. Run a simple prompt to warm it up:
```
curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"hello\",\"stream\":false}"
```
Then retry the chat command.

**After completing this module:**
You have finished the entire AI-Trainer-MAX training. Your YourNameBrain is live — populated with your values, your stories, and a letter to your children. Maintain it by adding new knowledge regularly, backing up your Weaviate data, and documenting the startup process for your family. Your name. Your brain. Your legacy. Pass it on.
