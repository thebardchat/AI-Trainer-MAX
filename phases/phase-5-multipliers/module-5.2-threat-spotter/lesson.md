# Module 5.2 — Threat Spotter

## WHAT YOU'LL BUILD

A threat classification system powered by YOUR definitions. You'll feed five common security threats into the knowledge base, each with severity levels and descriptions written in plain English. Then you'll point the AI at new scenarios and watch it classify them using the taxonomy you built.

This is the first time your knowledge base becomes a security advisor. Not a generic one from some vendor's website — one trained on the threats YOU defined, at the severity levels YOU assigned, for the environment YOU operate in.

---

## KEY TERMS

- **Threat Taxonomy**: A structured list of threat types, organized by category and severity. Think of it like a field guide for danger — when something suspicious happens, you flip to the right page and know exactly what you're dealing with.

- **Severity Level**: How bad is it? HIGH means act now or lose something. MEDIUM means fix it soon or it gets worse. LOW means watch it and address it when you can. Every threat in your taxonomy gets a severity rating.

- **Threat Classification**: The act of taking a real scenario — "someone called asking for my password" — and matching it to a known threat type. Your AI does this by searching your taxonomy and reasoning about the match.

- **RAG Classification**: Using Retrieval-Augmented Generation to classify threats. The AI searches your knowledge base for relevant threat definitions, then uses those definitions as context to analyze a new scenario. It doesn't guess from general training — it reasons from YOUR definitions.

- **Security Knowledge Category**: Entries stored with category "security" in the knowledge base. This keeps your threat definitions separate from family values or life lessons, making them easy to find and maintain.

---

## THE LESSON

### Why build your own threat taxonomy?

Generic security tools flag everything the same way. They don't know that your setup runs on local hardware with no cloud exposure. They don't know that your biggest risk is someone in the same room, not a hacker in another country. They don't know what matters to YOU.

When you build your own threat taxonomy, you're teaching the AI to think about security the way you do. A phishing email aimed at stealing your Angel Cloud credentials is HIGH severity. A generic spam message is LOW. Only you know the difference — and now your AI will too.

### The five threats you'll define

The exercise loads five threat types that cover the most common attacks against local AI setups:

**1. Phishing (HIGH)** — Fake emails or messages designed to trick you into giving up credentials or clicking malicious links. High severity because one click can compromise everything.

**2. Shoulder Surfing (MEDIUM)** — Someone physically watching your screen or keyboard. Medium severity because it requires physical proximity, but it can expose passwords and sensitive data.

**3. Unpatched Software (HIGH)** — Running outdated software with known vulnerabilities. High severity because attackers specifically scan for unpatched systems. This is the reason 800 million Windows users are at risk.

**4. Weak Passwords (MEDIUM)** — Passwords that are short, common, or reused across services. Medium severity because they're easy to fix but catastrophic if exploited.

**5. Social Engineering (HIGH)** — Manipulating people into breaking security procedures. High severity because it bypasses every technical control. The best firewall in the world can't stop someone from voluntarily handing over access.

### How classification works

Once those five threats are in your knowledge base, the AI can classify new scenarios. Here's the flow:

```
NEW SCENARIO          SEARCH             MATCH            CLASSIFY
"Got a call from     -->  Find threat   -->  Matches      -->  "Social
 IT asking for            definitions       social             Engineering,
 my password"             in knowledge      engineering        HIGH severity"
```

You describe what happened. The AI searches your threat taxonomy for the closest match. It pulls the relevant definitions as context. Then it reasons about the scenario using YOUR definitions, not generic ones.

### Severity is a spectrum, not a box

Some scenarios match multiple threats. An email (phishing) that includes a fake login page (weak passwords) and pretends to be from your IT department (social engineering) touches three categories. Your AI will surface all relevant matches and help you understand the compound risk.

The goal isn't perfect automated classification — it's having a knowledgeable advisor that speaks your language and knows your priorities.

### Security logs confirm the picture

After classifying threats, you'll check the security logs to see your system's current state. Clean logs plus a loaded taxonomy means you're watching and ready. That's the defender's advantage — you defined what to look for before it shows up.

---

## THE PATTERN

```
DEFINE         -->  STORE           -->  CLASSIFY        -->  VERIFY
(write threat      (add_knowledge      (chat with AI       (check logs,
 descriptions       category:           about new           confirm
 with severity)     security)           scenarios)          system clean)
```

This is the threat-spotter loop. Define what danger looks like, store it, then use the AI to recognize it in the wild. Every threat you define makes the system smarter. Every scenario you classify builds pattern recognition.

---

## WHAT YOU PROVED

- You can build a threat taxonomy in the knowledge base using the "security" category
- Severity levels (HIGH/MEDIUM/LOW) give each threat a priority ranking
- RAG-powered classification matches new scenarios against your definitions
- The AI reasons from YOUR threat descriptions, not generic training data
- Security logs show the current state of your system
- You are the one defining what danger looks like — that makes you the multiplier

**Next:** Run `exercise.bat`
