#!/usr/bin/env bash

################################################################################
# Pre-Flight Orchestrator
# Version: 2.4.0
# Purpose: Pre-flight checks, initialization, and configuration setup
# Part of: Workflow Automation Modularization Phase 3
################################################################################

set -euo pipefail

# ==============================================================================
# PRE-FLIGHT CHECKS
# ==============================================================================

check_prerequisites() {
    print_info "Checking prerequisites..."
    log_to_workflow "INFO" "Checking prerequisites"
    
    # Check Bash version (require 4.0+)
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
        print_error "Bash 4.0 or higher is required (current: ${BASH_VERSION})"
        log_to_workflow "ERROR" "Insufficient Bash version: ${BASH_VERSION}"
        return 1
    fi
    
    # Check required commands
    local required_commands=("git" "node" "npm")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        print_error "Missing required commands: ${missing_commands[*]}"
        log_to_workflow "ERROR" "Missing commands: ${missing_commands[*]}"
        return 1
    fi
    
    # Check Node.js version (require 16.0+)
    local node_version
    node_version=$(node --version | sed 's/v//' | cut -d. -f1)
    if [[ "$node_version" -lt 16 ]]; then
        print_warning "Node.js 16+ recommended (current: $(node --version))"
        log_to_workflow "WARNING" "Node.js version $(node --version) may be insufficient"
    fi
    
    print_success "Prerequisites check completed"
    log_to_workflow "SUCCESS" "Prerequisites validated"
    return 0
}

validate_dependencies() {
    print_info "Validating project dependencies..."
    log_to_workflow "INFO" "Validating dependencies"
    
    cd "$PROJECT_ROOT"
    
    # Check if package.json exists
    if [[ ! -f "package.json" ]]; then
        print_warning "No package.json found - skipping dependency validation"
        log_to_workflow "WARNING" "No package.json in project root"
        return 0
    fi
    
    # Check if node_modules exists
    if [[ ! -d "node_modules" ]]; then
        print_warning "node_modules not found - dependencies may need installation"
        log_to_workflow "WARNING" "node_modules directory missing"
        
        if [[ "$INTERACTIVE_MODE" == true ]]; then
            echo ""
            read -p "Run npm install? (y/N) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                npm install
                print_success "Dependencies installed"
                log_to_workflow "SUCCESS" "Dependencies installed via npm install"
            fi
        else
            print_info "Skipping dependency installation (non-interactive mode)"
            log_to_workflow "INFO" "Skipped npm install in auto mode"
        fi
    else
        print_success "Dependencies validated"
        log_to_workflow "SUCCESS" "node_modules present"
    fi
    
    return 0
}

# ==============================================================================
# INITIALIZATION
# ==============================================================================

init_workflow_log() {
    {
        echo "=================================="
        echo "Workflow Execution Log"
        echo "=================================="
        echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Version: ${SCRIPT_VERSION}"
        echo "Project: ${PROJECT_ROOT}"
        echo "Workflow Home: ${WORKFLOW_HOME}"
        echo "=================================="
        echo ""
    } > "$WORKFLOW_LOG_FILE"
    
    print_success "Workflow log initialized: $WORKFLOW_LOG_FILE"
}

init_directories() {
    # Create backlog, summaries, and logs directories for this run
    mkdir -p "$BACKLOG_RUN_DIR"
    mkdir -p "$SUMMARIES_RUN_DIR"
    mkdir -p "$LOGS_RUN_DIR"
    
    print_info "Backlog directory: $BACKLOG_RUN_DIR"
    print_info "Summaries directory: $SUMMARIES_RUN_DIR"
    print_info "Logs directory: $LOGS_RUN_DIR"
    
    log_to_workflow "INFO" "Directories initialized"
}

# ==============================================================================
# CONFIGURATION VALIDATION
# ==============================================================================

validate_project_structure() {
    print_info "Validating project structure..."
    log_to_workflow "INFO" "Validating project structure"
    
    cd "$PROJECT_ROOT"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a git repository: $PROJECT_ROOT"
        log_to_workflow "ERROR" "Not a git repository"
        return 1
    fi
    
    # Check for basic project structure
    local warnings=0
    
    if [[ ! -d "src" ]] && [[ ! -d "lib" ]] && [[ ! -d "app" ]]; then
        print_warning "No standard source directory found (src/lib/app)"
        ((warnings++)) || true
    fi
    
    if [[ ! -f "README.md" ]]; then
        print_warning "No README.md found in project root"
        ((warnings++)) || true
    fi
    
    if [[ $warnings -gt 0 ]]; then
        print_warning "Project structure validation completed with $warnings warnings"
        log_to_workflow "WARNING" "Project structure validation: $warnings warnings"
    else
        print_success "Project structure validated"
        log_to_workflow "SUCCESS" "Project structure validated"
    fi
    
    return 0
}

# ==============================================================================
# PRE-FLIGHT ORCHESTRATION
# ==============================================================================

execute_preflight() {
    print_header "Pre-Flight Checks & Initialization"
    log_to_workflow "INFO" "Starting pre-flight phase"
    
    local start_time
    start_time=$(date +%s)
    
    # Initialize directories
    init_directories
    
    # Initialize workflow log
    init_workflow_log
    
    # Execute checks
    if ! check_prerequisites; then
        print_error "Prerequisites check failed"
        log_to_workflow "ERROR" "Pre-flight failed: prerequisites"
        return 1
    fi
    
    if ! validate_dependencies; then
        print_error "Dependency validation failed"
        log_to_workflow "ERROR" "Pre-flight failed: dependencies"
        return 1
    fi
    
    if ! validate_project_structure; then
        print_error "Project structure validation failed"
        log_to_workflow "ERROR" "Pre-flight failed: structure"
        return 1
    fi
    
    # Initialize git cache (performance optimization)
    init_git_cache
    
    # Initialize AI cache (v2.3.0)
    if [[ "$USE_AI_CACHE" == true ]]; then
        init_ai_cache
    fi
    
    # Initialize metrics collection (v2.3.0)
    init_metrics
    
    # Analyze change impact
    analyze_change_impact
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_success "Pre-flight completed in ${duration}s"
    log_to_workflow "SUCCESS" "Pre-flight phase completed in ${duration}s"
    
    return 0
}
