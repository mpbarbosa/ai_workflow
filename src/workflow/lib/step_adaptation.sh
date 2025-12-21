#!/usr/bin/env bash
set -euo pipefail

# Step Adaptation Module - Project Kind Adaptive Framework
# 
# This module provides functions for adapting workflow step execution based on
# detected project kind. It determines step relevance, loads step-specific
# configurations, and provides adaptation context to workflow steps.
#
# Dependencies:
#   - project_kind_detection.sh (PRIMARY_KIND, SECONDARY_KINDS)
#   - config.sh (load_yaml_value, load_yaml_section)
#
# Functions:
#   - should_execute_step()     : Determine if step should execute
#   - get_step_relevance()      : Get relevance level for step
#   - get_step_adaptations()    : Get step-specific adaptations
#   - get_adaptation_value()    : Get specific adaptation value
#   - list_step_adaptations()   : List all adaptations for step
#   - validate_step_relevance() : Validate relevance configuration
#
# Version: 1.0.0
# Created: 2025-12-18

set -euo pipefail

# Module version
readonly STEP_ADAPTATION_VERSION_MAJOR=1
readonly STEP_ADAPTATION_VERSION_MINOR=0
readonly STEP_ADAPTATION_VERSION_PATCH=0

# Determine config directory
if [[ -z "${CONFIG_DIR:-}" ]]; then
    SCRIPT_BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    CONFIG_DIR="${SCRIPT_BASE}/config"
fi

# Configuration paths
STEP_RELEVANCE_CONFIG="${CONFIG_DIR}/step_relevance.yaml"

# Relevance levels (in order of priority)
readonly RELEVANCE_REQUIRED="required"
readonly RELEVANCE_RECOMMENDED="recommended"
readonly RELEVANCE_OPTIONAL="optional"
readonly RELEVANCE_SKIP="skip"

# Cache for loaded configurations
declare -gA STEP_RELEVANCE_CACHE
declare -gA STEP_ADAPTATIONS_CACHE

#######################################
# Load a single value from YAML file using yq
# Arguments:
#   $1 - YAML path (e.g., "step_relevance.nodejs_api.step_00_analyze")
#   $2 - YAML file path
# Outputs:
#   Value from YAML or empty string
# Returns:
#   0 on success
#######################################
load_yaml_value() {
    local yaml_path="$1"
    local yaml_file="$2"
    
    if [[ ! -f "${yaml_file}" ]]; then
        return 1
    fi
    
    # Try different yq versions
    if command -v yq &>/dev/null; then
        local yq_version
        yq_version=$(yq --version 2>&1 || echo "")
        
        # Python yq (kislyuk/jq wrapper) - most common, check first
        if echo "${yq_version}" | grep -qE "(yq [0-9]+\.[0-9]+\.[0-9]+$|version [0-9]+\.[0-9]+\.[0-9]+$)" || \
           [[ "${yq_version}" =~ ^yq[[:space:]]?3\.[0-9]+\.[0-9]+$ ]]; then
            yq -r ".${yaml_path} // empty" "${yaml_file}" 2>/dev/null || echo ""
        # Try mikefarah yq v4
        elif echo "${yq_version}" | grep -qE "version (4|v4)"; then
            yq eval ".${yaml_path}" "${yaml_file}" 2>/dev/null | grep -v "^null$" || echo ""
        # Try mikefarah yq v3 (legacy)
        elif echo "${yq_version}" | grep -qE "mikefarah"; then
            yq r "${yaml_file}" "${yaml_path}" 2>/dev/null || echo ""
        # Default to Python yq format
        else
            yq -r ".${yaml_path} // empty" "${yaml_file}" 2>/dev/null || echo ""
        fi
    else
        echo ""
        return 1
    fi
}

