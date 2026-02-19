# Module 2.1 — Load Your Business Brain

## WHAT YOU'LL BUILD

A searchable knowledge base from YOUR real business documents. By the end of this module, your AI can answer questions about your business — pricing, policies, procedures, anything you feed it — without the internet.

Think of it like this: Phase 1, you built an engine. Now you're filling the tank with YOUR fuel. A local AI with no business context is just a fancy autocomplete. A local AI loaded with your SOPs, price lists, and customer FAQs? That's an operator's edge.

---

## WHO THIS IS FOR

Small business owners. Dispatchers. Contractors. Anyone who has documents scattered across folders and needs answers fast. You don't need to be technical — if you finished Phase 1, you have everything you need.

---

## KEY TERMS

- **Business Knowledge Base**: Your company's documents stored as vectors so AI can search them by meaning, not just keywords. Like giving your AI employee a filing cabinet and a photographic memory.

- **BusinessDoc**: The Weaviate class we create in this module. Each document gets a title, content, category (like "pricing" or "policy"), and source path. Separate from Phase 1's classes — your business data stays organized.

- **Category Tagging**: Labeling each document with what type it is (pricing, policy, procedure, FAQ). This lets you filter searches later — "only search my pricing docs" instead of searching everything.

- **Batch Ingestion**: Loading multiple documents at once instead of one at a time. Your exercise will scan a folder and ingest every .txt file it finds.

- **Source Attribution**: Tracking WHERE each answer came from. When your AI says "the markup is 15%," you can trace that back to the exact document. Trust but verify.

---

## THE LESSON

### Step 1: Organize your documents

Before your AI can learn your business, you need to give it something to learn from. Create a folder of plain text files — one topic per file works best.

Good document examples:
- `pricing.txt` — Your rates, markup percentages, payment terms
- `services.txt` — What you offer, service areas, capabilities
- `policies.txt` — Return policy, warranty terms, cancellation rules
- `faq.txt` — Common customer questions and your standard answers
- `procedures.txt` — How jobs get done, step-by-step workflows

**Keep each file focused.** A 1-page pricing doc beats a 50-page employee handbook. Small models work best with clear, focused chunks.

### Step 2: Create the BusinessDoc schema

We need a place in Weaviate to store your business documents. The `BusinessDoc` class has four properties:

| Property | Type | Purpose |
|----------|------|---------|
| title | text | Document name (e.g., "Pricing Guide") |
| content | text | The actual document text |
| category | text | Type: pricing, policy, procedure, faq, general |
| source | text | File path it came from |

This is separate from Phase 1's BrainDoc or MyBrain classes. Your business data gets its own space.

### Step 3: Ingest your documents

The ingestion pipeline works the same as Phase 1:
1. Read the .txt file
2. Send the text to Ollama for embedding (turning words into numbers)
3. Store the text + vector in Weaviate under the `BusinessDoc` class
4. Tag it with a category based on the filename

After ingestion, your AI can search these documents by meaning. Ask "what do we charge for rush jobs?" and it finds the relevant pricing doc even if it never says "rush jobs" exactly.

### Step 4: Verify your knowledge base

A good knowledge base has:
- At least 3 documents loaded (more is better)
- Every document has a category tag
- Semantic search returns relevant results
- Source attribution works (you can trace answers to documents)

---

## THE PATTERN

This module establishes the foundation for every Phase 2 tool:

```
YOUR DOCS  →  EMBED  →  STORE  →  SEARCH  →  ACT
  (txt)      (Ollama)  (Weaviate) (semantic)  (answer/draft/sort)
```

Module 2.2 adds the "answer" step. Module 2.3 adds "draft." Module 2.4 adds "sort." But they ALL start here — with your documents loaded and searchable.

---

## WHAT YOU PROVED

- You can turn scattered business documents into a searchable AI knowledge base
- Your AI answers from YOUR data, not internet guesses
- Category tagging keeps your knowledge organized
- Source attribution means you can trust and verify every answer
- You built the foundation that every other Phase 2 module depends on

**Next:** Run `exercise.bat` to load your business brain.
