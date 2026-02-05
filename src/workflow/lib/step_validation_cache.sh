#!/bin/bash
set -euo pipefail

################################################################################
# Step Validation Cache Module
# Version: 1.0.1
# Purpose: Cache validation results between workflow runs to skip unchanged files
# Part of: Tests & Documentation Workflow Automation v2.7.0
# Expected Benefit: 60% reduction in repeated workflow runs
################################################################################

# Prevent double-loading
if [[ "${STEP_VALIDATION_CACHE_LOADED:-}" == "true" ]]; then
    return 0
fi

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Set default for WORKFLOW_HOME if not already set
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}

# Cache directory structure
VALIDATION_CACHE_DIR="${WORKFLOW_HOME}/src/workflow/.validation_cache"
VALIDATION_CACHE_INDEX="${VALIDATION_CACHE_DIR}/index.json"
VALIDATION_CACHE_TTL=86400  # 24 hours in seconds
VALIDATION_CACHE_VERSION="1.0.1"

# Enable/disable validation caching
USE_VALIDATION_CACHE=${USE_VALIDATION_CACHE:-true}

# Validation cache statistics
declare -g VALIDATION_CACHE_HITS=0
declare -g VALIDATION_CACHE_MISSES=0
declare -g VALIDATION_CACHE_SKIPPED_FILES=0

# ==============================================================================
# CACHE INITIALIZATION
# ==============================================================================

# Initialize validation cache directory and index
init_validation_cache() {
    if [[ "${USE_VALIDATION_CACHE}" != "true" ]]; then
        return 0
    fi
    
    mkdir -p "${VALIDATION_CACHE_DIR}"
    
    # Create index file if it doesn't exist
    if [[ ! -f "${VALIDATION_CACHE_INDEX}" ]]; then
        cat > "${VALIDATION_CACHE_INDEX}" << 'EOF'
{
  "version": "1.0.1",
  "created": "",
  "last_cleanup": "",
  "entries": {}
}
EOF
        local now=$(date -Iseconds)
        sed -i "s/\"created\": \"\"/\"created\": \"${now}\"/" "${VALIDATION_CACHE_INDEX}"
        sed -i "s/\"last_cleanup\": \"\"/\"last_cleanup\": \"${now}\"/" "${VALIDATION_CACHE_INDEX}"
    fi
    
    # Cleanup old entries on initialization
    cleanup_validation_cache_old_entries
    
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        print_info "Validation cache initialized: ${VALIDATION_CACHE_DIR}"
    fi
}

# ==============================================================================
# FILE HASH CALCULATION
# ==============================================================================

# Calculate SHA256 hash of file content
# Args: $1 = file path
# Returns: SHA256 hash string
calculate_file_hash() {
    local file_path="$1"
    
    if [[ ! -f "${file_path}" ]]; then
        echo "FILE_NOT_FOUND"
        return 1
    fi
    
    sha256sum "${file_path}" | awk '{print $1}'
}

# Calculate combined hash for multiple files
# Args: $@ = file paths
# Returns: Combined SHA256 hash
calculate_files_hash() {
    local combined_content=""
    
    for file in "$@"; do
        if [[ -f "${file}" ]]; then
            combined_content+=$(cat "${file}")
        fi
    done
    
    echo -n "${combined_content}" | sha256sum | awk '{print $1}'
}

# Calculate directory structure hash (recursive file listing)
# Args: $1 = directory path
# Returns: SHA256 hash of directory structure
calculate_directory_hash() {
    local dir_path="$1"
    
    if [[ ! -d "${dir_path}" ]]; then
        echo "DIR_NOT_FOUND"
        return 1
    fi
    
    # Create hash from directory structure (file paths + sizes)
    find "${dir_path}" -type f 2>/dev/null | sort | while read -r file; do
        stat -c "%s %n" "${file}" 2>/dev/null
    done | sha256sum | awk '{print $1}'
}

# ==============================================================================
# CACHE KEY GENERATION
# ==============================================================================

# Generate cache key for file validation
# Args: $1 = step_name, $2 = validation_type, $3 = file_path
# Returns: Cache key string
generate_validation_cache_key() {
    local step_name="$1"
    local validation_type="$2"
    local file_path="$3"
    
    # Normalize file path (remove leading ./)
    local normalized_path="${file_path#./}"
    
    # Create cache key: step:validation_type:file_path
    echo "${step_name}:${validation_type}:${normalized_path}"
}

# Generate cache key for directory validation
# Args: $1 = step_name, $2 = validation_type, $3 = directory_path
# Returns: Cache key string
generate_directory_validation_key() {
    local step_name="$1"
    local validation_type="$2"
    local dir_path="$3"
    
    local normalized_path="${dir_path#./}"
    echo "${step_name}:${validation_type}:dir:${normalized_path}"
}

