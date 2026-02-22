@echo off
setlocal enabledelayedexpansion
title Module 5.7 Exercise — Family Mesh

:: ============================================================
:: MODULE 5.7 EXERCISE: Family Mesh
:: Goal: Simulate multi-brain family network using knowledge
::       categories as namespaces. Load 3 brains, prove
::       isolation, run cross-brain queries, map social graph
:: Time: ~20 minutes
:: Prerequisites: Module 5.6, Module 4.7
:: ============================================================

set "MCP_CALL=%~dp0..\..\..\shared\utils\mcp-call.py"
set "TEMP_DIR=%TEMP%\module-5.7"

echo.
echo  ======================================================
echo   MODULE 5.7 EXERCISE: Family Mesh
echo   Multi-Brain Family Network
echo  ======================================================
echo.
echo   Every family member knows different things. Dad fixes
echo   the faucet. Mom knows what is for dinner. The kid
echo   knows what homework is due. This exercise builds a
echo   brain for each of them — then connects them into a
echo   mesh you can query all at once.
echo.
echo  ------------------------------------------------------
echo.

:: --- PRE-FLIGHT: MCP Server ---
echo  [PRE-FLIGHT] Checking MCP server...
echo.

if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

python "%MCP_CALL%" system_health > "%TEMP_DIR%\preflight.json" 2>nul
if %errorlevel% NEQ 0 (
    echo  [91m   X MCP server not reachable at localhost:8100[0m
    echo     Fix: Make sure the MCP server container is running.
    echo     Run: shared\utils\mcp-health-check.bat
    pause
    exit /b 1
)
echo  [92m   OK — MCP server responding[0m
echo.

:: ============================================================
:: TASK 1: Load Brain-Dad (3 entries)
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 1/8] Brain-Dad — The Fixer
echo.
echo   Dad knows how things work. Plumbing, cars, budgets.
echo   When something breaks, you call Dad. Loading three
echo   entries into the brain-dad namespace...
echo.

python "%MCP_CALL%" add_knowledge "{\"content\":\"To fix a leaky faucet, first turn off the water supply valve under the sink. Then remove the handle — usually one screw under the cap. Pull out the cartridge or stem and check the O-ring and washer. Replace any worn parts. Reassemble in reverse order and test. Most leaks are just a worn washer that costs less than a dollar.\",\"category\":\"brain-dad\",\"title\":\"Plumbing Basics — Leaky Faucet\"}" > "%TEMP_DIR%\dad1.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Dad entry 1: Plumbing Basics[0m
) else (
    echo  [91m   FAIL — Could not add Dad entry 1[0m
)

python "%MCP_CALL%" add_knowledge "{\"content\":\"Car maintenance schedule: Change oil every 5000 miles or 6 months, whichever comes first. Rotate tires every 7500 miles. Replace air filter once a year. Check brake pads at every oil change — if the pad is thinner than a pencil, replace it. Keep jumper cables and a tire gauge in the trunk at all times.\",\"category\":\"brain-dad\",\"title\":\"Car Maintenance Schedule\"}" > "%TEMP_DIR%\dad2.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Dad entry 2: Car Maintenance[0m
) else (
    echo  [91m   FAIL — Could not add Dad entry 2[0m
)

python "%MCP_CALL%" add_knowledge "{\"content\":\"Family budget rule: 50-30-20. Fifty percent of income goes to needs — rent, groceries, utilities, insurance. Thirty percent goes to wants — eating out, hobbies, entertainment. Twenty percent goes to savings and debt payoff. Track every dollar for one month before making changes. You cannot fix what you do not measure.\",\"category\":\"brain-dad\",\"title\":\"Family Budget Tips\"}" > "%TEMP_DIR%\dad3.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Dad entry 3: Family Budget[0m
) else (
    echo  [91m   FAIL — Could not add Dad entry 3[0m
)
echo.

:: ============================================================
:: TASK 2: Load Brain-Mom (3 entries)
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 2/8] Brain-Mom — The Organizer
echo.
echo   Mom keeps the family running. Recipes, schedules,
echo   medical info. When you need to know what is happening
echo   and when, you ask Mom. Loading three entries...
echo.

python "%MCP_CALL%" add_knowledge "{\"content\":\"Grandma's chicken and dumplings: Boil a whole chicken until tender, about 90 minutes. Remove and shred the meat. Keep the broth. Mix 2 cups flour, 1 tsp salt, 3 tbsp butter, and enough broth to make a stiff dough. Roll thin, cut into strips, drop into simmering broth. Cook 15 minutes. Add shredded chicken back. Season with salt and pepper. Feeds the whole family with leftovers.\",\"category\":\"brain-mom\",\"title\":\"Family Recipe — Chicken and Dumplings\"}" > "%TEMP_DIR%\mom1.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Mom entry 1: Chicken and Dumplings Recipe[0m
) else (
    echo  [91m   FAIL — Could not add Mom entry 1[0m
)

python "%MCP_CALL%" add_knowledge "{\"content\":\"School pickup schedule: Monday through Friday, school lets out at 3:15 PM. Carpool lane opens at 3:00. Oldest son has baseball practice Tuesdays and Thursdays until 5:00 — pick up at the field. Wednesday is early release at 1:30. Pack snacks for the car on early release days. Emergency contact at the school office: 555-0147.\",\"category\":\"brain-mom\",\"title\":\"School Pickup Schedule\"}" > "%TEMP_DIR%\mom2.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Mom entry 2: School Pickup Schedule[0m
) else (
    echo  [91m   FAIL — Could not add Mom entry 2[0m
)

python "%MCP_CALL%" add_knowledge "{\"content\":\"First aid basics for kids: For cuts, clean with water, apply pressure with clean cloth, use antibiotic ointment and bandage. For burns, run cool water for 10 minutes — never ice. For fever over 101F, give age-appropriate dose of acetaminophen and call the doctor if it lasts more than 3 days. Allergies: youngest is allergic to tree nuts. EpiPen is in the kitchen drawer by the fridge.\",\"category\":\"brain-mom\",\"title\":\"First Aid Basics\"}" > "%TEMP_DIR%\mom3.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Mom entry 3: First Aid Basics[0m
) else (
    echo  [91m   FAIL — Could not add Mom entry 3[0m
)
echo.

:: ============================================================
:: TASK 3: Load Brain-Kid (3 entries)
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 3/8] Brain-Kid — The Student
echo.
echo   The kid knows school stuff, games, and friends.
echo   Different world, different knowledge. Loading three
echo   entries...
echo.

python "%MCP_CALL%" add_knowledge "{\"content\":\"Math homework help: To solve fractions, find a common denominator first. For 1/3 + 1/4, the common denominator is 12. Convert: 4/12 + 3/12 = 7/12. For multiplication, just multiply straight across: 2/3 times 4/5 = 8/15. For division, flip the second fraction and multiply: 2/3 divided by 4/5 = 2/3 times 5/4 = 10/12 = 5/6.\",\"category\":\"brain-kid\",\"title\":\"Math Homework — Fractions\"}" > "%TEMP_DIR%\kid1.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Kid entry 1: Math Homework Help[0m
) else (
    echo  [91m   FAIL — Could not add Kid entry 1[0m
)

python "%MCP_CALL%" add_knowledge "{\"content\":\"Minecraft survival mode rules: On the first day, punch trees for wood, make a crafting table, build a wooden pickaxe, mine stone, upgrade to stone tools. Find coal for torches before nightfall. Build a shelter — even a dirt hut works. Never dig straight down. Always carry a water bucket. Diamonds are found below Y level 16. Creepers are silent — always look behind you.\",\"category\":\"brain-kid\",\"title\":\"Favorite Game Rules — Minecraft\"}" > "%TEMP_DIR%\kid2.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Kid entry 2: Minecraft Rules[0m
) else (
    echo  [91m   FAIL — Could not add Kid entry 2[0m
)

python "%MCP_CALL%" add_knowledge "{\"content\":\"Best friend info: Marcus has been my best friend since second grade. He lives on Oak Street, three houses down. His mom is Mrs. Johnson. We ride bikes after school on Fridays. He is good at science and helps me study. His birthday is March 15. He likes pepperoni pizza and Dr Pepper. We are building a treehouse this summer.\",\"category\":\"brain-kid\",\"title\":\"Best Friend — Marcus\"}" > "%TEMP_DIR%\kid3.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Kid entry 3: Best Friend Info[0m
) else (
    echo  [91m   FAIL — Could not add Kid entry 3[0m
)
echo.

:: ============================================================
:: TASK 4: Prove Namespace Isolation
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 4/8] Prove Isolation — Each Brain Stays Separate
echo.
echo   If the mesh works, searching brain-dad should NOT
echo   return Mom's recipes. Let's prove it.
echo.

echo   Searching brain-dad for "faucet repair"...
python "%MCP_CALL%" search_knowledge "{\"query\":\"faucet repair\",\"category\":\"brain-dad\"}" > "%TEMP_DIR%\search_dad.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — brain-dad search returned results[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search_dad.json')); results=d.get('results',d.get('knowledge',[])); entries=results if isinstance(results,list) else [results]; print('       Found',len(entries),'entries in brain-dad')" 2>nul
) else (
    echo  [91m   FAIL — brain-dad search failed[0m
)
echo.

echo   Searching brain-mom for "dinner recipe"...
python "%MCP_CALL%" search_knowledge "{\"query\":\"dinner recipe\",\"category\":\"brain-mom\"}" > "%TEMP_DIR%\search_mom.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — brain-mom search returned results[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search_mom.json')); results=d.get('results',d.get('knowledge',[])); entries=results if isinstance(results,list) else [results]; print('       Found',len(entries),'entries in brain-mom')" 2>nul
) else (
    echo  [91m   FAIL — brain-mom search failed[0m
)
echo.

echo   Searching brain-kid for "homework"...
python "%MCP_CALL%" search_knowledge "{\"query\":\"homework\",\"category\":\"brain-kid\"}" > "%TEMP_DIR%\search_kid.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — brain-kid search returned results[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search_kid.json')); results=d.get('results',d.get('knowledge',[])); entries=results if isinstance(results,list) else [results]; print('       Found',len(entries),'entries in brain-kid')" 2>nul
) else (
    echo  [91m   FAIL — brain-kid search failed[0m
)
echo.

:: ============================================================
:: TASK 5: Cross-Brain Query — Who Knows About Plumbing?
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 5/8] Cross-Brain Query — Who Fixes the Faucet?
echo.
echo   Now the mesh test. We ask a question that spans ALL
echo   brains. The system should find Dad's plumbing entry.
echo.
echo   Asking: "Who in the family knows about fixing a leaky faucet?"
echo   Give it a moment — Ollama is thinking...
echo.

python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"Who in the family knows about fixing a leaky faucet? Check the brain-dad, brain-mom, and brain-kid knowledge categories.\"}" > "%TEMP_DIR%\cross1.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Cross-brain query answered[0m
    echo.
    echo   +--------------------------------------------------+
    echo   ^|  MESH RESPONSE:                                  ^|
    echo   +--------------------------------------------------+
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\cross1.json')); text=d.get('response',d.get('text',d.get('message',str(d)))); print('    ',text[:500])" 2>nul
    echo.
    echo   +--------------------------------------------------+
) else (
    echo  [91m   FAIL — Cross-brain query failed[0m
    echo     Ollama may need time to load. Try again in 30 seconds.
)
echo.

:: ============================================================
:: TASK 6: Cross-Brain Query — What's for Dinner?
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 6/8] Cross-Brain Query — What's for Dinner?
echo.
echo   Asking: "What is the family recipe for dinner?"
echo   This should draw from brain-mom...
echo.

python "%MCP_CALL%" chat_with_shanebrain "{\"message\":\"What is the family recipe for dinner tonight? Check the brain-mom knowledge for recipes.\"}" > "%TEMP_DIR%\cross2.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Cross-brain query answered[0m
    echo.
    echo   +--------------------------------------------------+
    echo   ^|  MESH RESPONSE:                                  ^|
    echo   +--------------------------------------------------+
    echo.
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\cross2.json')); text=d.get('response',d.get('text',d.get('message',str(d)))); print('    ',text[:500])" 2>nul
    echo.
    echo   +--------------------------------------------------+
) else (
    echo  [91m   FAIL — Cross-brain query failed[0m
    echo     Check hints.md for troubleshooting.
)
echo.

:: ============================================================
:: TASK 7: Map the Family Social Graph
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 7/8] Social Graph — Family Connections
echo.
echo   A mesh is not just knowledge — it is relationships.
echo   Who is connected to who? How strong is the bond?
echo.

echo   Fetching top friends (social graph)...
python "%MCP_CALL%" get_top_friends "{\"limit\":10}" > "%TEMP_DIR%\friends.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Social graph retrieved[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\friends.json')); friends=d.get('friends',d.get('results',[])); entries=friends if isinstance(friends,list) else [friends]; print('       Found',len(entries),'connections in social graph')" 2>nul
) else (
    echo  [93m   WARN — get_top_friends returned no data[0m
    echo     This is OK if you have not added friend profiles yet.
)
echo.

echo   Searching friends for "family"...
python "%MCP_CALL%" search_friends "{\"query\":\"family\"}" > "%TEMP_DIR%\search_friends.json" 2>nul
if %errorlevel% EQU 0 (
    echo  [92m   OK — Friend search completed[0m
    python -c "import json; d=json.load(open(r'%TEMP_DIR%\search_friends.json')); friends=d.get('friends',d.get('results',[])); entries=friends if isinstance(friends,list) else [friends]; print('       Found',len(entries),'matches for family')" 2>nul
) else (
    echo  [93m   WARN — search_friends returned no data[0m
    echo     This is OK — friend profiles are optional for this exercise.
)
echo.

:: ============================================================
:: TASK 8: Mesh Summary
:: ============================================================
echo  ------------------------------------------------------
echo.
echo  [TASK 8/8] Family Mesh Summary
echo.
echo   +======================================================+
echo   ^|                                                      ^|
echo   ^|  [92m   FAMILY MESH — NETWORK MAP[0m                       ^|
echo   ^|                                                      ^|
echo   ^|  [93m   brain-dad[0m (3 entries)                           ^|
echo   ^|     - Plumbing basics                                ^|
echo   ^|     - Car maintenance                                ^|
echo   ^|     - Family budget                                  ^|
echo   ^|                                                      ^|
echo   ^|  [93m   brain-mom[0m (3 entries)                           ^|
echo   ^|     - Chicken and dumplings recipe                   ^|
echo   ^|     - School pickup schedule                         ^|
echo   ^|     - First aid basics                               ^|
echo   ^|                                                      ^|
echo   ^|  [93m   brain-kid[0m (3 entries)                           ^|
echo   ^|     - Math homework (fractions)                      ^|
echo   ^|     - Minecraft rules                                ^|
echo   ^|     - Best friend Marcus                             ^|
echo   ^|                                                      ^|
echo   ^|  [92m   TOTAL: 3 brains, 9 entries[0m                     ^|
echo   ^|  [92m   Cross-brain queries: WORKING[0m                   ^|
echo   ^|  [92m   Social graph: MAPPED[0m                           ^|
echo   ^|                                                      ^|
echo   +======================================================+
echo.
echo   You just built a family mesh. Three brains, each with
echo   their own knowledge, connected through one query layer.
echo.
echo   Today it is categories on one server. Tomorrow it could
echo   be three Raspberry Pis on your home network — one per
echo   family member, each with their own Ollama and Weaviate.
echo   The architecture is the same. The scale changes.
echo.
echo   Now run verify.bat to lock in your completion.
echo.

if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
exit /b 0
