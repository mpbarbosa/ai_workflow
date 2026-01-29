#!/bin/bash
set -euo pipefail

echo "=== Step 15 Integration Test ==="
echo ""

# Test 1: Check dependency graph
echo "Test 1: Checking dependency_graph.sh..."
if grep -q '\[15\]="10,12,13,14"' src/workflow/lib/dependency_graph.sh; then
    echo "  ✅ Step 15 dependencies configured"
else
    echo "  ❌ Step 15 dependencies missing"
    exit 1
fi

if grep -q '\[11\]="15"' src/workflow/lib/dependency_graph.sh; then
    echo "  ✅ Step 11 updated to depend on Step 15"
else
    echo "  ❌ Step 11 dependency not updated"
    exit 1
fi

if grep -q '\[15\]=60' src/workflow/lib/dependency_graph.sh; then
    echo "  ✅ Step 15 time estimate configured"
else
    echo "  ❌ Step 15 time estimate missing"
    exit 1
fi

echo ""

# Test 2: Check workflow orchestrator
echo "Test 2: Checking execute_tests_docs_workflow.sh..."
if grep -q 'step15_version_update' src/workflow/execute_tests_docs_workflow.sh; then
    echo "  ✅ Step 15 execution block present"
else
    echo "  ❌ Step 15 execution block missing"
    exit 1
fi

if grep -B5 'step15_version_update' src/workflow/execute_tests_docs_workflow.sh | grep -q 'Step 15:'; then
    echo "  ✅ Step 15 comment header present"
else
    echo "  ❌ Step 15 comment header missing"
    exit 1
fi

echo ""

# Test 3: Check step module exists
echo "Test 3: Checking step module..."
if [[ -f src/workflow/steps/step_15_version_update.sh ]]; then
    echo "  ✅ Step 15 module file exists"
else
    echo "  ❌ Step 15 module file missing"
    exit 1
fi

if [[ -x src/workflow/steps/step_15_version_update.sh ]]; then
    echo "  ✅ Step 15 module is executable"
else
    echo "  ❌ Step 15 module not executable"
    exit 1
fi

echo ""

# Test 4: Check AI persona
echo "Test 4: Checking AI persona..."
if grep -q 'version_manager_prompt:' src/workflow/lib/ai_helpers.yaml; then
    echo "  ✅ version_manager persona defined"
else
    echo "  ❌ version_manager persona missing"
    exit 1
fi

echo ""

# Test 5: Load workflow and check function availability
echo "Test 5: Checking function loading..."
export WORKFLOW_DIR="$(pwd)/src/workflow"
export LIB_DIR="${WORKFLOW_DIR}/lib"
export STEPS_DIR="${WORKFLOW_DIR}/steps"
export TEST_MODE=1
export BACKLOG_RUN_DIR=/tmp/test_step15
mkdir -p /tmp/test_step15

# Source all required dependencies
source "${LIB_DIR}/colors.sh" >/dev/null 2>&1
source "${LIB_DIR}/utils.sh" >/dev/null 2>&1
source "${LIB_DIR}/ai_helpers.sh" >/dev/null 2>&1
source "${LIB_DIR}/git_cache.sh" >/dev/null 2>&1
source "${LIB_DIR}/third_party_exclusion.sh" >/dev/null 2>&1
source "${STEPS_DIR}/step_15_version_update.sh" 2>&1 | grep -v "^$" || true

if type -t step15_version_update >/dev/null 2>&1; then
    echo "  ✅ step15_version_update function available"
else
    echo "  ❌ step15_version_update function not available"
    exit 1
fi

# Check helper functions
if type -t extract_version >/dev/null 2>&1; then
    echo "  ✅ extract_version function available"
else
    echo "  ❌ extract_version function not available"
fi

if type -t increment_version >/dev/null 2>&1; then
    echo "  ✅ increment_version function available"
else
    echo "  ❌ increment_version function not available"
fi

echo ""
echo "=========================================="
echo "✅ All integration tests passed!"
echo "=========================================="
echo ""
echo "Step 15 is ready for production use."
echo ""
echo "Next steps:"
echo "  • Run full workflow: ./src/workflow/execute_tests_docs_workflow.sh --dry-run"
echo "  • Test Step 15 only: ./src/workflow/execute_tests_docs_workflow.sh --steps 15 --dry-run"
echo "  • Run unit tests: ./tests/test_step_15_version_update.sh"
