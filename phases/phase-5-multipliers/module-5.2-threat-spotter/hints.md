# Module 5.2 Hints — Threat Spotter

## Level 1 — General Direction

- The MCP server must be running before you start. All four tools (`add_knowledge`, `search_knowledge`, `chat_with_shanebrain`, `security_log_search`) talk to ShaneBrain through MCP.
- The exercise adds five threat definitions automatically — phishing, shoulder surfing, unpatched software, weak passwords, and social engineering. You don't need to write them yourself.
- All threat entries use category "security" in the knowledge base. This keeps them separate from family, faith, or other categories.
- After storing threats, the exercise uses `chat_with_shanebrain` to classify three scenarios. The AI searches your threat taxonomy and reasons about each scenario using YOUR definitions.
- If the AI classification doesn't mention severity levels, your threat definitions may not have been stored yet. Run exercise.bat before verify.bat.

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: The ShaneBrain gateway needs to be running on localhost:8100. Check with: `python shared\utils\mcp-call.py system_health`
- **"Could not store phishing threat"** (or any add_knowledge failure): The Knowledge collection may not exist yet, or Weaviate is down. Check: `curl http://localhost:8080/v1/.well-known/ready`
- **"Found fewer than 5 security knowledge entries"**: Not all five threats were stored. Run exercise.bat again — it will re-add the missing entries. Or add manually using the commands in Level 3.
- **"chat_with_shanebrain returned empty response"**: Ollama may not be running or the model isn't loaded. Check: `curl http://localhost:11434/api/tags` and verify `llama3.2:1b` is listed. If not: `ollama pull llama3.2:1b`
- **"Response missing severity keywords"**: The AI responded but didn't use threat/severity language. This usually means the threat definitions aren't in the knowledge base yet. The AI needs those definitions as RAG context to classify properly. Run exercise.bat first.
- **"security_log_search tool call failed"**: The SecurityLog collection may not exist. Check MCP server health: `python shared\utils\mcp-call.py system_health` — look for SecurityLog in the collection counts.
- **JSON errors**: If you see Python JSON errors, a previous MCP call may have returned non-JSON output. Check that the MCP server is healthy first.

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
cd phases\phase-5-multipliers\module-5.2-threat-spotter
exercise.bat
```
Watch for green PASS lines during each task:
- TASK 1: Five threat definitions stored (phishing, shoulder surfing, unpatched software, weak passwords, social engineering)
- TASK 2: Search verifies threats are findable by meaning
- TASK 3: Three scenarios classified by the AI
- TASK 4: Security logs checked
- TASK 5: Summary displayed

**Step 3: Run verification**
```
verify.bat
```
All 5 checks should pass.

**If add_knowledge fails**, try manually:
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"THREAT: Phishing. SEVERITY: HIGH. Fake emails designed to steal credentials.\",\"category\":\"security\",\"title\":\"Threat - Phishing (HIGH)\"}"
```

**If chat_with_shanebrain fails**, check Ollama:
```
curl http://localhost:11434/api/tags
ollama pull llama3.2:1b
```
Then try manually:
```
python shared\utils\mcp-call.py chat_with_shanebrain "{\"message\":\"What security threats should I watch for?\"}"
```

**If search returns fewer than 5 entries**, add the missing ones:
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"THREAT: Phishing. SEVERITY: HIGH. Fake emails to steal credentials.\",\"category\":\"security\",\"title\":\"Threat - Phishing (HIGH)\"}"
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"THREAT: Shoulder Surfing. SEVERITY: MEDIUM. Someone watching your screen.\",\"category\":\"security\",\"title\":\"Threat - Shoulder Surfing (MEDIUM)\"}"
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"THREAT: Unpatched Software. SEVERITY: HIGH. Outdated software with known vulnerabilities.\",\"category\":\"security\",\"title\":\"Threat - Unpatched Software (HIGH)\"}"
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"THREAT: Weak Passwords. SEVERITY: MEDIUM. Short or reused passwords.\",\"category\":\"security\",\"title\":\"Threat - Weak Passwords (MEDIUM)\"}"
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"THREAT: Social Engineering. SEVERITY: HIGH. Manipulating people into giving up access.\",\"category\":\"security\",\"title\":\"Threat - Social Engineering (HIGH)\"}"
```

**If security_log_search fails**, try:
```
python shared\utils\mcp-call.py security_log_search "{\"query\":\"test\"}"
```
If this returns an error about the collection not existing, the MCP server may need to be restarted to initialize the SecurityLog collection.

**To add your own custom threats after the exercise:**
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"THREAT: USB Drop Attack. SEVERITY: HIGH. Unknown USB drives left in public areas that contain malware.\",\"category\":\"security\",\"title\":\"Threat - USB Drop Attack (HIGH)\"}"
```
