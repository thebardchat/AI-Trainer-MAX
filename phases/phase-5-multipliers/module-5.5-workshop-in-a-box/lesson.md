# Module 5.5 — Workshop in a Box

## WHAT YOU'LL BUILD

A complete, ready-to-run workshop kit for teaching a room full of people how to install and use local AI. You'll generate a 30-minute workshop script with timed sections, checkpoints, and a materials list. Then you'll build a facilitator checklist covering setup, troubleshooting, and follow-up. Both get stored in your vault as reusable teaching assets.

This is the multiplier moment. Module 5.4 taught you how to teach one person. This module packages that knowledge into a kit you can hand to anyone and say: "Run this. You'll have a room full of new AI users in 30 minutes."

Think of it like a toolbox. A good carpenter doesn't just know how to use a hammer — he keeps a kit packed and ready so he can walk onto any job site and get to work. That's what you're building here. A teaching kit. Everything packaged. Everything ready. Open the box and go.

---

## KEY TERMS

- **Workshop Script**: A timed, step-by-step plan for teaching a group. Includes what to say, what to show, and when to check that everyone is keeping up. This is your lesson plan for a live session.

- **Facilitator Checklist**: A one-page reference for the person running the workshop. Pre-workshop setup, materials needed, common problems and fixes, follow-up actions. The checklist makes sure nothing gets forgotten when it's go time.

- **Teaching Asset**: Any document stored in your vault under the "teaching" category that helps you or someone else teach AI skills. Workshop scripts, checklists, lesson outlines, tip sheets — all teaching assets.

- **draft_create**: The MCP tool that generates writing from a prompt. When `use_vault_context` is true, it pulls from your stored knowledge and vault documents to make the output personal and grounded in your experience.

- **vault_add**: Stores a document in your personal vault with a category and title. Once stored, it's searchable and available as context for future drafts.

---

## THE LESSON

### From student to teacher to workshop leader

You started this training as someone learning local AI from scratch. Then you taught someone else what you learned. Now you're packaging that teaching into something that scales — a workshop anyone can run.

This is how knowledge actually spreads. Not through documentation nobody reads. Not through videos people half-watch. Through one person standing in a room saying "here's how this works" while five other people follow along on their own machines.

### Step 1: Gather your teaching context

Before you generate anything, search your knowledge base for what you already stored in Module 5.4. Those teaching entries — tips, lessons, methods — become the foundation for your workshop script.

```
python shared\utils\mcp-call.py search_knowledge "{\"query\":\"teaching local AI\"}"
```

This shows the AI what you've already learned about teaching. When you generate the workshop script, it pulls from this context instead of writing generic instructions.

### Step 2: Generate the workshop script

Use `draft_create` with a detailed prompt. The more specific you are about structure, timing, and audience, the better the output:

```
python shared\utils\mcp-call.py draft_create "{\"prompt\":\"Write a 30-minute workshop script for teaching 5 people how to install Ollama and run their first local AI query. Include a materials list, 3 timed sections (10 min each), and 2 checkpoints where participants verify their setup works.\",\"draft_type\":\"general\",\"use_vault_context\":true}"
```

The script comes back with sections, timing marks, and checkpoint instructions. It's a first draft — read it, adjust the timing, add your own examples. But the structure is solid and ready to use.

### Step 3: Generate the facilitator checklist

A workshop script tells you what to teach. A facilitator checklist tells you how to prepare and what to do when things go wrong:

```
python shared\utils\mcp-call.py draft_create "{\"prompt\":\"Write a one-page facilitator checklist for running a local AI workshop. Include: pre-workshop setup steps, materials needed, common problems and solutions, and a post-workshop follow-up plan.\",\"draft_type\":\"general\",\"use_vault_context\":true}"
```

This is the safety net. The checklist catches the things you forget under pressure — "Did I test the WiFi?" "What if someone's laptop won't install Ollama?" "What do I send people after the workshop?"

### Step 4: Store both as teaching assets

Once generated, both documents go into your vault under the "teaching" category:

```
python shared\utils\mcp-call.py vault_add "{\"content\":\"[your workshop script]\",\"category\":\"teaching\",\"title\":\"Local AI Workshop Script\"}"
python shared\utils\mcp-call.py vault_add "{\"content\":\"[your checklist]\",\"category\":\"teaching\",\"title\":\"Workshop Facilitator Checklist\"}"
```

Now they're searchable, reusable, and available as context for future drafts. Next time you need a workshop for a different topic, the AI will pull from these existing assets and build on what worked.

---

## THE PATTERN

```
GATHER CONTEXT     ->  GENERATE SCRIPT    ->  GENERATE CHECKLIST  ->  STORE IN VAULT
(search_knowledge)    (draft_create)          (draft_create)          (vault_add x2)
```

The pattern is: search what you know, generate structured teaching materials, store the results. Each time you do this, your vault gets richer. Each time the vault gets richer, the next workshop gets better. That's the flywheel.

---

## WHAT YOU PROVED

- You can generate a complete, timed workshop script using AI and your own stored knowledge
- A facilitator checklist covers setup, materials, troubleshooting, and follow-up in one page
- Teaching assets stored in the vault are searchable and reusable for future workshops
- One trained person with a workshop kit can train a room — that's the multiplier
- The AI builds on YOUR teaching experience, not generic templates, because it pulls from your vault
- You went from "I learned AI" to "I can teach a room full of people AI" in five modules

**Next:** Run `exercise.bat`
