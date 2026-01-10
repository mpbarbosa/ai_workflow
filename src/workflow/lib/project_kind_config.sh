#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Project Kind Configuration Module
# Purpose: Load and access project kind configuration from YAML
# Version: 1.0.0
# Part of: Tests & Documentation Workflow Automation v2.3.1
################################################################################

# Module metadata
readonly PROJECT_KIND_CONFIG_VERSION="1.0.0"

# Get the directory where this script is located (use local variable to avoid overwriting global SCRIPT_DIR)
_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration file path
readonly PROJECT_KIND_CONFIG_FILE="${_MODULE_DIR}/../config/project_kinds.yaml"
export PROJECT_KIND_CONFIG_FILE

# Cache for parsed configuration
declare -g -A PROJECT_KIND_CACHE

################################################################################
# Configuration Loading Functions
################################################################################

# Detect yq version
detect_yq_version() {
    if ! command -v yq &> /dev/null; then
        echo "none"
        return
    fi
    
    local help_output
    help_output=$(yq --help 2>&1 || echo "")
    
    # Check for kislyuk yq (jq wrapper for YAML)
    if [[ "${help_output}" == *"jq wrapper"* ]] || [[ "${help_output}" == *"kislyuk"* ]]; then
        echo "kislyuk"
        return
    fi
    
    local version_output
    version_output=$(yq --version 2>&1 || echo "")
    
    if [[ "${version_output}" == *"mikefarah"* ]] || [[ "${version_output}" == *"version 4"* ]]; then
        echo "v4"
    elif [[ "${version_output}" == *"version 3"* ]] || [[ "${version_output}" == *"3."* ]]; then
        echo "v3"
    else
        echo "unknown"
    fi
}

YQ_VERSION=$(detect_yq_version)
export YQ_VERSION

# Load project kind configuration from YAML file
# Uses yq to parse YAML into shell-friendly format
# Returns: 0 on success, 1 on failure
load_project_kind_config() {
    local kind="$1"
    
    # Check if yq is available
    if [[ "${YQ_VERSION}" == "none" ]]; then
        echo "Warning: yq not found. Using basic YAML parsing." >&2
        return 1
    fi
    
    # Check if config file exists
    if [[ ! -f "${PROJECT_KIND_CONFIG_FILE}" ]]; then
        echo "Error: Project kind configuration file not found: ${PROJECT_KIND_CONFIG_FILE}" >&2
        return 1
    fi
    
    # Verify kind exists in configuration (version-specific)
    local exists=false
    if [[ "${YQ_VERSION}" == "v4" ]]; then
        if yq eval ".project_kinds.${kind}" "${PROJECT_KIND_CONFIG_FILE}" > /dev/null 2>&1; then
            exists=true
        fi
    elif [[ "${YQ_VERSION}" == "kislyuk" ]]; then
        # kislyuk yq uses jq syntax
        if yq -e ".project_kinds.${kind}" "${PROJECT_KIND_CONFIG_FILE}" > /dev/null 2>&1; then
            exists=true
        fi
    else
        # yq v3 syntax
        if yq r "${PROJECT_KIND_CONFIG_FILE}" "project_kinds.${kind}" > /dev/null 2>&1; then
            exists=true
        fi
    fi
    
    if ! ${exists}; then
        echo "Error: Project kind '${kind}' not found in configuration" >&2
        return 1
    fi
    
    # Cache the kind for quick access
    PROJECT_KIND_CACHE["current"]="${kind}"
    
    return 0
}

################################################################################
# Configuration Access Functions
################################################################################

