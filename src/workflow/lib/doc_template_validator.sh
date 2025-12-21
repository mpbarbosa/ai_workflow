#!/bin/bash
set -euo pipefail

################################################################################
# Documentation Template Validator
# Purpose: Ensure consistent formatting and version sync across documentation
# Part of: Tests & Documentation Workflow Automation v2.3.1
#
# Implements recommendations from AI workflow analysis:
# - Maintain version-controlled documentation template
# - Automated checks for version reference synchronization
# - Format consistency validation
################################################################################

# ==============================================================================
# TEMPLATE STRUCTURE VALIDATION
# ==============================================================================

# Define expected documentation structure
# This can be overridden by project-specific configuration
declare -A DOC_TEMPLATES

# README.md template requirements
DOC_TEMPLATES[README]='
REQUIRED_SECTIONS:
- # Project Title
- ## Description
- ## Installation
- ## Usage
- ## License

OPTIONAL_SECTIONS:
- ## Features
- ## Documentation
- ## Contributing
- ## Changelog
'

# CONTRIBUTING.md template
DOC_TEMPLATES[CONTRIBUTING]='
REQUIRED_SECTIONS:
- # Contributing
- ## Code of Conduct
- ## How to Contribute
- ## Development Setup
- ## Pull Request Process
'

# Validate documentation structure
# Usage: validate_doc_structure <filepath> <template_name>
# Returns: 0 if valid, 1 if issues found
validate_doc_structure() {
    local filepath="$1"
    local template_name="$2"
    
    if [[ ! -f "$filepath" ]]; then
        print_warning "File not found: $filepath"
        return 1
    fi
    
    print_info "Validating structure of: $(basename "$filepath")"
    
    local issues=0
    
    # Get required sections for this template
    local required_sections
    required_sections=$(echo "${DOC_TEMPLATES[$template_name]}" | grep "^- #" | sed 's/^- //' || true)
    
    if [[ -z "$required_sections" ]]; then
        print_info "No structure requirements defined for $template_name"
        return 0
    fi
    
    # Check each required section
    while IFS= read -r section; do
        if ! grep -q "^${section}" "$filepath" 2>/dev/null; then
            print_warning "Missing section: $section"
            ((issues++))
        fi
    done <<< "$required_sections"
    
    if [[ $issues -eq 0 ]]; then
        print_success "✓ Structure validation passed"
        return 0
    else
        print_warning "⚠ Found $issues structure issues"
        return 1
    fi
}

# ==============================================================================
# VERSION SYNCHRONIZATION
# ==============================================================================

# Extract all version references from a file
# Usage: extract_version_refs <filepath>
# Returns: list of version strings found
extract_version_refs() {
    local filepath="$1"
    
    if [[ ! -f "$filepath" ]]; then
        print_error "File not found: $filepath"
        return 1
    fi
    
    # Match various version patterns:
    # - v1.2.3
    # - version 1.2.3
    # - Version: 1.2.3
    # - @version 1.2.3
    grep -oE '([vV]ersion[:\s]+)?v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?' "$filepath" 2>/dev/null | \
        grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?' | \
        sort -u
}

