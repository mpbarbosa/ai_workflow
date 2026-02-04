#!/bin/bash
# Note: No 'set -e' in this module as it's meant to be sourced
# Individual functions handle errors appropriately

################################################################################
# JQ Wrapper Module
# Version: 1.0.0
# Purpose: Safe wrapper for jq command with validation, logging, and error handling
# Part of: Tests & Documentation Workflow Automation v3.0.0+
# Created: February 3, 2026
################################################################################

# ==============================================================================
# JQ WRAPPER FUNCTION
# ==============================================================================

# Safe wrapper for jq command with argument validation and logging
# Prevents "invalid JSON text passed to --argjson" errors
# Logs all arguments when DEBUG=true or WORKFLOW_LOG_FILE is set
#
# Usage: jq_safe [jq options and arguments...]
#
# Features:
#   - Validates --argjson arguments are non-empty before execution
#   - Logs all arguments for debugging when DEBUG=true
#   - Provides clear error messages with context
#   - Handles both -n (null input) and file input modes
#   - Preserves all jq exit codes and behavior
#
# Examples:
#   jq_safe -n --arg name "test" --argjson count 5 '{name: $name, count: $count}'
#   jq_safe '.foo' input.json
#   jq_safe -r '.items[] | .name' < data.json
#
# Returns:
#   Same exit code as jq would return
#   0 = success, 1+ = error
jq_safe() {
    local caller_context="${FUNCNAME[1]:-unknown}"
    local log_enabled=false
    
    # Enable logging if DEBUG or WORKFLOW_LOG_FILE is set
    if [[ "${DEBUG:-false}" == "true" ]] || [[ -n "${WORKFLOW_LOG_FILE:-}" ]]; then
        log_enabled=true
    fi
    
    # Log function entry
    if [[ "$log_enabled" == "true" ]]; then
        {
            echo "[DEBUG] jq_safe called from: ${caller_context}"
            echo "  Arguments: $*"
        } >> "${WORKFLOW_LOG_FILE:-/dev/null}" 2>/dev/null
    fi
    
    # Validate --argjson arguments
    local validation_errors=()
    local args=("$@")
    local i=0
    
    while [[ $i -lt ${#args[@]} ]]; do
        local arg="${args[$i]}"
        
        # Check if this is --argjson flag
        if [[ "$arg" == "--argjson" ]]; then
            # Next argument is variable name
            local next_idx=$((i + 1))
            if [[ $next_idx -lt ${#args[@]} ]]; then
                local var_name="${args[$next_idx]}"
                
                # Value is the argument after that
                local value_idx=$((i + 2))
                if [[ $value_idx -lt ${#args[@]} ]]; then
                    local value="${args[$value_idx]}"
                    
                    # Validate the value is not empty
                    if [[ -z "$value" ]]; then
                        validation_errors+=("--argjson variable '$var_name' has empty value")
                    # Validate the value looks like valid JSON (basic check)
                    # Must be: number, "string", true, false, null, {object}, [array]
                    elif ! [[ "$value" =~ ^(-?[0-9]+\.?[0-9]*|\".*\"|true|false|null|\{.*\}|\[.*\])$ ]]; then
                        validation_errors+=("--argjson variable '$var_name' value '$value' may not be valid JSON")
                    fi
                fi
            fi
        fi
        
        ((i++))
    done
    
    # Report validation errors
    if [[ ${#validation_errors[@]} -gt 0 ]]; then
        {
            echo "ERROR: jq_safe validation failed in ${caller_context}"
            for error in "${validation_errors[@]}"; do
                echo "  - $error"
            done
        } >&2
        
        if [[ "$log_enabled" == "true" ]]; then
            {
                echo "[ERROR] jq_safe validation failed in ${caller_context}"
                for error in "${validation_errors[@]}"; do
                    echo "  - $error"
                done
            } >> "${WORKFLOW_LOG_FILE:-/dev/null}" 2>/dev/null
        fi
        
        return 1
    fi
    
    # Execute jq with all original arguments
    local jq_exit_code=0
    if command -v jq &> /dev/null; then
        jq "$@" || jq_exit_code=$?
    else
        echo "ERROR: jq command not found" >&2
        if [[ "$log_enabled" == "true" ]]; then
            echo "[ERROR] jq command not found in ${caller_context}" >> "${WORKFLOW_LOG_FILE:-/dev/null}" 2>/dev/null
        fi
        return 127
    fi
    
    # Log execution result
    if [[ "$log_enabled" == "true" ]]; then
        if [[ $jq_exit_code -eq 0 ]]; then
            echo "[DEBUG] jq_safe completed successfully in ${caller_context}" >> "${WORKFLOW_LOG_FILE:-/dev/null}" 2>/dev/null
        else
            echo "[ERROR] jq_safe failed with exit code $jq_exit_code in ${caller_context}" >> "${WORKFLOW_LOG_FILE:-/dev/null}" 2>/dev/null
        fi
    fi
    
    return $jq_exit_code
}

# Export the function for use in subshells
export -f jq_safe

################################################################################
# HELPER FUNCTIONS
################################################################################

# Validate a JSON string is well-formed
# Args: $1 = JSON string
# Returns: 0 if valid, 1 if invalid
validate_json() {
    local json="$1"
    
    if [[ -z "$json" ]]; then
        return 1
    fi
    
    if command -v jq &> /dev/null; then
        echo "$json" | jq -e . >/dev/null 2>&1
        return $?
    else
        # Basic fallback validation
        [[ "$json" =~ ^(\{.*\}|\[.*\]|\".*\"|[0-9]+|true|false|null)$ ]]
        return $?
    fi
}

# Sanitize a value for use with --argjson
# Ensures value is a valid JSON primitive (number, boolean, or null)
# Args: $1 = value to sanitize, $2 = default value (optional, defaults to 0)
# Returns: sanitized value
sanitize_argjson_value() {
    local value="$1"
    local default="${2:-0}"
    
    # Handle empty or unset
    if [[ -z "$value" ]]; then
        echo "$default"
        return 0
    fi
    
    # Handle numbers (strip non-numeric characters)
    if [[ "$value" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
        echo "$value"
        return 0
    fi
    
    # Handle booleans
    if [[ "$value" == "true" ]] || [[ "$value" == "false" ]]; then
        echo "$value"
        return 0
    fi
    
    # Handle null
    if [[ "$value" == "null" ]]; then
        echo "null"
        return 0
    fi
    
    # Invalid - return default
    echo "$default"
    return 0
}

# Export helper functions
export -f validate_json
export -f sanitize_argjson_value

################################################################################
# DOCUMENTATION
################################################################################

# Show usage information
jq_wrapper_help() {
    cat << 'EOF'
JQ Wrapper Module - Safe jq Command Execution
==============================================

FUNCTION: jq_safe
-----------------
Safe wrapper for jq command with validation, logging, and error handling.

SYNOPSIS:
    jq_safe [jq-options] [filter] [files...]

DESCRIPTION:
    Wraps the jq command to provide:
    - Argument validation (prevents empty --argjson values)
    - Debug logging (when DEBUG=true or WORKFLOW_LOG_FILE is set)
    - Clear error messages with caller context
    - Graceful error handling

USAGE EXAMPLES:

    1. Create JSON with validated arguments:
       jq_safe -n --arg name "test" --argjson count 5 '{name: $name, count: $count}'

    2. Process file input:
       jq_safe '.items[] | select(.active == true)' data.json

    3. Pipeline usage:
       echo '{"foo": "bar"}' | jq_safe '.foo'

    4. With multiple --argjson arguments:
       jq_safe -n \
           --argjson total 100 \
           --argjson completed 75 \
           '{total: $total, completed: $completed, remaining: ($total - $completed)}'

VALIDATION:
    - Checks all --argjson values are non-empty
    - Validates values look like valid JSON (basic check)
    - Reports clear error messages if validation fails

LOGGING:
    When DEBUG=true or WORKFLOW_LOG_FILE is set, logs:
    - Function entry with caller context
    - All arguments passed to jq
    - Validation errors (if any)
    - Execution result (success/failure)

HELPER FUNCTIONS:

    validate_json <json-string>
        Returns 0 if JSON is well-formed, 1 otherwise

    sanitize_argjson_value <value> [default]
        Sanitizes a value for use with --argjson
        Returns valid JSON primitive or default value

RETURN CODES:
    0   - Success
    1   - Validation error or jq execution error
    127 - jq command not found

EXAMPLES IN WORKFLOW:

    # Instead of:
    jq -n --argjson count "$count" '{count: $count}'

    # Use:
    count=$(sanitize_argjson_value "$count" 0)
    jq_safe -n --argjson count "$count" '{count: $count}'

    # Or validate before use:
    if ! validate_json "$json_string"; then
        echo "Invalid JSON"
        return 1
    fi
    echo "$json_string" | jq_safe '.field'

MIGRATION:
    To migrate existing jq calls:
    1. Source this module: source lib/jq_wrapper.sh
    2. Replace 'jq' with 'jq_safe'
    3. Optionally add sanitize_argjson_value for --argjson arguments
    4. Test with DEBUG=true to verify logging

EOF
}

export -f jq_wrapper_help
