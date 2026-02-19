# Module 2.4 Hints — Sort and Route

## Level 1 — General Direction

- This module requires Module 2.1 (BusinessDoc) to be complete
- The exercise creates a MessageLog class and classifies 5 sample messages automatically
- Classification uses the LLM to categorize — results may vary slightly each run
- The generated `sort-and-route.bat` tool logs every classified message to Weaviate
- Categories are: quote_request, complaint, scheduling, payment, general

## Level 2 — Specific Guidance

- **"MessageLog class not found"**: Run exercise.bat — Task 1 creates the schema
- **Classification results seem random**: Small models (1b) can be inconsistent with classification. The prompt is structured to force specific output format (CATEGORY/PRIORITY/ACTION lines). If results are messy, the parsing still extracts what it can
- **"Only X messages in MessageLog"**: Run exercise.bat — Task 2 classifies and stores 5 sample messages. You can also classify more in Task 3
- **sort-and-route.bat not found**: Run exercise.bat — Task 3 generates it in the `output` folder
- **Pipeline says "EMPTY"**: The model may not be following the exact format. Check Ollama is loaded: `curl http://localhost:11434/api/tags`
- **Messages not logging**: Weaviate must be running during classification. Check: `curl http://localhost:8080/v1/.well-known/ready`

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

:: Run exercise
cd phases\phase-2-operators\module-2.4-sort-and-route
exercise.bat

:: Task 2 classifies 5 sample messages automatically
:: Task 3 lets you test your own — try:
:: "I want a quote for a kitchen remodel"
:: "Your team damaged my fence and I want compensation"
:: Type Q to exit

:: Verify
verify.bat
```

**To check logged messages:**
```
curl "http://localhost:8080/v1/objects?class=MessageLog&limit=5"
```

**If you need to start fresh:**
```
curl -X DELETE http://localhost:8080/v1/schema/MessageLog
```
Then run exercise.bat again.
