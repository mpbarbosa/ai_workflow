#!/bin/bash
set -euo pipefail

################################################################################
# Advanced Analysis Caching Module
# Version: 2.7.1
# Purpose: Cache analysis results for unchanged files to speed up subsequent runs
#
# Features:
#   - Content-based cache keys (SHA256 hashes)
#   - Multi-level caching (file, directory, tree)
#   - Automatic cache invalidation
#   - Cache statistics and reporting
#   - TTL-based expiration (configurable)
#
# Performance Target: 3-5x faster for subsequent runs
################################################################################

# Set defaults for required variables
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}
ANALYSIS_CACHE_DIR="${WORKFLOW_HOME}/src/workflow/.analysis_cache"
ANALYSIS_CACHE_INDEX="${ANALYSIS_CACHE_DIR}/index.json"
ANALYSIS_CACHE_TTL=86400  # 24 hours
ANALYSIS_CACHE_MAX_SIZE_MB=200  # Maximum cache size

# ==============================================================================
# CLEANUP MANAGEMENT
# ==============================================================================

# Track temporary files for cleanup
declare -a ANALYSIS_CACHE_TEMP_FILES=()

# Register temp file for cleanup
track_analysis_cache_temp() {
    local temp_file="$1"
    [[ -n "$temp_file" ]] && ANALYSIS_CACHE_TEMP_FILES+=("$temp_file")
}

# Cleanup handler for analysis cache
cleanup_analysis_cache_files() {
    local file
    for file in "${ANALYSIS_CACHE_TEMP_FILES[@]}"; do
        [[ -f "$file" ]] && rm -f "$file" 2>/dev/null
    done
    ANALYSIS_CACHE_TEMP_FILES=()
}

# ==============================================================================
# CACHE INITIALIZATION
# ==============================================================================

# Initialize analysis cache
init_analysis_cache() {
    mkdir -p "${ANALYSIS_CACHE_DIR}"
    
    # Create subdirectories for different cache types
    mkdir -p "${ANALYSIS_CACHE_DIR}/docs"
    mkdir -p "${ANALYSIS_CACHE_DIR}/scripts"
    mkdir -p "${ANALYSIS_CACHE_DIR}/directory"
    mkdir -p "${ANALYSIS_CACHE_DIR}/consistency"
    mkdir -p "${ANALYSIS_CACHE_DIR}/quality"
    
    # Create index if doesn't exist
    if [[ ! -f "${ANALYSIS_CACHE_INDEX}" ]]; then
        cat > "${ANALYSIS_CACHE_INDEX}" << 'EOF'
{
  "version": "2.7.1",
  "created": "",
  "last_cleanup": "",
  "cache_hits": 0,
  "cache_misses": 0,
  "entries": {
    "docs": [],
    "scripts": [],
    "directory": [],
    "consistency": [],
    "quality": []
  }
}
EOF
        local now=$(date -Iseconds)
        sed -i "s/\"created\": \"\"/\"created\": \"${now}\"/" "${ANALYSIS_CACHE_INDEX}"
        sed -i "s/\"last_cleanup\": \"\"/\"last_cleanup\": \"${now}\"/" "${ANALYSIS_CACHE_INDEX}"
    fi
    
    # Cleanup old entries
    cleanup_analysis_cache_old_entries
}

# ==============================================================================
# HASH GENERATION
# ==============================================================================

# Generate content hash for a file
# Args: $1 = file_path
# Returns: SHA256 hash
generate_file_hash() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo ""
        return 1
    fi
    
    sha256sum "$file" | awk '{print $1}'
}

# Generate hash for directory tree structure
# Args: $1 = directory_path
# Returns: SHA256 hash of directory structure
generate_directory_tree_hash() {
    local dir="$1"
    
    if [[ ! -d "$dir" ]]; then
        echo ""
        return 1
    fi
    
    # Hash directory structure (names, not contents)
    find "$dir" -type f -o -type d | sort | sha256sum | awk '{print $1}'
}

# Generate hash for multiple files
# Args: $@ = file_paths
# Returns: Combined SHA256 hash
generate_multi_file_hash() {
    local combined=""
    
    for file in "$@"; do
        [[ -f "$file" ]] && combined+=$(sha256sum "$file" | awk '{print $1}')
    done
    
    echo -n "$combined" | sha256sum | awk '{print $1}'
}

