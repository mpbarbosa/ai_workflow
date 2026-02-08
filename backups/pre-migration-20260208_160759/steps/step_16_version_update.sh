#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 16: AI-Powered Semantic Version Update
# Purpose: Update semantic versions in modified files and project metadata
# Part of: Tests & Documentation Workflow Automation v3.0.7
# Version: 1.0.0
# Position: Runs after all analysis (10,12,13,14), before Git Finalization (11)
# Dependencies: Steps 10, 12, 13, 14
################################################################################

# Module version information
readonly STEP16_VERSION="1.0.0"
readonly STEP16_VERSION_MAJOR=1
readonly STEP16_VERSION_MINOR=0
readonly STEP16_VERSION_PATCH=0

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${SCRIPT_DIR}/../lib"

source "${WORKFLOW_LIB_DIR}/colors.sh"
source "${WORKFLOW_LIB_DIR}/utils.sh"
source "${WORKFLOW_LIB_DIR}/ai_helpers.sh"
source "${WORKFLOW_LIB_DIR}/git_cache.sh"
source "${WORKFLOW_LIB_DIR}/third_party_exclusion.sh"
source "${WORKFLOW_LIB_DIR}/version_bump.sh"

# Constants
readonly SEMVER_PATTERN='[0-9]+\.[0-9]+\.[0-9]+'
readonly VERSION_PATTERN_REGEX='(version|VERSION|Version|@version)["'\''\s:=]*([0-9]+\.[0-9]+\.[0-9]+)'

################################################################################
# Helper Functions
################################################################################

# Extract version number from string
# Args: $1 - string containing version
# Returns: version string (X.Y.Z) or empty if not found
extract_version() {
    local input="$1"
    echo "$input" | grep -oE "$SEMVER_PATTERN" | head -1
}

# Detect version patterns in a file
# Args: $1 - file path
# Returns: line_number:matched_line pairs
detect_version_patterns() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    [[ ! -r "$file" ]] && return 1
    
    # Search for semver patterns
    grep -nE "$VERSION_PATTERN_REGEX" "$file" 2>/dev/null || true
}

# Increment version based on bump type
# Args: $1 - current version (X.Y.Z)
#       $2 - bump type (major|minor|patch)
# Returns: new version string
increment_version() {
    local version="$1"
    local bump_type="$2"
    
    local major minor patch
    IFS='.' read -r major minor patch <<< "$version"
    
    case "$bump_type" in
        major)
            echo "$((major + 1)).0.0"
            ;;
        minor)
            echo "${major}.$((minor + 1)).0"
            ;;
        patch)
            echo "${major}.${minor}.$((patch + 1))"
            ;;
        *)
            echo "$version"
            ;;
    esac
}

