# Module 5.1 Hints — Lock the Gates

## Level 1 — General Direction

- This module builds on Module 3.4 (Lock It Down). If you passed 3.4, you already have the MCP tools working.
- You need three things running: Ollama, Weaviate, and the ShaneBrain MCP server.
- The exercise uses two OS-level commands (`netstat` and `netsh advfirewall`) plus two MCP tools (`system_health` and `security_log_search`).
- `netstat` and `netsh` are built into Windows — no installation needed.
- If firewall queries fail, you may need to run cmd.exe as Administrator.
- Empty security logs are normal and expected. The verify script gives you a pass.

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: Same fix as every MCP module. The ShaneBrain gateway must be running. Test with: `python shared\utils\mcp-call.py system_health`
- **"netstat command failed"**: This is built into Windows and should always work. If it fails, try opening a new cmd window as Administrator (right-click cmd.exe, "Run as administrator") and running verify.bat from there.
- **"None of the AI service ports detected"**: At least one of Ollama (11434), Weaviate (8080), or MCP (8100) must be running. Start them:
  - Ollama: `ollama serve`
  - Weaviate: `docker start weaviate`
  - MCP: Check your ShaneBrain Docker container
- **"Could not query Windows Firewall"**: The `netsh advfirewall show currentprofile` command requires Administrator privileges on some systems. Right-click cmd.exe, choose "Run as administrator", navigate to this module folder, and run verify.bat again.
- **"Firewall State: OFF"**: Your firewall is disabled. Fix it immediately: `netsh advfirewall set currentprofile state on`. This is a real security issue, not just a training exercise.
- **Services bound to 0.0.0.0**: This means the service accepts connections from any device on your network. If you're running a single-machine setup, rebind to 127.0.0.1 in the service's configuration. For Docker services, check the port mapping in docker-compose.yml (change `0.0.0.0:8080:8080` to `127.0.0.1:8080:8080`).

## Level 3 — The Answer

Complete sequence to pass all 5 checks:

**Step 1: Start all services**
```
ollama serve
docker start weaviate
:: Ensure ShaneBrain MCP container is running
docker start shanebrain-mcp
```

**Step 2: Verify MCP server**
```
python shared\utils\mcp-call.py system_health
```
You should see JSON with service status and collection counts.

**Step 3: Verify netstat works**
```
netstat -an | findstr "LISTENING"
```
You should see multiple lines showing listening ports. Look for 11434, 8080, and 8100.

**Step 4: Verify firewall**
```
netsh advfirewall show currentprofile
```
You should see State: ON. If State is OFF, fix it:
```
netsh advfirewall set currentprofile state on
```

**Step 5: Run the exercise, then verify**
```
cd phases\phase-5-multipliers\module-5.1-lock-the-gates
exercise.bat
verify.bat
```

All 5 checks should pass:
1. MCP server reachable
2. netstat captures listening ports
3. At least 1 AI service port found
4. Firewall status captured
5. security_log_search executes

**Quick reference commands for ongoing security checks:**
```
:: Full port scan
netstat -an | findstr "LISTENING"

:: Check specific AI ports
netstat -an | findstr "11434 8080 8100"

:: Firewall status
netsh advfirewall show currentprofile

:: MCP health
python shared\utils\mcp-call.py system_health

:: Security log search
python shared\utils\mcp-call.py security_log_search "{\"query\":\"failed login\"}"
```
