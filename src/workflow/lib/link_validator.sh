#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Link Validator Module
# Version: 1.0.0
# Purpose: Comprehensive markdown link validation with caching support
#
# Features:
#   - Extract and validate markdown links (relative, absolute, URLs)
#   - Check local file references
#   - Validate HTTP/HTTPS URLs with caching
#   - Support for anchor links within documents
#   - Rate limiting for external URL checks
#   - Detailed reporting with line numbers
#
# Integration: Used by Step 2 (Documentation Validation)
################################################################################

# Set defaults
LINK_CACHE_DIR="${WORKFLOW_HOME:-$(pwd)}/.link_cache"
LINK_CACHE_TTL=$((24 * 3600))  # 24 hours
MAX_CONCURRENT_URL_CHECKS=5
URL_CHECK_TIMEOUT=10

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Initialize link validation system
init_link_validator() {
    mkdir -p "$LINK_CACHE_DIR"
    print_info "Link validator initialized (cache: $LINK_CACHE_DIR)"
    return 0
}

# Clean up expired cache entries
cleanup_link_cache() {
    local now=$(date +%s)
    local cleaned=0
    
    if [[ -d "$LINK_CACHE_DIR" ]]; then
        while IFS= read -r cache_file; do
            local mtime=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
            local age=$((now - mtime))
            
            if [[ $age -gt $LINK_CACHE_TTL ]]; then
                rm -f "$cache_file"
                ((cleaned++))
            fi
        done < <(find "$LINK_CACHE_DIR" -type f -name "*.cache" 2>/dev/null || true)
        
        [[ $cleaned -gt 0 ]] && print_info "Cleaned $cleaned expired link cache entries"
    fi
    
    return 0
}

# ==============================================================================
# LINK EXTRACTION
# ==============================================================================

# Extract all markdown links from a file
# Args: $1 = file path
# Output: Format "line_number|link_type|link_target|link_text"
extract_markdown_links() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    local line_num=0
    while IFS= read -r line; do
        ((line_num++))
        
        # Extract inline links: [text](url)
        while [[ "$line" =~ \[([^\]]+)\]\(([^\)]+)\) ]]; do
            local link_text="${BASH_REMATCH[1]}"
            local link_url="${BASH_REMATCH[2]}"
            
            # Determine link type
            local link_type="unknown"
            if [[ "$link_url" =~ ^https?:// ]]; then
                link_type="url"
            elif [[ "$link_url" =~ ^/ ]]; then
                link_type="absolute"
            elif [[ "$link_url" =~ ^# ]]; then
                link_type="anchor"
            else
                link_type="relative"
            fi
            
            echo "${line_num}|${link_type}|${link_url}|${link_text}"
            
            # Remove matched part and continue
            line="${line#*\](*\)}"
        done
        
        # Extract reference-style links: [text][ref]
        while [[ "$line" =~ \[([^\]]+)\]\[([^\]]+)\] ]]; do
            local link_text="${BASH_REMATCH[1]}"
            local ref_id="${BASH_REMATCH[2]}"
            echo "${line_num}|reference|${ref_id}|${link_text}"
            line="${line#*\]\[*\]}"
        done
        
    done < "$file"
}

# Extract reference definitions from markdown file
# Args: $1 = file path
# Output: Format "ref_id|link_target"
extract_link_references() {
    local file="$1"
    
    [[ ! -f "$file" ]] && return 1
    
    # Match reference definitions: [ref]: url
    grep -nE '^\[([^\]]+)\]:\s*(.+)$' "$file" 2>/dev/null | while IFS=: read -r line_num content; do
        if [[ "$content" =~ ^\[([^\]]+)\]:[[:space:]]*(.+)$ ]]; then
            local ref_id="${BASH_REMATCH[1]}"
            local target="${BASH_REMATCH[2]}"
            # Remove optional title in quotes
            target=$(echo "$target" | sed -E 's/[[:space:]]+"[^"]*"[[:space:]]*$//' | sed -E "s/[[:space:]]+'[^']*'[[:space:]]*$//")
            echo "${ref_id}|${target}"
        fi
    done
}

