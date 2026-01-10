#!/bin/bash
set -euo pipefail

################################################################################
# Auto-Commit Module
# Version: 1.0.0
# Purpose: Automatically commit workflow artifacts and changes
# Part of: Tests & Documentation Workflow Automation v2.6.0
# Created: December 24, 2025
################################################################################

# ==============================================================================
# CONDITIONAL STAGING FUNCTIONS (v2.6.0)
# ==============================================================================

# Check if tests passed based on workflow status
# Returns: 0 if tests passed, 1 if failed or not run
tests_passed() {
    local test_status="${WORKFLOW_STATUS[step7]:-NOT_EXECUTED}"
    
    # Tests passed if status is ✅
    [[ "$test_status" == "✅" ]]
}

# Check if documentation files were modified
# Returns: 0 if docs modified, 1 otherwise
docs_modified() {
    local modified_files=$(git status --porcelain 2>/dev/null | awk '{print $2}')
    
    # Check if any modified file is a doc file
    while IFS= read -r file; do
        if [[ "$file" =~ ^docs/ ]] || [[ "$file" =~ ^README\.md$ ]] || [[ "$file" =~ \.md$ ]]; then
            return 0
        fi
    done <<< "$modified_files"
    
    return 1
}

# Stage only documentation files
# Usage: stage_docs_only
# Returns: Number of files staged
stage_docs_only() {
    local files_staged=0
    local modified_files=$(git status --porcelain 2>/dev/null | awk '{print $2}')
    
    if [[ -z "$modified_files" ]]; then
        return 0
    fi
    
    # Stage only documentation files
    while IFS= read -r file; do
        if [[ -n "$file" ]] && ([[ "$file" =~ ^docs/ ]] || [[ "$file" =~ ^README\.md$ ]] || [[ "$file" =~ \.md$ ]]); then
            if git add "$file" 2>/dev/null; then
                ((files_staged++)) || true
            fi
        fi
    done <<< "$modified_files"
    
    echo "$files_staged"
}

# Conditionally stage documentation files after tests pass
# Implements: auto_stage_docs condition from YAML spec
# Usage: conditional_stage_docs
# Returns: 0 on success, 1 on skip
conditional_stage_docs() {
    # Check conditions: docs_modified && tests_pass
    if ! docs_modified; then
        print_info "Conditional staging skipped: No documentation files modified"
        return 1
    fi
    
    if ! tests_passed; then
        print_warning "Conditional staging skipped: Tests did not pass"
        print_info "Documentation files will not be staged automatically"
        return 1
    fi
    
    # Both conditions met - stage docs
    print_info "Conditional staging: Tests passed and docs modified"
    print_info "Staging documentation files automatically..."
    
    local files_staged=$(stage_docs_only)
    
    if [[ $files_staged -gt 0 ]]; then
        print_success "Staged $files_staged documentation file(s) ✅"
        return 0
    else
        print_info "No documentation files to stage"
        return 1
    fi
}

# ==============================================================================
# AUTO-COMMIT CONFIGURATION
# ==============================================================================

# Patterns for workflow artifacts to commit
declare -a AUTO_COMMIT_PATTERNS=(
    "docs/**/*.md"
    "README.md"
    "CONTRIBUTING.md"
    "tests/**/*.sh"
    "src/**/*.sh"
    ".workflow-config.yaml"
)

# Patterns to exclude from auto-commit (sensitive/generated files)
declare -a AUTO_COMMIT_EXCLUDES=(
    "*.log"
    "*.tmp"
    ".ai_workflow/backlog/**"
    ".ai_workflow/logs/**"
    "node_modules/**"
    "coverage/**"
)

# ==============================================================================
# AUTO-COMMIT FUNCTIONS
# ==============================================================================

# Check if there are changes to commit
has_changes_to_commit() {
    ! git diff --quiet HEAD 2>/dev/null || ! git diff --cached --quiet 2>/dev/null
}

# Get list of modified files
get_modified_files() {
    git status --porcelain 2>/dev/null | grep -E "^(M| M|A| A|MM)" | awk '{print $2}'
}

# Check if file matches artifact patterns
is_workflow_artifact() {
    local file="$1"
    
    # Check if file matches any artifact pattern
    for pattern in "${AUTO_COMMIT_PATTERNS[@]}"; do
        # Convert glob to regex
        local regex="${pattern//\*\*/.*}"
        regex="${regex//\*/[^/]*}"
        
        if [[ "$file" =~ ^${regex}$ ]]; then
            # Check it doesn't match exclude patterns
            for exclude in "${AUTO_COMMIT_EXCLUDES[@]}"; do
                local exclude_regex="${exclude//\*\*/.*}"
                exclude_regex="${exclude_regex//\*/[^/]*}"
                
                if [[ "$file" =~ ^${exclude_regex}$ ]]; then
                    return 1  # Excluded
                fi
            done
            return 0  # Matches and not excluded
        fi
    done
    
    return 1  # Doesn't match any pattern
}

