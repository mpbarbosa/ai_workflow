#!/bin/bash
################################################################################
# File Operations Module with Resilience
# Purpose: Safe file operations with pre-flight checks and fallback behavior
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# ==============================================================================
# FILE EXISTENCE CHECKS
# ==============================================================================

# Check if file exists and handle according to strategy
# Usage: check_file_exists <filepath> <strategy>
# Strategies: fail, overwrite, append_timestamp, increment, prompt
# Returns: 0 if OK to proceed, 1 if should abort
check_file_exists() {
    local filepath="$1"
    local strategy="${2:-fail}"
    
    if [[ ! -f "$filepath" ]]; then
        return 0  # File doesn't exist, OK to create
    fi
    
    # File exists - apply strategy
    case "$strategy" in
        fail)
            print_error "File already exists: $filepath"
            print_error "Aborting to prevent data loss"
            return 1
            ;;
            
        overwrite)
            print_warning "File exists: $filepath"
            print_warning "Will overwrite (strategy: overwrite)"
            return 0
            ;;
            
        append_timestamp)
            print_warning "File exists: $filepath"
            print_info "Will append timestamp (strategy: append_timestamp)"
            return 2  # Special code: caller should use get_safe_filename
            ;;
            
        increment)
            print_warning "File exists: $filepath"
            print_info "Will find next available number (strategy: increment)"
            return 2  # Special code: caller should use get_safe_filename
            ;;
            
        prompt)
            print_warning "File exists: $filepath"
            if [[ "$INTERACTIVE_MODE" == true ]]; then
                echo -e "${YELLOW}Options:${NC}"
                echo "  1) Overwrite"
                echo "  2) Append timestamp"
                echo "  3) Increment counter"
                echo "  4) Abort"
                read -p "Choose (1-4): " choice < /dev/tty
                
                case "$choice" in
                    1) return 0 ;;           # Overwrite
                    2) return 2 ;;           # Append timestamp
                    3) return 3 ;;           # Increment
                    *) return 1 ;;           # Abort
                esac
            else
                print_error "File exists and INTERACTIVE_MODE is false"
                return 1
            fi
            ;;
            
        *)
            print_error "Unknown file existence strategy: $strategy"
            return 1
            ;;
    esac
}

# ==============================================================================
# SAFE FILENAME GENERATION
# ==============================================================================

# Generate safe filename when file exists
# Usage: get_safe_filename <filepath> <strategy>
# Returns: safe filename via stdout
get_safe_filename() {
    local filepath="$1"
    local strategy="${2:-append_timestamp}"
    
    local dir=$(dirname "$filepath")
    local basename=$(basename "$filepath")
    local filename="${basename%.*}"
    local extension="${basename##*.}"
    
    # Handle files without extension
    if [[ "$filename" == "$extension" ]]; then
        extension=""
    else
        extension=".$extension"
    fi
    
    case "$strategy" in
        append_timestamp|2)
            local timestamp
            timestamp=$(date +%Y%m%d_%H%M%S)
            echo "${dir}/${filename}_${timestamp}${extension}"
            ;;
            
        increment|3)
            local counter=1
            local new_path
            
            while true; do
                new_path="${dir}/${filename}_${counter}${extension}"
                if [[ ! -f "$new_path" ]]; then
                    echo "$new_path"
                    return 0
                fi
                ((counter++))
                
                if [[ $counter -gt 1000 ]]; then
                    print_error "Too many file versions (>1000)"
                    return 1
                fi
            done
            ;;
            
        *)
            print_error "Invalid strategy for get_safe_filename: $strategy"
            return 1
            ;;
    esac
}

# ==============================================================================
# SAFE FILE CREATION
# ==============================================================================

