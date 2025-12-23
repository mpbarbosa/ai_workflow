#!/bin/bash
set -euo pipefail

################################################################################
# Test Suite for AI Cache Module
# Purpose: Comprehensive tests for ai_cache.sh functionality
# Version: 1.0.0
# Created: 2025-12-20
################################################################################

# Test framework setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_NAME="AI Cache Module Tests"
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test utilities
print_test_header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_TOTAL++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local test_name="$2"
    
    ((TESTS_TOTAL++))
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  File not found: $file"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local test_name="$2"
    
    ((TESTS_TOTAL++))
    
    if [[ -n "$value" ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Value is empty"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    export WORKFLOW_HOME="$(mktemp -d)"
    export USE_AI_CACHE="true"
    export AI_CACHE_DIR="${WORKFLOW_HOME}/src/workflow/.ai_cache"
    export AI_CACHE_INDEX="${AI_CACHE_DIR}/index.json"
    export AI_CACHE_TTL=86400
    
    mkdir -p "${WORKFLOW_HOME}/src/workflow"
    
    # Source required modules
    source "${SCRIPT_DIR}/colors.sh" 2>/dev/null || true
    source "${SCRIPT_DIR}/ai_cache.sh"
}

# Cleanup test environment
cleanup_test_env() {
    if [[ -n "${WORKFLOW_HOME}" ]] && [[ -d "${WORKFLOW_HOME}" ]]; then
        rm -rf "${WORKFLOW_HOME}"
    fi
}

# ==============================================================================
# TEST SUITE 1: Cache Initialization
# ==============================================================================

test_cache_initialization() {
    print_test_header "Test Suite 1: Cache Initialization"
    
    # Test 1.1: init_ai_cache creates directory
    init_ai_cache
    assert_file_exists "${AI_CACHE_DIR}" "Cache directory created"
    
    # Test 1.2: init_ai_cache creates index file
    assert_file_exists "${AI_CACHE_INDEX}" "Cache index file created"
    
    # Test 1.3: Index file has valid JSON structure
    if command -v jq &>/dev/null; then
        local is_valid=$(jq empty "${AI_CACHE_INDEX}" 2>&1 && echo "yes" || echo "no")
        assert_equals "yes" "$is_valid" "Index file is valid JSON"
    fi
    
    # Test 1.4: Index file has required fields
    if command -v jq &>/dev/null; then
        local has_version=$(jq -r '.version' "${AI_CACHE_INDEX}")
        assert_not_empty "$has_version" "Index has version field"
        
        local has_entries=$(jq -r '.entries' "${AI_CACHE_INDEX}")
        assert_not_empty "$has_entries" "Index has entries field"
    fi
}

# ==============================================================================
# TEST SUITE 2: Cache Key Generation
# ==============================================================================

test_cache_key_generation() {
    print_test_header "Test Suite 2: Cache Key Generation"
    
    # Test 2.1: generate_cache_key produces output
    local key1=$(generate_cache_key "test prompt" "test persona")
    assert_not_empty "$key1" "Cache key generated for prompt"
    
    # Test 2.2: Same inputs produce same key
    local key2=$(generate_cache_key "test prompt" "test persona")
    assert_equals "$key1" "$key2" "Same inputs produce same key"
    
    # Test 2.3: Different inputs produce different keys
    local key3=$(generate_cache_key "different prompt" "test persona")
    if [[ "$key1" != "$key3" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: Different inputs produce different keys"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: Different inputs should produce different keys"
    fi
    ((TESTS_TOTAL++))
    
    # Test 2.4: Cache key length is consistent
    local key_length=${#key1}
    assert_equals "64" "$key_length" "Cache key is 64 characters (SHA256)"
}

# ==============================================================================
# TEST SUITE 3: Cache Storage
# ==============================================================================

test_cache_storage() {
    print_test_header "Test Suite 3: Cache Storage"
    
    init_ai_cache
    
    # Test 3.1: store_ai_response creates cache entry
    local test_key="test_key_123"
    local test_response="This is a test response"
    
    store_ai_response "$test_key" "$test_response" "test_persona"
    
    local cache_file="${AI_CACHE_DIR}/${test_key}.cache"
    assert_file_exists "$cache_file" "Cache file created for response"
    
    # Test 3.2: Stored content matches original
    if [[ -f "$cache_file" ]]; then
        local stored_content=$(cat "$cache_file")
        assert_equals "$test_response" "$stored_content" "Stored content matches original"
    fi
    
    # Test 3.3: Index updated with entry
    if command -v jq &>/dev/null && [[ -f "${AI_CACHE_INDEX}" ]]; then
        local entry_count=$(jq '.entries | length' "${AI_CACHE_INDEX}")
        if [[ $entry_count -gt 0 ]]; then
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: Index updated with cache entry"
        else
            ((TESTS_FAILED++))
            echo -e "${RED}✗${NC} FAIL: Index not updated with cache entry"
        fi
        ((TESTS_TOTAL++))
    fi
}

# ==============================================================================
# TEST SUITE 4: Cache Retrieval
# ==============================================================================

test_cache_retrieval() {
    print_test_header "Test Suite 4: Cache Retrieval"
    
    init_ai_cache
    
    # Setup: Store a test response
    local test_key="retrieval_test_key"
    local test_response="Test response for retrieval"
    store_ai_response "$test_key" "$test_response" "test_persona"
    
    # Test 4.1: get_cached_response retrieves stored response
    local retrieved=$(get_cached_response "$test_key")
    assert_equals "$test_response" "$retrieved" "Retrieved response matches stored"
    
    # Test 4.2: get_cached_response returns empty for non-existent key
    local non_existent=$(get_cached_response "non_existent_key_xyz")
    assert_equals "" "$non_existent" "Non-existent key returns empty"
    
    # Test 4.3: has_cached_response returns true for existing key
    if has_cached_response "$test_key"; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: has_cached_response returns true for existing key"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: has_cached_response should return true"
    fi
    ((TESTS_TOTAL++))
    
    # Test 4.4: has_cached_response returns false for non-existent key
    if ! has_cached_response "non_existent_key_xyz"; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: has_cached_response returns false for non-existent key"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: has_cached_response should return false"
    fi
    ((TESTS_TOTAL++))
}

# ==============================================================================
# TEST SUITE 5: Cache Expiration (TTL)
# ==============================================================================

test_cache_expiration() {
    print_test_header "Test Suite 5: Cache Expiration"
    
    init_ai_cache
    
    # Test 5.1: Fresh entry is not expired
    local test_key="fresh_entry"
    store_ai_response "$test_key" "Fresh response" "test_persona"
    
    if has_cached_response "$test_key"; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: Fresh cache entry is not expired"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: Fresh cache entry should not be expired"
    fi
    ((TESTS_TOTAL++))
    
    # Test 5.2: is_cache_expired function exists and works
    if declare -f is_cache_expired &>/dev/null; then
        local cache_file="${AI_CACHE_DIR}/${test_key}.cache"
        if [[ -f "$cache_file" ]]; then
            if ! is_cache_expired "$cache_file"; then
                ((TESTS_PASSED++))
                echo -e "${GREEN}✓${NC} PASS: is_cache_expired returns false for fresh file"
            else
                ((TESTS_FAILED++))
                echo -e "${RED}✗${NC} FAIL: Fresh file should not be expired"
            fi
            ((TESTS_TOTAL++))
        fi
    fi
    
    # Test 5.3: Old cache entries would be expired (simulated)
    # Create an old file (touch with old timestamp)
    local old_key="old_entry"
    local old_file="${AI_CACHE_DIR}/${old_key}.cache"
    echo "Old response" > "$old_file"
    touch -d "2 days ago" "$old_file" 2>/dev/null || true
    
    if declare -f is_cache_expired &>/dev/null; then
        if is_cache_expired "$old_file"; then
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: Old file is detected as expired"
        else
            ((TESTS_FAILED++))
            echo -e "${RED}✗${NC} FAIL: Old file should be expired"
        fi
        ((TESTS_TOTAL++))
    fi
}

# ==============================================================================
# TEST SUITE 6: Cache Cleanup
# ==============================================================================

test_cache_cleanup() {
    print_test_header "Test Suite 6: Cache Cleanup"
    
    init_ai_cache
    
    # Setup: Create multiple cache entries
    for i in {1..5}; do
        store_ai_response "test_key_$i" "Response $i" "test_persona"
    done
    
    # Test 6.1: cleanup_ai_cache function exists
    if declare -f cleanup_ai_cache &>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: cleanup_ai_cache function exists"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: cleanup_ai_cache function not found"
    fi
    ((TESTS_TOTAL++))
    
    # Test 6.2: cleanup_ai_cache runs without error
    if declare -f cleanup_ai_cache &>/dev/null; then
        if cleanup_ai_cache 2>/dev/null; then
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: cleanup_ai_cache runs without error"
        else
            ((TESTS_FAILED++))
            echo -e "${RED}✗${NC} FAIL: cleanup_ai_cache encountered error"
        fi
        ((TESTS_TOTAL++))
    fi
    
    # Test 6.3: Fresh entries remain after cleanup
    if has_cached_response "test_key_1"; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: Fresh entries remain after cleanup"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: Fresh entries should remain after cleanup"
    fi
    ((TESTS_TOTAL++))
}

# ==============================================================================
# TEST SUITE 7: Cache Statistics
# ==============================================================================

test_cache_statistics() {
    print_test_header "Test Suite 7: Cache Statistics"
    
    init_ai_cache
    
    # Setup: Store some test responses
    for i in {1..3}; do
        store_ai_response "stats_key_$i" "Response $i" "test_persona"
    done
    
    # Test 7.1: get_cache_stats function exists
    if declare -f get_cache_stats &>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: get_cache_stats function exists"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: get_cache_stats function not found"
    fi
    ((TESTS_TOTAL++))
    
    # Test 7.2: get_cache_stats returns information
    if declare -f get_cache_stats &>/dev/null; then
        local stats=$(get_cache_stats 2>/dev/null || echo "")
        if [[ -n "$stats" ]]; then
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: get_cache_stats returns information"
        else
            ((TESTS_FAILED++))
            echo -e "${RED}✗${NC} FAIL: get_cache_stats should return information"
        fi
        ((TESTS_TOTAL++))
    fi
}

# ==============================================================================
# TEST SUITE 8: Cache Disabling
# ==============================================================================

test_cache_disabling() {
    print_test_header "Test Suite 8: Cache Disabling"
    
    # Test 8.1: Cache can be disabled via USE_AI_CACHE
    export USE_AI_CACHE="false"
    init_ai_cache
    
    # Attempt to store
    store_ai_response "disabled_key" "Should not store" "test_persona" 2>/dev/null || true
    
    # Cache directory should not be created or should be empty
    if [[ ! -d "${AI_CACHE_DIR}" ]] || [[ ! -f "${AI_CACHE_DIR}/disabled_key.cache" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: Cache disabled prevents storage"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: Cache should be disabled"
    fi
    ((TESTS_TOTAL++))
    
    # Re-enable for remaining tests
    export USE_AI_CACHE="true"
}

# ==============================================================================
# MAIN TEST EXECUTION
# ==============================================================================

main() {
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                   AI Cache Module Test Suite                        ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Setup
    setup_test_env
    
    # Run all test suites
    test_cache_initialization
    test_cache_key_generation
    test_cache_storage
    test_cache_retrieval
    test_cache_expiration
    test_cache_cleanup
    test_cache_statistics
    test_cache_disabling
    
    # Cleanup
    cleanup_test_env
    
    # Summary
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo "Total Tests:  $TESTS_TOTAL"
    echo -e "Passed:       ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed:       ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✓ ALL TESTS PASSED${NC}"
        return 0
    else
        echo -e "\n${RED}✗ SOME TESTS FAILED${NC}"
        return 1
    fi
}

# Run tests
main "$@"
