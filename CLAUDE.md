# CLAUDE.md — AI-Trainer-MAX Project Instructions

## Project Overview

AI-Trainer-MAX is a modular, CLI-based AI training system built on the Angel Cloud ecosystem. It teaches people how to build, run, and own local AI — starting from zero. Every module runs on Windows .bat scripts, targets 7.4GB RAM hardware, and has zero cloud dependencies in Phase 1.

**Repo:** https://github.com/thebardchat/AI-Trainer-MAX.git
**Base path on local machine:** /media/shane/ANGEL_CLOUD/AI-Trainer-MAX/
**Owner:** Shane — Alabama-based sole provider, father of 5 sons, building digital solutions for generational legacy.

## Project State (February 23, 2026)

### Completed — All Phases Pushed to GitHub
- **Phase 1 BUILDERS:** 5 modules — local AI fundamentals (Ollama, Weaviate, RAG)
- **Phase 2 OPERATORS:** 7 modules — business automation (Q&A, drafting, workflows)
- **Phase 3 EVERYDAY USERS:** 7 modules — MCP-powered personal AI tools
- **Phase 4 LEGACY:** 7 modules — YourNameBrain digital inheritance
- **Phase 5 MULTIPLIERS:** 10 modules — defend, teach, connect, build deeper
- **Total: 36 modules** (144 files: lesson.md, exercise.bat, verify.bat, hints.md each)
- **MCP server:** 19 tools live at localhost:8100 (shanebrain-mcp Docker container)
- **shared/utils/mcp-call.py:** MCP client helper (stdlib only, zero pip installs, 600s timeout)
- **shared/utils/mcp-health-check.bat:** MCP server health checker

### Performance Tuning (Pi Hardware)
- **Pi specs:** Raspberry Pi 5, 16GB RAM, ARM CPU (no GPU)
- **Default model:** shanebrain-3b — fits in 16GB, but CPU inference is slow (~6s/token through MCP stack)
- **Server-side timeouts:** ollama.Client timeout=600s in server.py (chat, briefing, draft)
- **Client-side timeout:** mcp-call.py timeout=600s
- **num_predict limits:** chat/briefing=100 tokens, drafts=150 tokens (keeps responses under 10 min)
- **Cold start:** First inference after model unload takes 2-6 min (model loading + prompt eval)
- **Warm model:** keep_alive="10m" holds model in RAM between calls

### What's Next
- **Phase 6:** Not yet planned. Possible directions: DEPLOYMENT (package for other families), FEDERATION (real multi-brain networking), MOBILE (phone-based access to local brain)
- **Testing:** All modules need live end-to-end testing on actual Windows hardware
- **Optimization:** Consider llama3.2:1b as a "fast mode" alternative for time-sensitive modules

### Phase 5 Module Specs
| Module | Title | Theme | MCP Tools | Purpose |
|--------|-------|-------|-----------|---------|
| 5.1 | Lock the Gates | DEFENDERS | `system_health`, `security_log_search` | Port scanning, firewall verification, hardening report |
| 5.2 | Threat Spotter | DEFENDERS | `add_knowledge`, `search_knowledge`, `chat_with_shanebrain`, `security_log_search` | Build threat taxonomy, AI-assisted threat classification |
| 5.3 | Backup and Restore | DEFENDERS | `search_knowledge`, `vault_search`, `vault_list_categories`, `system_health`, `add_knowledge`, `vault_add` | Export/import knowledge + vault data, verify integrity |
| 5.4 | Teach the Teacher | TEACHERS | `add_knowledge`, `search_knowledge`, `chat_with_shanebrain` | Build teaching knowledge base, AI as teaching assistant |
| 5.5 | Workshop in a Box | TEACHERS | `draft_create`, `vault_add`, `vault_search`, `search_knowledge` | Generate workshop script + facilitator checklist |
| 5.6 | Brain Export | CONNECTORS | `search_knowledge`, `vault_search`, `vault_list_categories`, `daily_note_search`, `system_health` | Structured JSON export with manifest and checksums |
| 5.7 | Family Mesh | CONNECTORS | `add_knowledge`, `search_knowledge`, `chat_with_shanebrain`, `search_friends`, `get_top_friends` | Multi-brain simulation using category namespaces |
| 5.8 | Under the Hood | BUILDERS v2 | `system_health` (raw curl) | Raw MCP protocol — JSON-RPC, sessions, SSE parsing |
| 5.9 | Prompt Chains | BUILDERS v2 | `chat_with_shanebrain`, `search_knowledge`, `vault_search`, `draft_create` | Multi-step prompt pipelines, output-as-input chains |
| 5.10 | The Multiplier | CAPSTONE | ALL | All four themes in one exercise, 8 checks, graduation |