# Create file safely with pre-flight check
# Usage: safe_create_file <filepath> <content> [strategy] [backup]
# Returns: 0 on success, 1 on failure
# Outputs: actual filepath used (may differ if renamed)
safe_create_file() {
    local filepath="$1"
    local content="$2"
    local strategy="${3:-fail}"
    local backup="${4:-false}"
    
    # Pre-flight check
    check_file_exists "$filepath" "$strategy"
    local check_result=$?
    
    case $check_result in
        0)
            # OK to create
            local actual_path="$filepath"
            ;;
            
        1)
            # Abort
            return 1
            ;;
            
        2|3)
            # Need to generate new filename
            local actual_path
            actual_path=$(get_safe_filename "$filepath" "$check_result")
            if [[ $? -ne 0 ]]; then
                return 1
            fi
            print_info "Using alternative filename: $(basename "$actual_path")"
            ;;
            
        *)
            print_error "Unexpected check result: $check_result"
            return 1
            ;;
    esac
    
    # Create backup if requested and file exists
    if [[ "$backup" == true ]] && [[ -f "$actual_path" ]]; then
        local backup_path="${actual_path}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$actual_path" "$backup_path"
        print_info "Created backup: $(basename "$backup_path")"
    fi
    
    # Create the file
    if echo -e "$content" > "$actual_path" 2>/dev/null; then
        print_success "Created: $(basename "$actual_path")"
        echo "$actual_path"  # Output actual path for caller
        return 0
    else
        print_error "Failed to create file: $actual_path"
        return 1
    fi
}

# ==============================================================================
# SAFE MARKDOWN FILE CREATION (WORKFLOW SPECIFIC)
# ==============================================================================

# Create markdown file with header and content
# Usage: safe_create_markdown <filepath> <title> <content> [strategy]
safe_create_markdown() {
    local filepath="$1"
    local title="$2"
    local content="$3"
    local strategy="${4:-append_timestamp}"
    
    local full_content="# ${title}

**Created:** $(date '+%Y-%m-%d %H:%M:%S')
**Workflow Run:** ${WORKFLOW_RUN_ID:-N/A}

---

${content}

---

*Generated by ${SCRIPT_NAME:-workflow} v${SCRIPT_VERSION:-1.0.0}*
"
    
    safe_create_file "$filepath" "$full_content" "$strategy" false
}

# ==============================================================================
# DIRECTORY OPERATIONS
# ==============================================================================

# Ensure directory exists, create if needed
# Usage: ensure_directory <dirpath> [permissions]
ensure_directory() {
    local dirpath="$1"
    local permissions="${2:-755}"
    
    if [[ -d "$dirpath" ]]; then
        return 0
    fi
    
    if [[ -f "$dirpath" ]]; then
        print_error "Path exists but is a file, not directory: $dirpath"
        return 1
    fi
    
    if mkdir -p "$dirpath" 2>/dev/null; then
        chmod "$permissions" "$dirpath" 2>/dev/null || true
        print_info "Created directory: $dirpath"
        return 0
    else
        print_error "Failed to create directory: $dirpath"
        return 1
    fi
}

# ==============================================================================
# ERROR RECOVERY
# ==============================================================================

# Retry operation with exponential backoff
# Usage: retry_operation <max_attempts> <command> [args...]
retry_operation() {
    local max_attempts="$1"
    shift
    local command="$@"
    
    local attempt=1
    local delay=1
    
    while [[ $attempt -le $max_attempts ]]; do
        print_info "Attempt $attempt/$max_attempts: $command"
        
        if eval "$command"; then
            return 0
        fi
        
        if [[ $attempt -lt $max_attempts ]]; then
            print_warning "Attempt $attempt failed, retrying in ${delay}s..."
            sleep $delay
            delay=$((delay * 2))  # Exponential backoff
        fi
        
        ((attempt++))
    done
    
    print_error "All $max_attempts attempts failed"
    return 1
}

# ==============================================================================
# ATOMIC FILE OPERATIONS
# ==============================================================================

# Atomic file update (write to temp, then move)
# Usage: atomic_update_file <filepath> <content> [strategy]
atomic_update_file() {
    local filepath="$1"
    local content="$2"
    local strategy="${3:-fail}"
    
    local temp_file="${filepath}.tmp.$$"
    
    # Write to temp file
    if ! echo -e "$content" > "$temp_file" 2>/dev/null; then
        print_error "Failed to write temporary file: $temp_file"
        return 1
    fi
    
    # Check if target exists
    check_file_exists "$filepath" "$strategy"
    local check_result=$?
    
    if [[ $check_result -eq 1 ]]; then
        rm -f "$temp_file"
        return 1
    fi
    
    local actual_path="$filepath"
    if [[ $check_result -ge 2 ]]; then
        actual_path=$(get_safe_filename "$filepath" "$check_result")
        if [[ $? -ne 0 ]]; then
            rm -f "$temp_file"
            return 1
        fi
    fi
    
    # Atomic move
    if mv "$temp_file" "$actual_path" 2>/dev/null; then
        print_success "Atomically updated: $(basename "$actual_path")"
        echo "$actual_path"
        return 0
    else
        print_error "Failed to move temp file to: $actual_path"
        rm -f "$temp_file"
        return 1
    fi
}

