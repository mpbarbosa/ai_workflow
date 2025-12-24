#!/usr/bin/env bash
set -euo pipefail

echo "Step 01 Refactoring Validation"
echo "==============================="
echo ""

# Mock functions
print_section() { echo "[SECTION] $*"; }
print_info() { echo "[INFO] $*"; }
print_success() { echo "[SUCCESS] $*"; }
print_warning() { echo "[WARNING] $*"; }
print_error() { echo "[ERROR] $*"; }
prompt_for_continuation() { return 0; }
export -f print_section print_info print_success print_warning print_error prompt_for_continuation

STEP1_DIR="./steps"

echo "Test 1: File structure..."
[[ -f "${STEP1_DIR}/step_01_documentation.sh" ]] && echo "✓ Main file exists" || echo "✗ Main file missing"
[[ -d "${STEP1_DIR}/step_01_lib" ]] && echo "✓ Sub-module directory exists" || echo "✗ Directory missing"
[[ -f "${STEP1_DIR}/step_01_lib/cache.sh" ]] && echo "✓ cache.sh exists" || echo "✗ cache.sh missing"
[[ -f "${STEP1_DIR}/step_01_lib/file_operations.sh" ]] && echo "✓ file_operations.sh exists" || echo "✗ file_operations.sh missing"
[[ -f "${STEP1_DIR}/step_01_lib/validation.sh" ]] && echo "✓ validation.sh exists" || echo "✗ validation.sh missing"
[[ -f "${STEP1_DIR}/step_01_lib/ai_integration.sh" ]] && echo "✓ ai_integration.sh exists" || echo "✗ ai_integration.sh missing"

echo ""
echo "Test 2: Syntax validation..."
bash -n "${STEP1_DIR}/step_01_documentation.sh" && echo "✓ Main script syntax OK" || echo "✗ Syntax error"
bash -n "${STEP1_DIR}/step_01_lib/cache.sh" && echo "✓ cache.sh syntax OK" || echo "✗ Syntax error"
bash -n "${STEP1_DIR}/step_01_lib/file_operations.sh" && echo "✓ file_operations.sh syntax OK" || echo "✗ Syntax error"
bash -n "${STEP1_DIR}/step_01_lib/validation.sh" && echo "✓ validation.sh syntax OK" || echo "✗ Syntax error"
bash -n "${STEP1_DIR}/step_01_lib/ai_integration.sh" && echo "✓ ai_integration.sh syntax OK" || echo "✗ Syntax error"

echo ""
echo "Test 3: Module loading..."
source "${STEP1_DIR}/step_01_documentation.sh" 2>/dev/null && echo "✓ Main script loads" || echo "✗ Loading error"

echo ""
echo "Test 4: Line counts..."
wc -l "${STEP1_DIR}/step_01_documentation.sh" "${STEP1_DIR}/step_01_lib"/*.sh | tail -1

echo ""
echo "Test 5: Function availability..."
declare -F step1_update_documentation >/dev/null && echo "✓ step1_update_documentation exists" || echo "✗ Missing"
declare -F init_performance_cache >/dev/null && echo "✓ init_performance_cache (compat) exists" || echo "✗ Missing"
declare -F check_copilot_available >/dev/null && echo "✓ check_copilot_available (compat) exists" || echo "✗ Missing"

echo ""
echo "✅ Refactoring validation complete!"
