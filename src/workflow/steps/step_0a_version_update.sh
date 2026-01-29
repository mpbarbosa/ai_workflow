#!/bin/bash
################################################################################
# Step 0a: Semantic Version Update (Pre-Processing)
# Purpose: Update semantic version numbers BEFORE documentation analysis
# Part of: Tests & Documentation Workflow Automation v3.0.0
# Version: 1.0.0
# Position: Runs between Step 0 (Pre-Analysis) and Step 1 (Documentation)
# Rationale: Version fixes must happen before docs are analyzed to avoid stale refs
################################################################################

# Only set strict error handling if not in test mode
if [[ "${BASH_SOURCE[0]}" != *"test"* ]] && [[ -z "${TEST_MODE:-}" ]]; then
    set -euo pipefail
fi

# Module version information
readonly STEP0A_VERSION="1.0.0"
readonly STEP0A_VERSION_MAJOR=1
readonly STEP0A_VERSION_MINOR=0
readonly STEP0A_VERSION_PATCH=0

# Determine script directory and project root
STEP0A_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${STEP0A_DIR}/../lib"

# Source required dependencies if not already loaded
if ! type -t print_info &>/dev/null; then
    # shellcheck source=../lib/colors.sh
    source "${WORKFLOW_LIB_DIR}/colors.sh" 2>/dev/null || true
    # shellcheck source=../lib/utils.sh
    source "${WORKFLOW_LIB_DIR}/utils.sh" 2>/dev/null || true
fi

# Define fallback functions if still not available (for standalone usage)
if ! type -t print_info &>/dev/null; then
    print_info() { echo "ℹ️  $1"; }
    print_success() { echo "✅ $1"; }
    print_warning() { echo "⚠️  WARNING: $1"; }
    print_error() { echo "❌ ERROR: $1" >&2; }
fi

# ==============================================================================
# STEP RELEVANCE CHECK
# ==============================================================================

# Check if this step should run based on project configuration
# Returns: 0 if should run, 1 if should skip
should_run_version_update_step() {
    local project_kind="${PROJECT_KIND:-unknown}"
    local step_relevance=""
    
    # Check step relevance configuration
    if command -v get_step_relevance &>/dev/null; then
        step_relevance=$(get_step_relevance "$project_kind" "step_0a_version_update" 2>/dev/null || echo "optional")
    else
        step_relevance="optional"
    fi
    
    print_info "Step 0a relevance for '$project_kind': $step_relevance"
    
    # Skip if explicitly marked as skip
    if [[ "$step_relevance" == "skip" ]]; then
        print_info "Step 0a skipped (marked as skip for this project kind)"
        return 1
    fi
    
    # Check for versioned files in the project
    local target_dir="${TARGET_PROJECT_ROOT:-${PROJECT_ROOT}}"
    
    # Look for common version indicators
    if [[ -f "${target_dir}/package.json" ]] || \
       [[ -f "${target_dir}/setup.py" ]] || \
       [[ -f "${target_dir}/pyproject.toml" ]] || \
       [[ -f "${target_dir}/Cargo.toml" ]] || \
       [[ -f "${target_dir}/pom.xml" ]] || \
       grep -qrE '(version|VERSION|Version)["\s:=]+[0-9]+\.[0-9]+\.[0-9]+' "${target_dir}" 2>/dev/null; then
        print_success "Version Update will run - versioned files detected"
        return 0
    else
        print_info "Version Update skipped - no versioned files detected"
        return 1
    fi
}

# ==============================================================================
# VERSION DETECTION AND UPDATE
# ==============================================================================

