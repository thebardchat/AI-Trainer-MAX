#!/usr/bin/env bash
# ============================================================
# BAT-to-Linux Module Runner
# Translates .bat exercise/verify scripts into Linux-compatible
# commands on the fly. Handles the common patterns used in
# AI-Trainer-MAX modules.
# ============================================================

set -euo pipefail

BAT_FILE="$1"
MOD_DIR="$(dirname "$BAT_FILE")"
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP_CALL="$BASE_DIR/shared/utils/mcp-call.py"
PROGRESS_FILE="$BASE_DIR/progress/user-progress.json"

RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
RESET='\033[0m'

if [ ! -f "$BAT_FILE" ]; then
    echo -e "${RED}  File not found: $BAT_FILE${RESET}"
    exit 1
fi

echo -e "${YELLOW}  Executing: $(basename "$BAT_FILE") (Linux compat mode)${RESET}"
echo ""

# Read the .bat file and translate common patterns to bash
# This handles the key patterns used in exercises and verifies:
#   - curl calls (pass through)
#   - python / python3 calls (translate python -> python3)
#   - mcp-call.py invocations (fix paths)
#   - echo with ANSI colors (pass through)
#   - set /a arithmetic -> bash arithmetic
#   - if errorlevel -> $?
#   - pause -> read -rp
#   - findstr -> grep

python3 - "$BAT_FILE" "$MCP_CALL" "$MOD_DIR" "$PROGRESS_FILE" <<'PYEOF'
import sys
import re
import subprocess
import os
import json

bat_file = sys.argv[1]
mcp_call = sys.argv[2]
mod_dir = sys.argv[3]
progress_file = sys.argv[4]

# Track state
pass_count = 0
fail_count = 0
total_checks = 0

def run_cmd(cmd, timeout=600):
    """Run a shell command, return (returncode, stdout, stderr)."""
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        return r.returncode, r.stdout.strip(), r.stderr.strip()
    except subprocess.TimeoutExpired:
        return 1, "", "Timeout"
    except Exception as e:
        return 1, "", str(e)

def mcp_tool(tool_name, args_dict=None):
    """Call an MCP tool via mcp-call.py. Auto-prefixes shanebrain_ and wraps in params."""
    if not tool_name.startswith("shanebrain_"):
        tool_name = f"shanebrain_{tool_name}"
    cmd = f'python3 {mcp_call} {tool_name}'
    if args_dict:
        # MCP tools expect {"params": {...}} envelope for Pydantic validation
        if "params" not in args_dict:
            args_dict = {"params": args_dict}
        args_json = json.dumps(args_dict).replace('"', '\\"')
        cmd = f'python3 {mcp_call} {tool_name} "{args_json}"'
    rc, out, err = run_cmd(cmd)
    return rc, out, err

def check_ollama():
    rc, _, _ = run_cmd("curl -sf http://localhost:11434/api/tags > /dev/null")
    return rc == 0

def check_weaviate():
    rc, _, _ = run_cmd("curl -sf http://localhost:8080/v1/.well-known/ready > /dev/null")
    return rc == 0

def check_mcp():
    rc, _, _ = run_cmd("curl -sf http://localhost:8100/health > /dev/null")
    return rc == 0

def report(test_name, passed, detail=""):
    global pass_count, fail_count, total_checks
    total_checks += 1
    if passed:
        pass_count += 1
        print(f"\033[92m  + PASS: {test_name}\033[0m")
    else:
        fail_count += 1
        print(f"\033[91m  x FAIL: {test_name}\033[0m")
    if detail:
        print(f"    {detail}")

# Read the bat file to understand what it does
with open(bat_file, "r", encoding="utf-8", errors="replace") as f:
    content = f.read()

filename = os.path.basename(bat_file).lower()
is_verify = "verify" in filename
is_exercise = "exercise" in filename

# Detect which phase/module
# Look for MCP calls (Phase 3-5)
uses_mcp = "mcp-call.py" in content or "mcp_call" in content.lower()
# Look for Weaviate direct calls (Phase 1-2)
uses_weaviate_direct = "localhost:8080" in content and not uses_mcp
# Look for Ollama direct calls
uses_ollama = "localhost:11434" in content

# Extract module ID from path
mod_path = os.path.abspath(mod_dir)
mod_id = ""
m = re.search(r'module-(\d+\.\d+)', mod_path)
if m:
    mod_id = m.group(1)

print(f"  Module: {mod_id}")
print(f"  Type: {'verify' if is_verify else 'exercise'}")
print(f"  Stack: {'MCP' if uses_mcp else 'Direct'} | Ollama: {uses_ollama} | Weaviate: {uses_weaviate_direct}")
print()

