# Module 2.6 Hints — Chain Reactions

## Level 1 — General Direction

- This module requires ALL previous Phase 2 modules (2.1-2.5) to be complete
- The exercise checks for all 4 prerequisite Weaviate classes before starting
- Task 2 runs a full complaint-response chain as a demo — watch each step
- The generated `chain-reactions.bat` offers 3 preset workflows
- Every workflow execution is logged to WorkflowLog

## Level 2 — Specific Guidance

- **"X class not found"**: Complete the corresponding module first. BusinessDoc=2.1, DraftTemplate=2.3, MessageLog=2.4, DocTemplate=2.5
- **Chain output is messy**: Small models sometimes mix up the step labels. The chain still works — the AI just isn't perfect at formatting. The important thing is it uses all the context
- **"No workflows logged"**: Run exercise.bat — Task 2 automatically runs and logs a demo chain. If it failed, check that all services are running
- **WorkflowLog count is 0 after exercise**: The logging step at the end requires Weaviate to be accepting writes. Check: `curl http://localhost:8080/v1/.well-known/ready`
- **chain-reactions.bat not found**: Run exercise.bat — Task 3 generates it

## Level 3 — The Answer

Complete sequence:

**Terminal 1:**
```
ollama serve
```

**Terminal 2:**
```
:: Verify ALL prerequisite classes exist
curl http://localhost:8080/v1/schema | findstr "BusinessDoc"
curl http://localhost:8080/v1/schema | findstr "DraftTemplate"
curl http://localhost:8080/v1/schema | findstr "MessageLog"
curl http://localhost:8080/v1/schema | findstr "DocTemplate"

:: Run exercise
cd phases\phase-2-operators\module-2.6-chain-reactions
exercise.bat

:: Task 2 runs automatically
:: Task 3 lets you test — try:
:: Workflow 1, message: "Your technician was rude and the job was not done right"
:: Workflow 2, message: "I need a quote for bathroom remodel in a 3-bathroom house"
:: Type Q to exit

:: Verify
verify.bat
```

**To check workflow logs:**
```
curl "http://localhost:8080/v1/objects?class=WorkflowLog&limit=5"
```

**If you need to start fresh:**
```
curl -X DELETE http://localhost:8080/v1/schema/WorkflowLog
```
Then run exercise.bat again.
