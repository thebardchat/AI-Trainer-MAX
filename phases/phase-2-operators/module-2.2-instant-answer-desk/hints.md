# Module 2.2 Hints — The Instant Answer Desk

## Level 1 — General Direction

- This module requires Module 2.1 to be complete — it uses the BusinessDoc collection
- The exercise generates a standalone `answer-desk.bat` tool you can use daily
- If answers seem wrong, it usually means the business docs are too vague or too short
- Source citations come from the Weaviate metadata (title, category) stored in Module 2.1
- The confidence score is based on vector distance — lower distance means better match

## Level 2 — Specific Guidance

- **"BusinessDoc class not found"**: You need to complete Module 2.1 first. Run its exercise.bat to create the class and load documents
- **"answer-desk.bat not found"**: Run this module's exercise.bat — Task 1 generates it in the `output` folder
- **"No response" or empty answers**: The model may be overloaded. Wait 10 seconds, try a simpler question like "What are the rates?"
- **Answers don't cite sources**: The source citation happens in the Python code that sends results back. If you only see the answer without sources, check that Python is working: `python --version`
- **"Low confidence" on everything**: Your question may be too different from document content. Try questions that use words from your actual documents
- **Verify fails on Q&A check**: This runs a full pipeline query. Make sure Ollama has the model loaded: `curl http://localhost:11434/api/tags`

## Level 3 — The Answer

Complete sequence:

**Terminal 1:**
```
ollama serve
```

**Terminal 2:**
```
:: Verify services
curl http://localhost:11434/api/tags
curl http://localhost:8080/v1/.well-known/ready

:: Verify Module 2.1 is done (should show BusinessDoc objects)
curl "http://localhost:8080/v1/objects?class=BusinessDoc&limit=1"

:: Run exercise
cd phases\phase-2-operators\module-2.2-instant-answer-desk
exercise.bat

:: Test with: "What do we charge per hour?"
:: Then: "What's the cancellation policy?"
:: Type Q to exit

:: Verify
verify.bat
```

**If answers are poor**, the fix is usually better documents in Module 2.1:
- Make docs more specific and detailed
- One topic per file
- Use the actual words your customers use
