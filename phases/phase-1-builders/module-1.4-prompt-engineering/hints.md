# Module 1.4 Hints — Prompt Engineering for Local Models

## Progressive hints — try each level before moving to the next.

---

## HINT LEVEL 1: General Direction

This module is different from the others. There's no infrastructure to
debug — if Ollama is running and the model is pulled, everything works.
The challenge is in the PROMPTS, not the plumbing.

If an experiment gives unexpected output, that's actually the lesson.
Small models are unpredictable with bad prompts and reliable with good
ones. The gap between the two IS the skill you're building.

If verify.bat fails a check, it's usually because the 1b model didn't
follow instructions precisely. That doesn't mean the technique is wrong.
It means small models need EVEN MORE structure. Add more constraints,
more examples, more explicit formatting.

---

## HINT LEVEL 2: Specific Guidance

### System prompt doesn't seem to change anything
Make the system prompt more aggressive:

Instead of: "Answer in 3 sentences or fewer."
Try: "Answer in exactly 1 sentence. Do not write more than 1 sentence.
If your answer is longer than 1 sentence, you have failed."

Small models respond better to stronger language in system prompts.
It's not rude — it's precise.

### Temperature doesn't seem to change output
Two possible causes:
1. The prompt is too constrained — if you ask "What is 2+2?" there's
   only one answer regardless of temperature
2. You're testing with very short prompts — temperature effects are
   more visible on longer, more open-ended responses

Try temperature comparison on: "Write a creative tagline for Angel Cloud"
Run it 3 times at temp 0.0, then 3 times at temp 0.8. Compare.

### Few-shot classification gives wrong label
Add more examples. The 1b model sometimes needs 4-5 examples to lock
into a pattern where a larger model needs 2-3.

Also make sure your instruction is explicit:

    "Respond with ONLY the classification label.
     Do not explain. Do not add any other text.
     Your entire response should be one word:
     POSITIVE, NEGATIVE, or NEUTRAL."

### Chain of thought doesn't show steps
The model might jump straight to an answer. Force the steps:

    "What is 20 percent of 150?

     Solve this step by step:
     Step 1: Convert the percentage to a decimal.
     Step 2: Multiply the decimal by the number.
     Step 3: State the final answer.

     Now solve:"

Pre-formatting the steps gives the model a scaffold to fill in.

### Guardrail check fails (model answers about Mars)
The 1b model sometimes ignores guardrails. Stack multiple:

    "Answer using ONLY the context below.
     Do not use outside knowledge.
     Do not guess.
     Do not infer.
     If the context does not contain the answer, respond with
     EXACTLY this text and nothing else:
     'I don't have that information in my knowledge base.'

     CONTEXT:
     Angel Cloud is a local AI platform built in Alabama.

     QUESTION:
     What is the population of Mars?"

If it STILL answers about Mars, that's a known limitation of 1b
models. Larger models (3b, 7b) hold guardrails more reliably. For
production RAG, consider this when choosing model size.

---

## HINT LEVEL 3: The Full Technique Reference

Here's every technique from the lesson with copy-paste curl commands:

### Specific prompt:
    curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Define artificial intelligence in exactly 2 sentences. Use language a 10th grader would understand.\",\"stream\":false,\"options\":{\"temperature\":0.3}}"

### System prompt:
    curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"system\":\"You are a concise technical assistant. Answer in 3 sentences or fewer. Use plain English. If you do not know, say so.\",\"prompt\":\"What is a vector database?\",\"stream\":false,\"options\":{\"temperature\":0.3}}"

### Temperature 0 (factual):
    curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"What is 2 + 2? Answer with just the number.\",\"stream\":false,\"options\":{\"temperature\":0.0}}"

### Temperature 0.8 (creative):
    curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Write a creative tagline for a local AI company.\",\"stream\":false,\"options\":{\"temperature\":0.8}}"

### Few-shot:
    curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Classify as POSITIVE, NEGATIVE, or NEUTRAL. Respond with only the label.\n\nText: Great product!\nLabel: POSITIVE\n\nText: Terrible experience.\nLabel: NEGATIVE\n\nText: It arrived on Monday.\nLabel: NEUTRAL\n\nText: This is the best tool ever.\nLabel:\",\"stream\":false,\"options\":{\"temperature\":0.0}}"

### Chain of thought:
    curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"What is 20 percent of 150? Think step by step before giving the final answer.\",\"stream\":false,\"options\":{\"temperature\":0.0}}"

### Guardrail:
    curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Answer using ONLY the context. If no answer exists in context, say I don't have that information.\n\nCONTEXT:\nAngel Cloud is built in Alabama.\n\nQUESTION:\nWhat is the population of Mars?\n\nANSWER:\",\"stream\":false,\"options\":{\"temperature\":0.0}}"

---

## STILL STUCK?

Prompt engineering is a skill, not a formula. The experiments in this
module show you the TOOLS. Using them well takes practice.

The best way to improve: take a task you actually need done (an email,
a summary, a classification) and iterate on the prompt 3-5 times.
Each iteration, change ONE thing. Watch what improves.

That's how you train yourself AND the model.
