#!/usr/bin/env bash
set -euo pipefail


################################################################################
# Tests & Documentation Workflow Automation Script
# Version: 2.4.0
# Purpose: Main orchestrator for workflow automation
# Architecture: Delegates to phase-specific sub-orchestrators
#
# NEW IN v2.4.0 - MODULARIZATION PHASE 3 (2025-12-18):
#   ✓ Refactored monolithic 5,294-line script into focused orchestrators
#   ✓ Pre-flight orchestrator (240 lines) - Initialization & validation
#   ✓ Validation orchestrator (241 lines) - Steps 0-4
#   ✓ Test orchestrator (136 lines) - Steps 5-7
#   ✓ Quality orchestrator (102 lines) - Steps 8-9
#   ✓ Finalization orchestrator (117 lines) - Steps 10-12
#   ✓ Main script reduced to <1,500 lines (delegation & coordination)
#   ✓ Impact: 60% reduction in maintenance burden
#
# Inherited from v2.3.0:
#   ✓ Smart execution - Change-based step skipping (40-82% time savings)
#   ✓ Parallel execution - Independent steps run simultaneously (33% faster)
#   ✓ AI response caching - 60-80% token usage reduction
#   ✓ Metrics collection - Automatic performance tracking
#   ✓ Dependency graph visualization - Interactive Mermaid diagrams
#   ✓ Target project support - Run workflow from anywhere
################################################################################

set -euo pipefail

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

SCRIPT_VERSION="2.4.0"
SCRIPT_NAME="Tests & Documentation Workflow Automation"
WORKFLOW_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_ROOT="$(pwd)"
TARGET_PROJECT_ROOT=""
SRC_DIR="${PROJECT_ROOT}/src"
BACKLOG_DIR="${WORKFLOW_HOME}/.ai_workflow/backlog"
SUMMARIES_DIR="${WORKFLOW_HOME}/.ai_workflow/summaries"
LOGS_DIR="${WORKFLOW_HOME}/.ai_workflow/logs"

# Workflow tracking
WORKFLOW_RUN_ID="workflow_$(date +%Y%m%d_%H%M%S)"
BACKLOG_RUN_DIR="${BACKLOG_DIR}/${WORKFLOW_RUN_ID}"
SUMMARIES_RUN_DIR="${SUMMARIES_DIR}/${WORKFLOW_RUN_ID}"
LOGS_RUN_DIR="${LOGS_DIR}/${WORKFLOW_RUN_ID}"
WORKFLOW_LOG_FILE="${LOGS_RUN_DIR}/workflow_execution.log"
WORKFLOW_START_TIME=$(date +%s)

# Execution modes
DRY_RUN=false
INTERACTIVE_MODE=true
AUTO_MODE=false
VERBOSE=false
STOP_ON_COMPLETION=false

# Phase 2/3 features
SMART_EXECUTION=false
SHOW_GRAPH=false
PARALLEL_EXECUTION=false
USE_AI_CACHE=true
NO_RESUME=false

# Step execution control
EXECUTE_STEPS="all"
declare -a SELECTED_STEPS
declare -A WORKFLOW_STATUS
TOTAL_STEPS=14

# Temporary files tracking
TEMP_FILES=()

# Analysis variables
ANALYSIS_COMMITS=""
ANALYSIS_MODIFIED=""
CHANGE_SCOPE=""

# Export environment variables
export DRY_RUN INTERACTIVE_MODE AUTO_MODE VERBOSE
export PROJECT_ROOT WORKFLOW_HOME
export SMART_EXECUTION SHOW_GRAPH PARALLEL_EXECUTION USE_AI_CACHE NO_RESUME

# ==============================================================================
# MODULE LOADING
# ==============================================================================

WORKFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="${WORKFLOW_DIR}"
export SCRIPT_DIR

LIB_DIR="${WORKFLOW_DIR}/lib"
STEPS_DIR="${WORKFLOW_DIR}/steps"
ORCHESTRATORS_DIR="${WORKFLOW_DIR}/orchestrators"

