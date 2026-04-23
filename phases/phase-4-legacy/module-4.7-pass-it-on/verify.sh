#!/usr/bin/env bash
# MODULE 4.7 VERIFICATION — TRAINING CAPSTONE (PHASE 4)
# Checks: MCP reachable, knowledge entries, vault entries, chat, personal content, collections
set -uo pipefail

BASE_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
MCP_CALL="$BASE_DIR/shared/utils/mcp-call.py"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

GREEN='\033[92m' RED='\033[91m' YELLOW='\033[93m' RESET='\033[0m'
PASS=0 FAIL=0 TOTAL=6

check() {
    local name="$1" result="$2"
    if [ "$result" = "pass" ]; then
        echo -e "  ${GREEN}  + PASS: $name${RESET}"
        PASS=$((PASS+1))
    else
        echo -e "  ${RED}  x FAIL: $name${RESET}"
        FAIL=$((FAIL+1))
    fi
}

echo ""
echo "  ======================================================"
echo "   MODULE 4.7 VERIFICATION — TRAINING CAPSTONE"
echo "  ======================================================"
echo ""

# CHECK 1: MCP server reachable
python3 "$MCP_CALL" shanebrain_system_health > "$TMPDIR/health.json" 2>/dev/null
[ $? -eq 0 ] && check "MCP server reachable" "pass" || check "MCP server reachable" "fail"

# CHECK 2: Knowledge base has family entries
python3 "$MCP_CALL" shanebrain_search_knowledge '{"params":{"query":"family values hard work honesty"}}' > "$TMPDIR/knowledge.json" 2>/dev/null
KNOW_COUNT=$(python3 -c "
import json
d=json.load(open('$TMPDIR/knowledge.json'))
results=d.get('results',d.get('knowledge',[]))
print(len(results) if isinstance(results,list) else 1)
" 2>/dev/null || echo "0")
[ "$KNOW_COUNT" -ge 3 ] 2>/dev/null && check "Knowledge: $KNOW_COUNT entries about family values (need 3+)" "pass" || check "Knowledge: $KNOW_COUNT entries (need 3+)" "fail"

# CHECK 3: Vault has life story entries
python3 "$MCP_CALL" shanebrain_vault_search '{"params":{"query":"life stories memories lessons children"}}' > "$TMPDIR/vault.json" 2>/dev/null
VAULT_COUNT=$(python3 -c "
import json
d=json.load(open('$TMPDIR/vault.json'))
results=d.get('results',d.get('documents',[]))
print(len(results) if isinstance(results,list) else 1)
" 2>/dev/null || echo "0")
[ "$VAULT_COUNT" -ge 3 ] 2>/dev/null && check "Vault: $VAULT_COUNT documents (need 3+)" "pass" || check "Vault: $VAULT_COUNT documents (need 3+)" "fail"

# CHECK 4: Chat responds
echo "   Talking to your brain..."
python3 "$MCP_CALL" shanebrain_chat '{"params":{"message":"What do you know about my family values?","max_tokens":200}}' > "$TMPDIR/chat.json" 2>/dev/null
CHAT_OK=$(python3 -c "
import json
d=json.load(open('$TMPDIR/chat.json'))
text=d.get('response',d.get('text',''))
print('pass' if len(str(text).strip())>20 and 'error' not in str(d).lower()[:100] else 'fail')
" 2>/dev/null || echo "fail")
check "Chat responds about family values" "$CHAT_OK"

# CHECK 5: Response contains personal content
PERSONAL_OK=$(python3 -c "
import json
d=json.load(open('$TMPDIR/chat.json'))
text=str(d.get('response',d.get('text',''))).lower()
keywords=['family','work','truth','honest','children','values','hard']
matches=[k for k in keywords if k in text]
print('pass' if len(matches)>=2 else 'fail')
" 2>/dev/null || echo "fail")
check "Response references personal content" "$PERSONAL_OK"

# CHECK 6: Collections populated
COLS_OK=$(python3 -c "
import json
d=json.load(open('$TMPDIR/health.json'))
cols=d.get('collections',{})
total=sum(v for v in cols.values() if isinstance(v,int))
populated=sum(1 for v in cols.values() if isinstance(v,int) and v>0)
print('pass' if populated>=2 and total>=6 else 'fail')
" 2>/dev/null || echo "fail")
check "Collections populated (2+ collections, 6+ objects)" "$COLS_OK"

# RESULTS
echo ""
echo "  ======================================================"
if [ "$FAIL" -eq 0 ]; then
    echo -e "  ${GREEN}  RESULT: PASS ($PASS/$TOTAL checks passed)${RESET}"
    echo ""
    echo -e "  ${GREEN}  PHASE 4 COMPLETE — Your name. Your brain. Your legacy.${RESET}"
    exit 0
else
    echo -e "  ${RED}  RESULT: FAIL ($PASS/$TOTAL passed, $FAIL failed)${RESET}"
    echo "   Review failures above, run exercises, then verify again."
    exit 1
fi
