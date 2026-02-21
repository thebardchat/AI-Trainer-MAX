# CLAUDE.md — AI-Trainer-MAX Project Instructions

## Project Overview

AI-Trainer-MAX is a modular, CLI-based AI training system built on the Angel Cloud ecosystem. It teaches people how to build, run, and own local AI — starting from zero. Every module runs on Windows .bat scripts, targets 7.4GB RAM hardware, and has zero cloud dependencies in Phase 1.

**Repo:** https://github.com/thebardchat/AI-Trainer-MAX.git
**Base path on local machine:** /media/shane/ANGEL_CLOUD/AI-Trainer-MAX/
**Owner:** Shane — Alabama-based sole provider, father of 5 sons, building digital solutions for generational legacy.

## Tech Stack

- **LLM Runtime:** Ollama (localhost:11434)
- **Default Model:** llama3.2:1b
- **Vector DB:** Weaviate (localhost:8080)
- **Scripting:** Windows .bat (CMD compatible — no PowerShell-only commands)
- **Content Format:** Markdown (.md files rendered via `type` command)
- **JSON Handling:** Python stdlib only (urllib.request, json) — zero pip installs
- **MCP Server:** ShaneBrain MCP (localhost:8100) — 19 tools via streamable HTTP (Phase 3)
- **MCP Client:** shared/utils/mcp-call.py (stdlib only — urllib.request + json)
- **Dependencies:** curl (built into Windows 10+), Python 3.x in PATH

## Hardware Constraints — CRITICAL

- **RAM ceiling:** 7.4GB total
- **Module budget:** 3GB max peak per module (reserve rest for Ollama + Weaviate)
- **Block threshold:** Script must refuse to run if < 2GB free RAM
- **Warn threshold:** Alert user if < 4GB free RAM
- Every script, every module, every feature MUST respect these limits. If a solution would exceed 3GB module budget, find a leaner approach.

## Project Structure

```
AI-Trainer-MAX/
├── launch-training.bat              # Main entry point — ASCII menu + health checks
├── config.json                      # Module registry with metadata
├── README.md                        # Open-source contributor guide
├── CLAUDE.md                        # This file
├── phases/
│   ├── phase-1-builders/            # COMPLETE — 5 modules
│   │   ├── module-1.1-first-local-llm/
│   │   ├── module-1.2-vectors/
│   │   ├── module-1.3-build-your-brain/
│   │   ├── module-1.4-prompt-engineering/
│   │   └── module-1.5-ship-it/
│   ├── phase-2-operators/           # COMPLETE — 7 modules
│   │   ├── module-2.1-load-your-business-brain/
│   │   ├── module-2.2-instant-answer-desk/
│   │   ├── module-2.3-draft-it/
│   │   ├── module-2.4-sort-and-route/
│   │   ├── module-2.5-paperwork-machine/
│   │   ├── module-2.6-chain-reactions/
│   │   └── module-2.7-operator-dashboard/
│   ├── phase-3-everyday/            # COMPLETE — 7 MCP-powered modules
│   │   ├── module-3.1-your-private-vault/
│   │   ├── module-3.2-ask-your-vault/
│   │   ├── module-3.3-write-it-right/
│   │   ├── module-3.4-lock-it-down/
│   │   ├── module-3.5-daily-briefing/
│   │   ├── module-3.6-digital-footprint/
│   │   └── module-3.7-family-dashboard/
│   └── phase-4-legacy/              # PLANNED — YourNameBrain digital inheritance
├── progress/
│   └── user-progress.json
└── shared/
    ├── ascii-art/
    └── utils/
        ├── health-check.bat
        ├── mcp-call.py              # MCP client helper (stdlib only)
        └── mcp-health-check.bat     # MCP server health check
```

## Module File Pattern

Every module contains exactly 4 files:

| File | Purpose |
|------|---------|
| `lesson.md` | Lesson content — starts with WHAT YOU'LL BUILD, ends with WHAT YOU PROVED |
| `exercise.bat` | Guided hands-on tasks — completable in under 15 minutes |
| `verify.bat` | Automated PASS/FAIL checks with specific failure reasons + fix instructions |
| `hints.md` | 3 progressive hint levels — general direction → specific guidance → full answer |

## Coding Standards