# Source library modules (exclude test files)
for lib_file in "${LIB_DIR}"/*.sh; do
    if [[ -f "$lib_file" ]] && [[ ! "$(basename "$lib_file")" =~ ^test_ ]]; then
        source "$lib_file"
    fi
done

# Source step modules
for step_file in "${STEPS_DIR}"/step_*.sh; do
    [[ -f "$step_file" ]] && source "$step_file"
done

# Source orchestrator modules
for orch_file in "${ORCHESTRATORS_DIR}"/*.sh; do
    [[ -f "$orch_file" ]] && source "$orch_file"
done

# ==============================================================================
# MAIN EXECUTION FLOW
# ==============================================================================

execute_full_workflow() {
    print_header "Executing Workflow"
    log_to_workflow "INFO" "Starting workflow execution"
    log_to_workflow "INFO" "Execution mode: $(if [[ "$DRY_RUN" == true ]]; then echo "DRY RUN"; elif [[ "$AUTO_MODE" == true ]]; then echo "AUTO"; else echo "INTERACTIVE"; fi)"
    log_to_workflow "INFO" "Change impact level: ${CHANGE_IMPACT:-Unknown}"
    
    # Validate and parse step selection
    validate_and_parse_steps
    log_to_workflow "INFO" "Step selection: ${EXECUTE_STEPS}"
    
    local resume_from=${RESUME_FROM_STEP:-0}
    if [[ $resume_from -gt 0 ]]; then
        print_info "Resuming from Step ${resume_from}"
        log_to_workflow "INFO" "Resuming workflow from Step ${resume_from}"
    fi
    
    # Execute workflow phases through orchestrators
    local phase_failed=false
    
    # Phase 1: Validation (Steps 0-4)
    if ! phase_failed && [[ $resume_from -le 4 ]]; then
        if ! execute_validation_phase; then
            print_error "Validation phase failed"
            phase_failed=true
        fi
    fi
    
    # Phase 2: Testing (Steps 5-7)
    if ! $phase_failed && [[ $resume_from -le 7 ]]; then
        if ! execute_test_phase; then
            print_error "Test phase failed"
            phase_failed=true
        fi
    fi
    
    # Phase 3: Quality (Steps 8-9)
    if ! $phase_failed && [[ $resume_from -le 9 ]]; then
        if ! execute_quality_phase; then
            print_error "Quality phase failed"
            phase_failed=true
        fi
    fi
    
    # Phase 4: Finalization (Steps 10-12)
    if ! $phase_failed && [[ $resume_from -le 12 ]]; then
        if ! execute_finalization_phase; then
            print_error "Finalization phase failed"
            phase_failed=true
        fi
    fi
    
    # Workflow completion
    local end_time=$(date +%s)
    local duration=$((end_time - WORKFLOW_START_TIME))
    
    if ! $phase_failed; then
        print_success "Workflow completed successfully in ${duration}s"
        log_to_workflow "SUCCESS" "Workflow completed: ${duration}s"
        
        # Finalize metrics
        finalize_metrics
        
        # Health check (if implemented)
        if command -v run_health_check &>/dev/null; then
            run_health_check
        fi
        
        # Show summary
        show_workflow_summary
        
        # Continuation prompt
        prompt_for_continuation
        
        return 0
    else
        print_error "Workflow failed after ${duration}s"
        log_to_workflow "ERROR" "Workflow failed: ${duration}s"
        return 1
    fi
}

show_workflow_summary() {
    print_header "Workflow Summary"
    
    local end_time=$(date +%s)
    local duration=$((end_time - WORKFLOW_START_TIME))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    
    echo -e "${CYAN}Duration:${NC} ${minutes}m ${seconds}s"
    echo -e "${CYAN}Workflow ID:${NC} ${WORKFLOW_RUN_ID}"
    echo ""
    echo -e "${CYAN}Output Locations:${NC}"
    echo -e "  Backlog:   ${BACKLOG_RUN_DIR}"
    echo -e "  Summaries: ${SUMMARIES_RUN_DIR}"
    echo -e "  Logs:      ${LOGS_RUN_DIR}"
    echo ""
    
    # Show step status
    local executed=0
    local skipped=0
    local failed=0
    
    for i in $(seq 0 $((TOTAL_STEPS - 1))); do
        local status="${WORKFLOW_STATUS[$i]:-NOT_EXECUTED}"
        case "$status" in
            "✅"|"SUCCESS") ((executed++)) || true ;;
            "⏭"|"SKIPPED") ((skipped++)) || true ;;
            "❌"|"FAILED") ((failed++)) || true ;;
        esac
    done
    
    echo -e "${CYAN}Step Statistics:${NC}"
    echo -e "  Executed: ${GREEN}$executed${NC}"
    echo -e "  Skipped:  ${YELLOW}$skipped${NC}"
    if [[ $failed -gt 0 ]]; then
        echo -e "  Failed:   ${RED}$failed${NC}"
    fi
    echo ""
    
    # Show metrics if available
    if command -v show_metrics_summary &>/dev/null; then
        show_metrics_summary
    fi
}

# ==============================================================================
# ARGUMENT PARSING
# ==============================================================================

show_usage() {
    cat << EOF
${SCRIPT_NAME} v2.4.0

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --target PATH       Target project root directory (default: current directory)
    --dry-run           Preview all actions without executing
    --auto              Run in automatic mode (no confirmations)
    --interactive       Run in interactive mode (default)
    --verbose           Enable verbose output
    --steps STEPS       Execute specific steps (comma-separated, e.g., "0,1,2" or "all")
    --stop              Enable continuation prompt on completion
    --smart-execution   Enable smart execution (skip steps based on change detection)
    --show-graph        Display dependency graph and parallelization opportunities
    --parallel          Enable parallel execution for independent steps (33% faster)
    --no-ai-cache       Disable AI response caching (increases token usage)
    --no-resume         Start from step 0, ignore any checkpoints
    --help              Show this help message
    --version           Show script version

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
    
    By default, the workflow runs on the current directory. Use --target to specify
    a different project directory.

PHASE ORCHESTRATION (v2.4.0):
    The workflow is organized into focused phases:
    - Pre-Flight: System checks and initialization
    - Validation: Documentation and structure (Steps 0-4)
    - Testing: Review, generation, execution (Steps 5-7)
    - Quality: Dependencies and code quality (Steps 8-9)
    - Finalization: Context, git, linting (Steps 10-12)

EXAMPLES:
    # Run on current directory (default behavior)
    cd /path/to/your/project
    $0
    
    # Run workflow on a different project
    $0 --target /path/to/project
    
    # Maximum performance (smart + parallel + AI cache)
    $0 --smart-execution --parallel --auto
    
    # Execute only documentation steps (0-4)
    $0 --steps 0,1,2,3,4
    
    # Show dependency graph before execution
    $0 --show-graph

For more information, see:
    - /docs/workflow-automation/COMPREHENSIVE_WORKFLOW_EXECUTION_ANALYSIS.md
    - /docs/TARGET_PROJECT_FEATURE.md

EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target)
                if [[ -z "$2" ]] || [[ "$2" == --* ]]; then
                    print_error "--target requires a directory path argument"
                    exit 1
                fi
                TARGET_PROJECT_ROOT="$2"
                if [[ ! -d "$TARGET_PROJECT_ROOT" ]]; then
                    print_error "Target directory does not exist: $TARGET_PROJECT_ROOT"
                    exit 1
                fi
                TARGET_PROJECT_ROOT="$(cd "$TARGET_PROJECT_ROOT" && pwd)"
                PROJECT_ROOT="$TARGET_PROJECT_ROOT"
                SRC_DIR="${PROJECT_ROOT}/src"
                print_info "Target project: $PROJECT_ROOT"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                export DRY_RUN
                print_info "Dry-run mode enabled"
                shift
                ;;
            --auto)
                AUTO_MODE=true
                INTERACTIVE_MODE=false
                export AUTO_MODE INTERACTIVE_MODE
                print_info "Automatic mode enabled"
                shift
                ;;
            --interactive)
                INTERACTIVE_MODE=true
                AUTO_MODE=false
                export INTERACTIVE_MODE AUTO_MODE
                shift
                ;;
            --verbose)
                VERBOSE=true
                print_info "Verbose mode enabled"
                shift
                ;;
            --steps)
                if [[ -z "$2" ]] || [[ "$2" == --* ]]; then
                    print_error "--steps requires a comma-separated list (e.g., '0,1,2')"
                    exit 1
                fi
                EXECUTE_STEPS="$2"
                shift 2
                ;;
            --stop)
                STOP_ON_COMPLETION=true
                shift
                ;;
            --smart-execution)
                SMART_EXECUTION=true
                export SMART_EXECUTION
                print_info "Smart execution enabled"
                shift
                ;;
            --show-graph)
                SHOW_GRAPH=true
                export SHOW_GRAPH
                shift
                ;;
            --parallel)
                PARALLEL_EXECUTION=true
                export PARALLEL_EXECUTION
                print_info "Parallel execution enabled"
                shift
                ;;
            --no-ai-cache)
                USE_AI_CACHE=false
                export USE_AI_CACHE
                print_info "AI response caching disabled"
                shift
                ;;
            --no-resume)
                NO_RESUME=true
                export NO_RESUME
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            --version)
                echo "${SCRIPT_NAME} v${SCRIPT_VERSION}"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# ==============================================================================
# MAIN FUNCTION
# ==============================================================================

main() {
    # Set up cleanup trap
    trap 'cleanup' EXIT
    trap 'exit 130' INT TERM
    
    print_header "${SCRIPT_NAME} v${SCRIPT_VERSION}"
    
    parse_arguments "$@"
    
    if [[ -n "$TARGET_PROJECT_ROOT" ]]; then
        print_info "Running workflow on target project: ${PROJECT_ROOT}"
        print_info "Workflow home: ${WORKFLOW_HOME}"
    else
        print_info "Running workflow on: ${PROJECT_ROOT}"
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        print_warning "DRY RUN MODE - No changes will be made"
    fi
    
    # Execute pre-flight checks and initialization
    if ! execute_preflight; then
        print_error "Pre-flight checks failed"
        exit 1
    fi
    
    # Show dependency graph if requested
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
    
    # Cleanup old checkpoints
    cleanup_old_checkpoints
    
    # Check for resume capability (unless --no-resume flag is set)
    if [[ "${NO_RESUME}" == "false" ]] && load_checkpoint; then
        print_info "Workflow will resume from Step ${RESUME_FROM_STEP}"
    elif [[ "${NO_RESUME}" == "true" ]]; then
        print_info "Fresh start mode - starting from Step 0"
    fi
    
    # Execute full workflow
    execute_full_workflow
}

# ==============================================================================
# SCRIPT ENTRY POINT
# ==============================================================================

main "$@"
