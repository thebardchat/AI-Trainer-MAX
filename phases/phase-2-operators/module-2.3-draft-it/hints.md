# Module 2.3 Hints — Draft It

## Level 1 — General Direction

- This module requires Module 2.1 (BusinessDoc) and 2.2 to be complete
- The exercise creates a DraftTemplate class AND seeds 5 starter templates
- Templates are stored in Weaviate just like business docs — with embeddings for semantic matching
- Tone options are: professional, friendly, firm. The AI adjusts language style accordingly
- The generated `draft-it.bat` is a standalone tool you can use daily

## Level 2 — Specific Guidance

- **"DraftTemplate class not found"**: Run exercise.bat — Task 1 creates the schema and seeds templates
- **"BusinessDoc class not found"**: Complete Module 2.1 first
- **Drafts are generic / don't include real numbers**: Make sure your BusinessDoc collection has specific data. Vague docs produce vague drafts
- **Templates seeding shows all warnings**: Templates may already exist from a previous run. Warnings about duplicates are safe to ignore — the count just needs to be 3+
- **"draft-it.bat not found"**: Run exercise.bat — Task 2 generates it in the `output` folder
- **Tone doesn't seem to change**: Small models (1b) are less sensitive to tone instructions. Try making the tone difference more obvious: "friendly" vs "firm" shows more contrast than "professional" vs "friendly"

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
curl http://localhost:8080/v1/schema | findstr "DraftTemplate"

:: Run exercise
cd phases\phase-2-operators\module-2.3-draft-it
exercise.bat

:: Test with:
:: Request: "reply to customer about our rates"
:: Tone: friendly
:: Then: "send payment reminder for overdue invoice"
:: Tone: firm
:: Type Q to exit

:: Verify
verify.bat
```

**To add your own templates:**
Save your best real messages as DraftTemplate objects using the same Python pattern from the exercise. Replace the placeholder content with your actual messages.

**If you need to start fresh:**
```
curl -X DELETE http://localhost:8080/v1/schema/DraftTemplate
```
Then run exercise.bat again.
