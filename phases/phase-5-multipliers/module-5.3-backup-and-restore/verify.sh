#!/usr/bin/env bash
# MODULE 5.3 VERIFICATION — Backup and Restore
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
echo "   MODULE 5.3 VERIFICATION — Backup and Restore"
echo "  ======================================================"
echo ""

# CHECK 1: MCP server
python3 "$MCP_CALL" shanebrain_system_health > "$TMPDIR/health.json" 2>/dev/null
[ $? -eq 0 ] && check "MCP server reachable" "pass" || check "MCP server reachable" "fail"

# CHECK 2: Knowledge export
python3 "$MCP_CALL" shanebrain_search_knowledge '{"params":{"query":"knowledge backup test"}}' > "$TMPDIR/know.json" 2>/dev/null
KNOW=$(python3 -c "import json; d=json.load(open('$TMPDIR/know.json')); r=d.get('results',[]); print('pass' if len(r)>0 else 'fail')" 2>/dev/null || echo "fail")
check "Knowledge export (search returns data)" "$KNOW"

# CHECK 3: Vault export
python3 "$MCP_CALL" shanebrain_vault_search '{"params":{"query":"vault backup documents"}}' > "$TMPDIR/vault.json" 2>/dev/null
VAULT=$(python3 -c "import json; d=json.load(open('$TMPDIR/vault.json')); r=d.get('results',[]); print('pass' if len(r)>0 else 'fail')" 2>/dev/null || echo "fail")
check "Vault export (search returns data)" "$VAULT"

# CHECK 4: System health returns collection counts
HEALTH=$(python3 -c "
import json; d=json.load(open('$TMPDIR/health.json'))
cols=d.get('collections',{})
total=sum(v for v in cols.values() if isinstance(v,int))
print('pass' if total>0 else 'fail')
" 2>/dev/null || echo "fail")
check "System health shows collection counts" "$HEALTH"

# CHECK 5: add_knowledge works
python3 "$MCP_CALL" shanebrain_add_knowledge '{"params":{"content":"Backup verify test entry from module 5.3","category":"training-test","source":"ai-trainer-max"}}' > "$TMPDIR/add.json" 2>/dev/null
ADD=$(python3 -c "import json; d=json.load(open('$TMPDIR/add.json')); print('pass' if d.get('success') or d.get('uuid') else 'fail')" 2>/dev/null || echo "fail")
check "add_knowledge works" "$ADD"

# CHECK 6: vault_list_categories
python3 "$MCP_CALL" shanebrain_vault_list_categories > "$TMPDIR/cats.json" 2>/dev/null
CATS=$(python3 -c "import json; d=json.load(open('$TMPDIR/cats.json')); print('pass' if 'error' not in str(d).lower()[:100] else 'fail')" 2>/dev/null || echo "fail")
check "vault_list_categories returns data" "$CATS"

echo ""
echo "  ======================================================"
[ "$FAIL" -eq 0 ] && { echo -e "  ${GREEN}  RESULT: PASS ($PASS/$TOTAL)${RESET}"; exit 0; } || { echo -e "  ${RED}  RESULT: FAIL ($PASS/$TOTAL passed, $FAIL failed)${RESET}"; exit 1; }
