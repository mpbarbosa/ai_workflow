#!/usr/bin/env bash
# Test script for Feature #12: Broken Reference Root Cause Analysis

set -euo pipefail

# ==============================================================================
# CLEANUP MANAGEMENT
# ==============================================================================

# Track temporary files for cleanup
declare -a TEST_REF_ANALYSIS_TEMP_FILES=()

# Register temp file for cleanup
track_test_ref_analysis_temp() {
    local temp_file="$1"
    [[ -n "$temp_file" ]] && TEST_REF_ANALYSIS_TEMP_FILES+=("$temp_file")
}

# Cleanup handler for test broken reference analysis
cleanup_test_ref_analysis_files() {
    local file
    for file in "${TEST_REF_ANALYSIS_TEMP_FILES[@]}"; do
        [[ -f "$file" ]] && rm -f "$file" 2>/dev/null
    done
    TEST_REF_ANALYSIS_TEMP_FILES=()
}

# CRITICAL: SCRIPT_DIR must be the src/workflow directory (parent of lib)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Source the module
source "${SCRIPT_DIR}/lib/ai_helpers.sh"

# Test result tracking
test_result() {
    local test_name="$1"
    local result="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$result" = "pass" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo "═══════════════════════════════════════════════════════════════"
echo "  Testing Feature #12: Broken Reference Root Cause Analysis"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Test 1: YAML Validity
echo "Test 1: YAML Validity"
echo "────────────────────────────────────────────────────────────────"
if python3 -c "import yaml; yaml.safe_load(open('${SCRIPT_DIR}/lib/ai_helpers.yaml'))" 2>/dev/null; then
    test_result "YAML parses without errors" "pass"
else
    test_result "YAML parses without errors" "fail"
fi
echo ""

# Test 2: Task Title Updated
echo "Test 2: Task Title Updated"
echo "────────────────────────────────────────────────────────────────"
if grep -q "Broken Reference Root Cause Analysis" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "New task title present in YAML" "pass"
else
    test_result "New task title present in YAML" "fail"
fi
echo ""

# Test 3: False Positive Framework
echo "Test 3: False Positive Framework"
echo "────────────────────────────────────────────────────────────────"
if grep -q "False Positive Check" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "False Positive Check section present" "pass"
else
    test_result "False Positive Check section present" "fail"
fi

if grep -q "Generated files" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Generated files example present" "pass"
else
    test_result "Generated files example present" "fail"
fi

if grep -q "External URLs" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "External URLs example present" "pass"
else
    test_result "External URLs example present" "fail"
fi
echo ""

# Test 4: Root Cause Framework
echo "Test 4: Root Cause Framework"
echo "────────────────────────────────────────────────────────────────"
if grep -q "Root Cause Determination" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Root Cause section present" "pass"
else
    test_result "Root Cause section present" "fail"
fi

if grep -q "Renamed file" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Renamed file scenario present" "pass"
else
    test_result "Renamed file scenario present" "fail"
fi

if grep -q "Moved location" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Moved location scenario present" "pass"
else
    test_result "Moved location scenario present" "fail"
fi
echo ""

# Test 5: Fix Recommendation Framework
echo "Test 5: Fix Recommendation Framework"
echo "────────────────────────────────────────────────────────────────"
if grep -q "Fix Recommendation" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Fix Recommendation section present" "pass"
else
    test_result "Fix Recommendation section present" "fail"
fi

if grep -q "Update reference" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Update reference option present" "pass"
else
    test_result "Update reference option present" "fail"
fi

if grep -q "Restore file" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Restore file option present" "pass"
else
    test_result "Restore file option present" "fail"
fi

if grep -q "Example:" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Examples provided for fixes" "pass"
else
    test_result "Examples provided for fixes" "fail"
fi
echo ""

# Test 6: Priority Assessment Framework
echo "Test 6: Priority Assessment Framework"
echo "────────────────────────────────────────────────────────────────"
if grep -q "Priority Assessment" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Priority Assessment section present" "pass"
else
    test_result "Priority Assessment section present" "fail"
fi

if grep -q "Critical" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Critical priority level defined" "pass"
else
    test_result "Critical priority level defined" "fail"
fi

if grep -q "High" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "High priority level defined" "pass"
else
    test_result "High priority level defined" "fail"
fi

if grep -q "Medium" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Medium priority level defined" "pass"
else
    test_result "Medium priority level defined" "fail"
fi

if grep -q "Low" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Low priority level defined" "pass"
else
    test_result "Low priority level defined" "fail"
fi
echo ""

# Test 7: Output Format Specified
echo "Test 7: Output Format Specified"
echo "────────────────────────────────────────────────────────────────"
if grep -q "Output Format for Each Reference" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Output format section present" "pass"
else
    test_result "Output format section present" "fail"
fi

if grep -q "Status.*False Positive / Truly Broken" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Status field defined in output" "pass"
else
    test_result "Status field defined in output" "fail"
fi

if grep -q "Root Cause.*Specific cause" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Root Cause field defined in output" "pass"
else
    test_result "Root Cause field defined in output" "fail"
fi
echo ""

# Test 8: Placeholder Preserved
echo "Test 8: Placeholder Preserved"
echo "────────────────────────────────────────────────────────────────"
if grep -q "{broken_refs_content}" "${SCRIPT_DIR}/lib/ai_helpers.yaml"; then
    test_result "Placeholder preserved in YAML" "pass"
else
    test_result "Placeholder preserved in YAML" "fail"
fi
echo ""

# Test 9: Prompt Generation
echo "Test 9: Prompt Generation"
echo "────────────────────────────────────────────────────────────────"

# Generate prompt and capture exit code
temp_file=$(mktemp)
track_test_ref_analysis_temp "$temp_file"
if build_step2_consistency_prompt "test" "test" "shell" "major" "10" "test.md" "None" > "$temp_file" 2>&1; then
    test_result "Prompt generation succeeds" "pass"
    
    # Read the generated prompt
    result=$(cat "$temp_file")
    
    if grep -q "Broken Reference Root Cause Analysis" "$temp_file"; then
        test_result "Generated prompt contains new title" "pass"
    else
        test_result "Generated prompt contains new title" "fail"
    fi
    
    if grep -q "False Positive Check" "$temp_file"; then
        test_result "Generated prompt contains false positive section" "pass"
    else
        test_result "Generated prompt contains false positive section" "fail"
    fi
    
    if grep -q "Priority Assessment" "$temp_file"; then
        test_result "Generated prompt contains priority section" "pass"
    else
        test_result "Generated prompt contains priority section" "fail"
    fi
    
    rm -f "$temp_file"
else
    test_result "Prompt generation succeeds" "fail"
    test_result "Generated prompt contains new title" "fail"
    test_result "Generated prompt contains false positive section" "fail"
    test_result "Generated prompt contains priority section" "fail"
    rm -f "$temp_file"
fi
echo ""

# Test 10: Backward Compatibility
echo "Test 10: Backward Compatibility"
echo "────────────────────────────────────────────────────────────────"
# Check that all other prompts still work
other_prompts=("step3_script_refs_prompt" "step4_directory_prompt" "step5_test_review_prompt")
all_ok=true

for prompt in "${other_prompts[@]}"; do
    if python3 -c "import yaml; data=yaml.safe_load(open('${SCRIPT_DIR}/lib/ai_helpers.yaml')); exit(0 if '$prompt' in data else 1)" 2>/dev/null; then
        : # Success, do nothing
    else
        all_ok=false
        break
    fi
done

if [ "$all_ok" = true ]; then
    test_result "Other prompts unchanged" "pass"
else
    test_result "Other prompts unchanged" "fail"
fi
echo ""

# Summary
echo "═══════════════════════════════════════════════════════════════"
echo "  TEST SUMMARY"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Tests Run:    $TESTS_RUN"
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo ""
    exit 1
fi

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f track_test_ref_analysis_temp
export -f cleanup_test_ref_analysis_files

# ==============================================================================
# CLEANUP TRAP
# ==============================================================================

# Ensure cleanup runs on exit
trap cleanup_test_ref_analysis_files EXIT INT TERM
