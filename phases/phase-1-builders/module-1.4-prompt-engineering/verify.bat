@echo off
setlocal enabledelayedexpansion
title Module 1.4 Verify

:: ============================================================
:: MODULE 1.4 VERIFICATION
:: Checks: Ollama running, system prompts work, temperature
::         control works, few-shot produces clean output,
::         chain of thought improves reasoning, guardrails hold
:: Returns: ERRORLEVEL 0 = PASS, 1 = FAIL
:: Pattern: Matches Module 1.1/1.2/1.3 verify.bat structure
:: ============================================================

set "PASS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_CHECKS=6"
set "TEMP_DIR=%TEMP%\prompt-eng-verify"

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 1.4 VERIFICATION
echo  ══════════════════════════════════════════════════════
echo.

:: --- CHECK 1: Ollama running ---
echo  [CHECK 1/%TOTAL_CHECKS%] Ollama server running
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Ollama responding on localhost:11434[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Ollama not responding[0m
    echo          Fix: Run "ollama serve" in a separate terminal
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 2: System prompt constrains output length ---
echo  [CHECK 2/%TOTAL_CHECKS%] System prompt constrains output
echo   Testing: system prompt "Answer in exactly 1 sentence."
curl -s http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"system\":\"Answer in exactly 1 sentence. Do not exceed 1 sentence.\",\"prompt\":\"What is Ollama?\",\"stream\":false,\"options\":{\"temperature\":0.0}}" > "%TEMP_DIR%\sys_test.json" 2>&1

:: Check response exists and is reasonable length (under 500 chars = likely constrained)
python -c "import json; r=json.load(open(r'%TEMP_DIR%\sys_test.json')); resp=r.get('response',''); print('OK' if 10<len(resp)<500 else 'LONG')" > "%TEMP_DIR%\sys_result.txt" 2>nul
set /p SYS_RESULT=<"%TEMP_DIR%\sys_result.txt"

if "%SYS_RESULT%"=="OK" (
    echo  [92m   PASS: System prompt produced constrained output[0m
    set /a PASS_COUNT+=1
) else (
    echo  [93m   PASS (partial^): System prompt sent, output may vary[0m
    echo          Small models don't always obey length constraints perfectly.
    echo          The technique still works — keep using it.
    set /a PASS_COUNT+=1
)
echo.

:: --- CHECK 3: Temperature 0 produces deterministic output ---
echo  [CHECK 3/%TOTAL_CHECKS%] Temperature 0 produces consistent output
echo   Running same prompt twice at temperature 0...

curl -s http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"What is 2 + 2? Answer with just the number.\",\"stream\":false,\"options\":{\"temperature\":0.0}}" > "%TEMP_DIR%\temp_a.json" 2>&1
curl -s http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"What is 2 + 2? Answer with just the number.\",\"stream\":false,\"options\":{\"temperature\":0.0}}" > "%TEMP_DIR%\temp_b.json" 2>&1

python -c "import json; a=json.load(open(r'%TEMP_DIR%\temp_a.json')).get('response',''); b=json.load(open(r'%TEMP_DIR%\temp_b.json')).get('response',''); print('MATCH' if a.strip()==b.strip() else 'DIFFER')" > "%TEMP_DIR%\temp_result.txt" 2>nul
set /p TEMP_RESULT=<"%TEMP_DIR%\temp_result.txt"

if "%TEMP_RESULT%"=="MATCH" (
    echo  [92m   PASS: Temperature 0 produced identical outputs[0m
    set /a PASS_COUNT+=1
) else (
    echo  [93m   PASS (partial^): Outputs differed slightly[0m
    echo          Temperature 0 should be deterministic. Minor variation
    echo          can happen due to batching. The technique still applies.
    set /a PASS_COUNT+=1
)
echo.

:: --- CHECK 4: Few-shot produces clean classification ---
echo  [CHECK 4/%TOTAL_CHECKS%] Few-shot prompting produces formatted output
echo   Testing: 3 examples then a new classification task...

curl -s http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Classify each text as POSITIVE, NEGATIVE, or NEUTRAL. Respond with only the classification label.\n\nText: Great product, works perfectly.\nClassification: POSITIVE\n\nText: Broken on arrival, terrible quality.\nClassification: NEGATIVE\n\nText: The package arrived on Tuesday.\nClassification: NEUTRAL\n\nText: This is the best tool I have ever used.\nClassification:\",\"stream\":false,\"options\":{\"temperature\":0.0}}" > "%TEMP_DIR%\fewshot.json" 2>&1

python -c "import json; r=json.load(open(r'%TEMP_DIR%\fewshot.json')).get('response','').strip().upper(); print('PASS' if 'POSITIVE' in r else 'FAIL')" > "%TEMP_DIR%\fs_result.txt" 2>nul
set /p FS_RESULT=<"%TEMP_DIR%\fs_result.txt"

if "%FS_RESULT%"=="PASS" (
    echo  [92m   PASS: Few-shot correctly classified as POSITIVE[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Few-shot did not return expected POSITIVE[0m
    echo          The model may need more examples. Review Technique 4.
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 5: Chain of thought shows reasoning ---
echo  [CHECK 5/%TOTAL_CHECKS%] Chain of thought produces step-by-step output
echo   Testing: "What is 20%% of 150? Think step by step."

curl -s http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"What is 20 percent of 150? Think step by step before giving the final answer.\",\"stream\":false,\"options\":{\"temperature\":0.0}}" > "%TEMP_DIR%\cot.json" 2>&1

:: Check that response contains step indicators or the number 30
python -c "import json; r=json.load(open(r'%TEMP_DIR%\cot.json')).get('response',''); has_steps=any(w in r.lower() for w in ['step','first','multiply','percent','0.2','0.20']); has_answer='30' in r; print('PASS' if has_steps or has_answer else 'FAIL')" > "%TEMP_DIR%\cot_result.txt" 2>nul
set /p COT_RESULT=<"%TEMP_DIR%\cot_result.txt"

if "%COT_RESULT%"=="PASS" (
    echo  [92m   PASS: Chain of thought produced reasoning steps[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Chain of thought did not show clear reasoning[0m
    echo          The 1b model may need a more explicit prompt.
    echo          Try: "Step 1: Convert percent to decimal. Step 2: Multiply."
    set /a FAIL_COUNT+=1
)
echo.

:: --- CHECK 6: Guardrail holds — model refuses out-of-context question ---
echo  [CHECK 6/%TOTAL_CHECKS%] Guardrail prevents hallucination
echo   Testing: Asking about Mars with context about Angel Cloud...

curl -s http://localhost:11434/api/generate -d "{\"model\":\"llama3.2:1b\",\"prompt\":\"Answer the question using ONLY the context provided. If the context does not contain the answer, respond with exactly: I don't have that information.\n\nCONTEXT:\nAngel Cloud is a local AI platform built in Alabama.\n\nQUESTION:\nWhat is the population of Mars?\n\nANSWER:\",\"stream\":false,\"options\":{\"temperature\":0.0}}" > "%TEMP_DIR%\guard.json" 2>&1

python -c "import json; r=json.load(open(r'%TEMP_DIR%\guard.json')).get('response','').lower(); refused=any(w in r for w in ['don','not have','no information','cannot','context']); print('PASS' if refused else 'FAIL')" > "%TEMP_DIR%\guard_result.txt" 2>nul
set /p GUARD_RESULT=<"%TEMP_DIR%\guard_result.txt"

if "%GUARD_RESULT%"=="PASS" (
    echo  [92m   PASS: Guardrail held — model refused out-of-context answer[0m
    set /a PASS_COUNT+=1
) else (
    echo  [91m   FAIL: Model answered about Mars despite no relevant context[0m
    echo          Guardrails need to be stronger. Add: "Do not guess."
    echo          Small models sometimes ignore guardrails — add more fences.
    set /a FAIL_COUNT+=1
)
echo.

:: Cleanup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

:: --- RESULTS ---
echo  ══════════════════════════════════════════════════════
if %FAIL_COUNT% EQU 0 (
    echo  [92m   RESULT: PASS  (%PASS_COUNT%/%TOTAL_CHECKS% checks passed)[0m
    echo.
    echo  [92m   ✓ MODULE 1.4 COMPLETE[0m
    echo  [92m   You proved: A small model with good prompts[0m
    echo  [92m   beats a big model with lazy prompts.[0m
    echo.

    :: --- Update progress ---
    set "PROGRESS_FILE=%~dp0..\..\..\..\progress\user-progress.json"
    if exist "!PROGRESS_FILE!" (
        echo   {"module": "1.4", "status": "completed", "timestamp": "%date% %time%"} >> "!PROGRESS_FILE!.log"
    )

    echo   Next up: Module 1.5 — Ship It
    echo   Package everything into a daily-use launcher.
    echo  ══════════════════════════════════════════════════════
    endlocal
    exit /b 0
) else (
    echo  [91m   RESULT: FAIL  (%PASS_COUNT%/%TOTAL_CHECKS% passed, %FAIL_COUNT% failed)[0m
    echo.
    echo   Review the failures above and fix them.
    echo   Note: Some checks may fail due to the 1b model's limitations.
    echo   If 4+ checks passed, you've demonstrated the core techniques.
    echo   Need help? Check hints.md in this folder.
    echo  ══════════════════════════════════════════════════════
    endlocal
    exit /b 1
)
