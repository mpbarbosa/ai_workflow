#!/bin/bash
set -euo pipefail

################################################################################
# Cleanup Template Module
# Purpose: Standard cleanup patterns for workflow scripts
# Version: 1.0.0
# Part of: AI Workflow Automation
################################################################################

#######################################
# Standard cleanup handler for scripts that create temporary resources
#
# This template provides a reusable cleanup pattern for scripts that:
# - Create temporary files/directories
# - Spawn background processes
# - Open file descriptors
# - Acquire locks
#
# Usage: Copy this template into your script and customize the cleanup()
#        function based on your specific resources.
#
# Example integration:
#   source "$(dirname "$0")/lib/cleanup_template.sh"
#   setup_cleanup  # Initialize cleanup handler
#   # ... your script logic ...
#######################################

# ==============================================================================
# GLOBAL RESOURCE TRACKING
# ==============================================================================

# Track resources created by the script
declare -a TEMP_FILES=()
declare -a TEMP_DIRS=()
declare -a BACKGROUND_PIDS=()
declare -a LOCK_FILES=()

# ==============================================================================
# CLEANUP FUNCTION
# ==============================================================================

#######################################
# Cleanup function called on script exit
#
# Cleans up all tracked resources in reverse order of creation.
# Handles errors gracefully to ensure all cleanup attempts are made.
#
# Globals:
#   TEMP_FILES - Array of temporary files to remove
#   TEMP_DIRS - Array of temporary directories to remove
#   BACKGROUND_PIDS - Array of background process PIDs to terminate
#   LOCK_FILES - Array of lock files to release
# Arguments:
#   None
# Returns:
#   Exit code from script execution (preserved)
#######################################
cleanup() {
    local exit_code=$?
    
    # Prevent cleanup from running multiple times
    if [[ "${CLEANUP_RUNNING:-false}" == true ]]; then
        return $exit_code
    fi
    export CLEANUP_RUNNING=true
    
    echo "INFO: Cleaning up resources..." >&2
    
    # 1. Terminate background processes
    if [[ ${#BACKGROUND_PIDS[@]} -gt 0 ]]; then
        echo "INFO: Terminating ${#BACKGROUND_PIDS[@]} background processes..." >&2
        for pid in "${BACKGROUND_PIDS[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                echo "  Terminating PID $pid..." >&2
                kill "$pid" 2>/dev/null || true
                sleep 0.5
                # Force kill if still running
                if kill -0 "$pid" 2>/dev/null; then
                    kill -9 "$pid" 2>/dev/null || true
                fi
            fi
        done
    fi
    
    # 2. Release locks
    if [[ ${#LOCK_FILES[@]} -gt 0 ]]; then
        echo "INFO: Releasing ${#LOCK_FILES[@]} locks..." >&2
        for lock in "${LOCK_FILES[@]}"; do
            if [[ -e "$lock" ]]; then
                echo "  Releasing lock: $lock" >&2
                rm -rf "$lock" 2>/dev/null || true
            fi
        done
    fi
    
    # 3. Remove temporary files
    if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
        echo "INFO: Removing ${#TEMP_FILES[@]} temporary files..." >&2
        for file in "${TEMP_FILES[@]}"; do
            if [[ -f "$file" ]]; then
                rm -f "$file" 2>/dev/null || true
            fi
        done
    fi
    
    # 4. Remove temporary directories
    if [[ ${#TEMP_DIRS[@]} -gt 0 ]]; then
        echo "INFO: Removing ${#TEMP_DIRS[@]} temporary directories..." >&2
        for dir in "${TEMP_DIRS[@]}"; do
            if [[ -d "$dir" && "$dir" =~ ^/tmp/ ]]; then
                rm -rf "$dir" 2>/dev/null || true
            fi
        done
    fi
    
    echo "INFO: Cleanup complete" >&2
    exit $exit_code
}

# ==============================================================================
# RESOURCE TRACKING HELPERS
# ==============================================================================

#######################################
# Register a temporary file for cleanup
# Arguments:
#   $1 - Path to temporary file
#######################################
track_temp_file() {
    local file="$1"
    TEMP_FILES+=("$file")
}

#######################################
# Register a temporary directory for cleanup
# Arguments:
#   $1 - Path to temporary directory
#######################################
track_temp_dir() {
    local dir="$1"
    TEMP_DIRS+=("$dir")
}

#######################################
# Register a background process PID for cleanup
# Arguments:
#   $1 - Process ID
#######################################
track_background_pid() {
    local pid="$1"
    BACKGROUND_PIDS+=("$pid")
}

#######################################
# Register a lock file for cleanup
# Arguments:
#   $1 - Path to lock file
#######################################
track_lock_file() {
    local lock="$1"
    LOCK_FILES+=("$lock")
}

#######################################
# Create tracked temporary file
# Returns: Path to temp file via stdout
#######################################
create_tracked_temp_file() {
    local temp_file
    temp_file=$(mktemp) || return 1
    track_temp_file "$temp_file"
    echo "$temp_file"
}

#######################################
# Create tracked temporary directory
# Returns: Path to temp directory via stdout
#######################################
create_tracked_temp_dir() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    track_temp_dir "$temp_dir"
    echo "$temp_dir"
}

# ==============================================================================
# SETUP FUNCTION
# ==============================================================================

#######################################
# Initialize cleanup handler
#
# Call this once at the beginning of your script to set up
# the cleanup trap. Handles EXIT, INT (Ctrl+C), and TERM signals.
#######################################
setup_cleanup() {
    trap cleanup EXIT INT TERM
    echo "INFO: Cleanup handler initialized" >&2
}

# ==============================================================================
# USAGE EXAMPLE
# ==============================================================================

# Example script using this template:
#
# #!/bin/bash
# set -euo pipefail
# 
# source "$(dirname "$0")/lib/cleanup_template.sh"
# 
# # Initialize cleanup
# setup_cleanup
# 
# # Create tracked resources
# TEMP_DIR=$(create_tracked_temp_dir)
# TEMP_FILE=$(create_tracked_temp_file)
# 
# # Start background process
# sleep 300 &
# track_background_pid $!
# 
# # Acquire lock
# LOCK_FILE="/tmp/my-script.lock"
# mkdir "$LOCK_FILE" 2>/dev/null || exit 1
# track_lock_file "$LOCK_FILE"
# 
# # Your script logic here
# echo "Doing work..."
# 
# # Resources will be cleaned up automatically on exit

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f cleanup setup_cleanup
export -f track_temp_file track_temp_dir track_background_pid track_lock_file
export -f create_tracked_temp_file create_tracked_temp_dir