# ==============================================================================
# DOCUMENTATION ANALYSIS CACHE
# ==============================================================================

# Check if documentation analysis is cached
# Args: $1 = file_path
# Returns: 0 if cached and valid, 1 otherwise
check_docs_analysis_cache() {
    local file="$1"
    local file_hash=$(generate_file_hash "$file")
    local cache_key=$(basename "$file" | sed 's/[^a-zA-Z0-9]/_/g')
    local cache_file="${ANALYSIS_CACHE_DIR}/docs/${cache_key}.json"
    
    [[ -z "$file_hash" ]] && return 1
    [[ ! -f "$cache_file" ]] && return 1
    
    # Check if hash matches
    local cached_hash=$(jq -r '.file_hash // empty' "$cache_file" 2>/dev/null)
    [[ "$cached_hash" != "$file_hash" ]] && return 1
    
    # Check TTL
    local cached_time=$(jq -r '.timestamp // 0' "$cache_file" 2>/dev/null)
    local current_time=$(date +%s)
    local age=$((current_time - cached_time))
    
    if [[ $age -gt $ANALYSIS_CACHE_TTL ]]; then
        return 1
    fi
    
    # Cache hit
    increment_cache_stat "cache_hits"
    return 0
}

# Save documentation analysis to cache
# Args: $1 = file_path, $2 = analysis_result, $3 = status (pass/fail)
save_docs_analysis_cache() {
    local file="$1"
    local result="$2"
    local status="$3"
    local file_hash=$(generate_file_hash "$file")
    local cache_key=$(basename "$file" | sed 's/[^a-zA-Z0-9]/_/g')
    local cache_file="${ANALYSIS_CACHE_DIR}/docs/${cache_key}.json"
    
    [[ -z "$file_hash" ]] && return 1
    
    # Create cache entry
    cat > "$cache_file" << EOF
{
  "file": "$file",
  "file_hash": "$file_hash",
  "timestamp": $(date +%s),
  "status": "$status",
  "result": $(echo "$result" | jq -Rs .)
}
EOF
    
    # Update index
    update_cache_index "docs" "$cache_key" "$file_hash"
}

# Retrieve documentation analysis from cache
# Args: $1 = file_path
# Returns: Cached analysis result
get_docs_analysis_cache() {
    local file="$1"
    local cache_key=$(basename "$file" | sed 's/[^a-zA-Z0-9]/_/g')
    local cache_file="${ANALYSIS_CACHE_DIR}/docs/${cache_key}.json"
    
    if [[ -f "$cache_file" ]]; then
        jq -r '.result' "$cache_file" 2>/dev/null
    fi
}

# ==============================================================================
# SCRIPT VALIDATION CACHE
# ==============================================================================

# Check if script validation is cached
# Args: $1 = script_path
# Returns: 0 if cached and valid, 1 otherwise
check_script_validation_cache() {
    local script="$1"
    local script_hash=$(generate_file_hash "$script")
    local cache_key=$(basename "$script" | sed 's/[^a-zA-Z0-9]/_/g')
    local cache_file="${ANALYSIS_CACHE_DIR}/scripts/${cache_key}.json"
    
    [[ -z "$script_hash" ]] && return 1
    [[ ! -f "$cache_file" ]] && return 1
    
    local cached_hash=$(jq -r '.file_hash // empty' "$cache_file" 2>/dev/null)
    [[ "$cached_hash" != "$script_hash" ]] && return 1
    
    local cached_time=$(jq -r '.timestamp // 0' "$cache_file" 2>/dev/null)
    local current_time=$(date +%s)
    local age=$((current_time - cached_time))
    
    [[ $age -gt $ANALYSIS_CACHE_TTL ]] && return 1
    
    increment_cache_stat "cache_hits"
    return 0
}

