#!/bin/bash
set -euo pipefail

################################################################################
# AI Response Caching Module
# Version: 1.0.0
# Purpose: Cache AI responses to reduce token usage and improve performance
# Part of: Tests & Documentation Workflow Automation v2.3.0
# Created: December 18, 2025
################################################################################

# ==============================================================================
# CACHE CONFIGURATION
# ==============================================================================

# Set defaults for configuration variables if not already set
VERBOSE=${VERBOSE:-false}
USE_AI_CACHE=${USE_AI_CACHE:-true}
WORKFLOW_RUN_ID=${WORKFLOW_RUN_ID:-unknown}
SCRIPT_VERSION=${SCRIPT_VERSION:-1.0.0}
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}

# Cache directory structure
AI_CACHE_DIR="${WORKFLOW_HOME}/src/workflow/.ai_cache"
AI_CACHE_INDEX="${AI_CACHE_DIR}/index.json"
AI_CACHE_TTL=86400  # 24 hours in seconds
AI_CACHE_MAX_SIZE_MB=100  # Maximum cache size in MB

# ==============================================================================
# CACHE INITIALIZATION
# ==============================================================================

# Initialize AI cache directory and index
init_ai_cache() {
    if [[ "${USE_AI_CACHE}" != "true" ]]; then
        return 0
    fi
    
    mkdir -p "${AI_CACHE_DIR}"
    
    # Create index file if it doesn't exist
    if [[ ! -f "${AI_CACHE_INDEX}" ]]; then
        cat > "${AI_CACHE_INDEX}" << 'EOF'
{
  "version": "1.0.0",
  "created": "",
  "last_cleanup": "",
  "entries": []
}
EOF
        # Update created timestamp
        local now=$(date -Iseconds)
        sed -i "s/\"created\": \"\"/\"created\": \"${now}\"/" "${AI_CACHE_INDEX}"
        sed -i "s/\"last_cleanup\": \"\"/\"last_cleanup\": \"${now}\"/" "${AI_CACHE_INDEX}"
    fi
    
    # Cleanup old entries on initialization
    cleanup_ai_cache_old_entries
    
    if [[ "${VERBOSE}" == "true" ]]; then
        print_info "AI cache initialized: ${AI_CACHE_DIR}"
    fi
}

# ==============================================================================
# CACHE KEY GENERATION
# ==============================================================================

# Generate a cache key from prompt and context
# Args: $1 = prompt text, $2 = context (optional)
# Returns: SHA256 hash as cache key
generate_cache_key() {
    local prompt="$1"
    local context="${2:-}"
    
    # Combine prompt and context, then hash
    local combined="${prompt}|${context}"
    echo -n "${combined}" | sha256sum | awk '{print $1}'
}

# ==============================================================================
# CACHE OPERATIONS
# ==============================================================================

# Check if cached response exists and is valid
# Args: $1 = cache_key
# Returns: 0 if exists and valid, 1 otherwise
check_cache() {
    local cache_key="$1"
    local cache_file="${AI_CACHE_DIR}/${cache_key}.txt"
    local cache_meta="${AI_CACHE_DIR}/${cache_key}.meta"
    
    if [[ "${USE_AI_CACHE}" != "true" ]]; then
        return 1
    fi
    
    # Check if cache file exists (meta is optional for backward compatibility)
    if [[ ! -f "${cache_file}" ]]; then
        return 1
    fi
    
    # If meta file exists, check if cache is expired
    if [[ -f "${cache_meta}" ]]; then
        local timestamp=$(jq -r '.timestamp_epoch' "${cache_meta}" 2>/dev/null || echo "0")
        local now=$(date +%s)
        local age=$((now - timestamp))
        
        if [[ ${age} -gt ${AI_CACHE_TTL} ]]; then
            if [[ "${VERBOSE}" == "true" ]]; then
                print_info "Cache expired for key: ${cache_key}"
            fi
            return 1
        fi
    fi
    
    return 0
}

# Get cached response
# Args: $1 = cache_key
# Returns: Cached response content
get_cached_response() {
    local cache_key="$1"
    local cache_file="${AI_CACHE_DIR}/${cache_key}.txt"
    
    if check_cache "${cache_key}"; then
        cat "${cache_file}"
        
        if [[ "${VERBOSE}" == "true" ]]; then
            print_success "Using cached AI response (key: ${cache_key:0:8}...)"
        fi
        
        return 0
    fi
    
    return 1
}

# Alias for backward compatibility with tests
get_from_cache() {
    get_cached_response "$@"
}

