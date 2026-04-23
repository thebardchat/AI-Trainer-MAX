#!/usr/bin/env bash
# ============================================================
# ANGEL CLOUD AI TRAINING TOOLS — Linux Launcher
# Ported from launch-training.bat for Pi / Linux
# RAM Ceiling: 16GB Pi 5 — modules capped at 3GB peak
# ============================================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
PROGRESS_FILE="$BASE_DIR/progress/user-progress.json"
CONFIG_FILE="$BASE_DIR/config.json"
HEALTH_CHECK="$BASE_DIR/shared/utils/health-check.sh"
MCP_CALL="$BASE_DIR/shared/utils/mcp-call.py"
RUN_MODULE="$BASE_DIR/run-module.sh"

# Colors
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BOLD='\033[1m'
RESET='\033[0m'

# ============================================================
# ASCII BANNER
# ============================================================
banner() {
    clear
    echo ""
    echo "   ╔══════════════════════════════════════════════════════════╗"
    echo "   ║                                                          ║"
    echo "   ║     █████╗ ███╗   ██╗ ██████╗ ███████╗██╗                ║"
    echo "   ║    ██╔══██╗████╗  ██║██╔════╝ ██╔════╝██║                ║"
    echo "   ║    ███████║██╔██╗ ██║██║  ███╗█████╗  ██║                ║"
    echo "   ║    ██╔══██║██║╚██╗██║██║   ██║██╔══╝  ██║                ║"
    echo "   ║    ██║  ██║██║ ╚████║╚██████╔╝███████╗███████╗           ║"
    echo "   ║    ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝           ║"
    echo "   ║                                                          ║"
    echo "   ║          ██████╗██╗      ██████╗ ██╗   ██╗██████╗        ║"
    echo "   ║         ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗       ║"
    echo "   ║         ██║     ██║     ██║   ██║██║   ██║██║  ██║       ║"
    echo "   ║         ██║     ██║     ██║   ██║██║   ██║██║  ██║       ║"
    echo "   ║         ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝      ║"
    echo "   ║          ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝       ║"
    echo "   ║                                                          ║"
    echo "   ║          AI TRAINING TOOLS (Linux Edition)               ║"
    echo "   ║          Local AI literacy for every person.             ║"
    echo "   ║                                                          ║"
    echo "   ╚══════════════════════════════════════════════════════════╝"
    echo ""
}

# ============================================================
# HEALTH CHECKS
# ============================================================
preflight() {
    echo "  [SYSTEM CHECK] Running pre-flight diagnostics..."
    echo ""

    # --- RAM CHECK ---
    FREE_RAM_MB=$(awk '/MemAvailable/ {printf "%d", $2/1024}' /proc/meminfo)
    TOTAL_RAM_MB=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo)

    if [ "$FREE_RAM_MB" -lt 2048 ]; then
        echo -e "  ${RED}  x BLOCKED: Only ${FREE_RAM_MB}MB RAM free. Need at least 2048MB.${RESET}"
        echo "    Close some applications and try again."
        exit 1
    elif [ "$FREE_RAM_MB" -lt 4096 ]; then
        echo -e "  ${YELLOW}  ! WARNING: Only ${FREE_RAM_MB}MB RAM free. Recommended: 4096MB+${RESET}"
    else
        echo -e "  ${GREEN}  + RAM: ${FREE_RAM_MB}MB / ${TOTAL_RAM_MB}MB — good to go${RESET}"
    fi

    # --- OLLAMA CHECK ---
    if curl -sf http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo -e "  ${GREEN}  + Ollama: Running${RESET}"
    else
        echo -e "  ${YELLOW}  ! Ollama not running. Trying to start...${RESET}"
        ollama serve &>/dev/null &
        sleep 3
        if curl -sf http://localhost:11434/api/tags > /dev/null 2>&1; then
            echo -e "  ${GREEN}  + Ollama: Started${RESET}"
        else
            echo -e "  ${RED}  x Could not start Ollama. Run: ollama serve${RESET}"
            exit 1
        fi
    fi

    # --- WEAVIATE CHECK ---
    if curl -sf http://localhost:8080/v1/.well-known/ready > /dev/null 2>&1; then
        echo -e "  ${GREEN}  + Weaviate: Running${RESET}"
    else
        echo -e "  ${YELLOW}  ! Weaviate not detected at localhost:8080${RESET}"
    fi

    # --- MCP SERVER CHECK ---
    HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" http://localhost:8100/health 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "  ${GREEN}  + MCP Server: Running (port 8100)${RESET}"
    else
        echo -e "  ${YELLOW}  ! MCP Server not detected at localhost:8100${RESET}"
    fi

    # --- MODEL CHECK ---
    if curl -sf http://localhost:11434/api/tags 2>/dev/null | grep -qi "shanebrain-3b"; then
        echo -e "  ${GREEN}  + Model: shanebrain-3b loaded${RESET}"
    else
        echo -e "  ${YELLOW}  ! Model shanebrain-3b not found${RESET}"
    fi

    echo ""
    echo "  ──────────────────────────────────────────────────────────"
    echo ""
}