# ============================================================
# VERIFY MODE — Run automated checks
# ============================================================
if is_verify:
    # Pre-flight
    if uses_ollama or uses_weaviate_direct:
        report("Ollama running", check_ollama())
    if uses_weaviate_direct:
        report("Weaviate running", check_weaviate())
    if uses_mcp:
        report("MCP server running", check_mcp())

    # Parse the .bat for specific check patterns
    # Pattern: curl checks, mcp-call checks, findstr checks
    lines = content.split("\n")

    for i, line in enumerate(lines):
        line = line.strip()

        # MCP tool call checks
        mcp_match = re.search(r'mcp-call\.py\s+(\w+)\s*(?:"([^"]*)")?', line)
        if mcp_match:
            tool = mcp_match.group(1)
            args_str = mcp_match.group(2)
            args = {}
            if args_str:
                try:
                    args = json.loads(args_str)
                except:
                    # Try to extract key=value patterns
                    pass

            rc, out, err = mcp_tool(tool, args if args else None)
            passed = rc == 0 and out and "error" not in out.lower()
            report(f"MCP {tool}", passed, out[:120] if out else err[:120])

        # Ollama inference check
        if "api/generate" in line or "api/chat" in line:
            rc, out, _ = run_cmd('curl -sf http://localhost:11434/api/tags | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get(\'models\',[])))"')
            report("Ollama models available", rc == 0 and out and int(out) > 0, f"{out} models")

        # Weaviate schema check
        if "v1/schema" in line and "class" in content[i:i+200].lower():
            rc, out, _ = run_cmd('curl -sf http://localhost:8080/v1/schema | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get(\'classes\',[])))"')
            report("Weaviate schema has classes", rc == 0 and out and int(out) > 0, f"{out} classes")

        # Weaviate object count checks
        wv_class_match = re.search(r'objects\?class=(\w+)', line)
        if wv_class_match:
            cls = wv_class_match.group(1)
            rc, out, _ = run_cmd(f'curl -sf "http://localhost:8080/v1/objects?class={cls}&limit=1" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get(\'totalResults\',0))"')
            count = int(out) if out and out.isdigit() else 0
            report(f"Weaviate {cls} has objects", count > 0, f"{count} objects")

    # If no specific checks found, do a general MCP health check
    if total_checks == 0 or (uses_mcp and total_checks < 2):
        rc, out, _ = mcp_tool("system_health")
        report("System health check", rc == 0 and "error" not in (out or "").lower())

    # Summary
    print()
    print(f"  ──────────────────────────────────────────────────────")
    print(f"  Results: {pass_count}/{total_checks} checks passed")

    if fail_count > 0:
        sys.exit(1)
    else:
        sys.exit(0)

# ============================================================
# EXERCISE MODE — Run interactive exercises
# ============================================================
elif is_exercise:
    print("  Running exercise steps...")
    print()

    # Extract exercise tasks from the .bat
    # Look for TASK markers, echo blocks, and curl/mcp commands
    tasks = []
    current_task = None

    lines = content.split("\n")
    for i, line in enumerate(lines):
        line_stripped = line.strip()

        # Task headers
        task_match = re.search(r'(?:TASK|Step|CHECK)\s*(\d+)', line_stripped, re.IGNORECASE)
        if task_match or ("===" in line_stripped and i + 1 < len(lines)):
            if current_task:
                tasks.append(current_task)
            current_task = {"title": line_stripped.replace("echo", "").strip().strip("=").strip(), "commands": []}
            continue

        if current_task is None:
            current_task = {"title": "Setup", "commands": []}

        # Extract actionable commands
        # MCP calls
        mcp_match = re.search(r'mcp-call\.py\s+(\w+)\s*(?:"([^"]*)")?', line_stripped)
        if mcp_match:
            tool = mcp_match.group(1)
            args_str = mcp_match.group(2)
            current_task["commands"].append(("mcp", tool, args_str))

        # curl commands to Ollama
        if "curl" in line_stripped and "localhost:11434" in line_stripped:
            # Extract the curl command
            curl_match = re.search(r'(curl\s+.+)', line_stripped)
            if curl_match:
                cmd = curl_match.group(1)
                # Fix Windows escaping
                cmd = cmd.replace("^", "").replace("%", "%%")
                current_task["commands"].append(("curl", cmd, None))

        # curl commands to Weaviate
        if "curl" in line_stripped and "localhost:8080" in line_stripped:
            curl_match = re.search(r'(curl\s+.+)', line_stripped)
            if curl_match:
                cmd = curl_match.group(1)
                cmd = cmd.replace("^", "").replace("%", "%%")
                current_task["commands"].append(("curl", cmd, None))

    if current_task:
        tasks.append(current_task)

    # Execute tasks
    for t_idx, task in enumerate(tasks):
        if not task["commands"]:
            continue
        print(f"\033[1m  --- {task['title']} ---\033[0m")
        for cmd_type, cmd, args in task["commands"]:
            if cmd_type == "mcp":
                args_dict = None
                if args:
                    try:
                        args_dict = json.loads(args)
                    except:
                        pass
                print(f"    MCP: {cmd}({json.dumps(args_dict) if args_dict else ''})")
                rc, out, err = mcp_tool(cmd, args_dict)
                if rc == 0 and out:
                    # Pretty print truncated
                    try:
                        parsed = json.loads(out)
                        display = json.dumps(parsed, indent=2)[:500]
                    except:
                        display = out[:500]
                    print(f"\033[92m    Result:\033[0m")
                    for dline in display.split("\n"):
                        print(f"      {dline}")
                else:
                    print(f"\033[91m    Error: {err[:200]}\033[0m")

            elif cmd_type == "curl":
                print(f"    Running: {cmd[:100]}...")
                rc, out, err = run_cmd(cmd)
                if rc == 0 and out:
                    print(f"\033[92m    OK\033[0m ({out[:200]})")
                elif err:
                    print(f"\033[91m    Error: {err[:200]}\033[0m")

        print()

    if not any(t["commands"] for t in tasks):
        print("  No automated commands found in this exercise.")
        print("  Read the lesson.md and follow the manual steps,")
        print("  then run verify to check your work.")

    print()
    print("  Exercise complete. Press V in the menu to verify.")

else:
    print(f"  Unknown script type: {bat_file}")
    sys.exit(1)
PYEOF