# Save script validation to cache
# Args: $1 = script_path, $2 = validation_result, $3 = status
save_script_validation_cache() {
    local script="$1"
    local result="$2"
    local status="$3"
    local script_hash=$(generate_file_hash "$script")
    local cache_key=$(basename "$script" | sed 's/[^a-zA-Z0-9]/_/g')
    local cache_file="${ANALYSIS_CACHE_DIR}/scripts/${cache_key}.json"
    
    [[ -z "$script_hash" ]] && return 1
    
    cat > "$cache_file" << EOF
{
  "script": "$script",
  "file_hash": "$script_hash",
  "timestamp": $(date +%s),
  "status": "$status",
  "result": $(echo "$result" | jq -Rs .)
}
EOF
    
    update_cache_index "scripts" "$cache_key" "$script_hash"
}

# ==============================================================================
# DIRECTORY STRUCTURE CACHE
# ==============================================================================

# Check if directory structure validation is cached
# Args: $1 = directory_path
# Returns: 0 if cached and valid, 1 otherwise
check_directory_structure_cache() {
    local dir="$1"
    local dir_hash=$(generate_directory_tree_hash "$dir")
    local cache_key="dir_$(echo "$dir" | md5sum | awk '{print $1}')"
    local cache_file="${ANALYSIS_CACHE_DIR}/directory/${cache_key}.json"
    
    [[ -z "$dir_hash" ]] && return 1
    [[ ! -f "$cache_file" ]] && return 1
    
    local cached_hash=$(jq -r '.tree_hash // empty' "$cache_file" 2>/dev/null)
    [[ "$cached_hash" != "$dir_hash" ]] && return 1
    
    local cached_time=$(jq -r '.timestamp // 0' "$cache_file" 2>/dev/null)
    local current_time=$(date +%s)
    local age=$((current_time - cached_time))
    
    [[ $age -gt $ANALYSIS_CACHE_TTL ]] && return 1
    
    increment_cache_stat "cache_hits"
    return 0
}

# Save directory structure validation to cache
# Args: $1 = directory_path, $2 = validation_result, $3 = status
save_directory_structure_cache() {
    local dir="$1"
    local result="$2"
    local status="$3"
    local dir_hash=$(generate_directory_tree_hash "$dir")
    local cache_key="dir_$(echo "$dir" | md5sum | awk '{print $1}')"
    local cache_file="${ANALYSIS_CACHE_DIR}/directory/${cache_key}.json"
    
    [[ -z "$dir_hash" ]] && return 1
    
    cat > "$cache_file" << EOF
{
  "directory": "$dir",
  "tree_hash": "$dir_hash",
  "timestamp": $(date +%s),
  "status": "$status",
  "result": $(echo "$result" | jq -Rs .)
}
EOF
    
    update_cache_index "directory" "$cache_key" "$dir_hash"
}

# ==============================================================================
# CONSISTENCY ANALYSIS CACHE
# ==============================================================================

# Check if consistency analysis is cached
# Args: $@ = file_paths
# Returns: 0 if cached and valid, 1 otherwise
check_consistency_cache() {
    local files_hash=$(generate_multi_file_hash "$@")
    local cache_key="consistency_${files_hash:0:16}"
    local cache_file="${ANALYSIS_CACHE_DIR}/consistency/${cache_key}.json"
    
    [[ -z "$files_hash" ]] && return 1
    [[ ! -f "$cache_file" ]] && return 1
    
    local cached_hash=$(jq -r '.files_hash // empty' "$cache_file" 2>/dev/null)
    [[ "$cached_hash" != "$files_hash" ]] && return 1
    
    local cached_time=$(jq -r '.timestamp // 0' "$cache_file" 2>/dev/null)
    local current_time=$(date +%s)
    local age=$((current_time - cached_time))
    
    [[ $age -gt $ANALYSIS_CACHE_TTL ]] && return 1
    
    increment_cache_stat "cache_hits"
    return 0
}

# Save consistency analysis to cache
# Args: $1 = analysis_result, $2 = status, $@ = file_paths
save_consistency_cache() {
    local result="$1"
    local status="$2"
    shift 2
    local files_hash=$(generate_multi_file_hash "$@")
    local cache_key="consistency_${files_hash:0:16}"
    local cache_file="${ANALYSIS_CACHE_DIR}/consistency/${cache_key}.json"
    
    [[ -z "$files_hash" ]] && return 1
    
    # Convert file array to JSON
    local files_json=$(printf '%s\n' "$@" | jq -R . | jq -s .)
    
    cat > "$cache_file" << EOF
{
  "files": $files_json,
  "files_hash": "$files_hash",
  "timestamp": $(date +%s),
  "status": "$status",
  "result": $(echo "$result" | jq -Rs .)
}
EOF
    
    update_cache_index "consistency" "$cache_key" "$files_hash"
}

