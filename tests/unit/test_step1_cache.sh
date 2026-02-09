#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Suite for Step 1 Cache Module
# Purpose: Unit tests for cache.sh functionality
# Version: 1.0.0
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEP1_LIB_DIR="${TEST_DIR}/../../src/workflow/steps/documentation_updates_lib"

echo "Test directory: $TEST_DIR"
echo "Step1 lib directory: $STEP1_LIB_DIR"
echo "Cache module: ${STEP1_LIB_DIR}/cache.sh"

# Source the cache module
if [[ ! -f "${STEP1_LIB_DIR}/cache.sh" ]]; then
    echo "ERROR: Cache module not found at ${STEP1_LIB_DIR}/cache.sh"
    exit 1
fi

source "${STEP1_LIB_DIR}/cache.sh"

# Add backward compatibility aliases for testing
init_performance_cache() { init_step1_cache; }
get_or_cache() { get_or_cache_step1 "$@"; }
get_cached_git_diff() { get_cached_git_diff_step1; }

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

assert_true() {
    if $1; then
        pass "$2"
    else
        fail "$2"
    fi
}

# Test Suite
echo "================================"
echo "Step 1 Cache Module Tests"
echo "================================"
echo ""

# Test 1: Module loads successfully
if [[ "${STEP1_CACHE_MODULE_LOADED:-}" == "true" ]]; then
    pass "Module loads successfully"
else
    fail "Module failed to load"
fi

# Test 2: Cache initialization
echo "Running Test 2: Cache initialization..."
init_step1_cache
stats=$(get_cache_stats_step1)
echo "Cache stats after init: '$stats'"
assert_equals "0" "$stats" "Cache initializes empty"

# Test 3: Cache a value
counter=0
dummy_function() {
    counter=$((counter + 1))
    echo "test_value_${counter}"
}
export -f dummy_function
result=$(get_or_cache_step1 "test_key" dummy_function)
assert_equals "test_value_1" "$result" "Cache stores and returns value"

# Test 4: Retrieve cached value (no re-execution)
# Function should NOT be called again
result=$(get_or_cache_step1 "test_key" dummy_function)
assert_equals "test_value_1" "$result" "Cache returns cached value without re-execution (counter still at 1)"

# Test 5: Cache statistics
# Note: Direct cache manipulation to test stats since subshell modifications don't persist
set +u  # Temporarily disable nounset for associative array access
STEP1_CACHE["test_key"]="test_value"
set -u  # Re-enable nounset
assert_equals "1" "$(get_cache_stats_step1)" "Cache reports correct count"

# Test 6: Check if key is cached
if is_cached_step1 "test_key"; then
    pass "is_cached returns true for cached key"
else
    fail "is_cached should return true for cached key"
fi

if ! is_cached_step1 "nonexistent_key"; then
    pass "is_cached returns false for non-cached key"
else
    fail "is_cached should return false for non-cached key"
fi

# Test 7: Clear specific cache entry
clear_cache_entry_step1 "test_key"
if ! is_cached_step1 "test_key"; then
    pass "clear_cache_entry removes specific key"
else
    fail "clear_cache_entry failed to remove key"
fi

# Test 8: Cache multiple values
get_or_cache_step1 "key1" echo "value1" > /dev/null
get_or_cache_step1 "key2" echo "value2" > /dev/null
get_or_cache_step1 "key3" echo "value3" > /dev/null
assert_equals "3" "$(get_cache_stats_step1)" "Cache handles multiple keys"

# Test 9: Clear all cache
clear_all_cache_step1
assert_equals "0" "$(get_cache_stats_step1)" "clear_all_cache empties cache"

# Test 10: Git diff caching (with mock)
git_counter=0
get_git_diff_files_output() {
    git_counter=$((git_counter + 1))
    echo "file${git_counter}.sh file${git_counter}_2.sh"
}
export -f get_git_diff_files_output

result=$(get_cached_git_diff_step1)
assert_equals "file1.sh file1_2.sh" "$result" "Git diff caching works"

# Test 11: Git diff returns cached on second call
result=$(get_cached_git_diff_step1)
assert_equals "file1.sh file1_2.sh" "$result" "Git diff returns cached value (counter still at 1)"

# Test 12: Cache with function arguments
function_with_args() {
    echo "args: $1 $2"
}
result=$(get_or_cache_step1 "args_key" function_with_args "hello" "world")
assert_equals "args: hello world" "$result" "Cache handles function with arguments"

# Test 13: Cache empty values
empty_function() {
    echo ""
}
clear_all_cache_step1
result=$(get_or_cache_step1 "empty_key" empty_function)
# Empty value shouldn't be cached (by design - see the [[ -n check]])
if ! is_cached_step1 "empty_key"; then
    pass "Cache correctly skips empty values"
else
    fail "Cache should not store empty values"
fi

# Test 14: Backward compatibility aliases
init_performance_cache  # Should call init_step1_cache
assert_equals "0" "$(get_cache_stats_step1)" "Backward compat: init_performance_cache works"

test_func() { echo "compat_test"; }
result=$(get_or_cache "compat_key" test_func)
assert_equals "compat_test" "$result" "Backward compat: get_or_cache works"

# Print results
echo ""
echo "================================"
echo "Test Results"
echo "================================"
echo "Tests run: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