#######################################
# Load a section from YAML file as key=value pairs
# Arguments:
#   $1 - YAML path (e.g., "step_adaptations.step_05_test_review.nodejs_api")
#   $2 - YAML file path
# Outputs:
#   Key=value pairs, one per line
# Returns:
#   0 on success
#######################################
load_yaml_section() {
    local yaml_path="$1"
    local yaml_file="$2"
    
    if [[ ! -f "${yaml_file}" ]]; then
        return 1
    fi
    
    # Try different yq versions
    if command -v yq &>/dev/null; then
        local yq_version
        yq_version=$(yq --version 2>&1 || echo "")
        
        # Python yq (kislyuk/jq wrapper)
        if echo "${yq_version}" | grep -qE "(yq [0-9]+\.[0-9]+\.[0-9]+$|version [0-9]+\.[0-9]+\.[0-9]+$)" || \
           [[ "${yq_version}" =~ ^yq[[:space:]]?3\.[0-9]+\.[0-9]+$ ]]; then
            yq -r ".${yaml_path} | to_entries | .[] | \"\(.key)=\(.value)\"" "${yaml_file}" 2>/dev/null || echo ""
        # Try mikefarah yq v4
        elif echo "${yq_version}" | grep -qE "version (4|v4)"; then
            yq eval ".${yaml_path} | to_entries | .[] | .key + \"=\" + (.value | tostring)" "${yaml_file}" 2>/dev/null || echo ""
        # Try mikefarah yq v3 (legacy)
        elif echo "${yq_version}" | grep -qE "mikefarah"; then
            yq r "${yaml_file}" "${yaml_path}" 2>/dev/null | grep -v "^---" || echo ""
        # Default to Python yq format
        else
            yq -r ".${yaml_path} | to_entries | .[] | \"\(.key)=\(.value)\"" "${yaml_file}" 2>/dev/null || echo ""
        fi
    else
        echo ""
        return 1
    fi
}

#######################################
# Determine if a step should be executed based on project kind and user preferences
# Globals:
#   PRIMARY_KIND - Current project kind
#   SKIP_STEPS - Array of steps to skip (optional)
#   INCLUDE_STEPS - Array of steps to include (optional)
# Arguments:
#   $1 - Step name (e.g., "step_05_test_review")
# Returns:
#   0 if step should execute, 1 otherwise
#######################################
should_execute_step() {
    local step_name="$1"
    local project_kind="${PRIMARY_KIND:-generic}"
    
    # Get relevance level
    local relevance
    relevance=$(get_step_relevance "${step_name}" "${project_kind}")
    
    case "${relevance}" in
        "${RELEVANCE_REQUIRED}")
            # Always execute required steps
            return 0
            ;;
        "${RELEVANCE_RECOMMENDED}")
            # Execute unless explicitly skipped by user
            if [[ -n "${SKIP_STEPS:-}" ]] && [[ " ${SKIP_STEPS[*]:-} " =~ " ${step_name} " ]]; then
                log_info "Skipping recommended step (user preference): ${step_name}"
                return 1
            fi
            return 0
            ;;
        "${RELEVANCE_OPTIONAL}")
            # Execute only if explicitly included by user
            if [[ -n "${INCLUDE_STEPS:-}" ]] && [[ " ${INCLUDE_STEPS[*]:-} " =~ " ${step_name} " ]]; then
                log_info "Including optional step (user preference): ${step_name}"
                return 0
            fi
            log_info "Skipping optional step for ${project_kind}: ${step_name}"
            return 1
            ;;
        "${RELEVANCE_SKIP}")
            # Never execute unless force-included
            if [[ -n "${FORCE_INCLUDE_STEPS:-}" ]] && [[ " ${FORCE_INCLUDE_STEPS[*]:-} " =~ " ${step_name} " ]]; then
                log_warning "Force-including skipped step: ${step_name}"
                return 0
            fi
            log_info "Skipping irrelevant step for ${project_kind}: ${step_name}"
            return 1
            ;;
        *)
            # Unknown relevance, default to execute for safety
            log_warning "Unknown relevance '${relevance}' for ${step_name}, executing by default"
            return 0
            ;;
    esac
}

#######################################
# Get the relevance level for a step
# Globals:
#   STEP_RELEVANCE_CACHE - Cache for loaded relevance values
# Arguments:
#   $1 - Step name
#   $2 - Project kind (optional, defaults to PRIMARY_KIND)
# Outputs:
#   Relevance level (required|recommended|optional|skip)
# Returns:
#   0 on success, 1 on error
#######################################
get_step_relevance() {
    local step_name="$1"
    local project_kind="${2:-${PRIMARY_KIND:-generic}}"
    
    # Check cache first
    local cache_key="${project_kind}.${step_name}"
    if [[ -n "${STEP_RELEVANCE_CACHE[${cache_key}]:-}" ]]; then
        echo "${STEP_RELEVANCE_CACHE[${cache_key}]}"
        return 0
    fi
    
    # Load from configuration
    local relevance
    relevance=$(load_yaml_value "step_relevance.${project_kind}.${step_name}" \
                               "${STEP_RELEVANCE_CONFIG}" 2>/dev/null)
    
    if [[ -z "${relevance}" ]]; then
        # Fall back to generic if kind-specific not found
        if [[ "${project_kind}" != "generic" ]]; then
            relevance=$(load_yaml_value "step_relevance.generic.${step_name}" \
                                       "${STEP_RELEVANCE_CONFIG}" 2>/dev/null)
        fi
        
        # Default to recommended if still not found
        if [[ -z "${relevance}" ]]; then
            relevance="${RELEVANCE_RECOMMENDED}"
        fi
    fi
    
    # Cache the value
    STEP_RELEVANCE_CACHE[${cache_key}]="${relevance}"
    
    echo "${relevance}"
    return 0
}

