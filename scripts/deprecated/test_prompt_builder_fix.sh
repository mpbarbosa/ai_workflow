#!/bin/bash
set -euo pipefail

################################################################################
# Test Script for Prompt Builder Fix
# Purpose: Verify prompt generation produces complete, correctly-formatted prompts
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/src/workflow"
export SCRIPT_DIR

# Source the fixed prompt builder
source "$SCRIPT_DIR/lib/ai_prompt_builder.sh"

echo "======================================"
echo "Prompt Builder Fix Validation Tests"
echo "======================================"
echo ""

# Test 1: YAML Loading
echo "Test 1: YAML Value Loading"
echo "----------------------------"
role_prefix=$(get_yq_value "$SCRIPT_DIR/lib/ai_helpers.yaml" "doc_analysis_prompt.role_prefix")
behavioral=$(get_yq_value "$SCRIPT_DIR/lib/ai_helpers.yaml" "_behavioral_actionable")

if [[ ${#role_prefix} -gt 100 ]]; then
    echo "✓ Role prefix loaded (${#role_prefix} chars)"
else
    echo "✗ Role prefix too short or missing (${#role_prefix} chars)"
    exit 1
fi

if [[ ${#behavioral} -gt 100 ]]; then
    echo "✓ Behavioral guidelines loaded (${#behavioral} chars)"
else
    echo "✗ Behavioral guidelines missing (${#behavioral} chars)"
    exit 1
fi

echo ""

# Test 2: Prompt Generation
echo "Test 2: Complete Prompt Generation"
echo "-----------------------------------"
test_changed_files="src/test.js
docs/README.md
package.json"

test_doc_files="README.md
docs/api/API.md
.github/copilot-instructions.md"

# Redirect stderr to avoid debug output in test
prompt_output=$(build_doc_analysis_prompt "$test_changed_files" "$test_doc_files" 2>/dev/null)

# Count lines
prompt_lines=$(echo "$prompt_output" | wc -l)

# Check for key sections
has_role=$(echo "$prompt_output" | grep -c "^\*\*Role\*\*:" || echo "0")
has_task=$(echo "$prompt_output" | grep -c "^\*\*Task\*\*:" || echo "0")
has_approach=$(echo "$prompt_output" | grep -c "^\*\*Approach\*\*:" || echo "0")
has_behavioral=$(echo "$prompt_output" | grep -c "Critical Behavioral Guidelines" || echo "0")
has_methodology=$(echo "$prompt_output" | grep -c "Methodology" || echo "0")
# Clean up counts (remove any extra output)
has_ansi=$(echo "$prompt_output" | { grep -cE '\[0;[0-9]+m' 2>/dev/null || echo "0"; } | head -1)
has_ansi=${has_ansi//[^0-9]/}  # Remove any non-digit characters
has_ansi=${has_ansi:-0}  # Default to 0 if empty

echo "Prompt statistics:"
echo "  - Total lines: $prompt_lines"
echo "  - Has Role section: $has_role"
echo "  - Has Task section: $has_task"
echo "  - Has Approach section: $has_approach"
echo "  - Has Behavioral Guidelines: $has_behavioral"
echo "  - Has Methodology: $has_methodology"
echo "  - Has ANSI codes: $has_ansi"
echo ""

# Validations
all_passed=true

if [[ $prompt_lines -lt 50 ]]; then
    echo "✗ FAIL: Prompt too short ($prompt_lines lines, expected 50+)"
    all_passed=false
else
    echo "✓ PASS: Prompt length adequate ($prompt_lines lines)"
fi

if [[ $has_role -eq 0 ]]; then
    echo "✗ FAIL: Missing Role section"
    all_passed=false
else
    echo "✓ PASS: Role section present"
fi

if [[ $has_task -eq 0 ]]; then
    echo "✗ FAIL: Missing Task section"
    all_passed=false
else
    echo "✓ PASS: Task section present"
fi

if [[ $has_approach -eq 0 ]]; then
    echo "✗ FAIL: Missing Approach section"
    all_passed=false
else
    echo "✓ PASS: Approach section present"
fi

if [[ $has_behavioral -eq 0 ]]; then
    echo "✗ FAIL: Missing Behavioral Guidelines"
    all_passed=false
else
    echo "✓ PASS: Behavioral Guidelines present"
fi

if [[ $has_methodology -eq 0 ]]; then
    echo "✗ FAIL: Missing Methodology section"
    all_passed=false
else
    echo "✓ PASS: Methodology section present"
fi

if [[ $has_ansi -gt 0 ]]; then
    echo "✗ FAIL: ANSI escape codes found in prompt ($has_ansi occurrences)"
    all_passed=false
else
    echo "✓ PASS: No ANSI escape codes in prompt"
fi

echo ""

# Test 3: Content Quality
echo "Test 3: Content Quality Checks"
echo "-------------------------------"

has_concrete=$(echo "$prompt_output" | grep -c "concrete" || echo "0")
has_actionable=$(echo "$prompt_output" | grep -c "actionable" || echo "0")
has_exact=$(echo "$prompt_output" | grep -ci "exact" || echo "0")
has_specific=$(echo "$prompt_output" | grep -c "specific" || echo "0")

quality_score=0
if [[ $has_concrete -gt 0 ]]; then
    echo "✓ Contains 'concrete' ($has_concrete times)"
    quality_score=$((quality_score + 1))
fi

if [[ $has_actionable -gt 0 ]]; then
    echo "✓ Contains 'actionable' ($has_actionable times)"
    quality_score=$((quality_score + 1))
fi

if [[ $has_exact -gt 0 ]]; then
    echo "✓ Contains 'exact' ($has_exact times)"
    quality_score=$((quality_score + 1))
fi

if [[ $has_specific -gt 0 ]]; then
    echo "✓ Contains 'specific' ($has_specific times)"
    quality_score=$((quality_score + 1))
fi

echo ""
echo "Quality score: $quality_score/4"

if [[ $quality_score -ge 3 ]]; then
    echo "✓ PASS: High quality guidance present"
else
    echo "✗ FAIL: Quality guidance insufficient ($quality_score/4)"
    all_passed=false
fi

echo ""

# Test 4: Sample Output
echo "Test 4: Sample Prompt Output"
echo "-----------------------------"
echo "First 30 lines of generated prompt:"
echo "------------------------------------"
echo "$prompt_output" | head -30
echo "------------------------------------"
echo ""

# Final Result
echo "======================================"
if [[ "$all_passed" == "true" ]]; then
    echo "✅ ALL TESTS PASSED"
    echo "======================================"
    echo ""
    echo "Prompt builder fix validated successfully."
    echo "The generated prompts now contain complete content."
    exit 0
else
    echo "❌ SOME TESTS FAILED"
    echo "======================================"
    echo ""
    echo "Review the failures above and check:"
    echo "  1. YAML paths are correct"
    echo "  2. yq is installed and working"
    echo "  3. get_yq_value function handles your yq version"
    echo "  4. No debug output is being written to prompt"
    exit 1
fi
