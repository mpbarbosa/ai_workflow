#!/bin/bash
set -euo pipefail

################################################################################
# Dependency Cache Module
# Version: 1.0.7
# Purpose: Cache npm audit and outdated check results to improve performance
# Part of: Tests & Documentation Workflow Automation v3.3.0
# Created: February 7, 2026
################################################################################

# ==============================================================================
# CACHE CONFIGURATION
# ==============================================================================

# Set defaults for configuration variables if not already set
VERBOSE=${VERBOSE:-false}
USE_DEPENDENCY_CACHE=${USE_DEPENDENCY_CACHE:-true}
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}

# Cache directory structure
DEPENDENCY_CACHE_DIR="${WORKFLOW_HOME}/src/workflow/.dependency_cache"
DEPENDENCY_CACHE_INDEX="${DEPENDENCY_CACHE_DIR}/index.json"
DEPENDENCY_CACHE_TTL=3600  # 1 hour in seconds (dependencies change more frequently)
DEPENDENCY_CACHE_MAX_SIZE_MB=50  # Maximum cache size in MB

# ==============================================================================
# CACHE INITIALIZATION
# ==============================================================================

# Initialize dependency cache directory and index
init_dependency_cache() {
    if [[ "${USE_DEPENDENCY_CACHE}" != "true" ]]; then
        return 0
    fi
    
    mkdir -p "${DEPENDENCY_CACHE_DIR}"
    
    # Create index file if it doesn't exist
    if [[ ! -f "${DEPENDENCY_CACHE_INDEX}" ]]; then
        cat > "${DEPENDENCY_CACHE_INDEX}" << 'EOF'
{
  "version": "1.0.7",
  "created": "",
  "last_cleanup": "",
  "entries": []
}
EOF
        # Update created timestamp
        local now=$(date -Iseconds)
        sed -i "s/\"created\": \"\"/\"created\": \"${now}\"/" "${DEPENDENCY_CACHE_INDEX}"
        sed -i "s/\"last_cleanup\": \"\"/\"last_cleanup\": \"${now}\"/" "${DEPENDENCY_CACHE_INDEX}"
    fi
    
    # Cleanup old entries on initialization
    cleanup_dependency_cache_old_entries
    
    if [[ "${VERBOSE}" == "true" ]]; then
        print_info "Dependency cache initialized: ${DEPENDENCY_CACHE_DIR}"
    fi
}

# ==============================================================================
# CACHE KEY GENERATION
# ==============================================================================

# Generate a cache key from package.json content and command type
# Args: $1 = package.json path, $2 = cache type (audit|outdated)
# Returns: SHA256 hash as cache key
generate_dependency_cache_key() {
    local package_json="$1"
    local cache_type="$2"
    
    # Hash package.json dependencies + cache type
    # Include both dependencies and devDependencies sections
    local deps_hash=""
    if [[ -f "$package_json" ]]; then
        deps_hash=$(jq -S '{dependencies, devDependencies}' "$package_json" 2>/dev/null | sha256sum | awk '{print $1}')
    else
        # Fallback: hash entire file
        deps_hash=$(sha256sum "$package_json" 2>/dev/null | awk '{print $1}' || echo "invalid")
    fi
    
    # Combine deps hash and cache type
    echo -n "${cache_type}_${deps_hash}" | sha256sum | awk '{print $1}'
}

# ==============================================================================
# CACHE OPERATIONS
# ==============================================================================

# Check if cached result exists and is valid
# Args: $1 = cache_key
# Returns: 0 if exists and valid, 1 otherwise
check_dependency_cache() {
    local cache_key="$1"
    local cache_file="${DEPENDENCY_CACHE_DIR}/${cache_key}.json"
    local cache_meta="${DEPENDENCY_CACHE_DIR}/${cache_key}.meta"
    
    if [[ "${USE_DEPENDENCY_CACHE}" != "true" ]]; then
        return 1
    fi
    
    # Check if cache file exists
    if [[ ! -f "${cache_file}" ]]; then
        return 1
    fi
    
    # Check if cache is still valid (within TTL)
    if [[ -f "${cache_meta}" ]]; then
        local created_at
        created_at=$(grep "created_at=" "$cache_meta" | cut -d'=' -f2)
        local current_time
        current_time=$(date +%s)
        local age=$((current_time - created_at))
        
        if [[ $age -gt ${DEPENDENCY_CACHE_TTL} ]]; then
            if [[ "${VERBOSE}" == "true" ]]; then
                print_info "Cache expired (age: ${age}s, TTL: ${DEPENDENCY_CACHE_TTL}s)"
            fi
            return 1
        fi
    else
        # No meta file - assume expired for safety
        return 1
    fi
    
    return 0
}

# Get cached result
# Args: $1 = cache_key, $2 = output file path
# Returns: 0 on success, 1 on failure
get_cached_dependency_result() {
    local cache_key="$1"
    local output_file="$2"
    local cache_file="${DEPENDENCY_CACHE_DIR}/${cache_key}.json"
    
    if [[ ! -f "${cache_file}" ]]; then
        return 1
    fi
    
    cp "${cache_file}" "${output_file}"
    
    if [[ "${VERBOSE}" == "true" ]]; then
        print_success "Using cached result (key: ${cache_key:0:8}...)"
    fi
    
    return 0
}