# Generate commit message based on changes
generate_commit_message() {
    local change_type="${1:-general}"
    local files_changed="${2:-0}"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$change_type" in
        docs)
            echo "docs: update documentation and fix issues

- Updated documentation files
- Fixed broken references
- Improved clarity and examples

Files modified: ${files_changed}
Generated: ${timestamp}
Workflow: AI Workflow Automation v2.6.0"
            ;;
        tests)
            echo "test: update test suite

- Updated test files
- Added new test cases
- Fixed test issues

Files modified: ${files_changed}
Generated: ${timestamp}
Workflow: AI Workflow Automation v2.6.0"
            ;;
        feature)
            echo "feat: implement workflow changes

- Updated implementation files
- Added new functionality
- Improved workflow automation

Files modified: ${files_changed}
Generated: ${timestamp}
Workflow: AI Workflow Automation v2.6.0"
            ;;
        *)
            echo "chore: workflow automation updates

- Updated workflow artifacts
- Generated by AI Workflow Automation

Files modified: ${files_changed}
Generated: ${timestamp}
Workflow: AI Workflow Automation v2.6.0"
            ;;
    esac
}

# Detect change type from modified files
detect_change_type() {
    local files="$1"
    local docs_count=0
    local test_count=0
    local code_count=0
    
    while IFS= read -r file; do
        if [[ "$file" =~ ^docs/ ]] || [[ "$file" =~ \.md$ ]]; then
            ((docs_count++)) || true
        elif [[ "$file" =~ ^tests/ ]] || [[ "$file" =~ test.*\.sh$ ]]; then
            ((test_count++)) || true
        else
            ((code_count++)) || true
        fi
    done <<< "$files"
    
    # Determine primary change type
    if [[ $docs_count -gt 0 ]] && [[ $test_count -eq 0 ]] && [[ $code_count -eq 0 ]]; then
        echo "docs"
    elif [[ $test_count -gt 0 ]] && [[ $docs_count -eq 0 ]] && [[ $code_count -eq 0 ]]; then
        echo "tests"
    elif [[ $code_count -gt 0 ]]; then
        echo "feature"
    else
        echo "general"
    fi
}

# Stage workflow artifacts
stage_workflow_artifacts() {
    local files_staged=0
    
    # Get all modified files
    local modified_files=$(get_modified_files)
    
    if [[ -z "$modified_files" ]]; then
        return 0
    fi
    
    # Stage only workflow artifacts
    while IFS= read -r file; do
        if [[ -n "$file" ]] && is_workflow_artifact "$file"; then
            git add "$file" 2>/dev/null || true
            ((files_staged++)) || true
        fi
    done <<< "$modified_files"
    
    echo "$files_staged"
}

# Execute auto-commit
execute_auto_commit() {
    local dry_run="${DRY_RUN:-false}"
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "[DRY RUN] Would auto-commit workflow artifacts"
        return 0
    fi
    
    # Check if there are changes
    if ! has_changes_to_commit; then
        print_info "No changes to commit"
        return 0
    fi
    
    print_info "Auto-commit: Staging workflow artifacts..."
    
    # Stage workflow artifacts
    local files_staged=$(stage_workflow_artifacts)
    
    if [[ $files_staged -eq 0 ]]; then
        print_info "No workflow artifacts to commit"
        return 0
    fi
    
    print_info "Staged ${files_staged} file(s)"
    
    # Get staged files for change detection
    local staged_files=$(git diff --cached --name-only)
    local change_type=$(detect_change_type "$staged_files")
    
    # Generate commit message
    local commit_msg=$(generate_commit_message "$change_type" "$files_staged")
    
    # Show what will be committed
    print_info "Changes to be committed:"
    git diff --cached --stat | head -20
    
    # Commit
    print_info "Creating commit..."
    if git commit -m "$commit_msg" --quiet; then
        print_success "✅ Auto-commit successful"
        print_info "Commit message:"
        echo "$commit_msg" | head -5
        return 0
    else
        print_warning "Auto-commit failed - manual commit may be needed"
        return 1
    fi
}

# Show auto-commit status
show_auto_commit_status() {
    if [[ "${AUTO_COMMIT:-false}" == "true" ]]; then
        print_info "🤖 Auto-commit: ENABLED - Artifacts will be committed automatically"
    else
        print_info "Auto-commit: disabled (use --auto-commit to enable)"
    fi
}

# Export functions
export -f has_changes_to_commit
export -f get_modified_files
export -f is_workflow_artifact
export -f generate_commit_message
export -f detect_change_type
export -f stage_workflow_artifacts
export -f execute_auto_commit
export -f show_auto_commit_status
