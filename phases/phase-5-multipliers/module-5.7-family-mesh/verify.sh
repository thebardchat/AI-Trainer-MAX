#!/usr/bin/env bash
# MODULE 5.7 VERIFICATION — Family Mesh
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
echo "   MODULE 5.7 VERIFICATION — Family Mesh"
echo "  ======================================================"
echo ""

# CHECK 1: MCP server
python3 "$MCP_CALL" shanebrain_system_health > "$TMPDIR/health.json" 2>/dev/null
[ $? -eq 0 ] && check "MCP server reachable" "pass" || check "MCP server reachable" "fail"

# CHECK 2: brain-dad namespace has entries
python3 "$MCP_CALL" shanebrain_search_knowledge '{"params":{"query":"dad father provider hard work family"}}' > "$TMPDIR/dad.json" 2>/dev/null
DAD=$(python3 -c "import json; d=json.load(open('$TMPDIR/dad.json')); r=d.get('results',[]); print('pass' if len(r)>0 else 'fail')" 2>/dev/null || echo "fail")
check "Dad brain namespace has entries" "$DAD"

# CHECK 3: brain-mom namespace has entries
python3 "$MCP_CALL" shanebrain_search_knowledge '{"params":{"query":"mom mother nurture care family home"}}' > "$TMPDIR/mom.json" 2>/dev/null
MOM=$(python3 -c "import json; d=json.load(open('$TMPDIR/mom.json')); r=d.get('results',[]); print('pass' if len(r)>0 else 'fail')" 2>/dev/null || echo "fail")
check "Mom brain namespace has entries" "$MOM"

# CHECK 4: brain-kid namespace has entries
python3 "$MCP_CALL" shanebrain_search_knowledge '{"params":{"query":"kid child learning growing playing"}}' > "$TMPDIR/kid.json" 2>/dev/null
KID=$(python3 -c "import json; d=json.load(open('$TMPDIR/kid.json')); r=d.get('results',[]); print('pass' if len(r)>0 else 'fail')" 2>/dev/null || echo "fail")
check "Kid brain namespace has entries" "$KID"

# CHECK 5: Cross-brain chat
python3 "$MCP_CALL" shanebrain_chat '{"params":{"message":"What does this family value most?","max_tokens":200}}' > "$TMPDIR/chat.json" 2>/dev/null
CHAT=$(python3 -c "import json; d=json.load(open('$TMPDIR/chat.json')); t=d.get('response',''); print('pass' if len(str(t))>20 else 'fail')" 2>/dev/null || echo "fail")
check "Cross-brain chat responds" "$CHAT"

# CHECK 6: Social graph accessible
python3 "$MCP_CALL" shanebrain_get_top_friends > "$TMPDIR/friends.json" 2>/dev/null
FRIENDS=$(python3 -c "import json; d=json.load(open('$TMPDIR/friends.json')); print('pass' if 'error' not in str(d).lower()[:100] else 'fail')" 2>/dev/null || echo "fail")
check "Social graph accessible" "$FRIENDS"

echo ""
echo "  ======================================================"
[ "$FAIL" -eq 0 ] && { echo -e "  ${GREEN}  RESULT: PASS ($PASS/$TOTAL)${RESET}"; exit 0; } || { echo -e "  ${RED}  RESULT: FAIL ($PASS/$TOTAL passed, $FAIL failed)${RESET}"; exit 1; }
