#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Unit Tests for Parallel Documentation Analysis
# Purpose: Test file categorization and parallel processing setup
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR=$(mktemp -d)

# Mock functions
print_info() { echo "[INFO] $*"; }
print_success() { echo "[OK] $*"; }
print_error() { echo "[ERROR] $*"; }

# Source the module
export WORKFLOW_HOME="$TEST_DIR"
export DOC_PARALLEL_THRESHOLD=3
export DOC_MAX_PARALLEL_JOBS=4
source "${SCRIPT_DIR}/ai_integration.sh"

# Test counters
PASSED=0
FAILED=0

test_result() {
    local name="$1"
    local result="$2"
    if [[ "$result" == "PASS" ]]; then
        echo "✅ $name"
        ((PASSED++))
    else
        echo "❌ $name"
        ((FAILED++))
    fi
}

cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

echo "Testing Parallel Documentation Analysis Functions"
echo ""

# Test 1: Categorize architecture doc
cd "$TEST_DIR"
echo "# Test" > "architecture-design.md"
category=$(categorize_doc_file "architecture-design.md")
if [[ "$category" == "architecture" ]]; then
    test_result "Test 1: Categorize architecture doc" "PASS"
else
    test_result "Test 1: Categorize architecture doc (got: $category)" "FAIL"
fi

# Test 2: Categorize reference doc
echo "# API" > "api-reference.md"
category=$(categorize_doc_file "api-reference.md")
if [[ "$category" == "reference" ]]; then
    test_result "Test 2: Categorize reference doc" "PASS"
else
    test_result "Test 2: Categorize reference doc (got: $category)" "FAIL"
fi

# Test 3: Categorize guide doc
echo "# Guide" > "getting-started.md"
category=$(categorize_doc_file "getting-started.md")
if [[ "$category" == "guides" ]]; then
    test_result "Test 3: Categorize guide doc" "PASS"
else
    test_result "Test 3: Categorize guide doc (got: $category)" "FAIL"
fi

# Test 4: Categorize README (root)
echo "# README" > "README.md"
category=$(categorize_doc_file "README.md")
if [[ "$category" == "root" ]]; then
    test_result "Test 4: Categorize README (root)" "PASS"
else
    test_result "Test 4: Categorize README (got: $category)" "FAIL"
fi

# Test 5: Categorize example doc
echo "# Example" > "example-usage.md"
category=$(categorize_doc_file "example-usage.md")
if [[ "$category" == "examples" ]]; then
    test_result "Test 5: Categorize example doc" "PASS"
else
    test_result "Test 5: Categorize example doc (got: $category)" "FAIL"
fi

# Test 6: Categorize other doc
echo "# Other" > "random-doc.md"
category=$(categorize_doc_file "random-doc.md")
if [[ "$category" == "other" ]]; then
    test_result "Test 6: Categorize other/unknown doc" "PASS"
else
    test_result "Test 6: Categorize other/unknown doc (got: $category)" "FAIL"
fi

# Test 7: Categorize multiple docs
stats=$(categorize_docs "README.md" "api-reference.md" "getting-started.md" "random-doc.md")
if echo "$stats" | grep -q "root" && echo "$stats" | grep -q "reference"; then
    test_result "Test 7: Categorize multiple docs (JSON output)" "PASS"
else
    test_result "Test 7: Categorize multiple docs (invalid JSON: $stats)" "FAIL"
fi

echo ""
echo "================================================"
echo "Test Summary"
echo "================================================"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo "✅ All categorization tests passed!"
    exit 0
else
    echo "❌ Some tests failed"
    exit 1
fi
