#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 1 Incremental Processing Module
# Purpose: File-level change detection with hash-based caching for documentation
# Part of: Step 1 Optimization - Phase 1
# Version: 1.0.0
################################################################################

# Get script directory
STEP1_INCR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Hash cache file location (in AI cache directory)
DOC_HASH_CACHE_FILE="${AI_CACHE_DIR:-${WORKFLOW_HOME:-/tmp}/src/workflow/.ai_cache}/doc_hashes.json"

# ==============================================================================
# FILE HASH CALCULATION
# ==============================================================================

# Calculate SHA256 hash for a file
# Usage: calculate_file_hash <file_path>
# Returns: Hash string or empty on error
calculate_file_hash() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        return 1
    fi
    
    # Use sha256sum for consistent hashing
    sha256sum "$file_path" 2>/dev/null | awk '{print $1}' || echo ""
}

# Calculate hash for multiple files efficiently
# Usage: calculate_file_hashes <file1> [file2] [...]
# Returns: JSON object with file->hash mappings
calculate_file_hashes() {
    local files=("$@")
    local json_entries=()
    
    for file in "${files[@]}"; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue
        
        local hash
        hash=$(calculate_file_hash "$file")
        
        if [[ -n "$hash" ]]; then
            local size
            size=$(stat -c%s "$file" 2>/dev/null || echo "0")
            local mtime
            mtime=$(stat -c%Y "$file" 2>/dev/null || echo "0")
            
            # Escape file path for JSON
            local escaped_file
            escaped_file=$(echo "$file" | sed 's/"/\\"/g')
            
            json_entries+=("\"${escaped_file}\": {\"hash\": \"${hash}\", \"size\": ${size}, \"mtime\": ${mtime}}")
        fi
    done
    
    # Build JSON object
    if [[ ${#json_entries[@]} -gt 0 ]]; then
        echo "{$(IFS=,; echo "${json_entries[*]}")}"
    else
        echo "{}"
    fi
}

# ==============================================================================
# HASH CACHE MANAGEMENT
# ==============================================================================

# Initialize hash cache file if not exists
# Usage: init_doc_hash_cache
# Returns: 0 on success
init_doc_hash_cache() {
    # Ensure cache directory exists
    local cache_dir
    cache_dir=$(dirname "$DOC_HASH_CACHE_FILE")
    mkdir -p "$cache_dir"
    
    # Create cache file if it doesn't exist
    if [[ ! -f "$DOC_HASH_CACHE_FILE" ]]; then
        cat > "$DOC_HASH_CACHE_FILE" << 'EOF'
{
  "version": "1.0.0",
  "last_updated": "",
  "files": {}
}
EOF
        # Set initial timestamp
        local now
        now=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)
        
        # Use jq if available, otherwise sed
        if command -v jq &>/dev/null; then
            jq --arg now "$now" '.last_updated = $now' "$DOC_HASH_CACHE_FILE" > "${DOC_HASH_CACHE_FILE}.tmp"
            mv "${DOC_HASH_CACHE_FILE}.tmp" "$DOC_HASH_CACHE_FILE"
        else
            sed -i "s/\"last_updated\": \"\"/\"last_updated\": \"${now}\"/" "$DOC_HASH_CACHE_FILE"
        fi
    fi
    
    return 0
}

# Load cached file hashes
# Usage: load_doc_hash_cache
# Returns: JSON object with cached hashes
load_doc_hash_cache() {
    init_doc_hash_cache
    
    if [[ -f "$DOC_HASH_CACHE_FILE" ]]; then
        cat "$DOC_HASH_CACHE_FILE"
    else
        echo '{"version":"1.0.0","last_updated":"","files":{}}'
    fi
}

# Get cached hash for a specific file
# Usage: get_cached_doc_hash <file_path>
# Returns: Hash string or empty if not cached
get_cached_doc_hash() {
    local file_path="$1"
    
    if [[ ! -f "$DOC_HASH_CACHE_FILE" ]]; then
        return 1
    fi
    
    # Escape file path for jq query
    local escaped_file
    escaped_file=$(echo "$file_path" | sed 's/"/\\"/g')
    
    if command -v jq &>/dev/null; then
        jq -r --arg file "$escaped_file" '.files[$file].hash // empty' "$DOC_HASH_CACHE_FILE" 2>/dev/null || echo ""
    else
        # Fallback to grep/sed if jq not available
        grep -A1 "\"${escaped_file}\"" "$DOC_HASH_CACHE_FILE" 2>/dev/null | grep '"hash"' | sed 's/.*"hash": "\([^"]*\)".*/\1/' || echo ""
    fi
}

# Save file hashes to cache
# Usage: save_doc_hash_cache <files_json>
# Args: JSON object with file->hash mappings
# Returns: 0 on success
save_doc_hash_cache() {
    local files_json="$1"
    
    # Validate input JSON
    if [[ -z "$files_json" ]] || [[ "$files_json" == "null" ]]; then
        files_json="{}"
    fi
    
    # Validate JSON syntax if jq available
    if command -v jq &>/dev/null; then
        if ! echo "$files_json" | jq empty 2>/dev/null; then
            echo "Warning: Invalid JSON passed to save_doc_hash_cache, using empty object" >&2
            files_json="{}"
        fi
    fi
    
    init_doc_hash_cache
    
    local now
    now=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)
    
    if command -v jq &>/dev/null; then
        # Log jq arguments for debugging
        if [[ "${DEBUG:-false}" == "true" ]] || [[ "${WORKFLOW_LOG_FILE:-}" != "" ]]; then
            {
                echo "[DEBUG] save_doc_hash_cache jq arguments:"
                echo "  now=${now}"
                echo "  files_json (first 200 chars)=${files_json:0:200}..."
            } >> "${WORKFLOW_LOG_FILE:-/dev/null}" 2>/dev/null
        fi
        
        # Use jq for proper JSON merging
        jq --arg now "$now" --argjson files "$files_json" \
           '.last_updated = $now | .files = (.files + $files)' \
           "$DOC_HASH_CACHE_FILE" > "${DOC_HASH_CACHE_FILE}.tmp"
        mv "${DOC_HASH_CACHE_FILE}.tmp" "$DOC_HASH_CACHE_FILE"
    else
        # Fallback: simple replacement (less safe but works for basic cases)
        local temp_file="${DOC_HASH_CACHE_FILE}.tmp"
        {
            echo "{"
            echo "  \"version\": \"1.0.0\","
            echo "  \"last_updated\": \"${now}\","
            echo "  \"files\": ${files_json}"
            echo "}"
        } > "$temp_file"
        mv "$temp_file" "$DOC_HASH_CACHE_FILE"
    fi
    
    return 0
}

# ==============================================================================
# CHANGE DETECTION
# ==============================================================================

# Detect which documentation files have changed since last run
# Usage: detect_changed_docs <file1> [file2] [...]
# Returns: List of changed files (newline-separated)
detect_changed_docs() {
    local files=("$@")
    local changed_files=()
    
    # If cache disabled or doesn't exist, all files are "changed"
    if [[ "${USE_AI_CACHE:-true}" != "true" ]] || [[ ! -f "$DOC_HASH_CACHE_FILE" ]]; then
        printf '%s\n' "${files[@]}"
        return 0
    fi
    
    for file in "${files[@]}"; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue
        
        # Calculate current hash
        local current_hash
        current_hash=$(calculate_file_hash "$file")
        [[ -z "$current_hash" ]] && continue
        
        # Get cached hash
        local cached_hash
        cached_hash=$(get_cached_doc_hash "$file")
        
        # If no cached hash or hash mismatch, file has changed
        if [[ -z "$cached_hash" ]] || [[ "$cached_hash" != "$current_hash" ]]; then
            changed_files+=("$file")
        fi
    done
    
    # Return changed files
    printf '%s\n' "${changed_files[@]}"
}

# Detect changed docs and update cache
# Usage: detect_and_cache_changed_docs <file1> [file2] [...]
# Returns: List of changed files + updates cache
detect_and_cache_changed_docs() {
    local files=("$@")
    
    # Detect changes
    local changed_files
    changed_files=$(detect_changed_docs "${files[@]}")
    
    # Calculate hashes for all files (for caching)
    local all_hashes
    all_hashes=$(calculate_file_hashes "${files[@]}")
    
    # Update cache
    if [[ -n "$all_hashes" ]] && [[ "$all_hashes" != "{}" ]]; then
        save_doc_hash_cache "$all_hashes"
    fi
    
    # Return changed files
    echo "$changed_files"
}

# Get statistics about cached vs changed files
# Usage: get_doc_cache_stats <file1> [file2] [...]
# Returns: JSON with stats
get_doc_cache_stats() {
    local files=("$@")
    local total=${#files[@]}
    local cached=0
    local changed=0
    local new=0
    
    for file in "${files[@]}"; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue
        
        local cached_hash
        cached_hash=$(get_cached_doc_hash "$file")
        
        if [[ -n "$cached_hash" ]]; then
            ((cached++))
            
            local current_hash
            current_hash=$(calculate_file_hash "$file")
            
            if [[ "$cached_hash" != "$current_hash" ]]; then
                ((changed++))
            fi
        else
            ((new++))
        fi
    done
    
    local unchanged=$((cached - changed))
    
    echo "{\"total\": $total, \"cached\": $cached, \"changed\": $changed, \"new\": $new, \"unchanged\": $unchanged}"
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f calculate_file_hash
export -f calculate_file_hashes
export -f init_doc_hash_cache
export -f load_doc_hash_cache
export -f get_cached_doc_hash
export -f save_doc_hash_cache
export -f detect_changed_docs
export -f detect_and_cache_changed_docs
export -f get_doc_cache_stats
