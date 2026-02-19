# Module 2.2 — The Instant Answer Desk

## WHAT YOU'LL BUILD

A Q&A tool that answers business questions with source citations. Ask "what's our cancellation policy?" and get the answer plus exactly which document it came from. This is the tool you'll actually use every day — an employee who has read every document and never forgets.

---

## WHO THIS IS FOR

Anyone who gets asked the same questions over and over. Customers calling about pricing. New hires asking about procedures. Your own brain at 6 AM trying to remember the warranty terms. The Answer Desk handles all of it — instantly, from your own docs.

---

## KEY TERMS

- **Source Citation**: Showing WHERE the answer came from. Not just "the rate is $65/hour" but "the rate is $65/hour (source: pricing.txt [pricing])." Trust requires traceability.

- **Confidence Filtering**: Using vector distance to judge how relevant a search result is. Close distance = high confidence. Far distance = the AI is guessing. Your Answer Desk will flag low-confidence answers so you know when to double-check.

- **Context Window**: The amount of text you can feed to the model along with the question. The llama3.2:1b model has a limited window, so we send the top 2-3 most relevant chunks — not every document. Quality over quantity.

- **Grounded Response**: An answer that comes from your documents, not the model's training data. The system prompt tells the AI: "only use what I give you." That's grounding. That's what makes local AI trustworthy for business.

---

## THE LESSON

### The Answer Desk Architecture

```
QUESTION  →  EMBED  →  SEARCH  →  FILTER  →  PROMPT  →  ANSWER + SOURCES
            (Ollama)  (Weaviate) (distance) (with ctx) (cited response)
```

This builds directly on Module 2.1. Your BusinessDoc collection is the knowledge base. The Answer Desk adds the query interface.

### Step 1: Embed the question

Same as Phase 1 RAG — turn the question into a vector so Weaviate can find similar documents.

### Step 2: Search with metadata

Unlike Phase 1, we now get metadata WITH results:
- **title** — which document matched
- **category** — what type of doc it is
- **distance** — how close the match is (lower = better)

This metadata powers source citations and confidence scoring.

### Step 3: Filter by confidence

Vector distance tells you how relevant the result is:
- **Distance < 0.5**: Strong match. High confidence answer.
- **Distance 0.5 - 0.8**: Moderate match. Answer may be partial.
- **Distance > 0.8**: Weak match. Flag as "low confidence."

Your Answer Desk shows these confidence levels so the operator knows when to trust the AI and when to verify manually.

### Step 4: Generate with citations

The prompt template includes the source documents AND instructions to cite them:

```
Answer using ONLY the business documents below.
After your answer, list which documents you used.
If the documents don't contain the answer, say so.

[Document 1: pricing.txt (category: pricing)]
Our standard rates: Service call fee is $85...

[Document 2: services.txt (category: services)]
We provide residential and commercial services...

QUESTION: What's the service call fee?
ANSWER:
```

The model sees the document labels and includes them in the response. That's your source citation.

---

## THE DAILY USE CASE

Picture this: It's Monday morning. Phone rings.

"Hey, what's your rate for emergency weekend work?"

You type the question into your Answer Desk. Two seconds later:

> Emergency and after-hours calls are billed at 1.5x the standard rate. The standard hourly rate is $65/hour, so emergency rate is $97.50/hour. (Source: pricing.txt)

No digging through files. No calling the boss. No guessing. Your AI read the pricing doc and did the math.

---

## WHAT YOU PROVED

- You can query your business knowledge base with natural language
- Source citations make every answer verifiable
- Confidence scoring tells you when to trust and when to verify
- The Answer Desk pattern works for any business with documents
- This is the foundation for Draft It (2.3) and every tool after

**Next:** Run `exercise.bat` to build your Answer Desk.