#######################################
# Get step-specific adaptations for project kind
# Globals:
#   STEP_ADAPTATIONS_CACHE - Cache for loaded adaptations
# Arguments:
#   $1 - Step name
#   $2 - Project kind (optional, defaults to PRIMARY_KIND)
# Outputs:
#   YAML section as key=value pairs
# Returns:
#   0 on success, 1 on error
#######################################
get_step_adaptations() {
    local step_name="$1"
    local project_kind="${2:-${PRIMARY_KIND:-generic}}"
    
    # Check cache first
    local cache_key="${project_kind}.${step_name}"
    if [[ -n "${STEP_ADAPTATIONS_CACHE[${cache_key}]:-}" ]]; then
        echo "${STEP_ADAPTATIONS_CACHE[${cache_key}]}"
        return 0
    fi
    
    # Load from configuration
    local adaptations
    adaptations=$(load_yaml_section "step_adaptations.${step_name}.${project_kind}" \
                                   "${STEP_RELEVANCE_CONFIG}" 2>/dev/null)
    
    if [[ -z "${adaptations}" ]]; then
        # No adaptations found for this combination
        adaptations=""
    fi
    
    # Cache the value
    STEP_ADAPTATIONS_CACHE[${cache_key}]="${adaptations}"
    
    echo "${adaptations}"
    return 0
}

#######################################
# Get a specific adaptation value for a step
# Arguments:
#   $1 - Step name
#   $2 - Adaptation key (e.g., "minimum_coverage")
#   $3 - Project kind (optional, defaults to PRIMARY_KIND)
#   $4 - Default value (optional)
# Outputs:
#   Adaptation value or default
# Returns:
#   0 on success
#######################################
get_adaptation_value() {
    local step_name="$1"
    local adaptation_key="$2"
    local project_kind="${3:-${PRIMARY_KIND:-generic}}"
    local default_value="${4:-}"
    
    # Load value from configuration
    local value
    value=$(load_yaml_value "step_adaptations.${step_name}.${project_kind}.${adaptation_key}" \
                           "${STEP_RELEVANCE_CONFIG}" 2>/dev/null)
    
    if [[ -z "${value}" ]]; then
        echo "${default_value}"
    else
        echo "${value}"
    fi
    
    return 0
}

#######################################
# List all available adaptations for a step
# Arguments:
#   $1 - Step name
#   $2 - Project kind (optional, defaults to PRIMARY_KIND)
# Outputs:
#   List of adaptation keys (one per line)
# Returns:
#   0 on success
#######################################
list_step_adaptations() {
    local step_name="$1"
    local project_kind="${2:-${PRIMARY_KIND:-generic}}"
    
    # Get all adaptations
    local adaptations
    adaptations=$(get_step_adaptations "${step_name}" "${project_kind}")
    
    if [[ -z "${adaptations}" ]]; then
        return 0
    fi
    
    # Extract keys (everything before '=')
    echo "${adaptations}" | grep -o '^[^=]*' | sort -u
    
    return 0
}

