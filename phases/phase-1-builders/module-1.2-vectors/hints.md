# Module 1.2 Hints — Vectors Made Simple

## Progressive hints — try each level before moving to the next.

---

## HINT LEVEL 1: General Direction

The most common issue in this module is Weaviate not running. Check with:

    curl http://localhost:8080/v1/.well-known/ready

If that doesn't respond, Weaviate isn't started. Go back to the Docker
command in the lesson.

The second most common issue is trying to store a document WITHOUT the
embedding vector. Weaviate accepts the object but semantic search won't
work. Make sure you're copying the FULL embedding array from Ollama.

---

## HINT LEVEL 2: Specific Guidance

### "connection refused" on port 8080
Weaviate isn't running. If using Docker:

    docker ps

Check if a container named "weaviate" is listed. If not:

    docker start weaviate

If it was never created, run the full docker run command from the lesson.

### "class name Document already exists"
This is fine. It means you already created the schema. Skip to Task 3.

### Embedding array is massive / hard to copy
Yes — the embedding array for llama3.2:1b has 2048 numbers. That's
normal. Use your terminal's copy function to grab the entire array
including the square brackets.

Pro tip: You can pipe the Ollama response directly. But for learning,
manual copy-paste helps you SEE what an embedding looks like.

### "vector lengths don't match"
This means the vector you pasted has a different number of dimensions
than what Weaviate expects. Make sure you're using the same model
(llama3.2:1b) for ALL embeddings. Don't mix models — each one produces
vectors of different sizes.

### GraphQL query returns empty
Two possible causes:
1. No documents stored — run Task 3 first
2. The nearVector embedding is too different — make sure you're
   generating it with the same model (llama3.2:1b)

### "Docker not recognized"
Docker isn't installed. Get Docker Desktop from:
https://www.docker.com/products/docker-desktop/

After install, restart your terminal. Docker needs a fresh session.

---

## HINT LEVEL 3: The Answer (but try the above first)

Here's the complete sequence. Run each line in order:

    Terminal 1 (keep open):
    ollama serve

    Terminal 2 (keep open):
    docker start weaviate
    (or run the full docker run command if first time)

    Terminal 3 (working terminal):

    Step 1 — Verify services:
    curl http://localhost:8080/v1/.well-known/ready
    curl http://localhost:11434/api/tags

    Step 2 — Create schema:
    curl -X POST http://localhost:8080/v1/schema -H "Content-Type: application/json" -d "{\"class\":\"Document\",\"description\":\"Training documents for ShaneBrain\",\"vectorizer\":\"none\",\"properties\":[{\"name\":\"title\",\"dataType\":[\"text\"],\"description\":\"Document title\"},{\"name\":\"content\",\"dataType\":[\"text\"],\"description\":\"Document body text\"}]}"

    Step 3 — Get embedding:
    curl http://localhost:11434/api/embeddings -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Angel Cloud is a local-first AI platform built for families.\"}"

    Step 4 — Store document (paste the embedding from Step 3):
    curl -X POST http://localhost:8080/v1/objects -H "Content-Type: application/json" -d "{\"class\":\"Document\",\"properties\":{\"title\":\"About Angel Cloud\",\"content\":\"Angel Cloud is a local-first AI platform built for families.\"},\"vector\":[...PASTE EMBEDDING HERE...]}"

    Step 5 — Verify stored:
    curl http://localhost:8080/v1/objects?class=Document

    Step 6 — Run verify.bat

If all of that works, you're done. Run verify.bat and move on.

---

## STILL STUCK?

Weaviate docs: https://weaviate.io/developers/weaviate
Ollama embeddings: https://ollama.com/blog/embedding-models

The hardest part of this module is the copy-paste of long embedding
arrays. If that's tripping you up, Module 1.3 automates all of this
with a script. You're doing the hard version on purpose — so you
understand what's happening under the hood.

That's how builders learn. You're almost there.