# ==============================================================================
# CODE QUALITY CACHE
# ==============================================================================

# Check if code quality analysis is cached
# Args: $1 = file_path
# Returns: 0 if cached and valid, 1 otherwise
check_quality_cache() {
    local file="$1"
    local file_hash=$(generate_file_hash "$file")
    local cache_key=$(basename "$file" | sed 's/[^a-zA-Z0-9]/_/g')
    local cache_file="${ANALYSIS_CACHE_DIR}/quality/${cache_key}.json"
    
    [[ -z "$file_hash" ]] && return 1
    [[ ! -f "$cache_file" ]] && return 1
    
    local cached_hash=$(jq -r '.file_hash // empty' "$cache_file" 2>/dev/null)
    [[ "$cached_hash" != "$file_hash" ]] && return 1
    
    local cached_time=$(jq -r '.timestamp // 0' "$cache_file" 2>/dev/null)
    local current_time=$(date +%s)
    local age=$((current_time - cached_time))
    
    [[ $age -gt $ANALYSIS_CACHE_TTL ]] && return 1
    
    increment_cache_stat "cache_hits"
    return 0
}

# Save code quality analysis to cache
# Args: $1 = file_path, $2 = analysis_result, $3 = status
save_quality_cache() {
    local file="$1"
    local result="$2"
    local status="$3"
    local file_hash=$(generate_file_hash "$file")
    local cache_key=$(basename "$file" | sed 's/[^a-zA-Z0-9]/_/g')
    local cache_file="${ANALYSIS_CACHE_DIR}/quality/${cache_key}.json"
    
    [[ -z "$file_hash" ]] && return 1
    
    cat > "$cache_file" << EOF
{
  "file": "$file",
  "file_hash": "$file_hash",
  "timestamp": $(date +%s),
  "status": "$status",
  "result": $(echo "$result" | jq -Rs .)
}
EOF
    
    update_cache_index "quality" "$cache_key" "$file_hash"
}

# ==============================================================================
# CACHE MANAGEMENT
# ==============================================================================

# Update cache index with new entry
# Args: $1 = cache_type, $2 = cache_key, $3 = hash
update_cache_index() {
    local cache_type="$1"
    local cache_key="$2"
    local hash="$3"
    
    [[ ! -f "${ANALYSIS_CACHE_INDEX}" ]] && return 1
    
    # Use jq to update index
    local temp_index=$(mktemp)
    track_analysis_cache_temp "$temp_index"
    jq --arg type "$cache_type" --arg key "$cache_key" --arg hash "$hash" --arg ts "$(date +%s)" \
        '.entries[$type] |= (. // []) + [{key: $key, hash: $hash, timestamp: ($ts | tonumber)}] | unique_by(.key)' \
        "${ANALYSIS_CACHE_INDEX}" > "$temp_index" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        mv "$temp_index" "${ANALYSIS_CACHE_INDEX}"
    else
        rm -f "$temp_index"
    fi
}

# Increment cache statistic
# Args: $1 = stat_name (cache_hits or cache_misses)
increment_cache_stat() {
    local stat="$1"
    
    [[ ! -f "${ANALYSIS_CACHE_INDEX}" ]] && return 1
    
    local temp_index=$(mktemp)
    track_analysis_cache_temp "$temp_index"
    jq --arg stat "$stat" '.[$stat] = ((.[$stat] // 0) + 1)' "${ANALYSIS_CACHE_INDEX}" > "$temp_index" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        mv "$temp_index" "${ANALYSIS_CACHE_INDEX}"
    else
        rm -f "$temp_index"
    fi
}

# Record cache miss
record_cache_miss() {
    increment_cache_stat "cache_misses"
}

