# Module 2.4 — Sort and Route

## WHAT YOU'LL BUILD

A message triage system that classifies incoming messages, assigns priority levels, and suggests actions. Feed it a customer email, a vendor question, or a complaint — it tells you what category it is, how urgent it is, and what to do next. Like having a dispatcher who reads every message before you do.

---

## WHO THIS IS FOR

Anyone drowning in messages. Emails, texts, voicemail transcripts, web form submissions. If you spend your first hour every morning just figuring out what to deal with first, this tool cuts that to minutes.

---

## KEY TERMS

- **MessageLog**: The Weaviate class that stores classified messages. Each entry has the original content, assigned category, priority level, suggested action, and timestamp. It's your message history with built-in intelligence.

- **Classification**: Sorting a message into a category — quote request, complaint, scheduling, payment, general inquiry. The AI reads the message and picks the best fit based on content, not keywords.

- **Priority Scoring**: Rating urgency on a scale — HIGH (needs action today), MEDIUM (needs action this week), LOW (informational, no rush). Based on the message content and category.

- **Action Suggestion**: The AI doesn't just classify — it tells you what to do. "Send quote within 24 hours." "Escalate to owner." "Reply with FAQ link." Specific, actionable next steps.

- **Triage**: Military term for sorting casualties by urgency. Same concept applied to your inbox. Handle the critical stuff first, batch the routine stuff, file the rest.

---

## THE LESSON

### The Triage Architecture

```
MESSAGE  →  CLASSIFY  →  PRIORITIZE  →  SUGGEST ACTION  →  LOG
            (category)   (high/med/low)  (next step)      (MessageLog)
```

One message in, four useful data points out. Every classified message gets logged so you can track patterns over time.

### Step 1: Create the MessageLog schema

| Property | Type | Purpose |
|----------|------|---------|
| content | text | The original message text |
| category | text | quote_request, complaint, scheduling, payment, general |
| priority | text | HIGH, MEDIUM, LOW |
| suggestedAction | text | What to do next |
| timestamp | text | When it was classified |

### Step 2: Define your categories

The exercise uses five categories that fit most small businesses:

| Category | Description | Typical Priority |
|----------|-------------|-----------------|
| quote_request | Customer wants pricing or estimate | MEDIUM-HIGH |
| complaint | Customer is unhappy about something | HIGH |
| scheduling | Appointment requests or changes | MEDIUM |
| payment | Invoice questions, payment issues | MEDIUM-HIGH |
| general | Everything else — info requests, thanks | LOW |

### Step 3: Classify with context

The AI classifies messages using two inputs:
1. **The message itself** — what the person actually wrote
2. **Your business docs** — to understand your services and policies

A message saying "I need you here tomorrow, the pipe burst" gets classified as `scheduling` with `HIGH` priority and a suggested action of "Schedule emergency visit, bill at 1.5x rate."

### Step 4: Log and track patterns

Every classified message gets stored in MessageLog. Over time, you see patterns:
- How many complaints vs. quote requests per week?
- What's your average priority distribution?
- Which types of messages take the most time?

Data-driven decisions instead of gut feelings.

---

## THE DAILY USE CASE

Monday morning. 12 new messages from the weekend. Instead of reading each one:

1. Paste them into Sort and Route
2. Get back a sorted list:
   - 2 HIGH priority (complaint + emergency scheduling)
   - 4 MEDIUM priority (quote requests + payment questions)
   - 6 LOW priority (general inquiries + thank you notes)
3. Handle the HIGHs first. Batch the MEDIUMs. File the LOWs.

Twenty minutes instead of an hour.

---

## WHAT YOU PROVED

- You can automatically classify business messages by category
- Priority scoring ensures you handle urgent items first
- Action suggestions tell you exactly what to do next
- MessageLog tracks everything for pattern analysis
- Triage thinking applies to any business that handles communications

**Next:** Run `exercise.bat` to build your triage system.
