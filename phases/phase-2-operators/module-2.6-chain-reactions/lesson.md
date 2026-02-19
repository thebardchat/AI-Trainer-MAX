# Module 2.6 — Chain Reactions

## WHAT YOU'LL BUILD

Multi-step workflows that chain all your previous tools together. A complaint comes in — it gets classified, the relevant policy gets found, a response gets drafted, and the whole chain gets logged. One input, four operations, zero manual handoffs. This is where individual tools become an automated business system.

---

## WHO THIS IS FOR

Anyone who handles repetitive multi-step processes. A new lead comes in and you always do the same five things. A complaint arrives and the response process is always the same. A job finishes and the wrap-up paperwork follows the same pattern. If you can describe the chain, the AI can run it.

---

## KEY TERMS

- **Workflow**: A defined sequence of operations that run in order. Step 1's output feeds Step 2's input, and so on. Like an assembly line for information processing.

- **WorkflowLog**: The Weaviate class that records every workflow execution. Stores the workflow name, the original input, the steps that ran, the final output, and a timestamp. Your audit trail.

- **Chain**: Connecting multiple tools so they run automatically in sequence. Classify → Search → Draft → Save. Each link in the chain takes the previous result and acts on it.

- **Trigger**: What starts the workflow. A customer message, a job completion, a daily schedule. The chain reacts to the trigger and runs every step without you touching it.

---

## THE LESSON

### Why Chains Matter

You've built five tools:
1. **Business Brain** (2.1) — Knowledge base
2. **Answer Desk** (2.2) — Q&A with citations
3. **Draft It** (2.3) — Message drafting
4. **Sort and Route** (2.4) — Message triage
5. **Paperwork Machine** (2.5) — Document generation

Each one is useful alone. But the real power is connecting them. A single customer message can trigger a chain that classifies it, finds the relevant policy, drafts a response, generates a follow-up document, and logs the whole thing. Five steps, zero manual work between them.

### The Chain Architecture

```
INPUT  →  STEP 1 (Classify)  →  STEP 2 (Search)  →  STEP 3 (Draft/Generate)  →  LOG
          (Sort & Route)        (Answer Desk)        (Draft It / Paperwork)     (WorkflowLog)
```

### Step 1: Create the WorkflowLog schema

| Property | Type | Purpose |
|----------|------|---------|
| workflowName | text | Which workflow ran ("complaint-response") |
| input | text | The original trigger input |
| steps | text | JSON string of each step and its result |
| finalOutput | text | The end result of the chain |
| timestamp | text | When the workflow ran |

### Step 2: Define your workflows

The exercise builds three preset workflows:

**Complaint Response Chain:**
1. Classify the message (Sort and Route)
2. Find relevant policy (Answer Desk)
3. Draft a professional response (Draft It)
4. Log the entire chain (WorkflowLog)

**New Lead Chain:**
1. Classify as quote request (Sort and Route)
2. Pull pricing info (Answer Desk)
3. Draft a welcome + quote message (Draft It)
4. Generate an estimate (Paperwork Machine)
5. Log the chain (WorkflowLog)

**Job Completion Chain:**
1. Generate a job report (Paperwork Machine)
2. Draft a follow-up message to customer (Draft It)
3. Log the chain (WorkflowLog)

### Step 3: Run the chain

Feed a message into the workflow selector. It matches the best workflow, runs every step in sequence, shows you each step's output, and logs the whole chain for your records.

### Step 4: Review the log

WorkflowLog shows you what happened at every step. If a response went out wrong, you can trace back through the chain to find where. Full audit trail, full accountability.

---

## THE DAILY USE CASE

Email comes in: "I'm not happy with the work your team did yesterday. The leak is still there."

You paste it into Chain Reactions. The complaint-response workflow fires:

1. **Classify**: complaint / HIGH priority / "Respond within 24 hours"
2. **Search**: Finds your warranty policy (90-day labor warranty) and complaint procedure (respond within 7 days)
3. **Draft**: Generates a professional response acknowledging the issue, referencing your warranty, and committing to a follow-up visit

All logged. All traceable. What used to take 15 minutes of reading policies and writing from scratch now takes 15 seconds.

---

## WHAT YOU PROVED

- You can chain multiple AI tools into automated workflows
- Multi-step processes run without manual handoffs between tools
- WorkflowLog provides a complete audit trail of every chain
- Preset workflows handle your most common business scenarios
- This is the pattern that turns individual tools into a business system

**Next:** Run `exercise.bat` to build your workflow chains.
