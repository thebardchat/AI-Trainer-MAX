# Angel Cloud AI Training Tools (ACATT)

**Local AI literacy for every person. No cloud. No subscription. No permission needed.**

---

## What Is This?

A modular, CLI-based training system that teaches people how to build, run, and own local AI — starting from zero. Every module runs on Windows, uses batch scripts, and respects a 7.4GB RAM ceiling.

This is the training layer of the Angel Cloud ecosystem.

## Why?

800 million Windows users are about to lose security update support. Most of them have never touched AI. This project exists to give them the skills to run AI on their own hardware before that window closes.

We believe AI literacy is a right, not a subscription.

## Architecture

```
training-tools/
├── launch-training.bat              # Main entry point — start here
├── config.json                      # Module registry + metadata
├── phases/
│   ├── phase-1-builders/            # NOW — Local AI fundamentals
│   │   ├── module-1.1-first-local-llm/
│   │   ├── module-1.2-vectors/
│   │   ├── module-1.3-build-your-brain/
│   │   ├── module-1.4-prompt-engineering/
│   │   └── module-1.5-ship-it/
│   ├── phase-2-operators/           # NEXT — Business automation
│   ├── phase-3-everyday/            # SCALE — The 800 million
│   └── phase-4-legacy/              # LONG-TERM — Digital inheritance
├── progress/
│   └── user-progress.json           # Auto-tracked completion data
└── shared/
    ├── ascii-art/                   # CLI branding assets
    └── utils/                       # Health checks, RAM monitor, etc.
```

## Quick Start

1. Make sure Ollama is installed: https://ollama.com
2. Open a terminal in this folder
3. Run: `launch-training.bat`
4. Start with Module 1.1

That's it. The launcher handles health checks, progress tracking, and module navigation.

## Requirements

- Windows 10 or 11
- 7.4GB RAM (4GB+ free recommended)
- Ollama installed
- Weaviate (for Modules 1.2+) — local instance on port 8080
- curl (included in Windows 10+)

## Module Flow

Every module follows the same pattern:

```
LESSON → EXERCISE → VERIFY → NEXT
```

- **lesson.md** — What you need to know (readable via `type lesson.md`)
- **exercise.bat** — Hands-on tasks (guided, under 15 minutes)
- **verify.bat** — Automated pass/fail check with specific failure reasons
- **hints.md** — Progressive hints if you get stuck (3 levels, no full answers until Level 3)

## Phase Roadmap

| Phase | Audience | Status |
|-------|----------|--------|
| Phase 1: Builders | Developers, self-learners | Active |
| Phase 2: Operators | Business owners, dispatchers | Planned |
| Phase 3: Everyday | Non-technical Windows users | Planned |
| Phase 4: Legacy | Families, next generation | Planned |

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
4. Test on a machine with 4GB free RAM

## Tech Stack

- **LLM Runtime:** Ollama
- **Default Model:** llama3.2:1b
- **Vector DB:** Weaviate (local)
- **Scripting:** Windows .bat
- **Content Format:** Markdown
- **Dependencies:** curl (built into Windows 10+)

## The Mission

This project is part of Angel Cloud — a faith-rooted, family-driven AI platform built on the belief that every person deserves access to AI literacy and local AI sovereignty.

Built in Alabama. Built for everyone.

---

*"Your legacy runs local."*
