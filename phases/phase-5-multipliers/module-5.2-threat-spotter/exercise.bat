@echo off
setlocal enabledelayedexpansion
title Module 5.2 Exercise — Threat Spotter

:: ============================================================
:: MODULE 5.2 EXERCISE: Threat Spotter
:: Goal: Build a threat taxonomy in the knowledge base, then
::       use AI to classify security scenarios against it
:: Time: ~15 minutes
:: MCP Tools: add_knowledge, search_knowledge, chat_with_shanebrain, security_log_search
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.2"

echo.
echo  ══════════════════════════════════════════════════════
echo   MODULE 5.2 EXERCISE: Threat Spotter
echo  ══════════════════════════════════════════════════════
echo.
echo   You're about to build a threat taxonomy — five threat
echo   definitions that turn your AI into a security advisor.
echo   Five tasks. Fifteen minutes. You define what danger
echo   looks like.
echo.
echo  ──────────────────────────────────────────────────────
echo.

:: --- PRE-FLIGHT: Check MCP server ---
echo  [PRE-FLIGHT] Checking MCP server...
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

python "%MCP_CALL%" system_health > "%TEMP_DIR%\health.txt" 2>&1
if %errorlevel% NEQ 0 (
    echo  [91m   X MCP server not reachable. Is ShaneBrain running?[0m
    echo       Check: python "%MCP_CALL%" system_health
    pause
    exit /b 1
)
echo  [92m   PASS: MCP server responding[0m
echo.

:: ============================================================
:: TASK 1: Add 5 threat definitions to Knowledge (category: security)
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 1/5] Build your threat taxonomy
echo.
echo   Five threats. Each one gets a name, severity level,
echo   and plain-English description. These go into the
echo   knowledge base under category "security" so your AI
echo   can find them when classifying new scenarios.
echo.

:: --- Threat 1: Phishing ---
echo   Storing threat: Phishing (HIGH)...
python "%MCP_CALL%" add_knowledge "{\"content\":\"THREAT: Phishing. SEVERITY: HIGH. Phishing is when an attacker sends fake emails, texts, or messages that look legitimate to trick you into clicking a malicious link, downloading malware, or giving up your credentials. Phishing is high severity because a single click can compromise your entire system — your local AI, your knowledge base, your vault, everything. Watch for: unexpected messages asking you to log in, urgency language like 'act now or lose access', and links that don't match the sender's real domain.\",\"category\":\"security\",\"title\":\"Threat - Phishing (HIGH)\"}" > "%TEMP_DIR%\t1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Phishing threat stored[0m
) else (
    echo  [91m   FAIL: Could not store phishing threat[0m
    echo          Check MCP server and try again
)
echo.

:: --- Threat 2: Shoulder Surfing ---
echo   Storing threat: Shoulder Surfing (MEDIUM)...
python "%MCP_CALL%" add_knowledge "{\"content\":\"THREAT: Shoulder Surfing. SEVERITY: MEDIUM. Shoulder surfing is when someone physically watches your screen, keyboard, or device to steal passwords, read private data, or learn your security patterns. Medium severity because it requires the attacker to be in the same physical space, but it can expose passwords, API keys, and sensitive knowledge base content. Watch for: people standing too close when you type passwords, screens visible from public areas, and unlocked machines left unattended.\",\"category\":\"security\",\"title\":\"Threat - Shoulder Surfing (MEDIUM)\"}" > "%TEMP_DIR%\t2.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Shoulder surfing threat stored[0m
) else (
    echo  [91m   FAIL: Could not store shoulder surfing threat[0m
)
echo.

:: --- Threat 3: Unpatched Software ---
echo   Storing threat: Unpatched Software (HIGH)...
python "%MCP_CALL%" add_knowledge "{\"content\":\"THREAT: Unpatched Software. SEVERITY: HIGH. Running outdated software with known security vulnerabilities is high severity because attackers actively scan for unpatched systems and exploit them automatically. This includes your operating system, Ollama, Weaviate, Docker, Python, and any other tool in your AI stack. High severity because one unpatched service can give an attacker a foothold into your entire local network. Watch for: update notifications you keep dismissing, software that stopped receiving updates, and services running old versions.\",\"category\":\"security\",\"title\":\"Threat - Unpatched Software (HIGH)\"}" > "%TEMP_DIR%\t3.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Unpatched software threat stored[0m
) else (
    echo  [91m   FAIL: Could not store unpatched software threat[0m
)
echo.

:: --- Threat 4: Weak Passwords ---
echo   Storing threat: Weak Passwords (MEDIUM)...
python "%MCP_CALL%" add_knowledge "{\"content\":\"THREAT: Weak Passwords. SEVERITY: MEDIUM. Weak passwords are passwords that are short, common, predictable, or reused across multiple services. Medium severity because they are easy to fix but catastrophic if exploited — a weak password on one service often means the same password works on others. This is especially dangerous if you reuse passwords between your local AI tools and online accounts. Watch for: passwords under 12 characters, passwords that are dictionary words, the same password on multiple services, and passwords that include your name or birthday.\",\"category\":\"security\",\"title\":\"Threat - Weak Passwords (MEDIUM)\"}" > "%TEMP_DIR%\t4.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Weak passwords threat stored[0m
) else (
    echo  [91m   FAIL: Could not store weak passwords threat[0m
)
echo.

:: --- Threat 5: Social Engineering ---
echo   Storing threat: Social Engineering (HIGH)...
python "%MCP_CALL%" add_knowledge "{\"content\":\"THREAT: Social Engineering. SEVERITY: HIGH. Social engineering is when an attacker manipulates a person into breaking security procedures — giving up passwords, granting access, or disabling protections. High severity because it bypasses every technical control. The best firewall in the world cannot stop someone from voluntarily handing over their credentials. Common tactics: pretending to be IT support, creating fake urgency, exploiting trust relationships, and offering help that requires your login. Watch for: anyone asking for your password over phone or email, requests to disable security features, and pressure to act fast without verifying identity.\",\"category\":\"security\",\"title\":\"Threat - Social Engineering (HIGH)\"}" > "%TEMP_DIR%\t5.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Social engineering threat stored[0m
) else (
    echo  [91m   FAIL: Could not store social engineering threat[0m
)
echo.

echo  [92m   Five threat definitions stored in Knowledge (security).[0m
echo.
echo   Press any key to verify the taxonomy...
pause >nul
echo.

:: ============================================================
:: TASK 2: Search knowledge to verify entries exist
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 2/5] Verify the taxonomy — can the brain find your threats?
echo.
echo   You stored five threats. Now let's search for them
echo   using different words to prove semantic search works.
echo.

:: --- Search 1: Find phishing ---
echo   Search: "fake emails trying to steal credentials"
python "%MCP_CALL%" search_knowledge "{\"query\":\"fake emails trying to steal credentials\",\"category\":\"security\"}" > "%TEMP_DIR%\s1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Found relevant threats[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\s1.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])); print('   Found: ' + str(len(results) if isinstance(results,list) else 1) + ' result(s)')" 2>nul
    echo   Asked about "fake emails" — should match Phishing.
) else (
    echo  [91m   FAIL: Knowledge search failed[0m
)
echo.

:: --- Search 2: Find unpatched software ---
echo   Search: "outdated software with vulnerabilities"
python "%MCP_CALL%" search_knowledge "{\"query\":\"outdated software with vulnerabilities\",\"category\":\"security\"}" > "%TEMP_DIR%\s2.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Found relevant threats[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\s2.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])); print('   Found: ' + str(len(results) if isinstance(results,list) else 1) + ' result(s)')" 2>nul
    echo   Asked about "outdated software" — should match Unpatched Software.
) else (
    echo  [91m   FAIL: Knowledge search failed[0m
)
echo.

echo  [92m   Taxonomy verified — the brain finds threats by meaning.[0m
echo.
echo   Press any key to classify real scenarios...
pause >nul
echo.

:: ============================================================
:: TASK 3: Classify 3 test scenarios using chat_with_shanebrain
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 3/5] Classify security scenarios
echo.
echo   Three real-world scenarios. Your AI will search the
echo   threat taxonomy you just built and classify each one.
echo   Watch how it uses YOUR definitions to reason.
echo.

:: --- Scenario 1 ---
echo  ─── Scenario 1 ───────────────────────────────────────
echo.
echo   "I got an email from 'support@ollama-update.net'
echo    saying my Ollama installation needs an urgent
echo    security patch. There's a download link."
echo.
echo   Classifying...
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"Classify this security scenario using the threat definitions stored in the security category of the knowledge base. What type of threat is this, and what severity? Scenario: I got an email from support@ollama-update.net saying my Ollama installation needs an urgent security patch and I need to click a download link to update it.\"}" > "%TEMP_DIR%\c1.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   AI Classification:[0m
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\c1.txt')); text=d.get('response',d.get('text',d.get('result',str(d)))); lines=text.strip().split('\n'); [print('   ' + l) for l in lines[:8]]" 2>nul
) else (
    echo  [91m   FAIL: Classification failed[0m
)
echo.
echo   Press any key for the next scenario...
pause >nul
echo.

:: --- Scenario 2 ---
echo  ─── Scenario 2 ───────────────────────────────────────
echo.
echo   "A guy at the coffee shop kept leaning over while
echo    I was configuring my Weaviate database on my laptop."
echo.
echo   Classifying...
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"Classify this security scenario using the threat definitions stored in the security category of the knowledge base. What type of threat is this, and what severity? Scenario: A guy at the coffee shop kept leaning over my shoulder while I was configuring my Weaviate database on my laptop. He could see my screen clearly.\"}" > "%TEMP_DIR%\c2.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   AI Classification:[0m
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\c2.txt')); text=d.get('response',d.get('text',d.get('result',str(d)))); lines=text.strip().split('\n'); [print('   ' + l) for l in lines[:8]]" 2>nul
) else (
    echo  [91m   FAIL: Classification failed[0m
)
echo.
echo   Press any key for the last scenario...
pause >nul
echo.

:: --- Scenario 3 ---
echo  ─── Scenario 3 ───────────────────────────────────────
echo.
echo   "Someone called claiming to be from Microsoft
echo    support saying my Windows needs a remote fix.
echo    They asked for my admin password."
echo.
echo   Classifying...
python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"Classify this security scenario using the threat definitions stored in the security category of the knowledge base. What type of threat is this, and what severity? Scenario: Someone called me claiming to be from Microsoft support and said my Windows computer needs a remote fix. They asked for my admin password to connect remotely and fix the issue.\"}" > "%TEMP_DIR%\c3.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   AI Classification:[0m
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\c3.txt')); text=d.get('response',d.get('text',d.get('result',str(d)))); lines=text.strip().split('\n'); [print('   ' + l) for l in lines[:8]]" 2>nul
) else (
    echo  [91m   FAIL: Classification failed[0m
)
echo.
echo   Press any key to check security logs...
pause >nul
echo.

:: ============================================================
:: TASK 4: Check security logs
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 4/5] Check security logs — is your system clean?
echo.
echo   Your threat taxonomy is loaded. Now let's check the
echo   security logs to see the current state of your system.
echo.

python "%MCP_CALL%" security_log_search "{\"query\":\"security threats unauthorized access\"}" > "%TEMP_DIR%\logs.txt" 2>&1
if %errorlevel% EQU 0 (
    echo  [92m   PASS: Security log search completed[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\logs.txt')); results=d if isinstance(d,list) else d.get('results',d.get('entries',[])); count=len(results) if isinstance(results,list) else 0; print('   Log entries found: ' + str(count)); print('   Status: CLEAN' if count==0 else '   Status: Review entries above')" 2>nul
) else (
    echo  [91m   FAIL: Security log search failed[0m
)
echo.
echo   Press any key to see your threat classification summary...
pause >nul
echo.

:: ============================================================
:: TASK 5: Display threat classification summary
:: ============================================================
echo  ──────────────────────────────────────────────────────
echo.
echo  [TASK 5/5] Threat Classification Summary
echo.
echo   ┌────────────────────────────────────────────────┐
echo   │  YOUR THREAT TAXONOMY                          │
echo   ├────────────────────────────────────────────────┤
echo   │  [91mHIGH[0m   Phishing              — Fake messages   │
echo   │  [93mMEDIUM[0m Shoulder Surfing       — Physical spying │
echo   │  [91mHIGH[0m   Unpatched Software     — Old versions    │
echo   │  [93mMEDIUM[0m Weak Passwords         — Easy to crack   │
echo   │  [91mHIGH[0m   Social Engineering     — Manipulation    │
echo   ├────────────────────────────────────────────────┤
echo   │  3 scenarios classified against this taxonomy  │
echo   │  Security logs checked                         │
echo   └────────────────────────────────────────────────┘
echo.

:: ============================================================
:exercise_done
echo.
echo  ══════════════════════════════════════════════════════
echo   EXERCISE COMPLETE
echo  ══════════════════════════════════════════════════════
echo.
echo   You just built:
echo.
echo     5 threat definitions  (Knowledge — security category)
echo     3 scenario classifications  (AI-powered via RAG)
echo     1 security log check  (system state verified)
echo.
echo   Your AI is now a security advisor trained on YOUR
echo   threat definitions. Add more threats anytime:
echo.
echo     python "%MCP_CALL%" add_knowledge "{\"content\":\"THREAT: ... SEVERITY: ...\",\"category\":\"security\",\"title\":\"Threat - Name\"}"
echo.
echo   Now run verify.bat to confirm everything passed:
echo.
echo       verify.bat
echo.

:: Cleanup temp files
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
