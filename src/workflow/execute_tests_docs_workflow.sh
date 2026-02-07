#!/bin/bash
set -euo pipefail


################################################################################
# Tests & Documentation Workflow Automation Script
# Version: 3.2.1
# Purpose: Automate the complete tests and documentation update workflow
# Related: /prompts/tests_documentation_update_enhanced.txt
#
# AI ENHANCEMENTS APPLIED (v1.2.0):
# ==================================
# This script leverages GitHub Copilot CLI for intelligent documentation
# analysis and validation. Fifteen steps have been enhanced with specialized
# AI personas using the modern 'copilot -p' command.
#
# Enhanced Steps with AI Personas:
#   Step 0b: Bootstrap Documentation (Technical Writer) ⭐ NEW v3.1.1
#   Step 1:  Documentation Updates (Technical Documentation Specialist)
#   Step 2:  Consistency Analysis (Documentation Specialist + Information Architect)
#   Step 2.5: Documentation Optimization (Documentation Architect + AI Optimizer) ⭐ NEW v3.2.1
#   Step 3:  Script Reference Validation (DevOps Documentation Expert)
#   Step 4:  Directory Structure Validation (Software Architect + Documentation Specialist)
#   Step 5:  Test Review (QA Engineer + Test Automation Specialist)
#   Step 6:  Test Generation (TDD Expert + Code Generation Specialist)
#   Step 7:  Test Execution (QA Automation Engineer + CI/CD Specialist)
#   Step 8:  Dependency Validation (DevOps Engineer + Package Management Specialist)
#   Step 9:  Code Quality Validation (Software Quality Engineer + Code Review Specialist)
#   Step 10: Context Analysis (Technical Project Manager + Workflow Orchestration Specialist)
#   Step 12: Markdown Linting (Technical Documentation Specialist) ⭐ NEW
#   Step 13: Prompt Engineer Analysis (Prompt Engineer + AI Specialist) ⭐ NEW v2.3.1
#   Step 14: UX Analysis (UX Designer + Frontend Specialist) ⭐ NEW v2.4.0
#   Step 0a: Semantic Version Update (Version Manager - PRE-PROCESSING) ⭐ NEW v2.6.0
#   Step 11: Git Finalization (Git Workflow Specialist + Technical Communication Expert) ⭐ ENHANCED [FINAL STEP]
#
# ARCHITECTURE PATTERN:
#   All enhanced steps follow: Role → Task → Standards structure
#   All use two-phase validation: Automated + AI-powered
#   All have smart triggering: Auto/Interactive/Optional modes
#
# BEST PRACTICES APPLIED (v1.2.0):
#   ✓ Modern Copilot CLI (copilot -p) instead of deprecated gh copilot
#   ✓ Professional specialist personas matched to task domain
#   ✓ Temporary file cleanup with trap handlers
#   ✓ AI-powered conventional commit message generation ⭐ NEW
#   ✓ Interactive workflow with copy-paste for AI output ⭐ NEW
#   ✓ Graceful fallbacks when Copilot unavailable
#   ✓ Comprehensive git context analysis for commit messages
#   ✓ Auto-mode skip for interactive AI features
#
# NEW IN v1.3.0:
#   ✓ Backlog tracking - saves issues from every step to /backlog
#   ✓ Workflow run directories with unique timestamped IDs
#   ✓ Markdown issue reports for each step with findings
#   ✓ Centralized backlog management for issue review
#   ✓ Complete audit trail of workflow execution
#
# NEW IN v1.4.0:
#   ✓ Summary generation - concise conclusions for every step
#   ✓ Separate /summaries directory with step conclusions
#   ✓ Quick-reference summaries alongside detailed backlog reports
#   ✓ Status indicators (✅ ⚠️ ❌) for each step outcome
#   ✓ High-level overview without detailed technical output
#
# NEW IN v1.5.0:
#   ✓ Git state caching - eliminates 30+ redundant git subprocess calls
#   ✓ Performance optimization - 25-30% faster workflow execution
#   ✓ Centralized git cache with accessor functions
#   ✓ Single git query per workflow run for status/diff/branch info
#   ✓ Consistent git state across all workflow steps
#
# NEW IN v2.0.0:
#   ✓ Workflow execution logging - comprehensive audit trail
#   ✓ Main execution log (workflow_execution.log) per workflow run
#   ✓ Timestamped log entries for all major events
#   ✓ Pre-flight checks logging with SUCCESS/ERROR/WARNING levels
#   ✓ Step execution tracking with start/complete timestamps
#   ✓ Workflow summary with duration and step status
#   ✓ Log file location info displayed at completion
#
# NEW IN v2.1.0 (2025-12-18):
#   ✓ Workflow health check - verify all 13 steps complete or capture failure
#   ✓ Documentation placement validation - enforce /docs directory structure
#   ✓ Enhanced git state reporting - separate coverage regeneration detection
#   ✓ Automatic health check execution on workflow completion
#   ✓ New library module: lib/health_check.sh with 3 validation functions
#   ✓ 4 comprehensive reports per workflow run (including 3 new health reports)
#
# NEW IN v2.2.0 (2025-12-18):
#   ✓ Conditional step execution - skip redundant steps when change impact = Low
#   ✓ Parallel step processing - steps 1-4 (validation) run simultaneously
#   ✓ Workflow resume capability - checkpoint system to restart from last step
#   ✓ Change impact analysis - automatic Low/Medium/High impact detection
#   ✓ Smart test skipping - skip test steps for documentation-only changes
#   ✓ Dependency-aware execution - skip dependency validation when unchanged
#   ✓ Checkpoint management - auto-cleanup checkpoints older than 7 days
#   ✓ New library module: lib/workflow_optimization.sh with 9 functions
#   ✓ Performance boost: 60-75% faster validation (parallel execution)
#
# PERFORMANCE OPTIMIZATIONS (2025-11-14):
#   ✓ Optimized find operations - replaced with fast_find (performance.sh)
#   ✓ Reduced redundant file searches - cache and reuse results
#   ✓ Smart exclusions - skip node_modules/.git/coverage directories
#   ✓ Maxdepth limits - prevent deep directory traversals
#   ✓ Performance module integration - lib/performance.sh auto-loaded
#   Expected Impact: Additional 15-25% reduction in execution time
#
# NEW IN v2.3.0 - PHASE 2 INTEGRATION (2025-12-18):
#   ✓ --smart-execution flag - Change-based step skipping (40-82% time savings)
#   ✓ --show-graph flag - Dependency graph visualization
#   ✓ --parallel flag - Parallel step execution (33% time savings)
#   ✓ --no-ai-cache flag - Disable AI response caching
#   ✓ Integrated metrics collection - Automatic performance tracking
#   ✓ AI response caching - Reduce token usage by 60-80%
#   ✓ Enhanced resume capability - Automatic checkpoint management
#   ✓ Combined optimizations - Up to 85% faster for simple changes
################################################################################

set -euo pipefail

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

SCRIPT_VERSION="3.2.1"  # Git Submodule Support in Step 11
SCRIPT_NAME="Tests & Documentation Workflow Automation"
WORKFLOW_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_ROOT="$(pwd)"  # Default: current directory; can be overridden with --target option
TARGET_PROJECT_ROOT=""  # Set via --target option when specified
SRC_DIR="${PROJECT_ROOT}/src"

# Artifact directories - will be updated after --target option is processed
# These store workflow execution artifacts (logs, backlog, summaries, prompts)
# By default, stored in workflow home; with --target, stored in target project
BACKLOG_DIR=""
SUMMARIES_DIR=""
LOGS_DIR=""
PROMPTS_DIR=""

# Temporary files tracking for cleanup
# Used by AI-enhanced steps to store intermediate validation results
# Cleaned up automatically via trap handler on script exit
TEMP_FILES=()

# Backlog tracking
WORKFLOW_RUN_ID="workflow_$(date +%Y%m%d_%H%M%S)"
export WORKFLOW_RUN_ID
# Note: BACKLOG_RUN_DIR, SUMMARIES_RUN_DIR, LOGS_RUN_DIR, PROMPTS_RUN_DIR are set after argument parsing
# because BACKLOG_DIR, SUMMARIES_DIR, LOGS_DIR, PROMPTS_DIR depend on --target option
BACKLOG_RUN_DIR=""
SUMMARIES_RUN_DIR=""
LOGS_RUN_DIR=""
PROMPTS_RUN_DIR=""
WORKFLOW_LOG_FILE=""

# Color codes (matching existing scripts)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Workflow tracking
declare -A WORKFLOW_STATUS
TOTAL_STEPS=15
DRY_RUN=false
INTERACTIVE_MODE=true
AUTO_MODE=false
AI_BATCH_MODE=false  # Hybrid mode: run AI non-interactively
AUTO_COMMIT=false    # Auto-commit workflow artifacts
VERBOSE=false
STOP_ON_COMPLETION=false
WORKFLOW_START_TIME=$(date +%s)

# Phase 2 enhancements (v2.3.0+) - Smart defaults for Phase 2
SMART_EXECUTION=true   # ✅ ENABLED BY DEFAULT (Phase 2) - Auto-skip unnecessary steps
SHOW_GRAPH=false
PARALLEL_EXECUTION=true  # ✅ ENABLED BY DEFAULT (Phase 2) - Parallel validation steps
USE_AI_CACHE=true  # Enabled by default
NO_RESUME=false    # When true, ignore checkpoints and start from step 0

# Enhanced validations (v2.7.0) - NEW
ENABLE_ENHANCED_VALIDATIONS=false  # Off by default - enable with --enhanced-validations
STRICT_VALIDATIONS=false            # Fail workflow if validations fail

# Machine Learning (v2.7.0) - NEW
ML_OPTIMIZE=false                   # Off by default - enable with --ml-optimize
SHOW_ML_STATUS=false                # Show ML system status and exit

# Multi-Stage Pipeline (v2.8.0) - NEW
MULTI_STAGE=false                   # Off by default - enable with --multi-stage
SHOW_PIPELINE=false                 # Show pipeline configuration and exit
MANUAL_TRIGGER=false                # Force all stages to run

# Auto-Documentation (v2.9.0) - NEW
AUTO_GENERATE_DOCS=false            # Auto-generate workflow reports
AUTO_UPDATE_CHANGELOG=false         # Auto-update CHANGELOG.md from commits
GENERATE_API_DOCS=false             # Generate API documentation

# Pre-Commit Hooks (v2.10.0)
INSTALL_HOOKS=false
UNINSTALL_HOOKS=false
TEST_HOOKS=false

# Fast Track Control (v5.0.0)
DISABLE_FAST_TRACK=false

# Workflow Dashboard (v2.11.0) - NEW
GENERATE_DASHBOARD=false            # Generate HTML dashboard
SERVE_DASHBOARD=false               # Serve dashboard on HTTP server
DASHBOARD_PORT=8080                 # Dashboard server port

# Export mode variables so they're available in step functions
export DRY_RUN
export INTERACTIVE_MODE
export AUTO_MODE
export AUTO_COMMIT
export VERBOSE
export PROJECT_ROOT
export WORKFLOW_HOME
export SMART_EXECUTION
export SHOW_GRAPH
export PARALLEL_EXECUTION
export USE_AI_CACHE
export NO_RESUME
export ENABLE_ENHANCED_VALIDATIONS
export STRICT_VALIDATIONS
export ML_OPTIMIZE
export SHOW_ML_STATUS
export MULTI_STAGE
export SHOW_PIPELINE
export MANUAL_TRIGGER
export AUTO_GENERATE_DOCS
export AUTO_UPDATE_CHANGELOG
export GENERATE_API_DOCS
export INSTALL_HOOKS
export UNINSTALL_HOOKS
export TEST_HOOKS
export DISABLE_FAST_TRACK

# Step execution control
EXECUTE_STEPS="all"  # Default: execute all steps
declare -a SELECTED_STEPS

# Configuration wizard control
INIT_CONFIG_WIZARD=false

# Analysis variables (populated during execution)
ANALYSIS_COMMITS=""
ANALYSIS_MODIFIED=""
CHANGE_SCOPE=""

# ==============================================================================
# MODULE LOADING
# ==============================================================================
# Source workflow library and step modules
WORKFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="${WORKFLOW_DIR}"  # Alias for library compatibility
export SCRIPT_DIR
LIB_DIR="${WORKFLOW_DIR}/lib"
STEPS_DIR="${WORKFLOW_DIR}/steps"