# ==============================================================================
# FILE LOCKING
# ==============================================================================

# Acquire file lock
# Usage: acquire_file_lock <lockfile> [timeout_seconds]
acquire_file_lock() {
    local lockfile="$1"
    local timeout="${2:-30}"
    local elapsed=0
    
    while [[ $elapsed -lt $timeout ]]; do
        if mkdir "$lockfile" 2>/dev/null; then
            echo $$ > "${lockfile}/pid"
            return 0
        fi
        
        # Check if lock is stale
        if [[ -f "${lockfile}/pid" ]]; then
            local lock_pid
            lock_pid=$(cat "${lockfile}/pid" 2>/dev/null || echo "")
            if [[ -n "$lock_pid" ]] && ! kill -0 "$lock_pid" 2>/dev/null; then
                print_warning "Removing stale lock (PID: $lock_pid)"
                release_file_lock "$lockfile"
                continue
            fi
        fi
        
        sleep 1
        ((elapsed++))
    done
    
    print_error "Failed to acquire lock after ${timeout}s: $lockfile"
    return 1
}

# Release file lock
# Usage: release_file_lock <lockfile>
release_file_lock() {
    local lockfile="$1"
    
    if [[ -d "$lockfile" ]]; then
        rm -rf "$lockfile"
        return 0
    fi
    
    return 1
}

# ==============================================================================
# INTEGRATED WORKFLOW FUNCTIONS
# ==============================================================================

# Save step issues with resilience (replaces save_step_issues from utils.sh)
# Usage: resilient_save_step_issues <step_num> <step_name> <issues_content> [strategy]
resilient_save_step_issues() {
    local step_num="$1"
    local step_name="$2"
    local issues_content="$3"
    local strategy="${4:-append_timestamp}"
    
    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi
    
    # Ensure directory exists
    ensure_directory "$BACKLOG_RUN_DIR" || return 1
    
    local step_file="${BACKLOG_RUN_DIR}/step${step_num}_${step_name// /_}.md"
    
    # Process content
    local processed_content=$(echo -e "${issues_content}")
    
    # Create content
    local content="# Step ${step_num}: ${step_name}

**Workflow Run ID:** ${WORKFLOW_RUN_ID}
**Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')
**Status:** Issues Found

---

## Issues and Findings

${processed_content}

---

**Generated by:** ${SCRIPT_NAME} v${SCRIPT_VERSION}"
    
    # Create file safely
    local actual_file
    actual_file=$(safe_create_file "$step_file" "$content" "$strategy" false)
    
    if [[ $? -eq 0 ]]; then
        print_info "Saved issues to: $(basename "$actual_file")"
        return 0
    else
        return 1
    fi
}

# Save step summary with resilience
# Usage: resilient_save_step_summary <step_num> <step_name> <summary_content> <status> [strategy]
resilient_save_step_summary() {
    local step_num="$1"
    local step_name="$2"
    local summary_content="$3"
    local status="${4:-✅}"
    local strategy="${5:-append_timestamp}"
    
    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi
    
    # Ensure directory exists
    ensure_directory "$SUMMARIES_RUN_DIR" || return 1
    
    local summary_file="${SUMMARIES_RUN_DIR}/step${step_num}_${step_name// /_}_summary.md"
    
    local content="# Step ${step_num}: ${step_name} - Summary

**Status:** ${status}
**Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')
**Workflow Run:** ${WORKFLOW_RUN_ID}

---

## Conclusion

${summary_content}

---

*Generated by ${SCRIPT_NAME} v${SCRIPT_VERSION}*"
    
    # Create file safely
    local actual_file
    actual_file=$(safe_create_file "$summary_file" "$content" "$strategy" false)
    
    if [[ $? -eq 0 ]]; then
        print_info "Saved summary to: $(basename "$actual_file")"
        return 0
    else
        return 1
    fi
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f check_file_exists get_safe_filename safe_create_file safe_create_markdown
export -f ensure_directory retry_operation atomic_update_file
export -f acquire_file_lock release_file_lock
export -f resilient_save_step_issues resilient_save_step_summary