# Detect version patterns in file
# Usage: detect_version_pattern <file_path>
# Returns: version pattern type (semver, date, custom) or "none"
detect_version_pattern() {
    local file="$1"
    
    # Check for semver pattern (X.Y.Z)
    if grep -qE '(version|VERSION|Version)["\s:=]+[0-9]+\.[0-9]+\.[0-9]+' "$file" 2>/dev/null; then
        echo "semver"
        return 0
    fi
    
    # Check for date-based version (YYYY-MM-DD or YYYYMMDD)
    if grep -qE '(version|VERSION|Version)["\s:=]+[0-9]{4}-[0-9]{2}-[0-9]{2}' "$file" 2>/dev/null; then
        echo "date"
        return 0
    fi
    
    # Check for version in header comments
    if grep -qE '^#.*[Vv]ersion:?\s+[0-9]+\.[0-9]+\.[0-9]+' "$file" 2>/dev/null; then
        echo "semver_comment"
        return 0
    fi
    
    echo "none"
}

# Extract current version from file
# Usage: extract_current_version <file_path> <pattern_type>
# Returns: current version string or empty
extract_current_version() {
    local file="$1"
    local pattern_type="$2"
    
    case "$pattern_type" in
        semver)
            grep -oE '[0-9]+\.[0-9]+\.[0-9]+' "$file" 2>/dev/null | head -1
            ;;
        date)
            grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$file" 2>/dev/null | head -1
            ;;
        semver_comment)
            grep -oE '^#.*[Vv]ersion:?\s+[0-9]+\.[0-9]+\.[0-9]+' "$file" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
            ;;
        *)
            echo ""
            ;;
    esac
}

# Increment semantic version
# Usage: increment_version <version> <bump_type>
# bump_type: major, minor, patch (default: patch)
# Returns: new version string
increment_version() {
    local version="$1"
    local bump_type="${2:-patch}"
    
    # Parse version components
    local major minor patch
    IFS='.' read -r major minor patch <<< "$version"
    
    case "$bump_type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch|*)
            patch=$((patch + 1))
            ;;
    esac
    
    echo "${major}.${minor}.${patch}"
}

# Determine bump type based on git changes
# Usage: determine_bump_type
# Returns: major, minor, or patch
determine_bump_type() {
    # Use cached git state
    local code_modified=$(get_git_code_modified 2>/dev/null || echo "0")
    local tests_modified=$(get_git_tests_modified 2>/dev/null || echo "0")
    local docs_modified=$(get_git_docs_modified 2>/dev/null || echo "0")
    
    # Major: Breaking changes (check commit messages for BREAKING)
    if git log --format=%B -n 10 2>/dev/null | grep -qi "BREAKING CHANGE"; then
        echo "major"
        return 0
    fi
    
    # Minor: New features (code + tests modified)
    if [[ $code_modified -gt 0 ]] && [[ $tests_modified -gt 0 ]]; then
        echo "minor"
        return 0
    fi
    
    # Patch: Bug fixes, docs, or small changes
    echo "patch"
}

# Update version in file
# Usage: update_version_in_file <file_path> <old_version> <new_version> <pattern_type>
# Returns: 0 for success, 1 for failure
update_version_in_file() {
    local file="$1"
    local old_version="$2"
    local new_version="$3"
    local pattern_type="$4"
    
    # Create backup
    cp "$file" "${file}.version_backup"
    
    case "$pattern_type" in
        semver)
            # Update version in common patterns
            sed -i "s/\(version\|VERSION\|Version\)[\"' :=]*${old_version}/\1\"${new_version}/g" "$file"
            ;;
        semver_comment)
            # Update version in header comments
            sed -i "s/^\(#.*[Vv]ersion:*\s*\)${old_version}/\1${new_version}/" "$file"
            ;;
        date)
            # Update date-based version
            local new_date
            new_date=$(date +%Y-%m-%d)
            sed -i "s/${old_version}/${new_date}/g" "$file"
            ;;
    esac
    
    # Verify change was made
    if ! grep -q "$new_version" "$file" 2>/dev/null; then
        # Restore backup on failure
        mv "${file}.version_backup" "$file"
        return 1
    fi
    
    # Remove backup on success
    rm -f "${file}.version_backup"
    return 0
}