#######################################
# Validate step relevance configuration
# Globals:
#   STEP_RELEVANCE_CONFIG - Configuration file path
# Outputs:
#   Validation errors (if any)
# Returns:
#   0 if valid, 1 if errors found
#######################################
validate_step_relevance() {
    local errors=0
    
    # Check if configuration file exists
    if [[ ! -f "${STEP_RELEVANCE_CONFIG}" ]]; then
        echo "ERROR: Step relevance configuration not found: ${STEP_RELEVANCE_CONFIG}" >&2
        return 1
    fi
    
    # Validate structure (basic checks)
    if ! grep -q "^step_relevance:" "${STEP_RELEVANCE_CONFIG}" 2>/dev/null; then
        echo "ERROR: Missing step_relevance section in configuration" >&2
        ((errors++))
    fi
    
    if ! grep -q "^step_adaptations:" "${STEP_RELEVANCE_CONFIG}" 2>/dev/null; then
        echo "WARNING: Missing step_adaptations section in configuration" >&2
    fi
    
    # Check for valid relevance values
    local invalid_relevance
    invalid_relevance=$(grep -E "^\s+step_[0-9]+.*:\s+" "${STEP_RELEVANCE_CONFIG}" | \
                       grep -v -E "(required|recommended|optional|skip)" || true)
    
    if [[ -n "${invalid_relevance}" ]]; then
        echo "WARNING: Possible invalid relevance values found:" >&2
        echo "${invalid_relevance}" >&2
    fi
    
    if [[ ${errors} -gt 0 ]]; then
        return 1
    fi
    
    return 0
}

#######################################
# Get list of required steps for a project kind
# Arguments:
#   $1 - Project kind (optional, defaults to PRIMARY_KIND)
# Outputs:
#   List of required step names (one per line)
# Returns:
#   0 on success
#######################################
get_required_steps() {
    local project_kind="${1:-${PRIMARY_KIND:-generic}}"
    
    # Get all steps from configuration
    local all_steps
    all_steps=$(load_yaml_section "step_relevance.${project_kind}" \
                                  "${STEP_RELEVANCE_CONFIG}" 2>/dev/null | \
                grep "=required$" | cut -d'=' -f1)
    
    echo "${all_steps}"
    return 0
}

#######################################
# Get list of optional/skippable steps for a project kind
# Arguments:
#   $1 - Project kind (optional, defaults to PRIMARY_KIND)
# Outputs:
#   List of optional/skip step names (one per line)
# Returns:
#   0 on success
#######################################
get_skippable_steps() {
    local project_kind="${1:-${PRIMARY_KIND:-generic}}"
    
    # Get all steps that are optional or skip
    local skippable_steps
    skippable_steps=$(load_yaml_section "step_relevance.${project_kind}" \
                                       "${STEP_RELEVANCE_CONFIG}" 2>/dev/null | \
                     grep -E "=(optional|skip)$" | cut -d'=' -f1)
    
    echo "${skippable_steps}"
    return 0
}

#######################################
# Display step execution plan based on project kind
# Arguments:
#   $1 - Project kind (optional, defaults to PRIMARY_KIND)
# Outputs:
#   Formatted execution plan
# Returns:
#   0 on success
#######################################
display_execution_plan() {
    local project_kind="${1:-${PRIMARY_KIND:-generic}}"
    
    echo "Step Execution Plan for '${project_kind}':"
    echo "============================================"
    echo ""
    
    # Get all steps
    local step_names=(
        "step_00_analyze"
        "step_01_documentation"
        "step_02_consistency"
        "step_03_script_refs"
        "step_04_directory"
        "step_05_test_review"
        "step_06_test_gen"
        "step_07_test_exec"
        "step_08_dependencies"
        "step_09_code_quality"
        "step_10_context"
        "step_11_git"
        "step_12_markdown_lint"
    )
    
    for step_name in "${step_names[@]}"; do
        local relevance
        relevance=$(get_step_relevance "${step_name}" "${project_kind}")
        
        local status_icon
        case "${relevance}" in
            "${RELEVANCE_REQUIRED}")     status_icon="✓ [REQUIRED]   " ;;
            "${RELEVANCE_RECOMMENDED}")  status_icon="○ [RECOMMENDED]" ;;
            "${RELEVANCE_OPTIONAL}")     status_icon="◌ [OPTIONAL]   " ;;
            "${RELEVANCE_SKIP}")         status_icon="✗ [SKIP]       " ;;
            *)                           status_icon="? [UNKNOWN]    " ;;
        esac
        
        echo "  ${status_icon} ${step_name}"
    done
    
    echo ""
    return 0
}

# Module initialization
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Sourced - validate configuration if not in test mode
    if [[ "${TEST_MODE:-false}" != "true" ]]; then
        if [[ -f "${STEP_RELEVANCE_CONFIG}" ]]; then
            if ! validate_step_relevance 2>/dev/null; then
                echo "WARNING: Step relevance configuration validation failed" >&2
            fi
        fi
    fi
fi