### .bat Files
- Always start with `@echo off` and `setlocal enabledelayedexpansion`
- Use ANSI color codes: `[92m` green (success), `[93m` yellow (warning), `[91m` red (error), `[0m` reset
- Every script must have a title: `title Module X.X — Name`
- Always check service health before operations (Ollama, Weaviate)
- Exit codes: 0 = success, 1 = failure — always set explicitly
- Temp files go in `%TEMP%\` with descriptive subfolder names, cleaned up on exit
- All paths must work relative to the script location using `%~dp0`
- Never use PowerShell-only commands without a .bat fallback

### verify.bat Pattern
- Set `PASS_COUNT`, `FAIL_COUNT`, `TOTAL_CHECKS` at top
- Number each check: `[CHECK X/TOTAL]`
- Every FAIL must include a `Fix:` line with the exact command to resolve
- Update progress log on full pass
- Return ERRORLEVEL 0 (pass) or 1 (fail)

### Python Usage
- Python is ONLY used for JSON parsing that .bat cannot handle
- Use stdlib only: `json`, `urllib.request`, `os`, `sys`
- Zero pip installs — nothing beyond what a default Python 3 install provides
- Always wrap in `python -c "..."` one-liners or single-file scripts
- Always handle Python not being in PATH gracefully

### Weaviate Schema Classes
Each module that creates a Weaviate class uses a UNIQUE class name to avoid conflicts:
- Module 1.2: `Document`
- Module 1.3: `BrainDoc`
- Module 1.5: `MyBrain`
- Module 2.1: `BusinessDoc`
- Module 2.3: `DraftTemplate`
- Module 2.4: `MessageLog`
- Module 2.5: `DocTemplate`
- Module 2.6: `WorkflowLog`
- Phase 3 uses MCP server collections: `PersonalDoc`, `DailyNote`, `PersonalDraft`, `SecurityLog`, `PrivacyAudit`
- Future modules should follow this pattern — never reuse a class name

### Phase 3 MCP Tools
Phase 3 modules use `shared/utils/mcp-call.py` to call ShaneBrain MCP server tools:
- `vault_add`, `vault_search`, `vault_list_categories` — Personal vault storage
- `chat_with_shanebrain` — RAG Q&A with Ollama
- `draft_create`, `draft_search` — AI drafting with vault context
- `security_log_search`, `privacy_audit_search` — Security auditing
- `daily_note_add`, `daily_note_search`, `daily_briefing` — Journaling + AI briefings
- `system_health` — Service status + collection counts
- `search_knowledge`, `get_top_friends` — Knowledge base + social

## Writing Style for Lesson Content

- Write like a senior dev mentoring a motivated beginner — direct, encouraging, zero fluff
- Use real terminal output examples (copy-paste ready, not hypothetical)
- Every lesson starts with **WHAT YOU'LL BUILD** and ends with **WHAT YOU PROVED**
- Analogies are encouraged — especially construction, trucking, dispatching, or family-based metaphors
- Reading level: Grade 8-10. Technical terms get a one-line plain-English definition on first use
- **Never use:** "streamline", "revolutionary", "in today's rapidly evolving landscape", "it's important to note"
- Key terms section after WHAT YOU'LL BUILD — bold term name, plain-English definition
- Show the connection to ShaneBrain / Angel Cloud where relevant

## Phase Architecture

| Phase | Audience | Status | Focus |
|-------|----------|--------|-------|
| Phase 1: BUILDERS | Developers, self-learners | ✅ COMPLETE (5 modules) | Local AI with Ollama/RAG |
| Phase 2: OPERATORS | Small business owners, dispatchers | ✅ COMPLETE (7 modules) | Business automation |
| Phase 3: EVERYDAY | 800M non-technical Windows users | ✅ COMPLETE (7 modules) | MCP-powered personal AI tools |
| Phase 4: LEGACY | Families, next generation | 📋 PLANNED | YourNameBrain digital inheritance |

## Mission Context

800 million Windows users are about to lose security update support. This platform exists to give them local AI skills before that window closes. Every design decision must prioritize: **ships fast, runs lean, teaches effectively.**

Angel Cloud is faith-rooted and family-driven. The founder is building this as a sole provider — time and resources are limited. Efficiency is not optional.

## Common Commands

```bash
# Start services
ollama serve
docker start weaviate

# Verify services
curl http://localhost:11434/api/tags
curl http://localhost:8080/v1/.well-known/ready

# Run training launcher
launch-training.bat

# Check RAM
wmic os get FreePhysicalMemory /value
```

## When Building New Modules

1. Create folder: `module-X.X-short-name/`
2. Create all 4 files: lesson.md, exercise.bat, verify.bat, hints.md
3. Register in config.json with title, description, estimated_time, prerequisites
4. Test on a machine with < 4GB free RAM
5. Ensure exercise completes in under 15 minutes
6. Ensure verify.bat returns clean PASS/FAIL with no ambiguity
7. Use a unique Weaviate class name if the module creates one

## Do NOT

- Add cloud dependencies to Phase 1 modules
- Use npm, pip install, or virtual environments in Phase 1
- Exceed 3GB peak memory in any single module
- Create scripts that require admin/elevated privileges
- Use PowerShell without a .bat fallback
- Write lessons with filler, hedging language, or academic tone
- Assume the user has done anything beyond the listed prerequisites
