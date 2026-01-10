#!/bin/bash
set -euo pipefail

################################################################################
# Conditional Step Execution Module
# Version: 2.7.0
# Purpose: Smart step execution based on file changes and conditions
#
# Features:
#   - File-based condition evaluation
#   - Directory change detection
#   - Smart step skipping
#   - Execution plan generation
#   - Performance reporting
#
# Performance Target: 40-60% reduction in unnecessary step execution
################################################################################

# Set defaults
PROJECT_ROOT=${PROJECT_ROOT:-$(pwd)}
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}

# ==============================================================================
# FILE CHANGE DETECTION
# ==============================================================================

# Get modified files from Git
# Returns: List of modified files (newline-separated)
get_modified_files() {
    git diff --name-only HEAD 2>/dev/null || echo ""
}

# Get new directories
# Returns: Count of new directories
get_new_dirs_count() {
    local new_files=$(git ls-files --others --exclude-standard 2>/dev/null || echo "")
    [[ -z "$new_files" ]] && echo "0" && return 0
    
    # Get unique directories from new files
    local new_dirs=$(echo "$new_files" | xargs -r dirname 2>/dev/null | sort -u | wc -l)
    echo "${new_dirs:-0}"
}

# Get deleted directories
# Returns: Count of deleted directories  
get_deleted_dirs_count() {
    local deleted_files=$(git diff --name-only --diff-filter=D HEAD 2>/dev/null || echo "")
    [[ -z "$deleted_files" ]] && echo "0" && return 0
    
    # Get unique directories from deleted files
    local deleted_dirs=$(echo "$deleted_files" | xargs -r dirname 2>/dev/null | sort -u | wc -l)
    echo "${deleted_dirs:-0}"
}

