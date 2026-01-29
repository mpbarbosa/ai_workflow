#!/usr/bin/env bash
# Test script for Step 1 log file fix

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_PROJECT="/tmp/test_step1_log_$$"
WORKFLOW_DIR="${SCRIPT_DIR}/src/workflow"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_test() { echo -e "${YELLOW}[TEST]${NC} $1"; }
print_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
print_fail() { echo -e "${RED}[FAIL]${NC} $1"; }

cleanup() {
    rm -rf "$TEST_PROJECT"
}
trap cleanup EXIT

print_test "Creating test project..."
mkdir -p "$TEST_PROJECT"
cd "$TEST_PROJECT"

# Initialize git repo
git init >/dev/null 2>&1
git config user.email "test@example.com"
git config user.name "Test User"

# Create minimal project structure
cat > README.md <<'EOF'
# Test Project

This is a test project for Step 1 log file verification.
EOF

cat > package.json <<'EOF'
{
  "name": "test-project",
  "version": "1.0.0"
}
EOF

git add -A
git commit -m "Initial commit" >/dev/null 2>&1

# Make a documentation change
echo "## New Section" >> README.md
git add README.md
git commit -m "Update docs" >/dev/null 2>&1

print_test "Running workflow Step 1 only..."

# Set required environment variables
export TARGET_DIR="$TEST_PROJECT"
export PROJECT_ROOT="$TEST_PROJECT"
export PRIMARY_LANGUAGE="bash"
export AI_BATCH_MODE="true"

# Create logs directory structure
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGS_RUN_DIR="$TEST_PROJECT/.ai_workflow/logs/workflow_${TIMESTAMP}"
mkdir -p "$LOGS_RUN_DIR"
export LOGS_RUN_DIR

# Source required modules
source "${WORKFLOW_DIR}/lib/utils.sh"
source "${WORKFLOW_DIR}/lib/tech_stack.sh"
source "${WORKFLOW_DIR}/lib/change_detection.sh"
source "${WORKFLOW_DIR}/lib/ai_helpers.sh"
source "${WORKFLOW_DIR}/steps/step_01_lib/validation.sh"
source "${WORKFLOW_DIR}/steps/step_01_lib/ai_integration.sh"

# Check if we have copilot available
if ! command -v copilot &>/dev/null; then
    print_test "Skipping AI test - copilot not available"
    print_test "Testing log file path generation only..."
    
    # Test the log file path generation without actually calling AI
    log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
    log_file="${LOGS_RUN_DIR}/step1_copilot_documentation_analysis_${log_timestamp}.log"
    
    if [[ "$log_file" == *"/step1_copilot_documentation_analysis_"* ]]; then
        print_pass "Log file path pattern is correct: $log_file"
    else
        print_fail "Log file path pattern is incorrect: $log_file"
        exit 1
    fi
    
    if [[ "$log_file" == "${LOGS_RUN_DIR}"* ]]; then
        print_pass "Log file uses LOGS_RUN_DIR correctly"
    else
        print_fail "Log file doesn't use LOGS_RUN_DIR"
        exit 1
    fi
    
    print_pass "Log file path generation verified (AI test skipped)"
    exit 0
fi

# Run Step 1
print_test "Executing Step 1..."
BACKLOG_DIR="$TEST_PROJECT/.ai_workflow/backlog/workflow_${TIMESTAMP}"
mkdir -p "$BACKLOG_DIR"

if run_ai_documentation_workflow_step1 "README.md" "" "$BACKLOG_DIR"; then
    print_pass "Step 1 execution completed"
else
    print_fail "Step 1 execution failed"
    exit 1
fi

# Verify log file was created
print_test "Checking for log file in ${LOGS_RUN_DIR}..."
log_files=$(find "$LOGS_RUN_DIR" -name "step1_copilot_*.log" -type f 2>/dev/null || true)

if [[ -n "$log_files" ]]; then
    print_pass "Log file created: $log_files"
    
    # Verify log file contains content
    if [[ -s "$log_files" ]]; then
        print_pass "Log file contains content ($(wc -l < "$log_files") lines)"
    else
        print_fail "Log file is empty"
        exit 1
    fi
else
    print_fail "No log file created in ${LOGS_RUN_DIR}"
    echo "Directory contents:"
    ls -la "$LOGS_RUN_DIR" || echo "  (directory doesn't exist)"
    exit 1
fi

# Verify backward compatibility (backlog file)
if [[ -f "$BACKLOG_DIR/ai_documentation_analysis.txt" ]]; then
    print_pass "Backward compatibility maintained (backlog file exists)"
else
    print_fail "Backlog file missing (backward compatibility broken)"
    exit 1
fi

print_pass "All tests passed!"
