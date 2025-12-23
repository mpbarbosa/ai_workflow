#!/bin/bash
# Note: set -euo pipefail removed to allow this module to be sourced in test files
# Individual functions handle their own error conditions

################################################################################
# Third-Party File Exclusion Module
# Purpose: Centralized management of third-party and build artifact exclusions
# Part of: Tests & Documentation Workflow Automation v2.3.0
#
# This module implements the functional requirements from:
# CONSOLIDATED_FUNCTIONAL_REQUIREMENTS.md >> Cross-Cutting Concerns >> Third-Party File Exclusion
#
# All workflow steps MUST exclude third-party dependencies and build artifacts
# from analysis, as they are outside the project development scope.
################################################################################

# ==============================================================================
# STANDARD EXCLUSION PATTERNS
# ==============================================================================

# Get standard exclusion patterns for all languages
# Returns: Array of directory patterns to exclude
# Usage: get_standard_exclusion_patterns
get_standard_exclusion_patterns() {
    cat << 'EOF'
node_modules
venv
.venv
env
__pycache__
vendor
target
build
dist
.git
coverage
.pytest_cache
.egg-info
.next
out
.gradle
.bundle
tmp
log
cmake-build-debug
.deps
obj
pkg
bin
EOF
}

# Get exclusion patterns as array
# Usage: exclusion_patterns=($(get_exclusion_array))
get_exclusion_array() {
    get_standard_exclusion_patterns
}

# Get exclusion patterns for find command
# Usage: find . $(get_find_exclusions) -name "*.sh"
get_find_exclusions() {
    local patterns=($(get_standard_exclusion_patterns))
    local args=()
    
    for pattern in "${patterns[@]}"; do
        args+=("! -path \"*/${pattern}/*\"")
    done
    
    echo "${args[@]}"
}

# ==============================================================================
# LANGUAGE-SPECIFIC EXCLUSIONS
# ==============================================================================

# Get exclusion patterns for specific language/tech stack
# Usage: get_language_exclusions "javascript"
get_language_exclusions() {
    local language="${1:-}"
    
    case "$language" in
        javascript|node|nodejs|typescript)
            echo "node_modules dist build coverage .next out"
            ;;
        python)
            echo "venv .venv env __pycache__ .pytest_cache *.egg-info dist build"
            ;;
        go|golang)
            echo "vendor bin pkg"
            ;;
        java)
            echo "target .gradle out build"
            ;;
        ruby)
            echo "vendor .bundle tmp log"
            ;;
        rust)
            echo "target"
            ;;
        php)
            echo "vendor"
            ;;
        cpp|c)
            echo "build cmake-build-debug .deps obj"
            ;;
        *)
            # Return common patterns for unknown languages
            get_standard_exclusion_patterns | tr '\n' ' '
            ;;
    esac
}

# ==============================================================================
# TECH STACK INTEGRATION
# ==============================================================================

# Get exclusion patterns from tech stack configuration
# Requires: tech_stack.sh module loaded
# Usage: get_tech_stack_exclusions
get_tech_stack_exclusions() {
    local exclusions=""
    
    # Try to get from tech stack config if available
    if declare -f get_tech_stack_value &>/dev/null; then
        exclusions=$(get_tech_stack_value "exclude_dirs" 2>/dev/null || echo "")
    fi
    
    # If no tech stack config, use standard patterns
    if [[ -z "$exclusions" ]]; then
        exclusions=$(get_standard_exclusion_patterns | tr '\n' ' ')
    fi
    
    echo "$exclusions"
}

# ==============================================================================
# OPTIMIZED FILE DISCOVERY WITH EXCLUSIONS
# ==============================================================================

# Fast find with standard exclusions applied
# Usage: find_with_exclusions <directory> <pattern> [max_depth]
# Example: find_with_exclusions "." "*.js" 5
find_with_exclusions() {
    local dir="${1:-.}"
    local pattern="${2:-*}"
    local max_depth="${3:-5}"
    
    # Get exclusion patterns
    local excludes=($(get_standard_exclusion_patterns))
    
    # Build exclusion arguments
    local exclude_args=()
    for exclude in "${excludes[@]}"; do
        exclude_args+=(-path "*/$exclude" -prune -o)
    done
    
    # Execute find with exclusions
    find "$dir" -maxdepth "$max_depth" \
        "${exclude_args[@]}" \
        -type f -name "$pattern" -print 2>/dev/null
}