# ============================================================
# PROGRESS
# ============================================================
init_progress() {
    if [ ! -f "$PROGRESS_FILE" ]; then
        mkdir -p "$(dirname "$PROGRESS_FILE")"
        cat > "$PROGRESS_FILE" <<'PEOF'
{
  "user": "shanebrain",
  "started": "",
  "modules_completed": [],
  "current_module": "1.1"
}
PEOF
        # Stamp the start time
        local now
        now=$(date -Iseconds)
        sed -i "s/\"started\": \"\"/\"started\": \"$now\"/" "$PROGRESS_FILE"
    fi
}

check_complete() {
    # Returns 0 if module is in completed list
    grep -q "\"$1\"" "$PROGRESS_FILE" 2>/dev/null && return 0 || return 1
}

mark_icon() {
    if check_complete "$1"; then
        echo "[+]"
    else
        echo "[ ]"
    fi
}

# ============================================================
# MODULE RUNNER
# ============================================================
run_module() {
    local mod_id="$1"
    local mod_dir="$2"
    local mod_title="$3"

    clear
    echo ""
    echo "  ======================================================"
    echo "   MODULE $mod_id: $mod_title"
    echo "  ======================================================"
    echo ""

    # Show lesson
    if [ -f "$mod_dir/lesson.md" ]; then
        cat "$mod_dir/lesson.md"
    else
        echo -e "  ${RED}  Module not yet built. Check back soon.${RESET}"
        read -rp "  Press Enter to go back..."
        return
    fi

    echo ""
    echo "  ======================================================"
    echo ""

    while true; do
        read -rp "  [E]xercise  [H]ints  [V]erify  [B]ack: " action
        case "${action,,}" in
            e)
                if [ -f "$mod_dir/exercise.sh" ]; then
                    bash "$mod_dir/exercise.sh"
                elif [ -f "$mod_dir/exercise.bat" ]; then
                    echo -e "  ${YELLOW}  Running .bat exercise via compatibility layer...${RESET}"
                    bash "$RUN_MODULE" "$mod_dir/exercise.bat"
                else
                    echo -e "  ${RED}  Exercise not found.${RESET}"
                fi
                ;;
            h)
                if [ -f "$mod_dir/hints.md" ]; then
                    cat "$mod_dir/hints.md"
                else
                    echo -e "  ${YELLOW}  No hints available for this module.${RESET}"
                fi
                ;;
            v)
                local exit_code=0
                if [ -f "$mod_dir/verify.sh" ]; then
                    bash "$mod_dir/verify.sh" || exit_code=$?
                elif [ -f "$mod_dir/verify.bat" ]; then
                    bash "$RUN_MODULE" "$mod_dir/verify.bat" || exit_code=$?
                else
                    echo -e "  ${RED}  Verify script not found.${RESET}"
                    continue
                fi

                if [ "$exit_code" -eq 0 ]; then
                    echo ""
                    echo -e "  ${GREEN}  ============================================${RESET}"
                    echo -e "  ${GREEN}   + MODULE $mod_id COMPLETE — Nice work.     ${RESET}"
                    echo -e "  ${GREEN}  ============================================${RESET}"
                    # Mark complete in progress
                    if ! check_complete "$mod_id"; then
                        python3 -c "
import json
with open('$PROGRESS_FILE') as f: d = json.load(f)
if '$mod_id' not in d['modules_completed']:
    d['modules_completed'].append('$mod_id')
    d['current_module'] = '$mod_id'
with open('$PROGRESS_FILE','w') as f: json.dump(d, f, indent=2)
"
                    fi
                else
                    echo ""
                    echo -e "  ${RED}  x Not quite. Review the hints and try again.${RESET}"
                fi
                ;;
            b)
                return
                ;;
            *)
                echo "  Invalid choice."
                ;;
        esac
    done
}

# ============================================================
# MODULE MAP
# ============================================================
declare -A MODULE_DIRS MODULE_TITLES

