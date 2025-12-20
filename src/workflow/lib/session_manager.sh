#!/bin/bash
set -euo pipefail

################################################################################
# Bash Session Management Module
# Purpose: Manage unique bash sessions, timeouts, and cleanup for workflow steps
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# ==============================================================================
# SESSION ID GENERATION AND TRACKING
# ==============================================================================

# Global associative array to track active sessions
declare -gA ACTIVE_SESSIONS
declare -ga SESSION_CLEANUP_QUEUE

# Generate unique session ID with workflow context
# Usage: generate_session_id <step_num> <operation_name>
# Returns: session_id string (e.g., "step07_test_exec_20251113_193721_abc123")
generate_session_id() {
    local step_num="$1"
    local operation="$2"
    local timestamp
    local random_suffix
    
    timestamp=$(date +%Y%m%d_%H%M%S)
    random_suffix=$(head /dev/urandom | tr -dc a-z0-9 | head -c 6)
    
    local session_id="step${step_num}_${operation}_${timestamp}_${random_suffix}"
    echo "$session_id"
}

# Register a session for tracking and cleanup
# Usage: register_session <session_id> <description>
register_session() {
    local session_id="$1"
    local description="${2:-No description}"
    
    ACTIVE_SESSIONS["$session_id"]="$description"
    SESSION_CLEANUP_QUEUE+=("$session_id")
    
    print_info "Registered session: $session_id ($description)"
}

# Unregister a session after completion
# Usage: unregister_session <session_id>
unregister_session() {
    local session_id="$1"
    
    if [[ -v ACTIVE_SESSIONS["$session_id"] ]]; then
        unset ACTIVE_SESSIONS["$session_id"]
        
        # Remove from cleanup queue
        local new_queue=()
        for sid in "${SESSION_CLEANUP_QUEUE[@]}"; do
            [[ "$sid" != "$session_id" ]] && new_queue+=("$sid")
        done
        SESSION_CLEANUP_QUEUE=("${new_queue[@]}")
        
        print_info "Unregistered session: $session_id"
    fi
}

# ==============================================================================
# COMMAND EXECUTION WITH SESSION MANAGEMENT
# ==============================================================================

# Execute command with proper session management
# Usage: execute_with_session <step_num> <operation> <command> [timeout_seconds] [mode]
# Returns: command exit code
execute_with_session() {
    local step_num="$1"
    local operation="$2"
    local command="$3"
    local timeout="${4:-30}"
    local mode="${5:-sync}"
    
    local session_id
    session_id=$(generate_session_id "$step_num" "$operation")
    
    register_session "$session_id" "Executing: $command"
    
    print_info "Executing (session: $session_id, timeout: ${timeout}s, mode: $mode):"
    print_info "  → $command"
    
    local exit_code=0
    
    # Execute based on mode
    case "$mode" in
        sync)
            # Synchronous execution with timeout
            if timeout "$timeout" bash -c "$command" 2>&1; then
                exit_code=0
                print_success "Command completed successfully"
            else
                exit_code=$?
                if [[ $exit_code -eq 124 ]]; then
                    print_error "Command timed out after ${timeout}s"
                else
                    print_warning "Command exited with code: $exit_code"
                fi
            fi
            ;;
            
        async)
            # Asynchronous execution - background process
            print_info "Starting async command (PID tracking enabled)..."
            bash -c "$command" &
            local pid=$!
            ACTIVE_SESSIONS["${session_id}_pid"]="$pid"
            print_info "Background process started (PID: $pid)"
            exit_code=0
            ;;
            
        detached)
            # Detached execution - completely independent
            print_info "Starting detached command (no PID tracking)..."
            nohup bash -c "$command" > "/tmp/${session_id}.log" 2>&1 &
            print_info "Detached process started (logs: /tmp/${session_id}.log)"
            exit_code=0
            ;;
            
        *)
            print_error "Invalid execution mode: $mode (use: sync|async|detached)"
            exit_code=1
            ;;
    esac
    
    # For sync mode, immediately cleanup
    if [[ "$mode" == "sync" ]]; then
        unregister_session "$session_id"
    fi
    
    return $exit_code
}

# ==============================================================================
# ASYNC PROCESS MANAGEMENT
# ==============================================================================

# Wait for async session to complete
# Usage: wait_for_session <session_id> [timeout_seconds]
# Returns: 0 if completed successfully, 1 if timeout or error
wait_for_session() {
    local session_id="$1"
    local timeout="${2:-60}"
    local pid_key="${session_id}_pid"
    
    if [[ ! -v ACTIVE_SESSIONS["$pid_key"] ]]; then
        print_warning "Session $session_id not found or already completed"
        return 1
    fi
    
    local pid="${ACTIVE_SESSIONS[$pid_key]}"
    print_info "Waiting for session $session_id (PID: $pid, timeout: ${timeout}s)..."
    
    local elapsed=0
    local interval=1
    
    while kill -0 "$pid" 2>/dev/null; do
        sleep $interval
        ((elapsed += interval))
        
        if [[ $elapsed -ge $timeout ]]; then
            print_error "Session timed out after ${timeout}s"
            kill "$pid" 2>/dev/null
            unset ACTIVE_SESSIONS["$pid_key"]
            return 1
        fi
        
        # Progress indicator every 10 seconds
        if (( elapsed % 10 == 0 )); then
            print_info "  ... still waiting (${elapsed}s elapsed)"
        fi
    done
    
    # Get exit status
    wait "$pid"
    local exit_code=$?
    
    unset ACTIVE_SESSIONS["$pid_key"]
    unregister_session "$session_id"
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "Session completed successfully"
    else
        print_warning "Session exited with code: $exit_code"
    fi
    
    return $exit_code
}

