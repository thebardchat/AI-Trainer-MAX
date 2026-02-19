# Module 1.2: Vectors Made Simple

## WHAT YOU'LL BUILD

By the end of this module, you will have a vector database running on
your machine, loaded with your own documents, answering questions based
on meaning — not just keyword matching.

Think of it like this: A normal search is like looking through a filing
cabinet by label. Vector search is like having a librarian who actually
READ every document and can find the one you need even if you describe
it in completely different words.

Module 1.1 gave your AI a voice. This module gives it a memory.

---

## KEY TERMS

**Vector:** A list of numbers that represents the MEANING of a piece of
text. The sentence "I'm hungry" and "I need food" have different words
but nearly identical vectors. That's the power.

**Embedding:** The process of converting text into a vector. You feed in
words, you get back numbers. Those numbers capture what the words MEAN,
not just what they spell.

**Vector Database:** A database built to store and search vectors. Instead
of matching exact words (like SQL), it finds documents with the closest
MEANING to your question. Weaviate is ours.

**Weaviate:** An open-source vector database that runs locally. It stores
your embeddings, indexes them, and lets you search by meaning. Think of
it as the filing cabinet with the smart librarian built in.

**Semantic Search:** Searching by meaning instead of keywords. Ask
"What's our refund policy?" and it finds the document about "return
procedures and money-back guarantees" — even though those words don't
match.

**Schema:** The structure you define in Weaviate that tells it what kind
of data you're storing. Like building the shelves before you put the
books on them.

**Class:** In Weaviate, a class is a category of objects. If you're storing
notes, you'd create a "Note" class. Think of it as a table in a regular
database, but for vectors.

---

## THE LESSON

### Prerequisites

Before starting, you need:
- Ollama running (Module 1.1 — verify with: curl http://localhost:11434/api/tags)
- Weaviate running locally on port 8080

If Weaviate isn't running yet, here's the fastest path. You need Docker
installed. Then run:

    docker run -d --name weaviate -p 8080:8080 -p 50051:50051 ^
      -e QUERY_DEFAULTS_LIMIT=25 ^
      -e AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED=true ^
      -e PERSISTENCE_DATA_PATH=/var/lib/weaviate ^
      -e DEFAULT_VECTORIZER_MODULE=none ^
      -e CLUSTER_HOSTNAME=node1 ^
      cr.weaviate.io/semitechnologies/weaviate:1.28.4

That's it. One command. Weaviate is now running on your machine.

No Docker? You can also download the Weaviate binary directly from
https://weaviate.io/developers/weaviate/installation — but Docker
is the fastest route.

### Step 1: Verify Weaviate is alive

    curl http://localhost:8080/v1/.well-known/ready

You should see:

    {}

Empty JSON = healthy. That's Weaviate saying "I'm here, ready to work."

Check what's in the database:

    curl http://localhost:8080/v1/schema

You should see:

    {"classes":[]}

Empty classes. Clean slate. Good — we're about to fill it.

### Step 2: Create a schema (build the shelves)

Before storing anything, Weaviate needs to know WHAT you're storing.
We'll create a class called "Document" with two properties: title and
content.

Run this curl command (copy-paste the whole thing):

    curl -X POST http://localhost:8080/v1/schema -H "Content-Type: application/json" -d "{\"class\":\"Document\",\"description\":\"Training documents for ShaneBrain\",\"vectorizer\":\"none\",\"properties\":[{\"name\":\"title\",\"dataType\":[\"text\"],\"description\":\"Document title\"},{\"name\":\"content\",\"dataType\":[\"text\"],\"description\":\"Document body text\"}]}"

You should get back a JSON blob that echoes your schema. The key part:

    "class": "Document"

That means the shelves are built. Now verify:

    curl http://localhost:8080/v1/schema

You should see your "Document" class listed with its properties.

### Step 3: Generate an embedding (turn words into numbers)

This is where Ollama comes in. Ollama can generate embeddings — not just
chat responses. We'll use it to convert text into vectors.

    curl http://localhost:11434/api/embeddings -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Angel Cloud is a family-driven AI platform\"}"

You'll get back something like:

    {"embedding":[0.123, -0.456, 0.789, ...]}

That array of numbers IS the meaning of your sentence, encoded as math.
The model compressed "Angel Cloud is a family-driven AI platform" into
a list of numbers that captures its essence.

### Step 4: Store a document with its vector

Now we combine Steps 2 and 3. We'll store a document AND its embedding
in Weaviate.

First, generate the embedding (you already know how):

    curl http://localhost:11434/api/embeddings -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Angel Cloud is a local-first AI platform built for families. It runs on your own hardware with no cloud dependencies.\"}"

Copy the embedding array from the response. Then store it in Weaviate:

    curl -X POST http://localhost:8080/v1/objects -H "Content-Type: application/json" -d "{\"class\":\"Document\",\"properties\":{\"title\":\"About Angel Cloud\",\"content\":\"Angel Cloud is a local-first AI platform built for families. It runs on your own hardware with no cloud dependencies.\"},\"vector\":[PASTE_YOUR_EMBEDDING_HERE]}"

Replace [PASTE_YOUR_EMBEDDING_HERE] with the actual numbers from the
embedding response. Yes, it's a long array. That's normal.

You should get back a JSON object with an "id" field — that's your
document's unique ID in Weaviate. It's stored. It has meaning.

### Step 5: Search by meaning (the magic moment)

Now ask Weaviate a question using a vector. First, generate an embedding
for your QUESTION:

    curl http://localhost:11434/api/embeddings -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"What platform runs without internet?\"}"

Then search Weaviate with that vector:

    curl -X POST http://localhost:8080/v1/graphql -H "Content-Type: application/json" -d "{\"query\":\"{Get{Document(nearVector:{vector:[PASTE_QUESTION_EMBEDDING_HERE]},limit:1){title content _additional{distance}}}}\"}"

Replace [PASTE_QUESTION_EMBEDDING_HERE] with your question's embedding.

You should get back your "About Angel Cloud" document — even though
your question ("What platform runs without internet?") uses completely
different words than the stored content.

That's semantic search. That's the memory layer for ShaneBrain.

### Step 6: Verify your data is persisted

    curl http://localhost:8080/v1/objects?class=Document

This returns all stored Document objects. You should see the one you
added. As long as Weaviate is running (or Docker persists the volume),
your data stays.

---

## HOW THIS CONNECTS TO SHANEBRAIN

ShaneBrain's entire knowledge system works exactly like what you just
built:

1. Documents get loaded (your notes, your values, your history)
2. Each document gets embedded into a vector via Ollama
3. Vectors get stored in Weaviate
4. When you ask ShaneBrain a question, it embeds your question
5. Weaviate finds the most relevant documents by meaning
6. Those documents get fed to the LLM as context
7. The LLM answers based on YOUR data — not random internet training

That's RAG. That's Module 1.3. But first — prove you've got the
foundation.

---

## WHAT YOU PROVED

- You can run a vector database on your own machine
- You understand the difference between keyword search and semantic search
- You can generate embeddings from text using Ollama
- You can store documents with vectors in Weaviate
- You can search by MEANING and get relevant results
- You're ready to build a full RAG pipeline (Module 1.3)

---

## NEXT: Run exercise.bat to lock in what you learned.