### Architecture Decisions
- Phase 1-2 use direct curl to Ollama/Weaviate
- Phase 3-4 use MCP tools via mcp-call.py wrapper
- Phase 5 uses MCP tools via mcp-call.py PLUS raw curl to MCP (Module 5.8)
- MCP server lives in shanebrain-core repo on RAID (`/mnt/shanebrain-raid/shanebrain-core/`)
- Training modules live in THIS repo on external drive (`/media/shane/ANGEL_CLOUD/AI-Trainer-MAX/`)
- These are TWO SEPARATE repos — do NOT mix them
- All training content builds HERE in AI-Trainer-MAX
- MCP server is a dependency, not something we build here
- Phase 4 tone is legacy-focused — family metaphors, what you leave behind. Module 4.7 is the capstone where users build their own YourNameBrain.
- Phase 5 tone is empowerment-focused — you are no longer a student, you are a multiplier. Defend, teach, connect, build.
- Phase 5 creates NO new Weaviate classes — uses existing MCP collections only
- Phase 5 uses knowledge categories as namespaces for multi-brain simulation (Module 5.7)

## Repository Boundaries — SINGLE SOURCE OF TRUTH

| Repo | URL | Purpose |
|------|-----|---------|
| AI-Trainer-MAX | https://github.com/thebardchat/AI-Trainer-MAX | Training modules, lessons, exercises, launcher |
| shanebrain-core | https://github.com/thebardchat/shanebrain-core | MCP server, ShaneBrain API, Docker services |

**NEVER** build training modules in shanebrain-core.
**NEVER** build MCP server code in AI-Trainer-MAX.

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

- **Target user RAM:** 7.4GB minimum (modules designed for this ceiling)
- **Dev/build machine:** Raspberry Pi 5 with 16GB RAM
- **Module budget:** 3GB max peak per module (reserve rest for Ollama + Weaviate)
- **Block threshold:** Script must refuse to run if < 2GB free RAM
- **Warn threshold:** Alert user if < 4GB free RAM
- Every script, every module, every feature MUST respect these limits. If a solution would exceed 3GB module budget, find a leaner approach.
- **Inference reality:** shanebrain-3b on Pi CPU runs ~6s/token. Modules using `chat_with_shanebrain` will take 2-10 minutes per AI response. Design exercises to account for wait times.

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
│   ├── phase-4-legacy/              # COMPLETE — 7 modules, YourNameBrain digital inheritance
│   │   ├── module-4.1-what-is-a-brain/
│   │   ├── module-4.2-feed-your-brain/
│   │   ├── module-4.3-talk-to-your-brain/
│   │   ├── module-4.4-your-daily-companion/
│   │   ├── module-4.5-write-your-story/
│   │   ├── module-4.6-guard-your-legacy/
│   │   └── module-4.7-pass-it-on/
│   └── phase-5-multipliers/         # COMPLETE — 10 modules, defend/teach/connect/build
│       ├── module-5.1-lock-the-gates/
│       ├── module-5.2-threat-spotter/
│       ├── module-5.3-backup-and-restore/
│       ├── module-5.4-teach-the-teacher/
│       ├── module-5.5-workshop-in-a-box/
│       ├── module-5.6-brain-export/
│       ├── module-5.7-family-mesh/
│       ├── module-5.8-under-the-hood/
│       ├── module-5.9-prompt-chains/
│       └── module-5.10-the-multiplier/
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

### Phase 3-4 MCP Tools
Phase 3 and 4 modules use `shared/utils/mcp-call.py` to call ShaneBrain MCP server tools:
- `vault_add`, `vault_search`, `vault_list_categories` — Personal vault storage
- `chat_with_shanebrain` — RAG Q&A with Ollama
- `draft_create`, `draft_search` — AI drafting with vault context
- `security_log_search`, `privacy_audit_search` — Security auditing
- `daily_note_add`, `daily_note_search`, `daily_briefing` — Journaling + AI briefings
- `system_health` — Service status + collection counts
- `search_knowledge`, `get_top_friends` — Knowledge base + social
- `add_knowledge` — Add entries to the legacy knowledge base (Phase 4)

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
| Phase 4: LEGACY | Families, next generation | ✅ COMPLETE (7 modules) | YourNameBrain digital inheritance |
| Phase 5: MULTIPLIERS | Phase 1-4 graduates | ✅ COMPLETE (10 modules) | Harden, teach, connect, extend |
| **TOTAL** | **All levels** | **36 modules shipped** | **Zero to sovereignty** |

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

## Development Standards

### Document Before You Build (Mandatory)
Every new phase, feature, or architectural change MUST follow this sequence:
1. UPDATE CLAUDE.md with the current project state — what's complete, what's in progress, what's planned
2. UPDATE config.json with module specs if adding modules
3. SHOW the changes for review before proceeding
4. THEN build

Never start writing lesson.md, exercise.bat, verify.bat, or hints.md files until CLAUDE.md reflects where the project is RIGHT NOW. This prevents session drift — where different Claude Code sessions build in different directions because they don't know what came before.

### Why This Matters
Claude Code sessions start cold. CLAUDE.md is the ONLY continuity between sessions. If it's stale, the next session guesses. If it's current, the next session picks up exactly where the last one left off.

## Do NOT

- Add cloud dependencies to Phase 1 modules
- Use npm, pip install, or virtual environments in Phase 1
- Exceed 3GB peak memory in any single module
- Create scripts that require admin/elevated privileges
- Use PowerShell without a .bat fallback
- Write lessons with filler, hedging language, or academic tone
- Assume the user has done anything beyond the listed prerequisites