# Check version consistency across documentation
# Usage: check_version_consistency [expected_version]
# Returns: 0 if consistent, 1 if inconsistencies found
check_version_consistency() {
    local expected_version="${1:-}"
    
    print_info "Checking version consistency across documentation..."
    
    # Find all documentation files
    local doc_files=()
    while IFS= read -r file; do
        doc_files+=("$file")
    done < <(find "$PROJECT_ROOT" -name "*.md" -type f 2>/dev/null)
    
    if [[ ${#doc_files[@]} -eq 0 ]]; then
        print_warning "No markdown files found"
        return 0
    fi
    
    # Collect all versions found
    declare -A version_locations
    local all_versions=()
    
    for file in "${doc_files[@]}"; do
        local versions
        versions=$(extract_version_refs "$file")
        
        if [[ -n "$versions" ]]; then
            while IFS= read -r version; do
                version_locations["$version"]+="  - $(basename "$file")
"
                all_versions+=("$version")
            done <<< "$versions"
        fi
    done
    
    # Get unique versions
    local unique_versions
    unique_versions=$(printf '%s\n' "${all_versions[@]}" | sort -u)
    local version_count
    version_count=$(echo "$unique_versions" | wc -l)
    
    if [[ $version_count -eq 0 ]]; then
        print_info "No version references found in documentation"
        return 0
    fi
    
    if [[ $version_count -eq 1 ]]; then
        print_success "✓ All documentation uses consistent version: $unique_versions"
        
        if [[ -n "$expected_version" ]] && [[ "$unique_versions" != "$expected_version" ]]; then
            print_warning "⚠ Version mismatch: expected $expected_version, found $unique_versions"
            return 1
        fi
        
        return 0
    fi
    
    # Multiple versions found
    print_warning "⚠ Found $version_count different version references:"
    echo ""
    
    for version in $(echo "$unique_versions"); do
        echo "${YELLOW}Version $version:${NC}"
        echo "${version_locations[$version]}"
    done
    
    if [[ -n "$expected_version" ]]; then
        print_info "Expected version: $expected_version"
    fi
    
    return 1
}

# Update all version references in documentation
# Usage: update_all_versions <new_version> [dry_run]
# Returns: 0 on success, 1 on failure
update_all_versions() {
    local new_version="$1"
    local dry_run="${2:-false}"
    
    print_info "Updating all version references to: $new_version"
    
    # Validate version format
    if ! echo "$new_version" | grep -qE '^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$'; then
        print_error "Invalid version format: $new_version"
        print_info "Expected format: v1.2.3 or 1.2.3 (with optional pre-release suffix)"
        return 1
    fi
    
    # Find all markdown files
    local doc_files=()
    while IFS= read -r file; do
        doc_files+=("$file")
    done < <(find "$PROJECT_ROOT" -name "*.md" -type f 2>/dev/null)
    
    local updated_count=0
    local failed_count=0
    
    for file in "${doc_files[@]}"; do
        local old_versions
        old_versions=$(extract_version_refs "$file")
        
        if [[ -z "$old_versions" ]]; then
            continue
        fi
        
        print_info "Updating: $(basename "$file")"
        
        if [[ "$dry_run" == "true" ]]; then
            echo "  Would update versions: $old_versions → $new_version"
            ((updated_count++))
        else
            # Create backup
            cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
            
            # Update each version pattern
            local temp_file="${file}.tmp.$$"
            cp "$file" "$temp_file"
            
            while IFS= read -r old_version; do
                # Try multiple patterns
                sed -i "s/version[:\s]*${old_version}/version ${new_version}/gi" "$temp_file"
                sed -i "s/v${old_version}/${new_version}/g" "$temp_file"
                sed -i "s/@version[:\s]*${old_version}/@version ${new_version}/g" "$temp_file"
            done <<< "$old_versions"
            
            if mv "$temp_file" "$file"; then
                print_success "✓ Updated $(basename "$file")"
                ((updated_count++))
            else
                print_error "✗ Failed to update $(basename "$file")"
                rm -f "$temp_file"
                ((failed_count++))
            fi
        fi
    done
    
    echo ""
    if [[ "$dry_run" == "true" ]]; then
        print_info "[DRY RUN] Would update $updated_count files"
    else
        print_success "Updated $updated_count files"
        if [[ $failed_count -gt 0 ]]; then
            print_warning "Failed to update $failed_count files"
            return 1
        fi
    fi
    
    return 0
}

# ==============================================================================
# FORMAT CONSISTENCY CHECKS
# ==============================================================================

# Check for common formatting issues
# Usage: check_doc_formatting <filepath>
# Returns: 0 if no issues, 1 if issues found
check_doc_formatting() {
    local filepath="$1"
    
    if [[ ! -f "$filepath" ]]; then
        print_error "File not found: $filepath"
        return 1
    fi
    
    print_info "Checking formatting: $(basename "$filepath")"
    
    local issues=0
    
    # Check 1: Multiple blank lines
    if grep -Pzo '\n\n\n+' "$filepath" &>/dev/null; then
        print_warning "Found multiple consecutive blank lines"
        ((issues++))
    fi
    
    # Check 2: Trailing whitespace
    if grep -n ' $' "$filepath" &>/dev/null; then
        print_warning "Found trailing whitespace on some lines"
        ((issues++))
    fi
    
    # Check 3: Inconsistent heading style
    local heading_styles
    heading_styles=$(grep -cE '^#+\s' "$filepath" 2>/dev/null || echo "0")
    local underline_headings
    underline_headings=$(grep -cE '^[=-]+$' "$filepath" 2>/dev/null || echo "0")
    
    if [[ $heading_styles -gt 0 ]] && [[ $underline_headings -gt 0 ]]; then
        print_warning "Mixed heading styles (# vs underline)"
        ((issues++))
    fi
    
    # Check 4: Code block consistency
    local triple_backtick
    triple_backtick=$(grep -c '```' "$filepath" 2>/dev/null || echo "0")
    if [[ $((triple_backtick % 2)) -ne 0 ]]; then
        print_warning "Unclosed code block (odd number of triple backticks)"
        ((issues++))
    fi
    
    # Check 5: Link format
    if grep -nE '\[.*\]\([^)]*\s[^)]*\)' "$filepath" &>/dev/null; then
        print_warning "Found links with spaces in URLs (may be broken)"
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        print_success "✓ No formatting issues found"
        return 0
    else
        print_warning "⚠ Found $issues formatting issues"
        return 1
    fi
}

# ==============================================================================
# COMPREHENSIVE DOCUMENTATION AUDIT
# ==============================================================================

# Run all documentation checks
# Usage: audit_documentation [fix]
# Returns: 0 if all checks pass, 1 if issues found
audit_documentation() {
    local fix_mode="${1:-false}"
    
    print_header "Documentation Audit"
    
    local total_issues=0
    
    # 1. Version consistency check
    print_info "1. Checking version consistency..."
    if ! check_version_consistency; then
        ((total_issues++))
        
        if [[ "$fix_mode" == "fix" ]]; then
            print_info "Attempting to fix version inconsistencies..."
            read -r -p "Enter correct version (e.g., v2.3.1): " correct_version
            update_all_versions "$correct_version" false
        fi
    fi
    echo ""
    
    # 2. README structure validation
    if [[ -f "$PROJECT_ROOT/README.md" ]]; then
        print_info "2. Validating README.md structure..."
        if ! validate_doc_structure "$PROJECT_ROOT/README.md" "README"; then
            ((total_issues++))
        fi
        echo ""
    fi
    
    # 3. Format consistency checks
    print_info "3. Checking document formatting..."
    local format_issues=0
    
    while IFS= read -r file; do
        if ! check_doc_formatting "$file"; then
            ((format_issues++))
        fi
    done < <(find "$PROJECT_ROOT" -name "*.md" -maxdepth 2 -type f 2>/dev/null)
    
    if [[ $format_issues -gt 0 ]]; then
        ((total_issues++))
        print_warning "Found formatting issues in $format_issues files"
    fi
    echo ""
    
    # 4. Summary
    print_header "Audit Summary"
    if [[ $total_issues -eq 0 ]]; then
        print_success "✓ All documentation checks passed!"
        return 0
    else
        print_warning "⚠ Found issues in $total_issues area(s)"
        print_info "Run with 'fix' argument to auto-fix some issues"
        return 1
    fi
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f validate_doc_structure
export -f extract_version_refs
export -f check_version_consistency
export -f update_all_versions
export -f check_doc_formatting
export -f audit_documentation

# Only print if print_info function exists (loaded after colors.sh)
if declare -f print_info &>/dev/null; then
    print_info "Documentation template validator loaded (v2.3.1)"
fi
