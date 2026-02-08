#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Script for Step 1.5: API Coverage Report
# Purpose: Validate Step 1.5 implementation
################################################################################

# Setup
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEP_DIR="${TEST_DIR}"  # We're already in steps directory
LIB_DIR="${TEST_DIR}/../lib"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $*"; }
print_error() { echo -e "${RED}✗${NC} $*"; }
print_info() { echo -e "${YELLOW}ℹ${NC} $*"; }

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    ((TESTS_RUN++))
    
    if eval "$test_cmd"; then
        ((TESTS_PASSED++))
        print_success "$test_name"
        return 0
    else
        ((TESTS_FAILED++))
        print_error "$test_name"
        return 1
    fi
}

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Step 1.5 API Coverage Report - Test Suite                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Module loading
print_info "Testing module loading..."
run_test "Load main step script" \
    "source '${STEP_DIR}/step_01_5_api_coverage.sh' 2>/dev/null"

run_test "Load coverage_threshold.sh" \
    "source '${STEP_DIR}/step_01_5_lib/coverage_threshold.sh' 2>/dev/null"

run_test "Load incremental.sh" \
    "source '${STEP_DIR}/step_01_5_lib/incremental.sh' 2>/dev/null"

run_test "Load reporting.sh" \
    "source '${STEP_DIR}/step_01_5_lib/reporting.sh' 2>/dev/null"

echo ""

# Test 2: Function exports
print_info "Testing exported functions..."
source "${STEP_DIR}/step_01_5_api_coverage.sh" 2>/dev/null || true
source "${STEP_DIR}/step_01_5_lib/coverage_threshold.sh" 2>/dev/null || true
source "${STEP_DIR}/step_01_5_lib/incremental.sh" 2>/dev/null || true
source "${STEP_DIR}/step_01_5_lib/reporting.sh" 2>/dev/null || true

run_test "Function: step_01_5_api_coverage exists" \
    "declare -f step_01_5_api_coverage &>/dev/null"

run_test "Function: check_coverage_threshold exists" \
    "declare -f check_coverage_threshold &>/dev/null"

run_test "Function: get_coverage_status exists" \
    "declare -f get_coverage_status &>/dev/null"

run_test "Function: calculate_required_apis exists" \
    "declare -f calculate_required_apis &>/dev/null"

echo ""

# Test 3: Threshold checking logic
print_info "Testing threshold logic..."
source "${LIB_DIR}/colors.sh" 2>/dev/null || true
source "${LIB_DIR}/utils.sh" 2>/dev/null || true
source "${STEP_DIR}/step_01_5_lib/coverage_threshold.sh"

run_test "Threshold check: 90% >= 80% should pass" \
    "check_coverage_threshold 90 80"

run_test "Threshold check: 70% < 80% should fail" \
    "! check_coverage_threshold 70 80"

run_test "Coverage status: 90% is Excellent" \
    "[[ \$(get_coverage_status 90) == 'Excellent' ]]"

run_test "Coverage status: 85% is Good" \
    "[[ \$(get_coverage_status 85) == 'Good' ]]"

run_test "Coverage status: 70% is Fair" \
    "[[ \$(get_coverage_status 70) == 'Fair' ]]"

run_test "Coverage status: 50% is Poor" \
    "[[ \$(get_coverage_status 50) == 'Poor' ]]"

echo ""

# Test 4: Required APIs calculation
print_info "Testing required APIs calculation..."
run_test "Required APIs: 50 total, 35 documented, 80% threshold = 5 needed" \
    "[[ \$(calculate_required_apis 50 35 80) == '5' ]]"

run_test "Required APIs: 50 total, 45 documented, 80% threshold = 0 needed" \
    "[[ \$(calculate_required_apis 50 45 80) == '0' ]]"

echo ""

# Test 5: Version info
print_info "Testing version information..."
run_test "Version function exists" \
    "declare -f step_01_5_get_version &>/dev/null"

if declare -f step_01_5_get_version &>/dev/null; then
    version=$(step_01_5_get_version)
    run_test "Version returns valid format" \
        "[[ \$version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]"
fi

echo ""

# Summary
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  TEST SUMMARY                                                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Tests Run:    ${TESTS_RUN}"
echo "  Tests Passed: ${TESTS_PASSED}"
echo "  Tests Failed: ${TESTS_FAILED}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    print_success "✅ All tests passed!"
    exit 0
else
    print_error "❌ Some tests failed"
    exit 1
fi