# Kill async session
# Usage: kill_session <session_id>
kill_session() {
    local session_id="$1"
    local pid_key="${session_id}_pid"
    
    if [[ -v ACTIVE_SESSIONS["$pid_key"] ]]; then
        local pid="${ACTIVE_SESSIONS[$pid_key]}"
        print_warning "Killing session $session_id (PID: $pid)..."
        
        kill -TERM "$pid" 2>/dev/null || kill -KILL "$pid" 2>/dev/null
        
        unset ACTIVE_SESSIONS["$pid_key"]
        unregister_session "$session_id"
        
        print_success "Session terminated"
    else
        print_warning "Session $session_id not found or already terminated"
    fi
}

# ==============================================================================
# CLEANUP AND RESOURCE MANAGEMENT
# ==============================================================================

# Cleanup all active sessions (called on exit/interrupt)
# Usage: cleanup_all_sessions
cleanup_all_sessions() {
    if [[ ${#SESSION_CLEANUP_QUEUE[@]} -eq 0 ]]; then
        return 0
    fi
    
    print_warning "Cleaning up ${#SESSION_CLEANUP_QUEUE[@]} active session(s)..."
    
    for session_id in "${SESSION_CLEANUP_QUEUE[@]}"; do
        local pid_key="${session_id}_pid"
        
        # Kill async processes if they exist
        if [[ -v ACTIVE_SESSIONS["$pid_key"] ]]; then
            local pid="${ACTIVE_SESSIONS[$pid_key]}"
            if kill -0 "$pid" 2>/dev/null; then
                print_info "Terminating session: $session_id (PID: $pid)"
                kill -TERM "$pid" 2>/dev/null || kill -KILL "$pid" 2>/dev/null
            fi
        fi
        
        unregister_session "$session_id"
    done
    
    print_success "All sessions cleaned up"
}

# List all active sessions
# Usage: list_active_sessions
list_active_sessions() {
    if [[ ${#ACTIVE_SESSIONS[@]} -eq 0 ]]; then
        print_info "No active sessions"
        return 0
    fi
    
    echo ""
    print_header "Active Sessions (${#ACTIVE_SESSIONS[@]})"
    
    for key in "${!ACTIVE_SESSIONS[@]}"; do
        # Skip PID entries in listing
        if [[ ! "$key" =~ _pid$ ]]; then
            local description="${ACTIVE_SESSIONS[$key]}"
            echo -e "${CYAN}  • ${key}${NC}"
            echo -e "    ${YELLOW}${description}${NC}"
        fi
    done
    
    echo ""
}

# ==============================================================================
# TIMEOUT CONFIGURATION
# ==============================================================================

# Get recommended timeout for common operations
# Usage: get_recommended_timeout <operation_type>
# Returns: timeout in seconds
get_recommended_timeout() {
    local operation="$1"
    
    case "$operation" in
        "npm_test")
            echo "300"  # 5 minutes for test suite
            ;;
        "npm_install")
            echo "120"  # 2 minutes for dependency installation
            ;;
        "npm_build")
            echo "180"  # 3 minutes for build
            ;;
        "git_operation")
            echo "30"   # 30 seconds for git commands
            ;;
        "file_operation")
            echo "10"   # 10 seconds for file I/O
            ;;
        "validation")
            echo "60"   # 1 minute for validation tasks
            ;;
        "ai_analysis")
            echo "300"  # 5 minutes for AI processing
            ;;
        *)
            echo "30"   # Default 30 seconds
            ;;
    esac
}

# ==============================================================================
# HELPER FUNCTIONS FOR COMMON WORKFLOW OPERATIONS
# ==============================================================================

# Execute npm command with proper session management
# Usage: execute_npm_command <step_num> <npm_command> [args...]
execute_npm_command() {
    local step_num="$1"
    local npm_command="$2"
    shift 2
    local npm_args="$*"
    
    local operation="npm_${npm_command}"
    local timeout
    timeout=$(get_recommended_timeout "$operation")
    
    local full_command="npm ${npm_command} ${npm_args}"
    
    execute_with_session "$step_num" "$operation" "$full_command" "$timeout" "sync"
}

# Execute git command with proper session management
# Usage: execute_git_command <step_num> <git_args...>
execute_git_command() {
    local step_num="$1"
    shift
    local git_args="$*"
    
    local operation="git_operation"
    local timeout
    timeout=$(get_recommended_timeout "git_operation")
    
    local full_command="git $git_args"
    
    execute_with_session "$step_num" "$operation" "$full_command" "$timeout" "sync"
}

# ==============================================================================
# INTEGRATION WITH WORKFLOW CLEANUP
# ==============================================================================

# Enhanced cleanup that includes session management
# Should be called from main workflow cleanup handler
enhanced_workflow_cleanup() {
    local exit_code=$?
    
    print_info "Running enhanced cleanup..."
    
    # Cleanup bash sessions
    cleanup_all_sessions
    
    # Call original cleanup if it exists
    if declare -f cleanup > /dev/null; then
        cleanup
    fi
    
    exit $exit_code
}

# ==============================================================================
# EXPORTS
# ==============================================================================

# Export all session management functions
export -f generate_session_id register_session unregister_session
export -f execute_with_session wait_for_session kill_session
export -f cleanup_all_sessions list_active_sessions
export -f get_recommended_timeout
export -f execute_npm_command execute_git_command
export -f enhanced_workflow_cleanup
