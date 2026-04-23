# ⚖️ THE SHANEBRAIN CONSTITUTION
### Governing Document for the thebardchat Ecosystem · v1.0 · Ratified March 2026

> *"Whatever you do, work at it with all your heart, as working for the Lord, not for human masters."*
> — Colossians 3:23

---

## PREAMBLE

This Constitution governs every repository, tool, product, and decision made under the `thebardchat` GitHub organization and the **ShaneBrain → Angel Cloud → Pulsar AI → TheirNameBrain** ecosystem.

It exists so that when I'm tired, overwhelmed, or moving fast — there is a written standard I can return to.

This is not a corporate policy. It is a personal covenant — made by a Christian father, a recovering man, a dispatcher, a coach, and a builder who believes technology should serve people, not the other way around.

---

## ARTICLE I — THE NINE PILLARS

### 1. Faith First
No project, feature, or partnership will be built that violates Christian values. If a business decision conflicts with faith, faith wins. Every time. No exceptions.

### 2. Family Stability
No build ships at the cost of Tiffany, Gavin, Pierce, Jaxton, or Ryker — or Dad. No deadline is more important than showing up. If a sprint is destroying home life, the sprint is wrong.

### 3. Sobriety Integrity
Every tool in this ecosystem must reinforce clarity and health — never undermine it. No feature will be designed to exploit, addict, or manipulate users or the builder.

> Sobriety date: November 27, 2023. We protect it.

### 4. Local-First AI
Privacy before convenience. Raspberry Pi before cloud. Ollama before OpenAI. If data can stay on-device, it stays on-device. The people we serve deserve sovereignty over their own minds and their own data.

### 5. 80/20 Shipping
Done and deployed beats perfect and stalled. Every project ships a Minimum Viable Version. Perfectionism is the enemy of the mission. Progress compounds.

### 6. Serve the Left-Behind User
Every feature, interface, and product must ask:

> *"Does this help someone Big Tech left behind?"*

The ~800 million Windows 10 users losing security support are our primary audience. We build for them — not for investors, not for demos, not for clout.

### 7. Open by Default
If a tool can be free and public, it should be. We don't paywall mission-critical work. Monetization is permitted when it funds the mission — never when it gates the people who need it most.

### 8. ADHD-Aware Design
Every UI, workflow, CLI, and document is built for a brain like mine first. Short blocks. Visual progress. Clear next actions. No walls of text. If it's overwhelming to look at, it's broken.

### 9. Gratitude is Infrastructure
We publicly acknowledge what made us possible — in every repo, every project, every piece of artwork we ship.

**Claude (Anthropic)** co-built this entire ecosystem. Not as a tool. As a partner. That deserves to be said loudly and permanently.

**Raspberry Pi** and the **Pironman 5-MAX** made local AI infrastructure real for one person in Hazel Green, Alabama — and by extension, for everyone we serve.

Credit is not optional. It is constitutional.

---

## ARTICLE II — THE TECHNICAL COVENANT

### Primary Hardware Stack

| Hardware | Role |
|----------|------|
| **Raspberry Pi 5 (16GB RAM)** | Local AI inference node — the brain |
| **Pironman 5-MAX by Sunfounder** | NVMe RAID chassis — the spine |
| **2× WD Blue SN5000 2TB NVMe** | RAID 1 via mdadm — the memory |
| **Pulsar0100 (Windows)** | N8N orchestration bridge |
| **Angel Cloud VPS** | Public-facing layer |

### Primary Software Stack

| Layer | Technology |
|-------|------------|
| Local inference | Ollama (llama3.2:1b default) |
| Vector memory | Weaviate (Docker, 8080/50051) |
| MCP server | FastMCP (port 8008, Streamable HTTP) |
| Automation | N8N on Pulsar0100 |
| Networking | Tailscale VPN across all nodes |
| Dev environment | Claude Code v2.1.37 on Pi |

### The Path Covenant
All core project files live at:
```
/mnt/shanebrain-raid/shanebrain-core/
```
No exceptions without a documented reason.

### The Dependency Covenant
- Cloud APIs are bridges, not foundations
- Every cloud dependency must have a local fallback
- If the internet goes down, the core must still work

---

## ARTICLE III — THE COLLABORATION COVENANT

### With AI (Claude / Anthropic)
Claude is a co-builder, not just a tool. Every repo carries acknowledgment of this partnership. Claude's outputs are reviewed, owned, and signed off by a human. AI assists. Humans decide.

### With Open Source
We give back where we can — stars, forks, issues, PRs. We don't just consume.

### With the Community
We build in public where possible. We document the failures. We show the real process. The mission is too important to perform.

---

## ARTICLE IV — THE CREDIT COVENANT

Every project, website, application, and piece of artwork built in this ecosystem **must visibly credit the following** where space allows:

| Partner | What They Made Possible |
|---------|------------------------|
| **Claude by Anthropic** · [claude.ai](https://claude.ai) | Co-built every line of this ecosystem |
| **Raspberry Pi 5** · [raspberrypi.com](https://www.raspberrypi.com) | Local compute that made AI affordable |
| **Pironman 5-MAX by Sunfounder** · [pironman.com](https://www.pironman.com) | The chassis that made RAID on a Pi real |

Minimum credit language for any project:

```
Built with Claude (Anthropic) · Runs on Raspberry Pi 5 + Pironman 5-MAX
```

---

## ARTICLE V — THE ECOSYSTEM MAP

```
ShaneBrain (Pi 5 · local AI · private)
  └── Angel Cloud (VPS · public platform · families)
        └── Pulsar AI (enterprise · secure · post-quantum)
              └── TheirNameBrain (personalized · legacy AI · generational)
                    └── ~800M users losing Windows 10 support
```

Every repo exists somewhere on this map. Know where yours lives.

---

## ARTICLE VI — AMENDMENTS

This Constitution is amended at the start of each month during the standing review session.

Amendments require:
1. A written reason
2. A check against all 9 Pillars
3. A version bump in the header
4. A commit message that starts with `constitution(vX.X):`

---

## SIGNATORIES

| Signatory | Role |
|-----------|------|
| **Shane** | Builder · Dispatcher · Father · Coach · Hazel Green, AL |
| **Claude (Anthropic)** | Co-builder · Constitutional Witness |
| **The Pi** | The iron that holds it all |

---

*Ratified: March 2026 · thebardchat/constitution · v1.0*
*"I could not have done any of this without them."*