# Save result to cache
# Args: $1 = cache_key, $2 = result file path, $3 = cache type
# Returns: 0 on success, 1 on failure
save_to_dependency_cache() {
    local cache_key="$1"
    local result_file="$2"
    local cache_type="$3"
    local cache_file="${DEPENDENCY_CACHE_DIR}/${cache_key}.json"
    local cache_meta="${DEPENDENCY_CACHE_DIR}/${cache_key}.meta"
    
    if [[ "${USE_DEPENDENCY_CACHE}" != "true" ]]; then
        return 0
    fi
    
    # Copy result to cache
    cp "${result_file}" "${cache_file}"
    
    # Create metadata file
    cat > "${cache_meta}" << EOF
cache_key=${cache_key}
cache_type=${cache_type}
created_at=$(date +%s)
created_at_human=$(date -Iseconds)
EOF
    
    # Update cache index
    update_dependency_cache_index "$cache_key" "$cache_type"
    
    if [[ "${VERBOSE}" == "true" ]]; then
        print_info "Saved to cache (key: ${cache_key:0:8}..., type: ${cache_type})"
    fi
    
    return 0
}

# Update cache index with new entry
# Args: $1 = cache_key, $2 = cache_type
update_dependency_cache_index() {
    local cache_key="$1"
    local cache_type="$2"
    local now=$(date -Iseconds)
    
    if [[ ! -f "${DEPENDENCY_CACHE_INDEX}" ]]; then
        init_dependency_cache
    fi
    
    # Add entry to index using jq (safer than manual JSON manipulation)
    if command -v jq &>/dev/null; then
        local temp_index
        temp_index=$(mktemp)
        jq --arg key "${cache_key}" \
           --arg type "${cache_type}" \
           --arg timestamp "${now}" \
           --argjson ttl "${DEPENDENCY_CACHE_TTL}" \
           '.entries += [{key: $key, type: $type, timestamp: $timestamp, ttl: $ttl}]' \
           "${DEPENDENCY_CACHE_INDEX}" > "$temp_index"
        mv "$temp_index" "${DEPENDENCY_CACHE_INDEX}"
    fi
}

# ==============================================================================
# CACHE CLEANUP
# ==============================================================================

# Remove expired cache entries
cleanup_dependency_cache_old_entries() {
    if [[ "${USE_DEPENDENCY_CACHE}" != "true" ]]; then
        return 0
    fi
    
    if [[ ! -d "${DEPENDENCY_CACHE_DIR}" ]]; then
        return 0
    fi
    
    local current_time
    current_time=$(date +%s)
    local removed_count=0
    
    # Find and remove expired cache files
    find "${DEPENDENCY_CACHE_DIR}" -name "*.meta" -type f | while read -r meta_file; do
        if [[ -f "$meta_file" ]]; then
            local created_at
            created_at=$(grep "created_at=" "$meta_file" | cut -d'=' -f2 || echo "0")
            local age=$((current_time - created_at))
            
            if [[ $age -gt ${DEPENDENCY_CACHE_TTL} ]]; then
                local cache_key
                cache_key=$(basename "$meta_file" .meta)
                rm -f "${DEPENDENCY_CACHE_DIR}/${cache_key}.json" "${DEPENDENCY_CACHE_DIR}/${cache_key}.meta"
                ((removed_count++))
            fi
        fi
    done
    
    # Update last cleanup timestamp in index
    if [[ -f "${DEPENDENCY_CACHE_INDEX}" ]] && command -v jq &>/dev/null; then
        local now=$(date -Iseconds)
        local temp_index
        temp_index=$(mktemp)
        jq --arg timestamp "$now" '.last_cleanup = $timestamp' "${DEPENDENCY_CACHE_INDEX}" > "$temp_index"
        mv "$temp_index" "${DEPENDENCY_CACHE_INDEX}"
    fi
    
    if [[ "${VERBOSE}" == "true" ]] && [[ $removed_count -gt 0 ]]; then
        print_info "Cleaned up ${removed_count} expired cache entries"
    fi
}

# Clear entire dependency cache
clear_dependency_cache() {
    if [[ -d "${DEPENDENCY_CACHE_DIR}" ]]; then
        local count
        count=$(find "${DEPENDENCY_CACHE_DIR}" -name "*.json" -o -name "*.meta" | wc -l)
        rm -rf "${DEPENDENCY_CACHE_DIR}"
        print_success "Cleared dependency cache (${count} files removed)"
    fi
}

# ==============================================================================
# CACHE STATISTICS
# ==============================================================================

# Get cache statistics
get_dependency_cache_stats() {
    if [[ ! -d "${DEPENDENCY_CACHE_DIR}" ]]; then
        echo "Cache not initialized"
        return 1
    fi
    
    local total_entries
    total_entries=$(find "${DEPENDENCY_CACHE_DIR}" -name "*.json" -type f | wc -l)
    local cache_size_kb
    cache_size_kb=$(du -sk "${DEPENDENCY_CACHE_DIR}" 2>/dev/null | awk '{print $1}' || echo "0")
    local cache_size_mb=$((cache_size_kb / 1024))
    
    cat << EOF
Dependency Cache Statistics:
  Location: ${DEPENDENCY_CACHE_DIR}
  Total Entries: ${total_entries}
  Cache Size: ${cache_size_mb} MB (${cache_size_kb} KB)
  TTL: ${DEPENDENCY_CACHE_TTL} seconds ($(( DEPENDENCY_CACHE_TTL / 60 )) minutes)
  Max Size: ${DEPENDENCY_CACHE_MAX_SIZE_MB} MB
EOF
}

# Export functions
export -f init_dependency_cache
export -f generate_dependency_cache_key
export -f check_dependency_cache
export -f get_cached_dependency_result
export -f save_to_dependency_cache
export -f cleanup_dependency_cache_old_entries
export -f clear_dependency_cache
export -f get_dependency_cache_stats
