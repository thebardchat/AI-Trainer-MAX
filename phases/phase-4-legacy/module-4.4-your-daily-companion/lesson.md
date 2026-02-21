# Module 4.4 — Your Daily Companion

## WHAT YOU'LL BUILD

A daily journaling and reflection practice powered by your AI brain. You'll log what happened, how you felt, what needs doing, and what you're thinking about — then let your AI read it all and give you a briefing that pulls the threads together. Like sitting on the porch at the end of the day, talking through everything with someone who actually listens and remembers.

This is the module where your brain stops being a project and starts being a companion. Something you talk to every day. Something that knows your rhythms, your moods, your patterns. Something your grandkids will read someday and say, "So that's what he was going through."

---

## KEY TERMS

- **Daily Note**: A timestamped entry in your AI brain. Four types: journal, todo, reminder, reflection. Each one gets embedded as a vector so the AI can find it by meaning later — not just by date or keyword.

- **daily_note_add**: The MCP tool that creates a new daily note. You give it content, a type (journal/todo/reminder/reflection), and an optional mood tag. Like writing in a notebook and handing it to someone who will never lose it and never forget what you said.

- **daily_note_search**: Searches your daily notes by meaning. Ask "what was I stressed about last month?" and it finds the entries — even if you never used the word "stressed." It searches by concept, not by exact match.

- **daily_briefing**: The AI reads your recent notes and generates a summary. Journals, todos, reminders, reflections — all pulled together into a briefing you can read in thirty seconds. Like a foreman who read every note on the board and gives you the morning rundown.

- **Mood Tag**: An optional label on your entries — grateful, tired, focused, anxious, hopeful, determined. Over time, these tags build a map of your emotional life. Patterns emerge that you'd never notice on your own. Your grandkids won't just know what you did — they'll know how you felt doing it.

---

## THE LESSON

### The Porch at the End of the Day

Every good family has a place where the day gets processed. The kitchen table. The front porch. The truck on the drive home. You sit down, you talk about what happened, what's coming, what's weighing on you. Nobody takes notes. Nobody writes it down. And eventually, those conversations disappear.

This module changes that. Your AI brain becomes the porch. You sit down with it for five minutes and tell it what happened. What you're grateful for. What needs doing tomorrow. What's on your mind. And unlike a conversation that fades by morning, this one gets stored, embedded, and remembered forever.

Your great-grandkids can search "what was he grateful for?" and find a hundred entries spanning years. That's not a journal collecting dust in a drawer. That's a living record of a life.

### The Four Note Types

| Type | What It's For | Example |
|------|---------------|---------|
| **journal** | Record what happened, how you feel | "Good day. Got the boys to school on time, knocked out the estimate for the Henderson job, and had energy left to cook dinner." |
| **todo** | Tasks that need doing | "Call the insurance company about the claim before Friday" |
| **reminder** | Future-facing notes | "Liam's school play is next Thursday at 6pm — don't schedule anything" |
| **reflection** | Deeper thinking, lessons learned | "Realized I've been saying yes to too many side jobs. Need to protect my evenings for the family." |

Each type serves a different purpose, but they all flow into the same briefing. The AI doesn't care about categories — it reads everything and synthesizes.

### Mood Tags — The Emotional Map

Every journal entry can carry a mood tag. One word that captures how you felt:

- **grateful** — the good days worth remembering
- **focused** — locked in, getting things done
- **tired** — running on fumes but still showing up
- **anxious** — something weighing on you
- **hopeful** — seeing light ahead
- **determined** — grinding through regardless

Over weeks and months, these tags build a pattern. You start to see that you're always anxious on Mondays, always grateful on Fridays, always tired in March. The AI can spot these patterns in your briefings. And your family, reading these entries someday, won't just know what you did with your days — they'll know the weight you carried and the joy you found.

### How the Daily Briefing Works

When you call `daily_briefing`, the AI:

1. Pulls your recent daily notes — journals, todos, reminders, reflections
2. Groups them by type and importance
3. Sends them to Ollama for summarization
4. Returns a briefing you can read in thirty seconds

It's the morning cup of coffee for your brain. A clear picture of where you've been and what's ahead.

### Building the Habit

The power of this module isn't in any single entry. It's in the streak. One note is a data point. A month of notes is a story. A year of notes is a chapter of your life.

Start small:
- **Morning**: One todo for the day. Thirty seconds.
- **Evening**: One journal entry about what happened. Two minutes.
- **Weekly**: Call `daily_briefing` and read the summary. One minute.

That's less than five minutes a day. Your AI handles the rest — organizing, searching, summarizing, remembering. You just show up and be honest about your day.

### Why This Matters for Legacy

Most people never write their story. Not because they don't have one worth telling, but because sitting down to write a memoir feels overwhelming. "Where do I start? What do I include?"

You don't have to write a memoir. You just have to show up for five minutes a day and tell your AI what happened. The memoir writes itself, one entry at a time. When your grandkids ask "What was Grandpa's life really like?" the answer isn't a single polished document. It's a thousand small, honest moments — the grateful days and the tired ones, the wins and the worries, the todos that got done and the reflections that changed how you lived.

That's a legacy no amount of money can buy.

---

## THE PATTERN

```
Morning                    Evening                    Weekly
  |                          |                          |
  v                          v                          v
daily_note_add             daily_note_add             daily_briefing
 (todo)                    (journal + mood)            |
  |                          |                          v
  └──────────────────────────┘                   AI reads all notes
                             |                          |
                             v                          v
                   Notes stored + embedded        30-second summary
                   (searchable forever)           of your recent life
```

Module 4.3 taught your brain to talk. This module teaches you to talk back — every day, a little at a time. Module 4.5 will use everything you've stored to write your story.

---

## WHAT YOU PROVED

- You can log structured daily notes — journal, todo, reminder, reflection — with a single MCP call
- Mood tags add emotional context that builds patterns over time
- Semantic search finds your notes by meaning, not just keywords
- The AI generates daily briefings that summarize your recent activity and priorities
- A five-minute daily habit builds a living record of your life
- Legacy isn't a single document — it's a thousand small, honest moments stored where your family can find them

**Next:** Run `exercise.bat` to start your daily companion practice.