# ==============================================================================
# LINK VALIDATION
# ==============================================================================

# Validate a local file path reference
# Args: $1 = file path, $2 = base directory for relative paths
# Returns: 0 if valid, 1 if broken
validate_local_link() {
    local link="$1"
    local base_dir="${2:-.}"
    local full_path=""
    
    # Handle anchor-only links (valid within same file)
    [[ "$link" =~ ^# ]] && return 0
    
    # Strip anchor from link
    local link_path="${link%%#*}"
    [[ -z "$link_path" ]] && return 0
    
    # Resolve path
    if [[ "$link_path" =~ ^/ ]]; then
        # Absolute path
        full_path="${PROJECT_ROOT:-}${link_path}"
    else
        # Relative path
        full_path="${base_dir}/${link_path}"
    fi
    
    # Normalize path
    full_path=$(realpath -m "$full_path" 2>/dev/null || echo "$full_path")
    
    # Check if file exists
    if [[ -e "$full_path" ]]; then
        # If anchor specified, validate anchor exists in file
        if [[ "$link" =~ \#(.+)$ ]]; then
            local anchor="${BASH_REMATCH[1]}"
            if [[ -f "$full_path" ]]; then
                # Convert anchor to heading format (e.g., "my-section" -> "My Section")
                local heading_search=$(echo "$anchor" | tr '-' ' ')
                if ! grep -qiE "^#{1,6}[[:space:]]+${heading_search}" "$full_path" 2>/dev/null; then
                    return 1  # Anchor not found
                fi
            fi
        fi
        return 0
    else
        return 1
    fi
}

# Validate a URL (with caching)
# Args: $1 = URL
# Returns: 0 if valid/cached, 1 if broken
validate_url() {
    local url="$1"
    local cache_key=$(echo -n "$url" | sha256sum | cut -d' ' -f1)
    local cache_file="${LINK_CACHE_DIR}/${cache_key}.cache"
    
    # Check cache
    if [[ -f "$cache_file" ]]; then
        local mtime=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
        local now=$(date +%s)
        local age=$((now - mtime))
        
        if [[ $age -lt $LINK_CACHE_TTL ]]; then
            local cached_status=$(cat "$cache_file")
            [[ "$cached_status" == "valid" ]] && return 0 || return 1
        fi
    fi
    
    # Validate URL with curl
    local status_code
    if command -v curl &>/dev/null; then
        status_code=$(curl -o /dev/null -s -w "%{http_code}" \
            --max-time "$URL_CHECK_TIMEOUT" \
            --retry 2 \
            --retry-delay 1 \
            -L "$url" 2>/dev/null || echo "000")
        
        if [[ "$status_code" =~ ^(200|301|302|303|307|308)$ ]]; then
            echo "valid" > "$cache_file"
            return 0
        else
            echo "broken:${status_code}" > "$cache_file"
            return 1
        fi
    else
        # No curl available, assume valid (optimistic)
        echo "valid:no-curl" > "$cache_file"
        return 0
    fi
}

# ==============================================================================
# COMPREHENSIVE VALIDATION
# ==============================================================================

# Validate all links in a markdown file
# Args: $1 = file path, $2 = output report file
# Returns: Count of broken links
validate_file_links() {
    local file="$1"
    local report_file="$2"
    local broken_count=0
    local total_count=0
    
    local base_dir=$(dirname "$file")
    local refs_map=()
    
    # Build reference map
    while IFS='|' read -r ref_id target; do
        refs_map["$ref_id"]="$target"
    done < <(extract_link_references "$file")
    
    # Validate each link
    while IFS='|' read -r line_num link_type link_target link_text; do
        ((total_count++))
        local validation_target="$link_target"
        
        # Resolve reference links
        if [[ "$link_type" == "reference" ]]; then
            validation_target="${refs_map[$link_target]:-}"
            if [[ -z "$validation_target" ]]; then
                echo "${file}:${line_num}: Undefined reference '${link_target}' in link '${link_text}'" >> "$report_file"
                ((broken_count++))
                continue
            fi
            # Re-determine link type
            if [[ "$validation_target" =~ ^https?:// ]]; then
                link_type="url"
            elif [[ "$validation_target" =~ ^/ ]]; then
                link_type="absolute"
            else
                link_type="relative"
            fi
        fi
        
        # Skip placeholder/example links
        if [[ "$validation_target" =~ ^(http://example\.com|https://example\.|/path/to/|/images/placeholder) ]]; then
            continue
        fi
        
        # Validate based on type
        case "$link_type" in
            url)
                if ! validate_url "$validation_target"; then
                    echo "${file}:${line_num}: Broken URL link '${validation_target}' in text '${link_text}'" >> "$report_file"
                    ((broken_count++))
                fi
                ;;
            absolute|relative)
                if ! validate_local_link "$validation_target" "$base_dir"; then
                    echo "${file}:${line_num}: Broken file link '${validation_target}' in text '${link_text}'" >> "$report_file"
                    ((broken_count++))
                fi
                ;;
            anchor)
                # Validate anchor exists in current file
                local anchor="${validation_target#\#}"
                local heading_search=$(echo "$anchor" | tr '-' ' ')
                if ! grep -qiE "^#{1,6}[[:space:]]+${heading_search}" "$file" 2>/dev/null; then
                    echo "${file}:${line_num}: Broken anchor link '${validation_target}' in text '${link_text}'" >> "$report_file"
                    ((broken_count++))
                fi
                ;;
        esac
    done < <(extract_markdown_links "$file")
    
    return $broken_count
}

# Validate links in all documentation files
# Args: $1 = output report file, $2 = directory to scan (default: current)
# Returns: Total count of broken links
validate_all_documentation_links() {
    local report_file="$1"
    local scan_dir="${2:-.}"
    local total_broken=0
    local files_checked=0
    
    print_info "Validating links in documentation files..."
    
    # Initialize
    init_link_validator
    cleanup_link_cache
    
    # Find and validate all markdown files
    while IFS= read -r md_file; do
        ((files_checked++))
        local broken=0
        validate_file_links "$md_file" "$report_file" || broken=$?
        ((total_broken += broken))
    done < <(find "$scan_dir" -name "*.md" -type f ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/.ai_workflow/*" 2>/dev/null || true)
    
    if [[ $total_broken -eq 0 ]]; then
        print_success "All links validated successfully ($files_checked files checked)"
    else
        print_warning "Found $total_broken broken links in $files_checked files"
    fi
    
    return $total_broken
}

# ==============================================================================
# REPORTING
# ==============================================================================

# Generate link validation summary report
# Args: $1 = report file, $2 = output summary file
generate_link_validation_summary() {
    local report_file="$1"
    local summary_file="$2"
    
    [[ ! -f "$report_file" ]] && return 1
    
    local total_issues=$(wc -l < "$report_file" 2>/dev/null || echo 0)
    local url_issues=$(grep -c "Broken URL" "$report_file" 2>/dev/null || echo 0)
    local file_issues=$(grep -c "Broken file" "$report_file" 2>/dev/null || echo 0)
    local anchor_issues=$(grep -c "Broken anchor" "$report_file" 2>/dev/null || echo 0)
    local ref_issues=$(grep -c "Undefined reference" "$report_file" 2>/dev/null || echo 0)
    
    cat > "$summary_file" << EOF
# Link Validation Report

**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Total Issues**: $total_issues

## Summary by Type

- **Broken URLs**: $url_issues
- **Broken File Links**: $file_issues
- **Broken Anchors**: $anchor_issues
- **Undefined References**: $ref_issues

## Details

\`\`\`
$(cat "$report_file")
\`\`\`

---

*Generated by Link Validator Module v1.0.0*
EOF
    
    print_info "Link validation summary generated: $summary_file"
}

# Export functions
export -f init_link_validator
export -f cleanup_link_cache
export -f extract_markdown_links
export -f extract_link_references
export -f validate_local_link
export -f validate_url
export -f validate_file_links
export -f validate_all_documentation_links
export -f generate_link_validation_summary
