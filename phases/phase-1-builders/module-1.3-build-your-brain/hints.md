# Module 1.3 Hints — Build Your Brain

## Progressive hints — try each level before moving to the next.

---

## HINT LEVEL 1: General Direction

This module has more moving parts than 1.1 or 1.2. If something fails,
narrow it down:

1. Is Ollama running? → curl http://localhost:11434/api/tags
2. Is Weaviate running? → curl http://localhost:8080/v1/.well-known/ready
3. Does the BrainDoc schema exist? → curl http://localhost:8080/v1/schema
4. Are documents ingested? → curl http://localhost:8080/v1/objects?class=BrainDoc

If all four answer yes, the pipeline should work. If one fails, that's
your bottleneck.

The exercise.bat uses Python for JSON handling — make sure Python is
installed and in your PATH. Type "python --version" to check.

---

## HINT LEVEL 2: Specific Guidance

### "Python is not recognized"
Python isn't in your PATH. Two options:
1. Install Python from https://python.org — check "Add to PATH" during install
2. If Python is installed but not in PATH, find it:
   - Usually at C:\Users\YourName\AppData\Local\Programs\Python\Python3X\
   - Add that folder to your system PATH

### Schema creation fails
If the BrainDoc class already exists from a previous run:

    curl http://localhost:8080/v1/schema

If you see "BrainDoc" in the output, you're fine. Move on.

If you need to delete it and start fresh:

    curl -X DELETE http://localhost:8080/v1/schema/BrainDoc

Then re-run exercise.bat.

### Ingestion says "0 documents stored"
Three possible causes:
1. No .txt files in the knowledge folder — exercise.bat creates them
   automatically, but check the path
2. Ollama embedding call failed — check if Ollama is running
3. Python couldn't parse the JSON — make sure Python is working

### RAG answer is empty or nonsensical
This usually means the context retrieval step failed. Check:
1. Are there BrainDoc objects in Weaviate?

       curl http://localhost:8080/v1/objects?class=BrainDoc

2. Is the GraphQL endpoint working?

       curl -X POST http://localhost:8080/v1/graphql -H "Content-Type: application/json" -d "{\"query\":\"{Get{BrainDoc(limit:1){title content}}}\"}"

3. If those return data, the issue is likely in the prompt template.
   The model might be struggling with the prompt format. This is
   exactly what Module 1.4 (Prompt Engineering) addresses.

### "vector lengths don't match"
Same fix as Module 1.2 — make sure all embeddings come from the same
model (llama3.2:1b). If you mixed models between schema creation and
document ingestion, delete the schema and start fresh.

### Exercise runs slow
The LLM inference step (generating the final answer) takes 5-15 seconds
on most hardware. That's normal for a 1b model on CPU. If it takes
longer than 30 seconds, you might be low on RAM.

Check available memory:

    wmic os get FreePhysicalMemory

If under 2GB free, close some applications.

---

## HINT LEVEL 3: The Answer (but try the above first)

The full manual pipeline without exercise.bat:

    Terminal 1: ollama serve
    Terminal 2: docker start weaviate

    Terminal 3:

    Step 1 — Create knowledge folder and files:
    mkdir knowledge
    echo Angel Cloud is a family-driven AI platform. > knowledge\mission.txt
    echo Faith first. Family always. > knowledge\values.txt

    Step 2 — Create schema:
    curl -X POST http://localhost:8080/v1/schema -H "Content-Type: application/json" -d "{\"class\":\"BrainDoc\",\"description\":\"ShaneBrain RAG knowledge documents\",\"vectorizer\":\"none\",\"properties\":[{\"name\":\"title\",\"dataType\":[\"text\"],\"description\":\"Source filename\"},{\"name\":\"content\",\"dataType\":[\"text\"],\"description\":\"Document text content\"},{\"name\":\"source\",\"dataType\":[\"text\"],\"description\":\"File path\"}]}"

    Step 3 — Ingest (using Python):
    python -c "
    import json, urllib.request, os
    for f in os.listdir('knowledge'):
        if f.endswith('.txt'):
            content = open(os.path.join('knowledge', f)).read().strip()
            # Get embedding
            emb_data = json.dumps({'model':'llama3.2:1b','prompt':content}).encode()
            emb_req = urllib.request.Request('http://localhost:11434/api/embeddings', data=emb_data, headers={'Content-Type':'application/json'})
            emb = json.loads(urllib.request.urlopen(emb_req).read())['embedding']
            # Store in Weaviate
            payload = json.dumps({'class':'BrainDoc','properties':{'title':f,'content':content,'source':f},'vector':emb}).encode()
            store_req = urllib.request.Request('http://localhost:8080/v1/objects', data=payload, headers={'Content-Type':'application/json'})
            urllib.request.urlopen(store_req)
            print(f'Stored: {f}')
    "

    Step 4 — Query:
    python -c "
    import json, urllib.request
    question = 'What is Angel Cloud?'
    # Embed question
    emb_data = json.dumps({'model':'llama3.2:1b','prompt':question}).encode()
    emb = json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/embeddings', data=emb_data, headers={'Content-Type':'application/json'})).read())['embedding']
    # Search
    query = '{Get{BrainDoc(nearVector:{vector:'+json.dumps(emb)+'},limit:2){title content}}}'
    gql = json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:8080/v1/graphql', data=json.dumps({'query':query}).encode(), headers={'Content-Type':'application/json'})).read())
    docs = gql['data']['Get']['BrainDoc']
    context = ' '.join([d['content'] for d in docs])
    # Generate
    prompt = f'Answer using ONLY this context:\n{context}\n\nQuestion: {question}\nAnswer:'
    gen = json.loads(urllib.request.urlopen(urllib.request.Request('http://localhost:11434/api/generate', data=json.dumps({'model':'llama3.2:1b','prompt':prompt,'stream':False}).encode(), headers={'Content-Type':'application/json'})).read())
    print(gen['response'])
    "

    Step 5 — Run verify.bat

If the Python query step returns an answer based on your documents,
your RAG pipeline is working. That's the whole thing.

---

## STILL STUCK?

This is the hardest module in Phase 1. If it's not clicking, that's
normal. Here's the mental model:

    Your documents → numbers (embeddings)
    Your question → numbers (embedding)
    Compare numbers → find closest match
    Feed match + question → LLM → answer

That's RAG. Four steps. Everything else is plumbing.

If exercise.bat isn't working, try the manual Python commands in
Hint Level 3. Sometimes seeing each step separately makes it click.

You're building the same thing that cost companies millions to develop.
Except yours runs on your machine, for free. Keep going.
