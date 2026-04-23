# CHANGELOG

## [Unreleased] — 2026-04-23

### Content Audit (Full Repo Scan)

Performed a complete structural and content audit of all 36 modules across 5 phases.

**Finding: No content issues found.**

Every module has all 4 required files (lesson.md, exercise.bat, verify.bat, hints.md). All
lesson.md files contain "WHAT YOU'LL BUILD" and "WHAT YOU PROVED" sections. All exercise.bat
files start with `@echo off` and `setlocal enabledelayedexpansion`. All verify.bat files
implement the PASS_COUNT/FAIL_COUNT pattern with Fix: lines in every failure block. No
placeholder stubs, no broken markdown links, no PowerShell-only calls without fallbacks found.

All 8 shell scripts (.sh files) pass `bash -n` syntax check.

---

### Linux / Raspberry Pi Platform Port

Added Linux-compatible launcher and utilities to support running the curriculum on Raspberry Pi
5 and other Linux systems (the primary development/build machine for this project).

**New files:**
- `launch-training.sh` — Bash port of launch-training.bat; full ASCII menu, health checks,
  progress tracking, module navigation for all 36 modules
- `run-module.sh` — .bat-to-bash compatibility layer; transpiles common bat patterns (curl,
  set /a arithmetic, findstr, ANSI colors, pause) so .bat modules run under Linux via Python 3
- `shared/utils/health-check.sh` — Linux health check: RAM, Ollama, Weaviate, MCP server,
  disk space (RAID + SD card)
- `phases/phase-4-legacy/module-4.7-pass-it-on/verify.sh` — Linux verify for Phase 4 capstone
- `phases/phase-5-multipliers/module-5.3-backup-and-restore/verify.sh`
- `phases/phase-5-multipliers/module-5.7-family-mesh/verify.sh`
- `phases/phase-5-multipliers/module-5.9-prompt-chains/verify.sh`
- `phases/phase-5-multipliers/module-5.10-the-multiplier/verify.sh` — Linux verify for Phase 5 capstone

**Modified files:**
- `config.json` — Updated version (5.0.0 → 5.1.0-linux), platform field (linux-arm64),
  base_path to Pi RAID mount, ram_ceiling_gb to 16.0 (Pi 5), default model to shanebrain-3b,
  mcp_url added. Note: base_path is dev-machine-specific metadata; training modules use
  relative paths via %~dp0 (.bat) and $BASE_DIR (.sh) so this does not affect users.

**Decision:** `base_path` in config.json reflects the Pi development environment. It is metadata
only — no module script reads it for path resolution. Left as-is per current convention.

---

### mcp-call.py — SSE Streaming Optimization

Rewrote the `mcp_post()` function to read SSE streams line-by-line and return immediately upon
receiving the first complete JSON-RPC response (`"result"` or `"error"` key present), rather
than blocking until the server closes the connection.

- Socket timeout: 600s → 120s (sufficient since we no longer block for EOF)
- Safety limit: 200 SSE lines before giving up
- Plain JSON responses (non-SSE) handled unchanged
- Result: faster round-trips on Pi CPU where shanebrain-3b takes 6s/token; exercises no longer
  need to wait for stream termination after result is received

---

### README.md — Linux Install Instructions

Added Windows/Linux split in Quick Start section. Added `launch-training.sh`, `run-module.sh`,
and `health-check.sh` to the Architecture tree.

---

### CLAUDE.md — Timeout Correction

Updated client-side timeout note to reflect actual mcp-call.py behavior: socket timeout=120s
with SSE early-exit on first complete JSON-RPC result (previously documented as 600s).
