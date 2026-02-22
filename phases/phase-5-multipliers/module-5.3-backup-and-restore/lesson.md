# Module 5.3 — Backup and Restore

## WHAT YOU'LL BUILD

Your first real backup-and-restore cycle. You will export your entire knowledge base and personal vault to local JSON files on your own drive. You will verify the exports are complete by checking entry counts against the server. You will add a new entry, re-export, and prove the count increased by exactly one. When you finish, you will have a repeatable backup process that protects everything you built in Phases 1 through 4.

---

## KEY TERMS

- **Export**: Pulling data out of your AI system (Weaviate collections via MCP) and saving it as a plain JSON file on your local drive. The file is yours — no server required to read it.

- **Backup**: A copy of your data stored somewhere separate from the original. If the original breaks, the backup lets you rebuild. Think of it like a fireproof safe — the house can burn down and the documents inside survive.

- **Restore**: Taking a backup file and loading the data back into the system. The proof that a backup works is not that the file exists — it is that you can put the data back.

- **Integrity Check**: Comparing the backup to the source to confirm nothing was lost. Entry counts, file sizes, and content spot-checks all count.

- **Collection Counts**: The number of entries in each Weaviate collection (LegacyKnowledge, PersonalDoc, etc.). The `system_health` tool reports these. They are your baseline.

---

## THE LESSON

### Why Backup Matters

You spent four phases building a brain. Family values. Life stories. A letter to your children. Security logs. Daily notes. All of it lives in Weaviate collections on your hardware.

Hardware fails. Drives die. Power surges happen. A bad Docker update can wipe a volume. If you do not have a backup, everything you built disappears.

A backup is an insurance policy for your brain. Not the kind you pay for and hope you never use — the kind you make yourself and verify with your own hands.

### What Gets Backed Up

Your MCP server manages several collections. The two most important for legacy purposes are:

| Collection | What It Holds | MCP Tool to Export |
|------------|---------------|-------------------|
| LegacyKnowledge | Family values, life lessons, philosophy | `search_knowledge` |
| PersonalDoc | Vault documents — stories, letters, records | `vault_search` |

The `system_health` tool gives you the full picture — every collection and its entry count. That is your starting point for any backup.

### The Backup Process

Here is the pattern. It works the same whether you are backing up one collection or ten:

**1. Get the baseline.** Run `system_health` and write down the collection counts. This is your "before" snapshot.

**2. Export the data.** Use `search_knowledge` and `vault_search` with a broad query to pull all entries. Save the raw JSON response to a file on your local drive.

**3. Count and compare.** Use Python to count the entries in each export file. Compare to the baseline. If the numbers match, the export is complete.

**4. Verify with a test entry.** Add one new entry via `add_knowledge`. Re-run `system_health`. The count should increase by exactly one. This proves the system is tracking changes accurately and your next backup will catch the new data.

**5. Store the backup files.** Copy the JSON files to a second drive, a USB stick, or another folder outside the Docker volume. The backup is only useful if it survives the thing it is protecting you from.

### Where to Store Backups

The worst place to store a backup is on the same drive as the original. That is like keeping your fireproof safe inside the house.

Good backup locations:
- A second hard drive (external USB drive works fine)
- A USB flash drive in a drawer
- A folder on a different partition
- A family member's computer (encrypted first)

The best backup is one you verify regularly and store somewhere physically separate from the original.

### How Often to Back Up

Depends on how often you add to your brain:
- **Weekly** if you journal or add knowledge daily
- **Monthly** if you add content occasionally
- **Before any system update** — always back up before upgrading Docker, Weaviate, or Ollama
- **After any major addition** — if you just added 20 family values, back up immediately

### Restore Is the Real Test

A backup file you have never tested is a hope, not a plan. The exercise will not cover a full restore cycle (that requires clearing and re-importing collections), but it will prove the export contains real, countable data. In a real emergency, you would use `add_knowledge` and `vault_add` to re-import entries from the JSON files one by one — or write a script to loop through them.

The point is: the data is in a format you control. Plain JSON. Readable by any text editor. Not locked inside a proprietary database format. That is the whole advantage of building local.

---

## WHAT YOU PROVED

- Your knowledge base and vault can be exported to local JSON files
- `system_health` gives you accurate collection counts as a baseline
- Exports can be verified by counting entries and comparing to the baseline
- Adding a new entry increases the count by exactly one — the system tracks changes
- Backup files are plain JSON — portable, readable, yours
- A backup stored on the same drive as the original is not a real backup
- The backup process is repeatable and takes minutes, not hours

**Next:** Run `exercise.bat`