# Grep with standard exclusions applied
# Usage: grep_with_exclusions <pattern> <directory> [file_pattern]
# Example: grep_with_exclusions "function" "." "*.sh"
grep_with_exclusions() {
    local pattern="$1"
    local dir="${2:-.}"
    local file_pattern="${3:-*}"
    
    # Get exclusion patterns
    local excludes=($(get_standard_exclusion_patterns))
    
    # Build exclusion arguments
    local exclude_args=()
    for exclude in "${excludes[@]}"; do
        exclude_args+=(--exclude-dir="$exclude")
    done
    
    # Use ripgrep if available (faster)
    if command -v rg &>/dev/null; then
        rg --no-heading --line-number "$pattern" \
            --glob "$file_pattern" \
            "${exclude_args[@]}" \
            "$dir" 2>/dev/null || true
    else
        # Fallback to GNU grep
        grep -r -n \
            --include="$file_pattern" \
            "${exclude_args[@]}" \
            "$pattern" \
            "$dir" 2>/dev/null || true
    fi
}

# Count files excluding third-party directories
# Usage: count_project_files [directory] [pattern]
count_project_files() {
    local dir="${1:-.}"
    local pattern="${2:-*}"
    
    find_with_exclusions "$dir" "$pattern" 10 | wc -l
}

# ==============================================================================
# VALIDATION HELPERS
# ==============================================================================

# Check if path is in excluded directory
# Usage: is_excluded_path "/path/to/file"
# Returns: 0 if excluded, 1 if not excluded
is_excluded_path() {
    local path="$1"
    local excludes=($(get_standard_exclusion_patterns))
    
    for exclude in "${excludes[@]}"; do
        if [[ "$path" == *"/${exclude}/"* ]] || [[ "$path" == *"/${exclude}" ]]; then
            return 0  # Path is excluded
        fi
    done
    
    return 1  # Path is not excluded
}

# Filter file list to remove excluded paths
# Usage: filter_excluded_files < file_list.txt
# Or: echo "/path/file" | filter_excluded_files
filter_excluded_files() {
    local line
    while IFS= read -r line; do
        if ! is_excluded_path "$line"; then
            echo "$line"
        fi
    done
}

# ==============================================================================
# REPORTING HELPERS
# ==============================================================================

# Get human-readable exclusion list for logging
# Usage: get_exclusion_summary
get_exclusion_summary() {
    echo "Excluding third-party directories: node_modules, venv, vendor, target, build, dist, and others"
}

# Log exclusion information
# Usage: log_exclusions [log_file]
log_exclusions() {
    local log_file="${1:-}"
    local message="[Third-Party Exclusion] $(get_exclusion_summary)"
    
    if [[ -n "$log_file" ]]; then
        echo "$message" >> "$log_file"
    else
        echo "$message"
    fi
}

# Count excluded directories in current project
# Usage: count_excluded_dirs [directory]
count_excluded_dirs() {
    local dir="${1:-.}"
    local excludes=($(get_standard_exclusion_patterns))
    local count=0
    
    for exclude in "${excludes[@]}"; do
        if [[ -d "${dir}/${exclude}" ]]; then
            ((count++)) || true
        fi
    done
    
    echo "$count"
}

# ==============================================================================
# AI PROMPT INTEGRATION
# ==============================================================================

# Get exclusion context for AI prompts
# Usage: get_ai_exclusion_context
get_ai_exclusion_context() {
    local excluded_count=$(count_excluded_dirs ".")
    
    if [[ $excluded_count -gt 0 ]]; then
        echo "Note: Analysis excludes $excluded_count third-party dependency directories (node_modules, venv, vendor, build artifacts, etc.) as they are maintained externally."
    else
        echo "Note: Analysis excludes standard third-party directories if present (node_modules, venv, vendor, build artifacts, etc.)."
    fi
}

# ==============================================================================
# COMPATIBILITY WITH EXISTING CODE
# ==============================================================================

# Wrapper for backward compatibility with fast_find
# Usage: fast_find_safe <directory> <pattern> [max_depth] [additional_excludes...]
fast_find_safe() {
    local dir="$1"
    local pattern="$2"
    local max_depth="${3:-5}"
    shift 3
    
    # Combine standard exclusions with additional ones
    local standard_excludes=($(get_standard_exclusion_patterns))
    local additional_excludes=("$@")
    local all_excludes=("${standard_excludes[@]}" "${additional_excludes[@]}")
    
    # Build exclusion arguments
    local exclude_args=()
    for exclude in "${all_excludes[@]}"; do
        exclude_args+=(-path "*/$exclude" -prune -o)
    done
    
    # Execute find
    find "$dir" -maxdepth "$max_depth" \
        "${exclude_args[@]}" \
        -type f -name "$pattern" -print 2>/dev/null
}

# ==============================================================================
# EXPORT FUNCTIONS
# ==============================================================================

# Export all functions for use in other modules
export -f get_standard_exclusion_patterns
export -f get_exclusion_array
export -f get_find_exclusions
export -f get_language_exclusions
export -f get_tech_stack_exclusions
export -f find_with_exclusions
export -f grep_with_exclusions
export -f count_project_files
export -f is_excluded_path
export -f filter_excluded_files
export -f get_exclusion_summary
export -f log_exclusions
export -f count_excluded_dirs
export -f get_ai_exclusion_context
export -f fast_find_safe

################################################################################
# END OF MODULE
################################################################################
