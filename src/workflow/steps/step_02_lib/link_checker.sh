#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 2 Link Checker Module
# Purpose: Broken link detection in documentation
# Part of: Step 2 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.0
################################################################################

# ==============================================================================
# LINK EXTRACTION
# ==============================================================================

# Extract absolute path references from a markdown file
# Usage: extract_absolute_refs_step2 <file_path>
# Returns: List of absolute path references
extract_absolute_refs_step2() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    # Extract file paths using regex (paths starting with /)
    grep -oP '(?<=\()(/[^)]+)(?=\))' "$file" 2>/dev/null || true
}

# ==============================================================================
# LINK VALIDATION
# ==============================================================================

# Check for broken references in a single file
# Usage: check_file_refs_step2 <file_path> <output_file>
# Returns: Count of broken references found
check_file_refs_step2() {
    local file="$1"
    local output_file="$2"
    local broken_count=0
    
    local refs
    refs=$(extract_absolute_refs_step2 "$file")
    
    while IFS= read -r ref; do
        [[ -z "$ref" ]] && continue
        
        # Extract file paths using regex (paths starting with /)
        local full_path="${PROJECT_ROOT}${ref}"
        if [[ ! -e "$full_path" ]]; then
            print_warning "Broken reference in $file: $ref"
            echo "$file: $ref" >> "$output_file"
            ((broken_count++))
        fi
    done <<< "$refs"
    
    return $broken_count
}

# ==============================================================================
# COMPREHENSIVE LINK CHECKING
# ==============================================================================

# Check all documentation files for broken links
# Usage: check_all_documentation_links_step2 <output_file>
# Returns: Count of broken links found
check_all_documentation_links_step2() {
    local output_file="$1"
    local total_broken=0
    
    print_info "Phase 1: Automated broken link detection..."
    
    # Check docs directory for broken references
    while IFS= read -r md_file; do
        local broken=0
        check_file_refs_step2 "$md_file" "$output_file" || broken=$?
        ((total_broken += broken)) || true
    done < <(fast_find "docs" "*.md" 5 2>/dev/null || find docs -name "*.md" -type f 2>/dev/null || true)
    
    # Check README.md
    if [[ -f "README.md" ]]; then
        local broken=0
        check_file_refs_step2 "README.md" "$output_file" || broken=$?
        ((total_broken += broken)) || true
    fi
    
    # Check .github/copilot-instructions.md (critical for CI/CD)
    if [[ -f ".github/copilot-instructions.md" ]]; then
        local broken
        check_file_refs_step2 ".github/copilot-instructions.md" "$output_file" || broken=$?
        ((total_broken += broken)) || true
    fi
    
    return $total_broken
}

# ==============================================================================
# DOCUMENTATION INVENTORY
# ==============================================================================

# Gather documentation file inventory
# Usage: get_documentation_inventory_step2
# Returns: List of documentation files
get_documentation_inventory_step2() {
    # Use fast_find if available, otherwise fallback to regular find
    if command -v fast_find &>/dev/null; then
        fast_find "." "*.md" 5 "node_modules" ".git" "coverage" 2>/dev/null | sort
    else
        find . -name "*.md" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/coverage/*" 2>/dev/null | sort
    fi
}

# Count documentation files
# Usage: count_documentation_files_step2
# Returns: Number of documentation files
count_documentation_files_step2() {
    get_documentation_inventory_step2 | wc -l
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f extract_absolute_refs_step2
export -f check_file_refs_step2
export -f check_all_documentation_links_step2
export -f get_documentation_inventory_step2
export -f count_documentation_files_step2
