#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Unit Tests for Step 1 Incremental Module
# Purpose: Test file hash calculation and change detection
################################################################################

# Setup test environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_TEMP_DIR=$(mktemp -d)
export WORKFLOW_HOME="$TEST_TEMP_DIR"
export AI_CACHE_DIR="$TEST_TEMP_DIR/.ai_cache"
export USE_AI_CACHE=true

# Mock print functions if not available
if ! command -v print_info &>/dev/null; then
    print_info() { echo "[INFO] $*"; }
    print_success() { echo "[OK] $*"; }
    print_error() { echo "[ERROR] $*"; }
fi

# Source the module under test
source "${SCRIPT_DIR}/incremental.sh"

# Test utilities
TESTS_PASSED=0
TESTS_FAILED=0

test_result() {
    local test_name="$1"
    local result="$2"
    
    if [[ "$result" == "PASS" ]]; then
        echo "✅ $test_name"
        ((TESTS_PASSED++))
    else
        echo "❌ $test_name"
        ((TESTS_FAILED++))
    fi
}

# Create test files
setup_test_files() {
    mkdir -p "$TEST_TEMP_DIR/docs"
    echo "# Test Doc 1" > "$TEST_TEMP_DIR/docs/test1.md"
    echo "# Test Doc 2" > "$TEST_TEMP_DIR/docs/test2.md"
    echo "# README" > "$TEST_TEMP_DIR/README.md"
}

# Cleanup
cleanup() {
    rm -rf "$TEST_TEMP_DIR"
}
trap cleanup EXIT

# ==============================================================================
# TESTS
# ==============================================================================

echo "Running Step 1 Incremental Module Tests..."
echo ""

# Test 1: Calculate file hash
setup_test_files
cd "$TEST_TEMP_DIR"

hash1=$(calculate_file_hash "README.md")
if [[ -n "$hash1" ]] && [[ ${#hash1} -eq 64 ]]; then
    test_result "Test 1: Calculate file hash" "PASS"
else
    test_result "Test 1: Calculate file hash (expected 64-char hash, got: ${#hash1})" "FAIL"
fi

# Test 2: Hash stability (same file = same hash)
hash2=$(calculate_file_hash "README.md")
if [[ "$hash1" == "$hash2" ]]; then
    test_result "Test 2: Hash stability" "PASS"
else
    test_result "Test 2: Hash stability (hashes differ)" "FAIL"
fi

# Test 3: Hash changes when file changes
echo "# README MODIFIED" > "README.md"
hash3=$(calculate_file_hash "README.md")
if [[ "$hash1" != "$hash3" ]]; then
    test_result "Test 3: Hash changes on file modification" "PASS"
else
    test_result "Test 3: Hash changes on file modification (hash unchanged)" "FAIL"
fi

# Test 4: Initialize hash cache
init_doc_hash_cache
if [[ -f "$AI_CACHE_DIR/doc_hashes.json" ]]; then
    test_result "Test 4: Initialize hash cache file" "PASS"
else
    test_result "Test 4: Initialize hash cache file (not created)" "FAIL"
fi

# Test 5: Save and load hash cache
files_json='{"test.md": {"hash": "abc123", "size": 100, "mtime": 1234567890}}'
save_doc_hash_cache "$files_json"
cached_hash=$(get_cached_doc_hash "test.md")
if [[ "$cached_hash" == "abc123" ]]; then
    test_result "Test 5: Save and load hash from cache" "PASS"
else
    test_result "Test 5: Save and load hash from cache (got: $cached_hash)" "FAIL"
fi

# Test 6: Detect changed docs (first run, all new)
setup_test_files
cd "$TEST_TEMP_DIR"
changed=$(detect_changed_docs "README.md" "docs/test1.md" "docs/test2.md")
changed_count=$(echo "$changed" | grep -c . || echo 0)
if [[ $changed_count -eq 3 ]]; then
    test_result "Test 6: Detect changes (first run, all new)" "PASS"
else
    test_result "Test 6: Detect changes (expected 3, got $changed_count)" "FAIL"
fi

# Test 7: Detect and cache (cache population)
changed_cached=$(detect_and_cache_changed_docs "README.md" "docs/test1.md")
if [[ -f "$AI_CACHE_DIR/doc_hashes.json" ]]; then
    cached_readme=$(get_cached_doc_hash "README.md")
    if [[ -n "$cached_readme" ]]; then
        test_result "Test 7: Detect and cache (cache populated)" "PASS"
    else
        test_result "Test 7: Detect and cache (cache not populated)" "FAIL"
    fi
else
    test_result "Test 7: Detect and cache (cache file missing)" "FAIL"
fi

# Test 8: No changes detected on second run
changed2=$(detect_changed_docs "README.md")
changed2_count=$(echo "$changed2" | grep -c . || echo 0)
if [[ $changed2_count -eq 0 ]]; then
    test_result "Test 8: No changes detected (cached hash matches)" "PASS"
else
    test_result "Test 8: No changes detected (expected 0, got $changed2_count)" "FAIL"
fi

# Test 9: Change detected after file modification
echo "# README CHANGED AGAIN" > "README.md"
changed3=$(detect_changed_docs "README.md")
changed3_count=$(echo "$changed3" | grep -c . || echo 0)
if [[ $changed3_count -eq 1 ]]; then
    test_result "Test 9: Change detected after modification" "PASS"
else
    test_result "Test 9: Change detected after modification (expected 1, got $changed3_count)" "FAIL"
fi

# Test 10: Get cache statistics
stats=$(get_doc_cache_stats "README.md" "docs/test1.md" "docs/test2.md")
if command -v jq &>/dev/null; then
    total=$(echo "$stats" | jq -r '.total')
    if [[ "$total" == "3" ]]; then
        test_result "Test 10: Get cache statistics" "PASS"
    else
        test_result "Test 10: Get cache statistics (expected total=3, got $total)" "FAIL"
    fi
else
    test_result "Test 10: Get cache statistics (jq not available - SKIP)" "PASS"
fi

# ==============================================================================
# SUMMARY
# ==============================================================================

echo ""
echo "================================================"
echo "Test Results Summary"
echo "================================================"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo "Total:  $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed"
    exit 1
fi
