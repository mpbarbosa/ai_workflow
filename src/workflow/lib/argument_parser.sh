#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Argument Parser Module
# Purpose: Extract command-line argument parsing logic from main workflow script
# Version: 3.0.1
# Part of: Technical Debt Reduction Phase 1
################################################################################

# Parse command-line arguments for workflow execution
# Sets global variables based on provided options
# Usage: parse_workflow_arguments "$@"
parse_workflow_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target)
                if [[ -z "${2:-}" ]] || [[ "$2" == --* ]]; then
                    print_error "--target requires a directory path argument"
                    exit 1
                fi
                TARGET_PROJECT_ROOT="$2"
                # Validate target directory exists
                if [[ ! -d "$TARGET_PROJECT_ROOT" ]]; then
                    print_error "Target directory does not exist: $TARGET_PROJECT_ROOT"
                    exit 1
                fi
                # Convert to absolute path
                TARGET_PROJECT_ROOT="$(cd "$TARGET_PROJECT_ROOT" && pwd)"
                PROJECT_ROOT="$TARGET_PROJECT_ROOT"
                SRC_DIR="${PROJECT_ROOT}/src"
                
                # Set artifact directories to target project's .ai_workflow directory
                # This prevents permission issues when accessing logs from different directories
                BACKLOG_DIR="${PROJECT_ROOT}/.ai_workflow/backlog"
                SUMMARIES_DIR="${PROJECT_ROOT}/.ai_workflow/summaries"
                LOGS_DIR="${PROJECT_ROOT}/.ai_workflow/logs"
                PROMPTS_DIR="${PROJECT_ROOT}/.ai_workflow/prompts"
                METRICS_DIR="${PROJECT_ROOT}/.ai_workflow/metrics"
                
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
                export AUTO_MODE
                export INTERACTIVE_MODE
                print_info "Automatic mode enabled"
                shift
                ;;
            --auto-commit)
                AUTO_COMMIT=true
                export AUTO_COMMIT
                print_info "Auto-commit mode enabled - workflow artifacts will be committed automatically"
                shift
                ;;
            --ai-batch)
                AI_BATCH_MODE=true
                export AI_BATCH_MODE
                print_info "AI batch mode enabled - AI prompts will run non-interactively"
                shift
                ;;
            --interactive)
                INTERACTIVE_MODE=true
                AUTO_MODE=false
                export INTERACTIVE_MODE
                export AUTO_MODE
                shift
                ;;
            --verbose)
                VERBOSE=true
                print_info "Verbose mode enabled"
                shift
                ;;
            --stop)
                STOP_ON_COMPLETION=true
                print_info "Continuation prompt enabled"
                shift
                ;;
            --steps)
                if [[ -z "${2:-}" ]] || [[ "$2" == --* ]]; then
                    print_error "--steps requires an argument (e.g., '0,1,2' or 'all')"
                    exit 1
                fi
                EXECUTE_STEPS="$2"
                shift 2
                ;;
            --smart-execution)
                SMART_EXECUTION=true
                export SMART_EXECUTION
                print_info "Smart execution enabled - steps will be skipped based on change detection"
                shift
                ;;
            --force-model)
                if [[ -z "${2:-}" ]] || [[ "$2" == --* ]]; then
                    print_error "--force-model requires a model name argument"
                    exit 1
                fi
                
                # Validate model name if model_selector is available
                local model_valid=true
                if command -v validate_model_name &>/dev/null; then
                    if ! validate_model_name "$2"; then
                        model_valid=false
                        print_error "Invalid model name: $2"
                        echo ""
                        echo "Supported models:"
                        list_supported_models | tr ' ' '\n' | sed 's/^/  - /'
                        echo ""
                        echo "Did you mean one of these?"
                        suggest_similar_models "$2" | tr ' ' '\n' | sed 's/^/  - /'
                        exit 1
                    fi
                fi
                
                FORCE_MODEL="$2"
                export FORCE_MODEL
                print_info "Force model enabled - all AI steps will use: $FORCE_MODEL"
                shift 2
                ;;
            --show-model-plan)
                SHOW_MODEL_PLAN=true
                export SHOW_MODEL_PLAN
                print_info "Show model plan mode - will display model assignments and exit"
                shift
                ;;
            --no-smart-execution)
                SMART_EXECUTION=false
                export SMART_EXECUTION
                print_info "Smart execution disabled - all steps will run"
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
                print_info "Parallel execution enabled - independent steps will run simultaneously"
                shift
                ;;
            --no-parallel)
                PARALLEL_EXECUTION=false
                USER_DISABLED_PARALLEL=true  # Track that user explicitly disabled parallel
                export PARALLEL_EXECUTION USER_DISABLED_PARALLEL
                print_info "Parallel execution disabled - sequential execution"
                shift
                ;;
            --parallel-tracks)
                PARALLEL_TRACKS=true
                PARALLEL_EXECUTION=true  # Implies parallel execution
                export PARALLEL_TRACKS PARALLEL_EXECUTION
                print_info "3-Track parallel execution enabled - optimal performance mode"
                shift
                ;;
            --no-ai-cache)
                USE_AI_CACHE=false
                export USE_AI_CACHE
                print_warning "AI response caching disabled - this will increase token usage"
                shift
                ;;
            --no-resume)
                NO_RESUME=true
                export NO_RESUME
                print_info "Fresh start enabled - ignoring any checkpoints"
                shift
                ;;
            --skip-submodules)
                SKIP_SUBMODULES=true
                export SKIP_SUBMODULES
                print_info "Git submodule operations disabled"
                shift
                ;;
            --cleanup-days)
                if [[ -z "${2:-}" ]] || [[ "$2" == --* ]]; then
                    print_error "--cleanup-days requires a number argument"
                    exit 1
                fi
                if ! [[ "$2" =~ ^[0-9]+$ ]]; then
                    print_error "--cleanup-days must be a positive number"
                    exit 1
                fi
                CLEANUP_DAYS="$2"
                export CLEANUP_DAYS
                print_info "Artifact cleanup retention set to ${CLEANUP_DAYS} days"
                shift 2
                ;;
            --no-cleanup)
                NO_CLEANUP=true
                export NO_CLEANUP
                print_info "Artifact cleanup disabled"
                shift
                ;;
            --show-tech-stack)
                SHOW_TECH_STACK=true
                export SHOW_TECH_STACK
                shift
                ;;
            --config-file)
                if [[ -z "${2:-}" ]] || [[ "$2" == --* ]]; then
                    print_error "--config-file requires a file path argument"
                    exit 1
                fi
                TECH_STACK_CONFIG_FILE="$2"
                export TECH_STACK_CONFIG_FILE
                print_info "Using config file: $TECH_STACK_CONFIG_FILE"
                shift 2
                ;;
            --init-config)
                INIT_CONFIG_WIZARD=true
                export INIT_CONFIG_WIZARD
                shift
                ;;
            --enhanced-validations)
                ENABLE_ENHANCED_VALIDATIONS=true
                export ENABLE_ENHANCED_VALIDATIONS
                print_info "Enhanced validations enabled (lint, changelog, CDN, metrics)"
                shift
                ;;
            --strict-validations)
                ENABLE_ENHANCED_VALIDATIONS=true
                STRICT_VALIDATIONS=true
                export ENABLE_ENHANCED_VALIDATIONS STRICT_VALIDATIONS
                print_info "Strict validation mode enabled - workflow will fail if validations fail"
                shift
                ;;
            --ml-optimize)
                ML_OPTIMIZE=true
                export ML_OPTIMIZE
                print_info "ML optimization enabled - predictive workflow optimization"
                shift
                ;;
            --intelligent-skip)
                INTELLIGENT_SKIP=true
                export INTELLIGENT_SKIP
                print_info "Intelligent skip prediction enabled - ML-powered step necessity analysis"
                shift
                ;;
            --show-ml-status)
                SHOW_ML_STATUS=true
                export SHOW_ML_STATUS
                shift
                ;;
            --multi-stage)
                MULTI_STAGE=true
                export MULTI_STAGE
                print_info "Multi-stage pipeline enabled - progressive validation (3 stages)"
                shift
                ;;
            --show-pipeline)
                SHOW_PIPELINE=true
                export SHOW_PIPELINE
                shift
                ;;
            --manual-trigger)
                MANUAL_TRIGGER=true
                export MANUAL_TRIGGER
                print_info "Manual trigger enabled - all 3 stages will execute"
                shift
                ;;
            --generate-docs)
                AUTO_GENERATE_DOCS=true
                export AUTO_GENERATE_DOCS
                print_info "Auto-documentation enabled - workflow reports will be generated"
                shift
                ;;
            --update-changelog)
                AUTO_UPDATE_CHANGELOG=true
                export AUTO_UPDATE_CHANGELOG
                print_info "Auto-changelog enabled - CHANGELOG.md will be updated from commits"
                shift
                ;;
            --generate-api-docs)
                GENERATE_API_DOCS=true
                export GENERATE_API_DOCS
                print_info "API documentation generation enabled"
                shift
                ;;
            --install-hooks)
                INSTALL_HOOKS=true
                export INSTALL_HOOKS
                print_info "Pre-commit hooks will be installed"
                shift
                ;;
            --uninstall-hooks)
                UNINSTALL_HOOKS=true
                export UNINSTALL_HOOKS
                print_info "Pre-commit hooks will be uninstalled"
                shift
                ;;
            --test-hooks)
                TEST_HOOKS=true
                export TEST_HOOKS
                print_info "Pre-commit hooks will be tested"
                shift
                ;;
            --no-fast-track)
                DISABLE_FAST_TRACK=true
                export DISABLE_FAST_TRACK
                print_info "Fast track mode disabled - standard execution will be used"
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
                show_usage
                exit 1
                ;;
        esac
    done
}

