# Module 4.6 Hints — Guard Your Legacy

## Level 1 — General Direction

- The MCP server must be running. All three tools (`system_health`, `security_log_search`, `privacy_audit_search`) go through it.
- This module is standalone — you don't need vault data to run it. But having data from earlier modules makes the collection counts more meaningful.
- Empty security logs and privacy audits on a local system are GOOD. That means nothing suspicious happened. Don't worry if searches return zero results.
- `system_health` is your daily check. `security_log_search` is your weekly review. `privacy_audit_search` is your monthly audit. Build the habit.
- The verify script checks that tools execute without errors — it doesn't require specific log entries to exist.

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: The ShaneBrain MCP gateway isn't running on localhost:8100. Start it before running the exercise or verify.
- **"system_health returned invalid data"**: Weaviate or Ollama may be down. Check both:
  - `curl http://localhost:8080/v1/.well-known/ready` (Weaviate)
  - `curl http://localhost:11434/api/tags` (Ollama)
- **"security_log_search call failed"**: The SecurityLog collection may not exist yet. This happens on fresh systems. The MCP server should handle this gracefully — if it doesn't, the collection gets created on first write.
- **"privacy_audit_search call failed"**: Same as above but for the PrivacyAudit collection. Fresh systems may not have this collection until a privacy-related event occurs.
- **"No data collections found"**: The health report might format collection counts differently than expected. As long as system_health returns valid JSON, you're fine. The verify script gives a pass either way.
- **Security logs have entries you don't recognize**: On a local system, these are usually from your own testing or from services starting up. Review them but don't panic. If you see entries referencing external IPs you don't recognize, that's worth investigating.

## Level 3 — The Answer

Complete sequence to get everything working:

**Step 1: Verify prerequisites**
```
:: Check MCP server
python shared\utils\mcp-call.py system_health

:: Check Weaviate
curl http://localhost:8080/v1/.well-known/ready

:: Check Ollama
curl http://localhost:11434/api/tags
```

**Step 2: Run the exercise**
```
cd phases\phase-4-legacy\module-4.6-guard-your-legacy
exercise.bat
```
Watch for green PASS/CLEAN lines on each task. Empty results are normal.

**Step 3: Run verification**
```
verify.bat
```

**If tools keep failing**, test each one separately:
```
:: Test system health
python shared\utils\mcp-call.py system_health

:: Test security log search
python shared\utils\mcp-call.py security_log_search "{\"query\":\"failed login\"}"

:: Test privacy audit search
python shared\utils\mcp-call.py privacy_audit_search "{\"query\":\"data access\"}"
```

**Manual security posture check:**
```
:: Full posture in three commands
python shared\utils\mcp-call.py system_health
python shared\utils\mcp-call.py security_log_search "{\"query\":\"unauthorized access failed login unusual activity\"}"
python shared\utils\mcp-call.py privacy_audit_search "{\"query\":\"vault access data export personal documents\"}"
```

**If Weaviate won't start:**
```
docker start weaviate
:: Wait 10 seconds, then check
curl http://localhost:8080/v1/.well-known/ready
```

**If Ollama won't respond:**
```
ollama serve
:: In a new terminal, check
curl http://localhost:11434/api/tags
```
