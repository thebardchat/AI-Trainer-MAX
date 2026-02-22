# Module 5.6 — Brain Export

## WHAT YOU'LL BUILD

A structured, portable brain snapshot. Not a raw dump of JSON files like Module 5.3 — this is a complete export bundle with a manifest, entry counts, and an MD5 checksum. One file that contains your knowledge, your vault, and your daily notes, all labeled, inventoried, and verifiable. When you finish, you will have a single `brain-export.json` file that can move your entire brain to a new machine.

---

## KEY TERMS

- **Export Bundle**: A single JSON file that packages multiple collections together with metadata. Instead of three separate backup files, you get one organized package — like a shipping container with a packing list taped to the door.

- **Manifest**: The packing list at the top of your export bundle. It records when the export happened, what system it came from, how many entries are in each section, and a checksum to prove nothing was altered. If the manifest says 12 knowledge entries, the bundle better have exactly 12.

- **Checksum (MD5)**: A digital fingerprint of your data. Python runs the content through a math function and produces a short string of characters. If even one character of the data changes, the checksum changes. This is how you prove the export is intact after copying it to another drive.

- **Portability**: The ability to move your brain from one machine to another. A portable brain is not locked to one hard drive, one Docker install, or one Weaviate instance. The export bundle is plain JSON — any machine with Python can read it.

- **Collection Counts**: The number of entries in each section of your brain. The manifest records these so you can verify nothing was lost during export or transfer.

---

## THE LESSON

### Beyond Raw Backup

Module 5.3 taught you to back up. You pulled data from collections and saved JSON files. That works. But raw backup files are like throwing boxes into a moving truck with no labels — everything is there, but unpacking is chaos.

Brain Export is like packing that truck properly. Every box is labeled. There is an inventory sheet on the clipboard. And there is a seal on the back door so you know nobody opened it in transit.

### The Export Bundle Structure

Your brain export is one JSON file with four sections:

```json
{
  "manifest": {
    "export_timestamp": "2026-02-22T14:30:00",
    "source_system": "YourNameBrain",
    "collections": {
      "knowledge": 15,
      "vault": 8,
      "notes": 23
    },
    "total_entries": 46,
    "checksum": "a1b2c3d4e5f6..."
  },
  "knowledge": [ ... ],
  "vault": [ ... ],
  "notes": [ ... ]
}
```

**manifest** — the packing list. Timestamp tells you when. Source tells you where. Collections tells you how much. Checksum tells you it is unchanged.

**knowledge** — everything from your LegacyKnowledge collection. Family values, life lessons, philosophy.

**vault** — everything from your PersonalDoc collection. Letters, stories, documents.

**notes** — everything from your DailyNote collection. Journal entries, todos, reflections.

### Why the Manifest Matters

Imagine handing a USB drive to your son and saying "your inheritance is on here." He plugs it in five years later. How does he know the data is complete? How does he know nothing was corrupted?

The manifest answers both questions. He checks the entry counts against what is in the file. He runs the checksum and compares. If both match, the data is exactly what you exported. No guessing.

### How the Checksum Works

Python's `hashlib` module (part of the standard library — no pip install) takes any string and produces a fixed-length fingerprint:

```python
import hashlib
data = '{"knowledge": [...], "vault": [...], "notes": [...]}'
checksum = hashlib.md5(data.encode()).hexdigest()
# Result: something like "a3f2b8c1d4e5f6a7b8c9d0e1f2a3b4c5"
```

The checksum covers the knowledge, vault, and notes sections — not the manifest itself. That way you can verify the data independently of the metadata.

### The Export Process

Here is what the exercise walks you through:

1. **Check system health** — confirm services are running and see collection counts
2. **Discover vault categories** — use `vault_list_categories` to see what types of documents exist
3. **Pull knowledge entries** — `search_knowledge` with a broad query
4. **Pull vault entries** — `vault_search` with a broad query
5. **Pull daily notes** — `daily_note_search` with a broad query
6. **Assemble the bundle** — Python combines all three into one JSON structure, calculates the checksum, and writes the manifest
7. **Write the file** — one `brain-export.json` file with everything inside
8. **Verify** — display the manifest summary so you can see counts, checksum, and file size

### Where This Goes Next

This export bundle is the foundation of brain portability. Module 5.7 (Family Mesh) will use it to share brain data between family members. But even without that, the export file is yours. Copy it to a USB drive. Email it to yourself. Store it in a safe. Your brain travels with you.

---

## WHAT YOU PROVED

- Your brain data can be packaged into a single structured file
- A manifest provides an inventory of what the export contains
- MD5 checksums verify data integrity without opening every entry
- The export is plain JSON — portable, readable, not locked to any platform
- Three collections (knowledge, vault, notes) combine into one bundle
- The export process is repeatable and takes minutes
- Your brain is not locked to one machine

**Next:** Run `exercise.bat`
