# Module 4.5 — Write Your Story

## WHAT YOU'LL BUILD

A personal writing station powered by your AI brain. You'll use your vault as context to draft letters to your children, capture life stories, and compose messages to the people who matter most. The AI doesn't write for you — it writes WITH you, pulling from the memories, values, and details you've already stored.

This is the module where the data becomes the message. You've been feeding your brain documents, asking it questions, journaling your days. Now you turn all of that into something your family can hold onto. The letters your grandfather never wrote. The stories your great-grandmother took with her. You're putting them down, and your brain helps you say it right.

---

## WHO THIS IS FOR

Anyone who has something to say to someone they love but hasn't found the time or the words. Fathers writing letters to their sons. Mothers capturing family recipes with the story behind them. Anyone who wants to leave behind more than a bank account. If you've ever thought "I should write that down someday" — today is someday.

---

## KEY TERMS

- **draft_create**: The MCP tool that generates a writing draft. You give it a prompt (what to write), a type (letter, email, message, post, general), and it produces a draft. When `use_vault_context` is true, it searches your vault first and weaves your real details into the writing.

- **vault_search**: Searches your personal vault by meaning. Before you write, you can see what the AI will pull from. Search "family" and see what context exists. That's how you make sure the draft sounds like YOU, not a template.

- **Vault Context**: The personal details your brain pulls from your stored documents to make drafts specific and real. Writing a letter to your oldest son? The AI finds his name, the stories you stored about him, and uses those details. That's vault context — your life data making the writing personal.

- **Draft Type**: The format of writing:
  - `letter` — formal structure, greeting, body, closing. For letters meant to be kept.
  - `email` — professional format with subject line
  - `message` — short, casual, conversational
  - `post` — announcement or social media style
  - `general` — free-form, no specific structure

---

## THE LESSON

### Why writing matters more than you think

A house you build lasts 50 years if someone maintains it. A letter you write lasts forever if someone keeps it.

Most families lose their stories in two generations. Grandpa's wisdom, mama's sayings, the reason your family moved to Alabama or why your father picked that trade — gone. Not because nobody cared, but because nobody wrote it down.

You have an AI brain now. It holds your documents, your values, your daily notes. The raw material is there. This module teaches you to shape it into something worth passing down.

### Step 1: Search your vault for context

Before you write, check what your brain knows. Use `vault_search` to see what's stored about a topic:

```
python shared\utils\mcp-call.py vault_search "{\"query\":\"family values children\"}"
```

This shows you what the AI will pull from when drafting. If you stored documents about your kids, your faith, your work — those become the building blocks of your letters. The more you've stored in earlier modules, the richer the drafts.

### Step 2: Write a letter to your children

The `draft_create` tool with `draft_type` set to "letter" produces a structured, keepable letter. But the prompt is where it matters:

Be specific. "Write a letter to my kids" produces generic fluff. "Write a letter to my five sons about why I chose to build things with my hands, and what I hope they learn from watching me work" — that produces something real.

The AI searches your vault, finds the details you've stored about your family, your work, your values, and weaves them into the letter. It's not writing fiction. It's organizing what you've already said into something polished.

### Step 3: Capture a life story

Same tool, different purpose. A life story draft pulls from everything in your vault:

- The daily notes about what you're grateful for
- The family documents you stored
- The values and beliefs you've recorded

Give it a prompt like: "Write a short life story covering my journey as a father and builder. Include the challenges I faced and the faith that carried me through."

The AI won't make things up (it can only use what you stored). But it will organize scattered notes into a narrative. Think of it as a rough draft — your job is to read it, fix what's wrong, and make it yours.

### Step 4: Write to a specific person

The most powerful use: a letter to one person. A son about to graduate. A friend who stood by you. A spouse who carried the family when times were hard.

The prompt should name the person and the purpose:
"Write a letter to my oldest son about the values I want him to carry forward — hard work, faith, and taking care of family."

Vault context makes this real. If you stored documents mentioning that person, the AI pulls those details in. The draft will reference actual things from your life, not generic advice.

---

## THE PATTERN

```
SEARCH VAULT  →  CHECK CONTEXT  →  WRITE PROMPT  →  GENERATE DRAFT
(vault_search)  (see what exists) (be specific)   (draft_create)
```

The quality of the draft depends on two things:
1. What you've stored in your vault (more context = better drafts)
2. How specific your prompt is (detailed instructions = personal results)

This is the same RAG pattern from earlier modules, but the output is something your grandchildren might read someday.

---

## WHAT YOU PROVED

- You can search your vault to preview what context the AI will use
- The AI drafts personal letters using YOUR stored details, not generic templates
- Life stories pull from daily notes, vault documents, and knowledge entries
- The more specific your prompt, the more personal the draft
- Writing with vault context turns scattered data into meaningful messages
- Your AI brain is not just a database — it's a writing partner for the words that matter most

**Next:** Run `exercise.bat` to write your first legacy letters.
