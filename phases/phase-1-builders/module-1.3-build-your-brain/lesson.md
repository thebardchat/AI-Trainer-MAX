# Module 1.3: Build Your Brain

## WHAT YOU'LL BUILD

By the end of this module, you will have a working RAG pipeline — a
system that loads YOUR documents, stores them as vectors, and lets you
ask questions that get answered from YOUR knowledge, not the internet.

This is the ShaneBrain blueprint. What took weeks to figure out, you're
about to build in 15 minutes.

Think of it like building a house. Module 1.1 gave you the power tools
(Ollama). Module 1.2 poured the foundation (Weaviate). Now you're
framing the walls — connecting those pieces into something you can
actually live in.

---

## KEY TERMS

**RAG (Retrieval-Augmented Generation):** A system where the AI retrieves
relevant documents FIRST, then generates an answer based on what it
found. Without RAG, the AI guesses from training data. With RAG, it
answers from YOUR data. That's the difference between a random stranger
and a coworker who read the same files you did.

**Pipeline:** A series of steps that run in order, each one feeding into
the next. Load documents → embed them → store vectors → query by meaning
→ feed context to LLM → get answer. That's a RAG pipeline.

**Context Window:** The amount of text you can feed to the LLM along with
your question. Think of it as the LLM's short-term memory. For
llama3.2:1b, it's about 2048 tokens (~1500 words). Everything the model
needs to answer MUST fit in that window.

**Chunking:** Breaking a large document into smaller pieces before
embedding. A 10-page document won't fit in one vector search result. But
10 half-page chunks? Now Weaviate can find the ONE chunk that answers
your question.

**Prompt Template:** A reusable text structure that combines your question
with retrieved context before sending it to the LLM. Instead of just
asking "What's our mission?", the template says: "Based on these
documents: [CONTEXT], answer this question: [QUESTION]."

**Ingestion:** The process of loading documents into the vector database.
Read the file, split it into chunks, embed each chunk, store each chunk
with its vector. That's ingestion. Do it once, search forever.

---

## THE LESSON

### What You Already Have

From Modules 1.1 and 1.2, your stack looks like this:

    Ollama (localhost:11434) ← Generates text + embeddings
    Weaviate (localhost:8080) ← Stores vectors + searches by meaning

Right now these two systems don't talk to each other automatically.
You manually copied embeddings between them in Module 1.2. That was
on purpose — so you understand the plumbing.

Now we automate the plumbing. That's the pipeline.

### The RAG Flow

Here's what happens every time you ask ShaneBrain a question:

    YOU: "What's the Angel Cloud mission?"
         │
         ▼
    [1] Embed the question (Ollama → vector)
         │
         ▼
    [2] Search Weaviate (find closest documents by meaning)
         │
         ▼
    [3] Build the prompt (question + retrieved docs)
         │
         ▼
    [4] Send to LLM (Ollama generates answer from context)
         │
         ▼
    ANSWER: Based on your documents, Angel Cloud is...

Four steps. That's the entire architecture of every RAG system on the
planet. ChatGPT's retrieval, Perplexity's search, ShaneBrain's brain —
all the same four steps. The difference is yours runs LOCAL.

### Step 1: Create your knowledge documents

Create a folder for your source documents. On your machine:

    mkdir D:\Angel_Cloud\shanebrain-core\training-tools\phases\phase-1-builders\module-1.3-build-your-brain\knowledge

Now create a few simple text files in that folder. Here are three to
start with. Create each one using notepad or echo:

File: mission.txt

    Angel Cloud is a family-driven, faith-rooted AI platform. Our mission
    is to make AI literacy accessible to every person. We believe you
    should own your AI, not rent it. Everything runs local. No cloud
    dependencies. No subscriptions. Built in Alabama for the world.

File: values.txt

    The Angel Cloud values are: Faith first. Family always. Sobriety as
    strength. Every person deserves access to AI. Local-first means you
    own your data. We build for the 800 million Windows users who are
    about to lose security updates. Legacy matters — what you build
    today protects your children tomorrow.

File: technical.txt

    Angel Cloud runs on Ollama for local LLM inference using the
    llama3.2:1b model. Weaviate provides vector storage and semantic
    search. The RAG pipeline connects them — documents go in, embeddings
    get stored, questions get answered from your own knowledge base.
    Everything fits in 7.4GB RAM.

### Step 2: Ingest documents (the automation)

In Module 1.2, you manually embedded text and stored it. Now we script
that process. The exercise.bat for this module includes an ingestion
script that does this for EVERY file in the knowledge folder:

    For each .txt file:
      1. Read the file content
      2. Send content to Ollama's embedding API
      3. Store the text + vector in Weaviate under the "Document" class

After ingestion, every document is searchable by meaning.

### Step 3: Query the pipeline

Once documents are ingested, querying works like this:

    1. You type a question
    2. The script embeds your question via Ollama
    3. The script searches Weaviate for the closest document
    4. The script builds a prompt:

       "Based on the following context:
       [RETRIEVED DOCUMENT TEXT]

       Answer this question: [YOUR QUESTION]

       Answer only from the context provided. If the context doesn't
       contain the answer, say 'I don't have that information.'"

    5. The script sends that prompt to Ollama's generate API
    6. You get an answer grounded in YOUR documents

This is the exact same flow ShaneBrain uses. You're building the
engine that powers it.

### Step 4: Understanding chunking (why it matters)

Our example documents are short — a few sentences each. Real documents
are pages or chapters long. A 10-page PDF won't fit in the LLM's
context window, and searching for it as one giant vector loses precision.

The fix: chunking. Break each document into pieces of roughly 200-500
words. Each chunk gets its own embedding and its own entry in Weaviate.

When you search, Weaviate returns the most relevant CHUNK, not the
whole document. That chunk fits in the context window. The LLM gets
exactly the information it needs.

For this module, our documents are small enough to skip chunking. But
Module 1.5 revisits this when you package everything for production.

### Step 5: The prompt template (the secret weapon)

The prompt template is what separates a useful RAG system from a
toy demo. Here's the one we use:

    You are ShaneBrain, a local AI assistant. Answer the user's question
    using ONLY the context provided below. If the context does not contain
    enough information to answer, say "I don't have that information in
    my knowledge base."

    CONTEXT:
    {retrieved_text}

    QUESTION:
    {user_question}

    ANSWER:

Three critical design decisions in that template:

1. "ONLY the context" — prevents the model from making things up
2. "I don't have that information" — teaches the model to admit gaps
3. The CONTEXT comes BEFORE the question — the model reads context
   first, then sees what you're asking. Order matters.

---

## HOW THIS IS SHANEBRAIN

What you're building in this exercise IS ShaneBrain at its core:

- ShaneBrain loads documents from D:\Angel_Cloud\shanebrain-core\knowledge\
- ShaneBrain embeds them with Ollama and stores them in Weaviate
- ShaneBrain answers questions from those documents
- The start-shanebrain.bat launcher runs this pipeline every time

The only difference between your exercise and the production system is
scale — more documents, better chunking, and a polished launcher. You
build that in Module 1.5.

---

## WHAT YOU PROVED

- You can build a complete RAG pipeline from scratch
- You understand the 4-step flow: embed → search → build prompt → generate
- You can ingest multiple documents into a vector database automatically
- You can query your own knowledge and get grounded answers
- You understand prompt templates and why context ordering matters
- You're running the same architecture as ShaneBrain

---

## NEXT: Run exercise.bat to build your first RAG pipeline.
