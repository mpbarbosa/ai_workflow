#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Suite for Step 1 File Operations Module
# Purpose: Unit tests for file_operations.sh functionality
# Version: 1.0.0
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEP1_LIB_DIR="${TEST_DIR}/../../src/workflow/steps/step_01_lib"

# Create temp directory for tests
TEST_TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_TEMP_DIR"' EXIT

# Set up test environment
export PROJECT_ROOT="$TEST_TEMP_DIR/project"
mkdir -p "$PROJECT_ROOT"/{docs,src/workflow,.github}

# Source the module
if [[ ! -f "${STEP1_LIB_DIR}/file_operations.sh" ]]; then
    echo "ERROR: File operations module not found"
    exit 1
fi

source "${STEP1_LIB_DIR}/file_operations.sh"

# Test helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    if [[ "$expected" == "$actual" ]]; then
        pass "$message"
    else
        fail "$message (expected: '$expected', got: '$actual')"
    fi
}

# Test Suite
echo "========================================"
echo "Step 1 File Operations Module Tests"
echo "========================================"
echo ""

# Test 1: Module loads
if [[ "${STEP1_FILE_OPS_MODULE_LOADED:-}" == "true" ]]; then
    pass "Module loads successfully"
else
    fail "Module failed to load"
fi

# Test 2: Batch file check - all exist
touch "$PROJECT_ROOT/file1.txt" "$PROJECT_ROOT/file2.txt"
missing=$(batch_file_check_step1 "$PROJECT_ROOT/file1.txt" "$PROJECT_ROOT/file2.txt")
if [[ -z "$missing" ]]; then
    pass "batch_file_check finds all existing files"
else
    fail "batch_file_check reported missing files when all exist"
fi

# Test 3: Batch file check - some missing
missing=$(batch_file_check_step1 "$PROJECT_ROOT/file1.txt" "$PROJECT_ROOT/missing.txt")
if echo "$missing" | grep -q "missing.txt"; then
    pass "batch_file_check detects missing files"
else
    fail "batch_file_check failed to detect missing file"
fi

# Test 4: Optimized multi grep
echo "error: something failed" > "$PROJECT_ROOT/test.log"
echo "warning: check this" >> "$PROJECT_ROOT/test.log"
echo "info: normal operation" >> "$PROJECT_ROOT/test.log"

result=$(optimized_multi_grep_step1 "$PROJECT_ROOT/test.log" "error" "warning")
if echo "$result" | grep -q "error" && echo "$result" | grep -q "warning"; then
    pass "optimized_multi_grep finds multiple patterns"
else
    fail "optimized_multi_grep failed to find patterns"
fi

# Test 5: Optimized multi grep - no matches
result=$(optimized_multi_grep_step1 "$PROJECT_ROOT/test.log" "nonexistent")
if [[ -z "$result" ]]; then
    pass "optimized_multi_grep returns empty for no matches"
else
    fail "optimized_multi_grep should return empty"
fi

# Test 6: Determine doc folder - docs path
folder=$(determine_doc_folder_step1 "docs/api/README.md")
assert_equals "$PROJECT_ROOT/docs" "$folder" "determine_doc_folder handles docs/ path"

# Test 7: Determine doc folder - src/workflow path
folder=$(determine_doc_folder_step1 "src/workflow/lib/module.sh")
assert_equals "$PROJECT_ROOT/src/workflow" "$folder" "determine_doc_folder handles src/workflow/ path"

# Test 8: Determine doc folder - src path
folder=$(determine_doc_folder_step1 "src/utils/helper.js")
assert_equals "$PROJECT_ROOT/src" "$folder" "determine_doc_folder handles src/ path"

# Test 9: Determine doc folder - README.md
folder=$(determine_doc_folder_step1 "README.md")
assert_equals "$PROJECT_ROOT" "$folder" "determine_doc_folder handles README.md"