# Validate that required arguments are provided
# Returns 0 if valid, 1 if invalid
validate_parsed_arguments() {
    local errors=0
    
    # Validate PROJECT_ROOT is set and exists
    if [[ -z "${PROJECT_ROOT:-}" ]]; then
        print_error "PROJECT_ROOT is not set"
        ((errors++)) || true
    elif [[ ! -d "$PROJECT_ROOT" ]]; then
        print_error "PROJECT_ROOT does not exist: $PROJECT_ROOT"
        ((errors++)) || true
    fi
    
    # Validate EXECUTE_STEPS format
    if [[ -n "${EXECUTE_STEPS:-}" ]] && [[ "$EXECUTE_STEPS" != "all" ]]; then
        if ! [[ "$EXECUTE_STEPS" =~ ^[0-9,]+$ ]]; then
            print_error "Invalid --steps format: must be 'all' or comma-separated numbers (e.g., '0,1,2')"
            ((errors++)) || true
        fi
    fi
    
    # Validate mutually exclusive modes
    if [[ "${AUTO_MODE:-false}" == "true" ]] && [[ "${INTERACTIVE_MODE:-false}" == "true" ]]; then
        print_error "Cannot use both --auto and --interactive modes"
        ((errors++)) || true
    fi
    
    # Validate config file if specified
    if [[ -n "${TECH_STACK_CONFIG_FILE:-}" ]] && [[ ! -f "$TECH_STACK_CONFIG_FILE" ]]; then
        print_error "Config file does not exist: $TECH_STACK_CONFIG_FILE"
        ((errors++)) || true
    fi
    
    # Set default artifact directories if not already set (no --target option used)
    if [[ -z "${BACKLOG_DIR:-}" ]]; then
        BACKLOG_DIR="${WORKFLOW_HOME}/.ai_workflow/backlog"
        SUMMARIES_DIR="${WORKFLOW_HOME}/.ai_workflow/summaries"
        LOGS_DIR="${WORKFLOW_HOME}/.ai_workflow/logs"
        PROMPTS_DIR="${WORKFLOW_HOME}/.ai_workflow/prompts"
        METRICS_DIR="${WORKFLOW_HOME}/.ai_workflow/metrics"
    fi
    
    # Export artifact directory variables
    export BACKLOG_DIR
    export SUMMARIES_DIR
    export LOGS_DIR
    export PROMPTS_DIR
    export METRICS_DIR
    
    # Set run-specific directories now that base directories are known
    BACKLOG_RUN_DIR="${BACKLOG_DIR}/${WORKFLOW_RUN_ID}"
    SUMMARIES_RUN_DIR="${SUMMARIES_DIR}/${WORKFLOW_RUN_ID}"
    LOGS_RUN_DIR="${LOGS_DIR}/${WORKFLOW_RUN_ID}"
    PROMPTS_RUN_DIR="${PROMPTS_DIR}/${WORKFLOW_RUN_ID}"
    WORKFLOW_LOG_FILE="${LOGS_RUN_DIR}/workflow_execution.log"
    
    export BACKLOG_RUN_DIR
    export SUMMARIES_RUN_DIR
    export LOGS_RUN_DIR
    export PROMPTS_RUN_DIR
    export WORKFLOW_LOG_FILE
    
    return $errors
}

