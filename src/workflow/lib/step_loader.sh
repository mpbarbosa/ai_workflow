#!/bin/bash
set -euo pipefail

################################################################################
# Step Loader Module
# Version: 4.0.0
# Purpose: Dynamic step module loading and execution
#
# Features:
#   - Dynamic sourcing of step modules
#   - Generic step execution wrapper
#   - Pre-execution validation
#   - Error handling and logging
#   - Support for both v3.x and v4.0 step modules
#
# Usage:
#   source lib/step_loader.sh
#   load_step_module "documentation_updates"
#   execute_step "documentation_updates"
################################################################################

# Module version
readonly STEP_LOADER_VERSION="4.0.0"

# Global variables
WORKFLOW_STEPS_DIR="${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/steps"
declare -gA LOADED_STEP_MODULES  # Track loaded modules

# ==============================================================================
# MODULE LOADING
# ==============================================================================

# Load a step module dynamically
# Args: $1 = step name
# Returns: 0 on success, 1 on failure
load_step_module() {
    local step_name="$1"
    
    # Check if already loaded
    if [[ "${LOADED_STEP_MODULES[$step_name]:-}" == "true" ]]; then
        return 0
    fi
    
    # Get module file from registry
    local metadata
    metadata=$(get_step_metadata "$step_name" 2>/dev/null) || {
        print_error "Step not found in registry: $step_name"
        return 1
    }
    
    IFS=: read -r module_file function_name description enabled <<< "$metadata"
    
    # Construct full path to module
    local module_path="${WORKFLOW_STEPS_DIR}/${module_file}"
    
    # Check if module file exists
    if [[ ! -f "$module_path" ]]; then
        print_error "Step module not found: $module_path"
        print_info "Expected: ${module_file} for step: $step_name"
        return 1
    fi
    
    # Source the module
    # shellcheck disable=SC1090
    if ! source "$module_path"; then
        print_error "Failed to load step module: $module_path"
        return 1
    fi
    
    # Verify function exists
    if ! declare -f "$function_name" > /dev/null 2>&1; then
        print_error "Step function not found: $function_name"
        print_error "Module: $module_path"
        return 1
    fi
    
    # Mark as loaded
    LOADED_STEP_MODULES["$step_name"]="true"
    
    return 0
}

# Pre-load all step modules
# Useful for validation and early error detection
# Returns: 0 if all modules loaded, 1 if any failed
load_all_step_modules() {
    print_info "Pre-loading all step modules..."
    
    local failed_count=0
    local loaded_count=0
    
    # Get execution order from registry
    local execution_order
    execution_order=$(get_execution_order)
    
    for step_name in $execution_order; do
        if load_step_module "$step_name"; then
            ((loaded_count++)) || true
        else
            ((failed_count++)) || true
            print_error "Failed to load: $step_name"
        fi
    done
    
    if [[ $failed_count -gt 0 ]]; then
        print_error "Failed to load $failed_count step modules"
        return 1
    fi
    
    print_success "Loaded $loaded_count step modules"
    return 0
}

# ==============================================================================
# STEP VALIDATION
# ==============================================================================

# Validate that a step exists and can be executed
# Args: $1 = step name or index
# Returns: 0 if valid, 1 if invalid
validate_step_exists() {
    local step_identifier="$1"
    local step_name=""
    
    # Check if it's a numeric index
    if [[ "$step_identifier" =~ ^[0-9]+$ ]]; then
        step_name=$(get_step_by_index "$step_identifier")
        
        if [[ -z "$step_name" ]]; then
            print_error "Invalid step index: $step_identifier"
            return 1
        fi
    else
        step_name="$step_identifier"
        
        # Verify step exists in registry
        local step_index
        step_index=$(get_step_index "$step_name")
        
        if [[ -z "$step_index" ]]; then
            print_error "Invalid step name: $step_name"
            return 1
        fi
    fi
    
    # Check if step is enabled
    if ! is_step_enabled "$step_name"; then
        print_warning "Step is disabled: $step_name"
        return 1
    fi
    
    return 0
}

# Validate step dependencies are met
# Args: $1 = step name
# Args: $2 = comma-separated list of completed steps
# Returns: 0 if dependencies met, 1 if not
validate_step_dependencies_met() {
    local step_name="$1"
    local completed_steps="$2"
    
    # Get step dependencies
    local deps
    deps=$(get_step_dependencies "$step_name")
    
    # No dependencies = always ready
    [[ -z "$deps" ]] && return 0
    
    # Check each dependency
    IFS=',' read -ra dep_array <<< "$deps"
    
    for dep in "${dep_array[@]}"; do
        [[ -z "$dep" ]] && continue
        
        # Check if dependency is in completed list
        if [[ ! ",$completed_steps," =~ ",$dep," ]]; then
            print_error "Step '$step_name' requires '$dep' to be completed first"
            return 1
        fi
    done
    
    return 0
}

