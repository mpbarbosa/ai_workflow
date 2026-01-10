#!/bin/bash
set -euo pipefail

################################################################################
# Test Suite for Step Validation Cache Module
# Purpose: Comprehensive tests for validation caching functionality
# Version: 1.0.0
################################################################################

# Test setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_HOME="${SCRIPT_DIR}/.."
export WORKFLOW_HOME

# Fallback color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Source required modules (colors.sh may override)
source "${SCRIPT_DIR}/colors.sh" 2>/dev/null || true

# Define print functions if not already defined
if ! command -v print_info &>/dev/null; then
    print_info() { echo -e "${BLUE}ℹ${NC} $*"; }
    print_success() { echo -e "${GREEN}✓${NC} $*"; }
    print_error() { echo -e "${RED}✗${NC} $*"; }
    print_warning() { echo -e "${YELLOW}⚠${NC} $*"; }
fi

source "${SCRIPT_DIR}/step_validation_cache.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test mode - enable caching
export USE_VALIDATION_CACHE=true
export VERBOSE=false

# ==============================================================================
# TEST HELPERS
# ==============================================================================

# Setup test environment
setup_test_env() {
    # Create temporary test directory
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    
    # Override cache directory for testing
    export VALIDATION_CACHE_DIR="${TEST_DIR}/.validation_cache"
    export VALIDATION_CACHE_INDEX="${VALIDATION_CACHE_DIR}/index.json"
    
    # Create test files
    mkdir -p "${TEST_DIR}/src"
    echo "console.log('test');" > "${TEST_DIR}/src/test.js"
    echo "# Test Doc" > "${TEST_DIR}/src/README.md"
    
    # Initialize cache
    init_validation_cache
}

# Cleanup test environment
cleanup_test_env() {
    if [[ -d "${TEST_DIR}" ]]; then
        rm -rf "${TEST_DIR}"
    fi
    
    # Reset cache counters
    VALIDATION_CACHE_HITS=0
    VALIDATION_CACHE_MISSES=0
    VALIDATION_CACHE_SKIPPED_FILES=0
}

# Assert function
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    
    if [[ "${expected}" == "${actual}" ]]; then
        echo -e "${GREEN}✓${NC} ${test_name}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} ${test_name}"
        echo "  Expected: ${expected}"
        echo "  Actual: ${actual}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert file exists
