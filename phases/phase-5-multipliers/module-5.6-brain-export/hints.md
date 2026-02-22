# Module 5.6 Hints — Brain Export

## Level 1 — General Direction

- The MCP server must be running before you start. All five tools (`system_health`, `search_knowledge`, `vault_search`, `vault_list_categories`, `daily_note_search`) go through it.
- This module builds on Module 5.3 (Backup and Restore). If you can run backups, you can run exports. The difference is structure — one file instead of many, with a manifest and checksum.
- Empty collections are fine. The export bundle handles zero entries gracefully. Your manifest will show `0` for empty collections and the checksum still works.
- The MD5 checksum uses Python's `hashlib` module, which is part of the standard library. No pip install needed.
- The export file goes to `%TEMP%\module-5.6\brain-export.json`. Copy it somewhere safe after the exercise — the temp folder can get cleaned up.

## Level 2 — Specific Guidance

- **"MCP server not reachable"**: The ShaneBrain MCP gateway is not running on localhost:8100. Start it before running the exercise or verify.
- **"search_knowledge returned invalid format"**: The tool returned something unexpected. Test it directly:
  ```
  python shared\utils\mcp-call.py search_knowledge "{\"query\":\"test\"}"
  ```
  You should see JSON output. If you see an error about the collection not existing, you need to add knowledge entries first (Module 4.2).
- **"vault_search returned invalid format"**: Same issue for the vault. Test:
  ```
  python shared\utils\mcp-call.py vault_search "{\"query\":\"test\"}"
  ```
  If the PersonalDoc collection is empty, that is OK — the verify script accepts empty results as long as the format is valid.
- **"vault_list_categories call failed"**: The vault_list_categories tool needs the PersonalDoc collection to exist. If you have not stored any vault documents, this collection may not exist yet. Add a test document:
  ```
  python shared\utils\mcp-call.py vault_add "{\"content\":\"Test document\",\"category\":\"personal\"}"
  ```
- **"Python could not assemble valid JSON bundle"**: Check that Python 3 is in your PATH and that `json` and `hashlib` are available:
  ```
  python -c "import json, hashlib; print('OK')"
  ```
  If that prints `OK`, the modules are fine. The issue is likely with the temp files — run the exercise again to regenerate them.
- **"No collection counts found"**: The `system_health` response does not contain integer values. This usually means Weaviate is not running or has no collections. Check:
  ```
  curl http://localhost:8080/v1/.well-known/ready
  ```

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

**Step 2: Ensure data exists (if collections are empty)**
```
:: Add a knowledge entry
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Family comes first\",\"category\":\"family\"}"

:: Add a vault document
python shared\utils\mcp-call.py vault_add "{\"content\":\"Test export document\",\"category\":\"personal\"}"

:: Add a daily note
python shared\utils\mcp-call.py daily_note_add "{\"content\":\"Testing brain export\",\"note_type\":\"journal\"}"
```

**Step 3: Run the exercise**
```
cd phases\phase-5-multipliers\module-5.6-brain-export
exercise.bat
```
Follow the prompts. Each task pulls data from one collection. Task 6 assembles the bundle. Task 7 shows the manifest.

**Step 4: Run verification**
```
verify.bat
```

**Step 5: Verify the export file manually**
```
:: Check the file exists
dir %TEMP%\module-5.6\brain-export.json

:: Read the manifest
python -c "import json; b=json.load(open(r'%TEMP%\module-5.6\brain-export.json')); print(json.dumps(b['manifest'],indent=2))"

:: Verify the checksum
python -c "import json,hashlib; b=json.load(open(r'%TEMP%\module-5.6\brain-export.json')); d={'knowledge':b['knowledge'],'vault':b['vault'],'notes':b['notes']}; computed=hashlib.md5(json.dumps(d,sort_keys=True,default=str).encode()).hexdigest(); stored=b['manifest']['checksum']; print('MATCH' if computed==stored else 'MISMATCH'); print('Stored:   '+stored); print('Computed: '+computed)"
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
