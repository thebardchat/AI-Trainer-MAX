# Module 4.6 — Guard Your Legacy

## WHAT YOU'LL BUILD

A security posture view of your entire AI brain system. You'll check system health, review security logs, audit privacy trails, and understand exactly what's running, who could access it, and how to verify that your legacy data stays private. You built something worth protecting. Now you lock the doors.

This isn't abstract security theory. This is a father checking the locks before bed. You've stored personal letters, family values, life stories, financial notes — the kind of data that matters more than a bank password. If someone got into your vault, they wouldn't just steal data. They'd steal your family's future words. This module teaches you to make sure that never happens.

---

## WHO THIS IS FOR

Anyone who has built a personal AI brain and stored real data in it. If your vault holds family letters, medical records, financial documents, or anything you wouldn't post on a billboard — this module is for you. Especially if you're building this brain to pass down to the next generation. The more valuable the contents, the more the container needs protecting.

---

## KEY TERMS

- **system_health**: The MCP tool that checks every service in your AI stack — Weaviate (vector database), Ollama (AI model), and the MCP gateway itself. Returns status for each service plus document counts for every collection. Think of it as a daily walk-around inspection before the crew rolls out.

- **security_log_search**: Searches the SecurityLog collection for events like failed access attempts, unusual activity, or system warnings. On a clean local system, empty logs are good news — like checking the security cameras and seeing nothing but an empty parking lot.

- **privacy_audit_search**: Searches the PrivacyAudit collection for records of who accessed what data and when. Even on a single-user system, this trail proves your data pipeline is clean. If you ever need to show that sensitive documents weren't mishandled, this is your proof.

- **Security Posture**: The overall picture of how protected your system is. Healthy services + clean security logs + verified privacy audits = strong posture. Any failures or unexpected entries = something to investigate.

- **Local-First Privacy**: Your data lives on YOUR machine. Not in someone's cloud. Not on a server you don't control. This means your security depends on YOUR machine's security — which is both the strength and the responsibility of local AI.

---

## THE LESSON

### Why security matters MORE for legacy data

Regular data breaches are bad. Someone steals your credit card number, you get a new card. Inconvenient but fixable.

Legacy data is different. If someone accesses the letter you wrote to your sons, the family medical history you documented, the financial plan you built for the next generation — that's not replaceable. That's not a card you can cancel. Those are the most personal words and plans you've ever committed to a system.

The security of your AI brain is the security of your family's inheritance. Treat it that way.

### Step 1: Check system health — the daily walk-around

Every morning on a job site, you walk the lot. Check the equipment. Make sure the trucks start. Make sure nothing happened overnight.

`system_health` is that walk-around for your AI brain:

```
python shared\utils\mcp-call.py system_health
```

What you're looking for:
- **Services running**: Weaviate, Ollama, and MCP gateway should all show as healthy/running
- **Collection counts**: How many documents in each collection (PersonalDoc, DailyNote, SecurityLog, etc.)
- **Any errors or warnings**: Anything that isn't green needs attention

If a service is down, your brain can't function. If collection counts drop unexpectedly, something deleted your data. Both are problems you catch early with this one command.

### Step 2: Review security logs — what happened while you weren't looking

Security logs record events. Failed login attempts. Unauthorized access tries. System warnings. On a local system that nobody else touches, you should see clean logs — and that's a good result.

```
python shared\utils\mcp-call.py security_log_search "{\"query\":\"failed login attempts\"}"
```

The search is semantic — you describe what you're looking for in plain English, and the system finds related entries. Search for:
- "failed login attempts" — someone tried to get in and couldn't
- "unauthorized access" — something tried to reach data it shouldn't
- "unusual activity" — anything out of the ordinary

Empty results on a local single-user system = clean system. That's the best result. When you eventually add users, expose services, or connect to a network, these logs become your first line of defense.

### Step 3: Audit privacy trails — who touched what

Privacy audits go deeper than security logs. They track data access patterns — which documents were read, which collections were queried, and when.

```
python shared\utils\mcp-call.py privacy_audit_search "{\"query\":\"vault access personal data\"}"
```

This matters for legacy because:
- You can prove your data hasn't been shared without your knowledge
- You can track which tools accessed which collections
- If you pass this brain to your children, the audit trail comes with it — showing the data is clean

### Step 4: Build your security posture view

Put it all together. A security posture is the complete picture:

| Check | Tool | What You Learn |
|-------|------|---------------|
| Services running? | `system_health` | Is everything online? |
| Suspicious events? | `security_log_search` | Did anything bad happen? |
| Data accessed properly? | `privacy_audit_search` | Is the data pipeline clean? |
| Collection sizes stable? | `system_health` | Is anything missing? |

Run all three regularly. Daily health checks. Weekly security reviews. Monthly privacy audits. That's the rhythm of someone who takes their legacy seriously.

### What "local" really means for privacy

Your brain runs on your machine. Period. Here's what that means:

**What's protected by default:**
- No data leaves your machine unless YOU send it somewhere
- No cloud company has a copy of your vault
- No terms of service can change how your data is used
- Your AI model runs locally — your prompts aren't sent to anyone

**What you're responsible for:**
- Physical security of the machine (lock the room, lock the screen)
- Software updates (keep your OS and services patched)
- Network exposure (don't open ports you don't need)
- Backups (local data dies if the drive dies — back it up)

Local-first means maximum privacy AND maximum responsibility. You're the security team. These tools help you do that job.

---

## THE PATTERN

```
HEALTH CHECK  →  SECURITY REVIEW  →  PRIVACY AUDIT  →  POSTURE REPORT
(system_health)  (security_log)     (privacy_audit)    (all clear?)
```

Four steps. Three tools. One picture. Run this pattern regularly and you'll catch problems before they become emergencies. Like checking the smoke detectors — boring when nothing's wrong, lifesaving when something is.

---

## WHAT YOU PROVED

- You can verify all services in your AI brain are running and healthy
- Security log searches detect (or confirm the absence of) suspicious events
- Privacy audit searches verify your data pipeline is clean
- Collection counts tell you if data is stable, growing, or unexpectedly shrinking
- Local-first means your data stays on your machine — no cloud, no third party
- The security of your legacy data is YOUR responsibility, and now you have the tools to handle it
- Empty security logs on a clean system = best possible result

**Next:** Run `exercise.bat` to audit your system and build your security posture.