MODULE_DIRS[1.1]="phases/phase-1-builders/module-1.1-first-local-llm"
MODULE_DIRS[1.2]="phases/phase-1-builders/module-1.2-vectors"
MODULE_DIRS[1.3]="phases/phase-1-builders/module-1.3-build-your-brain"
MODULE_DIRS[1.4]="phases/phase-1-builders/module-1.4-prompt-engineering"
MODULE_DIRS[1.5]="phases/phase-1-builders/module-1.5-ship-it"
MODULE_DIRS[2.1]="phases/phase-2-operators/module-2.1-load-your-business-brain"
MODULE_DIRS[2.2]="phases/phase-2-operators/module-2.2-instant-answer-desk"
MODULE_DIRS[2.3]="phases/phase-2-operators/module-2.3-draft-it"
MODULE_DIRS[2.4]="phases/phase-2-operators/module-2.4-sort-and-route"
MODULE_DIRS[2.5]="phases/phase-2-operators/module-2.5-paperwork-machine"
MODULE_DIRS[2.6]="phases/phase-2-operators/module-2.6-chain-reactions"
MODULE_DIRS[2.7]="phases/phase-2-operators/module-2.7-operator-dashboard"
MODULE_DIRS[3.1]="phases/phase-3-everyday/module-3.1-your-private-vault"
MODULE_DIRS[3.2]="phases/phase-3-everyday/module-3.2-ask-your-vault"
MODULE_DIRS[3.3]="phases/phase-3-everyday/module-3.3-write-it-right"
MODULE_DIRS[3.4]="phases/phase-3-everyday/module-3.4-lock-it-down"
MODULE_DIRS[3.5]="phases/phase-3-everyday/module-3.5-daily-briefing"
MODULE_DIRS[3.6]="phases/phase-3-everyday/module-3.6-digital-footprint"
MODULE_DIRS[3.7]="phases/phase-3-everyday/module-3.7-family-dashboard"
MODULE_DIRS[4.1]="phases/phase-4-legacy/module-4.1-what-is-a-brain"
MODULE_DIRS[4.2]="phases/phase-4-legacy/module-4.2-feed-your-brain"
MODULE_DIRS[4.3]="phases/phase-4-legacy/module-4.3-talk-to-your-brain"
MODULE_DIRS[4.4]="phases/phase-4-legacy/module-4.4-your-daily-companion"
MODULE_DIRS[4.5]="phases/phase-4-legacy/module-4.5-write-your-story"
MODULE_DIRS[4.6]="phases/phase-4-legacy/module-4.6-guard-your-legacy"
MODULE_DIRS[4.7]="phases/phase-4-legacy/module-4.7-pass-it-on"
MODULE_DIRS[5.1]="phases/phase-5-multipliers/module-5.1-lock-the-gates"
MODULE_DIRS[5.2]="phases/phase-5-multipliers/module-5.2-threat-spotter"
MODULE_DIRS[5.3]="phases/phase-5-multipliers/module-5.3-backup-and-restore"
MODULE_DIRS[5.4]="phases/phase-5-multipliers/module-5.4-teach-the-teacher"
MODULE_DIRS[5.5]="phases/phase-5-multipliers/module-5.5-workshop-in-a-box"
MODULE_DIRS[5.6]="phases/phase-5-multipliers/module-5.6-brain-export"
MODULE_DIRS[5.7]="phases/phase-5-multipliers/module-5.7-family-mesh"
MODULE_DIRS[5.8]="phases/phase-5-multipliers/module-5.8-under-the-hood"
MODULE_DIRS[5.9]="phases/phase-5-multipliers/module-5.9-prompt-chains"
MODULE_DIRS[5.10]="phases/phase-5-multipliers/module-5.10-the-multiplier"

