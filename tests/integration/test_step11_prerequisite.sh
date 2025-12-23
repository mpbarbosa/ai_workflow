#!/bin/bash
# Manual integration test for Step 10→11 dependency enforcement
# Tests that Step 11 correctly validates Step 10 prerequisite

set -eo pipefail

# Setup test environment
PROJECT_ROOT="/home/runner/work/ai_workflow/ai_workflow"
cd "$PROJECT_ROOT"

# Source required modules
source "src/workflow/lib/colors.sh"
source "src/workflow/lib/utils.sh"
source "src/workflow/lib/validation.sh"
source "src/workflow/lib/backlog.sh"
source "src/workflow/lib/summary.sh"
source "src/workflow/lib/git_cache.sh"
source "src/workflow/lib/ai_helpers.sh"

# Initialize required variables
export INTERACTIVE_MODE=false
export AUTO_MODE=true
export DRY_RUN=false
export WORKFLOW_RUN_ID="test_run_$(date +%s)"
export LOGS_RUN_DIR="/tmp/test_logs"
export BACKLOG_RUN_DIR="/tmp/test_backlog"
export SUMMARIES_RUN_DIR="/tmp/test_summaries"
export TEMP_FILES=()

mkdir -p "$LOGS_RUN_DIR" "$BACKLOG_RUN_DIR" "$SUMMARIES_RUN_DIR"

# Initialize workflow status array
declare -A WORKFLOW_STATUS
WORKFLOW_STATUS=()

echo ""
echo "=========================================="
echo "Manual Integration Test: Step 10→11 Dependency"
echo "=========================================="
echo ""

# Test Case 1: Step 11 without Step 10 (should fail)
echo "Test Case 1: Attempting Step 11 without Step 10 completion"
echo "Expected: Step 11 should fail with prerequisite error"
echo ""

# Set Step 10 status to empty (not executed)
WORKFLOW_STATUS[step10]=""

# Source and execute Step 11
source "src/workflow/steps/step_11_git.sh"

echo "Executing step11_git_finalization()..."
if step11_git_finalization; then
    echo "❌ TEST FAILED: Step 11 should have failed without Step 10"
    exit 1
else
    echo "✅ TEST PASSED: Step 11 correctly failed without Step 10"
    echo ""
fi

# Test Case 2: Step 11 with Step 10 failed (should fail)
echo "Test Case 2: Attempting Step 11 with Step 10 failed"
echo "Expected: Step 11 should fail with prerequisite error"
echo ""

# Set Step 10 status to failed
WORKFLOW_STATUS[step10]="❌"

echo "Executing step11_git_finalization()..."
if step11_git_finalization; then
    echo "❌ TEST FAILED: Step 11 should have failed with Step 10 failed"
    exit 1
else
    echo "✅ TEST PASSED: Step 11 correctly failed with Step 10 failed"
    echo ""
fi

# Test Case 3: Step 11 with Step 10 succeeded (should pass prerequisite check)
echo "Test Case 3: Attempting Step 11 with Step 10 completed"
echo "Expected: Step 11 should pass prerequisite validation (then skip git operations in dry-run)"
echo ""

# Set Step 10 status to success
WORKFLOW_STATUS[step10]="✅"
# Enable dry-run to avoid actual git operations
export DRY_RUN=true

echo "Executing step11_git_finalization() in dry-run mode..."
if step11_git_finalization; then
    echo "✅ TEST PASSED: Step 11 prerequisite validation succeeded with Step 10 completed"
    echo ""
else
    echo "❌ TEST FAILED: Step 11 should have passed prerequisite validation"
    exit 1
fi

# Cleanup
rm -rf "$LOGS_RUN_DIR" "$BACKLOG_RUN_DIR" "$SUMMARIES_RUN_DIR"

echo ""
echo "=========================================="
echo "All Integration Tests Passed ✅"
echo "=========================================="
echo ""
echo "✅ Step 11 correctly enforces Step 10 prerequisite"
echo "✅ Runtime validation is working as expected"
echo ""

exit 0