# Source library modules first (dependencies for step modules)
# Exclude test files (test_*.sh) from being sourced as they contain executable main()
for lib_file in "${LIB_DIR}"/*.sh; do
    if [[ -f "$lib_file" ]] && [[ ! "$(basename "$lib_file")" =~ ^test_ ]]; then
        # shellcheck source=/dev/null
        source "$lib_file"
    fi
done

# Source all step modules
for step_file in "${STEPS_DIR}"/step_*.sh; do
    if [[ -f "$step_file" ]]; then
        # shellcheck source=/dev/null
        source "$step_file"
    fi
done

# ==============================================================================
# GIT STATE CACHING - PERFORMANCE OPTIMIZATION (v1.5.0)
# ==============================================================================
# Implements centralized git state caching to eliminate 30+ redundant git calls
# See: /docs/WORKFLOW_PERFORMANCE_OPTIMIZATION.md
# Performance Impact: 25-30% faster execution (reduces 2m 53s to ~1m 30s-2m)
#
# NOTE: Git cache implementation moved to lib/git_cache.sh (v2.3.1)
# All git cache functions are now provided by the library module.

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

print_header() {
    local message="$1"
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  ${message}${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_step() {
    local step_num="$1"
    local step_name="$2"
    echo -e "\n${MAGENTA}▶ Step ${step_num}: ${step_name}${NC}"
}

# Prompt user for continuation after workflow completion
# Uses STOP_ON_COMPLETION variable to control behavior
prompt_for_continuation() {
    # Skip prompt in AUTO_MODE
    if [[ "$AUTO_MODE" == true ]]; then
        log_to_workflow "INFO" "AUTO_MODE: Skipping continuation prompt"
        return 0
    fi
    
    if [[ "$STOP_ON_COMPLETION" == true ]]; then
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC}  ${YELLOW}Workflow Execution Complete${NC}                                ${CYAN}║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${NC}  ${GREEN}All selected steps have been executed successfully.${NC}        ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}                                                                ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  Review the workflow summary and backlog reports above.      ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  You can now proceed with follow-up actions such as:         ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}    • Reviewing and addressing identified issues              ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}    • Committing changes with git finalization                ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}    • Running additional validation steps                     ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}    • Deploying to production environments                    ${CYAN}║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Press Enter to continue or Ctrl+C to exit...${NC}"
        read -r
        log_to_workflow "INFO" "User acknowledged workflow completion"
    fi
}

# ==============================================================================
# WORKFLOW EXECUTION LOGGING
# ==============================================================================

# Initialize workflow execution log
# Creates log file with header information
init_workflow_log() {
    mkdir -p "$(dirname "$WORKFLOW_LOG_FILE")"
    
    cat > "$WORKFLOW_LOG_FILE" << EOF
================================================================================
WORKFLOW EXECUTION LOG
================================================================================
Workflow ID: ${WORKFLOW_RUN_ID}
Script Version: ${SCRIPT_VERSION}
Started: $(date '+%Y-%m-%d %H:%M:%S')
Mode: $(if [[ "$DRY_RUN" == true ]]; then echo "DRY RUN"; elif [[ "$AUTO_MODE" == true ]]; then echo "AUTO"; else echo "INTERACTIVE"; fi)
Steps: ${EXECUTE_STEPS}
Workflow Home: ${WORKFLOW_HOME}
Project Root: ${PROJECT_ROOT}$(if [[ -n "$TARGET_PROJECT_ROOT" ]]; then echo " (target project)"; fi)

================================================================================
EXECUTION LOG
================================================================================

EOF
    
    print_info "Workflow log initialized: $WORKFLOW_LOG_FILE"
}

# Log a message to the workflow execution log
# Usage: log_to_workflow <level> <message>
# Levels: INFO, SUCCESS, WARNING, ERROR, STEP
# v2.3.1 Fix: Added safety checks for early execution (--init-config, --show-tech-stack flags)
# Previous bug: Failed when called before log directory created during flag processing
# Solution: Validate WORKFLOW_LOG_FILE and directory exist before writing
log_to_workflow() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Only log if log file directory exists (safe for early execution like --init-config)
    if [[ -n "${WORKFLOW_LOG_FILE:-}" ]]; then
        local log_dir=$(dirname "$WORKFLOW_LOG_FILE")
        if [[ -d "$log_dir" ]]; then
            echo "[${timestamp}] [${level}] ${message}" >> "$WORKFLOW_LOG_FILE"
        fi
    fi
}

# Log step start
log_step_start() {
    local step_num="$1"
    local step_name="$2"
    log_to_workflow "STEP" "========== Step ${step_num}: ${step_name} =========="
    log_to_workflow "INFO" "Step ${step_num} started"
    
    # Start metrics timer if function exists (v2.3.0)
    if type -t start_step_timer > /dev/null; then
        start_step_timer "${step_num}" "${step_name}"
    fi
}

# Log step completion
log_step_complete() {
    local step_num="$1"
    local step_name="$2"
    local status="$3"  # SUCCESS, SKIPPED, FAILED
    log_to_workflow "INFO" "Step ${step_num} completed: ${status}"
    
    # Stop metrics timer if function exists (v2.3.0)
    if type -t stop_step_timer > /dev/null; then
        local metrics_status
        case "${status}" in
            SUCCESS) metrics_status="success" ;;
            FAILED) metrics_status="failed" ;;
            SKIPPED) metrics_status="skipped" ;;
            *) metrics_status="unknown" ;;
        esac
        stop_step_timer "${step_num}" "${metrics_status}"
    fi
}

# Finalize workflow log with summary
finalize_workflow_log() {
    local end_time=$(date +%s)
    local duration=$((end_time - WORKFLOW_START_TIME))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    
    cat >> "$WORKFLOW_LOG_FILE" << EOF

================================================================================
WORKFLOW SUMMARY
================================================================================
Completed: $(date '+%Y-%m-%d %H:%M:%S')
Duration: ${minutes}m ${seconds}s
Total Steps: ${TOTAL_STEPS}

Step Status:
EOF
    
    # Add step status summary
    for i in $(seq 0 $((TOTAL_STEPS - 1))); do
        local status="${WORKFLOW_STATUS[$i]:-NOT_EXECUTED}"
        echo "  Step $i: $status" >> "$WORKFLOW_LOG_FILE"
    done
    
    # Add file locations
    cat >> "$WORKFLOW_LOG_FILE" << EOF

Output Files:
  - Backlog: ${BACKLOG_RUN_DIR}
  - Summaries: ${SUMMARIES_RUN_DIR}
  - Logs: ${LOGS_RUN_DIR}

================================================================================
END OF LOG
================================================================================
EOF
    
    print_success "Workflow log finalized: $WORKFLOW_LOG_FILE"
}

# Save issues found in a step to backlog
# Usage: save_step_issues <step_num> <step_name> <issues_content>
save_step_issues() {
    local step_num="$1"
    local step_name="$2"
    local issues_content="$3"
    
    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi
    
    # Create backlog directory structure if it doesn't exist
    mkdir -p "$BACKLOG_RUN_DIR"
    
    local step_file="${BACKLOG_RUN_DIR}/step${step_num}_${step_name// /_}.md"
    
    # Process content to convert \n to actual newlines
    # Use echo -e to interpret escape sequences
    local processed_content
    processed_content=$(echo -e "${issues_content}")
    
    # Create markdown report
    cat > "$step_file" << EOF
# Step ${step_num}: ${step_name}

**Workflow Run ID:** ${WORKFLOW_RUN_ID}
**Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')
**Status:** Issues Found

---

## Issues and Findings

${processed_content}

---

**Generated by:** ${SCRIPT_NAME} v${SCRIPT_VERSION}
EOF
    
    print_info "Saved issues to: ${step_file}"
}

# Save step conclusion summary to summaries folder
# Usage: save_step_summary <step_num> <step_name> <summary_content> <status>
save_step_summary() {
    local step_num="$1"
    local step_name="$2"
    local summary_content="$3"
    local status="${4:-✅}"
    
    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi
    
    # Create summaries directory structure if it doesn't exist
    mkdir -p "$SUMMARIES_RUN_DIR"
    
    local summary_file="${SUMMARIES_RUN_DIR}/step${step_num}_${step_name// /_}_summary.md"
    
    # Create concise summary report
    cat > "$summary_file" << EOF
# Step ${step_num}: ${step_name} - Summary

**Status:** ${status}
**Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')
**Workflow Run:** ${WORKFLOW_RUN_ID}

---

## Conclusion

${summary_content}

---

*Generated by ${SCRIPT_NAME} v${SCRIPT_VERSION}*
EOF
    
    print_info "Saved summary to: ${summary_file}"
}

# User confirmation prompt with auto-mode bypass
# Updated: Simplified to "Enter to continue or Ctrl+C to exit" pattern
confirm_action() {
    local prompt="$1"
    local default_answer="${2:-}"  # Kept for backward compatibility but ignored
    
    if [[ "$AUTO_MODE" == true ]]; then
        return 0
    fi
    
    # Play audio notification if available (v3.1.0)
    if type -t play_notification_sound > /dev/null 2>&1; then
        play_notification_sound "continue_prompt" 2>/dev/null || true
    fi
    
    echo -e "${CYAN}ℹ️  ${prompt}${NC}"
    read -r -p "$(echo -e "${YELLOW}Enter to continue or Ctrl+C to exit...${NC}")" 
    
    return 0
}

# Cleanup handler for temporary files
# Registered via trap in main() to ensure cleanup on EXIT/INT/TERM
# Pattern: Each AI-enhanced step adds temp files to TEMP_FILES array
cleanup() {
    if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
        print_info "Cleaning up temporary files..."
        log_to_workflow "INFO" "Cleaning up ${#TEMP_FILES[@]} temporary files"
        for temp_file in "${TEMP_FILES[@]}"; do
            [[ -f "$temp_file" ]] && rm -f "$temp_file"
        done
    fi
    
    # Finalize workflow log before exit
    if [[ -f "$WORKFLOW_LOG_FILE" ]]; then
        finalize_workflow_log
    fi
}

update_workflow_status() {
    local step="$1"
    local status="$2"
    WORKFLOW_STATUS["$step"]="$status"
    
    # Log status update
    log_to_workflow "INFO" "Step ${step} status updated: ${status}"
}

show_progress() {
    local completed=0
    for status in "${WORKFLOW_STATUS[@]}"; do
        [[ "$status" == "✅" ]] && ((completed++))
    done
    
    echo -e "\n${CYAN}Progress: ${completed}/${TOTAL_STEPS} steps completed${NC}"
}

# ==============================================================================
# PRE-FLIGHT CHECKS
# ==============================================================================

check_prerequisites() {
    print_header "Pre-Flight System Checks"
    log_to_workflow "INFO" "Starting pre-flight system checks"
    
    local checks_passed=true
    
    # Check 1: Verify project directory
    print_info "Checking project directory structure..."
    if [[ ! -d "$PROJECT_ROOT" ]]; then
        print_error "Project root not found: $PROJECT_ROOT"
        log_to_workflow "ERROR" "Project root not found: $PROJECT_ROOT"
        checks_passed=false
    else
        print_success "Project root: $PROJECT_ROOT"
        log_to_workflow "SUCCESS" "Project root validated: $PROJECT_ROOT"
    fi
    
    # Check 2: Verify src directory (optional for standalone workflow repo)
    if [[ ! -d "$SRC_DIR" ]]; then
        print_warning "Source directory not found: $SRC_DIR (optional for workflow-only repo)"
        log_to_workflow "WARNING" "Source directory not found: $SRC_DIR"
    else
        print_success "Source directory: $SRC_DIR"
        log_to_workflow "SUCCESS" "Source directory validated: $SRC_DIR"
    fi
    
    # Check 3: Detect project tech stack
    print_info "Detecting project technology stack..."
    local tech_stack=()
    
    # Check for Node.js/JavaScript/TypeScript
    if [[ -f "$SRC_DIR/package.json" ]] || [[ -f "$PROJECT_ROOT/package.json" ]]; then
        tech_stack+=("nodejs")
    fi
    
    # Check for Python
    if [[ -f "$PROJECT_ROOT/requirements.txt" ]] || [[ -f "$PROJECT_ROOT/setup.py" ]] || \
       [[ -f "$PROJECT_ROOT/pyproject.toml" ]] || [[ -f "$PROJECT_ROOT/Pipfile" ]]; then
        tech_stack+=("python")
    fi
    
    # Check for Ruby
    if [[ -f "$PROJECT_ROOT/Gemfile" ]]; then
        tech_stack+=("ruby")
    fi
    
    # Check for Go
    if [[ -f "$PROJECT_ROOT/go.mod" ]]; then
        tech_stack+=("go")
    fi
    
    # If no specific tech detected, assume shell/bash project
    if [[ ${#tech_stack[@]} -eq 0 ]]; then
        tech_stack+=("shell")
    fi
    
    print_success "Tech stack detected: ${tech_stack[*]}"
    log_to_workflow "INFO" "Tech stack: ${tech_stack[*]}"
    
    # Check 4: Tech-specific validations
    if [[ " ${tech_stack[*]} " =~ " nodejs " ]]; then
        # Verify package.json exists
        if [[ ! -f "$SRC_DIR/package.json" ]] && [[ ! -f "$PROJECT_ROOT/package.json" ]]; then
            print_error "package.json not found (required for Node.js projects)"
            log_to_workflow "ERROR" "package.json not found"
            checks_passed=false
        else
            print_success "package.json found"
            log_to_workflow "SUCCESS" "package.json found"
        fi
        
        # Verify Node.js/npm installation
        print_info "Checking Node.js and npm (required for this project)..."
        if ! command -v node &> /dev/null; then
            print_error "Node.js is not installed (required for Node.js projects)"
            log_to_workflow "ERROR" "Node.js not installed"
            checks_passed=false
        else
            local node_version
            node_version=$(node --version)
            print_success "Node.js: $node_version"
            log_to_workflow "SUCCESS" "Node.js detected: $node_version"
        fi
        
        if ! command -v npm &> /dev/null; then
            print_error "npm is not installed (required for Node.js projects)"
            log_to_workflow "ERROR" "npm not installed"
            checks_passed=false
        else
            local npm_version
            npm_version=$(npm --version)
            print_success "npm: $npm_version"
            log_to_workflow "SUCCESS" "npm detected: $npm_version"
        fi
    else
        # Optional checks for non-Node.js projects
        if command -v node &> /dev/null; then
            local node_version
            node_version=$(node --version)
            print_info "Node.js available: $node_version (not required for this project)"
            log_to_workflow "INFO" "Node.js detected: $node_version (optional)"
        fi
        
        if command -v npm &> /dev/null; then
            local npm_version
            npm_version=$(npm --version)
            print_info "npm available: $npm_version (not required for this project)"
            log_to_workflow "INFO" "npm detected: $npm_version (optional)"
        fi
    fi
    
    # Check 5: Verify git repository
    print_info "Checking git repository..."
    if ! git -C "$PROJECT_ROOT" rev-parse --git-dir &> /dev/null; then
        print_error "Not a git repository: $PROJECT_ROOT"
        log_to_workflow "ERROR" "Not a git repository"
        checks_passed=false
    else
        print_success "Git repository validated"
        log_to_workflow "SUCCESS" "Git repository validated"
    fi
    
    # Check 6: Check git working tree status
    if git -C "$PROJECT_ROOT" diff-index --quiet HEAD -- 2>/dev/null; then
        print_success "Git working tree is clean"
        log_to_workflow "INFO" "Git working tree is clean"
    else
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY RUN] Would execute: git add -A"
            log_to_workflow "INFO" "[DRY RUN] Would stage all changes"
        else
            git -C "$PROJECT_ROOT" add -A
            print_success "All uncommitted changes staged automatically"
            log_to_workflow "INFO" "Staged all uncommitted changes"
        fi
    fi
    
    # Check 7: Verify docs directory
    if [[ ! -d "$PROJECT_ROOT/docs" ]]; then
        print_warning "docs directory not found - will be created if needed"
        log_to_workflow "WARNING" "docs directory not found"
    else
        print_success "docs directory found"
        log_to_workflow "SUCCESS" "docs directory found"
    fi
    
    # Check 8: Optional - tree command
    if command -v tree &> /dev/null; then
        print_success "tree command available (optional)"
        log_to_workflow "SUCCESS" "tree command available"
    else
        print_info "tree command not found (optional - some validation features limited)"
        log_to_workflow "INFO" "tree command not found (optional)"
    fi
    
    # Final verdict
    echo ""
    if [[ "$checks_passed" == false ]]; then
        print_error "Pre-flight checks failed. Please resolve issues before continuing."
        log_to_workflow "ERROR" "Pre-flight checks FAILED"
        exit 1
    else
        print_success "All pre-flight checks passed!"
        log_to_workflow "SUCCESS" "All pre-flight checks PASSED"
    fi
}

validate_dependencies() {
    print_header "Validating Dependencies"
    log_to_workflow "INFO" "Starting dependency validation"
    
    # Detect project tech stack
    print_info "Detecting project technology stack..."
    local tech_stack=()
    
    # Check for Node.js/JavaScript/TypeScript
    if [[ -f "$SRC_DIR/package.json" ]] || [[ -f "$PROJECT_ROOT/package.json" ]]; then
        tech_stack+=("nodejs")
    fi
    
    # Check for Python
    if [[ -f "$PROJECT_ROOT/requirements.txt" ]] || [[ -f "$PROJECT_ROOT/setup.py" ]] || \
       [[ -f "$PROJECT_ROOT/pyproject.toml" ]] || [[ -f "$PROJECT_ROOT/Pipfile" ]]; then
        tech_stack+=("python")
    fi
    
    # Check for Ruby
    if [[ -f "$PROJECT_ROOT/Gemfile" ]]; then
        tech_stack+=("ruby")
    fi
    
    # Check for Go
    if [[ -f "$PROJECT_ROOT/go.mod" ]]; then
        tech_stack+=("go")
    fi
    
    # If no specific tech detected, assume shell/bash project
    if [[ ${#tech_stack[@]} -eq 0 ]]; then
        tech_stack+=("shell")
    fi
    
    print_success "Tech stack detected: ${tech_stack[*]}"
    log_to_workflow "INFO" "Tech stack: ${tech_stack[*]}"
    
    # Only validate dependencies for projects that need them
    if [[ " ${tech_stack[*]} " =~ " nodejs " ]]; then
        print_info "Node.js project detected - validating npm dependencies..."
        log_to_workflow "INFO" "Node.js project - checking npm dependencies"
        
        # Determine package.json location
        local pkg_dir="$SRC_DIR"
        if [[ ! -f "$SRC_DIR/package.json" ]] && [[ -f "$PROJECT_ROOT/package.json" ]]; then
            pkg_dir="$PROJECT_ROOT"
        fi
        
        cd "$pkg_dir"
        
        # Check if node_modules exists
        if [[ ! -d "node_modules" ]]; then
            print_warning "node_modules not found. Installing dependencies..."
            log_to_workflow "WARNING" "node_modules not found, installing..."
            
            if [[ "$DRY_RUN" == true ]]; then
                print_info "[DRY RUN] Would execute: npm install"
                log_to_workflow "INFO" "[DRY RUN] Would run: npm install"
            else
                npm install
                print_success "Dependencies installed"
                log_to_workflow "SUCCESS" "Dependencies installed via npm install"
            fi
        else
            print_success "node_modules directory exists"
            log_to_workflow "SUCCESS" "node_modules directory exists"
        fi
        
        # Verify Jest is available (if package.json has it as dependency)
        if grep -q '"jest"' package.json 2>/dev/null; then
            if [[ -f "node_modules/.bin/jest" ]]; then
                print_success "Jest is available"
                log_to_workflow "SUCCESS" "Jest detected in node_modules"
            else
                print_warning "Jest not found in node_modules (may need npm install)"
                log_to_workflow "WARNING" "Jest not found in node_modules"
            fi
        fi
        
        cd "$PROJECT_ROOT"
        
    elif [[ " ${tech_stack[*]} " =~ " python " ]]; then
        print_info "Python project detected - skipping npm dependency checks"
        log_to_workflow "INFO" "Python project - npm dependencies not required"
        print_success "Python project validation complete"
        
    elif [[ " ${tech_stack[*]} " =~ " ruby " ]]; then
        print_info "Ruby project detected - skipping npm dependency checks"
        log_to_workflow "INFO" "Ruby project - npm dependencies not required"
        print_success "Ruby project validation complete"
        
    elif [[ " ${tech_stack[*]} " =~ " go " ]]; then
        print_info "Go project detected - skipping npm dependency checks"
        log_to_workflow "INFO" "Go project - npm dependencies not required"
        print_success "Go project validation complete"
        
    elif [[ " ${tech_stack[*]} " =~ " shell " ]]; then
        print_info "Shell/Bash project detected - no npm dependencies needed"
        log_to_workflow "INFO" "Shell project - npm dependencies not required"
        print_success "Shell project validation complete"
        
    else
        print_info "Generic project - skipping dependency installation"
        log_to_workflow "INFO" "Generic project - dependency validation skipped"
        print_success "Dependency validation skipped"
    fi
    
    log_to_workflow "SUCCESS" "Dependency validation completed"
}

# ==============================================================================
# PHASE 2: CORE WORKFLOW FUNCTIONS - AI-ENHANCED STEPS
# ==============================================================================


# ------------------------------------------------------------------------------
# STEP 2: AI-POWERED CONSISTENCY ANALYSIS
# ------------------------------------------------------------------------------
# Persona: Senior Technical Documentation Specialist + Information Architect
# Expertise: Documentation QA, technical writing, cross-reference validation
# 
# TWO-PHASE VALIDATION ARCHITECTURE:
#
# Phase 1: Automated Detection
#   - Broken file references (regex-based extraction)
#   - Missing documentation files
#   - Version number inconsistencies
#   → Results logged to temporary file for AI analysis
#
# Phase 2: AI-Powered Deep Analysis (5 categories)
#   1. Cross-Reference Validation
#   2. Content Synchronization
#   3. Architecture Consistency
#   4. Broken Reference Remediation
#   5. Quality Checks
#   → Comprehensive report with actionable recommendations
#
# Smart Triggering:
#   - Auto-trigger: Issues found in Phase 1
#   - User choice: Interactive mode
#   - Skip: Auto mode with clean results
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# STEP 3: AI-POWERED SCRIPT REFERENCE VALIDATION
# ------------------------------------------------------------------------------
# Persona: Senior Technical Documentation Specialist + DevOps Documentation Expert
# Expertise: Shell script docs, automation workflows, CLI tool guides
#
# WHY DEVOPS CONTEXT?
#   - Project uses shell scripts for deployment/automation
#   - Scripts work together in complex workflows
#   - CLI tool documentation patterns required
#
# TWO-PHASE VALIDATION ARCHITECTURE:
#
# Phase 1: Automated Detection (4 checks)
#   1. Script reference checks (documented scripts exist)
#   2. Executable permission validation
#   3. Script inventory gathering (count, list)
#   4. Undocumented script detection (NEW - finds "orphans")
#
# Phase 2: AI-Powered Deep Analysis (5 categories)
#   1. Script-to-Documentation Mapping
#   2. Reference Accuracy (CLI args, versions, paths)
#   3. Documentation Completeness
#   4. Shell Script Best Practices
#   5. Integration Documentation
#
# INNOVATION: Detects both missing scripts (404s) AND undocumented scripts (orphans)
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# REMAINING WORKFLOW STEPS (Steps 0, 4-11)
# ------------------------------------------------------------------------------
# Note: These are placeholder implementations for the complete workflow
# The three AI-enhanced steps (1, 2, 3) are the focus of v1.1.0
# Additional steps can be enhanced with AI personas in future versions
# ------------------------------------------------------------------------------

# Steps 4-10: Placeholder implementations
# ------------------------------------------------------------------------------
# STEP 4: AI-POWERED DIRECTORY STRUCTURE VALIDATION
# ------------------------------------------------------------------------------
# Persona: Software Architect + Technical Documentation Specialist
# Expertise: Project structure conventions, architectural patterns, documentation alignment
#
# WHY SOFTWARE ARCHITECT PERSONA?
#   - Directory structure reflects architectural decisions
#   - Project organization impacts maintainability
#   - Structure documentation must match reality
#   - Architectural patterns need consistency validation
#
# TWO-PHASE VALIDATION ARCHITECTURE:
#
# Phase 1: Automated Structure Detection
#   1. Directory inventory (tree structure analysis)
#   2. Expected vs actual structure comparison
#   3. Missing critical directories detection
#   4. Undocumented directories identification
#
# Phase 2: AI-Powered Architectural Analysis
#   1. Structure-to-Documentation Mapping
#   2. Architectural Pattern Validation
#   3. Naming Convention Consistency
#   4. Best Practice Compliance
#   5. Scalability and Maintainability Assessment
#
# INNOVATION: Validates both documented structure AND architectural best practices
# ------------------------------------------------------------------------------
# Steps 5-10: Placeholder implementations

# ------------------------------------------------------------------------------
# STEP 5: AI-POWERED TEST REVIEW AND GENERATION
# ------------------------------------------------------------------------------
# Persona: QA Engineer + Test Automation Specialist
# Expertise: Testing strategies, Jest framework, coverage analysis, TDD/BDD practices
#
# WHY QA ENGINEER + TEST AUTOMATION PERSONA?
#   - Test review requires QA mindset (what should be tested?)
#   - Test generation needs automation expertise
#   - Coverage analysis requires understanding of testing strategies
#   - Jest-specific knowledge for proper test structure
#
# TWO-PHASE VALIDATION ARCHITECTURE:
#
# Phase 1: Automated Test Analysis
#   1. Test file inventory and organization
#   2. Coverage report analysis (if available)
#   3. Untested code detection
#   4. Test-to-code ratio calculation
#
# Phase 2: AI-Powered Test Strategy Analysis
#   1. Existing Test Quality Assessment
#   2. Coverage Gap Identification
#   3. Test Case Generation Recommendations
#   4. Testing Best Practices Validation
#   5. CI/CD Integration Readiness
#
# INNOVATION: Combines coverage analysis with AI-powered test generation recommendations
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# STEP 6: AI-POWERED TEST GENERATION
# ------------------------------------------------------------------------------
# Persona: TDD Expert + Code Generation Specialist
# Expertise: Test-driven development, Jest patterns, code generation, edge case analysis
#
# WHY TDD EXPERT + CODE GENERATION PERSONA?
#   - Test generation requires TDD mindset (test-first thinking)
#   - Code generation needs deep understanding of testing patterns
#   - Edge case identification requires expert analysis
#   - Jest code generation requires framework expertise
#
# TWO-PHASE GENERATION ARCHITECTURE:
#
# Phase 1: Automated Gap Analysis
#   1. Identify untested modules/functions
#   2. Analyze code complexity (functions, branches)
#   3. Detect missing edge case coverage
#   4. Prioritize test generation targets
#
# Phase 2: AI-Powered Test Code Generation
#   1. Generate Unit Test Templates
#   2. Create Integration Test Scaffolds
#   3. Generate Edge Case Test Scenarios
#   4. Produce Mock and Stub Patterns
#   5. Generate Test Data Fixtures
#
# INNOVATION: AI generates actual test code based on Step 5 recommendations
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# STEP 7: AI-POWERED TEST EXECUTION AND ANALYSIS
# ------------------------------------------------------------------------------
# Persona: CI/CD Engineer + Test Results Analyst  
# Expertise: Test execution, failure diagnosis, coverage analysis, CI/CD best practices
#
# WHY CI/CD ENGINEER + TEST RESULTS ANALYST PERSONA?
#   - Test execution requires CI/CD pipeline knowledge
#   - Failure analysis needs diagnostic expertise
#   - Coverage interpretation requires analytical skills
#   - Test optimization needs CI/CD best practices
#
# TWO-PHASE EXECUTION ARCHITECTURE:
#
# Phase 1: Automated Test Execution
#   1. Run full test suite (npm test)
#   2. Generate coverage report
#   3. Parse test results and failures
#   4. Extract coverage metrics
#
# Phase 2: AI-Powered Results Analysis
#   1. Test Failure Root Cause Analysis
#   2. Coverage Gap Interpretation
#   3. Performance Bottleneck Detection
#   4. Flaky Test Identification
#   5. CI/CD Optimization Recommendations
#
# INNOVATION: AI analyzes test results and provides actionable failure diagnostics
# ------------------------------------------------------------------------------
#
# WHY CI/CD ENGINEER + TEST RESULTS ANALYST PERSONA?
#   - Test execution requires CI/CD pipeline knowledge
#   - Failure analysis needs diagnostic expertise
#   - Coverage interpretation requires analytical skills
#   - Test optimization needs CI/CD best practices
#
# TWO-PHASE EXECUTION ARCHITECTURE:
#
# Phase 1: Automated Test Execution
#   1. Run full test suite (npm test)
#   2. Generate coverage report
#   3. Parse test results and failures
#   4. Extract coverage metrics
#
# Phase 2: AI-Powered Results Analysis
#   1. Test Failure Root Cause Analysis
#   2. Coverage Gap Interpretation
#   3. Performance Bottleneck Detection
#   4. Flaky Test Identification
#   5. CI/CD Optimization Recommendations
#

# ------------------------------------------------------------------------------
# STEP 8: AI-POWERED DEPENDENCY VALIDATION
# ------------------------------------------------------------------------------
# Persona: DevOps Engineer + Package Management Specialist
# Expertise: Dependency management, security audits, version compatibility, npm/yarn
#
# WHY DEVOPS ENGINEER + PACKAGE MANAGEMENT PERSONA?
#   - Dependency validation requires DevOps infrastructure knowledge
#   - Security audit needs package management expertise
#   - Version compatibility requires ecosystem understanding
#   - Environment management needs DevOps best practices
#
# TWO-PHASE VALIDATION ARCHITECTURE:
#
# Phase 1: Automated Dependency Analysis
#   1. Check package.json existence and validity
#   2. Run npm audit for security vulnerabilities
#   3. Check for outdated packages
#   4. Verify lockfile integrity
#
# Phase 2: AI-Powered Dependency Strategy
#   1. Security Vulnerability Assessment
#   2. Version Compatibility Analysis
#   3. Dependency Tree Optimization
#   4. Environment Configuration Review
#   5. Update Strategy Recommendations
#
# INNOVATION: AI analyzes dependency health and provides security-first upgrade paths
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# STEP 9: AI-POWERED CODE QUALITY VALIDATION
# ------------------------------------------------------------------------------
# Persona: Software Quality Engineer + Code Review Specialist
# Expertise: Code quality standards, static analysis, linting, maintainability, best practices
#
# WHY SOFTWARE QUALITY ENGINEER + CODE REVIEW PERSONA?
#   - Code quality requires SQE methodology and standards
#   - Code review needs expert pattern recognition
#   - Static analysis requires quality engineering knowledge
#   - Maintainability assessment needs code review expertise
#
# TWO-PHASE VALIDATION ARCHITECTURE:
#
# Phase 1: Automated Code Quality Checks
#   1. JavaScript/HTML/CSS file enumeration
#   2. Code complexity analysis (file sizes, line counts)
#   3. Naming convention validation
#   4. Code duplication detection (basic)
#
# Phase 2: AI-Powered Code Quality Review
#   1. Code Standards Compliance Assessment
#   2. Best Practices Validation
#   3. Maintainability & Readability Analysis
#   4. Anti-Pattern Detection
#   5. Refactoring Recommendations
#
# INNOVATION: AI performs deep code review analyzing patterns, maintainability, and quality
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# STEP 10: AI-POWERED CONTEXT ANALYSIS & WORKFLOW ADAPTATION
# ------------------------------------------------------------------------------
# Persona: Technical Project Manager + Workflow Orchestration Specialist
# Expertise: Workflow analysis, context synthesis, adaptive planning, strategic recommendations
#
# WHY TECHNICAL PROJECT MANAGER + WORKFLOW ORCHESTRATION PERSONA?
#   - Context analysis requires holistic project understanding
#   - Workflow adaptation needs orchestration expertise
#   - Strategic recommendations require project management perspective
#   - Integration synthesis needs technical PM knowledge
#
# TWO-PHASE ANALYSIS ARCHITECTURE:
#
# Phase 1: Automated Context Collection
#   1. Workflow execution summary (all previous steps)
#   2. Git repository state analysis
#   3. Change impact assessment
#   4. Issue and warning aggregation
#
# Phase 2: AI-Powered Strategic Analysis
#   1. Workflow Effectiveness Assessment
#   2. Context-Aware Recommendations
#   3. Adaptive Workflow Optimization
#   4. Next Steps Strategic Planning
#   5. Risk & Opportunity Identification
#
# INNOVATION: AI analyzes entire workflow context and provides strategic adaptation recommendations
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# STEP 11: AI-POWERED GIT FINALIZATION & COMMIT MESSAGE GENERATION
# ------------------------------------------------------------------------------
# Persona: Git Workflow Specialist + Technical Communication Expert
# Expertise: Conventional commits, semantic versioning, git best practices, technical writing
#
# WHY GIT WORKFLOW SPECIALIST + TECHNICAL COMMUNICATION PERSONA?
#   - Commit messages require conventional commit standards
#   - Technical communication ensures clarity and context
#   - Git workflow expertise guides proper branching and merging
#   - Semantic versioning knowledge informs commit type selection
#
# TWO-PHASE FINALIZATION ARCHITECTURE:
#
# Phase 1: Automated Git Analysis
#   1. Repository state analysis (status, branch, upstream)
#   2. Change enumeration (modified, staged, untracked)
#   3. Diff statistics and file categorization
#   4. Commit type inference (feat/fix/docs/chore/refactor)
#
# Phase 2: AI-Powered Commit Message Generation
#   1. Conventional Commit Message Crafting
#   2. Semantic Context Integration
#   3. Change Impact Description
#   4. Breaking Change Detection
#   5. Commit Body & Footer Generation
#
# INNOVATION: AI generates professional conventional commit messages with context
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# STEP 12: MARKDOWN LINTING
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# STEP SELECTION & VALIDATION
# ------------------------------------------------------------------------------
validate_and_parse_steps() {
    if [[ "$EXECUTE_STEPS" == "all" ]]; then
        SELECTED_STEPS=(0 0a 0b 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)
        print_info "Step selection: All steps (0, 0a, 0b, 1-15)"
        return 0
    fi
    
    # Parse comma-separated step list
    IFS=',' read -ra SELECTED_STEPS <<< "$EXECUTE_STEPS"
    
    # Validate each step number
    for step in "${SELECTED_STEPS[@]}"; do
        # Allow alphanumeric steps like 0a, 0b
        if ! [[ "$step" =~ ^[0-9]+[a-z]?$ ]]; then
            print_error "Invalid step number: $step (valid: 0-15 or 0a, 0b)"
            exit 1
        fi
    done
    
    # Sort and deduplicate steps
    SELECTED_STEPS=($(echo "${SELECTED_STEPS[@]}" | tr ' ' '\n' | sort -n | uniq))
    
    print_info "Step selection: ${SELECTED_STEPS[*]}"
}

should_execute_step() {
    local step_num="$1"
    
    # If executing all steps, always return true
    if [[ "$EXECUTE_STEPS" == "all" ]]; then
        return 0
    fi
    
    # Check if step is in selected steps
    for selected in "${SELECTED_STEPS[@]}"; do
        if [[ "$selected" == "$step_num" ]]; then
            return 0
        fi
    done
    
    return 1
}

# ------------------------------------------------------------------------------
# STEP EXECUTION WRAPPER FOR MULTI-STAGE PIPELINE
# ------------------------------------------------------------------------------

# Execute a single workflow step
# Used by multi-stage pipeline for stage-based execution
# Args: $1 = step_number
# Returns: 0 on success, 1 on failure
execute_step() {
    local step_num="$1"
    local step_name=""
    
    case "$step_num" in
        0)
            step_name="Pre-Analysis"
            if step0_analyze_changes; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        0b)
            step_name="Bootstrap Documentation"
            if step0b_bootstrap_documentation; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        1)
            step_name="Documentation Updates"
            if step1_update_documentation; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        2)
            step_name="Consistency Analysis"
            if step2_check_consistency; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        3)
            step_name="Script Reference Validation"
            if step3_validate_script_references; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        4)
            step_name="Directory Structure Validation"
            if step4_validate_directory_structure; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        5)
            step_name="Test Review"
            if step5_review_existing_tests; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        6)
            step_name="Test Generation"
            if step6_generate_new_tests; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        7)
            step_name="Test Execution"
            if step7_execute_test_suite; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        8)
            step_name="Dependency Validation"
            if step8_validate_dependencies; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        9)
            step_name="Code Quality Validation"
            if step9_code_quality_validation; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        10)
            step_name="Context Analysis"
            if step10_context_analysis; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        11)
            step_name="Git Finalization"
            if step11_git_finalization; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        12)
            step_name="Markdown Linting"
            if step12_markdown_linting; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        13)
            step_name="Prompt Engineer Analysis"
            if step13_prompt_engineer_analysis; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        14)
            step_name="UX Analysis"
            if step14_ux_analysis; then
                update_workflow_status "$step_num" "✅"
                log_step_complete "$step_num" "$step_name" "SUCCESS"
                return 0
            else
                update_workflow_status "$step_num" "❌"
                log_step_complete "$step_num" "$step_name" "FAILED"
                return 1
            fi
            ;;
        *)
            print_error "Unknown step number: $step_num"
            return 1
            ;;
    esac
}

# ------------------------------------------------------------------------------
# WORKFLOW ORCHESTRATION
# ------------------------------------------------------------------------------
execute_full_workflow() {
    print_header "Executing Workflow"
    log_to_workflow "INFO" "Starting workflow execution"
    log_to_workflow "INFO" "Execution mode: $(if [[ "$DRY_RUN" == true ]]; then echo "DRY RUN"; elif [[ "$AUTO_MODE" == true ]]; then echo "AUTO"; else echo "INTERACTIVE"; fi)"
    log_to_workflow "INFO" "Change impact level: ${CHANGE_IMPACT:-Unknown}"
    
    # Validate and parse step selection
    validate_and_parse_steps
    log_to_workflow "INFO" "Step selection: ${EXECUTE_STEPS}"
    
    # Check for docs-only fast track (v2.7.0 - HIGHEST PRIORITY)
    # This is the fastest execution path for documentation-only changes (~1.5 min)
    # Can be disabled with --no-fast-track flag
    if [[ "${DOCS_ONLY_FAST_TRACK:-false}" == "true" && "$DRY_RUN" != true && "${DISABLE_FAST_TRACK:-false}" != "true" ]]; then
        print_info "🚀🚀🚀 Docs-Only Fast Track Enabled"
        print_info "Expected time: 90-120 seconds (93% faster than baseline)"
        echo ""
        
        if type -t execute_docs_only_fast_track > /dev/null 2>&1; then
            execute_docs_only_fast_track
            return $?
        else
            print_warning "execute_docs_only_fast_track function not found - falling back to standard execution"
        fi
    elif [[ "${DOCS_ONLY_FAST_TRACK:-false}" == "true" && "${DISABLE_FAST_TRACK:-false}" == "true" ]]; then
        print_info "Fast track mode available but disabled via --no-fast-track flag"
        log_to_workflow "INFO" "Docs-only fast track disabled by user"
    fi
    
    # Check for 4-track parallel execution (v2.7.0 - SECOND PRIORITY)
    # This provides maximum performance for full-stack changes with test sharding
    if [[ "${FULL_CHANGES_4TRACK:-false}" == "true" && "$DRY_RUN" != true ]]; then
        print_info "⚡⚡⚡⚡ 4-Track Parallel Execution Mode Enabled"
        print_info "Expected time: 10-11 minutes (52-57% faster than baseline)"
        echo ""
        
        if type -t execute_4track_parallel > /dev/null 2>&1; then
            execute_4track_parallel
            return $?
        else
            print_warning "execute_4track_parallel function not found - falling back to 3-track execution"
        fi
    fi
    
    # Check for 3-track parallel execution (v2.6.1 - THIRD PRIORITY)
    # This provides maximum performance by running all compatible steps in parallel
    if [[ "${PARALLEL_TRACKS:-false}" == "true" && "$DRY_RUN" != true ]]; then
        print_info "⚡⚡⚡ 3-Track Parallel Execution Mode Enabled"
        print_info "Expected time savings: ~46% compared to sequential execution"
        echo ""
        
        if type -t execute_parallel_tracks > /dev/null 2>&1; then
            execute_parallel_tracks
            return $?
        else
            print_warning "execute_parallel_tracks function not found - falling back to standard execution"
        fi
    fi
    
    # Standard execution path (sequential or limited parallel)
    local failed_step=""
    local executed_steps=0
    local skipped_steps=0
    
    # Check for resume point
    local resume_from=${RESUME_FROM_STEP:-0}
    if [[ $resume_from -gt 0 ]]; then
        print_info "Resuming from Step ${resume_from}"
        log_to_workflow "INFO" "Resuming workflow from Step ${resume_from}"
    fi
    
    # Execute Step 0 (Pre-Analysis) - always first unless resuming
    if [[ $resume_from -le 0 ]] && should_execute_step 0; then
        log_step_start 0 "Pre-Analysis"
        if step0_analyze_changes; then
            update_workflow_status 0 "✅"
            log_step_complete 0 "Pre-Analysis" "SUCCESS"
            ((executed_steps++)) || true
            save_checkpoint 0
        else
            failed_step="Step 0"
            update_workflow_status 0 "❌"
            log_step_complete 0 "Pre-Analysis" "FAILED"
        fi
    elif [[ $resume_from -le 0 ]]; then
        print_info "Skipping Step 0 (not selected)"
        log_to_workflow "INFO" "Skipping Step 0 (not selected)"
        log_step_complete 0 "Pre-Analysis" "SKIPPED"
        ((skipped_steps++)) || true
    else
        print_info "Skipping Step 0 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Execute Step 0a (Version Update - Pre-Processing) - runs between 0 and 1
    # This is a pre-processing step that must run before documentation analysis
    if [[ -z "$failed_step" && $resume_from -le 0 ]] && should_execute_step 0; then
        log_step_start "0a" "Version Update (Pre-Processing)"
        if step0a_version_update; then
            update_workflow_status "0a" "✅"
            log_step_complete "0a" "Version Update" "SUCCESS"
            ((executed_steps++)) || true
            save_checkpoint "0a"
        else
            failed_step="Step 0a"
            update_workflow_status "0a" "❌"
            log_step_complete "0a" "Version Update" "FAILED"
        fi
    elif [[ $resume_from -gt 0 ]]; then
        print_info "Skipping Step 0a (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Execute Step 0b (Bootstrap Documentation) - runs after 0a, before 1
    # NEW in v3.1.1: Generate comprehensive documentation from scratch
    if [[ -z "$failed_step" && $resume_from -le 0 ]] && should_execute_step 0; then
        log_step_start "0b" "Bootstrap Documentation"
        if step0b_bootstrap_documentation; then
            update_workflow_status "0b" "✅"
            log_step_complete "0b" "Bootstrap Documentation" "SUCCESS"
            ((executed_steps++)) || true
            save_checkpoint "0b"
        else
            failed_step="Step 0b"
            update_workflow_status "0b" "❌"
            log_step_complete "0b" "Bootstrap Documentation" "FAILED"
        fi
    elif [[ $resume_from -gt 0 ]]; then
        print_info "Skipping Step 0b (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Execute Steps 1-4 (Validation) - can run in parallel if enabled
    local can_parallelize=false
    if [[ -z "$failed_step" && $resume_from -le 1 ]]; then
        # Check if all validation steps are selected and no resume conflict
        if should_execute_step 1 && should_execute_step 2 && should_execute_step 3 && should_execute_step 4; then
            can_parallelize=true
        fi
    fi
    
    if [[ "$can_parallelize" == true && -z "$DRY_RUN" && "${PARALLEL_EXECUTION}" == "true" ]]; then
        # Parallel execution of validation steps (v2.3.0 optimization)
        echo ""
        print_info "⚡ Parallel execution enabled for validation steps (1-4)"
        print_info "Expected time savings: ~270 seconds"
        if execute_parallel_validation; then
            update_workflow_status 1 "✅"
            update_workflow_status 2 "✅"
            update_workflow_status 3 "✅"
            update_workflow_status 4 "✅"
            ((executed_steps+=4)) || true
            save_checkpoint 4
        else
            failed_step="Parallel Validation"
        fi
    else
        if [[ "$can_parallelize" == true && "${PARALLEL_EXECUTION}" != "true" ]]; then
            print_info "Parallel execution available but not enabled (use --parallel flag)"
        fi
        # Sequential execution (standard mode or selective steps)
        if [[ -z "$failed_step" && $resume_from -le 1 ]] && should_execute_step 1; then
            log_step_start 1 "Documentation Updates"
            step1_update_documentation || { failed_step="Step 1"; }
            [[ -z "$failed_step" ]] && update_workflow_status 1 "✅"
            ((executed_steps++)) || true
            save_checkpoint 1
        elif [[ -z "$failed_step" && $resume_from -le 1 ]]; then
            print_info "Skipping Step 1 (not selected)"
            log_to_workflow "INFO" "Skipping Step 1 (not selected)"
            ((skipped_steps++)) || true
        elif [[ $resume_from -gt 1 ]]; then
            print_info "Skipping Step 1 (resuming from checkpoint)"
            ((skipped_steps++)) || true
        fi
        
        if [[ -z "$failed_step" && $resume_from -le 2 ]] && should_execute_step 2; then
            log_step_start 2 "Consistency Analysis"
            step2_check_consistency || { failed_step="Step 2"; }
            [[ -z "$failed_step" ]] && update_workflow_status 2 "✅"
            ((executed_steps++)) || true
            save_checkpoint 2
        elif [[ -z "$failed_step" && $resume_from -le 2 ]]; then
            print_info "Skipping Step 2 (not selected)"
            log_to_workflow "INFO" "Skipping Step 2 (not selected)"
            ((skipped_steps++)) || true
        elif [[ $resume_from -gt 2 ]]; then
            print_info "Skipping Step 2 (resuming from checkpoint)"
            ((skipped_steps++)) || true
        fi
        
        if [[ -z "$failed_step" && $resume_from -le 3 ]] && should_execute_step 3; then
            log_step_start 3 "Script Reference Validation"
            step3_validate_script_references || { failed_step="Step 3"; }
            [[ -z "$failed_step" ]] && update_workflow_status 3 "✅"
            ((executed_steps++)) || true
            save_checkpoint 3
        elif [[ -z "$failed_step" && $resume_from -le 3 ]]; then
            print_info "Skipping Step 3 (not selected)"
            log_to_workflow "INFO" "Skipping Step 3 (not selected)"
            ((skipped_steps++)) || true
        elif [[ $resume_from -gt 3 ]]; then
            print_info "Skipping Step 3 (resuming from checkpoint)"
            ((skipped_steps++)) || true
        fi
    
        if [[ -z "$failed_step" && $resume_from -le 4 ]] && should_execute_step 4; then
            log_step_start 4 "Directory Structure Validation"
            step4_validate_directory_structure || { failed_step="Step 4"; }
            [[ -z "$failed_step" ]] && update_workflow_status 4 "✅"
            ((executed_steps++)) || true
            save_checkpoint 4
        elif [[ -z "$failed_step" && $resume_from -le 4 ]]; then
            print_info "Skipping Step 4 (not selected)"
            log_to_workflow "INFO" "Skipping Step 4 (not selected)"
            ((skipped_steps++)) || true
        elif [[ $resume_from -gt 4 ]]; then
            print_info "Skipping Step 4 (resuming from checkpoint)"
            ((skipped_steps++)) || true
        fi
    fi
    
    # Step 5: Test Review (conditional execution based on impact)
    if [[ -z "$failed_step" && $resume_from -le 5 ]] && should_execute_step 5; then
        if [[ "${SMART_EXECUTION}" == "true" ]] && should_skip_step_by_impact 5 "${CHANGE_IMPACT}"; then
            print_info "⚡ Step 5 skipped (smart execution - ${CHANGE_IMPACT} impact)"
            log_to_workflow "INFO" "Step 5 skipped - ${CHANGE_IMPACT} impact (no code/test changes)"
            ((skipped_steps++)) || true
        else
            log_step_start 5 "Test Review"
            step5_review_existing_tests || { failed_step="Step 5"; }
            [[ -z "$failed_step" ]] && update_workflow_status 5 "✅"
            ((executed_steps++)) || true
            save_checkpoint 5
        fi
    elif [[ -z "$failed_step" && $resume_from -le 5 ]]; then
        print_info "Skipping Step 5 (not selected)"
        log_to_workflow "INFO" "Skipping Step 5 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 5 ]]; then
        print_info "Skipping Step 5 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 6: Test Generation (conditional execution based on impact)
    if [[ -z "$failed_step" && $resume_from -le 6 ]] && should_execute_step 6; then
        if [[ "${SMART_EXECUTION}" == "true" ]] && should_skip_step_by_impact 6 "${CHANGE_IMPACT}"; then
            print_info "⚡ Step 6 skipped (smart execution - ${CHANGE_IMPACT} impact)"
            log_to_workflow "INFO" "Step 6 skipped - ${CHANGE_IMPACT} impact (no code changes)"
            ((skipped_steps++)) || true
        else
            log_step_start 6 "Test Generation"
            step6_generate_new_tests || { failed_step="Step 6"; }
            [[ -z "$failed_step" ]] && update_workflow_status 6 "✅"
            ((executed_steps++)) || true
            save_checkpoint 6
        fi
    elif [[ -z "$failed_step" && $resume_from -le 6 ]]; then
        print_info "Skipping Step 6 (not selected)"
        log_to_workflow "INFO" "Skipping Step 6 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 6 ]]; then
        print_info "Skipping Step 6 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 7: Test Execution (conditional execution based on impact)
    if [[ -z "$failed_step" && $resume_from -le 7 ]] && should_execute_step 7; then
        if [[ "${SMART_EXECUTION}" == "true" ]] && should_skip_step_by_impact 7 "${CHANGE_IMPACT}"; then
            print_info "⚡ Step 7 skipped (smart execution - ${CHANGE_IMPACT} impact)"
            log_to_workflow "INFO" "Step 7 skipped - ${CHANGE_IMPACT} impact (no code/test changes)"
            ((skipped_steps++)) || true
        else
            log_step_start 7 "Test Execution"
            # Test execution validates its own status internally to prevent silent failures
            if step7_execute_test_suite; then
                # Step already updated its status based on test results
                :  # No-op - status already set correctly
            else
                failed_step="Step 7"
                # Step already set status to ❌ if tests failed
            fi
            ((executed_steps++)) || true
            save_checkpoint 7
        fi
    elif [[ -z "$failed_step" && $resume_from -le 7 ]]; then
        print_info "Skipping Step 7 (not selected)"
        log_to_workflow "INFO" "Skipping Step 7 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 7 ]]; then
        print_info "Skipping Step 7 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 8: Dependency Validation (conditional execution based on impact)
    if [[ -z "$failed_step" && $resume_from -le 8 ]] && should_execute_step 8; then
        if [[ "${SMART_EXECUTION}" == "true" ]] && should_skip_step_by_impact 8 "${CHANGE_IMPACT}"; then
            print_info "⚡ Step 8 skipped (smart execution - ${CHANGE_IMPACT} impact)"
            log_to_workflow "INFO" "Step 8 skipped - ${CHANGE_IMPACT} impact (dependencies unchanged)"
            ((skipped_steps++)) || true
        else
            log_step_start 8 "Dependency Validation"
            step8_validate_dependencies || { failed_step="Step 8"; }
            [[ -z "$failed_step" ]] && update_workflow_status 8 "✅"
            ((executed_steps++)) || true
            save_checkpoint 8
        fi
    elif [[ -z "$failed_step" && $resume_from -le 8 ]]; then
        print_info "Skipping Step 8 (not selected)"
        log_to_workflow "INFO" "Skipping Step 8 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 8 ]]; then
        print_info "Skipping Step 8 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 9: Code Quality Validation (conditional execution based on impact)
    if [[ -z "$failed_step" && $resume_from -le 9 ]] && should_execute_step 9; then
        if [[ "${SMART_EXECUTION}" == "true" ]] && should_skip_step_by_impact 9 "${CHANGE_IMPACT}"; then
            print_info "⚡ Step 9 skipped (smart execution - ${CHANGE_IMPACT} impact)"
            log_to_workflow "INFO" "Step 9 skipped - ${CHANGE_IMPACT} impact (no code changes)"
            ((skipped_steps++)) || true
        else
            log_step_start 9 "Code Quality Validation"
            step9_code_quality_validation || { failed_step="Step 9"; }
            [[ -z "$failed_step" ]] && update_workflow_status 9 "✅"
            ((executed_steps++)) || true
            save_checkpoint 9
        fi
    elif [[ -z "$failed_step" && $resume_from -le 9 ]]; then
        print_info "Skipping Step 9 (not selected)"
        log_to_workflow "INFO" "Skipping Step 9 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 9 ]]; then
        print_info "Skipping Step 9 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Enhanced Validations (v2.7.0 - NEW)
    # Run additional validation checks if enabled
    if [[ -z "$failed_step" && "${ENABLE_ENHANCED_VALIDATIONS}" == "true" ]]; then
        echo ""
        print_header "Enhanced Validations"
        
        if type -t run_enhanced_validations > /dev/null 2>&1; then
            local validation_mode=""
            if [[ "${STRICT_VALIDATIONS}" == "true" ]]; then
                validation_mode="--strict"
            fi
            
            if ! run_enhanced_validations $validation_mode; then
                if [[ "${STRICT_VALIDATIONS}" == "true" ]]; then
                    failed_step="Enhanced Validations"
                    print_error "Enhanced validations failed in strict mode"
                else
                    print_warning "Some enhanced validations failed (non-strict mode - continuing)"
                fi
            fi
        else
            print_warning "Enhanced validations requested but module not loaded"
        fi
        
        echo ""
    fi
    
    # Step 10: Context Analysis (with checkpoint)
    if [[ -z "$failed_step" && $resume_from -le 10 ]] && should_execute_step 10; then
        log_step_start 10 "Context Analysis"
        step10_context_analysis || { failed_step="Step 10"; }
        [[ -z "$failed_step" ]] && update_workflow_status 10 "✅"
        ((executed_steps++)) || true
        save_checkpoint 10
    elif [[ -z "$failed_step" && $resume_from -le 10 ]]; then
        print_info "Skipping Step 10 (not selected)"
        log_to_workflow "INFO" "Skipping Step 10 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 10 ]]; then
        print_info "Skipping Step 10 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 12: Markdown Linting (with checkpoint)
    # MUST run before Step 11 (Git Finalization)
    if [[ -z "$failed_step" && $resume_from -le 12 ]] && should_execute_step 12; then
        log_step_start 12 "Markdown Linting"
        step12_markdown_linting || { failed_step="Step 12"; }
        [[ -z "$failed_step" ]] && update_workflow_status 12 "✅"
        ((executed_steps++)) || true
        save_checkpoint 12
    elif [[ -z "$failed_step" && $resume_from -le 12 ]]; then
        print_info "Skipping Step 12 (not selected)"
        log_to_workflow "INFO" "Skipping Step 12 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 12 ]]; then
        print_info "Skipping Step 12 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 13: Prompt Engineer Analysis (with checkpoint)
    # MUST run before Step 11 (Git Finalization)
    if [[ -z "$failed_step" && $resume_from -le 13 ]] && should_execute_step 13; then
        log_step_start 13 "Prompt Engineer Analysis"
        step13_prompt_engineer_analysis || { failed_step="Step 13"; }
        ((executed_steps++)) || true
        save_checkpoint 13
    elif [[ -z "$failed_step" && $resume_from -le 13 ]]; then
        print_info "Skipping Step 13 (not selected)"
        log_to_workflow "INFO" "Skipping Step 13 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 13 ]]; then
        print_info "Skipping Step 13 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 14: UX Analysis (with checkpoint)
    # MUST run before Step 11 (Git Finalization)
    if [[ -z "$failed_step" && $resume_from -le 14 ]] && should_execute_step 14; then
        log_step_start 14 "UX Analysis"
        step14_ux_analysis || { failed_step="Step 14"; }
        ((executed_steps++)) || true
        save_checkpoint 14
    elif [[ -z "$failed_step" && $resume_from -le 14 ]]; then
        print_info "Skipping Step 14 (not selected)"
        log_to_workflow "INFO" "Skipping Step 14 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 14 ]]; then
        print_info "Skipping Step 14 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    
    # Step 15: AI-Powered Semantic Version Update (with checkpoint)
    # NEW in v2.13.0: Runs after all analysis steps, before Git Finalization
    if [[ -z "$failed_step" && $resume_from -le 15 ]] && should_execute_step 15; then
        log_step_start 15 "AI-Powered Semantic Version Update"
        step15_version_update || { failed_step="Step 15"; }
        [[ -z "$failed_step" ]] && update_workflow_status 15 "✅"
        ((executed_steps++)) || true
        save_checkpoint 15
    elif [[ -z "$failed_step" && $resume_from -le 15 ]]; then
        print_info "Skipping Step 15 (not selected)"
        log_to_workflow "INFO" "Skipping Step 15 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 15 ]]; then
        print_info "Skipping Step 15 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    
    # Step 11: Git Finalization (with checkpoint)
    # MANDATORY: MUST BE THE FINAL STEP - runs after all analysis and validation steps
    if [[ -z "$failed_step" && $resume_from -le 11 ]] && should_execute_step 11; then
        log_step_start 11 "Git Finalization"
        step11_git_finalization || { failed_step="Step 11"; }
        [[ -z "$failed_step" ]] && update_workflow_status 11 "✅"
        ((executed_steps++)) || true
        save_checkpoint 11
    elif [[ -z "$failed_step" && $resume_from -le 11 ]]; then
        print_info "Skipping Step 11 (not selected)"
        log_to_workflow "INFO" "Skipping Step 11 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 11 ]]; then
        print_info "Skipping Step 11 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Final status
    echo ""
    print_header "Workflow Execution Summary"
    log_to_workflow "INFO" "Workflow execution completed"
    print_info "Executed steps: $executed_steps"
    log_to_workflow "INFO" "Executed steps: $executed_steps"
    print_info "Skipped steps: $skipped_steps"
    log_to_workflow "INFO" "Skipped steps: $skipped_steps"
    
    if [[ -n "$failed_step" ]]; then
        print_error "Workflow failed at: $failed_step"
        log_to_workflow "ERROR" "Workflow FAILED at: $failed_step"
        show_progress
        
        # Play completion sound notification (v3.1.0)
        if type -t play_notification_sound > /dev/null 2>&1; then
            play_notification_sound "completion" 2>/dev/null || true
        fi
        
        # Run health check to document failure point
        verify_workflow_health || true
        
        exit 1
    else
        print_header "🎉 Workflow Completed Successfully!"
        log_to_workflow "SUCCESS" "Workflow completed successfully"
        show_progress
        
        # Play completion sound notification (v3.1.0)
        if type -t play_notification_sound > /dev/null 2>&1; then
            play_notification_sound "completion" 2>/dev/null || true
        fi
        
        print_success "All selected steps completed successfully"
        print_info "Backlog reports saved to: $BACKLOG_RUN_DIR"
        print_info "Summaries saved to: $SUMMARIES_RUN_DIR"
        print_info "Execution log saved to: $WORKFLOW_LOG_FILE"
        
        # Finalize metrics collection (v2.3.0)
        if type -t finalize_metrics > /dev/null; then
            finalize_metrics "success"
        fi
        
        # Run post-completion health checks
        echo ""
        verify_workflow_health || true
        validate_doc_placement || true
        enhanced_git_state_report || true
        
        # Create workflow summary file
        create_workflow_summary
        
        # Display performance metrics (v2.3.0)
        echo ""
        print_header "Performance Metrics & Statistics"
        
        # Generate and display metrics summary
        if type -t generate_metrics_summary > /dev/null; then
            generate_metrics_summary
        fi
        
        # Display AI cache statistics
        if [[ "${USE_AI_CACHE}" == "true" ]] && type -t get_cache_metrics > /dev/null; then
            get_cache_metrics
        fi
        
        # Display cache statistics
        if type -t get_cache_stats > /dev/null; then
            get_cache_stats
        fi
        
        # Validate ML predictions if enabled (v2.7.0)
        if [[ "${ML_OPTIMIZE:-false}" == "true" ]] && [[ "${ML_ENABLED:-false}" == "true" ]]; then
            local actual_duration=$(($(date +%s) - WORKFLOW_START_TIME))
            validate_ml_predictions "$actual_duration"
        fi
        
        # Cleanup old workflow artifacts (v2.6.0)
        # Removes artifacts older than specified days after successful workflow completion
        # Default: 7 days, customizable with --cleanup-days, disable with --no-cleanup
        if [[ "$DRY_RUN" != true ]] && [[ "${NO_CLEANUP:-false}" != "true" ]] && type -t cleanup_old_artifacts > /dev/null; then
            echo ""
            print_header "Artifact Cleanup"
            local cleanup_days="${CLEANUP_DAYS:-7}"
            cleanup_old_artifacts "$cleanup_days" false
        fi
        
        # Prompt for continuation if enabled
        prompt_for_continuation
    fi
}

# Create a summary file for the entire workflow run
create_workflow_summary() {
    local summary_file="${BACKLOG_RUN_DIR}/WORKFLOW_SUMMARY.md"
    
    cat > "$summary_file" << EOF
# Workflow Execution Summary

**Workflow Run ID:** ${WORKFLOW_RUN_ID}
**Execution Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Script Version:** ${SCRIPT_VERSION}
**Mode:** $([ "$AUTO_MODE" = true ] && echo "Automatic" || echo "Interactive")

---

## Execution Overview

### Steps Completed

EOF
    
    # Add step status
    local step_num=0
    for step_num in {0..13}; do
        local step_key="step${step_num}"
        local step_status="${WORKFLOW_STATUS[$step_key]:-⏭️}"
        echo "- **Step ${step_num}:** ${step_status}" >> "$summary_file"
    done
    
    cat >> "$summary_file" << EOF

### Change Analysis

- **Change Scope:** ${CHANGE_SCOPE:-Not specified}
- **Commits Ahead:** ${ANALYSIS_COMMITS:-0}
- **Modified Files:** ${ANALYSIS_MODIFIED:-0}

---

## Individual Step Reports

EOF
    
    # List all step reports in this run
    for step_file in "$BACKLOG_RUN_DIR"/step*.md; do
        if [[ -f "$step_file" ]]; then
            local step_name=$(basename "$step_file" .md)
            echo "- [\`${step_name}\`](./${step_name}.md)" >> "$summary_file"
        fi
    done
    
    cat >> "$summary_file" << EOF

---

## How to Use These Reports

1. **Review Individual Steps:** Click on any step report above to see detailed findings
2. **Address Issues:** Work through issues by priority (Critical → High → Medium → Low)
3. **Track Progress:** Mark issues as resolved and update documentation
4. **Archive:** Move resolved workflow runs to \`backlog/archive/\` for historical reference

---

**Generated by:** ${SCRIPT_NAME} v${SCRIPT_VERSION}
EOF
    
    print_success "Workflow summary created: $summary_file"
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

show_usage() {
    cat << EOF
${SCRIPT_NAME} v${SCRIPT_VERSION}

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --target PATH       Target project root directory (default: current directory)
                        Analyzes any project from anywhere
    
    --dry-run          Preview all actions without executing
    
    --auto             Run in automatic mode (no confirmations, skip AI)
    --auto-commit      Auto-commit workflow artifacts (NEW v2.6.0)
                       Automatically commits docs, tests, and code changes
    --ai-batch         Run AI prompts non-interactively (hybrid auto mode)
    --interactive      Run in interactive mode (default)
    
    --verbose          Enable verbose output
    --steps STEPS      Execute specific steps (comma-separated, e.g., "0,1,2" or "all")
    --stop             Enable continuation prompt on completion
    
    --smart-execution  Enable smart execution (skip steps based on change detection)
                       ✅ ENABLED BY DEFAULT in v2.5.0+
                       Performance: 40-85% faster for incremental changes
                       Use --no-smart-execution to disable
    
    --force-model MODEL   Override AI model selection for all steps (NEW v3.2.1)
                          Force specific GitHub Copilot model regardless of complexity
                          Examples: claude-opus-4.6, gpt-5.2, claude-haiku-4.5
                          
    --show-model-plan     Preview AI model assignments without executing (NEW v3.2.1)
                          Displays which model will be used for each step based on
                          change complexity analysis, then exits
    
    --no-smart-execution  Disable smart execution (run all steps)
    
    --show-graph       Display dependency graph and parallelization opportunities
    
    --parallel         Enable parallel execution for independent steps
                       ✅ ENABLED BY DEFAULT in v2.5.0+
                       Performance: 33% faster execution time
                       Use --no-parallel to disable
    
    --parallel-tracks  Enable 3-track parallel execution (MAXIMUM PERFORMANCE)
                       ⚡ NEW in v2.6.1 - Runs all compatible steps in parallel
                       Performance: 46% faster than sequential (15.5 min vs 28.75 min)
                       Recommended for production workflows
    
    --no-parallel      Disable parallel execution (sequential mode)
    
    --no-ai-cache      Disable AI response caching (increases token usage)
                       Default: Enabled (60-80% token savings)
    
    --no-resume        Start from step 0, ignore any checkpoints
                       Default: Resume from last completed step
    
    --no-fast-track    Disable docs-only fast track optimization (NEW v5.0.0)
                       Forces standard execution for documentation-only changes
                       Default: Auto-enabled for docs-only changes (93% faster)
    
    --cleanup-days N   Remove artifacts older than N days (default: 7)
                       Runs automatically after successful completion
    --no-cleanup       Disable automatic artifact cleanup
    
    --show-tech-stack  Display detected tech stack configuration
    --config-file FILE Use specific .workflow-config.yaml file
    --init-config      Run interactive configuration wizard
    
    --ml-optimize      Enable ML-driven optimization (v2.7.0)
                       ⚡ Predictive step duration and smart recommendations
                       Performance: Additional 15-30% improvement
                       Requires: Minimum 10 historical workflow executions
    --show-ml-status   Display ML system status and training data
    
    --multi-stage      Enable multi-stage pipeline execution (NEW v2.8.0)
                       ⚡ Progressive validation with intelligent stage triggers
                       Stage 1: Fast validation (2 min, always runs)
                       Stage 2: Targeted checks (5 min, conditional)
                       Stage 3: Full validation (15 min, high-impact/manual)
                       Performance: 80%+ of runs complete in Stage 1-2
    --show-pipeline    Display pipeline configuration and stage plan
    --manual-trigger   Force all 3 stages to execute (with --multi-stage)
    
    --generate-docs    Auto-generate workflow execution reports (NEW v2.9.0)
                       📝 Extract summaries to docs/workflow-reports/
                       Includes metrics, issues, and performance data
    --update-changelog Auto-update CHANGELOG.md from git commits (NEW v2.9.0)
                       📋 Conventional commits parsed into Keep a Changelog format
    --generate-api-docs Generate API documentation from source (NEW v2.9.0)
                       📚 Extract function docs to docs/api/
    
    --install-hooks    Install pre-commit hooks (NEW v2.10.0)
                       ⚡ Fast validation checks (< 1 second)
                       Prevents broken commits, auto-stages generated files
    --uninstall-hooks  Remove pre-commit hooks (NEW v2.10.0)
    --test-hooks       Test pre-commit hooks without committing (NEW v2.10.0)
    
    --skip-submodules  Skip git submodule operations in Step 11 (NEW v3.1.0)
                       Default: Process all submodules automatically
                       Use when you want to manage submodules manually
    
    --help             Show this help message
    --version          Show script version

DESCRIPTION:
    Automates the complete tests and documentation update workflow including:
    - Pre-analysis of recent changes (Step 0)
    - Documentation updates and validation (Steps 1-4)
    - Test suite review and execution (Steps 5-7)
    - Dependency validation (Step 8)
    - Code quality checks (Step 9)
    - Context analysis (Step 10)
    - Git finalization (Step 11)
    - Markdown linting (Step 12)
    - Prompt engineering analysis (Step 13, ai_workflow only)
    - UX analysis (Step 14)
    - AI-powered semantic version update (Step 15)
    - Git finalization (Step 11) [FINAL STEP - commits all changes]

WORKFLOW STEPS:
    Step 0:  Pre-Analysis - Analyzing Recent Changes
    Step 0b: Bootstrap Documentation (NEW v3.1.1)
    Step 1:  Update Related Documentation
    Step 2:  Check Documentation Consistency
    Step 2.5: Documentation Optimization & Consolidation (NEW v3.2.1)
    Step 3:  Validate Script References
    Step 4:  Validate Directory Structure
    Step 5:  Review Existing Tests
    Step 6:  Generate New Tests
    Step 7:  Execute Test Suite
    Step 8:  Validate Dependencies
    Step 9:  Code Quality Validation
    Step 10: Context Analysis & Summary
    Step 12: Markdown Linting
    Step 13: Prompt Engineer Analysis (ai_workflow only)
    Step 14: UX Analysis
    Step 15: AI-Powered Semantic Version Update
    Step 11: Git Finalization [FINAL STEP - commits all changes]

EXAMPLES:
    # Basic: Run on current directory (default behavior)
    cd /path/to/your/project
    $0
    
    # Preview workflow without execution
    $0 --dry-run
    
    # Run in automatic mode (no confirmations, skip AI)
    $0 --auto
    
    # Hybrid mode: Auto + AI batch analysis (RECOMMENDED for CI/CD)
    $0 --auto --ai-batch
    
    # Run on different project using --target
    $0 --target /home/user/my-project
    
    # From workflow repo on target project with AI
    cd /path/to/ai_workflow
    $0 --target /home/user/nodejs-api --auto --ai-batch
    
    # Execute only documentation steps (0-4)
    $0 --steps 0,1,2,3,4
    
    # Execute only testing steps (0,5,6,7) on target project
    $0 --target /path/to/project --steps 0,5,6,7
    
    # Execute only git finalization (11)
    $0 --steps 11
    
    # Smart execution for faster workflow (40-85% faster)
    $0 --smart-execution --parallel
    
    # Show dependency graph before execution
    $0 --show-graph
    
    # Maximum performance: Smart + Parallel + AI Batch + Caching (RECOMMENDED)
    cd /path/to/project
    /path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh \
      --smart-execution --parallel --auto --ai-batch
    
    # ULTIMATE PERFORMANCE: 3-track parallel execution (NEW v2.6.1)
    # 46% faster than sequential - completes in ~15.5 minutes
    $0 --parallel-tracks --smart-execution --auto
    
    # With auto-commit (NEW v2.6.0)
    $0 --auto-commit --smart-execution --parallel
    
    # Use workflow templates (NEW v2.6.0)
    ./templates/workflows/docs-only.sh      # Documentation only (~3-4 min)
    ./templates/workflows/test-only.sh       # Tests only (~8-10 min)  
    ./templates/workflows/feature.sh         # Full feature workflow
    
    # Force fresh start (ignore checkpoints)
    $0 --no-resume --auto
    
    # Disable fast track mode (force standard execution for docs changes)
    $0 --no-fast-track --smart-execution --parallel
    
    # Interactive configuration wizard
    $0 --init-config
    
    # Show detected technology stack
    $0 --show-tech-stack

WORKFLOW TEMPLATES (NEW v2.6.0):
    Pre-configured templates for common development scenarios:
    
    📝 docs-only.sh      - Documentation changes (~3-4 min)
    🧪 test-only.sh      - Test development (~8-10 min)
    🚀 feature.sh        - Full feature workflow (~15-20 min)
    
    All templates include: auto-commit, smart execution, parallel processing
    Location: templates/workflows/
    Documentation: templates/workflows/README.md

IDE INTEGRATION (NEW v2.6.0):
    VS Code Tasks: Run via Ctrl+Shift+B or Tasks menu
    Configuration: .vscode/tasks.json
    Available tasks:
      • AI Workflow: Full Run (default)
      • AI Workflow: Documentation Only
      • AI Workflow: Test Only
      • AI Workflow: Feature Development
      • AI Workflow: Auto-commit
      • AI Workflow: Metrics Dashboard

PERFORMANCE OPTIMIZATION:
    
    Change Type         | Baseline | --smart-execution | --parallel | Combined | Optimized (v2.7)
    --------------------|----------|-------------------|------------|----------|------------------
    Documentation Only  | 23 min   | 3.5 min (85%)    | 15.5 min   | 2.3 min (90%) | 1.5 min (93%) ⭐
    Code Changes        | 23 min   | 14 min (40%)     | 15.5 min   | 10 min (57%)  | 6-7 min (70-75%) ⭐
    Full Changes        | 23 min   | 23 min           | 15.5 min   | 15.5 min (33%)| 10-11 min (52-57%) ⭐
    
    AI Response Caching: 60-80% token usage reduction (enabled by default)
    Checkpoint Resume: Automatic continuation from last completed step
    Docs-Only Fast Track: Auto-enabled for documentation-only changes (v2.7.0)
    Code Changes Optimization: Incremental tests + smart quality checks (v2.7.0)
    Full Changes 4-Track: Enhanced parallelization + test sharding (v2.7.0)

MODES COMPARISON:
    
    Feature             | Interactive | --auto | --auto --ai-batch
    --------------------|-------------|--------|-------------------
    User Prompts        | ✅ Required | ❌ Skip | ❌ Skip
    AI Analysis         | ✅ Interactive | ❌ Skip | ✅ Automated
    CI/CD Compatible    | ❌ No       | ✅ Yes  | ✅ Yes
    AI Insights         | ✅ Full     | ❌ None | ✅ Full
    AI Caching          | ✅ Yes      | N/A     | ✅ Yes
    Timeout Protection  | N/A         | N/A     | ✅ 5min

PROJECT KINDS SUPPORTED:
    - shell_script_automation (BATS tests, ShellCheck)
    - nodejs_api (Jest, ESLint, OpenAPI)
    - nodejs_cli (Jest CLI testing)
    - react_spa (Jest + RTL, accessibility)
    - static_website (HTML validation, performance)
    - python_app (pytest, PEP 8)
    - generic (universal fallback)

CONFIGURATION:
    Create .workflow-config.yaml in project root:
    
    project:
      kind: nodejs_api              # Override auto-detection
      name: "My API Project"
    
    tech_stack:
      primary_language: javascript
      framework: express
      build_system: npm
    
    testing:
      framework: jest
      coverage_target: 90
      test_command: "npm test"

PREREQUISITES:
    - Bash 4.0+
    - Git
    - Node.js v25.2.1+ (for Node.js projects)
    - GitHub Copilot CLI (optional, for AI features)

DOCUMENTATION:
    - Main Guide: MIGRATION_README.md
    - Module Reference: src/workflow/README.md
    - Tech Stack Guide: docs/TECH_STACK_ADAPTIVE_FRAMEWORK.md
    - Project Kinds: docs/PROJECT_KIND_FRAMEWORK.md
    - Target Feature: docs/TARGET_PROJECT_FEATURE.md
    - AI Batch Mode: docs/AI_BATCH_MODE.md

VERSION: ${SCRIPT_VERSION}
EOF
}

# Argument parsing delegated to lib/argument_parser.sh
# Kept as wrapper for backward compatibility
parse_arguments() {
    parse_workflow_arguments "$@"
    validate_parsed_arguments || exit 1
}

main() {
    # Set up cleanup trap for temporary files
    # Ensures cleanup on EXIT (normal), INT (Ctrl+C), TERM (kill)
    # Critical for AI-enhanced steps that create temp files
    trap 'cleanup' EXIT
    trap 'exit 130' INT TERM
    
    print_header "${SCRIPT_NAME} v${SCRIPT_VERSION}"
    
    parse_arguments "$@"
    
    # Handle hooks management flags (execute immediately and exit)
    if [[ "${INSTALL_HOOKS:-false}" == "true" ]]; then
        if type -t install_precommit_hook > /dev/null 2>&1; then
            install_precommit_hook
            exit $?
        else
            print_error "Pre-commit hooks module not loaded"
            exit 1
        fi
    fi
    
    if [[ "${UNINSTALL_HOOKS:-false}" == "true" ]]; then
        if type -t uninstall_precommit_hook > /dev/null 2>&1; then
            uninstall_precommit_hook
            exit $?
        else
            print_error "Pre-commit hooks module not loaded"
            exit 1
        fi
    fi
    
    if [[ "${TEST_HOOKS:-false}" == "true" ]]; then
        if type -t test_precommit_hook > /dev/null 2>&1; then
            test_precommit_hook
            exit $?
        else
            print_error "Pre-commit hooks module not loaded"
            exit 1
        fi
    fi
    
    # If --init-config flag is set, run wizard immediately and exit
    if [[ "${INIT_CONFIG_WIZARD:-false}" == "true" ]]; then
        print_header "Configuration Wizard"
        
        # Change to target project directory
        cd "$PROJECT_ROOT" || exit 1
        
        echo "Project directory: $PROJECT_ROOT"
        echo ""
        
        # Run the wizard
        if run_config_wizard; then
            print_success "Configuration wizard completed successfully"
            exit 0
        else
            print_error "Configuration wizard cancelled or failed"
            exit 1
        fi
    fi
    
    if [[ -n "$TARGET_PROJECT_ROOT" ]]; then
        print_info "Running workflow on target project: ${PROJECT_ROOT}"
        print_info "Workflow home: ${WORKFLOW_HOME}"
        print_info "Artifacts will be stored in: ${PROJECT_ROOT}/.ai_workflow/"
    else
        print_info "Running workflow on: ${PROJECT_ROOT}"
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        print_warning "DRY RUN MODE - No changes will be made"
    fi
    
    # Create backlog, summaries, and logs directories for this run
    mkdir -p "$BACKLOG_RUN_DIR"
    mkdir -p "$SUMMARIES_RUN_DIR"
    mkdir -p "$LOGS_RUN_DIR"
    print_info "Backlog directory created: $BACKLOG_RUN_DIR"
    print_info "Summaries directory created: $SUMMARIES_RUN_DIR"
    print_info "Logs directory created: $LOGS_RUN_DIR"
    
    # Initialize workflow execution log
    init_workflow_log
    
    # Execute pre-flight checks
    check_prerequisites
    validate_dependencies
    
    # Initialize git state cache (performance optimization v1.5.0)
    # Captures all git information once to eliminate 30+ redundant git calls
    init_git_cache
    
    # Initialize tech stack detection (v2.5.0 Phase 1)
    # Loads .workflow-config.yaml or auto-detects technology stack
    if ! init_tech_stack; then
        print_error "Tech stack initialization failed"
        log_to_workflow "ERROR" "Tech stack initialization failed"
        exit 1
    fi
    
    # If --show-tech-stack flag is set, display and exit
    if [[ "${SHOW_TECH_STACK:-false}" == "true" ]]; then
        print_header "Tech Stack Configuration"
        print_tech_stack_summary
        echo ""
        print_info "Configuration Details:"
        echo ""
        echo "  Primary Language:   ${PRIMARY_LANGUAGE}"
        echo "  Build System:       ${BUILD_SYSTEM}"
        echo "  Test Framework:     ${TEST_FRAMEWORK}"
        echo "  Test Command:       ${TEST_COMMAND}"
        echo "  Lint Command:       ${LINT_COMMAND}"
        echo "  Install Command:    ${INSTALL_COMMAND}"
        echo ""
        if [[ -n "${TECH_STACK_CONFIG[package_file]:-}" ]]; then
            echo "  Package File:       ${TECH_STACK_CONFIG[package_file]}"
        fi
        if [[ -n "${TECH_STACK_CONFIG[source_dirs]:-}" ]]; then
            echo "  Source Dirs:        ${TECH_STACK_CONFIG[source_dirs]}"
        fi
        if [[ -n "${TECH_STACK_CONFIG[test_dirs]:-}" ]]; then
            echo "  Test Dirs:          ${TECH_STACK_CONFIG[test_dirs]}"
        fi
        echo ""
        local confidence=$(get_confidence_score "$PRIMARY_LANGUAGE")
        if [[ $confidence -gt 0 ]]; then
            echo "  Detection Method:   Auto-detection"
            echo "  Confidence Score:   ${confidence}%"
        else
            echo "  Detection Method:   Configuration file"
        fi
        echo ""
        print_success "Tech stack display complete"
        exit 0
    fi
    
    # Load audio notification configuration (v3.1.0)
    if [[ -f "${PROJECT_ROOT}/.workflow-config.yaml" ]]; then
        local audio_enabled=$(yq '.audio.enabled // true' "${PROJECT_ROOT}/.workflow-config.yaml" 2>/dev/null || echo "true")
        local continue_sound=$(yq '.audio.continue_prompt_sound // ""' "${PROJECT_ROOT}/.workflow-config.yaml" 2>/dev/null | tr -d '"' || echo "")
        local completion_sound=$(yq '.audio.completion_sound // ""' "${PROJECT_ROOT}/.workflow-config.yaml" 2>/dev/null | tr -d '"' || echo "")
        
        export AUDIO_NOTIFICATIONS_ENABLED="${audio_enabled}"
        [[ -n "$continue_sound" ]] && export AUDIO_CONTINUE_PROMPT_SOUND="$continue_sound"
        [[ -n "$completion_sound" ]] && export AUDIO_COMPLETION_SOUND="$completion_sound"
    fi
    
    # Initialize AI cache (v2.3.0)
    init_ai_cache
    
    # Initialize auto-documentation system (v2.9.0)
    if [[ "${AUTO_GENERATE_DOCS:-false}" == "true" ]] || [[ "${AUTO_UPDATE_CHANGELOG:-false}" == "true" ]] || [[ "${GENERATE_API_DOCS:-false}" == "true" ]]; then
        if type -t init_auto_documentation > /dev/null 2>&1; then
            init_auto_documentation
        fi
    fi
    
    # Initialize ML system (v2.7.0)
    if [[ "${ML_OPTIMIZE:-false}" == "true" ]]; then
        if init_ml_system; then
            print_success "ML optimization system initialized"
            log_to_workflow "INFO" "ML optimization enabled"
        else
            print_warning "ML system not ready - collecting training data"
            log_to_workflow "WARNING" "ML system needs more training samples"
        fi
    fi
    
    # If --show-ml-status flag is set, display and exit
    if [[ "${SHOW_ML_STATUS:-false}" == "true" ]]; then
        display_ml_status
        exit 0
    fi
    
    # If --show-pipeline flag is set, display and exit (v2.8.0)
    if [[ "${SHOW_PIPELINE:-false}" == "true" ]]; then
        display_pipeline_config
        echo ""
        display_pipeline_plan
        exit 0
    fi
    
    # Initialize analysis cache (v2.7.0)
    if type -t init_analysis_cache > /dev/null 2>&1; then
        init_analysis_cache
        print_info "Advanced analysis caching enabled (3-5x faster for subsequent runs)"
    fi
    
    # Initialize Git automation (v2.7.0)
    if type -t on_workflow_start > /dev/null 2>&1; then
        on_workflow_start
    fi
    
    # Initialize metrics collection (v2.3.0)
    init_metrics
    
    # Analyze change impact for conditional execution (v2.2.0)
    analyze_change_impact
    
    # Apply ML optimization if enabled (v2.7.0)
    if [[ "${ML_OPTIMIZE:-false}" == "true" ]] && [[ "${ML_ENABLED:-false}" == "true" ]]; then
        print_header "ML-Driven Optimization"
        
        # Extract features from current changes
        ML_FEATURES=$(extract_change_features)
        export ML_FEATURES
        
        # Get ML recommendations
        ML_RECOMMENDATIONS=$(apply_ml_optimization)
        export ML_RECOMMENDATIONS
        
        # Apply parallelization recommendation
        # NOTE: Only applies if user hasn't explicitly disabled parallel execution with --no-parallel
        # We check if PARALLEL_EXECUTION was explicitly set by the user via command-line
        local ml_parallel=$(echo "$ML_RECOMMENDATIONS" | jq -r '.parallelization.recommend_parallel // false')
        if [[ "$ml_parallel" == "true" ]] && [[ "${PARALLEL_EXECUTION}" == "false" ]] && [[ "${USER_DISABLED_PARALLEL:-false}" != "true" ]]; then
            print_info "ML recommendation: Enabling parallel execution"
            PARALLEL_EXECUTION=true
            export PARALLEL_EXECUTION
        fi
        
        # Show predicted duration
        local predicted_duration=$(echo "$ML_RECOMMENDATIONS" | jq -r '.predicted_duration // 0')
        if [[ $predicted_duration -gt 0 ]]; then
            local pred_min=$((predicted_duration / 60))
            print_success "Predicted workflow duration: ${pred_min}m (${predicted_duration}s)"
        fi
        
        log_to_workflow "INFO" "ML optimization applied"
    fi
    
    # Enable docs-only fast track optimization if applicable (v2.7.0)
    if type -t enable_docs_only_optimization > /dev/null 2>&1; then
        if enable_docs_only_optimization; then
            # Docs-only fast track detected - will use optimized execution path
            print_info "Estimated completion time: 90-120 seconds"
        fi
    fi
    
    # Enable code changes optimization if applicable (v2.7.0)
    if type -t enable_code_changes_optimization > /dev/null 2>&1; then
        if enable_code_changes_optimization; then
            # Code changes optimization enabled
            :  # Info messages already printed by function
        fi
    fi
    
    # Enable full changes optimization if applicable (v2.7.0)
    if type -t enable_full_changes_optimization > /dev/null 2>&1; then
        if enable_full_changes_optimization; then
            # Full changes optimization enabled (4-track + sharding)
            :  # Info messages already printed by function
        fi
    fi
    
    # Show dependency graph if requested (v2.3.0)
    if [[ "${SHOW_GRAPH}" == "true" ]]; then
        print_header "Dependency Graph & Parallelization Analysis"
        generate_dependency_diagram "${BACKLOG_RUN_DIR}/DEPENDENCY_GRAPH.md"
        display_execution_phases
        echo ""
        echo "📊 Full graph saved to: ${BACKLOG_RUN_DIR}/DEPENDENCY_GRAPH.md"
        echo ""
        if [[ "${INTERACTIVE_MODE}" == "true" ]]; then
            echo "Press Enter to continue with workflow execution..."
            read -r
        fi
    fi
    
    # Cleanup old checkpoints (v2.2.0)
    cleanup_old_checkpoints
    
    # Check for resume capability (v2.2.0) unless --no-resume flag is set
    if [[ "${NO_RESUME}" == "false" ]] && load_checkpoint; then
        print_info "Workflow will resume from Step ${RESUME_FROM_STEP}"
    elif [[ "${NO_RESUME}" == "true" ]]; then
        print_info "Fresh start mode - starting from Step 0"
    fi
    
    # Execute workflow with appropriate mode (v2.8.0)
    if [[ "${MULTI_STAGE:-false}" == "true" ]]; then
        # Multi-stage pipeline mode
        print_header "Multi-Stage Pipeline Mode"
        
        if [[ "${MANUAL_TRIGGER:-false}" == "true" ]]; then
            print_info "Manual trigger enabled - all 3 stages will execute"
            enable_manual_trigger
        fi
        
        # Execute multi-stage pipeline
        if ! execute_pipeline; then
            print_error "Multi-stage pipeline execution failed"
            exit 1
        fi
    else
        # Standard full workflow execution
        execute_full_workflow
    fi
    
    # Execute post-workflow Git automation (v2.7.0)
    if type -t on_workflow_complete > /dev/null 2>&1; then
        local workflow_result=$?
        if [[ $workflow_result -eq 0 ]]; then
            on_workflow_complete "success"
        else
            on_workflow_complete "failure"
        fi
    fi
    
    # Auto-generate documentation (v2.9.0)
    if [[ "${AUTO_GENERATE_DOCS:-false}" == "true" ]] && type -t on_workflow_complete_docs > /dev/null 2>&1; then
        local workflow_status="success"
        [[ $? -ne 0 ]] && workflow_status="failure"
        
        on_workflow_complete_docs "$workflow_status"
    fi
    
    # Generate API documentation if requested (v2.9.0)
    if [[ "${GENERATE_API_DOCS:-false}" == "true" ]] && type -t generate_api_docs > /dev/null 2>&1; then
        print_header "Generating API Documentation"
        generate_api_docs "${WORKFLOW_DIR}/lib"
    fi
}

# ==============================================================================
# SCRIPT ENTRY POINT
# ==============================================================================

main "$@"
