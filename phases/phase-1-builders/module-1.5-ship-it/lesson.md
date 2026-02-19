# Module 1.5: Ship It

## WHAT YOU'LL BUILD

By the end of this module, you will have a single .bat file that boots
your entire local AI system — health checks, Weaviate, Ollama, document
ingestion, and an interactive RAG chat — all from one double-click.

This is the finish line for Phase 1. Everything you learned in Modules
1.1 through 1.4 gets welded together into a tool you'll actually use
every day. Not a demo. Not a tutorial. A product.

Think of it like this: You've been building an engine (1.1), a
transmission (1.2), wiring the electrical (1.3), and tuning the
carburetor (1.4). Now you bolt it all into the frame and turn the key.

---

## KEY TERMS

**Launcher:** A single script that starts your entire system. Health
checks, service startup, configuration — all handled before the user
sees a prompt. ShaneBrain's start-shanebrain.bat is a launcher.

**Graceful Failure:** When something goes wrong, the system tells you
WHAT went wrong and HOW to fix it instead of just crashing. Good
launchers never leave the user staring at a blank screen.

**Idempotent:** A script that produces the same result whether you run
it once or ten times. If the schema already exists, don't crash — skip
it. If documents are already ingested, don't duplicate them. Your
launcher should be safe to run repeatedly.

**Service Orchestration:** Starting multiple services in the right order
and verifying each one is healthy before moving to the next. Ollama
must be running before you can embed. Weaviate must be running before
you can store. Order matters.

**Exit Codes:** A number your script returns when it finishes. 0 means
success. Anything else means failure. Other scripts can check these
codes to know if something worked. Every .bat file should set exit
codes properly.

**User Experience (UX):** How the person using your tool FEELS while
using it. Clear menus, progress indicators, color-coded output, and
helpful error messages are UX. In CLI tools, UX is the difference
between "I'll use this daily" and "I'll never open this again."

---

## THE LESSON

### What You're Packaging

From the previous four modules, you have these pieces:

    Module 1.1: Ollama setup + local inference
    Module 1.2: Weaviate setup + vector storage + semantic search
    Module 1.3: RAG pipeline (ingest → embed → search → generate)
    Module 1.4: Prompt engineering (system prompts, temperature, guardrails)

Your launcher combines all of them into one workflow:

    [BOOT] → [HEALTH CHECK] → [INGEST] → [CHAT]

### The Launcher Architecture

Here's the blueprint for my-brain.bat — the launcher you're building:

    ┌─────────────────────────────────────────────┐
    │  1. BANNER                                   │
    │     Display ASCII branding                   │
    ├─────────────────────────────────────────────┤
    │  2. HEALTH CHECKS                            │
    │     RAM check (block if < 2GB free)          │
    │     Ollama check (auto-start if needed)      │
    │     Model check (prompt to pull if missing)  │
    │     Weaviate check (warn if not running)     │
    ├─────────────────────────────────────────────┤
    │  3. SCHEMA SETUP (idempotent)                │
    │     Create BrainDoc class if not exists      │
    ├─────────────────────────────────────────────┤
    │  4. DOCUMENT INGESTION (smart)               │
    │     Scan knowledge folder                    │
    │     Skip already-ingested files              │
    │     Embed + store new files only             │
    ├─────────────────────────────────────────────┤
    │  5. INTERACTIVE CHAT                         │
    │     Accept user questions                    │
    │     Run full RAG pipeline per question       │
    │     Display grounded answers                 │
    │     Loop until user types /bye               │
    └─────────────────────────────────────────────┘

### Design Principles

**1. One-Click Start**
The user double-clicks the .bat file. Everything else is automatic.
No flags, no arguments, no configuration. If it needs something, it
gets it or tells you how to get it.

**2. Fail Loudly, Fail Helpfully**
Never silently fail. If Ollama isn't running, don't just exit — print
the exact command to fix it. If RAM is low, say how much is available
and how much is needed. Red text for errors. Green for success.

**3. Idempotent Everything**
Running the launcher twice should not duplicate documents, recreate
existing schemas, or corrupt state. Check before acting. Every time.

**4. Respect the RAM**
Your ceiling is 7.4GB. Ollama uses ~1.5GB with the 1b model. Weaviate
uses ~500MB-1GB. Your script gets whatever's left. Never load more
than you need. Release resources when done.

**5. The 3-Second Rule**
From double-click to first usable prompt: under 30 seconds. Health
checks should take 3 seconds max. Ingestion should show progress.
The user should never wonder "is it frozen?"

### Building the Knowledge Folder

Your launcher needs a place to find documents. Create:

    D:\Angel_Cloud\shanebrain-core\knowledge\

Put any .txt files in there. The launcher ingests everything on boot.
You can add files anytime — next boot picks them up.

This is the same pattern ShaneBrain uses. Your knowledge folder IS
your AI's brain. What you put in there is what it knows.

### Smart Ingestion (Don't Re-Embed)

Naive ingestion re-embeds every document on every boot. That wastes
time and can create duplicates. Smart ingestion:

1. Reads the knowledge folder
2. Checks Weaviate for existing documents by title
3. Only embeds and stores NEW files
4. Reports: "3 documents found, 1 new, 2 already ingested"

The exercise builds this with a simple title-match check. Production
systems use content hashes, but title-match is solid for personal use.

### The Chat Loop

The core interaction after boot:

    ┌─────────────────────────────────────────┐
    │  YOU >> What are the Angel Cloud values? │
    │                                          │
    │  [embed question]                        │
    │  [search Weaviate → top 2 chunks]        │
    │  [build prompt with context + guardrails]│
    │  [generate answer via Ollama]            │
    │                                          │
    │  BRAIN >> The Angel Cloud values are:    │
    │  Faith first. Family always. Sobriety as │
    │  strength. Every person deserves access  │
    │  to AI...                                │
    │                                          │
    │  YOU >> /bye                              │
    │  Goodbye. Your legacy runs local.        │
    └─────────────────────────────────────────┘

The chat loop uses the prompt template from Module 1.4 with full
guardrails. Temperature 0.2 for factual accuracy. System prompt
defining the brain's personality.

### What Makes This ShaneBrain

The launcher you build in this exercise IS a ShaneBrain-class system.
The differences between your exercise and start-shanebrain.bat:

| Feature | Your Exercise | ShaneBrain Production |
|---------|--------------|----------------------|
| Knowledge source | knowledge\ folder | knowledge\ + RAG.md + custom docs |
| Chunking | Whole-file | Paragraph-level splits |
| Model | llama3.2:1b | Configurable (1b-7b) |
| Chat history | None (stateless) | Session memory |
| Launcher UX | Functional | Polished ASCII + menus |

You can close every one of those gaps. Module 1.5 gives you the
foundation. What you add after that is YOUR brain, YOUR way.

---

## WHAT YOU PROVED

- You can package a complete AI system into a single launcher
- You understand service orchestration and health checks
- You can build smart ingestion that skips duplicate work
- You can create an interactive RAG chat loop
- You have a working local AI assistant you built from scratch
- You completed Phase 1 — you're a Builder

---

## NEXT: Run exercise.bat to build and test your launcher.
