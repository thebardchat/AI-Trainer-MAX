#!/usr/bin/env bash
# MODULE 5.10 VERIFICATION — THE MULTIPLIER (PHASE 5 CAPSTONE)
set -uo pipefail

BASE_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
MCP_CALL="$BASE_DIR/shared/utils/mcp-call.py"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

GREEN='\033[92m' RED='\033[91m' YELLOW='\033[93m' RESET='\033[0m'
PASS=0 FAIL=0 TOTAL=8

check() {
    local name="$1" result="$2"
    if [ "$result" = "pass" ]; then echo -e "  ${GREEN}  + PASS: $name${RESET}"; PASS=$((PASS+1))
    else echo -e "  ${RED}  x FAIL: $name${RESET}"; FAIL=$((FAIL+1)); fi
}

echo ""
echo "  ======================================================"
echo "   MODULE 5.10 VERIFICATION — THE MULTIPLIER (CAPSTONE)"
echo "  ======================================================"
echo ""

# CHECK 1: MCP server
python3 "$MCP_CALL" shanebrain_system_health > "$TMPDIR/health.json" 2>/dev/null
[ $? -eq 0 ] && check "MCP server reachable" "pass" || check "MCP server reachable" "fail"

# CHECK 2: Collections populated
COLS=$(python3 -c "
import json; d=json.load(open('$TMPDIR/health.json'))
cols=d.get('collections',{})
total=sum(v for v in cols.values() if isinstance(v,int))
populated=sum(1 for v in cols.values() if isinstance(v,int) and v>0)
print('pass' if populated>=2 and total>=6 else 'fail')
" 2>/dev/null || echo "fail")
check "Collections populated (2+ collections, 6+ objects)" "$COLS"

# CHECK 3: Security log search
python3 "$MCP_CALL" shanebrain_security_log_search '{"params":{"query":"security events"}}' > "$TMPDIR/security.json" 2>/dev/null
SEC=$(python3 -c "import json; d=json.load(open('$TMPDIR/security.json')); print('pass' if 'error' not in str(d).lower()[:100] else 'fail')" 2>/dev/null || echo "fail")
check "Security log search executes" "$SEC"

# CHECK 4: Chat responds to beginner question
echo "   Asking brain a beginner question..."
python3 "$MCP_CALL" shanebrain_chat '{"params":{"message":"Explain what a RAG pipeline is in simple terms.","max_tokens":300}}' > "$TMPDIR/chat.json" 2>/dev/null
CHAT=$(python3 -c "import json; d=json.load(open('$TMPDIR/chat.json')); t=d.get('response',''); print('pass' if len(str(t))>50 else 'fail')" 2>/dev/null || echo "fail")
check "Chat responds to beginner question" "$CHAT"

# CHECK 5: Teaching draft stored in vault
python3 "$MCP_CALL" shanebrain_vault_add '{"params":{"content":"Teaching draft: A RAG pipeline connects your documents to your AI so it answers from YOUR data, not guesses.","category":"teaching"}}' > "$TMPDIR/teach.json" 2>/dev/null
TEACH=$(python3 -c "import json; d=json.load(open('$TMPDIR/teach.json')); print('pass' if d.get('success') or d.get('uuid') else 'fail')" 2>/dev/null || echo "fail")
check "Teaching draft stored in vault" "$TEACH"

# CHECK 6: vault_list_categories
python3 "$MCP_CALL" shanebrain_vault_list_categories > "$TMPDIR/cats.json" 2>/dev/null
CATS=$(python3 -c "import json; d=json.load(open('$TMPDIR/cats.json')); print('pass' if 'error' not in str(d).lower()[:100] else 'fail')" 2>/dev/null || echo "fail")
check "Vault categories accessible" "$CATS"

# CHECK 7: Knowledge search
python3 "$MCP_CALL" shanebrain_search_knowledge '{"params":{"query":"AI brain knowledge local"}}' > "$TMPDIR/know.json" 2>/dev/null
KNOW=$(python3 -c "import json; d=json.load(open('$TMPDIR/know.json')); r=d.get('results',[]); print('pass' if len(r)>0 else 'fail')" 2>/dev/null || echo "fail")
check "Knowledge search returns entries" "$KNOW"

# CHECK 8: Raw MCP curl call
HTTP=$(curl -sf -o /dev/null -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"verify-5.10","version":"1.0"}}}' \
    http://localhost:8100/mcp 2>/dev/null || echo "000")
[ "$HTTP" = "200" ] && check "Raw MCP protocol call (HTTP 200)" "pass" || check "Raw MCP protocol call (HTTP $HTTP)" "fail"

# RESULTS
echo ""
echo "  ======================================================"
if [ "$FAIL" -eq 0 ]; then
    echo -e "  ${GREEN}  RESULT: PASS ($PASS/$TOTAL checks passed)${RESET}"
    echo ""
    echo -e "  ${GREEN}  =====================================================${RESET}"
    echo -e "  ${GREEN}   PHASE 5 COMPLETE — THE MULTIPLIER${RESET}"
    echo -e "  ${GREEN}  =====================================================${RESET}"
    echo ""
    echo -e "  ${YELLOW}   ALL TRAINING COMPLETE${RESET}"
    echo ""
    echo "   You proved it. All of it."
    echo ""
    echo -e "    ${GREEN}Phase 1: BUILDER${RESET}      — You built the engine"
    echo -e "    ${GREEN}Phase 2: OPERATOR${RESET}     — You ran a business on it"
    echo -e "    ${GREEN}Phase 3: EVERYDAY${RESET}     — You used it daily"
    echo -e "    ${GREEN}Phase 4: LEGACY${RESET}       — You built something that outlasts you"
    echo -e "    ${GREEN}Phase 5: MULTIPLIER${RESET}   — You can defend, teach, connect, and build"
    echo ""
    echo -e "  ${YELLOW}  Your name. Your brain. Your legacy. Pass it on.${RESET}"
    echo ""
    exit 0
else
    echo -e "  ${RED}  RESULT: FAIL ($PASS/$TOTAL passed, $FAIL failed)${RESET}"
    echo "   Review failures above, run exercises, then verify again."
    exit 1
fi