assert_file_exists() {
    local file_path="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if [[ -f "${file_path}" ]] || [[ -d "${file_path}" ]]; then
        echo -e "${GREEN}✓${NC} ${test_name}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} ${test_name}"
        echo "  Path not found: ${file_path}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert condition
assert_true() {
    local condition="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if eval "${condition}"; then
        echo -e "${GREEN}✓${NC} ${test_name}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} ${test_name}"
        echo "  Condition failed: ${condition}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ==============================================================================
# CACHE INITIALIZATION TESTS
# ==============================================================================

test_cache_initialization() {
    echo -e "\n${BLUE}Testing Cache Initialization${NC}"
    
    setup_test_env
    
    # Test 1: Cache directory created
    assert_file_exists "${VALIDATION_CACHE_DIR}" "Cache directory created"
    
    # Test 2: Index file created
    assert_file_exists "${VALIDATION_CACHE_INDEX}" "Cache index file created"
    
    # Test 3: Index has valid JSON structure
    assert_true "[[ -n \$(jq -r '.version' '${VALIDATION_CACHE_INDEX}' 2>/dev/null) ]]" \
        "Index has valid JSON structure"
    
    # Test 4: Index has correct version
    local version=$(jq -r '.version' "${VALIDATION_CACHE_INDEX}")
    assert_equals "1.0.0" "${version}" "Index has correct version"
    
    cleanup_test_env
}

# ==============================================================================
# FILE HASH TESTS
# ==============================================================================

test_file_hash_calculation() {
    echo -e "\n${BLUE}Testing File Hash Calculation${NC}"
    
    setup_test_env
    
    # Test 1: Calculate hash for existing file
    local hash1=$(calculate_file_hash "${TEST_DIR}/src/test.js")
    assert_true "[[ -n '${hash1}' ]] && [[ '${hash1}' != 'FILE_NOT_FOUND' ]]" \
        "Calculate hash for existing file"
    
    # Test 2: Same file produces same hash
    local hash2=$(calculate_file_hash "${TEST_DIR}/src/test.js")
    assert_equals "${hash1}" "${hash2}" "Same file produces consistent hash"
    
    # Test 3: Different files produce different hashes
    echo "console.log('different');" > "${TEST_DIR}/src/test2.js"
    local hash3=$(calculate_file_hash "${TEST_DIR}/src/test2.js")
    assert_true "[[ '${hash1}' != '${hash3}' ]]" "Different files produce different hashes"
    
    # Test 4: Non-existent file returns error
    local hash4=$(calculate_file_hash "${TEST_DIR}/nonexistent.js" 2>/dev/null || echo "FILE_NOT_FOUND")
    assert_equals "FILE_NOT_FOUND" "${hash4}" "Non-existent file returns error"
    
    cleanup_test_env
}

test_directory_hash_calculation() {
    echo -e "\n${BLUE}Testing Directory Hash Calculation${NC}"
    
    setup_test_env
    
    # Test 1: Calculate hash for directory
    local dir_hash1=$(calculate_directory_hash "${TEST_DIR}/src")
    assert_true "[[ -n '${dir_hash1}' ]] && [[ '${dir_hash1}' != 'DIR_NOT_FOUND' ]]" \
        "Calculate hash for directory"
    
    # Test 2: Same directory produces same hash
    local dir_hash2=$(calculate_directory_hash "${TEST_DIR}/src")
    assert_equals "${dir_hash1}" "${dir_hash2}" "Same directory produces consistent hash"
    
    # Test 3: Directory changes produce different hash
    echo "new file" > "${TEST_DIR}/src/new.js"
    local dir_hash3=$(calculate_directory_hash "${TEST_DIR}/src")
    assert_true "[[ '${dir_hash1}' != '${dir_hash3}' ]]" "Directory changes produce different hash"
    
    cleanup_test_env
}

# ==============================================================================
# CACHE KEY TESTS
# ==============================================================================

test_cache_key_generation() {
    echo -e "\n${BLUE}Testing Cache Key Generation${NC}"
    
    setup_test_env
    
    # Test 1: Generate file validation key
    local key1=$(generate_validation_cache_key "step4" "directory_check" "src/test.js")
    assert_equals "step4:directory_check:src/test.js" "${key1}" "Generate file validation key"
    
    # Test 2: Generate directory validation key
    local key2=$(generate_directory_validation_key "step4" "structure_check" "src/")
    assert_equals "step4:structure_check:dir:src/" "${key2}" "Generate directory validation key"
    
    # Test 3: Normalize paths (remove leading ./)
    local key3=$(generate_validation_cache_key "step9" "lint" "./src/test.js")
    assert_equals "step9:lint:src/test.js" "${key3}" "Normalize paths in cache keys"
    
    cleanup_test_env
}

# ==============================================================================
# CACHE SAVE AND RETRIEVE TESTS
# ==============================================================================

test_save_and_retrieve_validation() {
    echo -e "\n${BLUE}Testing Save and Retrieve Validation Results${NC}"
    
    setup_test_env
    
    # Test 1: Save validation result
    local cache_key="step9:lint:src/test.js"
    local file_hash=$(calculate_file_hash "${TEST_DIR}/src/test.js")
    save_validation_result "${cache_key}" "${file_hash}" "pass" "OK"
    
    local entry=$(get_validation_result "${cache_key}")
    assert_true "[[ -n '${entry}' ]]" "Save and retrieve validation result"
    
    # Test 2: Retrieve validation status
    local status=$(echo "${entry}" | jq -r '.validation_status')
    assert_equals "pass" "${status}" "Retrieve correct validation status"
    
    # Test 3: Retrieve file hash
    local cached_hash=$(echo "${entry}" | jq -r '.file_hash')
    assert_equals "${file_hash}" "${cached_hash}" "Retrieve correct file hash"
    
    # Test 4: Check cache validates correctly
    if check_validation_cache "${cache_key}" "${file_hash}"; then
        assert_true "true" "Check cache validates with matching hash"
    else
        assert_true "false" "Check cache validates with matching hash"
    fi
    
    cleanup_test_env
}

# ==============================================================================
# CACHE INVALIDATION TESTS
# ==============================================================================

test_cache_invalidation() {
    echo -e "\n${BLUE}Testing Cache Invalidation${NC}"
    
    setup_test_env
    
    # Setup: Create and cache a validation result
    local cache_key="step9:lint:src/test.js"
    local original_hash=$(calculate_file_hash "${TEST_DIR}/src/test.js")
    save_validation_result "${cache_key}" "${original_hash}" "pass" "OK"
    
    # Test 1: Cache hit with unchanged file
    if check_validation_cache "${cache_key}" "${original_hash}"; then
        assert_true "true" "Cache hit with unchanged file"
    else
        assert_true "false" "Cache hit with unchanged file"
    fi
    
    # Test 2: Cache miss after file change
    echo "// modified" >> "${TEST_DIR}/src/test.js"
    local new_hash=$(calculate_file_hash "${TEST_DIR}/src/test.js")
    
    if check_validation_cache "${cache_key}" "${new_hash}"; then
        assert_true "false" "Cache miss after file change"
    else
        assert_true "true" "Cache miss after file change"
    fi
    
    # Test 3: Manual cache invalidation
    invalidate_files_cache "src/test.js"
    local entry=$(get_validation_result "${cache_key}")
    assert_true "[[ -z '${entry}' ]]" "Manual cache invalidation works"
    
    cleanup_test_env
}

# ==============================================================================
# TTL EXPIRATION TESTS
# ==============================================================================

test_cache_expiration() {
    echo -e "\n${BLUE}Testing Cache TTL Expiration${NC}"
    
    setup_test_env
    
    # Override TTL for testing (1 second)
    export VALIDATION_CACHE_TTL=1
    
    # Save validation result
    local cache_key="step9:lint:src/test.js"
    local file_hash=$(calculate_file_hash "${TEST_DIR}/src/test.js")
    save_validation_result "${cache_key}" "${file_hash}" "pass" "OK"
    
    # Test 1: Cache hit immediately
    if check_validation_cache "${cache_key}" "${file_hash}"; then
        assert_true "true" "Cache hit before expiration"
    else
        assert_true "false" "Cache hit before expiration"
    fi
    
    # Wait for TTL to expire
    sleep 2
    
    # Test 2: Cache miss after expiration
    if check_validation_cache "${cache_key}" "${file_hash}"; then
        assert_true "false" "Cache miss after TTL expiration"
    else
        assert_true "true" "Cache miss after TTL expiration"
    fi
    
    # Restore TTL
    export VALIDATION_CACHE_TTL=86400
    
    cleanup_test_env
}

# ==============================================================================
# BATCH VALIDATION TESTS
# ==============================================================================

test_batch_validation() {
    echo -e "\n${BLUE}Testing Batch Validation${NC}"
    
    setup_test_env
    
    # Create multiple test files
    echo "file1" > "${TEST_DIR}/src/file1.js"
    echo "file2" > "${TEST_DIR}/src/file2.js"
    echo "file3" > "${TEST_DIR}/src/file3.js"
    
    # Test 1: Batch validate (first run - all cache misses)
    local failed_count=0
    batch_validate_files_cached "step9" "lint" "echo 'OK' > /dev/null && true" \
        "${TEST_DIR}/src/file1.js" "${TEST_DIR}/src/file2.js" "${TEST_DIR}/src/file3.js" || failed_count=$?
    
    assert_equals "0" "${failed_count}" "Batch validation succeeds for all files"
    assert_equals "3" "${VALIDATION_CACHE_MISSES}" "First run has 3 cache misses"
    
    # Test 2: Batch validate again (all cache hits)
    VALIDATION_CACHE_HITS=0
    VALIDATION_CACHE_MISSES=0
    
    batch_validate_files_cached "step9" "lint" "echo 'OK' > /dev/null && true" \
        "${TEST_DIR}/src/file1.js" "${TEST_DIR}/src/file2.js" "${TEST_DIR}/src/file3.js" || true
    
    assert_equals "3" "${VALIDATION_CACHE_HITS}" "Second run has 3 cache hits"
    assert_equals "0" "${VALIDATION_CACHE_MISSES}" "Second run has 0 cache misses"
    
    cleanup_test_env
}

# ==============================================================================
# VALIDATION WRAPPER TESTS
# ==============================================================================

test_validate_file_cached() {
    echo -e "\n${BLUE}Testing validate_file_cached Wrapper${NC}"
    
    setup_test_env
    
    # Reset counters
    VALIDATION_CACHE_HITS=0
    VALIDATION_CACHE_MISSES=0
    
    # Test 1: First validation (cache miss)
    if validate_file_cached "step9" "lint" "${TEST_DIR}/src/test.js" "echo 'OK' && true"; then
        assert_true "true" "First validation succeeds (cache miss)"
    else
        assert_true "false" "First validation succeeds (cache miss)"
    fi
    
    assert_equals "1" "${VALIDATION_CACHE_MISSES}" "First validation is cache miss"
    
    # Test 2: Second validation (cache hit)
    VALIDATION_CACHE_HITS=0
    VALIDATION_CACHE_MISSES=0
    
    if validate_file_cached "step9" "lint" "${TEST_DIR}/src/test.js" "echo 'OK' && true"; then
        assert_true "true" "Second validation succeeds (cache hit)"
    else
        assert_true "false" "Second validation succeeds (cache hit)"
    fi
    
    assert_equals "1" "${VALIDATION_CACHE_HITS}" "Second validation is cache hit"
    assert_equals "1" "${VALIDATION_CACHE_SKIPPED_FILES}" "One file skipped via cache"
    
    cleanup_test_env
}

test_validate_directory_cached() {
    echo -e "\n${BLUE}Testing validate_directory_cached Wrapper${NC}"
    
    setup_test_env
    
    # Reset counters
    VALIDATION_CACHE_HITS=0
    VALIDATION_CACHE_MISSES=0
    
    # Test 1: First validation (cache miss)
    if validate_directory_cached "step4" "structure" "${TEST_DIR}/src" "echo 'OK' && true"; then
        assert_true "true" "First directory validation succeeds (cache miss)"
    else
        assert_true "false" "First directory validation succeeds (cache miss)"
    fi
    
    assert_equals "1" "${VALIDATION_CACHE_MISSES}" "First directory validation is cache miss"
    
    # Test 2: Second validation (cache hit)
    VALIDATION_CACHE_HITS=0
    VALIDATION_CACHE_MISSES=0
    
    if validate_directory_cached "step4" "structure" "${TEST_DIR}/src" "echo 'OK' && true"; then
        assert_true "true" "Second directory validation succeeds (cache hit)"
    else
        assert_true "false" "Second directory validation succeeds (cache hit)"
    fi
    
    assert_equals "1" "${VALIDATION_CACHE_HITS}" "Second directory validation is cache hit"
    
    cleanup_test_env
}

# ==============================================================================
# STATISTICS TESTS
# ==============================================================================

test_cache_statistics() {
    echo -e "\n${BLUE}Testing Cache Statistics${NC}"
    
    setup_test_env
    
    # Create some cache entries
    save_validation_result "step9:lint:file1.js" "hash1" "pass" "OK"
    save_validation_result "step9:lint:file2.js" "hash2" "fail" "Error"
    save_validation_result "step4:structure:dir1" "hash3" "pass" "OK"
    
    # Test 1: Count cache entries
    local entry_count=$(jq '.entries | length' "${VALIDATION_CACHE_INDEX}")
    assert_equals "3" "${entry_count}" "Cache has correct entry count"
    
    # Test 2: Statistics export
    local stats=$(export_validation_cache_metrics)
    assert_true "[[ -n '${stats}' ]]" "Export cache statistics"
    
    # Test 3: Hit rate calculation
    VALIDATION_CACHE_HITS=7
    VALIDATION_CACHE_MISSES=3
    local stats_output=$(export_validation_cache_metrics)
    local hit_rate=$(echo "${stats_output}" | jq -r '.validation_cache_hit_rate')
    assert_equals "70.0" "${hit_rate}" "Calculate correct hit rate"
    
    cleanup_test_env
}

# ==============================================================================
# CLEANUP TESTS
# ==============================================================================

test_cache_cleanup() {
    echo -e "\n${BLUE}Testing Cache Cleanup${NC}"
    
    setup_test_env
    
    # Override TTL for testing
    export VALIDATION_CACHE_TTL=1
    
    # Create old and new entries
    save_validation_result "old_entry" "hash1" "pass" "OK"
    sleep 2
    save_validation_result "new_entry" "hash2" "pass" "OK"
    
    # Test 1: Cleanup removes old entries
    cleanup_validation_cache_old_entries
    
    local old_exists=$(jq -r '.entries["old_entry"] // empty' "${VALIDATION_CACHE_INDEX}")
    local new_exists=$(jq -r '.entries["new_entry"] // empty' "${VALIDATION_CACHE_INDEX}")
    
    assert_true "[[ -z '${old_exists}' ]]" "Old entries removed by cleanup"
    assert_true "[[ -n '${new_exists}' ]]" "New entries preserved by cleanup"
    
    # Restore TTL
    export VALIDATION_CACHE_TTL=86400
    
    cleanup_test_env
}

# ==============================================================================
# RUN ALL TESTS
# ==============================================================================

run_all_tests() {
    echo -e "${BOLD}${BLUE}================================${NC}"
    echo -e "${BOLD}${BLUE}Step Validation Cache Test Suite${NC}"
    echo -e "${BOLD}${BLUE}================================${NC}"
    
    # Run test suites
    test_cache_initialization
    test_file_hash_calculation
    test_directory_hash_calculation
    test_cache_key_generation
    test_save_and_retrieve_validation
    test_cache_invalidation
    test_cache_expiration
    test_batch_validation
    test_validate_file_cached
    test_validate_directory_cached
    test_cache_statistics
    test_cache_cleanup
    
    # Print summary
    echo -e "\n${BOLD}${BLUE}================================${NC}"
    echo -e "${BOLD}Test Summary${NC}"
    echo -e "${BOLD}${BLUE}================================${NC}"
    echo -e "Tests Run:    ${TESTS_RUN}"
    echo -e "${GREEN}Tests Passed: ${TESTS_PASSED}${NC}"
    
    if [[ ${TESTS_FAILED} -gt 0 ]]; then
        echo -e "${RED}Tests Failed: ${TESTS_FAILED}${NC}"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

# Run tests
run_all_tests
