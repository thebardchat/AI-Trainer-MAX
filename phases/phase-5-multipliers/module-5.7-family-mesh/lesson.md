# Module 5.7 — Family Mesh

## WHAT YOU'LL BUILD

A simulated multi-brain family network where each family member has their own knowledge namespace. You will create three separate "brains" — brain-dad, brain-mom, and brain-kid — each loaded with different knowledge. Then you will query across all three to see how a family mesh works: Dad knows about plumbing and car repair. Mom knows the recipes and the school schedule. The kid knows homework and friends. Ask a question, and the mesh finds the right brain.

Think of it like a neighborhood. Each house has its own filing cabinet full of knowledge. When someone on the street needs an answer, they knock on the right door. Dad's house has the toolbox. Mom's house has the recipe book. The kid's house has the school binder. A family mesh lets you ask one question and get routed to the right house automatically.

Here is the honest part: this module simulates a mesh using one MCP server. We use knowledge categories as namespaces — "brain-dad", "brain-mom", "brain-kid" — to separate each person's knowledge. A real multi-brain network would use separate servers, separate databases, maybe separate machines. That is a future build. The CONCEPT is what matters here. Once you understand how namespace isolation and cross-brain queries work, scaling it to real separate brains is engineering, not invention.

---

## KEY TERMS

- **Namespace**: A label that keeps one set of data separate from another inside the same system. Like labeled folders in a filing cabinet — the cabinet is shared, but each folder belongs to one person. In this module, the knowledge category IS the namespace.

- **Multi-brain architecture**: A design where multiple AI brains coexist, each with their own knowledge, but can be queried together. Like a family where everyone has their own expertise, but you can ask the household a single question and the right person answers.

- **Family mesh**: A network of connected brains — one per family member — that can share information across boundaries when asked. The "mesh" part means they are linked, not isolated. Dad can ask what is for dinner. Mom can ask when the car needs an oil change.

- **Cross-brain query**: A question that searches across multiple namespaces at once. Instead of asking one brain, you ask the mesh, and it pulls relevant answers from whoever has them.

- **Social graph**: A map of relationships — who knows who, who trusts who, how strong each connection is. The `get_top_friends` and `search_friends` tools model this for your AI system.

---

## THE LESSON

### Step 1: One server, three brains

You already have a working MCP server with a knowledge base. So far, every entry you have added went into categories like "family", "philosophy", or "general". Those categories kept topics organized.

Now we repurpose categories as brain namespaces. Instead of "family" and "philosophy", we create "brain-dad", "brain-mom", and "brain-kid". Each category becomes a separate brain's memory.

```
brain-dad  ->  plumbing, car repair, family budget
brain-mom  ->  recipes, school schedule, first aid
brain-kid  ->  homework help, game rules, best friends
```

Same server. Same database. But the data is isolated by category. When you search "brain-dad", you only get Dad's knowledge. When you search "brain-mom", you only get Mom's.

### Step 2: Load each brain

Each brain gets three knowledge entries. The `add_knowledge` tool takes a `category` parameter — that is your namespace.

```
python shared\utils\mcp-call.py add_knowledge "{\"content\":\"To fix a leaky faucet...\",\"category\":\"brain-dad\",\"title\":\"Plumbing Basics\"}"
```

That entry belongs to brain-dad. Nobody else's brain will return it unless you search across all categories deliberately.

Do the same for brain-mom (recipes, schedules, first aid) and brain-kid (homework, games, friends). Nine entries total. Three brains, fully loaded.

### Step 3: Prove isolation works

Search each namespace individually:

```
python shared\utils\mcp-call.py search_knowledge "{\"query\":\"faucet repair\",\"category\":\"brain-dad\"}"
```

This should return Dad's plumbing entry and nothing from Mom or Kid. Then search brain-mom for "dinner recipe" — you should get Mom's recipe, not Dad's budget tips.

Isolation is the foundation of a mesh. If the brains bleed into each other, the mesh is broken.

### Step 4: Cross-brain queries

Now for the real test. Ask `chat_with_shanebrain` a question that spans the whole family:

```
python shared\utils\mcp-call.py chat_with_shanebrain "{\"message\":\"Who in the family knows about fixing a leaky faucet?\"}"
```

The RAG system searches ALL knowledge — across every category — and finds that brain-dad has plumbing content. The answer should point to Dad.

Ask another: "What is the family recipe for dinner?" The system should draw from brain-mom's entries.

This is the mesh in action. One question, multiple brains searched, the right answer surfaces.

### Step 5: Map the social graph

A family is not just knowledge — it is relationships. The `get_top_friends` tool shows the strongest connections in your social graph. The `search_friends` tool lets you search for specific people.

In a real family mesh, each brain would have its own friend profiles — Dad's coworkers, Mom's school contacts, the kid's classmates. For now, we use the existing social graph to show the concept.

### Step 6: The mesh summary

After loading all three brains, querying across them, and mapping the social graph, you have a working family mesh prototype. Three brains. Nine knowledge entries. Cross-brain queries that route to the right source.

---

## THE PATTERN

```
DEFINE NAMESPACES  ->  LOAD EACH BRAIN  ->  PROVE ISOLATION  ->  CROSS-BRAIN QUERY  ->  MAP SOCIAL GRAPH
(brain-dad,            (3 entries each)     (search by           (chat spans all         (get_top_friends,
 brain-mom,                                  category)            categories)              search_friends)
 brain-kid)
```

Five steps. Each one builds on the last. By the end, you have a working multi-brain family network running on one server.

---

## WHAT YOU PROVED

- You can use knowledge categories as brain namespaces to simulate multi-brain architecture
- You loaded three separate brains with distinct knowledge domains
- You proved namespace isolation — each brain's knowledge stays separate when searched directly
- You performed cross-brain queries that found the right source across all namespaces
- You mapped a social graph to model family relationships
- You understand the difference between a simulation (one server, category namespaces) and a real mesh (separate servers) — and why the concept transfers

**Next:** Run `exercise.bat`