# Test 10: Determine doc folder - .github path
folder=$(determine_doc_folder_step1 ".github/workflows/ci.yml")
assert_equals "$PROJECT_ROOT" "$folder" "determine_doc_folder handles .github/ path"

# Test 11: Determine doc folder - unknown path (defaults to docs)
folder=$(determine_doc_folder_step1 "random/file.txt")
assert_equals "$PROJECT_ROOT/docs" "$folder" "determine_doc_folder defaults to docs/ for unknown"

# Test 12: Save AI generated docs - simple case
echo "AI generated content" > "$TEST_TEMP_DIR/ai_output.md"
if save_ai_generated_docs_step1 "$TEST_TEMP_DIR/ai_output.md" "docs/new_doc.md"; then
    if [[ -f "$PROJECT_ROOT/docs/new_doc.md" ]]; then
        content=$(cat "$PROJECT_ROOT/docs/new_doc.md")
        assert_equals "AI generated content" "$content" "save_ai_generated_docs saves content correctly"
    else
        fail "save_ai_generated_docs failed to create file"
    fi
else
    fail "save_ai_generated_docs returned error"
fi

# Test 13: Save AI docs - absolute path
if save_ai_generated_docs_step1 "$TEST_TEMP_DIR/ai_output.md" "$PROJECT_ROOT/absolute_test.md"; then
    if [[ -f "$PROJECT_ROOT/absolute_test.md" ]]; then
        pass "save_ai_generated_docs handles absolute paths"
    else
        fail "save_ai_generated_docs failed with absolute path"
    fi
else
    fail "save_ai_generated_docs error with absolute path"
fi

# Test 14: Save AI docs - creates subdirectories
if save_ai_generated_docs_step1 "$TEST_TEMP_DIR/ai_output.md" "docs/deep/nested/file.md"; then
    if [[ -f "$PROJECT_ROOT/docs/deep/nested/file.md" ]]; then
        pass "save_ai_generated_docs creates nested directories"
    else
        fail "save_ai_generated_docs failed to create nested dirs"
    fi
else
    fail "save_ai_generated_docs error with nested path"
fi

# Test 15: Save AI docs - missing input file
if save_ai_generated_docs_step1 "/nonexistent/file.md" "docs/test.md" 2>/dev/null; then
    fail "save_ai_generated_docs should fail with missing input"
else
    pass "save_ai_generated_docs correctly fails with missing input"
fi

# Test 16: Backup file
echo "original content" > "$PROJECT_ROOT/backup_test.txt"
if backup_file_step1 "$PROJECT_ROOT/backup_test.txt"; then
    # Check if backup was created
    backup_count=$(find "$PROJECT_ROOT" -name "backup_test.txt.backup.*" | wc -l)
    if [[ $backup_count -eq 1 ]]; then
        pass "backup_file creates backup successfully"
    else
        fail "backup_file didn't create backup file"
    fi
else
    fail "backup_file returned error"
fi

# Test 17: Backup nonexistent file
if backup_file_step1 "$PROJECT_ROOT/nonexistent.txt" 2>/dev/null; then
    fail "backup_file should fail for nonexistent file"
else
    pass "backup_file correctly fails for nonexistent file"
fi

# Test 18: List files recursive
mkdir -p "$PROJECT_ROOT/search_test/sub"
touch "$PROJECT_ROOT/search_test/file1.md"
touch "$PROJECT_ROOT/search_test/file2.md"
touch "$PROJECT_ROOT/search_test/sub/file3.md"
touch "$PROJECT_ROOT/search_test/other.txt"

files=$(list_files_recursive_step1 "$PROJECT_ROOT/search_test" "*.md")
count=$(echo "$files" | grep -c ".md" || true)
if [[ $count -eq 3 ]]; then
    pass "list_files_recursive finds all matching files"
else
    fail "list_files_recursive found $count files, expected 3"
fi

# Print results
echo ""
echo "========================================"
echo "Test Results"
echo "========================================"
echo "Tests run: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
