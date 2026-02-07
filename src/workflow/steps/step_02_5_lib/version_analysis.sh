#!/usr/bin/env bash
#
# Version Analysis for Documentation Optimization
# Extracts and analyzes version references in documentation
#
# Functions:
# - Version number extraction
# - Version comparison and gap analysis
# - Outdated content detection based on versions
#

set -euo pipefail

################################################################################
# Extract version references from a markdown file
# Arguments:
#   $1 - File path
# Returns:
#   List of version references (one per line)
################################################################################
extract_version_references() {
    local file="$1"
    
    # Pattern matching for various version formats:
    # v1.2.3, Version 1.2.3, @1.2.3, [1.2.3], 1.2.3
    grep -oE '(v|V|version|Version|@)?\s*[0-9]+\.[0-9]+(\.[0-9]+)?' "$file" 2>/dev/null | \
        sed 's/^[vV@[:space:]]*//' | \
        grep -E '^[0-9]+\.[0-9]+' | \
        sort -u || true
}

################################################################################
# Get current project version
# Returns:
#   Version string from package.json, or "unknown"
################################################################################
get_current_project_version() {
    local version="unknown"
    
    # Try package.json
    if [[ -f "$PROJECT_ROOT/package.json" ]] && command -v jq &>/dev/null; then
        version=$(jq -r '.version // "unknown"' "$PROJECT_ROOT/package.json" 2>/dev/null)
    fi
    
    # Try pyproject.toml
    if [[ "$version" == "unknown" ]] && [[ -f "$PROJECT_ROOT/pyproject.toml" ]]; then
        version=$(grep -oP '^version\s*=\s*"\K[^"]+' "$PROJECT_ROOT/pyproject.toml" 2>/dev/null || echo "unknown")
    fi
    
    # Try Cargo.toml
    if [[ "$version" == "unknown" ]] && [[ -f "$PROJECT_ROOT/Cargo.toml" ]]; then
        version=$(grep -oP '^version\s*=\s*"\K[^"]+' "$PROJECT_ROOT/Cargo.toml" 2>/dev/null || echo "unknown")
    fi
    
    # Try CHANGELOG.md (first version mention)
    if [[ "$version" == "unknown" ]] && [[ -f "$PROJECT_ROOT/CHANGELOG.md" ]]; then
        version=$(grep -oE '\[?[0-9]+\.[0-9]+\.[0-9]+\]?' "$PROJECT_ROOT/CHANGELOG.md" | head -1 | tr -d '[]' 2>/dev/null || echo "unknown")
    fi
    
    echo "$version"
}

################################################################################
# Parse semantic version into major.minor.patch
# Arguments:
#   $1 - Version string (e.g., "1.2.3")
# Returns:
#   Three values: major minor patch
################################################################################
parse_version() {
    local version="$1"
    
    # Remove leading v or V
    version="${version#[vV]}"
    
    # Split by dots
    IFS='.' read -r major minor patch <<< "$version"
    
    # Default patch to 0 if not present
    patch="${patch:-0}"
    
    echo "$major $minor $patch"
}

################################################################################
# Compare two semantic versions
# Arguments:
#   $1 - Version 1 (e.g., "1.2.3")
#   $2 - Version 2 (e.g., "2.0.0")
# Returns:
#   -1 if v1 < v2, 0 if equal, 1 if v1 > v2
################################################################################
compare_versions() {
    local v1="$1"
    local v2="$2"
    
    # Parse versions
    read -r major1 minor1 patch1 <<< "$(parse_version "$v1")"
    read -r major2 minor2 patch2 <<< "$(parse_version "$v2")"
    
    # Compare major version
    if [[ $major1 -lt $major2 ]]; then
        echo "-1"
        return
    elif [[ $major1 -gt $major2 ]]; then
        echo "1"
        return
    fi
    
    # Compare minor version
    if [[ $minor1 -lt $minor2 ]]; then
        echo "-1"
        return
    elif [[ $minor1 -gt $minor2 ]]; then
        echo "1"
        return
    fi
    
    # Compare patch version
    if [[ $patch1 -lt $patch2 ]]; then
        echo "-1"
    elif [[ $patch1 -gt $patch2 ]]; then
        echo "1"
    else
        echo "0"
    fi
}

################################################################################
# Calculate version gap (major versions difference)
# Arguments:
#   $1 - Old version
#   $2 - New version
# Returns:
#   Major version gap
################################################################################
calculate_version_gap() {
    local old_version="$1"
    local new_version="$2"
    
    read -r major1 _ _ <<< "$(parse_version "$old_version")"
    read -r major2 _ _ <<< "$(parse_version "$new_version")"
    
    echo $((major2 - major1))
}