# ==============================================================================
# CACHE OPERATIONS
# ==============================================================================

# Check if validation result is cached and still valid
# Args: $1 = cache_key, $2 = current_file_hash
# Returns: 0 if cached and valid, 1 otherwise
check_validation_cache() {
    local cache_key="$1"
    local current_hash="$2"
    
    if [[ "${USE_VALIDATION_CACHE}" != "true" ]]; then
        return 1
    fi
    
    if [[ ! -f "${VALIDATION_CACHE_INDEX}" ]]; then
        return 1
    fi
    
    # Query cache index
    local cached_entry=$(jq -r ".entries[\"${cache_key}\"] // empty" "${VALIDATION_CACHE_INDEX}" 2>/dev/null)
    
    if [[ -z "${cached_entry}" ]]; then
        return 1
    fi
    
    # Extract cached hash and timestamp
    local cached_hash=$(echo "${cached_entry}" | jq -r '.file_hash // empty')
    local cached_timestamp=$(echo "${cached_entry}" | jq -r '.timestamp_epoch // 0')
    
    # Check if entry is expired
    local now=$(date +%s)
    local age=$((now - cached_timestamp))
    
    if [[ ${age} -gt ${VALIDATION_CACHE_TTL} ]]; then
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            print_info "Validation cache expired for: ${cache_key}"
        fi
        return 1
    fi
    
    # Check if file hash matches
    if [[ "${cached_hash}" == "${current_hash}" ]]; then
        ((VALIDATION_CACHE_HITS++))
        ((VALIDATION_CACHE_SKIPPED_FILES++))
        return 0
    fi
    
    # File changed - cache invalid
    ((VALIDATION_CACHE_MISSES++))
    return 1
}

# Get cached validation result
# Args: $1 = cache_key
# Returns: Cached validation result (JSON)
get_validation_result() {
    local cache_key="$1"
    
    if [[ ! -f "${VALIDATION_CACHE_INDEX}" ]]; then
        return 1
    fi
    
    jq -r ".entries[\"${cache_key}\"] // empty" "${VALIDATION_CACHE_INDEX}" 2>/dev/null
}

# Save validation result to cache
# Args: $1 = cache_key, $2 = file_hash, $3 = validation_status (pass/fail), $4 = details (optional)
save_validation_result() {
    local cache_key="$1"
    local file_hash="$2"
    local validation_status="$3"
    local details="${4:-}"
    
    if [[ "${USE_VALIDATION_CACHE}" != "true" ]]; then
        return 0
    fi
    
    if [[ ! -f "${VALIDATION_CACHE_INDEX}" ]]; then
        init_validation_cache
    fi
    
    # Create cache entry
    local cache_entry=$(cat << EOF
{
  "file_hash": "${file_hash}",
  "validation_status": "${validation_status}",
  "details": "${details}",
  "timestamp": "$(date -Iseconds)",
  "timestamp_epoch": $(date +%s),
  "workflow_run_id": "${WORKFLOW_RUN_ID:-unknown}",
  "version": "${VALIDATION_CACHE_VERSION}"
}
EOF
)
    
    # Update index atomically
    local temp_index=$(mktemp)
    jq ".entries[\"${cache_key}\"] = ${cache_entry}" "${VALIDATION_CACHE_INDEX}" > "${temp_index}"
    mv "${temp_index}" "${VALIDATION_CACHE_INDEX}"
    
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        print_success "Validation result cached: ${cache_key}"
    fi
}

# ==============================================================================
# HIGH-LEVEL VALIDATION WRAPPERS
# ==============================================================================

# Validate file with caching
# Args: $1 = step_name, $2 = validation_type, $3 = file_path, $4 = validation_command
# Returns: 0 if valid (cached or fresh), 1 if invalid
validate_file_cached() {
    local step_name="$1"
    local validation_type="$2"
    local file_path="$3"
    local validation_cmd="$4"
    
    # Generate cache key and file hash
    local cache_key=$(generate_validation_cache_key "${step_name}" "${validation_type}" "${file_path}")
    local file_hash=$(calculate_file_hash "${file_path}")
    
    # Check cache first
    if check_validation_cache "${cache_key}" "${file_hash}"; then
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            print_success "✓ ${file_path} (cached)"
        fi
        return 0
    fi
    
    # Cache miss - run validation
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        print_info "Validating ${file_path}..."
    fi
    
    local validation_output
    local validation_result=0
    validation_output=$(eval "${validation_cmd}" 2>&1) || validation_result=$?
    
    # Save result to cache
    if [[ ${validation_result} -eq 0 ]]; then
        save_validation_result "${cache_key}" "${file_hash}" "pass" "OK"
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            print_success "✓ ${file_path}"
        fi
        return 0
    else
        save_validation_result "${cache_key}" "${file_hash}" "fail" "${validation_output:0:200}"
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            print_error "✗ ${file_path}: ${validation_output}"
        fi
        return 1
    fi
}

