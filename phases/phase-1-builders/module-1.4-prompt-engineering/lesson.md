# Module 1.4: Prompt Engineering for Local Models

## WHAT YOU'LL BUILD

By the end of this module, you will know how to write prompts that
make a 1-billion parameter model produce answers that rival models
50x its size — on specific, well-scoped tasks.

Think of it like driving a pickup truck. A semi can haul more, but a
pickup with the right load plan gets the job done faster, cheaper, and
fits in your driveway. This module is the load plan.

Module 1.3 gave you a working pipeline. This module makes that pipeline
produce answers worth reading.

---

## KEY TERMS

**Prompt:** The text you send to the LLM. Everything the model knows
about what you want comes from the prompt. Bad prompt = bad answer.
Good prompt = good answer. Same model either way.

**System Prompt:** Instructions that define HOW the model should behave.
"You are a helpful assistant" is a system prompt. "You are a technical
writer who answers in exactly 3 bullet points" is a better one.

**Temperature:** A number between 0 and 1 that controls randomness.
Temperature 0 = the model picks the most likely word every time
(deterministic, predictable). Temperature 1 = the model gets creative
(varied, sometimes wild). For factual tasks, keep it low. For creative
tasks, let it breathe.

**Token:** The smallest unit the model reads. Roughly, 1 token = 3/4 of
a word. "ShaneBrain" is 3 tokens. "AI" is 1 token. The model's context
window is measured in tokens, not words.

**Few-Shot Prompting:** Giving the model examples of what you want before
asking your actual question. Show it 2-3 examples of the input/output
pattern, then give it a new input. The model follows the pattern.

**Zero-Shot Prompting:** Asking the model to do something with no
examples — just instructions. Works for simple tasks. Falls apart on
complex or formatted tasks with small models.

**Chain of Thought (CoT):** Telling the model to think step by step
before answering. This dramatically improves accuracy on reasoning
tasks, even on small models. The magic phrase: "Think step by step."

**Guardrails:** Constraints you put in the prompt to prevent the model
from going off-track. "Answer only from the context provided" is a
guardrail. "Do not make up information" is another. Small models need
more guardrails than large ones.

---

## THE LESSON

### Why Small Models Need Better Prompts

GPT-4 has over 1 trillion parameters. Claude has hundreds of billions.
Your llama3.2:1b has 1 billion. That's not a weakness — it's a design
choice. But it means:

- The model has less built-in knowledge
- It follows instructions less precisely
- It hallucinates more when given vague prompts
- It struggles with multi-step reasoning without guidance

The fix isn't a bigger model. The fix is better prompts. A well-crafted
prompt on a 1b model beats a lazy prompt on a 100b model for focused
tasks. You're about to see proof.

### Technique 1: Be Specific, Not General

Bad prompt:

    Tell me about AI.

What the 1b model does: Rambles for 500 words, covers random topics,
maybe gets some facts wrong.

Good prompt:

    Define artificial intelligence in exactly 2 sentences.
    Use language a 10th grader would understand.
    Do not use the words "revolutionary" or "transformative."

What the 1b model does: Gives you a tight, clear definition.

The rule: Every word in your prompt is a steering wheel. The more
specific you are, the less room the model has to drift.

### Technique 2: System Prompts (Set the Character)

Ollama lets you set a system prompt that frames every response:

    curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"system\":\"You are a concise technical assistant. Answer in 3 sentences or fewer. Use plain English. If you do not know, say so.\",\"prompt\":\"What is a vector database?\",\"stream\":false}"

Without the system prompt, the model might give you a 10-paragraph
essay. With it, you get three clean sentences.

System prompts work because they sit at the top of the context window.
The model reads them FIRST, before your question. They set the tone
for everything that follows.

### Technique 3: Temperature Control

    curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"What is 2 + 2?\",\"stream\":false,\"options\":{\"temperature\":0.0}}"

Temperature 0.0 on a math question = correct answer, every time.

    curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Write a creative tagline for a local AI company\",\"stream\":false,\"options\":{\"temperature\":0.8}}"

Temperature 0.8 on a creative task = varied, interesting output.

The rules:
- Factual/RAG queries: temperature 0.0 to 0.3
- Summarization: temperature 0.2 to 0.4
- Creative writing: temperature 0.6 to 0.9
- Never use 1.0 — the output gets incoherent on small models

### Technique 4: Few-Shot Prompting (Show, Don't Tell)

Instead of explaining what you want, SHOW the model:

    Classify the following text as POSITIVE, NEGATIVE, or NEUTRAL.

    Text: "The food was amazing and the service was fast."
    Classification: POSITIVE

    Text: "I waited 45 minutes and the order was wrong."
    Classification: NEGATIVE

    Text: "The weather today is cloudy with a chance of rain."
    Classification: NEUTRAL

    Text: "Angel Cloud makes local AI accessible to everyone."
    Classification:

The model sees the pattern and continues it. On a 1b model, few-shot
prompting improves accuracy by 30-50% on classification tasks compared
to zero-shot.

The key: Your examples must be consistent. Same format, same labels,
same structure. The model learns the PATTERN, not the meaning.

### Technique 5: Chain of Thought

Without CoT:

    What is 15% of 230?

Model might guess. Might get close. Might hallucinate.

With CoT:

    What is 15% of 230?
    Think step by step before giving the final answer.

Model response:
    Step 1: 15% means 15/100 = 0.15
    Step 2: 0.15 × 230 = 34.5
    The answer is 34.5.

The reasoning steps force the model to work through the problem instead
of jumping to an answer. This works even on 1b models for arithmetic,
logic, and multi-step questions.

### Technique 6: Guardrails for RAG

When using your RAG pipeline from Module 1.3, guardrails prevent the
model from hallucinating beyond your documents:

    Answer the question using ONLY the context provided below.
    Do not use any outside knowledge.
    If the context does not contain the answer, respond with exactly:
    "I don't have that information in my knowledge base."
    Do not guess. Do not infer beyond what is explicitly stated.

    CONTEXT:
    {your retrieved documents}

    QUESTION:
    {user question}

Each line in that prompt is a fence. Remove one, and the model starts
wandering. On a 1b model, you need ALL of them.

### Technique 7: Output Formatting

Small models struggle with complex output formats. Help them:

Bad:

    Give me information about Angel Cloud in a structured format.

Good:

    Answer in this exact format:
    NAME: [name]
    MISSION: [one sentence]
    TECH: [comma separated list]
    RAM: [number]GB

    Information: Angel Cloud is a local AI platform using Ollama
    and Weaviate, running on 7.4GB RAM, built for AI literacy.

The model fills in the template. Small models are much better at
following templates than inventing formats.

### The Prompt Engineering Checklist

Before sending any prompt to llama3.2:1b, run through this:

    □ Is there a system prompt defining the model's role?
    □ Is the task specific (not vague or open-ended)?
    □ Is the temperature appropriate for the task type?
    □ Would few-shot examples improve accuracy?
    □ Does a complex task need "think step by step"?
    □ Are there guardrails preventing hallucination?
    □ Is the output format explicitly defined?
    □ Is the prompt under 1000 tokens (leave room for the answer)?

If you check all 8 boxes, your 1b model will surprise you.

---

## WHAT YOU PROVED

- You can make a 1b model produce focused, accurate answers
- You understand 7 prompt engineering techniques for local models
- You know when to use temperature 0 vs temperature 0.8
- You can write few-shot prompts that teach the model by example
- You can add guardrails that prevent hallucination in RAG
- You have a reusable checklist for every prompt you write

---

## NEXT: Run exercise.bat to test each technique hands-on.
