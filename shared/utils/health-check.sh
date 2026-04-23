#!/usr/bin/env bash
# ============================================================
# ANGEL CLOUD HEALTH CHECK — Linux Edition
# Checks: RAM, Ollama, Weaviate, MCP, Models, Disk
# Safe to run anytime — read-only, changes nothing
# ============================================================

RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
RESET='\033[0m'

echo ""
echo "  ======================================================"
echo "   ANGEL CLOUD — SYSTEM HEALTH CHECK (Linux)"
echo "  ======================================================"
echo ""
echo "   Platform:   $(uname -srm)"
echo "   Timestamp:  $(date)"
echo ""
echo "  ──────────────────────────────────────────────────────"
echo ""

# === RAM CHECK ===
echo "  [RAM]"
TOTAL_MB=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo)
AVAIL_MB=$(awk '/MemAvailable/ {printf "%d", $2/1024}' /proc/meminfo)
USED_MB=$((TOTAL_MB - AVAIL_MB))

echo "    Total:     ${TOTAL_MB} MB"
echo "    Used:      ${USED_MB} MB"
echo "    Available: ${AVAIL_MB} MB"

if [ "$AVAIL_MB" -lt 2048 ]; then
    echo -e "  ${RED}   STATUS: CRITICAL — Below 2GB available${RESET}"
elif [ "$AVAIL_MB" -lt 4096 ]; then
    echo -e "  ${YELLOW}   STATUS: WARNING — Below 4GB available${RESET}"
else
    echo -e "  ${GREEN}   STATUS: GOOD${RESET}"
fi
echo ""

# === OLLAMA CHECK ===
echo "  [OLLAMA]"
if curl -sf http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "  ${GREEN}   Server:  Running on localhost:11434${RESET}"

    # List models
    echo "    Models installed:"
    curl -sf http://localhost:11434/api/tags 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for m in data.get('models', []):
        name = m.get('name', 'unknown')
        size_gb = m.get('size', 0) / (1024**3)
        print(f'      {name} ({size_gb:.1f} GB)')
except: pass
" 2>/dev/null

    # Check key models
    TAGS=$(curl -sf http://localhost:11434/api/tags 2>/dev/null)
    for model in "shanebrain-3b" "llama3.2:3b" "llama3.2:1b" "nomic-embed-text"; do
        if echo "$TAGS" | grep -qi "$model"; then
            echo -e "  ${GREEN}   Model:   $model available${RESET}"
        else
            echo -e "  ${YELLOW}   Model:   $model NOT found${RESET}"
        fi
    done
else
    echo -e "  ${RED}   Server:  NOT RUNNING${RESET}"
    echo "            Fix: sudo systemctl start ollama"
fi
echo ""

# === WEAVIATE CHECK ===
echo "  [WEAVIATE]"
if curl -sf http://localhost:8080/v1/.well-known/ready > /dev/null 2>&1; then
    echo -e "  ${GREEN}   Server:  Running on localhost:8080${RESET}"

    # Count collections
    CLASS_COUNT=$(curl -sf http://localhost:8080/v1/schema 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    classes = data.get('classes', [])
    print(len(classes))
    for c in classes:
        name = c.get('class', '')
        # Get object count
        import urllib.request
        resp = urllib.request.urlopen(f'http://localhost:8080/v1/objects?class={name}&limit=0')
        count_data = json.load(resp)
        count = count_data.get('totalResults', '?')
        print(f'      {name}: {count} objects')
except Exception as e:
    print(f'0')
" 2>/dev/null)

    echo "    Collections:"
    echo "$CLASS_COUNT" | tail -n +2
    TOTAL_CLASSES=$(echo "$CLASS_COUNT" | head -1)
    echo -e "  ${GREEN}   Schema:  $TOTAL_CLASSES collections detected${RESET}"
else
    echo -e "  ${RED}   Server:  NOT RUNNING${RESET}"
    echo "            Fix: cd /mnt/shanebrain-raid/shanebrain-core/weaviate-config && docker compose up -d"
fi
echo ""

# === MCP SERVER CHECK ===
echo "  [MCP SERVER]"
HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" http://localhost:8100/health 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "  ${GREEN}   Server:  Running on localhost:8100${RESET}"
    # Get health details
    curl -sf http://localhost:8100/health 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    for svc, info in d.get('services', {}).items():
        status = info.get('status', 'unknown')
        print(f'    {svc:12s} {status}')
except: pass
" 2>/dev/null
else
    echo -e "  ${RED}   Server:  NOT RUNNING${RESET}"
    echo "            Fix: docker start shanebrain-mcp"
fi
echo ""

# === DISK CHECK ===
echo "  [DISK]"
echo "    RAID (/mnt/shanebrain-raid):"
df -h /mnt/shanebrain-raid 2>/dev/null | tail -1 | awk '{printf "      Size: %s  Used: %s  Free: %s  (%s)\n", $2, $3, $4, $5}'
echo "    SD Card (/):"
df -h / | tail -1 | awk '{printf "      Size: %s  Used: %s  Free: %s  (%s)\n", $2, $3, $4, $5}'
echo ""

# === SUMMARY ===
echo "  ======================================================"
echo "   Health check complete. Review any warnings above."
echo "  ======================================================"
echo ""
