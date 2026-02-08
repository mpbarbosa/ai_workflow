#!/usr/bin/env bash
#
# Heuristics Engine for Documentation Optimization
# Implements fast, local similarity detection without AI
#
# Functions:
# - SHA256-based exact duplicate detection
# - Levenshtein distance for title similarity
# - Content similarity scoring (word overlap)
# - Structural pattern matching
#

set -euo pipefail

################################################################################
# Calculate SHA256 hash of file content
# Arguments:
#   $1 - File path
# Returns:
#   SHA256 hash string
################################################################################
calculate_file_hash() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    sha256sum "$file" | awk '{print $1}'
}

################################################################################
# Find exact duplicate files using SHA256 hashing
# Populates global EXACT_DUPLICATES array and DOC_HASHES map
################################################################################
find_exact_duplicates() {
    local -A hash_to_files
    local file hash
    
    print_info "Scanning for exact duplicates..."
    
    # Calculate hashes for all markdown files
    while IFS= read -r file; do
        # Skip excluded patterns
        if should_exclude_file "$file"; then
            continue
        fi
        
        hash=$(calculate_file_hash "$file")
        DOC_HASHES["$file"]="$hash"
        
        # Track files by hash
        if [[ -n "${hash_to_files[$hash]:-}" ]]; then
            hash_to_files["$hash"]+=" $file"
        else
            hash_to_files["$hash"]="$file"
        fi
    done < <(find "$DOCS_DIR" -name "*.md" -type f)
    
    # Find duplicates (hashes with multiple files)
    local dup_count=0
    for hash in "${!hash_to_files[@]}"; do
        local files=(${hash_to_files[$hash]})
        
        if [[ ${#files[@]} -gt 1 ]]; then
            # Keep first file, mark others as duplicates
            for ((i=1; i<${#files[@]}; i++)); do
                EXACT_DUPLICATES+=("${files[$i]}")
                ((dup_count++))
            done
            
            print_debug "Found duplicate set (${#files[@]} files):"
            for f in "${files[@]}"; do
                print_debug "  - $f"
            done
        fi
    done
    
    print_success "Found $dup_count exact duplicates"
    return 0
}

################################################################################
# Calculate Levenshtein distance between two strings
# Arguments:
#   $1 - String 1
#   $2 - String 2
# Returns:
#   Distance value (0 = identical)
################################################################################
levenshtein_distance() {
    local str1="$1"
    local str2="$2"
    local len1=${#str1}
    local len2=${#str2}
    
    # Handle empty strings
    [[ $len1 -eq 0 ]] && echo "$len2" && return
    [[ $len2 -eq 0 ]] && echo "$len1" && return
    
    # For bash implementation, use simplified algorithm for short strings
    # For longer strings, approximate based on character differences
    if [[ $len1 -gt 50 ]] || [[ $len2 -gt 50 ]]; then
        # Simplified: count character differences
        local diff=0
        local max_len=$len1
        [[ $len2 -gt $max_len ]] && max_len=$len2
        
        # Character-by-character comparison
        for ((i=0; i<max_len; i++)); do
            if [[ "${str1:$i:1}" != "${str2:$i:1}" ]]; then
                ((diff++))
            fi
        done
        
        echo "$diff"
    else
        # For short strings, use more accurate method
        # This is a simplified version - full LD algorithm is complex in bash
        local common=0
        local i j
        
        for ((i=0; i<len1; i++)); do
            for ((j=0; j<len2; j++)); do
                if [[ "${str1:$i:1}" == "${str2:$j:1}" ]]; then
                    ((common++))
                    break
                fi
            done
        done
        
        local max_len=$len1
        [[ $len2 -gt $max_len ]] && max_len=$len2
        
        echo $((max_len - common))
    fi
}

################################################################################
# Calculate title similarity between two files
# Arguments:
#   $1 - File path 1
#   $2 - File path 2
# Returns:
#   Similarity score (0.0 to 1.0)
################################################################################
calculate_title_similarity() {
    local file1="$1"
    local file2="$2"
    
    # Extract titles (first H1 or filename)
    local title1
    local title2
    
    title1=$(extract_document_title "$file1")
    title2=$(extract_document_title "$file2")
    
    # Normalize titles (lowercase, remove special chars)
    title1=$(echo "$title1" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:] ')
    title2=$(echo "$title2" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:] ')
    
    # Calculate similarity
    local distance
    distance=$(levenshtein_distance "$title1" "$title2")
    
    local max_len=${#title1}
    [[ ${#title2} -gt $max_len ]] && max_len=${#title2}
    
    # Avoid division by zero
    [[ $max_len -eq 0 ]] && echo "0.0" && return
    
    # Similarity = 1 - (distance / max_length)
    local similarity
    similarity=$(awk -v d="$distance" -v m="$max_len" 'BEGIN {printf "%.2f", 1 - (d/m)}')
    
    echo "$similarity"
}

################################################################################
# Extract document title from markdown file
# Arguments:
#   $1 - File path
# Returns:
#   Title string
################################################################################
extract_document_title() {
    local file="$1"
    
    # Try to find H1 heading (# Title)
    local title
    title=$(grep -m 1 '^# ' "$file" 2>/dev/null | sed 's/^# //' || true)
    
    # Fallback to filename without extension
    if [[ -z "$title" ]]; then
        title=$(basename "$file" .md)
    fi
    
    echo "$title"
}

################################################################################
# Calculate content similarity using word overlap
# Arguments:
#   $1 - File path 1
#   $2 - File path 2
# Returns:
#   Similarity score (0.0 to 1.0)
################################################################################
calculate_content_similarity() {
    local file1="$1"
    local file2="$2"
    
    # Extract words (alphanumeric tokens)
    local words1
    local words2
    
    words1=$(extract_significant_words "$file1")
    words2=$(extract_significant_words "$file2")
    
    # Calculate Jaccard similarity (intersection / union)
    local common_words
    common_words=$(comm -12 <(echo "$words1" | sort -u) <(echo "$words2" | sort -u) | wc -l)
    
    local total_words
    total_words=$(cat <(echo "$words1") <(echo "$words2") | sort -u | wc -l)
    
    # Avoid division by zero
    [[ $total_words -eq 0 ]] && echo "0.0" && return
    
    # Similarity = intersection / union
    local similarity
    similarity=$(awk -v c="$common_words" -v t="$total_words" 'BEGIN {printf "%.2f", c/t}')
    
    echo "$similarity"
}

################################################################################
# Extract significant words from document
# Arguments:
#   $1 - File path
# Returns:
#   Newline-separated list of words
################################################################################
extract_significant_words() {
    local file="$1"
    
    # Extract alphanumeric words, filter common words, normalize
    grep -oE '\b[a-zA-Z]{4,}\b' "$file" 2>/dev/null | \
        tr '[:upper:]' '[:lower:]' | \
        grep -vE '^(the|and|for|are|but|not|you|all|can|has|was|were|been|have|this|that|with|from|they|what|their|would|make|like|time|just|know|take|people|into|year|your|some|could|them|than|other|then|its|only|over|also|back|after|work|first|well|even|want|because|these|give|most)$' | \
        sort -u
}

################################################################################
# Calculate size similarity between files
# Arguments:
#   $1 - File path 1
#   $2 - File path 2
# Returns:
#   Similarity score (0.0 to 1.0)
################################################################################
calculate_size_similarity() {
    local file1="$1"
    local file2="$2"
    
    local size1
    local size2
    
    size1=$(wc -c < "$file1")
    size2=$(wc -c < "$file2")
    
    # Calculate ratio (smaller / larger)
    local min_size=$size1
    local max_size=$size2
    
    if [[ $size1 -gt $size2 ]]; then
        min_size=$size2
        max_size=$size1
    fi
    
    # Avoid division by zero
    [[ $max_size -eq 0 ]] && echo "0.0" && return
    
    local similarity
    similarity=$(awk -v m="$min_size" -v M="$max_size" 'BEGIN {printf "%.2f", m/M}')
    
    echo "$similarity"
}

################################################################################
# Calculate combined similarity score
# Arguments:
#   $1 - File path 1
#   $2 - File path 2
# Returns:
#   Combined similarity score (0.0 to 1.0)
################################################################################
calculate_combined_similarity() {
    local file1="$1"
    local file2="$2"
    
    # Skip if files are identical (already handled as exact duplicates)
    local hash1="${DOC_HASHES[$file1]:-}"
    local hash2="${DOC_HASHES[$file2]:-}"
    
    if [[ -n "$hash1" ]] && [[ "$hash1" == "$hash2" ]]; then
        echo "1.00"
        return
    fi
    
    # Calculate individual similarity metrics
    local title_sim
    local content_sim
    local size_sim
    
    title_sim=$(calculate_title_similarity "$file1" "$file2")
    content_sim=$(calculate_content_similarity "$file1" "$file2")
    size_sim=$(calculate_size_similarity "$file1" "$file2")
    
    # Weighted average: title (20%), content (60%), size (20%)
    local combined
    combined=$(awk -v t="$title_sim" -v c="$content_sim" -v s="$size_sim" \
        'BEGIN {printf "%.2f", (t*0.2 + c*0.6 + s*0.2)}')
    
    echo "$combined"
}

################################################################################
# Find redundant document pairs above similarity threshold
# Populates global REDUNDANT_PAIRS array
################################################################################
find_redundant_pairs() {
    local threshold="${DEFAULT_SIMILARITY_THRESHOLD}"
    local file1 file2 similarity
    
    print_info "Analyzing document similarity (threshold: $threshold)..."
    
    # Get list of all documentation files (excluding exact duplicates)
    local -a doc_files
    while IFS= read -r file; do
        if should_exclude_file "$file"; then
            continue
        fi
        
        # Skip if already marked as exact duplicate
        local is_duplicate=false
        for dup in "${EXACT_DUPLICATES[@]}"; do
            if [[ "$file" == "$dup" ]]; then
                is_duplicate=true
                break
            fi
        done
        
        [[ "$is_duplicate" == "true" ]] && continue
        
        doc_files+=("$file")
    done < <(find "$DOCS_DIR" -name "*.md" -type f)
    
    # Compare all pairs
    local total_comparisons=$(( ${#doc_files[@]} * (${#doc_files[@]} - 1) / 2 ))
    local comparison_count=0
    
    for ((i=0; i<${#doc_files[@]}-1; i++)); do
        file1="${doc_files[$i]}"
        
        for ((j=i+1; j<${#doc_files[@]}; j++)); do
            file2="${doc_files[$j]}"
            ((comparison_count++))
            
            # Show progress every 50 comparisons
            if [[ $((comparison_count % 50)) -eq 0 ]]; then
                print_debug "Progress: $comparison_count/$total_comparisons comparisons"
            fi
            
            # Calculate similarity
            similarity=$(calculate_combined_similarity "$file1" "$file2")
            
            # Store similarity score
            DOC_SIMILARITIES["$file1|$file2"]="$similarity"
            
            # Check if above threshold
            if (( $(awk -v s="$similarity" -v t="$threshold" 'BEGIN {print (s >= t)}') )); then
                REDUNDANT_PAIRS+=("$file1|$file2|$similarity")
                print_debug "Found redundant pair (similarity: $similarity):"
                print_debug "  $file1"
                print_debug "  $file2"
            fi
        done
    done
    
    print_success "Found ${#REDUNDANT_PAIRS[@]} redundant document pairs"
    return 0
}

################################################################################
# Check if file should be excluded from analysis
# Arguments:
#   $1 - File path
# Returns:
#   0 if should exclude, 1 if should include
################################################################################
should_exclude_file() {
    local file="$1"
    local basename
    basename=$(basename "$file")
    
    # Check against exclude patterns
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        case "$basename" in
            $pattern) return 0 ;;
        esac
    done
    
    # Check if in archive directory
    if [[ "$file" == *"/.archive/"* ]]; then
        return 0
    fi
    
    return 1
}

################################################################################
# Main heuristics analysis entry point
# Called from main step
################################################################################
analyze_documentation_heuristics() {
    # Find exact duplicates
    if ! find_exact_duplicates; then
        print_error "Exact duplicate detection failed"
        return 1
    fi
    
    # Find redundant pairs
    if ! find_redundant_pairs; then
        print_error "Redundancy detection failed"
        return 1
    fi
    
    print_success "Heuristics analysis complete"
    return 0
}

# Export functions
export -f calculate_file_hash
export -f find_exact_duplicates
export -f levenshtein_distance
export -f calculate_title_similarity
export -f extract_document_title
export -f calculate_content_similarity
export -f extract_significant_words
export -f calculate_size_similarity
export -f calculate_combined_similarity
export -f find_redundant_pairs
export -f should_exclude_file
export -f analyze_documentation_heuristics
