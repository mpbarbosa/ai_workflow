#!/usr/bin/env bash
#
# Consolidation Engine
# Handles archiving, consolidation, and file operations
#

set -euo pipefail

################################################################################
# Create archive directory with timestamp
################################################################################
create_archive_directory() {
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    
    ARCHIVE_DIR="${PROJECT_ROOT}/docs/.archive/${timestamp}"
    
    if ! mkdir -p "$ARCHIVE_DIR/original" "$ARCHIVE_DIR/consolidated"; then
        print_error "Failed to create archive directory: $ARCHIVE_DIR"
        return 1
    fi
    
    print_success "Created archive: $ARCHIVE_DIR"
    return 0
}

################################################################################
# Consolidate exact duplicate files
################################################################################
consolidate_duplicates() {
    local consolidated=0
    
    for dup_file in "${EXACT_DUPLICATES[@]}"; do
        # Find the original (first occurrence with same hash)
        local dup_hash="${DOC_HASHES[$dup_file]}"
        local original=""
        
        for file in "${!DOC_HASHES[@]}"; do
            if [[ "${DOC_HASHES[$file]}" == "$dup_hash" ]] && [[ "$file" != "$dup_file" ]]; then
                # Check if this is the original (not already marked as duplicate)
                local is_dup=false
                for d in "${EXACT_DUPLICATES[@]}"; do
                    if [[ "$file" == "$d" ]]; then
                        is_dup=true
                        break
                    fi
                done
                
                if [[ "$is_dup" == "false" ]]; then
                    original="$file"
                    break
                fi
            fi
        done
        
        if [[ -n "$original" ]]; then
            # Archive duplicate
            local archive_path="$ARCHIVE_DIR/original/$(basename "$dup_file")"
            cp "$dup_file" "$archive_path"
            
            # Remove duplicate (in dry-run, just report)
            if [[ "$DRY_RUN" == "false" ]]; then
                rm "$dup_file"
                print_info "Consolidated: $dup_file → $original"
            else
                print_info "[DRY-RUN] Would consolidate: $dup_file → $original"
            fi
            
            ((consolidated++))
        fi
    done
    
    print_success "Consolidated $consolidated exact duplicates"
    return 0
}

################################################################################
# Consolidate redundant pairs (STUB)
################################################################################
consolidate_redundant_pairs() {
    print_info "Redundant pair consolidation not yet implemented"
    print_warning "Manual review recommended for ${#REDUNDANT_PAIRS[@]} redundant pairs"
    return 0
}

################################################################################
# Prompt user to archive outdated files
################################################################################
prompt_archive_outdated() {
    if [[ ${#OUTDATED_FILES[@]} -eq 0 ]]; then
        return 0
    fi
    
    echo ""
    echo "Found ${#OUTDATED_FILES[@]} outdated files:"
    for file in "${OUTDATED_FILES[@]}"; do
        echo "  • $file"
    done
    echo ""
    
    read -p "Archive these outdated files? [y/N] " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        local archived=0
        for file in "${OUTDATED_FILES[@]}"; do
            local archive_path="$ARCHIVE_DIR/original/$(basename "$file")"
            cp "$file" "$archive_path"
            
            if [[ "$DRY_RUN" == "false" ]]; then
                rm "$file"
                print_info "Archived: $file"
            else
                print_info "[DRY-RUN] Would archive: $file"
            fi
            
            ((archived++))
        done
        
        print_success "Archived $archived outdated files"
    else
        print_info "Skipped archiving"
    fi
    
    return 0
}

# Export functions
export -f create_archive_directory
export -f consolidate_duplicates
export -f consolidate_redundant_pairs
export -f prompt_archive_outdated
