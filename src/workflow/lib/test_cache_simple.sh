#!/bin/bash
set -euo pipefail

WORKFLOW_HOME="$(cd .. && pwd)"
export WORKFLOW_HOME USE_VALIDATION_CACHE=true VERBOSE=false

# Colors
GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

# Define print functions
print_info() { :; }
print_success() { :; }
print_error() { :; }
print_warning() { :; }

source ./step_validation_cache.sh

echo "Testing Step Validation Cache Module..."
PASS=0; FAIL=0

# Test 1: Module loads
if [[ "${STEP_VALIDATION_CACHE_LOADED}" == "true" ]]; then
    echo -e "${GREEN}✓${NC} Module loads successfully"
    ((PASS++))
else
    echo -e "${RED}✗${NC} Module failed to load"
    ((FAIL++))
fi

# Test 2: Init cache
TEST_DIR=$(mktemp -d)
export VALIDATION_CACHE_DIR="${TEST_DIR}/.cache"
export VALIDATION_CACHE_INDEX="${VALIDATION_CACHE_DIR}/index.json"
init_validation_cache

if [[ -f "${VALIDATION_CACHE_INDEX}" ]]; then
    echo -e "${GREEN}✓${NC} Cache initialization works"
    ((PASS++))
else
    echo -e "${RED}✗${NC} Cache initialization failed"
    ((FAIL++))
fi

# Test 3: File hash
echo "test content" > "${TEST_DIR}/test.txt"
HASH=$(calculate_file_hash "${TEST_DIR}/test.txt")
if [[ -n "${HASH}" ]] && [[ "${HASH}" != "FILE_NOT_FOUND" ]]; then
    echo -e "${GREEN}✓${NC} File hash calculation works"
    ((PASS++))
else
    echo -e "${RED}✗${NC} File hash calculation failed"
    ((FAIL++))
fi

# Test 4: Cache key generation
KEY=$(generate_validation_cache_key "step9" "lint" "src/test.js")
if [[ "${KEY}" == "step9:lint:src/test.js" ]]; then
    echo -e "${GREEN}✓${NC} Cache key generation works"
    ((PASS++))
else
    echo -e "${RED}✗${NC} Cache key generation failed (got: ${KEY})"
    ((FAIL++))
fi

# Test 5: Save and retrieve
save_validation_result "test:key" "testhash" "pass" "OK"
RESULT=$(get_validation_result "test:key")
if [[ -n "${RESULT}" ]]; then
    echo -e "${GREEN}✓${NC} Save/retrieve validation result works"
    ((PASS++))
else
    echo -e "${RED}✗${NC} Save/retrieve validation result failed"
    ((FAIL++))
fi

# Test 6: Cache hit
if check_validation_cache "test:key" "testhash"; then
    echo -e "${GREEN}✓${NC} Cache hit detection works"
    ((PASS++))
else
    echo -e "${RED}✗${NC} Cache hit detection failed"
    ((FAIL++))
fi

# Test 7: Cache miss (different hash)
if check_validation_cache "test:key" "differenthash"; then
    echo -e "${RED}✗${NC} Cache miss detection failed (should have missed)"
    ((FAIL++))
else
    echo -e "${GREEN}✓${NC} Cache miss detection works"
    ((PASS++))
fi

# Cleanup
rm -rf "${TEST_DIR}"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[[ ${FAIL} -eq 0 ]] && exit 0 || exit 1
