#!/bin/bash
set -euo pipefail

################################################################################
# Cleanup Handlers Module
# Purpose: Standardized cleanup patterns for workflow scripts
# Part of: Tests & Documentation Workflow Automation v2.4.0
################################################################################

# ==============================================================================
# STANDARDIZED CLEANUP PATTERNS
# ==============================================================================

# Global cleanup registry
declare -g -A CLEANUP_HANDLERS=()
declare -g -A CLEANUP_TEMP_FILES=()
declare -g -A CLEANUP_TEMP_DIRS=()
declare -g CLEANUP_INITIALIZED=false

# Initialize cleanup system
# Usage: init_cleanup
init_cleanup() {
    if [[ "$CLEANUP_INITIALIZED" == "true" ]]; then
        return 0
    fi
    
    # Register cleanup on EXIT, INT, TERM
    trap 'execute_cleanup' EXIT
    trap 'execute_cleanup; exit 130' INT
    trap 'execute_cleanup; exit 143' TERM
    
    CLEANUP_INITIALIZED=true
}

# Register a cleanup handler
# Usage: register_cleanup_handler <name> <command>
register_cleanup_handler() {
    local name="$1"
    local command="$2"
    
    init_cleanup
    CLEANUP_HANDLERS["$name"]="$command"
}

# Register a temporary file for cleanup
# Usage: register_temp_file <file_path>
register_temp_file() {
    local file_path="$1"
    
    init_cleanup
    CLEANUP_TEMP_FILES["$file_path"]="1"
}

# Register a temporary directory for cleanup
# Usage: register_temp_dir <dir_path>
register_temp_dir() {
    local dir_path="$1"
    
    init_cleanup
    CLEANUP_TEMP_DIRS["$dir_path"]="1"
}

# Unregister a cleanup handler
# Usage: unregister_cleanup_handler <name>
unregister_cleanup_handler() {
    local name="$1"
    unset 'CLEANUP_HANDLERS[$name]'
}

# Unregister a temporary file
# Usage: unregister_temp_file <file_path>
unregister_temp_file() {
    local file_path="$1"
    unset 'CLEANUP_TEMP_FILES[$file_path]'
}

# Execute all registered cleanup handlers
# Usage: execute_cleanup (called automatically on EXIT/INT/TERM)
execute_cleanup() {
    local exit_code=$?
    
    # Execute custom cleanup handlers
    for name in "${!CLEANUP_HANDLERS[@]}"; do
        local command="${CLEANUP_HANDLERS[$name]}"
        eval "$command" 2>/dev/null || true
    done
    
    # Clean up temporary files
    for file in "${!CLEANUP_TEMP_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            rm -f "$file" 2>/dev/null || true
        fi
    done
    
    # Clean up temporary directories
    for dir in "${!CLEANUP_TEMP_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir" 2>/dev/null || true
        fi
    done
    
    return $exit_code
}

# Create a temporary file and register for cleanup
# Usage: create_temp_file [prefix]
# Outputs: Path to temporary file
create_temp_file() {
    local prefix="${1:-tmp}"
    local temp_file
    
    temp_file=$(mktemp "${TMPDIR:-/tmp}/${prefix}.XXXXXX")
    register_temp_file "$temp_file"
    echo "$temp_file"
}

# Create a temporary directory and register for cleanup
# Usage: create_temp_dir [prefix]
# Outputs: Path to temporary directory
create_temp_dir() {
    local prefix="${1:-tmpdir}"
    local temp_dir
    
    temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/${prefix}.XXXXXX")
    register_temp_dir "$temp_dir"
    echo "$temp_dir"
}

# ==============================================================================
# COMMON CLEANUP SCENARIOS
# ==============================================================================

# Cleanup for workflow step execution
# Usage: cleanup_step_execution <step_number>
cleanup_step_execution() {
    local step_number="$1"
    
    # Clean up step-specific temporary files
    register_cleanup_handler "step_${step_number}" \
        "rm -f /tmp/step_${step_number}_*.tmp 2>/dev/null || true"
}

# Cleanup for test execution
# Usage: cleanup_test_execution
cleanup_test_execution() {
    # Clean up test artifacts
    register_cleanup_handler "test_cleanup" \
        "rm -rf ${TEST_TEMP_DIR:-/tmp/test_*} 2>/dev/null || true"
}

# Cleanup for session management
# Usage: cleanup_sessions
cleanup_sessions() {
    # Source session manager if available
    if [[ -f "${SCRIPT_DIR}/lib/session_manager.sh" ]]; then
        source "${SCRIPT_DIR}/lib/session_manager.sh"
        register_cleanup_handler "session_cleanup" "cleanup_all_sessions"
    fi
}

# ==============================================================================
# USAGE EXAMPLE
# ==============================================================================
#
# # In your script:
# source "${SCRIPT_DIR}/lib/cleanup_handlers.sh"
#
# # Initialize cleanup (done automatically on first registration)
# init_cleanup
#
# # Register custom handlers
# register_cleanup_handler "my_cleanup" "echo 'Cleaning up...'"
#
# # Create temporary files (auto-registered)
# temp_file=$(create_temp_file "myapp")
#
# # Register existing files/dirs
# register_temp_file "/tmp/myfile.txt"
# register_temp_dir "/tmp/mydir"
#
# # Cleanup happens automatically on EXIT/INT/TERM
#