# Validate directory structure with caching
# Args: $1 = step_name, $2 = validation_type, $3 = directory_path, $4 = validation_command
# Returns: 0 if valid (cached or fresh), 1 if invalid
validate_directory_cached() {
    local step_name="$1"
    local validation_type="$2"
    local dir_path="$3"
    local validation_cmd="$4"
    
    # Generate cache key and directory hash
    local cache_key=$(generate_directory_validation_key "${step_name}" "${validation_type}" "${dir_path}")
    local dir_hash=$(calculate_directory_hash "${dir_path}")
    
    # Check cache first
    if check_validation_cache "${cache_key}" "${dir_hash}"; then
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            print_success "✓ ${dir_path}/ (cached)"
        fi
        return 0
    fi
    
    # Cache miss - run validation
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        print_info "Validating directory ${dir_path}/..."
    fi
    
    local validation_output
    local validation_result=0
    validation_output=$(eval "${validation_cmd}" 2>&1) || validation_result=$?
    
    # Save result to cache
    if [[ ${validation_result} -eq 0 ]]; then
        save_validation_result "${cache_key}" "${dir_hash}" "pass" "OK"
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            print_success "✓ ${dir_path}/"
        fi
        return 0
    else
        save_validation_result "${cache_key}" "${dir_hash}" "fail" "${validation_output:0:200}"
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            print_error "✗ ${dir_path}/: ${validation_output}"
        fi
        return 1
    fi
}

# Batch validate files with caching
# Args: $1 = step_name, $2 = validation_type, $3 = validation_command_template, $@ = file paths
# Returns: Count of failed validations
batch_validate_files_cached() {
    local step_name="$1"
    local validation_type="$2"
    local validation_cmd_template="$3"
    shift 3
    
    local failed_count=0
    local validated_count=0
    local cached_count=0
    
    for file_path in "$@"; do
        local cache_key=$(generate_validation_cache_key "${step_name}" "${validation_type}" "${file_path}")
        local file_hash=$(calculate_file_hash "${file_path}")
        
        # Check cache
        if check_validation_cache "${cache_key}" "${file_hash}"; then
            ((cached_count++))
            continue
        fi
        
        # Run validation (replace {file} placeholder)
        local validation_cmd="${validation_cmd_template//\{file\}/${file_path}}"
        local validation_result=0
        local validation_output
        validation_output=$(eval "${validation_cmd}" 2>&1) || validation_result=$?
        
        ((validated_count++))
        
        if [[ ${validation_result} -eq 0 ]]; then
            save_validation_result "${cache_key}" "${file_hash}" "pass" "OK"
        else
            save_validation_result "${cache_key}" "${file_hash}" "fail" "${validation_output:0:200}"
            ((failed_count++))
        fi
    done
    
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        print_info "Batch validation: ${cached_count} cached, ${validated_count} validated, ${failed_count} failed"
    fi
    
    return ${failed_count}
}

# ==============================================================================
# CACHE MANAGEMENT
# ==============================================================================

# Cleanup old cache entries
cleanup_validation_cache_old_entries() {
    if [[ "${USE_VALIDATION_CACHE}" != "true" ]]; then
        return 0
    fi
    
    if [[ ! -f "${VALIDATION_CACHE_INDEX}" ]]; then
        return 0
    fi
    
    local now=$(date +%s)
    local temp_index=$(mktemp)
    
    # Filter out expired entries using jq
    jq --arg now "${now}" --arg ttl "${VALIDATION_CACHE_TTL}" '
        .entries |= with_entries(
            select(
                (.value.timestamp_epoch | tonumber) + ($ttl | tonumber) > ($now | tonumber)
            )
        ) |
        .last_cleanup = (now | strftime("%Y-%m-%dT%H:%M:%S%z"))
    ' "${VALIDATION_CACHE_INDEX}" > "${temp_index}"
    
    if [[ -s "${temp_index}" ]]; then
        mv "${temp_index}" "${VALIDATION_CACHE_INDEX}"
        
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            local remaining=$(jq '.entries | length' "${VALIDATION_CACHE_INDEX}")
            print_info "Validation cache cleanup complete (${remaining} entries remaining)"
        fi
    else
        rm -f "${temp_index}"
    fi
}

# Invalidate cache entries for specific files
# Args: $@ = file paths
invalidate_files_cache() {
    if [[ ! -f "${VALIDATION_CACHE_INDEX}" ]]; then
        return 0
    fi
    
    local temp_index=$(mktemp)
    local jq_filter='.entries'
    
    for file_path in "$@"; do
        local normalized_path="${file_path#./}"
        # Remove any entry that matches this file path
        jq_filter+=" | with_entries(select(.key | contains(\"${normalized_path}\") | not))"
    done
    
    jq "${jq_filter}" "${VALIDATION_CACHE_INDEX}" > "${temp_index}"
    
    if [[ -s "${temp_index}" ]]; then
        mv "${temp_index}" "${VALIDATION_CACHE_INDEX}"
    else
        rm -f "${temp_index}"
    fi
}

