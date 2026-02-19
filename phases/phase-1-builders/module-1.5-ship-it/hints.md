# Module 1.5 Hints — Ship It

## Progressive hints — try each level before moving to the next.

---

## HINT LEVEL 1: General Direction

This module generates a launcher file for you — exercise.bat writes
my-brain.bat into the output/ folder. If something isn't working:

1. Did exercise.bat run? Check: Does output\my-brain.bat exist?
2. Did my-brain.bat run? The exercise launches it automatically.
3. Did you test the chat? Ask a question, get an answer, type /bye.

The most common issue is running verify.bat BEFORE running exercise.bat
and my-brain.bat. The verify checks whether the launcher was created
AND whether documents were ingested through it. Run them in order:

    exercise.bat → (it runs my-brain.bat for you) → verify.bat

If services aren't running, same drill as every other module:
- Ollama: ollama serve
- Weaviate: docker start weaviate

---

## HINT LEVEL 2: Specific Guidance

### my-brain.bat doesn't exist after running exercise.bat
Check the output folder:

    dir /b "%~dp0output\"

If it's empty, exercise.bat may have failed during generation. Run
it again. If it fails again, check for write permission issues on
the folder.

### my-brain.bat runs but chat doesn't work
The chat requires both Ollama AND Weaviate AND Python. Check all three:

    ollama --version
    python --version
    curl http://localhost:8080/v1/.well-known/ready

If any of those fail, fix that service first.

### "MyBrain class not found" in verify
The MyBrain schema gets created when my-brain.bat runs. If verify
fails this check, run my-brain.bat manually:

    cd output
    my-brain.bat

Ask one question, type /bye, then run verify.bat again.

### Documents aren't being ingested
Check the knowledge folder:

    dir "%~dp0output\knowledge\*.txt"

If no .txt files exist, exercise.bat should create them. If they
exist but aren't in Weaviate:

    curl http://localhost:8080/v1/objects?class=MyBrain&limit=10

If that returns empty, the ingestion step in my-brain.bat failed.
Most likely cause: Python not in PATH. Verify:

    python -c "print('OK')"

### Launcher is slow to start
The ingestion step embeds each document via Ollama. On first run,
this takes 5-15 seconds per document. On subsequent runs, smart
ingestion skips already-loaded documents, so startup is faster.

If it's slow every time, the duplicate detection may not be working.
The simple title-match check depends on Weaviate's text search. If
your document titles have special characters, they might not match.
Stick to simple filenames: mission.txt, values.txt, etc.

### verify.bat says FAIL on the RAG query
The end-to-end check runs a real RAG pipeline query. It needs:
1. MyBrain schema exists
2. At least one document ingested
3. Ollama can embed + generate
4. Weaviate can search

If checks 4-6 pass but check 7 fails, try running the query manually:

    python -c "
    import json, urllib.request
    q = 'What is the mission?'
    emb = json.loads(urllib.request.urlopen(
        urllib.request.Request('http://localhost:11434/api/embeddings',
        data=json.dumps({'model':'llama3.2:1b','prompt':q}).encode(),
        headers={'Content-Type':'application/json'})
    ).read()).get('embedding',[])
    docs = json.loads(urllib.request.urlopen(
        urllib.request.Request('http://localhost:8080/v1/graphql',
        data=json.dumps({'query':'{Get{MyBrain(nearVector:{vector:'+json.dumps(emb)+'},limit:2){title content}}}'}).encode(),
        headers={'Content-Type':'application/json'})
    ).read()).get('data',{}).get('Get',{}).get('MyBrain',[])
    print('Documents found:', len(docs))
    for d in docs:
        print(' -', d.get('title',''), ':', d.get('content','')[:80])
    "

If that shows documents, the pipeline works and verify should pass.
If it shows 0 documents, ingestion didn't complete — re-run my-brain.bat.

---

## HINT LEVEL 3: The Full Sequence

If everything seems broken, start clean:

    Step 1 — Start services:
    Terminal 1: ollama serve
    Terminal 2: docker start weaviate

    Step 2 — Verify services:
    curl http://localhost:11434/api/tags
    curl http://localhost:8080/v1/.well-known/ready

    Step 3 — Run the exercise:
    cd [module-1.5-ship-it folder]
    exercise.bat

    Step 4 — When the launcher opens, ask:
    "What is the mission?"
    (You should get an answer about Angel Cloud)
    Type: /bye

    Step 5 — Back in exercise, press any key to finish

    Step 6 — Run verify:
    verify.bat

If all 7 checks pass, you completed Phase 1. You're a Builder.

### If you want to start the schema completely fresh:

    curl -X DELETE http://localhost:8080/v1/schema/MyBrain
    (then re-run my-brain.bat)

---

## WHAT TO DO AFTER PHASE 1

You now have a working local AI system. Here's how to make it yours:

1. Add YOUR documents to the knowledge folder:
   - Work notes, journal entries, business procedures
   - Family history, important letters, values you live by
   - Technical docs for your trade

2. Customize the system prompt in my-brain.bat:
   - Change "My Brain" to your name
   - Add personality traits, communication style
   - Define the topics it should know about

3. Upgrade the model (if your RAM allows):
   - ollama pull llama3.2:3b (needs ~3GB extra RAM)
   - Change MODEL=llama3.2:3b in the launcher
   - Better reasoning, better guardrails, same pipeline

4. Look at start-shanebrain.bat to see how the production version
   handles everything you just built — plus session history,
   multi-model support, and advanced chunking.

You built the foundation. Now build on it.