# Display usage information
show_usage() {
    cat << 'EOF'
Usage: execute_tests_docs_workflow.sh [OPTIONS]

AI Workflow Automation - Intelligent workflow system for documentation,
code, and test validation with AI support.

OPTIONS:
  --target <dir>          Run workflow on specified project directory
                         (default: current directory)
  
  --dry-run              Preview actions without making changes
  --auto                 Run in automatic mode (no prompts)
  --interactive          Run in interactive mode (default)
  --verbose              Enable detailed logging output
  
  --steps <list>         Execute specific steps (e.g., '0,5,6' or 'all')
  --smart-execution      Enable change-based step skipping
  --parallel             Enable parallel execution of independent steps
  --parallel-tracks      Enable 3-track parallel execution (optimal mode)
  --no-resume            Start fresh, ignore checkpoints
  --no-fast-track        Disable docs-only fast track optimization
  
  --show-graph           Display dependency graph and exit
  --show-tech-stack      Display tech stack configuration and exit
  
  --config-file <path>   Use specific configuration file
  --init-config          Run interactive configuration wizard
  
  --no-ai-cache          Disable AI response caching
  --stop                 Prompt for continuation after completion
  
  --cleanup-days <N>     Remove artifacts older than N days (default: 7)
  --no-cleanup           Disable automatic artifact cleanup
  
  --enhanced-validations    Enable additional validation checks:
                            • Pre-commit lint (npm run lint)
                            • Changelog validation (version changes)
                            • CDN readiness (cdn-urls.txt)
                            • Metrics health (history.jsonl)
  --strict-validations      Enable enhanced validations in strict mode
                            (workflow fails if validations fail)
  
  --help                 Display this help message
  --version              Display script version

EXAMPLES:
  # Run on current directory with all optimizations
  ./execute_tests_docs_workflow.sh --smart-execution --parallel --auto
  
  # Run with intelligent skip prediction (ML-powered)
  ./execute_tests_docs_workflow.sh --intelligent-skip --smart-execution --parallel
  
  # Run on different project
  ./execute_tests_docs_workflow.sh --target /path/to/project
  
  # Run specific steps only
  ./execute_tests_docs_workflow.sh --steps 0,5,6,7
  
  # Initialize configuration
  ./execute_tests_docs_workflow.sh --init-config

For more information, see: docs/TARGET_PROJECT_FEATURE.md
EOF
}

# Export functions for use in main script
export -f parse_workflow_arguments
export -f validate_parsed_arguments
export -f show_usage
