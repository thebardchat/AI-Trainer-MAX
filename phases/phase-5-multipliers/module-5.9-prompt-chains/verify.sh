#!/usr/bin/env bash
# MODULE 5.9 VERIFICATION — Prompt Chains
set -uo pipefail

BASE_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
MCP_CALL="$BASE_DIR/shared/utils/mcp-call.py"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

GREEN='\033[92m' RED='\033[91m' RESET='\033[0m'
PASS=0 FAIL=0 TOTAL=6

check() {
    local name="$1" result="$2"
    if [ "$result" = "pass" ]; then echo -e "  ${GREEN}  + PASS: $name${RESET}"; PASS=$((PASS+1))
    else echo -e "  ${RED}  x FAIL: $name${RESET}"; FAIL=$((FAIL+1)); fi
}

echo ""
echo "  ======================================================"
echo "   MODULE 5.9 VERIFICATION — Prompt Chains"
echo "  ======================================================"
echo ""

# CHECK 1: MCP server
python3 "$MCP_CALL" shanebrain_system_health > "$TMPDIR/health.json" 2>/dev/null
[ $? -eq 0 ] && check "MCP server reachable" "pass" || check "MCP server reachable" "fail"

# CHECK 2: Vault has content to chain on
python3 "$MCP_CALL" shanebrain_vault_search '{"params":{"query":"personal values family life"}}' > "$TMPDIR/vault.json" 2>/dev/null
VAULT=$(python3 -c "import json; d=json.load(open('$TMPDIR/vault.json')); r=d.get('results',[]); print('pass' if len(r)>0 else 'fail')" 2>/dev/null || echo "fail")
check "Vault has content for chaining" "$VAULT"

# CHECK 3: Chain step 1 — Summary generation
echo "   Running chain step 1 (summary)..."
python3 "$MCP_CALL" shanebrain_chat '{"params":{"message":"Summarize what you know about my values and beliefs in 2-3 sentences.","max_tokens":300}}' > "$TMPDIR/step1.json" 2>/dev/null
STEP1=$(python3 -c "import json; d=json.load(open('$TMPDIR/step1.json')); t=d.get('response',''); print('pass' if len(str(t))>50 else 'fail')" 2>/dev/null || echo "fail")
check "Chain step 1: Summary (>50 chars)" "$STEP1"

# CHECK 4: Chain step 2 — Theme analysis
echo "   Running chain step 2 (themes)..."
python3 "$MCP_CALL" shanebrain_chat '{"params":{"message":"What are the top 3 themes in my knowledge base? List them briefly.","max_tokens":300}}' > "$TMPDIR/step2.json" 2>/dev/null
STEP2=$(python3 -c "import json; d=json.load(open('$TMPDIR/step2.json')); t=d.get('response',''); print('pass' if len(str(t))>50 else 'fail')" 2>/dev/null || echo "fail")
check "Chain step 2: Themes (>50 chars)" "$STEP2"

# CHECK 5: Chain step 3 — Draft creation
echo "   Running chain step 3 (draft)..."
python3 "$MCP_CALL" shanebrain_draft_create '{"params":{"content":"Mission statement draft: Built on faith, family, and hard work. AI sovereignty for every person.","title":"Mission Statement","tone":"inspiring"}}' > "$TMPDIR/step3.json" 2>/dev/null
STEP3=$(python3 -c "import json; d=json.load(open('$TMPDIR/step3.json')); print('pass' if d.get('success') or d.get('uuid') or 'error' not in str(d).lower()[:100] else 'fail')" 2>/dev/null || echo "fail")
check "Chain step 3: Draft created" "$STEP3"

# CHECK 6: Knowledge search for context
python3 "$MCP_CALL" shanebrain_search_knowledge '{"params":{"query":"values beliefs mission purpose"}}' > "$TMPDIR/know.json" 2>/dev/null
KNOW=$(python3 -c "import json; d=json.load(open('$TMPDIR/know.json')); r=d.get('results',[]); print('pass' if len(r)>0 else 'fail')" 2>/dev/null || echo "fail")
check "Knowledge has context entries" "$KNOW"

echo ""
echo "  ======================================================"
[ "$FAIL" -eq 0 ] && { echo -e "  ${GREEN}  RESULT: PASS ($PASS/$TOTAL)${RESET}"; exit 0; } || { echo -e "  ${RED}  RESULT: FAIL ($PASS/$TOTAL passed, $FAIL failed)${RESET}"; exit 1; }
