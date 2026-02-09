#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Documentation Section Extractor
# Purpose: Extract and replace specific sections in markdown files
# Version: 1.0.0
# Created: 2026-02-07
################################################################################

# ==============================================================================
# CLEANUP MANAGEMENT
# ==============================================================================

# Track temporary files for cleanup
declare -a DOC_EXTRACTOR_TEMP_FILES=()

# Register temp file for cleanup
track_doc_extractor_temp() {
    local temp_file="$1"
    [[ -n "$temp_file" ]] && DOC_EXTRACTOR_TEMP_FILES+=("$temp_file")
}

# Cleanup handler for doc section extractor
cleanup_doc_extractor_files() {
    local file
    for file in "${DOC_EXTRACTOR_TEMP_FILES[@]}"; do
        [[ -f "$file" ]] && rm -f "$file" 2>/dev/null
    done
    DOC_EXTRACTOR_TEMP_FILES=()
}

# ==============================================================================
# SECTION EXTRACTION
# ==============================================================================

# Extract specific section from markdown file
# Args: $1 - doc file path, $2 - section ID (e.g., "#configuration" or "configuration")
# Returns: Section content (without heading)
# Usage: content=$(extract_doc_section "docs/api/README.md" "#getting-started")
extract_doc_section() {
    local doc_file="$1"
    local section_id="${2#\#}"  # Remove leading # if present
    
    [[ ! -f "$doc_file" ]] && return 1
    
    # Normalize section_id to match markdown anchor format
    local normalized_id
    normalized_id=$(echo "$section_id" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//; s/-$//')
    
    # Extract section using awk
    awk -v section="$normalized_id" '
        BEGIN { found=0; level=0 }
        
        # Match heading and check if it matches our section
        /^#+[[:space:]]/ {
            # Get heading level and text
            match($0, /^(#+)[[:space:]]+(.+)$/, arr)
            heading_level = length(arr[1])
            heading_text = arr[2]
            
            # Normalize heading text to ID format
            gsub(/[^a-zA-Z0-9-]/, "-", heading_text)
            gsub(/--+/, "-", heading_text)
            gsub(/^-|-$/, "", heading_text)
            heading_text = tolower(heading_text)
            
            # Check if this is our section
            if (heading_text == section) {
                found = 1
                level = heading_level
                next  # Skip the heading itself
            }
            
            # If we found our section and hit same/higher level heading, stop
            if (found && heading_level <= level) {
                exit
            }
        }
        
        # Print content if we are in our section
        found { print }
    ' "$doc_file"
}

# Extract section with heading
# Args: $1 - doc file, $2 - section ID
# Returns: Section content including heading
extract_doc_section_with_heading() {
    local doc_file="$1"
    local section_id="${2#\#}"
    
    [[ ! -f "$doc_file" ]] && return 1
    
    local normalized_id
    normalized_id=$(echo "$section_id" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//; s/-$//')
    
    awk -v section="$normalized_id" '
        BEGIN { found=0; level=0 }
        
        /^#+[[:space:]]/ {
            match($0, /^(#+)[[:space:]]+(.+)$/, arr)
            heading_level = length(arr[1])
            heading_text = arr[2]
            
            gsub(/[^a-zA-Z0-9-]/, "-", heading_text)
            gsub(/--+/, "-", heading_text)
            gsub(/^-|-$/, "", heading_text)
            heading_text = tolower(heading_text)
            
            if (heading_text == section) {
                found = 1
                level = heading_level
                print  # Print the heading
                next
            }
            
            if (found && heading_level <= level) {
                exit
            }
        }
        
        found { print }
    ' "$doc_file"
}

# ==============================================================================
# SECTION REPLACEMENT
# ==============================================================================

# Replace specific section in markdown file
# Args: $1 - doc file, $2 - section ID, $3 - new content
# Returns: 0 on success, 1 on failure
# Usage: replace_doc_section "docs/api/README.md" "#configuration" "$new_content"
replace_doc_section() {
    local doc_file="$1"
    local section_id="${2#\#}"
    local new_content="$3"
    
    [[ ! -f "$doc_file" ]] && return 1
    
    # Create backup
    cp "$doc_file" "${doc_file}.section_backup"
    
    local normalized_id
    normalized_id=$(echo "$section_id" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//; s/-$//')
    
    # Create temp file with replacement
    local temp_file
    temp_file=$(mktemp)
    track_doc_extractor_temp "$temp_file"
    
    awk -v section="$normalized_id" -v content="$new_content" '
        BEGIN { found=0; level=0; replaced=0 }
        
        /^#+[[:space:]]/ {
            match($0, /^(#+)[[:space:]]+(.+)$/, arr)
            heading_level = length(arr[1])
            heading_text = arr[2]
            
            gsub(/[^a-zA-Z0-9-]/, "-", heading_text)
            gsub(/--+/, "-", heading_text)
            gsub(/^-|-$/, "", heading_text)
            heading_text = tolower(heading_text)
            
            # Found our section
            if (heading_text == section) {
                found = 1
                level = heading_level
                print  # Print the heading
                print content  # Insert new content
                print ""  # Blank line after content
                replaced = 1
                next
            }
            
            # End of our section - back to normal output
            if (found && heading_level <= level) {
                found = 0
            }
        }
        
        # Skip old content in our section
        !found { print }
        
    ' "$doc_file" > "$temp_file"
    
    # Replace original file
    if [[ -s "$temp_file" ]]; then
        mv "$temp_file" "$doc_file"
        rm -f "${doc_file}.section_backup"
        return 0
    else
        # Restore from backup on failure
        mv "${doc_file}.section_backup" "$doc_file"
        rm -f "$temp_file"
        return 1
    fi
}

# ==============================================================================
# SECTION VALIDATION
# ==============================================================================

# Check if section exists in document
# Args: $1 - doc file, $2 - section ID
# Returns: 0 if exists, 1 if not
section_exists() {
    local doc_file="$1"
    local section_id="${2#\#}"
    
    [[ ! -f "$doc_file" ]] && return 1
    
    local normalized_id
    normalized_id=$(echo "$section_id" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//; s/-$//')
    
    # Check if any heading matches
    while IFS= read -r heading; do
        local heading_id
        heading_id=$(echo "$heading" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//; s/-$//')
        
        [[ "$heading_id" == "$normalized_id" ]] && return 0
    done < <(grep -E '^##+ ' "$doc_file" | sed 's/^##*[[:space:]]*//')
    
    return 1
}

# Validate markdown structure after modification
# Args: $1 - doc file
# Returns: 0 if valid, 1 if corrupt
validate_doc_structure() {
    local doc_file="$1"
    
    [[ ! -f "$doc_file" ]] && return 1
    
    # Check for basic markdown validity
    # 1. No orphaned code block markers
    local code_blocks
    code_blocks=$(grep -c '```' "$doc_file" || echo "0")
    [[ $((code_blocks % 2)) -ne 0 ]] && return 1
    
    # 2. Headings are properly formed
    local malformed_headings
    malformed_headings=$(grep -cE '^#[^#[:space:]]' "$doc_file" || echo "0")
    [[ $malformed_headings -gt 0 ]] && return 1
    
    # 3. File is not empty
    [[ ! -s "$doc_file" ]] && return 1
    
    return 0
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# Get section heading level
# Args: $1 - doc file, $2 - section ID
# Returns: Heading level (2-6) or 0 if not found
get_section_level() {
    local doc_file="$1"
    local section_id="${2#\#}"
    
    [[ ! -f "$doc_file" ]] && echo "0" && return 1
    
    local normalized_id
    normalized_id=$(echo "$section_id" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//; s/-$//')
    
    while IFS= read -r line; do
        # Get heading level
        local level
        level=$(echo "$line" | grep -oE '^#+' | wc -c)
        level=$((level - 1))
        
        # Get heading text and normalize
        local heading_text
        heading_text=$(echo "$line" | sed 's/^##*[[:space:]]*//')
        local heading_id
        heading_id=$(echo "$heading_text" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//; s/-$//')
        
        [[ "$heading_id" == "$normalized_id" ]] && echo "$level" && return 0
    done < <(grep -E '^##+ ' "$doc_file")
    
    echo "0"
    return 1
}

# Export functions for testing
export -f extract_doc_section
export -f extract_doc_section_with_heading
export -f replace_doc_section
export -f section_exists
export -f validate_doc_structure
export -f get_section_level
export -f track_doc_extractor_temp
export -f cleanup_doc_extractor_files

# ==============================================================================
# CLEANUP TRAP
# ==============================================================================

# Ensure cleanup runs on exit
trap cleanup_doc_extractor_files EXIT INT TERM

################################################################################
# Documentation Section Extractor - Complete
################################################################################
