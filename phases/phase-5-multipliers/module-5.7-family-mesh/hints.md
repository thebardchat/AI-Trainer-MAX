# Module 5.7 Hints — Family Mesh

## Level 1 — General Direction

- This module uses five MCP tools: `add_knowledge`, `search_knowledge`, `chat_with_shanebrain`, `search_friends`, and `get_top_friends`
- Prerequisites: Module 5.6 (Brain Export) and Module 4.7 (Pass It On)
- The exercise creates 9 knowledge entries across 3 category namespaces: brain-dad, brain-mom, brain-kid
- Cross-brain queries use `chat_with_shanebrain` which searches ALL knowledge regardless of category
- Scoped searches use the `category` parameter in `search_knowledge` to prove isolation
- The social graph checks (get_top_friends, search_friends) may return empty results if you have not added friend profiles — that is OK, the tool just needs to respond
- If Ollama is slow on the chat queries, wait 30-60 seconds and retry

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: The MCP server must be running on port 8100. Run `shared\utils\mcp-health-check.bat` to diagnose
- **"No entries found in brain-dad"**: The exercise adds 3 entries with `category` set to `brain-dad`. If they did not stick, add them manually using the commands in Level 3
- **"No entries found in brain-mom"**: Same issue — the `category` parameter must be exactly `brain-mom` (lowercase, hyphenated). Check spelling
- **"No entries found in brain-kid"**: Same pattern — `category` must be `brain-kid`
- **"Cross-brain chat failed"**: Ollama must be running with a model loaded. Warm it up first: `curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"hello\",\"stream\":false}"`
- **"Chat returned empty"**: The RAG search may not find the brain-* entries if they were just added. Wait a few seconds for Weaviate to index, then retry
- **"get_top_friends failed"**: Try `search_friends` instead — the verify script tries both. If both fail, the MCP server may need a restart
- **"Social graph is empty"**: That is expected if you have not populated friend profiles in earlier modules. The check passes as long as the tool responds — it does not require data

## Level 3 — The Answer

Complete sequence to pass verification:

**Step 1: Verify MCP server is running**
```
python shared\utils\mcp-call.py system_health
```

**Step 2: Add brain-dad entries (3 minimum)**
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"To fix a leaky faucet, turn off the water supply, remove the handle, replace the washer, reassemble.\",\"category\":\"brain-dad\",\"title\":\"Plumbing Basics\"}"

python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Change oil every 5000 miles. Rotate tires every 7500 miles. Replace air filter yearly.\",\"category\":\"brain-dad\",\"title\":\"Car Maintenance\"}"

python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Family budget 50-30-20 rule: 50 percent needs, 30 percent wants, 20 percent savings.\",\"category\":\"brain-dad\",\"title\":\"Family Budget\"}"
```

**Step 3: Add brain-mom entries (3 minimum)**
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Chicken and dumplings: Boil chicken, shred it, make dough from flour and broth, drop into simmering broth.\",\"category\":\"brain-mom\",\"title\":\"Family Recipe\"}"

python shared\utils\mcp-call.py add_knowledge "{\"content\":\"School lets out 3:15 PM Monday-Friday. Early release Wednesday at 1:30. Baseball practice Tues/Thurs until 5.\",\"category\":\"brain-mom\",\"title\":\"School Schedule\"}"

python shared\utils\mcp-call.py add_knowledge "{\"content\":\"For cuts: clean, pressure, bandage. For burns: cool water 10 minutes. Youngest allergic to tree nuts. EpiPen in kitchen.\",\"category\":\"brain-mom\",\"title\":\"First Aid\"}"
```

**Step 4: Add brain-kid entries (3 minimum)**
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Fractions: find common denominator for addition. Multiply straight across. For division, flip and multiply.\",\"category\":\"brain-kid\",\"title\":\"Math Homework\"}"

python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Minecraft: punch trees first day, build shelter before night, never dig straight down, diamonds below Y-16.\",\"category\":\"brain-kid\",\"title\":\"Game Rules\"}"

python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Best friend Marcus lives on Oak Street. We ride bikes on Fridays. His birthday is March 15. Building a treehouse this summer.\",\"category\":\"brain-kid\",\"title\":\"Best Friend\"}"
```

**Step 5: Test cross-brain query**
```
python shared\utils\mcp-call.py chat_with_shanebrain "{\"message\":\"Who in the family knows about fixing things around the house?\"}"
```

**Step 6: Test social graph**
```
python shared\utils\mcp-call.py get_top_friends "{\"limit\":5}"
python shared\utils\mcp-call.py search_friends "{\"query\":\"family\"}"
```

**Step 7: Run verification**
```
cd phases\phase-5-multipliers\module-5.7-family-mesh
verify.bat
```

**If chat_with_shanebrain times out:**
Warm up Ollama first:
```
curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"hello\",\"stream\":false}"
```
Then retry the chat command.

**After completing this module:**
You have proved that knowledge categories can serve as brain namespaces — isolating each family member's knowledge while still allowing cross-brain queries. This is the foundation of multi-brain architecture. The next step (in a real deployment) would be separate MCP servers per family member, each on their own device, with a mesh layer that routes queries to the right brain.
