#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 2 Validation Module
# Purpose: Version validation and consistency checking
# Part of: Step 2 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.0
################################################################################

# ==============================================================================
# VERSION VALIDATION
# ==============================================================================

# Validates semantic version format (MAJOR.MINOR.PATCH)
# Usage: validate_semver_step2 <version_string>
# Returns: 0 if valid semver, 1 if invalid
validate_semver_step2() {
    local version="$1"
    
    # Semantic versioning regex: MAJOR.MINOR.PATCH (optional v prefix)
    if [[ "$version" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        return 0
    else
        return 1
    fi
}

# Extracts version numbers from documentation files
# Usage: extract_versions_from_file_step2 <file_path>
# Returns: Array of version strings found
extract_versions_from_file_step2() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    # Extract version patterns: v1.2.3 or 1.2.3
    grep -oP 'v?[0-9]+\.[0-9]+\.[0-9]+' "$file" 2>/dev/null | sort -u || true
}

# ==============================================================================
# VERSION CONSISTENCY CHECKING
# ==============================================================================

# Checks version consistency across documentation
# Returns: 0 if consistent, count of inconsistencies if found
check_version_consistency_step2() {
    local inconsistencies=0
    local version_map_file
    version_map_file=$(mktemp)
    TEMP_FILES+=("$version_map_file")
    
    print_info "Checking semantic version consistency across documentation..."
    
    # Find all markdown files
    while IFS= read -r md_file; do
        local versions
        versions=$(extract_versions_from_file_step2 "$md_file")
        
        while IFS= read -r version; do
            [[ -z "$version" ]] && continue
            
            # Validate semver format
            if ! validate_semver_step2 "$version"; then
                print_warning "Invalid semantic version format in $md_file: $version"
                echo "$md_file: $version (INVALID FORMAT)" >> "$version_map_file"
                ((inconsistencies++))
            else
                echo "$md_file: $version" >> "$version_map_file"
            fi
        done <<< "$versions"
    done < <(find . -name "*.md" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/.ai_workflow/*" 2>/dev/null || true)
    
    # Check package.json version if exists
    if [[ -f "src/package.json" ]]; then
        local pkg_version
        pkg_version=$(grep -oP '"version":\s*"\K[^"]+' "src/package.json" 2>/dev/null || true)
        
        if [[ -n "$pkg_version" ]]; then
            if ! validate_semver_step2 "$pkg_version"; then
                print_warning "Invalid semantic version in package.json: $pkg_version"
                echo "package.json: $pkg_version (INVALID FORMAT)" >> "$version_map_file"
                ((inconsistencies++))
            else
                echo "package.json: $pkg_version" >> "$version_map_file"
            fi
        fi
    fi
    
    # Display version map
    if [[ -s "$version_map_file" ]]; then
        local total_versions
        total_versions=$(wc -l < "$version_map_file")
        print_info "Found $total_versions version reference(s)"
        
        if [[ $inconsistencies -gt 0 ]]; then
            print_warning "Version format issues detected:"
            cat "$version_map_file"
        fi
    fi
    
    return $inconsistencies
}

# ==============================================================================
# METRICS VALIDATION
# ==============================================================================

# Validate metrics consistency across documentation
# Returns: 0 if consistent, 1 if inconsistencies found
check_metrics_consistency_step2() {
    print_info "Checking workflow metrics consistency..."
    
    # Source metrics validation library if available
    if [[ -f "${PROJECT_ROOT:-}/src/workflow/lib/metrics_validation.sh" ]]; then
        # shellcheck source=/dev/null
        source "${PROJECT_ROOT:-}/src/workflow/lib/metrics_validation.sh"
        
        # Run metrics validation
        if ! validate_all_documentation_metrics; then
            print_warning "Documentation metrics inconsistencies detected"
            return 1
        else
            print_success "All documentation metrics are consistent ✅"
            return 0
        fi
    else
        print_warning "Metrics validation library not found - skipping metrics check"
        return 0
    fi
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f validate_semver_step2
export -f extract_versions_from_file_step2
export -f check_version_consistency_step2
export -f check_metrics_consistency_step2
