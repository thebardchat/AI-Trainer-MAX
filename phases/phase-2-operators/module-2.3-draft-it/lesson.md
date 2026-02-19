# Module 2.3 — Draft It

## WHAT YOU'LL BUILD

An AI message drafting tool with reusable templates. Type what you need — a customer reply, a quote follow-up, a complaint response — and get a professional draft in your business voice. Save templates for messages you send often. Stop writing the same email from scratch every Monday.

---

## WHO THIS IS FOR

Anyone who writes business messages. Customer replies. Vendor emails. Team updates. Estimate follow-ups. If you've ever stared at a blank screen trying to word something right, this tool writes the first draft in seconds.

---

## KEY TERMS

- **DraftTemplate**: A Weaviate class that stores reusable message templates. Each template has a title, content, message type (email, text, letter), and tone (professional, friendly, firm). Think of it as your "best replies" folder that the AI can learn from.

- **Tone Control**: Telling the AI HOW to write, not just WHAT to write. "Professional" gives you formal language. "Friendly" gives you casual warmth. "Firm" gives you clear boundaries without being rude.

- **Context Injection**: Pulling relevant info from your BusinessDoc collection to make drafts accurate. When you draft a pricing response, the AI checks your actual pricing doc — no guessing, no outdated numbers.

- **Template Matching**: When you ask for a draft, the system searches your saved templates for similar messages. If you wrote a great complaint response last month, it uses that style for the next one.

---

## THE LESSON

### The Drafting Architecture

```
REQUEST  →  FIND TEMPLATE  →  PULL CONTEXT  →  DRAFT  →  OUTPUT
            (DraftTemplate)   (BusinessDoc)    (Ollama)  (ready to send)
```

Two collections work together. DraftTemplate stores your message patterns. BusinessDoc provides the facts. Ollama combines them into a draft.

### Step 1: Create the DraftTemplate schema

| Property | Type | Purpose |
|----------|------|---------|
| title | text | Template name ("Quote Follow-Up") |
| content | text | The template text with variable placeholders |
| messageType | text | email, text, letter, memo |
| tone | text | professional, friendly, firm |

### Step 2: Seed with starter templates

The exercise creates five starter templates:
- **Customer Welcome** — New customer onboarding message
- **Quote Follow-Up** — Following up after sending an estimate
- **Complaint Response** — Professional acknowledgment and resolution
- **Payment Reminder** — Polite but firm overdue notice
- **Job Completion** — Work finished, payment due, thank you

These are general enough for any small business. After the exercise, replace them with YOUR best messages.

### Step 3: Draft with context

When you request "draft a quote follow-up," the tool:
1. Searches DraftTemplate for similar templates (finds "Quote Follow-Up")
2. Searches BusinessDoc for relevant facts (finds pricing, payment terms)
3. Combines the template style with real business data
4. Generates a draft you can edit and send

### Step 4: Save new templates

Great draft? Save it as a new template. Over time, your DraftTemplate collection becomes a library of your best business writing. The AI gets better because it learns YOUR voice, not generic corporate speak.

---

## THE DAILY USE CASE

Customer emails asking about rates. You type:

> Draft a friendly reply about our hourly rates and emergency pricing

The AI checks your pricing doc ($65/hour, 1.5x emergency), finds your "friendly" templates for tone, and outputs:

> Hi! Thanks for reaching out. Our standard hourly rate is $65/hour. For emergency and after-hours calls, we charge 1.5x the standard rate ($97.50/hour). We also offer a free estimate for any job over $500. Let me know if you'd like to schedule a time that works for you!

Two seconds. Accurate numbers. Your tone. Ready to send.

---

## WHAT YOU PROVED

- You can draft business messages using AI with real data from your docs
- Reusable templates capture your best writing for future use
- Tone control lets you switch between professional, friendly, and firm
- Context injection keeps drafts accurate with real numbers and policies
- Every draft can be traced back to source documents

**Next:** Run `exercise.bat` to build your drafting tool.