# Save response to cache
# Args: $1 = cache_key, $2 = response_text, $3 = prompt (optional), $4 = context (optional)
save_to_cache() {
    local cache_key="$1"
    local response="$2"
    local prompt="${3:-}"
    local context="${4:-}"
    
    if [[ "${USE_AI_CACHE}" != "true" ]]; then
        return 0
    fi
    
    local cache_file="${AI_CACHE_DIR}/${cache_key}.txt"
    local cache_meta="${AI_CACHE_DIR}/${cache_key}.meta"
    
    # Save response
    echo "${response}" > "${cache_file}"
    
    # Save metadata
    cat > "${cache_meta}" << EOF
{
  "cache_key": "${cache_key}",
  "timestamp": "$(date -Iseconds)",
  "timestamp_epoch": $(date +%s),
  "prompt_preview": "$(echo "${prompt}" | head -c 100 | sed 's/"/\\"/g')...",
  "context": "$(echo "${context}" | sed 's/"/\\"/g')",
  "response_size": $(echo "${response}" | wc -c),
  "workflow_run_id": "${WORKFLOW_RUN_ID:-unknown}",
  "version": "${SCRIPT_VERSION:-1.0.0}"
}
EOF
    
    # Update index
    update_cache_index "${cache_key}"
    
    if [[ "${VERBOSE}" == "true" ]]; then
        print_success "Response cached (key: ${cache_key:0:8}...)"
    fi
}

# ==============================================================================
# CACHE MANAGEMENT
# ==============================================================================

# Update cache index with new entry
update_cache_index() {
    local cache_key="$1"
    
    if [[ "${USE_AI_CACHE}" != "true" ]]; then
        return 0
    fi
    
    if [[ ! -f "${AI_CACHE_INDEX}" ]]; then
        init_ai_cache
    fi
    
    # Check if entry already exists (look for both cache_key and key for compatibility)
    if jq -e ".entries[] | select(.cache_key == \"${cache_key}\" or .key == \"${cache_key}\")" "${AI_CACHE_INDEX}" > /dev/null 2>&1; then
        # Update existing entry
        local temp_index=$(mktemp)
        track_ai_cache_temp "$temp_index"
        jq ".entries |= map(if (.cache_key // .key) == \"${cache_key}\" then .last_accessed = \"$(date -Iseconds)\" | .access_count = ((.access_count // 0) + 1) else . end)" \
            "${AI_CACHE_INDEX}" > "${temp_index}"
        mv "${temp_index}" "${AI_CACHE_INDEX}"
    else
        # Add new entry
        local temp_index=$(mktemp)
        track_ai_cache_temp "$temp_index"
        jq ".entries += [{
            \"cache_key\": \"${cache_key}\",
            \"created\": \"$(date -Iseconds)\",
            \"last_accessed\": \"$(date -Iseconds)\",
            \"access_count\": 1
        }]" "${AI_CACHE_INDEX}" > "${temp_index}"
        mv "${temp_index}" "${AI_CACHE_INDEX}"
    fi
}