# Determine bump type using heuristics (fallback when AI unavailable)
# Returns: major|minor|patch
determine_heuristic_bump_type() {
    local modified_count="${1:-0}"
    local added_count="${2:-0}"
    local deleted_count="${3:-0}"
    
    # Get change statistics from git
    local stats
    stats=$(git diff --cached --shortstat 2>/dev/null || git diff --shortstat 2>/dev/null || echo "")
    
    local insertions deletions
    insertions=$(echo "$stats" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
    deletions=$(echo "$stats" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")
    
    # Heuristic rules
    # Major: Large deletions or many files modified
    if [[ $deletions -gt 500 ]] || [[ $modified_count -gt 20 ]]; then
        echo "major"
        return 0
    fi
    
    # Minor: New files added or significant additions
    if [[ $added_count -gt 0 ]] || [[ $insertions -gt 100 ]]; then
        echo "minor"
        return 0
    fi
    
    # Patch: Small changes, documentation, bug fixes
    echo "patch"
}

# Determine bump type using AI analysis
# Returns: major|minor|patch with reasoning logged
determine_ai_bump_type() {
    local output_file="${BACKLOG_RUN_DIR}/step_16_ai_bump_analysis.md"
    
    # Build context from workflow artifacts
    local context=""
    context+="# Version Bump Analysis Context\n\n"
    
    # Add git statistics
    local git_stats
    git_stats=$(git diff --cached --shortstat 2>/dev/null || git diff --shortstat 2>/dev/null || echo "No changes")
    context+="## Git Changes\n${git_stats}\n\n"
    
    # Add changed files
    context+="## Modified Files\n"
    local files
    files=$(get_git_diff_files_output | head -20)
    context+="${files}\n\n"
    
    # Add Step 0 pre-analysis if available
    if [[ -f "${BACKLOG_RUN_DIR}/step_00_pre_analysis.md" ]]; then
        context+="## Pre-Analysis Results\n"
        context+="$(head -50 "${BACKLOG_RUN_DIR}/step_00_pre_analysis.md")\n\n"
    fi
    
    # Build AI prompt
    local prompt="You are a Version Manager and Semantic Versioning Expert. Analyze the changes and determine the appropriate version bump type.

${context}

Based on this context, determine the semantic version bump type:
- **MAJOR (X.0.0)**: Breaking changes, API modifications, removed features
- **MINOR (X.Y.0)**: New features, enhancements, additive changes  
- **PATCH (X.Y.Z)**: Bug fixes, documentation, refactoring, tests

Output format:
Bump Type: [major|minor|patch]
Reasoning: [2-3 sentence explanation]
Confidence: [high|medium|low]"
    
    # Call AI with version_manager persona
    if ! execute_copilot_prompt "$prompt" "$output_file" "step_16_version_update" "version_manager"; then
        return 1
    fi
    
    # Parse AI response
    local bump_type
    bump_type=$(grep -i "^Bump Type:" "$output_file" | grep -oE "(major|minor|patch)" | head -1 || echo "")
    
    if [[ -z "$bump_type" ]]; then
        # Try alternative parsing
        bump_type=$(grep -iE "recommend.*(major|minor|patch)" "$output_file" | grep -oE "(major|minor|patch)" | head -1 || echo "")
    fi
    
    if [[ -n "$bump_type" ]]; then
        echo "$bump_type"
        return 0
    fi
    
    return 1
}

# Update version in a specific file
# Args: $1 - file path
#       $2 - old version
#       $3 - new version
# Returns: 0 on success, 1 on failure
update_version_in_file() {
    local file="$1"
    local old_version="$2"
    local new_version="$3"
    
    [[ ! -f "$file" ]] && return 1
    [[ ! -w "$file" ]] && return 1
    
    # Create backup
    cp "$file" "${file}.bak"
    
    # Perform replacement
    if sed -i.tmp "s/${old_version}/${new_version}/g" "$file" 2>/dev/null; then
        rm -f "${file}.tmp"
        
        # Verify update
        if grep -q "$new_version" "$file"; then
            rm -f "${file}.bak"
            return 0
        fi
    fi
    
    # Restore backup on failure
    mv "${file}.bak" "$file" 2>/dev/null || true
    return 1
}

# Update project version in metadata files
# Args: $1 - old version
#       $2 - new version
# Returns: 0 if at least one file updated, 1 if none
update_project_version() {
    local old_version="$1"
    local new_version="$2"
    local updated=false
    
    # Detect project type from tech stack
    local project_kind="${PROJECT_KIND:-generic}"
    
    # Try package.json (Node.js projects)
    if [[ -f "package.json" ]]; then
        if update_version_in_file "package.json" "$old_version" "$new_version"; then
            print_success "Updated version in package.json: ${old_version} → ${new_version}"
            updated=true
        fi
    fi
    
    # Try pyproject.toml (Python projects)
    if [[ -f "pyproject.toml" ]]; then
        if update_version_in_file "pyproject.toml" "$old_version" "$new_version"; then
            print_success "Updated version in pyproject.toml: ${old_version} → ${new_version}"
            updated=true
        fi
    fi
    
    # Try setup.py (Python projects)
    if [[ -f "setup.py" ]]; then
        if update_version_in_file "setup.py" "$old_version" "$new_version"; then
            print_success "Updated version in setup.py: ${old_version} → ${new_version}"
            updated=true
        fi
    fi
    
    # Try Cargo.toml (Rust projects)
    if [[ -f "Cargo.toml" ]]; then
        if update_version_in_file "Cargo.toml" "$old_version" "$new_version"; then
            print_success "Updated version in Cargo.toml: ${old_version} → ${new_version}"
            updated=true
        fi
    fi
    
    # Try .workflow-config.yaml
    if [[ -f ".workflow-config.yaml" ]]; then
        if update_version_in_file ".workflow-config.yaml" "$old_version" "$new_version"; then
            print_success "Updated version in .workflow-config.yaml: ${old_version} → ${new_version}"
            updated=true
        fi
    fi
    
    [[ "$updated" == true ]] && return 0 || return 1
}

################################################################################
# Main Step Function
################################################################################

step16_version_update() {
    print_step "15" "AI-Powered Semantic Version Update"
    
    # Check dry run mode
    if [[ "${DRY_RUN:-false}" == true ]]; then
        print_info "[DRY RUN] Step 16: Would update semantic versions"
        return 0
    fi
    
    # Initialize counters
    local files_updated=0
    local files_skipped=0
    local files_failed=0
    
    # Get modified files
    local modified_files
    modified_files=$(get_git_diff_files_output)
    if [[ -z "$modified_files" ]]; then
        print_warning "Could not determine modified files, using git diff"
        modified_files=$(git diff --name-only HEAD 2>/dev/null || echo "")
    fi
    
    if [[ -z "$modified_files" ]]; then
        print_info "No modified files to process"
        return 0
    fi
    
    # Count file types
    local modified_count=0
    local added_count=0
    local deleted_count=0
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        ((modified_count++))
        
        # Check if file exists (detect deleted files)
        [[ ! -f "$file" ]] && ((deleted_count++)) && continue
    done <<< "$modified_files"
    
    # Determine bump type
    local bump_type=""
    print_info "Determining version bump type..."
    
    # Try AI analysis first
    if check_copilot_available && [[ "${AUTO_MODE:-false}" != true ]]; then
        if bump_type=$(determine_ai_bump_type); then
            print_success "AI recommends: $bump_type version bump"
        else
            print_warning "AI analysis failed, using heuristics"
            bump_type=$(determine_heuristic_bump_type "$modified_count" "$added_count" "$deleted_count")
        fi
    else
        print_info "Using heuristic bump type (AI unavailable or auto mode)"
        bump_type=$(determine_heuristic_bump_type "$modified_count" "$added_count" "$deleted_count")
    fi
    
    print_info "Version bump type: ${bump_type}"
    
    # Extract current project version from first modified file with version
    local current_version=""
    local new_version=""
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue
        
        # Skip workflow artifacts
        [[ "$file" =~ ^(backlog|logs|summaries|metrics|\.ai_cache)/ ]] && continue
        
        # Skip third-party code
        is_excluded_path "$file" && continue
        
        # Detect version in file
        local version_match
        version_match=$(detect_version_patterns "$file" | head -1)
        
        if [[ -n "$version_match" ]]; then
            current_version=$(extract_version "$version_match")
            if [[ -n "$current_version" ]]; then
                break
            fi
        fi
    done <<< "$modified_files"
    
    if [[ -z "$current_version" ]]; then
        print_warning "No version pattern found in modified files"
        return 0
    fi
    
    # Get current version from project
    current_version=$(get_current_version "$PROJECT_ROOT")
    if [[ -z "$current_version" ]]; then
        print_warning "No version found in project metadata files"
        # Try to extract from modified files (old behavior)
        while IFS= read -r file; do
            [[ -z "$file" ]] && continue
            [[ ! -f "$file" ]] && continue
            
            # Skip workflow artifacts
            [[ "$file" =~ ^(backlog|logs|summaries|metrics|\.ai_cache)/ ]] && continue
            
            # Skip third-party code
            is_excluded_path "$file" && continue
            
            # Detect version in file
            local version_match
            version_match=$(detect_version_patterns "$file" | head -1)
            
            if [[ -n "$version_match" ]]; then
                current_version=$(extract_version "$version_match")
                if [[ -n "$current_version" ]]; then
                    break
                fi
            fi
        done <<< "$modified_files"
        
        if [[ -z "$current_version" ]]; then
            print_warning "No version pattern found in modified files"
            return 0
        fi
    fi
    
    print_info "Current version: ${current_version}"
    
    # Use automated_version_bump for proper version bumping
    print_info "Performing automated version bump..."
    
    # Preserve prerelease identifier if exists (e.g., -alpha, -beta)
    local prerelease_id=""
    if [[ "$current_version" =~ -([a-z]+) ]]; then
        prerelease_id="${BASH_REMATCH[1]}"
        print_info "Detected prerelease: $prerelease_id"
    fi
    
    # Perform version bump using the new library
    if ! automated_version_bump "$bump_type" "$PROJECT_ROOT" "false" "$prerelease_id"; then
        print_error "Automated version bump failed"
        return 1
    fi
    
    # Get new version after bump
    new_version=$(get_current_version "$PROJECT_ROOT")
    print_success "Version bumped: ${current_version} → ${new_version}"
    
    # Update versions in modified files
    print_info "Updating versions in modified files..."
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue
        
        # Skip workflow artifacts
        if [[ "$file" =~ ^(backlog|logs|summaries|metrics|\.ai_cache)/ ]]; then
            ((files_skipped++))
            continue
        fi
        
        # Skip third-party code
        if is_excluded_path "$file"; then
            ((files_skipped++))
            continue
        fi
        
        # Check if file contains version pattern
        if ! detect_version_patterns "$file" >/dev/null 2>&1; then
            ((files_skipped++))
            continue
        fi
        
        # Update version in file
        if update_version_in_file "$file" "$current_version" "$new_version"; then
            print_success "  ✓ $file"
            ((files_updated++))
        else
            print_warning "  ✗ $file (update failed)"
            ((files_failed++))
        fi
    done <<< "$modified_files"
    
    # Generate report
    local report_file="${BACKLOG_RUN_DIR}/step_16_version_update.md"
    {
        echo "# Step 16: AI-Powered Semantic Version Update"
        echo ""
        echo "**Status**: ✅ Complete"
        echo "**Bump Type**: $bump_type"
        echo "**Date**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
        echo ""
        echo "## Version Update"
        echo ""
        echo "- **Old Version**: $current_version"
        echo "- **New Version**: $new_version"
        echo "- **Bump Type**: $bump_type"
        echo ""
        echo "## Summary"
        echo ""
        echo "- Files updated: $files_updated"
        echo "- Files skipped: $files_skipped"
        echo "- Files failed: $files_failed"
        echo "- Total files processed: $((files_updated + files_skipped + files_failed))"
        echo ""
        echo "**Result**: Version update completed."
    } > "$report_file"
    
    print_success "Step 15 complete. Report: $report_file"
    print_info "Updated: $files_updated | Skipped: $files_skipped | Failed: $files_failed"
    
    return 0
}

# Export main function
export -f step16_version_update
