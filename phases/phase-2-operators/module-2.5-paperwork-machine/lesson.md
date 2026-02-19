# Module 2.5 — Paperwork Machine

## WHAT YOU'LL BUILD

A document generator that produces estimates, reports, checklists, and other structured business documents from simple prompts. Type "generate an estimate for a 2-bathroom remodel" and get a formatted document with your real rates, terms, and boilerplate — ready to hand to a customer.

---

## WHO THIS IS FOR

Anyone who wastes time recreating the same types of documents. Estimates that pull from your rate card. Daily reports with consistent formatting. Job checklists that never miss a step. If you've ever copy-pasted from an old document and forgotten to change the customer name, this tool is for you.

---

## KEY TERMS

- **DocTemplate**: The Weaviate class that stores your document templates. Each template has a title, content skeleton, document type (estimate, report, checklist), and a list of required fields. Think of it as a smart form that the AI fills in.

- **Document Type**: The kind of document you're generating — estimate, report, checklist, letter, invoice summary. Each type has its own structure and expected content.

- **Required Fields**: Variables that must be filled in for each document — customer name, job address, line items, dates. The AI fills in what it can from context and flags what it needs you to provide.

- **Structured Output**: Documents with consistent sections, formatting, and layout. Not a blob of text — headers, line items, totals, terms. Professional looking every time.

---

## THE LESSON

### The Document Generation Architecture

```
REQUEST  →  FIND TEMPLATE  →  PULL BUSINESS DATA  →  GENERATE  →  OUTPUT
            (DocTemplate)     (BusinessDoc)          (Ollama)    (.txt file)
```

Two collections feed the generator. DocTemplate provides structure. BusinessDoc provides facts (rates, terms, policies). Ollama fills in the blanks.

### Step 1: Create the DocTemplate schema

| Property | Type | Purpose |
|----------|------|---------|
| title | text | Template name ("Standard Estimate") |
| content | text | Template structure with sections |
| docType | text | estimate, report, checklist, letter |
| requiredFields | text | Comma-separated list of fields needed |

### Step 2: Seed with starter templates

The exercise creates four document templates:
- **Standard Estimate** — Service description, labor, materials, total, terms
- **Daily Job Report** — Date, site, crew, work performed, issues, next steps
- **Job Checklist** — Pre-arrival, on-site, completion, follow-up items
- **Customer Letter** — Header, body, closing, signature block

### Step 3: Generate documents

When you request "estimate for deck repair at 123 Oak St," the tool:
1. Finds the "Standard Estimate" template (closest match)
2. Pulls your rates from BusinessDoc (labor rate, material markup)
3. Generates a formatted document with real numbers
4. Saves it as a .txt file you can print or email

### Step 4: Save to file

Generated documents save to an `output/documents/` folder with timestamps. No more lost paperwork. Every document generated, dated, and stored.

---

## THE DAILY USE CASE

Customer calls for a quote. You type:

> generate estimate for replacing kitchen faucet at 456 Elm St for John Davis

The Paperwork Machine outputs:

```
ESTIMATE
Date: 2026-02-19
Customer: John Davis
Address: 456 Elm St

SERVICE: Kitchen faucet replacement
  Labor: 2 hours @ $65/hour = $130.00
  Materials: Faucet + supplies (15% markup) ≈ $85.00
  Service call fee: $85.00
  ─────────────────
  ESTIMATED TOTAL: $300.00

TERMS:
- Estimate valid for 30 days
- Payment due upon completion
- 90-day warranty on labor
```

All from your real pricing doc. Under 10 seconds. Print it and hand it over.

---

## WHAT YOU PROVED

- You can generate structured business documents from natural language
- Document templates ensure consistency across all paperwork
- Real business data (rates, terms) gets injected automatically
- Output saves to files for records and printing
- The Paperwork Machine pattern works for any document type

**Next:** Run `exercise.bat` to build your document generator.