# Cleanup old cache entries
cleanup_ai_cache_old_entries() {
    if [[ "${USE_AI_CACHE}" != "true" ]]; then
        return 0
    fi
    
    if [[ ! -d "${AI_CACHE_DIR}" ]]; then
        return 0
    fi
    
    local now=$(date +%s)
    local deleted_count=0
    
    # Find and delete expired cache files
    # Use simple command substitution to avoid stdin/subprocess issues
    local cache_files_list
    cache_files_list=$(find "${AI_CACHE_DIR}" -name "*.txt" -type f 2>/dev/null || true)
    
    if [[ -n "${cache_files_list}" ]]; then
        while IFS= read -r cache_file; do
            [[ -z "${cache_file}" ]] && continue
            
            local cache_key=$(basename "${cache_file}" .txt)
            local cache_meta="${AI_CACHE_DIR}/${cache_key}.meta"
            
            if [[ -f "${cache_meta}" ]]; then
                local timestamp=$(jq -r '.timestamp_epoch' "${cache_meta}" 2>/dev/null || echo "0")
                local age=$((now - timestamp))
                
                if [[ ${age} -gt ${AI_CACHE_TTL} ]]; then
                    rm -f "${cache_file}" "${cache_meta}"
                    ((deleted_count++)) || true
                fi
            fi
        done <<< "${cache_files_list}"
    fi
    
    # Only update index if we actually deleted something
    if [[ ${deleted_count} -gt 0 ]] && [[ -f "${AI_CACHE_INDEX}" ]]; then
        local temp_index=$(mktemp)
        track_ai_cache_temp "$temp_index"
        # Update last_cleanup and filter out entries where cache file no longer exists
        jq --arg cleanup "$(date -Iseconds)" '
            .last_cleanup = $cleanup | 
            .entries |= map(select(
                (.cache_key // .key) as $key | 
                ($key | . != null and . != "")
            ))
        ' "${AI_CACHE_INDEX}" > "${temp_index}" 2>/dev/null || true
        
        if [[ -s "${temp_index}" ]]; then
            mv "${temp_index}" "${AI_CACHE_INDEX}"
        else
            rm -f "${temp_index}"
        fi
        
        if [[ "${VERBOSE}" == "true" ]]; then
            print_info "Cleaned up ${deleted_count} expired cache entries"
        fi
    fi
}

# Get cache statistics
get_cache_stats() {
    if [[ ! -f "${AI_CACHE_INDEX}" ]]; then
        echo "Cache not initialized"
        return 1
    fi
    
    local total_entries=$(jq '.entries | length' "${AI_CACHE_INDEX}")
    local cache_size=$(du -sh "${AI_CACHE_DIR}" 2>/dev/null | awk '{print $1}')
    local cache_created=$(jq -r '.created' "${AI_CACHE_INDEX}")
    local last_cleanup=$(jq -r '.last_cleanup' "${AI_CACHE_INDEX}")
    
    cat << EOF

AI Cache Statistics:
  Total Entries: ${total_entries}
  Cache Size: ${cache_size}
  Created: ${cache_created}
  Last Cleanup: ${last_cleanup}
  Location: ${AI_CACHE_DIR}
EOF
}

# Clear entire cache
clear_ai_cache() {
    if [[ -d "${AI_CACHE_DIR}" ]]; then
        rm -rf "${AI_CACHE_DIR}"
        print_success "AI cache cleared"
    fi
    init_ai_cache
}

# ==============================================================================
# HELPER FUNCTIONS FOR AI INTEGRATION
# ==============================================================================

# Wrapper function for AI calls with caching
# Args: $1 = prompt, $2 = context, $3 = ai_command
# Returns: AI response (cached or fresh)
call_ai_with_cache() {
    local prompt="$1"
    local context="$2"
    local ai_command="$3"
    
    # Generate cache key
    local cache_key=$(generate_cache_key "${prompt}" "${context}")
    
    # Try to get cached response
    if get_cached_response "${cache_key}"; then
        return 0
    fi
    
    # Cache miss - call AI
    if [[ "${VERBOSE}" == "true" ]]; then
        print_info "Cache miss - calling AI (key: ${cache_key:0:8}...)"
    fi
    
    local response
    response=$(eval "${ai_command}" 2>&1)
    local exit_code=$?
    
    if [[ ${exit_code} -eq 0 ]]; then
        # Save to cache
        save_to_cache "${cache_key}" "${response}" "${prompt}" "${context}"
        echo "${response}"
        return 0
    else
        # AI call failed
        echo "${response}" >&2
        return ${exit_code}
    fi
}

# ==============================================================================
# CACHE METRICS
# ==============================================================================

# Track cache hit/miss for metrics
declare -g AI_CACHE_HITS=0
declare -g AI_CACHE_MISSES=0
declare -g AI_CACHE_TOKENS_SAVED=0

record_cache_hit() {
    ((AI_CACHE_HITS++))
    local estimated_tokens=${1:-1000}  # Estimate tokens saved
    ((AI_CACHE_TOKENS_SAVED+=estimated_tokens))
}

record_cache_miss() {
    ((AI_CACHE_MISSES++))
}

get_cache_metrics() {
    local total=$((AI_CACHE_HITS + AI_CACHE_MISSES))
    local hit_rate=0
    
    if [[ ${total} -gt 0 ]]; then
        hit_rate=$(awk "BEGIN {printf \"%.1f\", (${AI_CACHE_HITS} / ${total}) * 100}")
    fi
    
    cat << EOF

AI Cache Metrics (This Run):
  Cache Hits: ${AI_CACHE_HITS}
  Cache Misses: ${AI_CACHE_MISSES}
  Hit Rate: ${hit_rate}%
  Estimated Tokens Saved: ${AI_CACHE_TOKENS_SAVED}
EOF
}

# ==============================================================================
# CLEANUP HANDLER
# ==============================================================================

# Track temporary files created by this module
declare -a AI_CACHE_TEMP_FILES=()

# Register temp file for cleanup
track_ai_cache_temp() {
    local temp_file="$1"
    AI_CACHE_TEMP_FILES+=("$temp_file")
}

# Cleanup function for ai_cache module
cleanup_ai_cache() {
    # Remove any temporary files created during cache operations
    for temp_file in "${AI_CACHE_TEMP_FILES[@]}"; do
        if [[ -f "$temp_file" ]]; then
            rm -f "$temp_file" 2>/dev/null || true
        fi
    done
}

# Register cleanup handler
trap cleanup_ai_cache EXIT INT TERM

################################################################################
# Module initialized
################################################################################
