#!/usr/bin/env bash
# Demo script for gh-agent-task extension
# This script demonstrates all features of the extension

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GH_AGENT_TASK="${SCRIPT_DIR}/gh-agent-task"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TASK_ID="dd1fee47-abb8-4a9c-b18e-60b512427f5f"

header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

prompt() {
    echo -e "${YELLOW}$ $1${NC}"
    sleep 1
}

section() {
    echo ""
    echo -e "${BLUE}▶ $1${NC}"
    echo ""
}

clear
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║              gh-agent-task Extension Demo                  ║
║                                                            ║
║          GitHub CLI Extension for Agent Tasks              ║
║                    Version 0.1.0                           ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

EOF

sleep 2

header "1. Getting Help"
section "Display main help"
prompt "gh agent-task --help"
"$GH_AGENT_TASK" --help
echo ""
read -p "Press Enter to continue..."

header "2. Version Information"
section "Check extension version"
prompt "gh agent-task version"
"$GH_AGENT_TASK" version
echo ""
read -p "Press Enter to continue..."

header "3. View Task (Basic)"
section "View task details without logs"
prompt "gh agent-task view $TASK_ID"
"$GH_AGENT_TASK" view "$TASK_ID"
echo ""
read -p "Press Enter to continue..."

header "4. View Task with Logs"
section "View task details with execution logs"
prompt "gh agent-task view $TASK_ID --log"
"$GH_AGENT_TASK" view "$TASK_ID" --log
echo ""
read -p "Press Enter to continue..."

header "5. JSON Output"
section "View task in JSON format"
prompt "gh agent-task view $TASK_ID --json | jq ."
"$GH_AGENT_TASK" view "$TASK_ID" --json | jq .
echo ""
read -p "Press Enter to continue..."

header "6. List All Tasks"
section "List recent agent tasks"
prompt "gh agent-task list"
"$GH_AGENT_TASK" list
echo ""
read -p "Press Enter to continue..."

header "7. View Logs Only"
section "View just the execution logs"
prompt "gh agent-task logs $TASK_ID"
"$GH_AGENT_TASK" logs "$TASK_ID"
echo ""
read -p "Press Enter to continue..."

header "8. Command-Specific Help"
section "Get help for the view command"
prompt "gh agent-task view --help"
"$GH_AGENT_TASK" view --help
echo ""
read -p "Press Enter to continue..."

header "9. Error Handling"
section "Test with invalid UUID (this should fail gracefully)"
prompt "gh agent-task view invalid-uuid-format"
"$GH_AGENT_TASK" view invalid-uuid-format 2>&1 || true
echo ""
read -p "Press Enter to continue..."

clear
cat << "EOF"

╔════════════════════════════════════════════════════════════╗
║                                                            ║
║                     Demo Complete! ✓                       ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

EOF

echo -e "${GREEN}Summary of Demonstrated Features:${NC}"
echo ""
echo "  ✓ Help system with examples"
echo "  ✓ Version information"
echo "  ✓ View task details"
echo "  ✓ View task with logs"
echo "  ✓ JSON output for automation"
echo "  ✓ List all tasks"
echo "  ✓ View logs only"
echo "  ✓ Command-specific help"
echo "  ✓ Error handling"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "  1. Install: gh extension install /path/to/gh-agent-task"
echo "  2. Read: README.md for usage guide"
echo "  3. Read: IMPLEMENTATION.md for integration guide"
echo "  4. Run: ./test.sh to verify all tests pass"
echo ""
echo -e "${YELLOW}To integrate with real data:${NC}"
echo ""
echo "  • GitHub Actions: Follow examples/README.md"
echo "  • GitHub Issues:  See IMPLEMENTATION.md Option 2"
echo "  • Custom API:     See IMPLEMENTATION.md Option 4"
echo ""
echo -e "${GREEN}Thank you for trying gh-agent-task!${NC}"
echo ""
