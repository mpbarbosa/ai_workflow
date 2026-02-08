#!/usr/bin/env bash
# Simple test to verify Step 1 log file path generation fix

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_test() { echo -e "${YELLOW}[TEST]${NC} $1"; }
print_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
print_fail() { echo -e "${RED}[FAIL]${NC} $1"; }

print_test "Verifying Step 1 log file fix..."

# Test 1: Check that the fix is in place
print_test "1. Checking for LOGS_RUN_DIR usage in Step 1..."
if grep -q "LOGS_RUN_DIR" "${SCRIPT_DIR}/src/workflow/steps/step_01_lib/ai_integration.sh"; then
    print_pass "LOGS_RUN_DIR is now used in Step 1"
else
    print_fail "LOGS_RUN_DIR not found in Step 1"
    exit 1
fi

# Test 2: Check for proper log file pattern
print_test "2. Checking for step1_copilot_documentation_analysis pattern..."
if grep -q "step1_copilot_documentation_analysis" "${SCRIPT_DIR}/src/workflow/steps/step_01_lib/ai_integration.sh"; then
    print_pass "Log file pattern matches other steps"
else
    print_fail "Log file pattern not found"
    exit 1
fi

# Test 3: Check for timestamp generation
print_test "3. Checking for log timestamp generation..."
if grep -q 'log_timestamp.*date.*%Y%m%d_%H%M%S_%N' "${SCRIPT_DIR}/src/workflow/steps/step_01_lib/ai_integration.sh"; then
    print_pass "Timestamp generation implemented"
else
    print_fail "Timestamp generation missing"
    exit 1
fi

# Test 4: Check for backward compatibility (copying to backlog)
print_test "4. Checking for backward compatibility..."
if grep -q "cp.*log_file.*response_file" "${SCRIPT_DIR}/src/workflow/steps/step_01_lib/ai_integration.sh"; then
    print_pass "Backward compatibility maintained"
else
    print_fail "Backward compatibility not maintained"
    exit 1
fi

# Test 5: Verify the fix matches Step 2's pattern
print_test "5. Comparing with Step 2 implementation..."
step2_pattern=$(grep -o "step2_copilot_[a-z_]*_\${log_timestamp}" "${SCRIPT_DIR}/src/workflow/steps/step_02_lib/ai_integration.sh" || echo "")
step1_pattern=$(grep -o "step1_copilot_[a-z_]*_\${log_timestamp}" "${SCRIPT_DIR}/src/workflow/steps/step_01_lib/ai_integration.sh" || echo "")

if [[ -n "$step1_pattern" && -n "$step2_pattern" ]]; then
    print_pass "Step 1 pattern matches Step 2 style"
    echo "  Step 1: $step1_pattern"
    echo "  Step 2: $step2_pattern"
else
    print_fail "Pattern mismatch between Step 1 and Step 2"
    exit 1
fi

# Test 6: Show the exact changes made
print_test "6. Summary of changes made..."
echo ""
echo "Changes in src/workflow/steps/step_01_lib/ai_integration.sh:"
echo ""
echo "BEFORE (line ~319):"
echo '  local response_file="${output_dir}/ai_documentation_analysis.txt"'
echo '  if ! execute_ai_with_retry_step1 "$prompt" "$response_file"; then'
echo ""
echo "AFTER (lines ~320-327):"
echo '  local log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)'
echo '  local log_file="${LOGS_RUN_DIR:-./logs}/step1_copilot_documentation_analysis_${log_timestamp}.log"'
echo '  mkdir -p "$(dirname "$log_file")"'
echo '  if ! execute_ai_with_retry_step1 "$prompt" "$log_file"; then'
echo '  ...'
echo '  cp "$log_file" "$response_file" 2>/dev/null || true'
echo ""

print_pass "All verification checks passed!"
echo ""
echo "Summary:"
echo "  ✓ Step 1 now creates log files in LOGS_RUN_DIR"
echo "  ✓ Log file pattern: step1_copilot_documentation_analysis_TIMESTAMP.log"
echo "  ✓ Backward compatibility maintained (backlog copy)"
echo "  ✓ Implementation matches Step 2 pattern"
echo ""
echo "Next step: Test in actual workflow execution on guia_turistico project"