# ==============================================================================
# STEP EXECUTION
# ==============================================================================

# Execute a step with proper error handling and logging
# Args: $1 = step name or index
# Returns: 0 on success, 1 on failure
execute_step() {
    local step_identifier="$1"
    local step_name=""
    
    # Resolve step name
    if [[ "$step_identifier" =~ ^[0-9]+$ ]]; then
        step_name=$(get_step_by_index "$step_identifier")
        if [[ -z "$step_name" ]]; then
            print_error "Invalid step index: $step_identifier"
            return 1
        fi
    else
        step_name="$step_identifier"
    fi
    
    # Get step metadata
    local metadata
    metadata=$(get_step_metadata "$step_name") || {
        print_error "Step not found: $step_name"
        return 1
    }
    
    IFS=: read -r module_file function_name description enabled <<< "$metadata"
    
    # Check if enabled
    if [[ "$enabled" != "true" ]]; then
        print_info "Skipping disabled step: $step_name"
        return 0
    fi
    
    # Load module if not already loaded
    if ! load_step_module "$step_name"; then
        print_error "Failed to load step module: $step_name"
        return 1
    fi
    
    # Get step index for display
    local step_index
    step_index=$(get_step_index "$step_name")
    
    # Execute step function
    print_step "$step_index" "$description"
    
    local start_time
    start_time=$(date +%s)
    
    # Log step start
    if type -t log_step_start > /dev/null 2>&1; then
        log_step_start "$step_index" "$description"
    fi
    
    # Execute the step function
    local exit_code=0
    if ! "$function_name"; then
        exit_code=1
        print_error "Step failed: $step_name"
        
        # Log failure
        if type -t log_step_complete > /dev/null 2>&1; then
            log_step_complete "$step_index" "$description" "FAILED"
        fi
        
        # Update workflow status
        if type -t update_workflow_status > /dev/null 2>&1; then
            update_workflow_status "$step_index" "❌"
        fi
        
        return 1
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_success "Step completed in ${duration}s: $step_name"
    
    # Log success
    if type -t log_step_complete > /dev/null 2>&1; then
        log_step_complete "$step_index" "$description" "SUCCESS"
    fi
    
    # Update workflow status
    if type -t update_workflow_status > /dev/null 2>&1; then
        update_workflow_status "$step_index" "✅"
    fi
    
    return 0
}

# Execute multiple steps in sequence
# Args: $@ = step names or indices
# Returns: 0 if all succeed, 1 if any fail
execute_steps() {
    local -a step_list=("$@")
    local failed_step=""
    local completed_steps=""
    
    print_info "Executing ${#step_list[@]} steps..."
    
    for step_identifier in "${step_list[@]}"; do
        # Resolve step name
        local step_name="$step_identifier"
        if [[ "$step_identifier" =~ ^[0-9]+$ ]]; then
            step_name=$(get_step_by_index "$step_identifier")
        fi
        
        # Validate dependencies
        if ! validate_step_dependencies_met "$step_name" "$completed_steps"; then
            print_error "Dependencies not met for: $step_name"
            failed_step="$step_name"
            break
        fi
        
        # Execute step
        if ! execute_step "$step_identifier"; then
            failed_step="$step_name"
            break
        fi
        
        # Add to completed list
        if [[ -z "$completed_steps" ]]; then
            completed_steps="$step_name"
        else
            completed_steps="$completed_steps,$step_name"
        fi
    done
    
    if [[ -n "$failed_step" ]]; then
        print_error "Workflow stopped at failed step: $failed_step"
        return 1
    fi
    
    print_success "All ${#step_list[@]} steps completed successfully"
    return 0
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# Get loaded module count
get_loaded_module_count() {
    echo "${#LOADED_STEP_MODULES[@]}"
}

# Check if module is loaded
# Args: $1 = step name
# Returns: 0 if loaded, 1 if not
is_module_loaded() {
    local step_name="$1"
    [[ "${LOADED_STEP_MODULES[$step_name]:-}" == "true" ]]
}

# Print loaded modules
print_loaded_modules() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Loaded Step Modules"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Total loaded: ${#LOADED_STEP_MODULES[@]}"
    echo ""
    
    if [[ ${#LOADED_STEP_MODULES[@]} -gt 0 ]]; then
        for step_name in "${!LOADED_STEP_MODULES[@]}"; do
            local metadata
            metadata=$(get_step_metadata "$step_name")
            IFS=: read -r module_file function_name _ _ <<< "$metadata"
            
            printf "  %-30s → %s::%s\n" "$step_name" "$module_file" "$function_name"
        done
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
}

# Export functions
export -f load_step_module
export -f load_all_step_modules
export -f validate_step_exists
export -f validate_step_dependencies_met
export -f execute_step
export -f execute_steps
export -f get_loaded_module_count
export -f is_module_loaded
export -f print_loaded_modules