# Check if modified files contain pattern
# Args: $1 = pattern (e.g., "docs/", "*.sh", "README.md")
# Returns: 0 if pattern found, 1 otherwise
modified_files_contain() {
    local pattern="$1"
    local modified=$(get_modified_files)
    
    [[ -z "$modified" ]] && return 1
    
    # Check each file against pattern
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        case "$pattern" in
            */*)
                # Directory pattern (e.g., "docs/")
                [[ "$file" == ${pattern}* ]] && return 0
                ;;
            *.*)
                # Extension pattern (e.g., "*.sh")
                [[ "$file" == $pattern ]] && return 0
                ;;
            *)
                # Exact filename (e.g., "README.md")
                [[ "$(basename "$file")" == "$pattern" ]] && return 0
                ;;
        esac
    done <<< "$modified"
    
    return 1
}

# ==============================================================================
# STEP CONDITIONS
# ==============================================================================

# Define conditions for each step
# Format: step_number:condition_expression
declare -A STEP_CONDITIONS
STEP_CONDITIONS=(
    # Step 0: Always run (pre-analysis)
    [0]="always"
    
    # Step 1: Documentation updates
    [1]="modified_files_contain 'docs/' OR modified_files_contain '*.md'"
    
    # Step 2: Consistency analysis
    [2]="modified_files_contain 'docs/' OR modified_files_contain 'README.md'"
    
    # Step 3: Script validation
    [3]="modified_files_contain '*.sh' OR modified_files_contain 'cdn-delivery'"
    
    # Step 4: Directory validation
    [4]="new_dirs > 0 OR deleted_dirs > 0"
    
    # Step 5: Test review
    [5]="modified_files_contain 'test' OR modified_files_contain 'spec'"
    
    # Step 6: Test generation
    [6]="modified_files_contain 'src/' OR modified_files_contain 'lib/'"
    
    # Step 7: Test execution
    [7]="modified_files_contain 'src/' OR modified_files_contain 'test'"
    
    # Step 8: Dependencies
    [8]="modified_files_contain 'package.json' OR modified_files_contain 'requirements.txt'"
    
    # Step 9: Code quality
    [9]="modified_files_contain 'src/' OR modified_files_contain 'lib/'"
    
    # Step 10: Context analysis
    [10]="always"
    
    # Step 11: Git finalization
    [11]="always"
    
    # Step 12: Markdown linting
    [12]="modified_files_contain '*.md'"
    
    # Step 13: Prompt engineer analysis
    [13]="modified_files_contain 'templates/' OR modified_files_contain 'prompts/'"
    
    # Step 14: UX analysis
    [14]="modified_files_contain 'components/' OR modified_files_contain 'pages/'"
)

# ==============================================================================
# CONDITION EVALUATION
# ==============================================================================

# Evaluate a condition expression
# Args: $1 = condition_expression
# Returns: 0 if condition met, 1 otherwise
evaluate_condition() {
    local condition="$1"
    
    # Always run
    [[ "$condition" == "always" ]] && return 0
    
    # Never run
    [[ "$condition" == "never" ]] && return 1
    
    # Parse condition expression
    # Support: AND, OR, >, <, ==, contains
    
    # Handle OR conditions
    if [[ "$condition" =~ OR ]]; then
        IFS=' OR ' read -ra conditions <<< "$condition"
        for cond in "${conditions[@]}"; do
            if evaluate_single_condition "$cond"; then
                return 0
            fi
        done
        return 1
    fi
    
    # Handle AND conditions
    if [[ "$condition" =~ AND ]]; then
        IFS=' AND ' read -ra conditions <<< "$condition"
        for cond in "${conditions[@]}"; do
            if ! evaluate_single_condition "$cond"; then
                return 1
            fi
        done
        return 0
    fi
    
    # Single condition
    evaluate_single_condition "$condition"
}

# Evaluate a single condition
# Args: $1 = single_condition
# Returns: 0 if true, 1 if false
evaluate_single_condition() {
    local condition="$1"
    
    # modified_files_contain 'pattern'
    if [[ "$condition" =~ modified_files_contain\ [\'\"](.*)[\'\"] ]]; then
        local pattern="${BASH_REMATCH[1]}"
        modified_files_contain "$pattern"
        return $?
    fi
    
    # new_dirs > N
    if [[ "$condition" =~ new_dirs\ \>\ ([0-9]+) ]]; then
        local threshold="${BASH_REMATCH[1]}"
        local count=$(get_new_dirs_count)
        [[ $count -gt $threshold ]]
        return $?
    fi
    
    # deleted_dirs > N
    if [[ "$condition" =~ deleted_dirs\ \>\ ([0-9]+) ]]; then
        local threshold="${BASH_REMATCH[1]}"
        local count=$(get_deleted_dirs_count)
        [[ $count -gt $threshold ]]
        return $?
    fi
    
    # total_changes > N
    if [[ "$condition" =~ total_changes\ \>\ ([0-9]+) ]]; then
        local threshold="${BASH_REMATCH[1]}"
        local count=$(get_modified_files | wc -l)
        [[ $count -gt $threshold ]]
        return $?
    fi
    
    # Unknown condition - default to true (safe)
    return 0
}

# ==============================================================================
# STEP EXECUTION DECISION
# ==============================================================================

# Check if step should execute based on conditions
# Args: $1 = step_number
# Returns: 0 if should execute, 1 if should skip
should_execute_step_conditional() {
    local step="$1"
    
    # Check if step has a condition
    local condition="${STEP_CONDITIONS[$step]:-always}"
    
    # Evaluate condition
    if evaluate_condition "$condition"; then
        return 0  # Should execute
    else
        return 1  # Should skip
    fi
}

# Get skip reason for step
# Args: $1 = step_number
# Returns: Human-readable skip reason
get_skip_reason() {
    local step="$1"
    local condition="${STEP_CONDITIONS[$step]:-always}"
    
    case "$step" in
        2)
            echo "No documentation or README changes detected"
            ;;
        3)
            echo "No shell scripts or cdn-delivery files modified"
            ;;
        4)
            echo "No new or deleted directories"
            ;;
        5|6|7)
            echo "No code or test files modified"
            ;;
        8)
            echo "No dependency files (package.json, requirements.txt) modified"
            ;;
        9)
            echo "No source code files modified"
            ;;
        12)
            echo "No markdown files modified"
            ;;
        13)
            echo "No template or prompt files modified"
            ;;
        14)
            echo "No component or page files modified"
            ;;
        *)
            echo "Condition not met: $condition"
            ;;
    esac
}

# ==============================================================================
# EXECUTION PLAN GENERATION
# ==============================================================================

# Generate execution plan based on conditions
# Returns: JSON with execution plan
generate_conditional_execution_plan() {
    local plan='{"steps":[],"skipped":[],"total":15,"executed":0}'
    
    local executed_steps=()
    local skipped_steps=()
    
    for step in {0..14}; do
        if should_execute_step_conditional "$step"; then
            executed_steps+=("$step")
        else
            skipped_steps+=("$step")
        fi
    done
    
    local executed_count=${#executed_steps[@]}
    local skipped_count=${#skipped_steps[@]}
    
    # Convert arrays to JSON
    local executed_json=$(printf '%s\n' "${executed_steps[@]}" | jq -R . | jq -s . 2>/dev/null || echo "[]")
    local skipped_json=$(printf '%s\n' "${skipped_steps[@]}" | jq -R . | jq -s . 2>/dev/null || echo "[]")
    
    cat << EOF
{
  "steps": $executed_json,
  "skipped": $skipped_json,
  "total": 15,
  "executed": $executed_count,
  "skipped_count": $skipped_count,
  "efficiency": $(( skipped_count * 100 / 15 ))
}
EOF
}

# Display execution plan
display_conditional_execution_plan() {
    local plan=$(generate_conditional_execution_plan)
    
    local executed=$(echo "$plan" | jq -r '.executed')
    local skipped=$(echo "$plan" | jq -r '.skipped_count')
    local efficiency=$(echo "$plan" | jq -r '.efficiency')
    
    print_header "Conditional Execution Plan"
    print_success "Steps to execute: $executed of 15"
    print_info "Steps to skip: $skipped of 15"
    print_info "Efficiency gain: ${efficiency}%"
    echo ""
    
    # Show skipped steps with reasons
    if [[ $skipped -gt 0 ]]; then
        print_info "Skipped steps:"
        local skipped_list=$(echo "$plan" | jq -r '.skipped[]')
        while IFS= read -r step; do
            [[ -z "$step" ]] && continue
            local reason=$(get_skip_reason "$step")
            echo "  • Step $step: $reason"
        done <<< "$skipped_list"
    fi
}

# ==============================================================================
# INTEGRATION WITH EXISTING SYSTEMS
# ==============================================================================

# Enhanced should_execute_step with conditional logic
# Args: $1 = step_number
# Returns: 0 if should execute, 1 if should skip
should_execute_step_enhanced() {
    local step="$1"
    
    # Check manual selection first (highest priority)
    if [[ -n "${EXECUTE_STEPS:-}" ]]; then
        if [[ ",$EXECUTE_STEPS," == *",$step,"* ]]; then
            return 0  # Explicitly selected
        else
            return 1  # Not selected
        fi
    fi
    
    # Check conditional execution
    if ! should_execute_step_conditional "$step"; then
        # Log skip reason
        if type -t log_to_workflow > /dev/null; then
            local reason=$(get_skip_reason "$step")
            log_to_workflow "INFO" "Step $step skipped: $reason"
        fi
        return 1
    fi
    
    # Default: execute
    return 0
}

# ==============================================================================
# STATISTICS AND REPORTING
# ==============================================================================

# Track conditional execution statistics
declare -A CONDITIONAL_STATS
CONDITIONAL_STATS=(
    [steps_evaluated]=0
    [steps_executed]=0
    [steps_skipped]=0
    [time_saved]=0
)

# Record step decision
# Args: $1 = step_number, $2 = executed (true/false)
record_step_decision() {
    local step="$1"
    local executed="$2"
    
    ((CONDITIONAL_STATS[steps_evaluated]++)) || true
    
    if [[ "$executed" == "true" ]]; then
        ((CONDITIONAL_STATS[steps_executed]++)) || true
    else
        ((CONDITIONAL_STATS[steps_skipped]++)) || true
        
        # Estimate time saved (based on average step time)
        local avg_time=90  # 90 seconds average
        ((CONDITIONAL_STATS[time_saved]+=avg_time)) || true
    fi
}

# Display conditional execution statistics
display_conditional_stats() {
    local evaluated=${CONDITIONAL_STATS[steps_evaluated]:-0}
    local executed=${CONDITIONAL_STATS[steps_executed]:-0}
    local skipped=${CONDITIONAL_STATS[steps_skipped]:-0}
    local time_saved=${CONDITIONAL_STATS[time_saved]:-0}
    
    [[ $evaluated -eq 0 ]] && return 0
    
    print_header "Conditional Execution Statistics"
    print_info "Steps evaluated: $evaluated"
    print_success "Steps executed: $executed"
    print_info "Steps skipped: $skipped"
    print_success "Time saved: ~$(( time_saved / 60 )) minutes"
    
    local skip_rate=$(( skipped * 100 / evaluated ))
    print_info "Skip rate: ${skip_rate}%"
}

# ==============================================================================
# CUSTOM CONDITIONS
# ==============================================================================

# Add custom condition for a step
# Args: $1 = step_number, $2 = condition_expression
add_step_condition() {
    local step="$1"
    local condition="$2"
    
    STEP_CONDITIONS[$step]="$condition"
}

# Remove condition for a step (always execute)
# Args: $1 = step_number
remove_step_condition() {
    local step="$1"
    STEP_CONDITIONS[$step]="always"
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f get_modified_files
export -f get_new_dirs_count
export -f get_deleted_dirs_count
export -f modified_files_contain
export -f evaluate_condition
export -f evaluate_single_condition
export -f should_execute_step_conditional
export -f get_skip_reason
export -f generate_conditional_execution_plan
export -f display_conditional_execution_plan
export -f should_execute_step_enhanced
export -f record_step_decision
export -f display_conditional_stats
export -f add_step_condition
export -f remove_step_condition

################################################################################
# End of Conditional Step Execution Module
################################################################################