# Cleanup old cache entries
cleanup_analysis_cache_old_entries() {
    [[ ! -d "${ANALYSIS_CACHE_DIR}" ]] && return 0
    
    local current_time=$(date +%s)
    local deleted_count=0
    
    # Cleanup each cache type directory
    for cache_type in docs scripts directory consistency quality; do
        local cache_dir="${ANALYSIS_CACHE_DIR}/${cache_type}"
        [[ ! -d "$cache_dir" ]] && continue
        
        while IFS= read -r cache_file; do
            [[ ! -f "$cache_file" ]] && continue
            
            local cached_time=$(jq -r '.timestamp // 0' "$cache_file" 2>/dev/null)
            local age=$((current_time - cached_time))
            
            if [[ $age -gt $ANALYSIS_CACHE_TTL ]]; then
                rm -f "$cache_file"
                ((deleted_count++)) || true
            fi
        done < <(find "$cache_dir" -type f -name "*.json" 2>/dev/null)
    done
    
    if [[ $deleted_count -gt 0 ]]; then
        print_info "Cleaned up $deleted_count old cache entries"
        
        # Update last cleanup time
        if [[ -f "${ANALYSIS_CACHE_INDEX}" ]]; then
            local temp_index=$(mktemp)
            track_analysis_cache_temp "$temp_index"
            jq --arg ts "$(date -Iseconds)" '.last_cleanup = $ts' "${ANALYSIS_CACHE_INDEX}" > "$temp_index" 2>/dev/null
            [[ $? -eq 0 ]] && mv "$temp_index" "${ANALYSIS_CACHE_INDEX}" || rm -f "$temp_index"
        fi
    fi
}

# Get cache statistics
get_cache_stats() {
    [[ ! -f "${ANALYSIS_CACHE_INDEX}" ]] && return 1
    
    local hits=$(jq -r '.cache_hits // 0' "${ANALYSIS_CACHE_INDEX}")
    local misses=$(jq -r '.cache_misses // 0' "${ANALYSIS_CACHE_INDEX}")
    local total=$((hits + misses))
    local hit_rate=0
    
    if [[ $total -gt 0 ]]; then
        hit_rate=$((hits * 100 / total))
    fi
    
    echo "{\"hits\":$hits,\"misses\":$misses,\"total\":$total,\"hit_rate\":$hit_rate}"
}

# Display cache statistics
display_cache_stats() {
    local stats=$(get_cache_stats)
    
    if [[ -n "$stats" ]]; then
        local hits=$(echo "$stats" | jq -r '.hits')
        local misses=$(echo "$stats" | jq -r '.misses')
        local total=$(echo "$stats" | jq -r '.total')
        local hit_rate=$(echo "$stats" | jq -r '.hit_rate')
        
        print_header "Analysis Cache Statistics"
        print_info "Cache Hits:    $hits"
        print_info "Cache Misses:  $misses"
        print_info "Total Queries: $total"
        print_info "Hit Rate:      ${hit_rate}%"
        
        if [[ $hit_rate -ge 70 ]]; then
            print_success "Excellent cache performance (≥70%)"
        elif [[ $hit_rate -ge 40 ]]; then
            print_info "Good cache performance (40-70%)"
        else
            print_warning "Low cache performance (<40%) - consider increasing TTL"
        fi
    fi
}

# Clear entire cache
clear_analysis_cache() {
    print_warning "Clearing entire analysis cache..."
    
    rm -rf "${ANALYSIS_CACHE_DIR}"/*
    init_analysis_cache
    
    print_success "Analysis cache cleared"
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f init_analysis_cache
export -f generate_file_hash
export -f generate_directory_tree_hash
export -f generate_multi_file_hash
export -f check_docs_analysis_cache
export -f save_docs_analysis_cache
export -f get_docs_analysis_cache
export -f check_script_validation_cache
export -f save_script_validation_cache
export -f check_directory_structure_cache
export -f save_directory_structure_cache
export -f check_consistency_cache
export -f save_consistency_cache
export -f check_quality_cache
export -f save_quality_cache
export -f cleanup_analysis_cache_old_entries
export -f get_cache_stats
export -f display_cache_stats
export -f clear_analysis_cache
export -f record_cache_miss
export -f increment_cache_stat
export -f track_analysis_cache_temp
export -f cleanup_analysis_cache_files

# ==============================================================================
# CLEANUP TRAP
# ==============================================================================

# Ensure cleanup runs on exit
trap cleanup_analysis_cache_files EXIT INT TERM

################################################################################
# End of Advanced Analysis Caching Module
################################################################################
