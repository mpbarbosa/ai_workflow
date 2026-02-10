#!/bin/bash
set -euo pipefail

################################################################################
# Step Registry Module
# Version: 4.0.8
# Purpose: Configuration-driven step management and execution order resolution
#
# Features:
#   - Parse workflow.steps from .workflow-config.yaml
#   - Lookup steps by name or numeric index
#   - Validate step dependencies
#   - Resolve execution order with topological sort
#   - Support both v3.x numeric indices and v4.0 step names
#
# Breaking Changes from v3.x:
#   - Step execution order is now defined in config, not code
#   - Step names replace numeric identifiers
#   - Dependencies are explicit and validated
################################################################################

# Module version
readonly STEP_REGISTRY_VERSION="4.0.2"

# Global associative arrays for step registry
declare -gA STEP_REGISTRY_BY_NAME      # name → index
declare -gA STEP_REGISTRY_BY_INDEX     # index → name
declare -gA STEP_REGISTRY_MODULE       # name → module file
declare -gA STEP_REGISTRY_FUNCTION     # name → function name
declare -gA STEP_REGISTRY_DESCRIPTION  # name → description
declare -gA STEP_REGISTRY_ENABLED      # name → true/false
declare -gA STEP_REGISTRY_DEPENDENCIES # name → "dep1,dep2,dep3"
declare -gA STEP_REGISTRY_CONDITIONS   # name → "condition1,condition2"
declare -gA STEP_REGISTRY_AI_PERSONA   # name → ai_persona
declare -gA STEP_REGISTRY_OPTIONAL     # name → true/false

# Global array for execution order
declare -ga STEP_EXECUTION_ORDER=()

# Registry loaded flag
STEP_REGISTRY_LOADED=false

# ==============================================================================
# YAML PARSING (Simple Implementation)
# ==============================================================================