# Clear entire validation cache
clear_validation_cache() {
    if [[ -d "${VALIDATION_CACHE_DIR}" ]]; then
        rm -rf "${VALIDATION_CACHE_DIR}"
        print_success "Validation cache cleared"
    fi
    init_validation_cache
}

# ==============================================================================
# CACHE STATISTICS
# ==============================================================================

# Get validation cache statistics
get_validation_cache_stats() {
    if [[ ! -f "${VALIDATION_CACHE_INDEX}" ]]; then
        echo "Validation cache not initialized"
        return 1
    fi
    
    local total_entries=$(jq '.entries | length' "${VALIDATION_CACHE_INDEX}")
    local cache_size=$(du -sh "${VALIDATION_CACHE_DIR}" 2>/dev/null | awk '{print $1}')
    local cache_created=$(jq -r '.created' "${VALIDATION_CACHE_INDEX}")
    local last_cleanup=$(jq -r '.last_cleanup' "${VALIDATION_CACHE_INDEX}")
    
    # Calculate hit rate
    local total_checks=$((VALIDATION_CACHE_HITS + VALIDATION_CACHE_MISSES))
    local hit_rate=0
    if [[ ${total_checks} -gt 0 ]]; then
        hit_rate=$(awk "BEGIN {printf \"%.1f\", (${VALIDATION_CACHE_HITS} / ${total_checks}) * 100}")
    fi
    
    cat << EOF

Validation Cache Statistics:
  Total Entries: ${total_entries}
  Cache Size: ${cache_size}
  Created: ${cache_created}
  Last Cleanup: ${last_cleanup}
  Location: ${VALIDATION_CACHE_DIR}

Current Run Metrics:
  Cache Hits: ${VALIDATION_CACHE_HITS}
  Cache Misses: ${VALIDATION_CACHE_MISSES}
  Hit Rate: ${hit_rate}%
  Files Skipped: ${VALIDATION_CACHE_SKIPPED_FILES}
EOF
}

# Export validation cache metrics for workflow metrics
export_validation_cache_metrics() {
    local total_checks=$((VALIDATION_CACHE_HITS + VALIDATION_CACHE_MISSES))
    local hit_rate=0
    
    if [[ ${total_checks} -gt 0 ]]; then
        hit_rate=$(awk "BEGIN {printf \"%.1f\", (${VALIDATION_CACHE_HITS} / ${total_checks}) * 100}")
    fi
    
    cat << EOF
{
  "validation_cache_hits": ${VALIDATION_CACHE_HITS},
  "validation_cache_misses": ${VALIDATION_CACHE_MISSES},
  "validation_cache_hit_rate": ${hit_rate},
  "validation_files_skipped": ${VALIDATION_CACHE_SKIPPED_FILES}
}
EOF
}

# ==============================================================================
# INTEGRATION WITH CHANGE DETECTION
# ==============================================================================

# Invalidate cache for changed files from git
invalidate_changed_files_cache() {
    local changed_files=$(git diff --name-only HEAD 2>/dev/null)
    local staged_files=$(git diff --cached --name-only 2>/dev/null)
    local all_changes=$(echo -e "${changed_files}\n${staged_files}" | sort -u | grep -v '^$')
    
    if [[ -z "${all_changes}" ]]; then
        return 0
    fi
    
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        local change_count=$(echo "${all_changes}" | wc -l)
        print_info "Invalidating cache for ${change_count} changed files"
    fi
    
    invalidate_files_cache ${all_changes}
}

# ==============================================================================
# EXPORTS
# ==============================================================================

# Export all public functions
export -f init_validation_cache
export -f calculate_file_hash calculate_files_hash calculate_directory_hash
export -f generate_validation_cache_key generate_directory_validation_key
export -f check_validation_cache get_validation_result save_validation_result
export -f validate_file_cached validate_directory_cached batch_validate_files_cached
export -f cleanup_validation_cache_old_entries invalidate_files_cache clear_validation_cache
export -f get_validation_cache_stats export_validation_cache_metrics
export -f invalidate_changed_files_cache

# Export configuration variables
export VALIDATION_CACHE_DIR VALIDATION_CACHE_INDEX USE_VALIDATION_CACHE
export VALIDATION_CACHE_HITS VALIDATION_CACHE_MISSES VALIDATION_CACHE_SKIPPED_FILES

# Module loaded
readonly STEP_VALIDATION_CACHE_LOADED=true
export STEP_VALIDATION_CACHE_LOADED

################################################################################
# Module initialized - Validation cache ready
################################################################################
