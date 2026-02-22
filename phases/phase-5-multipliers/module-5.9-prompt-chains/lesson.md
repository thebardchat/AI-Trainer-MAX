# Module 5.9 — Prompt Chains

## WHAT YOU'LL BUILD

A multi-step prompt pipeline where one AI response feeds directly into the next. Instead of asking the AI one big question and hoping for a good answer, you'll break the work into focused stages — like an assembly line where each station does one job and passes the result forward.

You've done single-shot prompts (Module 1.4). You've chained different tools together (Module 2.6). Now you'll chain the SAME tool multiple times, where each step's output becomes the next step's input. Three steps: raw vault content goes in one end, a polished personal mission statement comes out the other.

---

## KEY TERMS

- **Prompt Chain**: A sequence of AI calls where each step's output feeds as context into the next step's prompt. Step 1 produces raw material. Step 2 refines it. Step 3 shapes the final product. Each link in the chain does one focused job.

- **Context Injection**: Taking the output from a previous AI response and embedding it directly into the next prompt. Instead of the AI guessing what came before, you hand it the exact text to work with.

- **Single-Shot vs. Multi-Step**: A single-shot prompt asks the AI to do everything at once — search, analyze, and create in one breath. A multi-step chain breaks that into separate stages. Each stage is simpler, more focused, and easier to debug when something goes wrong.

- **Pipeline**: A series of processing steps where data flows in one direction — input to output, no going back. Like water through a filtration system: each filter removes something different, and what comes out the end is cleaner than what went in.

- **Intermediate Output**: The result from a middle step in a chain. It's not the final answer — it's a work product that the next step needs. You save these to temp files so the chain can keep moving forward.

---

## THE LESSON

### Why One Giant Prompt Fails

Here's what happens when you ask an AI to do three things at once:

> "Search my vault, summarize my personal documents into 3 bullet points focusing on themes and values, then analyze those bullets to find the 2 most important themes with explanations, then write a personal mission statement based on those themes."

The AI tries to juggle all three jobs at once. The summary is rushed because it's already thinking about the mission statement. The theme analysis is thin because the model burned most of its attention on the summary. The final output is mediocre across the board.

Now compare that to three separate, focused prompts — each one doing exactly one job with full attention. That's a prompt chain.

### The Assembly Line Analogy

Think about a factory assembly line. Station 1 cuts the raw material to size. Station 2 shapes it. Station 3 finishes and polishes it. No station tries to do all three jobs. Each one does its job well and passes the result to the next.

Your prompt chain works the same way:

```
VAULT CONTENT (raw material)
     |
     v
STEP 1: Summarize — condense into 3 focused bullets
     |
     v
STEP 2: Analyze — identify the 2 strongest themes
     |
     v
STEP 3: Create — write a mission statement from those themes
     |
     v
FINAL OUTPUT (polished product)
```

Each step gets ONE job. Each step gets the full output of the previous step as its input. No guessing, no shortcuts.

### How Context Injection Works

The key technique is saving each step's output to a file, then reading that file into the next step's prompt. In practice:

1. Call `chat_with_shanebrain` with a focused prompt. Save the response to `step1.txt`.
2. Read `step1.txt` into a variable. Build a new prompt that includes that text as context. Call `chat_with_shanebrain` again. Save to `step2.txt`.
3. Read `step2.txt`. Feed it to `draft_create` for the final polished output. Save to `step3.txt`.

Each step sees exactly what the previous step produced. No information lost. No context forgotten.

### Why Chains Beat Monoliths

Three reasons:

**Focus.** A prompt that says "summarize these documents in 3 bullets" will produce better bullets than a prompt that says "summarize, analyze, and write a mission statement." The model gives its full attention to one task.

**Quality.** Each step builds on a clean, focused output from the previous step. The theme analysis works with a tight summary, not a sprawling document dump. The mission statement works with clear themes, not a messy analysis.

**Debugging.** When the final output is wrong, you can check each step independently. Bad mission statement? Look at step 2. Bad themes? Look at step 1. Bad summary? Look at the raw input. You can fix one link without rebuilding the whole chain.

### The Three-Step Chain You'll Build

Here's the specific chain this module runs:

**Gather:** Pull content from your vault (`vault_search`) and knowledge base (`search_knowledge`). This is your raw material — the personal documents and knowledge entries you've stored.

**Step 1 — Summarize:** Feed the raw content to `chat_with_shanebrain` with a prompt that says "summarize in exactly 3 bullet points focusing on key themes and values." The AI reads everything and distills it down.

**Step 2 — Analyze:** Feed the 3-bullet summary to `chat_with_shanebrain` with a prompt that says "identify the 2 most important themes and explain why each matters in one sentence." The AI takes the condensed summary and finds the core patterns.

**Step 3 — Create:** Feed the theme analysis to `draft_create` with a prompt that says "write a one-paragraph personal mission statement based on these themes." The drafting tool takes the distilled themes and produces something you can actually use.

Raw vault content goes in. A personal mission statement comes out. Three stations, three jobs, one clean result.

### Where Chains Go From Here

Once you understand the pattern, you can build chains for anything:

- **Research chain:** Search -> Summarize -> Compare -> Recommend
- **Writing chain:** Outline -> Draft -> Edit -> Polish
- **Analysis chain:** Gather data -> Find patterns -> Draw conclusions -> Generate report

The pattern is always the same: break the big job into focused steps, save each output, feed it forward. Every chain you build follows this blueprint.

---

## THE PATTERN

```
GATHER raw content (vault_search + search_knowledge)
     |
     v
STEP 1: chat_with_shanebrain("Summarize in 3 bullets: [raw content]")
     |  save to step1.txt
     v
STEP 2: chat_with_shanebrain("Find 2 themes: [step1.txt content]")
     |  save to step2.txt
     v
STEP 3: draft_create("Write mission statement: [step2.txt content]")
     |  save to step3.txt
     v
DISPLAY all three steps — see the chain in action
```

Each step does one job. Each output feeds the next input. That's a prompt chain.

---

## WHAT YOU PROVED

- Breaking a complex task into focused steps produces better results than one giant prompt
- Each step in a prompt chain does one job and passes its output forward
- Context injection — feeding one AI response into the next prompt — keeps the chain connected
- You can debug each step independently when something goes wrong
- The same tool (`chat_with_shanebrain`) produces different outputs depending on how you frame the prompt
- Prompt chains turn raw vault content into polished, actionable output through progressive refinement

**Next:** Run `exercise.bat`
