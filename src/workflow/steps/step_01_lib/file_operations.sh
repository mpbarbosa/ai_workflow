#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 1 File Operations Module
# Purpose: File system operations for Step 1 documentation management
# Part of: Step 1 Refactoring - Phase 2
# Version: 1.0.0
################################################################################

# Prevent double-loading
if [[ "${STEP1_FILE_OPS_MODULE_LOADED:-}" == "true" ]]; then
    return 0
fi

# Module version
readonly STEP1_FILE_OPS_VERSION="1.0.0"

################################################################################
# PUBLIC API - File Checking
################################################################################

# Batch file existence checks
# Efficiently checks multiple files in a single pass
# Usage: batch_file_check_step1 <file1> <file2> <file3> ...
# Returns: List of missing files (one per line)
# Example: missing=$(batch_file_check_step1 "README.md" "docs/API.md")
batch_file_check_step1() {
    local missing_files=()
    
    # Check all files in single pass
    for file in "$@"; do
        [[ -f "$file" ]] || missing_files+=("$file")
    done
    
    # Return missing files
    printf '%s\n' "${missing_files[@]}"
    return 0
}

# Optimized multi-pattern grep with single-pass processing
# Combines multiple patterns into single grep for efficiency
# Usage: optimized_multi_grep_step1 <file> <pattern1> <pattern2> ...
# Returns: Combined grep results
# Example: results=$(optimized_multi_grep_step1 "file.txt" "error" "warning" "critical")
optimized_multi_grep_step1() {
    local file="$1"
    shift
    local patterns=("$@")
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    # Combine patterns with OR operator for single grep pass
    local combined_pattern
    combined_pattern=$(IFS='|'; echo "${patterns[*]}")
    
    grep -E "$combined_pattern" "$file" 2>/dev/null || true
    return 0
}

################################################################################
# PUBLIC API - Path Determination
################################################################################

# Determine target folder for documentation based on file path
# Analyzes file path patterns to determine appropriate directory
# Usage: determine_doc_folder_step1 <file_path>
# Returns: Absolute path to target folder
# Example: folder=$(determine_doc_folder_step1 "docs/api/README.md")
determine_doc_folder_step1() {
    local doc_file="$1"
    local target_folder=""
    
    # Require PROJECT_ROOT to be set
    if [[ -z "${PROJECT_ROOT:-}" ]]; then
        echo "ERROR: PROJECT_ROOT not set" >&2
        return 1
    fi
    
    # Determine folder based on file path patterns
    if [[ "$doc_file" =~ ^docs/ ]]; then
        target_folder="$PROJECT_ROOT/docs"
    elif [[ "$doc_file" =~ ^src/workflow/ ]]; then
        target_folder="$PROJECT_ROOT/src/workflow"
    elif [[ "$doc_file" =~ ^src/ ]]; then
        target_folder="$PROJECT_ROOT/src"
    elif [[ "$doc_file" == "README.md" ]] || [[ "$doc_file" =~ ^\.github/ ]]; then
        target_folder="$PROJECT_ROOT"
    else
        # Default to docs folder for unknown types
        target_folder="$PROJECT_ROOT/docs"
    fi
    
    echo "$target_folder"
    return 0
}

################################################################################
# PUBLIC API - File Saving
################################################################################

# Save AI-generated documentation to proper folder
# Automatically determines target location and creates directories
# Usage: save_ai_generated_docs_step1 <ai_output_file> <target_doc_file>
# Returns: 0 for success, 1 for failure
# Example: save_ai_generated_docs_step1 "/tmp/ai_output.md" "docs/API.md"
save_ai_generated_docs_step1() {
    local ai_output="$1"
    local target_doc="$2"
    
    # Validate input file exists
    if [[ ! -f "$ai_output" ]]; then
        if command -v print_error &>/dev/null; then
            print_error "AI output file not found: $ai_output"
        else
            echo "ERROR: AI output file not found: $ai_output" >&2
        fi
        return 1
    fi
    
    # Determine target folder
    local target_folder
    target_folder=$(determine_doc_folder_step1 "$target_doc")
    
    # Ensure target folder exists
    mkdir -p "$target_folder"
    
    # Construct full target path
    local target_path
    if [[ "$target_doc" == /* ]]; then
        # Absolute path provided
        target_path="$target_doc"
    else
        # Relative path - construct full path
        target_path="$PROJECT_ROOT/$target_doc"
    fi
    
    # Ensure parent directory exists
    mkdir -p "$(dirname "$target_path")"
    
    # Save AI-generated content
    if cp "$ai_output" "$target_path"; then
        if command -v print_success &>/dev/null; then
            print_success "AI-generated documentation saved to: $target_path"
        fi
        return 0
    else
        if command -v print_error &>/dev/null; then
            print_error "Failed to save AI-generated documentation to: $target_path"
        else
            echo "ERROR: Failed to save to: $target_path" >&2
        fi
        return 1
    fi
}

# Create backup of file before modification
# Usage: backup_file_step1 <file_path>
# Returns: 0 on success, 1 on failure
# Example: backup_file_step1 "docs/API.md"
backup_file_step1() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        return 1
    fi
    
    local backup_path="${file_path}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if cp "$file_path" "$backup_path"; then
        if command -v print_info &>/dev/null; then
            print_info "Backup created: $backup_path"
        fi
        return 0
    else
        return 1
    fi
}

# List files matching pattern recursively
# Usage: list_files_recursive_step1 <directory> <pattern>
# Returns: List of matching files
# Example: files=$(list_files_recursive_step1 "docs" "*.md")
list_files_recursive_step1() {
    local directory="$1"
    local pattern="${2:-*}"
    
    if [[ ! -d "$directory" ]]; then
        return 1
    fi
    
    find "$directory" -type f -name "$pattern" 2>/dev/null || true
    return 0
}

################################################################################
# EXPORTS
################################################################################

# Export all public functions
export -f batch_file_check_step1
export -f optimized_multi_grep_step1
export -f determine_doc_folder_step1
export -f save_ai_generated_docs_step1
export -f backup_file_step1
export -f list_files_recursive_step1

# Module loaded indicator
readonly STEP1_FILE_OPS_MODULE_LOADED=true
export STEP1_FILE_OPS_MODULE_LOADED
