# Module 4.3 Hints — Talk to Your Brain

## Level 1 — General Direction

- Module 4.2 must be completed first — your brain needs knowledge entries before you can have a conversation with it
- Three services need to be running: MCP server (port 8100), Ollama (port 11434), and Weaviate (port 8080)
- `search_knowledge` finds matching documents. `chat_with_shanebrain` generates answers FROM those documents.
- If answers feel generic, your knowledge base probably doesn't cover that topic. Go back to Module 4.2 and add more entries.
- The interactive Q&A in Task 4 is for practice — Tasks 1-3 are what the verify script checks

## Level 2 — Specific Guidance

- **"Knowledge base appears empty"**: You need to run Module 4.2 first. That module stores knowledge entries — family values, work lessons, life experiences. Without those entries, the brain has nothing to search or answer from.
- **"chat_with_shanebrain did not respond"**: This usually means Ollama is not running. The MCP server handles the search step, but Ollama generates the actual answer text. Check: `curl http://localhost:11434/api/tags`
- **"Response was empty or contained an error"**: The model might be loading into RAM. Ollama loads models on first use — give it 30 seconds and try again. On constrained hardware, the model takes a moment to warm up.
- **Answers seem wrong or unrelated**: RAG answers come from your stored knowledge entries. If you stored generic sample data in Module 4.2, the answers will be generic. Replace with real, personal knowledge for meaningful answers.
- **"search_knowledge returned empty results"**: Try a broader query. If "fishing with my boys" returns nothing, try "family" or "sons." Semantic search finds related concepts, but there needs to be some overlap in meaning.
- **Answers are too short**: Your knowledge entries may be too brief. Longer, more detailed entries give the AI more context to work with when generating answers.

## Level 3 — The Answer

Complete sequence to get everything working:

**Step 1: Verify Module 4.2 completed**
```
cd phases\phase-4-legacy\module-4.2-feed-your-brain
verify.bat
```
All checks should pass. If not, run that module's exercise.bat first.

**Step 2: Verify all services**
```
python shared\utils\mcp-call.py system_health
```
Look for Weaviate and Ollama both showing healthy.

**Step 3: Test search manually**
```
python shared\utils\mcp-call.py search_knowledge "{\"query\":\"family values\"}"
```
You should see knowledge entries come back. If empty, run Module 4.2.

**Step 4: Test chat manually**
```
python shared\utils\mcp-call.py chat_with_shanebrain "{\"message\":\"What do you know about me?\"}"
```
You should get a paragraph or more of response text grounded in your knowledge.

**Step 5: Run the exercise**
```
cd phases\phase-4-legacy\module-4.3-talk-to-your-brain
exercise.bat
```

**Step 6: Run verification**
```
verify.bat
```

**If chat_with_shanebrain keeps failing**, test Ollama directly:
```
curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Hello\",\"stream\":false}"
```
If that fails, Ollama needs attention. If it works, the MCP server might need a restart.
