#!/bin/bash
set -euo pipefail

################################################################################
# Impact Analysis Calibration Tests
# Purpose: Verify correct impact classification for various change scenarios
# Version: 1.0.0 (2025-12-23)
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/change_detection.sh"

# Test results
PASS_COUNT=0
FAIL_COUNT=0

# ANSI colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${YELLOW}=== $1 ===${NC}"
}

test_scenario() {
    local name="$1"
    local files="$2"
    local expected_impact="$3"
    local expected_change_type="${4:-}"
    
    # Comprehensive git mock
    git() {
        case "$*" in
            "diff --name-only HEAD")
                echo "$files"
                ;;
            "diff --cached --name-only")
                echo ""
                ;;
            "ls-files --others --exclude-standard")
                echo ""
                ;;
            *)
                # Fallback for unexpected git calls
                return 0
                ;;
        esac
    }
    export -f git
    
    local change_type=$(detect_change_type)
    local impact=$(assess_change_impact)
    
    # Check impact
    if [[ "$impact" == "$expected_impact" ]]; then
        # Check change_type if provided
        if [[ -n "$expected_change_type" ]] && [[ "$change_type" != "$expected_change_type" ]]; then
            echo -e "${RED}✗ FAIL${NC}: $name"
            echo "  Expected impact: $expected_impact (actual: $impact) ✓"
            echo "  Expected change_type: $expected_change_type (actual: $change_type) ✗"
            ((FAIL_COUNT++))
        else
            echo -e "${GREEN}✓ PASS${NC}: $name → impact=$impact, change_type=$change_type"
            ((PASS_COUNT++))
        fi
    else
        echo -e "${RED}✗ FAIL${NC}: $name"
        echo "  Expected impact: $expected_impact (actual: $impact)"
        echo "  Change type: $change_type"
        ((FAIL_COUNT++))
    fi
    
    unset -f git
}

# ==============================================================================
# TEST SUITE
# ==============================================================================

print_header "Documentation-Only Changes"
test_scenario "5 docs only" "$(printf 'docs/file%d.md\n' {1..5})" "low" "docs-only"
test_scenario "35 docs only" "$(printf 'docs/file%d.md\n' {1..35})" "low" "docs-only"
test_scenario "50 docs (threshold)" "$(printf 'docs/file%d.md\n' {1..50})" "low" "docs-only"
test_scenario "51 docs (over threshold)" "$(printf 'docs/file%d.md\n' {1..51})" "medium" "docs-only"
test_scenario "100 docs (high volume)" "$(printf 'docs/file%d.md\n' {1..100})" "medium" "docs-only"

echo

print_header "Code-Only Changes"
test_scenario "1 code file" "src/main.js" "medium" "code-only"
test_scenario "2 code files" "$(printf 'src/file%d.js\n' {1..2})" "medium" "code-only"
test_scenario "5 code files (threshold)" "$(printf 'src/file%d.js\n' {1..5})" "medium" "code-only"
test_scenario "6 code files (over threshold)" "$(printf 'src/file%d.js\n' {1..6})" "high" "code-only"
test_scenario "10 code files" "$(printf 'src/file%d.js\n' {1..10})" "high" "code-only"

echo

print_header "Mixed Changes (Code + Docs)"
test_scenario "1 code + 5 docs" "$(echo 'src/app.js'; printf 'docs/file%d.md\n' {1..5})" "medium" "mixed"
test_scenario "2 code + 35 docs (reported bug)" "$(printf 'docs/file%d.md\n' {1..35}; printf 'src/app%d.js\n' {1..2})" "medium" "mixed"
test_scenario "5 code + 50 docs" "$(printf 'docs/file%d.md\n' {1..50}; printf 'src/app%d.js\n' {1..5})" "medium" "mixed"
test_scenario "6 code + 50 docs (over code threshold)" "$(printf 'docs/file%d.md\n' {1..50}; printf 'src/app%d.js\n' {1..6})" "high" "mixed"

echo

print_header "Test-Only Changes"
test_scenario "5 test files" "$(printf 'test%d.js\n' {1..5})" "low" "tests-only"
test_scenario "10 test files (threshold)" "$(printf 'test%d.js\n' {1..10})" "low" "tests-only"
test_scenario "11 test files (over threshold)" "$(printf 'test%d.js\n' {1..11})" "medium" "tests-only"
test_scenario "20 test files" "$(printf 'test%d.js\n' {1..20})" "medium" "tests-only"

echo

print_header "Script-Only Changes"
test_scenario "3 shell scripts" "$(printf 'scripts/script%d.sh\n' {1..3})" "low" "scripts-only"
test_scenario "10 shell scripts (threshold)" "$(printf 'scripts/script%d.sh\n' {1..10})" "low" "scripts-only"
test_scenario "15 shell scripts (over threshold)" "$(printf 'scripts/script%d.sh\n' {1..15})" "medium" "scripts-only"

echo

print_header "Configuration-Only Changes"
test_scenario "5 config files" "$(printf 'config%d.json\n' {1..5})" "low" "config-only"
test_scenario "10 config files" "$(printf 'config%d.json\n' {1..10})" "low" "config-only"

echo

print_header "Full-Stack Changes"
test_scenario "Code + Tests + Docs + Config" "$(echo 'src/app.js'; echo 'test.js'; echo 'docs/README.md'; echo 'config.json')" "high" "full-stack"

echo

# ==============================================================================
# SUMMARY
# ==============================================================================

print_header "Test Results Summary"
TOTAL=$((PASS_COUNT + FAIL_COUNT))
echo "Total tests: $TOTAL"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
