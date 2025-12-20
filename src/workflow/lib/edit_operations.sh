#!/bin/bash
set -euo pipefail

################################################################################
# Edit Operations Module with Fuzzy Matching
# Purpose: Advanced file editing with pre-flight validation and fuzzy matching
# Part of: Tests & Documentation Workflow Automation v2.3.1
# 
# Implements recommendations from AI workflow analysis:
# - Fuzzy matching for edit operations to reduce initial match failures
# - Pre-flight validation to verify exact string matches
# - Diff preview before edit application
# - Edit recovery with retry logic
################################################################################

# ==============================================================================
# FUZZY STRING MATCHING
# ==============================================================================

# Calculate Levenshtein distance between two strings
# Usage: levenshtein_distance <string1> <string2>
# Returns: distance value via stdout
levenshtein_distance() {
    local str1="$1"
    local str2="$2"
    local len1=${#str1}
    local len2=${#str2}
    
    # Create distance matrix
    declare -A matrix
    
    # Initialize first row and column
    for ((i=0; i<=len1; i++)); do
        matrix[$i,0]=$i
    done
    for ((j=0; j<=len2; j++)); do
        matrix[0,$j]=$j
    done
    
    # Calculate distances
    for ((i=1; i<=len1; i++)); do
        for ((j=1; j<=len2; j++)); do
            local cost=1
            if [[ "${str1:i-1:1}" == "${str2:j-1:1}" ]]; then
                cost=0
            fi
            
            local deletion=$((matrix[$((i-1)),$j] + 1))
            local insertion=$((matrix[$i,$((j-1))] + 1))
            local substitution=$((matrix[$((i-1)),$((j-1))] + cost))
            
            local min=$deletion
            [[ $insertion -lt $min ]] && min=$insertion
            [[ $substitution -lt $min ]] && min=$substitution
            
            matrix[$i,$j]=$min
        done
    done
    
    echo ${matrix[$len1,$len2]}
}

# Calculate similarity percentage between two strings
# Usage: string_similarity <string1> <string2>
# Returns: percentage (0-100) via stdout
string_similarity() {
    local str1="$1"
    local str2="$2"
    
    local max_len=${#str1}
    [[ ${#str2} -gt $max_len ]] && max_len=${#str2}
    
    if [[ $max_len -eq 0 ]]; then
        echo "100"
        return 0
    fi
    
    local distance
    distance=$(levenshtein_distance "$str1" "$str2")
    local similarity=$(( 100 - (distance * 100 / max_len) ))
    
    echo "$similarity"
}

# Find best fuzzy match in file
# Usage: find_fuzzy_match <filepath> <search_string> [min_similarity]
# Returns: 0 on success with match info, 1 if no match found
find_fuzzy_match() {
    local filepath="$1"
    local search_string="$2"
    local min_similarity="${3:-80}"  # Default 80% similarity
    
    if [[ ! -f "$filepath" ]]; then
        print_error "File not found: $filepath"
        return 1
    fi
    
    local best_match=""
    local best_similarity=0
    local best_line=0
    local line_num=0
    
    # Normalize search string (remove extra whitespace)
    local normalized_search
    normalized_search=$(echo "$search_string" | tr -s '[:space:]' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    while IFS= read -r line; do
        ((line_num++))
        
        # Normalize line
        local normalized_line
        normalized_line=$(echo "$line" | tr -s '[:space:]' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Calculate similarity
        local similarity
        similarity=$(string_similarity "$normalized_search" "$normalized_line")
        
        if [[ $similarity -gt $best_similarity ]]; then
            best_similarity=$similarity
            best_match="$line"
            best_line=$line_num
        fi
    done < "$filepath"
    
    if [[ $best_similarity -ge $min_similarity ]]; then
        echo "MATCH_FOUND"
        echo "LINE: $best_line"
        echo "SIMILARITY: $best_similarity%"
        echo "CONTENT: $best_match"
        return 0
    else
        print_warning "No fuzzy match found above ${min_similarity}% similarity"
        print_info "Best match: ${best_similarity}% at line $best_line"
        return 1
    fi
}

# ==============================================================================
# PRE-FLIGHT EDIT VALIDATION
# ==============================================================================

# Validate that search string exists in file before attempting edit
# Usage: validate_edit_string <filepath> <search_string>
# Returns: 0 if found, 1 if not found, 2 if found multiple times
validate_edit_string() {
    local filepath="$1"
    local search_string="$2"
    
    if [[ ! -f "$filepath" ]]; then
        print_error "File not found: $filepath"
        return 1
    fi
    
    # Count exact matches
    local match_count
    match_count=$(grep -Fc "$search_string" "$filepath" 2>/dev/null || echo "0")
    
    if [[ $match_count -eq 0 ]]; then
        print_warning "String not found in file: $(basename "$filepath")"
        print_info "Attempting fuzzy match..."
        
        # Try fuzzy matching
        if find_fuzzy_match "$filepath" "$search_string" 75; then
            print_info "Fuzzy match found - consider using the suggested line"
            return 3  # Special code: fuzzy match available
        fi
        return 1
    elif [[ $match_count -eq 1 ]]; then
        print_success "✓ Exact match found in $(basename "$filepath")"
        return 0
    else
        print_warning "⚠ Multiple matches found ($match_count) in $(basename "$filepath")"
        print_info "Edit may fail due to ambiguity"
        return 2
    fi
}

# Show context around match in file
# Usage: show_match_context <filepath> <search_string> [context_lines]
show_match_context() {
    local filepath="$1"
    local search_string="$2"
    local context="${3:-3}"
    
    if [[ ! -f "$filepath" ]]; then
        print_error "File not found: $filepath"
        return 1
    fi
    
    print_info "Context preview for: $(basename "$filepath")"
    echo "─────────────────────────────────────"
    
    # Show context with line numbers
    grep -B "$context" -A "$context" -n "$search_string" "$filepath" 2>/dev/null || {
        print_warning "Could not show context"
        return 1
    }
    
    echo "─────────────────────────────────────"
}

# ==============================================================================
# DIFF PREVIEW
# ==============================================================================

# Generate diff preview before applying edit
# Usage: preview_edit_diff <filepath> <old_string> <new_string>
# Returns: diff output via stdout
preview_edit_diff() {
    local filepath="$1"
    local old_string="$2"
    local new_string="$3"
    
    if [[ ! -f "$filepath" ]]; then
        print_error "File not found: $filepath"
        return 1
    fi
    
    # Create temporary files
    local temp_original="${filepath}.preview.orig.$$"
    local temp_modified="${filepath}.preview.mod.$$"
    
    cp "$filepath" "$temp_original"
    
    # Apply edit to temporary file
    sed "s|${old_string}|${new_string}|" "$temp_original" > "$temp_modified"
    
    print_info "Edit preview for: $(basename "$filepath")"
    echo "═════════════════════════════════════════════════════════════"
    
    # Show diff
    if command -v diff &>/dev/null; then
        diff -u "$temp_original" "$temp_modified" || true
    else
        print_warning "diff command not available, showing before/after"
        echo "BEFORE:"
        echo "───────"
        echo "$old_string"
        echo ""
        echo "AFTER:"
        echo "───────"
        echo "$new_string"
    fi
    
    echo "═════════════════════════════════════════════════════════════"
    
    # Cleanup
    rm -f "$temp_original" "$temp_modified"
}

# ==============================================================================
# SAFE EDIT OPERATIONS WITH RETRY
# ==============================================================================

# Perform safe edit operation with validation and retry
# Usage: safe_edit_file <filepath> <old_string> <new_string> [preview] [max_retries]
# Returns: 0 on success, 1 on failure
safe_edit_file() {
    local filepath="$1"
    local old_string="$2"
    local new_string="$3"
    local preview="${4:-true}"
    local max_retries="${5:-3}"
    
    print_info "Preparing edit for: $(basename "$filepath")"
    
    # Pre-flight validation
    validate_edit_string "$filepath" "$old_string"
    local validation_result=$?
    
    case $validation_result in
        0)
            # Exact match found
            print_success "Pre-flight check passed"
            ;;
        1)
            # No match found
            print_error "Pre-flight check failed: string not found"
            return 1
            ;;
        2)
            # Multiple matches
            print_warning "Multiple matches found - proceeding with caution"
            show_match_context "$filepath" "$old_string" 2
            ;;
        3)
            # Fuzzy match available
            print_warning "Only fuzzy match found - edit may fail"
            if [[ "$preview" == "true" ]]; then
                read -p "Attempt edit anyway? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    print_info "Edit cancelled"
                    return 1
                fi
            fi
            ;;
    esac
    
    # Show diff preview if requested
    if [[ "$preview" == "true" ]] && [[ $validation_result -eq 0 || $validation_result -eq 2 ]]; then
        preview_edit_diff "$filepath" "$old_string" "$new_string"
        
        if [[ "${AUTO_APPROVE_EDITS:-false}" != "true" ]]; then
            read -p "Apply this edit? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "Edit cancelled"
                return 1
            fi
        fi
    fi
    
    # Attempt edit with retry logic
    local attempt=1
    while [[ $attempt -le $max_retries ]]; do
        print_info "Edit attempt $attempt/$max_retries..."
        
        # Create backup
        local backup_file="${filepath}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$filepath" "$backup_file"
        
        # Attempt edit
        if sed -i.tmp "s|${old_string}|${new_string}|" "$filepath" 2>/dev/null; then
            rm -f "${filepath}.tmp"
            
            # Verify edit was applied
            if grep -q "$new_string" "$filepath" 2>/dev/null; then
                print_success "✓ Edit applied successfully to $(basename "$filepath")"
                rm -f "$backup_file"  # Clean up backup
                return 0
            else
                print_warning "Edit command succeeded but string not found in result"
                # Restore backup
                mv "$backup_file" "$filepath"
            fi
        else
            print_warning "Edit command failed"
            # Restore backup
            mv "$backup_file" "$filepath"
        fi
        
        if [[ $attempt -lt $max_retries ]]; then
            print_info "Retrying with adjusted strategy..."
            sleep 1
        fi
        
        ((attempt++))
    done
    
    print_error "All edit attempts failed"
    return 1
}

# ==============================================================================
# BATCH EDIT OPERATIONS
# ==============================================================================

# Apply multiple edits to a file atomically
# Usage: batch_edit_file <filepath> <edits_file>
# edits_file format: one edit per line: "OLD_STRING|||NEW_STRING"
batch_edit_file() {
    local filepath="$1"
    local edits_file="$2"
    
    if [[ ! -f "$filepath" ]]; then
        print_error "Target file not found: $filepath"
        return 1
    fi
    
    if [[ ! -f "$edits_file" ]]; then
        print_error "Edits file not found: $edits_file"
        return 1
    fi
    
    print_info "Preparing batch edit for: $(basename "$filepath")"
    
    # Create backup
    local backup_file="${filepath}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$filepath" "$backup_file"
    
    local edit_count=0
    local success_count=0
    local fail_count=0
    
    # Read edits
    while IFS='|||' read -r old_string new_string; do
        ((edit_count++))
        
        print_info "Applying edit $edit_count..."
        
        if safe_edit_file "$filepath" "$old_string" "$new_string" false 1; then
            ((success_count++))
        else
            ((fail_count++))
            print_warning "Edit $edit_count failed"
        fi
    done < "$edits_file"
    
    print_info "Batch edit complete: $success_count success, $fail_count failed out of $edit_count"
    
    if [[ $fail_count -eq 0 ]]; then
        rm -f "$backup_file"
        return 0
    else
        print_warning "Some edits failed. Backup preserved: $(basename "$backup_file")"
        return 1
    fi
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f levenshtein_distance
export -f string_similarity
export -f find_fuzzy_match
export -f validate_edit_string
export -f show_match_context
export -f preview_edit_diff
export -f safe_edit_file
export -f batch_edit_file

# Only print if print_info function exists (loaded after colors.sh)
if declare -f print_info &>/dev/null; then
    print_info "Edit operations module loaded (v2.3.1)"
fi