# Load step definitions from .workflow-config.yaml
# Returns: 0 on success, 1 on failure
load_step_definitions() {
    local config_file="${PROJECT_ROOT:-.}/.workflow-config.yaml"
    
    # Check if config file exists
    if [[ ! -f "$config_file" ]]; then
        print_error "Configuration file not found: $config_file"
        print_info "Run: ./execute_tests_docs_workflow.sh --init-config"
        return 1
    fi
    
    # Check if workflow.steps section exists
    if ! grep -q "^workflow:" "$config_file" 2>/dev/null; then
        print_warning "No workflow section found in $config_file"
        print_info "Using legacy step execution mode (v3.x compatibility)"
        _load_legacy_step_definitions
        return 0
    fi
    
    print_info "Loading step definitions from $config_file..."
    
    # Parse YAML workflow.steps section
    local in_steps_section=false
    local step_index=0
    local current_step_name=""
    local line_num=0
    
    while IFS= read -r line; do
        ((line_num++)) || true
        
        # Detect workflow.steps section
        if [[ "$line" =~ ^[[:space:]]*steps:[[:space:]]*$ ]]; then
            in_steps_section=true
            continue
        fi
        
        # Exit steps section if we hit another top-level key
        if [[ "$in_steps_section" == true ]] && [[ "$line" =~ ^[[:alpha:]] ]]; then
            in_steps_section=false
            break
        fi
        
        # Skip if not in steps section
        [[ "$in_steps_section" != true ]] && continue
        
        # Parse step entry (starts with "- id:")
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+id:[[:space:]]+\"?([^\"[:space:]]+)\"? ]]; then
            local step_id="${BASH_REMATCH[1]}"
            ((step_index++)) || true
            current_step_name="$step_id"
            
            # Initialize registry entries
            STEP_REGISTRY_BY_NAME["$current_step_name"]=$step_index
            STEP_REGISTRY_BY_INDEX[$step_index]="$current_step_name"
            STEP_REGISTRY_ENABLED["$current_step_name"]="true"
            STEP_REGISTRY_DEPENDENCIES["$current_step_name"]=""
            STEP_REGISTRY_CONDITIONS["$current_step_name"]=""
            STEP_REGISTRY_OPTIONAL["$current_step_name"]="false"
            
            continue
        fi
        
        # Skip if no current step
        [[ -z "$current_step_name" ]] && continue
        
        # Parse step properties
        if [[ "$line" =~ ^[[:space:]]+name:[[:space:]]+\"(.+)\" ]]; then
            # Use human-readable name as description if description not set
            if [[ -z "${STEP_REGISTRY_DESCRIPTION[$current_step_name]:-}" ]]; then
                STEP_REGISTRY_DESCRIPTION["$current_step_name"]="${BASH_REMATCH[1]}"
            fi
            
        elif [[ "$line" =~ ^[[:space:]]+description:[[:space:]]+\"(.+)\" ]]; then
            STEP_REGISTRY_DESCRIPTION["$current_step_name"]="${BASH_REMATCH[1]}"
            
        elif [[ "$line" =~ ^[[:space:]]+file:[[:space:]]+\"?([a-z0-9_\.]+\.sh)\"? ]]; then
            STEP_REGISTRY_MODULE["$current_step_name"]="${BASH_REMATCH[1]}"
            
        elif [[ "$line" =~ ^[[:space:]]+module:[[:space:]]+\"?([a-z0-9_\.]+\.sh)\"? ]]; then
            STEP_REGISTRY_MODULE["$current_step_name"]="${BASH_REMATCH[1]}"
            
        elif [[ "$line" =~ ^[[:space:]]+function:[[:space:]]+([a-z_]+) ]]; then
            STEP_REGISTRY_FUNCTION["$current_step_name"]="${BASH_REMATCH[1]}"
            
        elif [[ "$line" =~ ^[[:space:]]+enabled:[[:space:]]+([a-z]+) ]]; then
            STEP_REGISTRY_ENABLED["$current_step_name"]="${BASH_REMATCH[1]}"
            
        elif [[ "$line" =~ ^[[:space:]]+dependencies:[[:space:]]+\[([^\]]*)\] ]]; then
            # Parse dependency array: [dep1, dep2, dep3] or ["dep1", "dep2"]
            local deps="${BASH_REMATCH[1]}"
            deps="${deps//[[:space:]]/}"  # Remove spaces
            deps="${deps//\"/}"           # Remove quotes
            STEP_REGISTRY_DEPENDENCIES["$current_step_name"]="$deps"
            
        elif [[ "$line" =~ ^[[:space:]]+ai_persona:[[:space:]]+([a-z_]+) ]]; then
            STEP_REGISTRY_AI_PERSONA["$current_step_name"]="${BASH_REMATCH[1]}"
            
        elif [[ "$line" =~ ^[[:space:]]+optional:[[:space:]]+true ]]; then
            STEP_REGISTRY_OPTIONAL["$current_step_name"]="true"
            
        elif [[ "$line" =~ ^[[:space:]]+conditions: ]]; then
            # Start of conditions array - will parse next lines
            local conditions=""
            continue
            
        elif [[ "$line" =~ ^[[:space:]]+-[[:space:]]+([a-z_]+) ]]; then
            # Condition item
            local condition="${BASH_REMATCH[1]}"
            if [[ -n "${STEP_REGISTRY_CONDITIONS[$current_step_name]}" ]]; then
                STEP_REGISTRY_CONDITIONS["$current_step_name"]="${STEP_REGISTRY_CONDITIONS[$current_step_name]},$condition"
            else
                STEP_REGISTRY_CONDITIONS["$current_step_name"]="$condition"
            fi
        fi
        
    done < "$config_file"
    
    STEP_REGISTRY_LOADED=true
    
    print_success "Loaded $step_index steps from configuration"
    
    return 0
}

# Load legacy v3.x step definitions for backward compatibility
_load_legacy_step_definitions() {
    print_info "Loading legacy step definitions (v3.x compatibility mode)"
    
    # Define legacy step order manually
    local -a legacy_steps=(
        "version_update:version_update.sh:step0a_version_update"
        "pre_analysis:pre_analysis.sh:step0_analyze_changes"
        "bootstrap_documentation:bootstrap_docs.sh:step0b_bootstrap_documentation"
        "documentation_updates:documentation.sh:step1_update_documentation"
        "api_coverage_analysis:api_coverage.sh:step1_5_api_coverage_analysis"
        "consistency_analysis:consistency.sh:step2_check_consistency"
        "documentation_optimization:doc_optimize.sh:step2_5_doc_optimization"
        "script_reference_validation:script_refs.sh:step3_validate_script_references"
        "config_validation:config_validation.sh:step4_config_validation"
        "directory_validation:directory.sh:step5_validate_directory"
        "test_review:test_review.sh:step6_review_tests"
        "test_generation:test_gen.sh:step7_generate_tests"
        "test_execution:test_exec.sh:step8_execute_tests"
        "dependency_validation:dependencies.sh:step9_validate_dependencies"
        "code_quality_validation:code_quality.sh:step10_code_quality_validation"
        "context_analysis:context.sh:step10_context_analysis"
        "deployment_gate:deployment_gate.sh:step11_deployment_gate"
        "git_finalization:git_finalization.sh:step12_git_finalization"
        "markdown_linting:markdown_lint.sh:step13_markdown_linting"
        "prompt_engineer_analysis:prompt_engineer.sh:step14_prompt_engineer_analysis"
        "ux_analysis:ux_analysis.sh:step15_ux_analysis"
    )
    
    local index=1
    for step_def in "${legacy_steps[@]}"; do
        IFS=: read -r name module function <<< "$step_def"
        
        STEP_REGISTRY_BY_NAME["$name"]=$index
        STEP_REGISTRY_BY_INDEX[$index]="$name"
        STEP_REGISTRY_MODULE["$name"]="$module"
        STEP_REGISTRY_FUNCTION["$name"]="$function"
        STEP_REGISTRY_ENABLED["$name"]="true"
        STEP_REGISTRY_DESCRIPTION["$name"]="${name//_/ }"
        
        ((index++)) || true
    done
    
    STEP_REGISTRY_LOADED=true
    print_success "Loaded ${#legacy_steps[@]} legacy steps"
    
    # Source all step modules now that registry is loaded
    # Use WORKFLOW_DIR which is set by execute_tests_docs_workflow.sh
    local steps_dir="${WORKFLOW_DIR:?WORKFLOW_DIR not set}/steps"
    
    for step_def in "${legacy_steps[@]}"; do
        IFS=: read -r name module function <<< "$step_def"
        local module_path="${steps_dir}/${module}"
        if [[ -f "$module_path" ]]; then
            # shellcheck disable=SC1090
            source "$module_path" || print_warning "Failed to source: $module_path"
        else
            print_warning "Step module not found: $module_path"
        fi
    done
}

# ==============================================================================
# STEP LOOKUP
# ==============================================================================

# Get step name by numeric index
# Args: $1 = numeric index (1-N)
# Returns: step name, or empty string if not found
get_step_by_index() {
    local index="$1"
    
    if [[ ! "$STEP_REGISTRY_LOADED" == true ]]; then
        print_error "Step registry not loaded. Call load_step_definitions() first."
        return 1
    fi
    
    echo "${STEP_REGISTRY_BY_INDEX[$index]:-}"
}

# Get step index by name
# Args: $1 = step name
# Returns: numeric index, or empty string if not found
get_step_index() {
    local name="$1"
    
    if [[ ! "$STEP_REGISTRY_LOADED" == true ]]; then
        print_error "Step registry not loaded. Call load_step_definitions() first."
        return 1
    fi
    
    echo "${STEP_REGISTRY_BY_NAME[$name]:-}"
}

# Get step metadata
# Args: $1 = step name
# Returns: module_file:function_name:description:enabled
get_step_metadata() {
    local name="$1"
    
    if [[ ! "$STEP_REGISTRY_LOADED" == true ]]; then
        print_error "Step registry not loaded. Call load_step_definitions() first."
        return 1
    fi
    
    if [[ -z "${STEP_REGISTRY_BY_NAME[$name]:-}" ]]; then
        print_error "Step not found: $name"
        return 1
    fi
    
    local module="${STEP_REGISTRY_MODULE[$name]:-}"
    local function="${STEP_REGISTRY_FUNCTION[$name]:-}"
    local description="${STEP_REGISTRY_DESCRIPTION[$name]:-}"
    local enabled="${STEP_REGISTRY_ENABLED[$name]:-true}"
    
    echo "$module:$function:$description:$enabled"
}

# Check if step is enabled
# Args: $1 = step name
# Returns: 0 if enabled, 1 if disabled
is_step_enabled() {
    local name="$1"
    [[ "${STEP_REGISTRY_ENABLED[$name]:-true}" == "true" ]]
}

# Get step dependencies
# Args: $1 = step name
# Returns: comma-separated list of dependencies
get_step_dependencies() {
    local name="$1"
    echo "${STEP_REGISTRY_DEPENDENCIES[$name]:-}"
}

# ==============================================================================
# DEPENDENCY VALIDATION
# ==============================================================================

# Validate that all step dependencies exist
# Returns: 0 if valid, 1 if invalid
validate_step_dependencies() {
    if [[ ! "$STEP_REGISTRY_LOADED" == true ]]; then
        print_error "Step registry not loaded. Call load_step_definitions() first."
        return 1
    fi
    
    local validation_failed=false
    
    print_info "Validating step dependencies..."
    
    for step_name in "${!STEP_REGISTRY_BY_NAME[@]}"; do
        local deps="${STEP_REGISTRY_DEPENDENCIES[$step_name]:-}"
        
        [[ -z "$deps" ]] && continue
        
        # Split dependencies
        IFS=',' read -ra dep_array <<< "$deps"
        
        for dep in "${dep_array[@]}"; do
            [[ -z "$dep" ]] && continue
            
            if [[ -z "${STEP_REGISTRY_BY_NAME[$dep]:-}" ]]; then
                print_error "Step '$step_name' has invalid dependency: '$dep'"
                validation_failed=true
            fi
        done
    done
    
    if [[ "$validation_failed" == true ]]; then
        return 1
    fi
    
    print_success "All step dependencies are valid"
    return 0
}

# ==============================================================================
# EXECUTION ORDER RESOLUTION (Topological Sort)
# ==============================================================================

# Resolve execution order using topological sort
# Respects step dependencies and ensures steps run in correct order
# Returns: 0 on success, 1 on circular dependency
resolve_execution_order() {
    if [[ ! "$STEP_REGISTRY_LOADED" == true ]]; then
        print_error "Step registry not loaded. Call load_step_definitions() first."
        return 1
    fi
    
    # Check if registry is empty (disable unbound variable check temporarily)
    set +u
    local registry_size=${#STEP_REGISTRY_BY_NAME[@]}
    set -u
    
    if [[ $registry_size -eq 0 ]]; then
        print_warning "No steps loaded in registry. Execution order is empty."
        STEP_EXECUTION_ORDER=()
        return 0
    fi
    
    print_info "Resolving step execution order..."
    
    # Clear existing execution order
    STEP_EXECUTION_ORDER=()
    
    # Build dependency graph
    declare -A in_degree      # Count of dependencies for each step
    declare -A adj_list       # Adjacency list: step → dependent steps
    
    # Initialize in_degree and adj_list
    for step_name in "${!STEP_REGISTRY_BY_NAME[@]}"; do
        in_degree["$step_name"]=0
        adj_list["$step_name"]=""
    done
    
    # Calculate in_degree and build adjacency list
    for step_name in "${!STEP_REGISTRY_BY_NAME[@]}"; do
        local deps="${STEP_REGISTRY_DEPENDENCIES[$step_name]:-}"
        
        [[ -z "$deps" ]] && continue
        
        IFS=',' read -ra dep_array <<< "$deps"
        
        for dep in "${dep_array[@]}"; do
            [[ -z "$dep" ]] && continue
            
            # Validate dependency exists
            if [[ -z "${STEP_REGISTRY_BY_NAME[$dep]:-}" ]]; then
                print_warning "Step '$step_name' has unknown dependency: '$dep' - skipping"
                continue
            fi
            
            # Increment in_degree for this step
            ((in_degree["$step_name"]++)) || true
            
            # Add this step to dependency's adjacency list
            if [[ -z "${adj_list[$dep]:-}" ]]; then
                adj_list["$dep"]="$step_name"
            else
                adj_list["$dep"]="${adj_list[$dep]},$step_name"
            fi
        done
    done
    
    # Kahn's algorithm for topological sort
    local -a queue=()
    
    # Find all steps with no dependencies (in_degree = 0)
    for step_name in "${!in_degree[@]}"; do
        if [[ ${in_degree[$step_name]} -eq 0 ]]; then
            queue+=("$step_name")
        fi
    done
    
    # Process queue
    while [[ ${#queue[@]} -gt 0 ]]; do
        # Dequeue
        local current="${queue[0]}"
        queue=("${queue[@]:1}")
        
        # Add to execution order
        STEP_EXECUTION_ORDER+=("$current")
        
        # Process dependents
        local dependents="${adj_list[$current]:-}"
        [[ -z "$dependents" ]] && continue
        
        IFS=',' read -ra dependent_array <<< "$dependents"
        
        for dependent in "${dependent_array[@]}"; do
            [[ -z "$dependent" ]] && continue
            
            # Decrement in_degree
            ((in_degree["$dependent"]--)) || true
            
            # If in_degree becomes 0, add to queue
            if [[ ${in_degree[$dependent]} -eq 0 ]]; then
                queue+=("$dependent")
            fi
        done
    done
    
    # Check for circular dependencies
    if [[ ${#STEP_EXECUTION_ORDER[@]} -ne ${#STEP_REGISTRY_BY_NAME[@]} ]]; then
        print_error "Circular dependency detected in step configuration"
        print_error "Processed: ${#STEP_EXECUTION_ORDER[@]} steps"
        print_error "Expected: ${#STEP_REGISTRY_BY_NAME[@]} steps"
        return 1
    fi
    
    print_success "Resolved execution order for ${#STEP_EXECUTION_ORDER[@]} steps"
    
    return 0
}

# Get resolved execution order
# Returns: space-separated list of step names in execution order
get_execution_order() {
    echo "${STEP_EXECUTION_ORDER[@]}"
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# Print step registry summary
print_step_registry() {
    if [[ ! "$STEP_REGISTRY_LOADED" == true ]]; then
        print_error "Step registry not loaded"
        return 1
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Step Registry Summary"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Total steps: ${#STEP_REGISTRY_BY_NAME[@]}"
    echo ""
    
    # Print in execution order if available
    if [[ ${#STEP_EXECUTION_ORDER[@]} -gt 0 ]]; then
        echo "Execution Order:"
        local index=1
        for step_name in "${STEP_EXECUTION_ORDER[@]}"; do
            local enabled_icon="✅"
            [[ "${STEP_REGISTRY_ENABLED[$step_name]}" != "true" ]] && enabled_icon="⏸️"
            
            local deps="${STEP_REGISTRY_DEPENDENCIES[$step_name]:-none}"
            [[ "$deps" == "" ]] && deps="none"
            
            printf "  %2d. %-30s %s  [deps: %s]\n" \
                "$index" "$step_name" "$enabled_icon" "$deps"
            
            ((index++)) || true
        done
    else
        echo "Execution order not yet resolved. Call resolve_execution_order()"
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
}

# Export functions
export -f load_step_definitions
export -f get_step_by_index
export -f get_step_index
export -f get_step_metadata
export -f is_step_enabled
export -f get_step_dependencies
export -f validate_step_dependencies
export -f resolve_execution_order
export -f get_execution_order
export -f print_step_registry
