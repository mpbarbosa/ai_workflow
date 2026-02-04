#!/bin/bash
set -uo pipefail

################################################################################
# JQ Wrapper Test Suite
# Tests the jq_safe wrapper function
################################################################################

# Source the module
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/jq_wrapper.sh"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test helper
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing: $test_name ... "
    
    local test_result=0
    if ! eval "$test_command" > /dev/null 2>&1; then
        test_result=1
    fi
    
    if [[ $test_result -eq 0 ]]; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((TESTS_FAILED++))
        return 0  # Don't exit on test failure
    fi
}

# Run tests
echo "================================"
echo "JQ Wrapper Test Suite"
echo "================================"
echo ""

# Test 1: Basic usage with -n flag
run_test "Basic null input" \
    'result=$(jq_safe -n "{}") && [[ "$result" == "{}" ]]'

# Test 2: --arg usage
run_test "String argument with --arg" \
    'result=$(jq_safe -n --arg name "test" "{name: \$name}") && echo "$result" | grep -q "test"'

# Test 3: Valid --argjson with number
run_test "Numeric --argjson" \
    'result=$(jq_safe -n --argjson count 5 "{count: \$count}") && echo "$result" | grep -q "\"count\": 5"'

# Test 4: Valid --argjson with boolean
run_test "Boolean --argjson" \
    'result=$(jq_safe -n --argjson flag true "{flag: \$flag}") && echo "$result" | grep -q "\"flag\": true"'

# Test 5: Multiple --argjson arguments
run_test "Multiple --argjson" \
    'result=$(jq_safe -n --argjson a 1 --argjson b 2 "{sum: (\$a + \$b)}") && echo "$result" | grep -q "\"sum\": 3"'

# Test 6: Processing JSON from stdin
run_test "Stdin JSON processing" \
    'result=$(echo "{\"foo\": \"bar\"}" | jq_safe ".foo") && [[ "$result" == "\"bar\"" ]]'

# Test 7: Filter with file input
TEST_FILE="/tmp/test_jq_wrapper_$$.json"
echo '{"items": [1, 2, 3]}' > "$TEST_FILE"
run_test "File input processing" \
    'result=$(jq_safe ".items | length" "$TEST_FILE") && [[ "$result" == "3" ]]'
rm -f "$TEST_FILE"

# Test 8: sanitize_argjson_value with number
run_test "Sanitize numeric value" \
    'result=$(sanitize_argjson_value "42") && [[ "$result" == "42" ]]'

# Test 9: sanitize_argjson_value with empty (default)
run_test "Sanitize empty value with default" \
    'result=$(sanitize_argjson_value "" 0) && [[ "$result" == "0" ]]'

# Test 10: sanitize_argjson_value with boolean
run_test "Sanitize boolean value" \
    'result=$(sanitize_argjson_value "true") && [[ "$result" == "true" ]]'

# Test 11: validate_json with valid JSON
run_test "Validate valid JSON object" \
    'validate_json "{\"test\": true}"'

# Test 12: validate_json with valid JSON array
run_test "Validate valid JSON array" \
    'validate_json "[1, 2, 3]"'

# Test 13: validate_json with invalid JSON (should fail)
if ! validate_json "not json" 2>/dev/null; then
    echo -e "Testing: Validate invalid JSON ... ${GREEN}✓ PASS${NC} (correctly rejected)"
    ((TESTS_PASSED++))
else
    echo -e "Testing: Validate invalid JSON ... ${RED}✗ FAIL${NC} (should have rejected)"
    ((TESTS_FAILED++))
fi

# Test 14: Empty --argjson value (should fail)
if ! jq_safe -n --argjson empty "" "{}" 2>/dev/null; then
    echo -e "Testing: Reject empty --argjson ... ${GREEN}✓ PASS${NC} (correctly rejected)"
    ((TESTS_PASSED++))
else
    echo -e "Testing: Reject empty --argjson ... ${RED}✗ FAIL${NC} (should have rejected)"
    ((TESTS_FAILED++))
fi

# Test 15: Complex nested JSON
run_test "Complex nested JSON" \
    'result=$(jq_safe -n --argjson x 10 --argjson y 20 "{coordinates: {x: \$x, y: \$y}, sum: (\$x + \$y)}") && echo "$result" | grep -q "\"sum\": 30"'

# Test 16: Array manipulation
run_test "Array manipulation" \
    'result=$(echo "[1,2,3,4,5]" | jq_safe "map(. * 2) | .[0]") && [[ "$result" == "2" ]]'

# Test 17: Conditional selection
run_test "Conditional selection" \
    'result=$(echo "[{\"a\":1},{\"a\":2}]" | jq_safe "[.[] | select(.a > 1)]") && echo "$result" | grep -q "\"a\": 2"'

# Print summary
echo ""
echo "================================"
echo "Test Summary"
echo "================================"
echo -e "Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Failed: ${RED}${TESTS_FAILED}${NC}"
echo "Total:  $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
