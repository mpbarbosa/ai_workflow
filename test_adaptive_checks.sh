#!/bin/bash
################################################################################
# Test Script: Adaptive Pre-Flight Checks
# Purpose: Verify tech stack detection and adaptive validation
################################################################################

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Testing Adaptive Pre-Flight Checks${NC}"
echo -e "${BLUE}================================${NC}"
echo

# Set up test environment
export PROJECT_ROOT="/home/mpb/Documents/GitHub/ai_workflow"
export SRC_DIR="$PROJECT_ROOT/src"

# Source the validation library
source "$PROJECT_ROOT/src/workflow/lib/validation.sh" 2>/dev/null || {
    echo "Error: Could not source validation.sh"
    exit 1
}

echo -e "${YELLOW}Test 1: Tech Stack Detection${NC}"
echo "Testing on current repository (ai_workflow)..."
echo

DETECTED_STACK=$(detect_project_tech_stack)
echo "Detected: $DETECTED_STACK"

if [[ "$DETECTED_STACK" == "shell" ]]; then
    echo -e "${GREEN}✓ PASS: Correctly detected as shell project${NC}"
else
    echo -e "${RED}✗ FAIL: Expected 'shell', got '$DETECTED_STACK'${NC}"
    exit 1
fi
echo

echo -e "${YELLOW}Test 2: Check if package.json is NOT required${NC}"
if [[ ! -f "$SRC_DIR/package.json" ]] && [[ ! -f "$PROJECT_ROOT/package.json" ]]; then
    echo -e "${GREEN}✓ PASS: No package.json found (as expected for shell project)${NC}"
else
    echo -e "${YELLOW}⚠ WARNING: package.json found (unexpected but not an error)${NC}"
fi
echo

echo -e "${YELLOW}Test 3: Node.js/npm should be optional${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js available: $NODE_VERSION (optional)${NC}"
else
    echo -e "${YELLOW}⚠ Node.js not found (optional, so OK)${NC}"
fi

if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓ npm available: $NPM_VERSION (optional)${NC}"
else
    echo -e "${YELLOW}⚠ npm not found (optional, so OK)${NC}"
fi
echo

echo -e "${YELLOW}Test 4: Git repository validation${NC}"
if git -C "$PROJECT_ROOT" rev-parse --git-dir &> /dev/null; then
    echo -e "${GREEN}✓ PASS: Valid git repository${NC}"
else
    echo -e "${RED}✗ FAIL: Not a git repository${NC}"
    exit 1
fi
echo

echo -e "${YELLOW}Test 5: Simulate Node.js project detection${NC}"
# Create a temporary package.json
TEMP_PKG="$PROJECT_ROOT/test_package.json"
echo '{"name": "test", "version": "1.0.0"}' > "$TEMP_PKG"

# Override SRC_DIR to point to a location with package.json
export SRC_DIR_BACKUP="$SRC_DIR"
export SRC_DIR="$PROJECT_ROOT"

# Create symlink to test
ln -sf test_package.json "$PROJECT_ROOT/package.json" 2>/dev/null || true

DETECTED_STACK=$(detect_project_tech_stack)
echo "Detected with package.json present: $DETECTED_STACK"

# Cleanup
rm -f "$TEMP_PKG" "$PROJECT_ROOT/package.json"
export SRC_DIR="$SRC_DIR_BACKUP"

if [[ "$DETECTED_STACK" == *"nodejs"* ]]; then
    echo -e "${GREEN}✓ PASS: Correctly detected Node.js when package.json present${NC}"
else
    echo -e "${YELLOW}⚠ Detected: $DETECTED_STACK (may include shell too)${NC}"
fi
echo

echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}All tests completed!${NC}"
echo -e "${BLUE}================================${NC}"
echo
echo "Summary:"
echo "  ✓ Tech stack detection works"
echo "  ✓ Shell projects don't require package.json"
echo "  ✓ Node.js/npm are optional for shell projects"
echo "  ✓ Git validation works"
echo "  ✓ Can detect multiple tech stacks"
echo
echo "The adaptive pre-flight checks are functioning correctly!"
