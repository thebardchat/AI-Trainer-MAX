# Module 1.1 Hints — Your First Local LLM

## Progressive hints — try each level before moving to the next.

---

## HINT LEVEL 1: General Direction

If Ollama won't start, the most common issue is that another program
is already using port 11434. Close any other Ollama instances first.

If the model won't pull, check your internet connection — you need it
this one time to download the model. After that, everything is local.

---

## HINT LEVEL 2: Specific Guidance

### "ollama not recognized"
Ollama isn't in your system PATH. Two fixes:
1. Restart your terminal after installing Ollama
2. Use the full path: C:\Users\YourName\AppData\Local\Programs\Ollama\ollama.exe

### "connection refused" on curl commands
Ollama server isn't running. Open a SEPARATE terminal and run:

    ollama serve

Keep that terminal open. Don't close it.

### Model download stuck or failed
Run it again — Ollama resumes downloads:

    ollama pull llama3.2:1b

If it keeps failing, try:

    ollama pull llama3.2:1b --insecure

(Only use --insecure on your local network. Not on public wifi.)

---

## HINT LEVEL 3: The Answer (but try the above first)

The complete sequence, step by step:

    Terminal 1:
    ollama serve

    Terminal 2:
    ollama pull llama3.2:1b
    ollama run llama3.2:1b
    >>> What is a vector database?
    >>> /bye
    curl http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"What is RAM?\",\"stream\":false}"

If all of that works, run verify.bat. You'll pass.

---

## STILL STUCK?

Check the Ollama docs: https://ollama.com/docs
Or ask ShaneBrain — that's literally what we're building here.
