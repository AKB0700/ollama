#!/usr/bin/env bash
# Test script for gh-agent-task extension

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GH_AGENT_TASK="${SCRIPT_DIR}/gh-agent-task"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Testing gh-agent-task extension..."
echo ""

# Test 1: Help command
echo -e "${YELLOW}Test 1: Help command${NC}"
"$GH_AGENT_TASK" --help
echo -e "${GREEN}✓ Help command passed${NC}"
echo ""

# Test 2: Version command
echo -e "${YELLOW}Test 2: Version command${NC}"
"$GH_AGENT_TASK" version
echo -e "${GREEN}✓ Version command passed${NC}"
echo ""

# Test 3: View command (basic)
echo -e "${YELLOW}Test 3: View command (basic)${NC}"
"$GH_AGENT_TASK" view dd1fee47-abb8-4a9c-b18e-60b512427f5f
echo -e "${GREEN}✓ View command passed${NC}"
echo ""

# Test 4: View command with logs
echo -e "${YELLOW}Test 4: View command with logs${NC}"
"$GH_AGENT_TASK" view dd1fee47-abb8-4a9c-b18e-60b512427f5f --log
echo -e "${GREEN}✓ View command with logs passed${NC}"
echo ""

# Test 5: View command with JSON output
echo -e "${YELLOW}Test 5: View command with JSON output${NC}"
OUTPUT=$("$GH_AGENT_TASK" view dd1fee47-abb8-4a9c-b18e-60b512427f5f --json)
if echo "$OUTPUT" | jq . > /dev/null 2>&1; then
    echo -e "${GREEN}✓ JSON output is valid${NC}"
else
    echo -e "${RED}✗ JSON output is invalid${NC}"
    exit 1
fi
echo ""

# Test 6: List command
echo -e "${YELLOW}Test 6: List command${NC}"
"$GH_AGENT_TASK" list
echo -e "${GREEN}✓ List command passed${NC}"
echo ""

# Test 7: Logs command
echo -e "${YELLOW}Test 7: Logs command${NC}"
"$GH_AGENT_TASK" logs dd1fee47-abb8-4a9c-b18e-60b512427f5f
echo -e "${GREEN}✓ Logs command passed${NC}"
echo ""

# Test 8: Invalid UUID
echo -e "${YELLOW}Test 8: Invalid UUID (should fail)${NC}"
if "$GH_AGENT_TASK" view invalid-uuid 2>&1 | grep -q "Invalid UUID format"; then
    echo -e "${GREEN}✓ Invalid UUID correctly rejected${NC}"
else
    echo -e "${RED}✗ Invalid UUID not handled correctly${NC}"
    exit 1
fi
echo ""

# Test 9: View help
echo -e "${YELLOW}Test 9: View command help${NC}"
"$GH_AGENT_TASK" view --help
echo -e "${GREEN}✓ View help passed${NC}"
echo ""

echo -e "${GREEN}All tests passed!${NC}"
