# Module 2.1 Hints — Load Your Business Brain

## Level 1 — General Direction

- Both Ollama and Weaviate must be running before you start the exercise
- The exercise creates sample business documents automatically — you don't need to write them yourself
- If you already have business documents, put them as .txt files in the `business-docs` folder before running
- Category tagging happens automatically based on filename — name your files clearly (pricing.txt, policies.txt, etc.)
- The exercise uses the same ingestion pattern from Module 1.3, just with a new Weaviate class

## Level 2 — Specific Guidance

- **"BusinessDoc class not found"**: The exercise creates it automatically. If it failed, check Weaviate is running: `curl http://localhost:8080/v1/.well-known/ready`
- **"Failed to get embedding"**: Ollama might be overloaded. Wait 10 seconds and try again. Check with: `curl http://localhost:11434/api/tags`
- **"Failed to build payload"**: This means Python isn't in PATH. Fix: ensure `python --version` works in your terminal
- **"No documents were ingested"**: Check that .txt files exist in the business-docs folder. Run: `dir business-docs\*.txt`
- **Category shows as "general"**: The auto-tagger looks for keywords in the filename. Rename your files to include words like "pricing", "policy", "service", "faq", or "procedure"
- **Verify fails on object count**: If you ran the exercise multiple times, the objects may have duplicates. That's fine — the count just needs to be 3 or more

## Level 3 — The Answer

Complete sequence to get everything working:

**Terminal 1:**
```
ollama serve
```

**Terminal 2:**
```
:: Make sure Weaviate is running
docker start weaviate

:: Verify both services
curl http://localhost:11434/api/tags
curl http://localhost:8080/v1/.well-known/ready

:: Run the exercise
cd phases\phase-2-operators\module-2.1-load-your-business-brain
exercise.bat

:: When exercise finishes, test with a question like:
:: "What do we charge per hour?"
:: Then type Q to exit

:: Run verification
verify.bat
```

**If you need to start fresh** (delete the BusinessDoc class and recreate):
```
curl -X DELETE http://localhost:8080/v1/schema/BusinessDoc
```
Then run `exercise.bat` again.

**Adding your own documents:**
1. Put .txt files in the `business-docs` folder
2. Name them clearly: `pricing.txt`, `company-policies.txt`, etc.
3. Run `exercise.bat` again — it will ingest the new files
4. Run `verify.bat` to confirm
