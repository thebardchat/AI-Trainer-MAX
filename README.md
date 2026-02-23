# Angel Cloud AI Training Tools (ACATT)

**Local AI literacy for every person. No cloud. No subscription. No permission needed.**

---

## What Is This?

A modular, CLI-based training system that teaches people how to build, run, and own local AI — starting from zero. 36 modules across 5 phases take you from installing your first model to building a personal AI brain you can pass down to your family.

Every module runs on Windows .bat scripts, respects a 7.4GB RAM ceiling, and requires zero cloud accounts.

This is the training layer of the Angel Cloud ecosystem.

## Why?

800 million Windows users are about to lose security update support. Most of them have never touched AI. This project exists to give them the skills to run AI on their own hardware before that window closes.

We believe AI literacy is a right, not a subscription.

## Quick Start

1. Install Ollama: https://ollama.com
2. Install Docker Desktop (for Weaviate + MCP server)
3. Open a terminal in this folder
4. Run: `launch-training.bat`
5. Start with Module 1.1

The launcher handles health checks, progress tracking, and module navigation.

## Phase Roadmap

| Phase | Title | Modules | Audience | Focus |
|-------|-------|---------|----------|-------|
| 1 | BUILDERS | 5 | Developers, self-learners | Local AI with Ollama + RAG |
| 2 | OPERATORS | 7 | Business owners, dispatchers | Business automation |
| 3 | EVERYDAY | 7 | Non-technical Windows users | MCP-powered personal AI tools |
| 4 | LEGACY | 7 | Families, next generation | YourNameBrain digital inheritance |
| 5 | MULTIPLIERS | 10 | Phase 1-4 graduates | Defend, teach, connect, build deeper |
| **Total** | | **36** | **All levels** | **Zero to AI sovereignty** |

All 5 phases are complete and shipped.

## Architecture

```
AI-Trainer-MAX/
├── launch-training.bat              # Main entry point — start here
├── config.json                      # Module registry + metadata
├── phases/
│   ├── phase-1-builders/            # 5 modules — Ollama, vectors, RAG, prompts, packaging
│   ├── phase-2-operators/           # 7 modules — Business brain, Q&A, drafts, workflows
│   ├── phase-3-everyday/            # 7 modules — Vault, chat, drafting, security, briefings
│   ├── phase-4-legacy/              # 7 modules — YourNameBrain, journaling, storytelling
│   └── phase-5-multipliers/         # 10 modules — Hardening, teaching, export, protocol
├── progress/
│   └── user-progress.json           # Auto-tracked completion data
└── shared/
    ├── ascii-art/                   # CLI branding assets
    └── utils/
        ├── health-check.bat         # Ollama + Weaviate health check
        ├── mcp-call.py              # MCP client helper (stdlib only)
        └── mcp-health-check.bat     # MCP server health check
```

## Module Flow

Every module follows the same pattern:

```
LESSON → EXERCISE → VERIFY → NEXT
```

- **lesson.md** — What you need to know (starts with WHAT YOU'LL BUILD, ends with WHAT YOU PROVED)
- **exercise.bat** — Hands-on tasks (guided, under 15 minutes)
- **verify.bat** — Automated pass/fail checks with specific failure reasons
- **hints.md** — Progressive hints if you get stuck (3 levels)

## Tech Stack

- **LLM Runtime:** Ollama (localhost:11434)
- **Default Model:** llama3.2:1b (Phase 1-2), shanebrain-3b (Phase 3-5)
- **Vector DB:** Weaviate (localhost:8080)
- **MCP Server:** ShaneBrain MCP (localhost:8100) — 19 tools via Model Context Protocol
- **Scripting:** Windows .bat (CMD compatible)
- **Content Format:** Markdown
- **JSON Handling:** Python stdlib only — zero pip installs
- **Dependencies:** curl (built into Windows 10+), Python 3.x in PATH

## Requirements

- Windows 10 or 11
- 7.4GB RAM minimum (4GB+ free recommended)
- Ollama installed
- Docker Desktop (for Weaviate + MCP server)
- Python 3.x in PATH
- curl (included in Windows 10+)

## MCP Server (Phase 3-5)

Phases 3-5 use the ShaneBrain MCP server for 19 AI tools:

| Category | Tools |
|----------|-------|
| Knowledge | `search_knowledge`, `add_knowledge`, `chat_with_shanebrain` |
| Vault | `vault_add`, `vault_search`, `vault_list_categories` |
| Notes | `daily_note_add`, `daily_note_search`, `daily_briefing` |
| Drafting | `draft_create`, `draft_search` |
| Security | `security_log_search`, `privacy_audit_search` |
| Social | `search_friends`, `get_top_friends` |
| System | `system_health` |

The MCP server runs in Docker alongside Weaviate. See the [shanebrain-core](https://github.com/thebardchat/shanebrain-core) repo for server setup.

## Contributing

This is a family-driven project, but contributions are welcome.

**Ground rules:**
- Every script must run on Windows .bat (no PowerShell-only unless fallback provided)
- No cloud dependencies in Phase 1
- Peak memory per module: 3GB (reserve the rest for Ollama + Weaviate)
- Lesson tone: direct, encouraging, zero fluff, Grade 8-10 reading level
- Every lesson starts with "WHAT YOU'LL BUILD" and ends with "WHAT YOU PROVED"
- Banned words: "streamline", "revolutionary", "in today's rapidly evolving landscape"

**To add a module:**
1. Create a folder under the appropriate phase: `module-X.X-short-name/`
2. Include all 4 files: lesson.md, exercise.bat, verify.bat, hints.md
3. Register it in config.json
4. Add it to launch-training.bat menu
5. Test on a machine with 4GB free RAM

## The Mission

This project is part of Angel Cloud — a faith-rooted, family-driven AI platform built on the belief that every person deserves access to AI literacy and local AI sovereignty.

Built in Alabama. Built for everyone.

---

*"Your legacy runs local."*
