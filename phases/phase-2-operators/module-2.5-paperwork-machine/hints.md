# Module 2.5 Hints — Paperwork Machine

## Level 1 — General Direction

- This module requires Module 2.1 (BusinessDoc) and 2.3 (DraftTemplate concepts) to be complete
- The exercise creates a DocTemplate class with 4 document templates
- Generated documents save to the `output/documents/` folder as .txt files
- The tool matches your request to the best template, then fills it with your business data
- Document types: estimate, report, checklist, letter

## Level 2 — Specific Guidance

- **"DocTemplate class not found"**: Run exercise.bat — Task 1 creates the schema and seeds templates
- **Documents look generic**: The AI can only use data from your BusinessDoc collection. More specific business docs = better generated documents
- **"paperwork-machine.bat not found"**: Run exercise.bat — Task 2 generates it
- **Documents don't save**: The `output/documents/` folder must exist. The exercise creates it automatically. Check write permissions if on an external drive
- **Template seeding shows warnings**: Duplicates are harmless. The verify check just needs 3+ templates
- **Generated numbers are wrong**: The AI pulls from your pricing.txt in BusinessDoc. Update that document with your real rates and run Module 2.1's exercise again

## Level 3 — The Answer

Complete sequence:

**Terminal 1:**
```
ollama serve
```

**Terminal 2:**
```
:: Verify prerequisites
curl http://localhost:8080/v1/schema | findstr "BusinessDoc"
curl http://localhost:8080/v1/schema | findstr "DocTemplate"

:: Run exercise
cd phases\phase-2-operators\module-2.5-paperwork-machine
exercise.bat

:: Test with:
:: "estimate for fixing a leaky roof at 123 Main St for John Smith"
:: "daily report for the Johnson renovation, replaced 3 windows"
:: Type Q to exit

:: Check generated documents
dir output\documents\*.txt

:: Verify
verify.bat
```

**If you need to start fresh:**
```
curl -X DELETE http://localhost:8080/v1/schema/DocTemplate
```
Then run exercise.bat again.
