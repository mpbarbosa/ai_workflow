#!/bin/bash
set -euo pipefail

################################################################################
# Example: Session Manager Integration
# Purpose: Demonstrate session management best practices in workflow steps
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/session_manager.sh"

# Register cleanup handler
trap cleanup_all_sessions EXIT INT TERM

# ==============================================================================
# EXAMPLE 1: Basic Sync Execution with Recommended Timeouts
# ==============================================================================

example1_basic_sync() {
    print_header "Example 1: Basic Sync Execution"
    
    # Get recommended timeout for npm test
    local timeout
    timeout=$(get_recommended_timeout "npm_test")
    
    print_info "Running tests with ${timeout}s timeout..."
    
    # Execute with session management
    if execute_with_session "07" "test_suite" "npm test" "$timeout" "sync"; then
        print_success "Tests completed successfully"
        return 0
    else
        print_error "Tests failed"
        return 1
    fi
}

# ==============================================================================
# EXAMPLE 2: Async Execution with Wait
# ==============================================================================

example2_async_with_wait() {
    print_header "Example 2: Async Execution with Wait"
    
    # Generate unique session ID
    local session_id
    session_id=$(generate_session_id "08" "long_build")
    
    print_info "Starting async build process..."
    register_session "$session_id" "Building project asynchronously"
    
    # Start async build
    execute_with_session "08" "long_build" "sleep 5 && echo 'Build complete'" 300 "async"
    
    print_info "Build running in background (session: $session_id)"
    print_info "Performing other tasks while build runs..."
    
    # Simulate other work
    sleep 2
    print_info "Other tasks completed"
    
    # Wait for build to complete
    print_info "Waiting for build to finish..."
    if wait_for_session "$session_id" 300; then
        print_success "Build completed successfully"
    else
        print_error "Build failed or timed out"
    fi
}

# ==============================================================================
# EXAMPLE 3: Multiple Parallel Operations
# ==============================================================================

example3_parallel_operations() {
    print_header "Example 3: Multiple Parallel Operations"
    
    # Start multiple async operations
    local session_ids=()
    
    # Operation 1: Install dependencies
    local sid1
    sid1=$(generate_session_id "01" "npm_install")
    register_session "$sid1" "Installing dependencies"
    execute_with_session "01" "npm_install" "sleep 2 && echo 'Dependencies installed'" 120 "async"
    session_ids+=("$sid1")
    
    # Operation 2: Lint code
    local sid2
    sid2=$(generate_session_id "02" "lint_check")
    register_session "$sid2" "Running linter"
    execute_with_session "02" "lint_check" "sleep 3 && echo 'Linting complete'" 60 "async"
    session_ids+=("$sid2")
    
    # Operation 3: Run tests
    local sid3
    sid3=$(generate_session_id "03" "test_suite")
    register_session "$sid3" "Running test suite"
    execute_with_session "03" "test_suite" "sleep 4 && echo 'Tests passed'" 300 "async"
    session_ids+=("$sid3")
    
    print_info "Started ${#session_ids[@]} parallel operations"
    list_active_sessions
    
    # Wait for all to complete
    print_info "Waiting for all operations to complete..."
    for sid in "${session_ids[@]}"; do
        if wait_for_session "$sid" 300; then
            print_success "Session $sid completed"
        else
            print_error "Session $sid failed"
        fi
    done
    
    print_success "All parallel operations completed"
}

# ==============================================================================
# EXAMPLE 4: Convenience Wrapper Functions
# ==============================================================================

example4_convenience_wrappers() {
    print_header "Example 4: Convenience Wrapper Functions"
    
    # NPM commands with automatic timeouts
    print_info "Using npm command wrapper..."
    execute_npm_command "04" "run" "lint" || print_warning "Linting failed (may not exist)"
    
    # Git commands
    print_info "Using git command wrapper..."
    execute_git_command "11" "status" "--short"
    execute_git_command "11" "branch" "--show-current"
    
    print_success "Convenience wrappers executed"
}

# ==============================================================================
# EXAMPLE 5: Error Handling and Timeout Management
# ==============================================================================

example5_error_handling() {
    print_header "Example 5: Error Handling and Timeout"
    
    # Test 1: Successful command
    print_info "Test 1: Successful command"
    if execute_with_session "05" "success_test" "echo 'Success'" 5 "sync"; then
        print_success "Command succeeded as expected"
    fi
    
    # Test 2: Failing command
    print_info "Test 2: Failing command"
    if ! execute_with_session "05" "failure_test" "exit 1" 5 "sync"; then
        print_success "Failure handled correctly"
    fi
    
    # Test 3: Timeout scenario
    print_info "Test 3: Timeout scenario (will timeout after 2s)"
    if ! execute_with_session "05" "timeout_test" "sleep 10" 2 "sync"; then
        print_success "Timeout handled correctly"
    fi
}

# ==============================================================================
# EXAMPLE 6: Real-World Workflow Step
# ==============================================================================

example6_realistic_workflow_step() {
    print_header "Example 6: Realistic Workflow Step"
    
    print_step "7" "Execute Test Suite"
    
    # Change to source directory
    cd "$SRC_DIR" || return 1
    
    # Phase 1: Install dependencies
    print_info "Phase 1: Installing dependencies..."
    local install_timeout
    install_timeout=$(get_recommended_timeout "npm_install")
    
    if execute_with_session "07" "npm_install" "npm install --silent" "$install_timeout" "sync"; then
        print_success "Dependencies installed"
    else
        print_error "Dependency installation failed"
        return 1
    fi
    
    # Phase 2: Run tests
    print_info "Phase 2: Running test suite..."
    local test_timeout
    test_timeout=$(get_recommended_timeout "npm_test")
    
    if execute_with_session "07" "test_suite" "npm test" "$test_timeout" "sync"; then
        print_success "All tests passed"
    else
        print_warning "Some tests failed - review results"
        
        if confirm_action "Continue despite test failures?" "n"; then
            print_info "Continuing workflow..."
        else
            return 1
        fi
    fi
    
    # Phase 3: Check coverage
    print_info "Phase 3: Checking coverage..."
    if execute_with_session "07" "coverage_check" "npm run test:coverage --silent" "$test_timeout" "sync"; then
        print_success "Coverage report generated"
    fi
    
    cd "$PROJECT_ROOT" || return 1
    print_success "Workflow step completed"
}

# ==============================================================================
# MAIN DEMONSTRATION
# ==============================================================================

main() {
    print_header "Session Manager Integration Examples"
    echo -e "${CYAN}Demonstrating best practices for bash session management${NC}\n"
    
    # Run examples
    example1_basic_sync
    echo ""
    
    example2_async_with_wait
    echo ""
    
    example3_parallel_operations
    echo ""
    
    example4_convenience_wrappers
    echo ""
    
    example5_error_handling
    echo ""
    
    # Optional: Real workflow step (requires npm)
    if command -v npm &> /dev/null && confirm_action "Run realistic workflow step example (requires npm)?" "n"; then
        example6_realistic_workflow_step
    else
        print_info "Skipping realistic workflow step example"
    fi
    
    echo ""
    print_header "Examples Completed"
    print_success "All session manager examples executed successfully"
    print_info "Active sessions will be cleaned up on exit"
    
    # Show final state
    list_active_sessions
}

# Execute main function
main "$@"