MODULE_TITLES[1.1]="Your First Local LLM"
MODULE_TITLES[1.2]="Vectors Made Simple"
MODULE_TITLES[1.3]="Build Your Brain"
MODULE_TITLES[1.4]="Prompt Engineering"
MODULE_TITLES[1.5]="Ship It"
MODULE_TITLES[2.1]="Load Your Business Brain"
MODULE_TITLES[2.2]="The Instant Answer Desk"
MODULE_TITLES[2.3]="Draft It"
MODULE_TITLES[2.4]="Sort and Route"
MODULE_TITLES[2.5]="Paperwork Machine"
MODULE_TITLES[2.6]="Chain Reactions"
MODULE_TITLES[2.7]="Your Operator Dashboard"
MODULE_TITLES[3.1]="Your Private Vault"
MODULE_TITLES[3.2]="Ask Your Vault"
MODULE_TITLES[3.3]="Write It Right"
MODULE_TITLES[3.4]="Lock It Down"
MODULE_TITLES[3.5]="Daily Briefing"
MODULE_TITLES[3.6]="Digital Footprint"
MODULE_TITLES[3.7]="Family Dashboard"
MODULE_TITLES[4.1]="What Is a Brain?"
MODULE_TITLES[4.2]="Feed Your Brain"
MODULE_TITLES[4.3]="Talk to Your Brain"
MODULE_TITLES[4.4]="Your Daily Companion"
MODULE_TITLES[4.5]="Write Your Story"
MODULE_TITLES[4.6]="Guard Your Legacy"
MODULE_TITLES[4.7]="Pass It On"
MODULE_TITLES[5.1]="Lock the Gates"
MODULE_TITLES[5.2]="Threat Spotter"
MODULE_TITLES[5.3]="Backup and Restore"
MODULE_TITLES[5.4]="Teach the Teacher"
MODULE_TITLES[5.5]="Workshop in a Box"
MODULE_TITLES[5.6]="Brain Export"
MODULE_TITLES[5.7]="Family Mesh"
MODULE_TITLES[5.8]="Under the Hood"
MODULE_TITLES[5.9]="Prompt Chains"
MODULE_TITLES[5.10]="The Multiplier"

# ============================================================
# MAIN MENU
# ============================================================
main_menu() {
    init_progress

    while true; do
        banner
        preflight

        echo "  PHASE 1 — BUILDERS"
        echo "  ─────────────────────────────────────"
        for m in 1.1 1.2 1.3 1.4 1.5; do
            printf "    %s %-5s %-35s\n" "$(mark_icon $m)" "$m" "${MODULE_TITLES[$m]}"
        done
        echo ""

        echo "  PHASE 2 — OPERATORS"
        echo "  ─────────────────────────────────────"
        for m in 2.1 2.2 2.3 2.4 2.5 2.6 2.7; do
            printf "    %s %-5s %-35s\n" "$(mark_icon $m)" "$m" "${MODULE_TITLES[$m]}"
        done
        echo ""

        echo "  PHASE 3 — EVERYDAY [MCP]"
        echo "  ─────────────────────────────────────"
        for m in 3.1 3.2 3.3 3.4 3.5 3.6 3.7; do
            printf "    %s %-5s %-35s\n" "$(mark_icon $m)" "$m" "${MODULE_TITLES[$m]}"
        done
        echo ""

        echo "  PHASE 4 — LEGACY [MCP]"
        echo "  ─────────────────────────────────────"
        for m in 4.1 4.2 4.3 4.4 4.5 4.6 4.7; do
            printf "    %s %-5s %-35s\n" "$(mark_icon $m)" "$m" "${MODULE_TITLES[$m]}"
        done
        echo ""

        echo "  PHASE 5 — MULTIPLIERS [MCP]"
        echo "  ─────────────────────────────────────"
        for m in 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 5.10; do
            printf "    %s %-5s %-35s\n" "$(mark_icon $m)" "$m" "${MODULE_TITLES[$m]}"
        done
        echo ""

        echo "  ─────────────────────────────────────"
        echo "    H  Health Check     R  Reset Progress     Q  Quit"
        echo ""

        read -rp "  Select module (1.1-5.10) or option: " CHOICE

        case "$CHOICE" in
            [Hh])
                bash "$HEALTH_CHECK"
                read -rp "  Press Enter to continue..."
                ;;
            [Rr])
                read -rp "  Reset all progress? Cannot be undone. (y/N): " confirm
                if [[ "${confirm,,}" == "y" ]]; then
                    cat > "$PROGRESS_FILE" <<PEOF
{
  "user": "shanebrain",
  "started": "$(date -Iseconds)",
  "modules_completed": [],
  "current_module": "1.1"
}
PEOF
                    echo -e "  ${GREEN}  Progress reset.${RESET}"
                    sleep 1
                fi
                ;;
            [Qq])
                echo ""
                echo "   Keep building. Your legacy runs local."
                echo ""
                exit 0
                ;;
            *)
                if [[ -n "${MODULE_DIRS[$CHOICE]+x}" ]]; then
                    run_module "$CHOICE" "$BASE_DIR/${MODULE_DIRS[$CHOICE]}" "${MODULE_TITLES[$CHOICE]}"
                else
                    echo -e "  ${RED}  Invalid selection. Try again.${RESET}"
                    sleep 1
                fi
                ;;
        esac
    done
}

main_menu