# ==============================================================================
# MAIN STEP FUNCTION
# ==============================================================================

# Main step function - updates versions in modified files
# Returns: 0 for success, 1 for failure
step0a_version_update() {
    print_step "15" "Semantic Version Update"
    
    # Check if this step should run
    if ! should_run_version_update_step; then
        print_info "Step 0a: Version Update skipped (no versioned files)"
        
        # Create minimal backlog entry
        local backlog_file="${BACKLOG_RUN_DIR}/step_0a_version_update.md"
        cat > "$backlog_file" << EOF
# Step 0a: Semantic Version Update - SKIPPED

**Status**: ⏭️ Skipped
**Reason**: No versioned files detected in this project
**Date**: $(date '+%Y-%m-%d %H:%M:%S')

## Summary

This step was skipped because the project does not contain files with version patterns that require updating.

Project types that skip this step:
- Projects without semantic versioning
- Documentation-only projects
- Projects without version metadata

Project types that run this step:
- Node.js packages (package.json)
- Python packages (setup.py, pyproject.toml)
- Rust packages (Cargo.toml)
- Java projects (pom.xml)
- Shell scripts with version headers

## Recommendation

If your project does have version numbers that were not detected, please:
1. Check that version patterns follow standard formats (X.Y.Z)
2. Ensure version metadata is in standard locations
3. Manually update versions if needed

EOF
        
        save_step_issues "15" "Version_Update" "$(cat "$backlog_file")"
        save_step_summary "15" "Version_Update" "Skipped - no versioned files detected" "⏭️"
        update_workflow_status "step0a" "⏭️"
        print_success "Step 0a completed (skipped - no versioned files)"
        return 0
    fi
    
    cd "$PROJECT_ROOT" || return 1
    
    # Initialize tracking
    local files_updated=0
    local files_skipped=0
    local files_failed=0
    local update_report
    update_report=$(mktemp)
    TEMP_FILES+=("$update_report")
    
    echo "# Step 0a: Semantic Version Update" > "$update_report"
    echo "" >> "$update_report"
    echo "**Status:** In Progress" >> "$update_report"
    echo "" >> "$update_report"
    
    # Dry-run preview
    if [[ "${DRY_RUN:-false}" == true ]]; then
        print_info "[DRY RUN] Version update preview:"
        print_info "  - Would detect version patterns in modified files"
        print_info "  - Would determine appropriate version bump"
        print_info "  - Would update versions accordingly"
        
        echo "**Status:** ✅ DRY RUN MODE" >> "$update_report"
        echo "" >> "$update_report"
        echo "Dry run mode enabled. No version updates performed." >> "$update_report"
        
        save_step_issues "15" "Version_Update" "$(cat "$update_report")"
        save_step_summary "15" "Version_Update" "Dry run mode - no version updates performed." "✅"
        update_workflow_status "step0a" "✅"
        return 0
    fi
    
    print_info "Analyzing modified files for version updates..."
    
    # Get modified files (exclude workflow artifacts)
    local modified_files
    modified_files=$(get_git_modified_files 2>/dev/null || git diff --name-only HEAD 2>/dev/null || echo "")
    
    if [[ -z "$modified_files" ]]; then
        print_info "No modified files to update"
        echo "**Status:** ✅ No Changes" >> "$update_report"
        echo "" >> "$update_report"
        echo "No modified files require version updates." >> "$update_report"
        
        save_step_issues "15" "Version_Update" "$(cat "$update_report")"
        save_step_summary "15" "Version_Update" "No modified files require version updates." "✅"
        update_workflow_status "step0a" "✅"
        return 0
    fi
    
    # Determine bump type
    local bump_type
    bump_type=$(determine_bump_type)
    print_info "Detected change level: $bump_type bump"
    echo "## Version Bump Type: $bump_type" >> "$update_report"
    echo "" >> "$update_report"
    
    # Process each modified file
    echo "## Files Processed" >> "$update_report"
    echo "" >> "$update_report"
    
    while IFS= read -r file; do
        # Skip if file doesn't exist or is in workflow artifacts
        [[ ! -f "$file" ]] && continue
        [[ "$file" =~ ^(src/workflow/backlog|src/workflow/logs|src/workflow/summaries|src/workflow/metrics) ]] && continue
        
        print_info "Checking: $file"
        
        # Detect version pattern
        local pattern_type
        pattern_type=$(detect_version_pattern "$file")
        
        if [[ "$pattern_type" == "none" ]]; then
            print_info "  ↳ No version pattern detected, skipping"
            ((files_skipped++)) || true
            echo "- \`$file\`: No version pattern (skipped)" >> "$update_report"
            continue
        fi
        
        print_info "  ↳ Pattern detected: $pattern_type"
        
        # Extract current version
        local current_version
        current_version=$(extract_current_version "$file" "$pattern_type")
        
        if [[ -z "$current_version" ]]; then
            print_warning "  ↳ Could not extract version, skipping"
            ((files_skipped++)) || true
            echo "- \`$file\`: Pattern detected but version extraction failed (skipped)" >> "$update_report"
            continue
        fi
        
        print_info "  ↳ Current version: $current_version"
        
        # Calculate new version
        local new_version
        if [[ "$pattern_type" == "date" ]]; then
            new_version=$(date +%Y-%m-%d)
        else
            new_version=$(increment_version "$current_version" "$bump_type")
        fi
        
        print_info "  ↳ New version: $new_version"
        
        # Skip if version is already current
        if [[ "$current_version" == "$new_version" ]]; then
            print_info "  ↳ Version already current, skipping"
            ((files_skipped++)) || true
            echo "- \`$file\`: Version already current ($current_version) (skipped)" >> "$update_report"
            continue
        fi
        
        # Update version
        if update_version_in_file "$file" "$current_version" "$new_version" "$pattern_type"; then
            print_success "  ↳ Updated: $current_version → $new_version"
            ((files_updated++)) || true
            echo "- \`$file\`: Updated $current_version → $new_version ✅" >> "$update_report"
        else
            print_error "  ↳ Failed to update version"
            ((files_failed++)) || true
            echo "- \`$file\`: Update failed ❌" >> "$update_report"
        fi
        
    done <<< "$modified_files"
    
    # Summary
    echo "" >> "$update_report"
    echo "## Summary" >> "$update_report"
    echo "" >> "$update_report"
    echo "- Files updated: $files_updated" >> "$update_report"
    echo "- Files skipped: $files_skipped" >> "$update_report"
    echo "- Files failed: $files_failed" >> "$update_report"
    echo "" >> "$update_report"
    
    local status_icon="✅"
    local summary_msg="Updated $files_updated files"
    
    if [[ $files_failed -gt 0 ]]; then
        status_icon="⚠️"
        summary_msg="Updated $files_updated files, $files_failed failed"
        print_warning "Version update completed with failures: $files_failed files"
    elif [[ $files_updated -eq 0 ]]; then
        print_info "No version updates needed"
        summary_msg="No version updates needed"
    else
        print_success "Version update completed: $files_updated files updated"
    fi
    
    echo "**Status:** $status_icon Complete" >> "$update_report"
    
    # Save results
    save_step_issues "15" "Version_Update" "$(cat "$update_report")"
    save_step_summary "15" "Version_Update" "$summary_msg" "$status_icon"
    
    update_workflow_status "step0a" "$status_icon"
    
    # Return success even if some files failed (partial success)
    return 0
}

# Export all functions for testing and workflow integration
export -f step0a_version_update
export -f should_run_version_update_step
export -f detect_version_pattern
export -f extract_current_version
export -f increment_version
export -f determine_bump_type
export -f update_version_in_file

# Prevent direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should be sourced by the main workflow, not executed directly."
    exit 1
fi

################################################################################
# Step 0a: Semantic Version Update - Complete
################################################################################