################################################################################
# Analyze version references in a file
# Arguments:
#   $1 - File path
#   $2 - Current project version
# Returns:
#   Analysis summary
################################################################################
analyze_file_versions() {
    local file="$1"
    local current_version="$2"
    
    # Extract version references
    local versions
    versions=$(extract_version_references "$file")
    
    if [[ -z "$versions" ]]; then
        echo "no_versions"
        return
    fi
    
    # Find oldest version mentioned
    local oldest_version=""
    local oldest_gap=0
    
    while IFS= read -r version; do
        [[ -z "$version" ]] && continue
        
        # Compare with current version
        local comparison
        comparison=$(compare_versions "$version" "$current_version")
        
        if [[ $comparison -eq -1 ]]; then
            # This version is older than current
            local gap
            gap=$(calculate_version_gap "$version" "$current_version")
            
            if [[ $gap -gt $oldest_gap ]]; then
                oldest_gap=$gap
                oldest_version="$version"
            fi
        fi
    done <<< "$versions"
    
    # Return result
    if [[ -n "$oldest_version" ]]; then
        echo "outdated|$oldest_version|$oldest_gap"
    else
        echo "current"
    fi
}

################################################################################
# Scan all documentation for version references
# Populates DOC_VERSION_REFS map
################################################################################
scan_documentation_versions() {
    local current_version
    current_version=$(get_current_project_version)
    
    print_info "Scanning version references (current version: $current_version)..."
    
    if [[ "$current_version" == "unknown" ]]; then
        print_warning "Could not determine current project version - skipping version analysis"
        return 1
    fi
    
    local file analysis
    local scanned=0
    
    while IFS= read -r file; do
        # Skip excluded files
        if should_exclude_file "$file"; then
            continue
        fi
        
        # Analyze versions in file
        analysis=$(analyze_file_versions "$file" "$current_version")
        DOC_VERSION_REFS["$file"]="$analysis"
        
        ((scanned++))
    done < <(find "$DOCS_DIR" -name "*.md" -type f)
    
    print_success "Scanned version references in $scanned files"
    return 0
}

################################################################################
# Identify files with outdated version references
# Adds to OUTDATED_FILES array if version gap > threshold
################################################################################
identify_version_outdated_files() {
    local version_gap_threshold=2  # Major versions
    
    print_info "Identifying files with outdated version references..."
    
    local outdated_count=0
    
    for file in "${!DOC_VERSION_REFS[@]}"; do
        local analysis="${DOC_VERSION_REFS[$file]}"
        
        # Skip if no versions or current
        if [[ "$analysis" == "no_versions" ]] || [[ "$analysis" == "current" ]]; then
            continue
        fi
        
        # Parse analysis result
        IFS='|' read -r status old_version gap <<< "$analysis"
        
        if [[ "$status" == "outdated" ]] && [[ $gap -ge $version_gap_threshold ]]; then
            # Check if not already in OUTDATED_FILES
            local already_marked=false
            for outdated in "${OUTDATED_FILES[@]}"; do
                if [[ "$file" == "$outdated" ]]; then
                    already_marked=true
                    break
                fi
            done
            
            if [[ "$already_marked" == "false" ]]; then
                OUTDATED_FILES+=("$file")
                ((outdated_count++))
                
                print_debug "Version outdated: $file (references v$old_version, $gap major versions behind)"
            fi
        fi
    done
    
    print_success "Found $outdated_count files with outdated version references"
    return 0
}

################################################################################
# Generate version analysis report for a file
# Arguments:
#   $1 - File path
# Returns:
#   Formatted version analysis
################################################################################
generate_version_analysis_summary() {
    local file="$1"
    local current_version
    current_version=$(get_current_project_version)
    
    local analysis="${DOC_VERSION_REFS[$file]:-no_versions}"
    
    if [[ "$analysis" == "no_versions" ]]; then
        echo "  No version references found"
        return
    elif [[ "$analysis" == "current" ]]; then
        echo "  Version references are current"
        return
    fi
    
    # Parse analysis
    IFS='|' read -r status old_version gap <<< "$analysis"
    
    echo "  Oldest version: v$old_version"
    echo "  Current version: v$current_version"
    echo "  Gap: $gap major version(s)"
    
    if [[ $gap -ge 2 ]]; then
        echo "  ⚠️  Significantly outdated"
    fi
}

################################################################################
# Check if documentation section should be updated
# Arguments:
#   $1 - File path
#   $2 - Version threshold (major versions)
# Returns:
#   0 if should update, 1 otherwise
################################################################################
should_update_for_version() {
    local file="$1"
    local threshold="${2:-2}"
    
    local analysis="${DOC_VERSION_REFS[$file]:-no_versions}"
    
    if [[ "$analysis" == "no_versions" ]] || [[ "$analysis" == "current" ]]; then
        return 1
    fi
    
    IFS='|' read -r status old_version gap <<< "$analysis"
    
    if [[ $gap -ge $threshold ]]; then
        return 0
    else
        return 1
    fi
}

################################################################################
# Main version analysis entry point
# Called from main step
################################################################################
analyze_documentation_versions() {
    # Scan for version references
    if ! scan_documentation_versions; then
        print_warning "Version scanning failed"
        return 1
    fi
    
    # Identify outdated files based on versions
    if ! identify_version_outdated_files; then
        print_error "Version-based outdated detection failed"
        return 1
    fi
    
    print_success "Version analysis complete"
    return 0
}

# Export functions
export -f extract_version_references
export -f get_current_project_version
export -f parse_version
export -f compare_versions
export -f calculate_version_gap
export -f analyze_file_versions
export -f scan_documentation_versions
export -f identify_version_outdated_files
export -f generate_version_analysis_summary
export -f should_update_for_version
export -f analyze_documentation_versions
