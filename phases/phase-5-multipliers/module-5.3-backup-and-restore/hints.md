# Module 5.3 Hints — Backup and Restore

## Level 1 — General Direction

- This module uses six MCP tools: `search_knowledge`, `vault_search`, `vault_list_categories`, `system_health`, `add_knowledge`, and `vault_add`
- Prerequisites: Module 4.7 complete (you need data in your brain to back up)
- The exercise exports knowledge and vault data to local JSON files, then verifies counts
- Verification checks six things: MCP connectivity, knowledge export, vault export, collection counts, adding a test entry, and listing vault categories
- If exports come back empty, you may need to run Phase 4 exercises first to populate your collections
- All backup files are saved to a `backups` subfolder inside the module directory

## Level 2 — Specific Guidance

- **"Cannot reach MCP server"**: MCP server must be running on port 8100. Run `shared\utils\mcp-health-check.bat`
- **"search_knowledge returned 0 entries"**: Your knowledge base is empty. Add at least one entry:
  ```
  python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Family comes first.\",\"category\":\"family\",\"title\":\"Core Value\"}"
  ```
- **"vault_search returned 0 entries"**: Your vault is empty. Add at least one document:
  ```
  python shared\utils\mcp-call.py vault_add "{\"content\":\"A story worth keeping.\",\"category\":\"personal\",\"title\":\"First Entry\"}"
  ```
- **"system_health did not return collection counts"**: The MCP server may need a restart. Check Docker is running and the shanebrain-mcp container is up
- **"add_knowledge call failed"**: Same fix as MCP connectivity — verify the server is running and responsive
- **"vault_list_categories returned empty"**: You need at least one vault entry with a category. Add one using the vault_add command above
- **Export files are tiny (under 100 bytes)**: The search query may not match your content. Try a broader query or check what is actually in your collections with `system_health`

## Level 3 — The Answer

Complete sequence to pass verification:

**Step 1: Verify MCP server is running**
```
python shared\utils\mcp-call.py system_health
```
You should see collection names and counts. If this fails, start the MCP container.

**Step 2: Make sure you have knowledge entries**
```
python shared\utils\mcp-call.py search_knowledge "{\"query\":\"family values\"}"
```
If empty, add some:
```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Family always comes first. No job is worth more than the people at your table.\",\"category\":\"family\",\"title\":\"Family First\"}"

python shared\utils\mcp-call.py add_knowledge "{\"content\":\"Hard work is proof you care enough to show up.\",\"category\":\"philosophy\",\"title\":\"Hard Work\"}"
```

**Step 3: Make sure you have vault entries**
```
python shared\utils\mcp-call.py vault_search "{\"query\":\"personal stories\"}"
```
If empty, add some:
```
python shared\utils\mcp-call.py vault_add "{\"content\":\"The day my first child was born changed everything.\",\"category\":\"personal\",\"title\":\"The Day Everything Changed\"}"

python shared\utils\mcp-call.py vault_add "{\"content\":\"I learned to build things because nobody was going to build them for me.\",\"category\":\"personal\",\"title\":\"How I Learned to Build\"}"
```

**Step 4: Verify vault categories exist**
```
python shared\utils\mcp-call.py vault_list_categories
```
Should show at least one category with a count.

**Step 5: Run the exercise**
```
cd phases\phase-5-multipliers\module-5.3-backup-and-restore
exercise.bat
```

**Step 6: Run verification**
```
verify.bat
```

**If system_health shows zero collections:**
The Weaviate database may not have the expected schema. Run a Phase 4 exercise (like 4.2 or 4.7) to populate the collections, then come back to this module.

**If exports succeed but counts seem low:**
The `search_knowledge` and `vault_search` tools return semantically matched results, not a full dump. The count in the export may be less than the total collection count from `system_health`. That is normal — semantic search returns the most relevant matches, not every entry. For a production backup, you would paginate through all entries. This exercise proves the export mechanism works.