# Get a configuration value for a project kind
# Usage: get_project_kind_config <kind> <path>
# Example: get_project_kind_config "nodejs_api" ".testing.test_command"
# Returns: Configuration value or empty string
get_project_kind_config() {
    local kind="$1"
    local config_path="$2"
    
    if [[ "${YQ_VERSION}" == "none" ]]; then
        return 1
    fi
    
    local value
    if [[ "${YQ_VERSION}" == "v4" ]]; then
        local full_path=".project_kinds.${kind}${config_path}"
        value=$(yq eval "${full_path}" "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null || echo "")
    elif [[ "${YQ_VERSION}" == "kislyuk" ]]; then
        # kislyuk yq uses jq syntax
        local full_path=".project_kinds.${kind}${config_path}"
        value=$(yq -r "${full_path}" "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null || echo "")
    else
        # yq v3 - remove leading dot from config_path
        local clean_path="${config_path#.}"
        value=$(yq r "${PROJECT_KIND_CONFIG_FILE}" "project_kinds.${kind}.${clean_path}" 2>/dev/null || echo "")
    fi
    
    # Return empty string for null values
    if [[ "${value}" == "null" ]] || [[ "${value}" == "---" ]]; then
        echo ""
    else
        echo "${value}"
    fi
}

# Get project kind name
get_project_kind_name() {
    local kind="$1"
    get_project_kind_config "${kind}" ".name"
}

# Get project kind description
get_project_kind_description() {
    local kind="$1"
    get_project_kind_config "${kind}" ".description"
}

################################################################################
# Project Workflow Configuration Functions
################################################################################

# Get project kind from .workflow-config.yaml
# Arguments:
#   $1 - Project directory (optional, defaults to current directory)
# Returns:
#   Project kind string or empty string if not found
# Example:
#   kind=$(get_project_kind)
#   kind=$(get_project_kind "/path/to/project")
get_project_kind() {
    local project_dir="${1:-.}"
    local config_file="${project_dir}/.workflow-config.yaml"
    
    # Check alternate extension
    if [[ ! -f "${config_file}" ]] && [[ -f "${project_dir}/.workflow-config.yml" ]]; then
        config_file="${project_dir}/.workflow-config.yml"
    fi
    
    # Return empty if config doesn't exist
    if [[ ! -f "${config_file}" ]]; then
        return 0
    fi
    
    # Parse project.kind or project.type from YAML config
    local kind=""
    
    if [[ "${YQ_VERSION}" == "none" ]]; then
        # Fallback: simple awk-based parsing - check both kind and type
        kind=$(awk '
            BEGIN { in_project=0 }
            /^project:/ { in_project=1; next }
            in_project && /^[^ ]/ { in_project=0 }
            in_project && /^[[:space:]]+(kind|type):/ {
                sub(/^[[:space:]]+(kind|type):[[:space:]]*/, "")
                gsub(/"/, "")
                gsub(/'\''/, "")
                print
                exit
            }
        ' "${config_file}")
    elif [[ "${YQ_VERSION}" == "v4" ]]; then
        # Try project.kind first, then project.type
        kind=$(yq eval ".project.kind" "${config_file}" 2>/dev/null || echo "")
        if [[ -z "$kind" ]] || [[ "$kind" == "null" ]]; then
            kind=$(yq eval ".project.type" "${config_file}" 2>/dev/null || echo "")
        fi
    elif [[ "${YQ_VERSION}" == "kislyuk" ]]; then
        # Try project.kind first, then project.type
        kind=$(yq -r ".project.kind" "${config_file}" 2>/dev/null || echo "")
        if [[ -z "$kind" ]] || [[ "$kind" == "null" ]]; then
            kind=$(yq -r ".project.type" "${config_file}" 2>/dev/null || echo "")
        fi
    else
        # yq v3 - try project.kind first, then project.type
        kind=$(yq r "${config_file}" "project.kind" 2>/dev/null || echo "")
        if [[ -z "$kind" ]] || [[ "$kind" == "null" ]]; then
            kind=$(yq r "${config_file}" "project.type" 2>/dev/null || echo "")
        fi
    fi
    
    # Normalize: convert hyphens to underscores
    kind="${kind//-/_}"
    
    # Return empty string for null values
    if [[ "${kind}" == "null" ]] || [[ "${kind}" == "---" ]]; then
        echo ""
    else
        echo "${kind}"
    fi
}

################################################################################
# Validation Configuration Functions
################################################################################

# Get required files for project kind
# Returns: Space-separated list of required files
get_required_files() {
    local kind="$1"
    _get_array_values "${kind}" "validation.required_files"
}

# Helper function to get array values
_get_array_values() {
    local kind="$1"
    local path="$2"
    
    if [[ "${YQ_VERSION}" == "none" ]]; then
        return 0
    fi
    
    if [[ "${YQ_VERSION}" == "v4" ]]; then
        yq eval ".project_kinds.${kind}.${path}[]" \
            "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null | tr '\n' ' ' || echo ""
    elif [[ "${YQ_VERSION}" == "kislyuk" ]]; then
        yq -r ".project_kinds.${kind}.${path}[]?" \
            "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null | tr '\n' ' ' || echo ""
    else
        yq r "${PROJECT_KIND_CONFIG_FILE}" "project_kinds.${kind}.${path}[*]" 2>/dev/null | tr '\n' ' ' || echo ""
    fi
}

# Get required directories for project kind
get_required_directories() {
    local kind="$1"
    _get_array_values "${kind}" "validation.required_directories"
}

# Get optional files for project kind
get_optional_files() {
    local kind="$1"
    _get_array_values "${kind}" "validation.optional_files"
}

# Get file patterns for project kind
get_file_patterns() {
    local kind="$1"
    _get_array_values "${kind}" "validation.file_patterns"
}

################################################################################
# Testing Configuration Functions
################################################################################

# Get test framework for project kind
get_test_framework() {
    local kind="$1"
    get_project_kind_config "${kind}" ".testing.test_framework"
}

# Get test directory for project kind
get_test_directory() {
    local kind="$1"
    get_project_kind_config "${kind}" ".testing.test_directory"
}

# Get test file pattern for project kind
get_test_file_pattern() {
    local kind="$1"
    get_project_kind_config "${kind}" ".testing.test_file_pattern"
}

# Get test command for project kind
get_test_command() {
    local kind="$1"
    get_project_kind_config "${kind}" ".testing.test_command"
}

# Check if coverage is required for project kind
is_coverage_required() {
    local kind="$1"
    local required
    required=$(get_project_kind_config "${kind}" ".testing.coverage_required")
    [[ "${required}" == "true" ]]
}

# Get coverage threshold for project kind
get_coverage_threshold() {
    local kind="$1"
    get_project_kind_config "${kind}" ".testing.coverage_threshold"
}

################################################################################
# Quality Configuration Functions
################################################################################

# Get list of linters for project kind
# Returns: JSON array of linter configurations
get_linters() {
    local kind="$1"
    
    if [[ "${YQ_VERSION}" == "none" ]]; then
        echo "[]"
        return 0
    fi
    
    if [[ "${YQ_VERSION}" == "v4" ]]; then
        yq eval -o=json ".project_kinds.${kind}.quality.linters" \
            "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null || echo "[]"
    elif [[ "${YQ_VERSION}" == "kislyuk" ]]; then
        yq ".project_kinds.${kind}.quality.linters" \
            "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null || echo "[]"
    else
        yq r -j "${PROJECT_KIND_CONFIG_FILE}" "project_kinds.${kind}.quality.linters" 2>/dev/null || echo "[]"
    fi
}

# Get enabled linters for project kind
# Returns: Space-separated list of enabled linter names
get_enabled_linters() {
    local kind="$1"
    
    if [[ "${YQ_VERSION}" == "none" ]]; then
        return 0
    fi
    
    if [[ "${YQ_VERSION}" == "v4" ]]; then
        yq eval ".project_kinds.${kind}.quality.linters[] | select(.enabled == true) | .name" \
            "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null | tr '\n' ' ' || echo ""
    elif [[ "${YQ_VERSION}" == "kislyuk" ]]; then
        yq -r ".project_kinds.${kind}.quality.linters[]? | select(.enabled == true) | .name" \
            "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null | tr '\n' ' ' || echo ""
    else
        # For yq v3, we need a different approach - get all linter names and check enabled status
        local linter_count
        linter_count=$(yq r "${PROJECT_KIND_CONFIG_FILE}" "project_kinds.${kind}.quality.linters" -l 2>/dev/null || echo 0)
        local enabled_linters=""
        for ((i=0; i<linter_count; i++)); do
            local enabled
            enabled=$(yq r "${PROJECT_KIND_CONFIG_FILE}" "project_kinds.${kind}.quality.linters[$i].enabled" 2>/dev/null || echo "false")
            if [[ "${enabled}" == "true" ]]; then
                local name
                name=$(yq r "${PROJECT_KIND_CONFIG_FILE}" "project_kinds.${kind}.quality.linters[$i].name" 2>/dev/null || echo "")
                if [[ -n "${name}" ]]; then
                    enabled_linters="${enabled_linters} ${name}"
                fi
            fi
        done
        echo "${enabled_linters# }"
    fi
}

# Check if documentation is required
is_documentation_required() {
    local kind="$1"
    local required
    required=$(get_project_kind_config "${kind}" ".quality.documentation_required")
    [[ "${required}" == "true" ]]
}

# Check if README is required
is_readme_required() {
    local kind="$1"
    local required
    required=$(get_project_kind_config "${kind}" ".quality.readme_required")
    [[ "${required}" == "true" ]]
}

################################################################################
# Dependencies Configuration Functions
################################################################################

# Get package files for project kind
get_package_files() {
    local kind="$1"
    _get_array_values "${kind}" "dependencies.package_files"
}

# Get lock files for project kind
get_lock_files() {
    local kind="$1"
    _get_array_values "${kind}" "dependencies.lock_files"
}

# Check if dependency validation is required
is_dependency_validation_required() {
    local kind="$1"
    local required
    required=$(get_project_kind_config "${kind}" ".dependencies.validation_required")
    [[ "${required}" == "true" ]]
}

# Check if security audit is required
is_security_audit_required() {
    local kind="$1"
    local required
    required=$(get_project_kind_config "${kind}" ".dependencies.security_audit_required")
    [[ "${required}" == "true" ]]
}

# Get security audit command
get_audit_command() {
    local kind="$1"
    get_project_kind_config "${kind}" ".dependencies.audit_command"
}

################################################################################
# Build Configuration Functions
################################################################################

# Check if build is required
is_build_required() {
    local kind="$1"
    local required
    required=$(get_project_kind_config "${kind}" ".build.required")
    [[ "${required}" == "true" ]]
}

# Get build command
get_build_command() {
    local kind="$1"
    get_project_kind_config "${kind}" ".build.build_command"
}

# Get build output directory
get_build_output_directory() {
    local kind="$1"
    get_project_kind_config "${kind}" ".build.output_directory"
}

################################################################################
# Deployment Configuration Functions
################################################################################

# Get deployment type
get_deployment_type() {
    local kind="$1"
    get_project_kind_config "${kind}" ".deployment.type"
}

# Check if build is required for deployment
is_deployment_build_required() {
    local kind="$1"
    local required
    required=$(get_project_kind_config "${kind}" ".deployment.requires_build")
    [[ "${required}" == "true" ]]
}

# Get artifact patterns for deployment
get_artifact_patterns() {
    local kind="$1"
    _get_array_values "${kind}" "deployment.artifact_patterns"
}

################################################################################
# Utility Functions
################################################################################

# List all available project kinds
list_project_kinds() {
    if [[ "${YQ_VERSION}" == "none" ]]; then
        echo "shell_script_automation nodejs_api static_website react_spa python_app generic"
        return 0
    fi
    
    if [[ "${YQ_VERSION}" == "v4" ]]; then
        yq eval '.project_kinds | keys | .[]' "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null || \
            echo "shell_script_automation nodejs_api static_website react_spa python_app generic"
    elif [[ "${YQ_VERSION}" == "kislyuk" ]]; then
        yq -r '.project_kinds | keys[]' "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null || \
            echo "shell_script_automation nodejs_api static_website react_spa python_app generic"
    else
        yq r "${PROJECT_KIND_CONFIG_FILE}" "project_kinds" --printMode k 2>/dev/null | sed 's/^project_kinds\.//' || \
            echo "shell_script_automation nodejs_api static_website react_spa python_app generic"
    fi
}

# Validate project against kind configuration
# Returns: 0 if valid, 1 if validation fails
validate_project_kind() {
    local kind="$1"
    local project_root="${2:-.}"
    
    local required_files
    required_files=$(get_required_files "${kind}")
    
    # Check required files
    for file_pattern in ${required_files}; do
        if ! compgen -G "${project_root}/${file_pattern}" > /dev/null 2>&1; then
            echo "Missing required file: ${file_pattern}" >&2
            return 1
        fi
    done
    
    local required_dirs
    required_dirs=$(get_required_directories "${kind}")
    
    # Check required directories
    for dir_pattern in ${required_dirs}; do
        # Handle pipe-separated alternatives
        if [[ "${dir_pattern}" == *"|"* ]]; then
            local found=false
            IFS='|' read -ra alternatives <<< "${dir_pattern}"
            for alt in "${alternatives[@]}"; do
                if [[ -d "${project_root}/${alt}" ]]; then
                    found=true
                    break
                fi
            done
            if ! ${found}; then
                echo "Missing required directory (one of): ${dir_pattern}" >&2
                return 1
            fi
        else
            if [[ ! -d "${project_root}/${dir_pattern}" ]]; then
                echo "Missing required directory: ${dir_pattern}" >&2
                return 1
            fi
        fi
    done
    
    return 0
}

# Print project kind configuration summary
print_project_kind_config() {
    local kind="$1"
    
    echo "Project Kind: $(get_project_kind_name "${kind}")"
    echo "Description: $(get_project_kind_description "${kind}")"
    echo ""
    echo "Testing:"
    echo "  Framework: $(get_test_framework "${kind}")"
    echo "  Test Directory: $(get_test_directory "${kind}")"
    echo "  Test Command: $(get_test_command "${kind}")"
    echo "  Coverage Required: $(is_coverage_required "${kind}" && echo "Yes" || echo "No")"
    echo ""
    echo "Quality:"
    echo "  Enabled Linters: $(get_enabled_linters "${kind}")"
    echo "  Documentation Required: $(is_documentation_required "${kind}" && echo "Yes" || echo "No")"
    echo ""
    echo "Dependencies:"
    echo "  Package Files: $(get_package_files "${kind}")"
    echo "  Validation Required: $(is_dependency_validation_required "${kind}" && echo "Yes" || echo "No")"
    echo ""
    echo "Build:"
    echo "  Build Required: $(is_build_required "${kind}" && echo "Yes" || echo "No")"
    echo "  Build Command: $(get_build_command "${kind}")"
}

################################################################################
# Module Initialization
################################################################################

# Verify configuration file exists on module load
if [[ ! -f "${PROJECT_KIND_CONFIG_FILE}" ]]; then
    echo "Warning: Project kind configuration file not found: ${PROJECT_KIND_CONFIG_FILE}" >&2
fi

# Export functions for use in other modules
export -f detect_yq_version
export -f load_project_kind_config
export -f get_project_kind_config
export -f get_project_kind_name
export -f get_project_kind_description
export -f get_project_kind
export -f _get_array_values
export -f get_required_files
export -f get_required_directories
export -f get_optional_files
export -f get_file_patterns
export -f get_test_framework
export -f get_test_directory
export -f get_test_file_pattern
export -f get_test_command
export -f is_coverage_required
export -f get_coverage_threshold
export -f get_linters
export -f get_enabled_linters
export -f is_documentation_required
export -f is_readme_required
export -f get_package_files
export -f get_lock_files
export -f is_dependency_validation_required
export -f is_security_audit_required
export -f get_audit_command
export -f is_build_required
export -f get_build_command
export -f get_build_output_directory
export -f get_deployment_type
export -f is_deployment_build_required
export -f get_artifact_patterns
export -f list_project_kinds
export -f validate_project_kind
export -f print_project_kind_config

################################################################################
# AI Guidance Functions
################################################################################

# Get language-specific testing standards for AI prompts
# Usage: get_language_testing_standards <project_kind>
# Returns: Newline-separated list of testing standards
get_language_testing_standards() {
    local project_kind="${1:-}"
    
    if [[ -z "${project_kind}" ]]; then
        project_kind=$(get_project_kind 2>/dev/null || echo "generic")
    fi
    
    local yq_version
    yq_version=$(detect_yq_version)
    
    if [[ "${yq_version}" == "none" ]]; then
        echo "- Follow language-appropriate testing framework conventions"
        return
    fi
    
    local standards
    if [[ "${yq_version}" == "v4" ]]; then
        standards=$(yq eval ".project_kinds.${project_kind}.ai_guidance.testing_standards[]" "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null || echo "")
    elif [[ "${yq_version}" == "kislyuk" ]]; then
        standards=$(yq ".project_kinds.${project_kind}.ai_guidance.testing_standards[]" "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null | sed 's/"//g' || echo "")
    else
        standards=$(yq r "${PROJECT_KIND_CONFIG_FILE}" "project_kinds.${project_kind}.ai_guidance.testing_standards[*]" 2>/dev/null || echo "")
    fi
    
    if [[ -z "${standards}" ]]; then
        echo "- Follow language-appropriate testing framework conventions"
    else
        echo "${standards}" | sed 's/^/- /'
    fi
}

# Get language-specific style guides for AI prompts
# Usage: get_language_style_guides <project_kind>
# Returns: Newline-separated list of style guides
get_language_style_guides() {
    local project_kind="${1:-}"
    
    if [[ -z "${project_kind}" ]]; then
        project_kind=$(get_project_kind 2>/dev/null || echo "generic")
    fi
    
    local yq_version
    yq_version=$(detect_yq_version)
    
    if [[ "${yq_version}" == "none" ]]; then
        echo "- Follow language-specific style guides"
        return
    fi
    
    local guides
    if [[ "${yq_version}" == "v4" ]]; then
        guides=$(yq eval ".project_kinds.${project_kind}.ai_guidance.style_guides[]" "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null || echo "")
    elif [[ "${yq_version}" == "kislyuk" ]]; then
        guides=$(yq ".project_kinds.${project_kind}.ai_guidance.style_guides[]" "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null | sed 's/"//g' || echo "")
    else
        guides=$(yq r "${PROJECT_KIND_CONFIG_FILE}" "project_kinds.${project_kind}.ai_guidance.style_guides[*]" 2>/dev/null || echo "")
    fi
    
    if [[ -z "${guides}" ]]; then
        echo "- Follow language-specific style guides"
    else
        echo "${guides}" | sed 's/^/- /'
    fi
}

# Get language-specific best practices for AI prompts
# Usage: get_language_best_practices <project_kind>
# Returns: Newline-separated list of best practices
get_language_best_practices() {
    local project_kind="${1:-}"
    
    if [[ -z "${project_kind}" ]]; then
        project_kind=$(get_project_kind 2>/dev/null || echo "generic")
    fi
    
    local yq_version
    yq_version=$(detect_yq_version)
    
    if [[ "${yq_version}" == "none" ]]; then
        echo "- Follow language-appropriate best practices"
        return
    fi
    
    local practices
    if [[ "${yq_version}" == "v4" ]]; then
        practices=$(yq eval ".project_kinds.${project_kind}.ai_guidance.best_practices[]" "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null || echo "")
    elif [[ "${yq_version}" == "kislyuk" ]]; then
        practices=$(yq ".project_kinds.${project_kind}.ai_guidance.best_practices[]" "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null | sed 's/"//g' || echo "")
    else
        practices=$(yq r "${PROJECT_KIND_CONFIG_FILE}" "project_kinds.${project_kind}.ai_guidance.best_practices[*]" 2>/dev/null || echo "")
    fi
    
    if [[ -z "${practices}" ]]; then
        echo "- Follow language-appropriate best practices"
    else
        echo "${practices}" | sed 's/^/- /'
    fi
}

# Export AI guidance functions
export -f get_language_testing_standards
export -f get_language_style_guides
export -f get_language_best_practices

# Get language-specific directory structure standards for AI prompts
# Usage: get_language_directory_standards <project_kind>
# Returns: Newline-separated list of directory standards
get_language_directory_standards() {
    local project_kind="${1:-}"
    
    if [[ -z "${project_kind}" ]]; then
        project_kind=$(get_project_kind 2>/dev/null || echo "generic")
    fi
    
    local yq_version
    yq_version=$(detect_yq_version)
    
    if [[ "${yq_version}" == "none" ]]; then
        echo "- Follow language/framework conventional structure"
        return
    fi
    
    local standards
    if [[ "${yq_version}" == "v4" ]]; then
        standards=$(yq eval ".project_kinds.${project_kind}.ai_guidance.directory_standards[]" "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null || echo "")
    elif [[ "${yq_version}" == "kislyuk" ]]; then
        standards=$(yq ".project_kinds.${project_kind}.ai_guidance.directory_standards[]" "${PROJECT_KIND_CONFIG_FILE}" 2>/dev/null | sed 's/"//g' || echo "")
    else
        standards=$(yq r "${PROJECT_KIND_CONFIG_FILE}" "project_kinds.${project_kind}.ai_guidance.directory_standards[*]" 2>/dev/null || echo "")
    fi
    
    if [[ -z "${standards}" ]]; then
        echo "- Follow language/framework conventional structure"
    else
        echo "${standards}" | sed 's/^/- /'
    fi
}

# Export directory standards function
export -f get_language_directory_standards
