# Module 2.7 Hints — Your Operator Dashboard

## Level 1 — General Direction

- This is the capstone — it requires ALL modules 2.1-2.6 to be complete
- The exercise generates one file: `operator-dashboard.bat` — your daily business AI launcher
- All 5 Weaviate classes must exist AND have data for verification to pass
- The dashboard is self-contained — it includes inline versions of all 5 tools
- Press B in any tool to return to the main dashboard menu

## Level 2 — Specific Guidance

- **"X class not found"**: Complete the corresponding module. BusinessDoc=2.1, DraftTemplate=2.3, MessageLog=2.4, DocTemplate=2.5, WorkflowLog=2.6
- **"Only X/5 collections have data"**: Run the exercise for each empty collection's module. Each exercise populates its collection with sample data
- **"operator-dashboard.bat not found"**: Run this module's exercise.bat — Task 1 generates it
- **"Dashboard missing components"**: The dashboard should reference all 5 tools by name. If it's corrupted, delete it and re-run exercise.bat
- **Tools don't work inside dashboard**: Each tool needs both Ollama and Weaviate running. Check the health section (press H) for status
- **Verify passes but dashboard seems broken**: Try running it directly: `output\operator-dashboard.bat`. Some display issues come from terminal encoding — make sure `chcp 65001` runs at the top

## Level 3 — The Answer

Complete sequence to pass verification:

**Step 1: Verify all prerequisites**
```
:: Check all 5 classes exist
curl http://localhost:8080/v1/schema

:: You should see: BusinessDoc, DraftTemplate, MessageLog, DocTemplate, WorkflowLog
:: If any are missing, go back and run that module's exercise.bat
```

**Step 2: Run the exercise**
```
cd phases\phase-2-operators\module-2.7-operator-dashboard
exercise.bat
```

**Step 3: Test the dashboard**
When the dashboard launches:
1. Check health (H) — all green
2. Try Answer Desk (1) — ask "What are our rates?" then B to go back
3. Try Draft It (2) — "reply about pricing" then B
4. Try Sort (3) — paste a message, then B
5. Quit (Q) to return to exercise

**Step 4: Verify**
```
verify.bat
```

**If verification fails on data counts:**
```
:: Quick fix — re-run each module's exercise
cd ..\module-2.1-load-your-business-brain && exercise.bat
cd ..\module-2.3-draft-it && exercise.bat
cd ..\module-2.4-sort-and-route && exercise.bat
cd ..\module-2.5-paperwork-machine && exercise.bat
cd ..\module-2.6-chain-reactions && exercise.bat
cd ..\module-2.7-operator-dashboard && verify.bat
```

**After completing Phase 2:**
1. Copy `operator-dashboard.bat` to your desktop
2. Replace sample docs in Module 2.1's `business-docs/` with YOUR real documents
3. Re-run Module 2.1's exercise to ingest them
4. Replace sample templates with YOUR best messages
5. Use the dashboard daily — it gets more useful as you add more data
