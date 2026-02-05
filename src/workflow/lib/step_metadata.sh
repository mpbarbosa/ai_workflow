#!/bin/bash
set -euo pipefail

################################################################################
# Step Metadata Module
# Purpose: Comprehensive metadata for workflow steps enabling smart execution
# Part of: Tests & Documentation Workflow Automation v2.6.1
# Version: 1.0.1
################################################################################

# ==============================================================================
# STEP METADATA DEFINITIONS
# ==============================================================================

# Declare step metadata as associative arrays
declare -A STEP_NAMES
declare -A STEP_DESCRIPTIONS
declare -A STEP_CATEGORIES
declare -A STEP_CAN_SKIP
declare -A STEP_CAN_PARALLELIZE
declare -A STEP_REQUIRES_AI
declare -A STEP_AFFECTS_FILES

# Step 0: Pre-Analysis
STEP_NAMES[0]="Pre-Analysis"
STEP_DESCRIPTIONS[0]="Analyze git state and recent changes, validate test infrastructure"
STEP_CATEGORIES[0]="analysis"
STEP_CAN_SKIP[0]=false
STEP_CAN_PARALLELIZE[0]=false
STEP_REQUIRES_AI[0]=false
STEP_AFFECTS_FILES[0]=""

# Step 1: Documentation Update
STEP_NAMES[1]="Documentation Update"
STEP_DESCRIPTIONS[1]="Update project documentation with AI assistance"
STEP_CATEGORIES[1]="documentation"
STEP_CAN_SKIP[1]=true
STEP_CAN_PARALLELIZE[1]=true
STEP_REQUIRES_AI[1]=true
STEP_AFFECTS_FILES[1]="docs/**/*.md,README.md"

# Step 2: Consistency Analysis
STEP_NAMES[2]="Consistency Analysis"
STEP_DESCRIPTIONS[2]="Verify documentation consistency with code"
STEP_CATEGORIES[2]="validation"
STEP_CAN_SKIP[2]=true
STEP_CAN_PARALLELIZE[2]=true
STEP_REQUIRES_AI[2]=true
STEP_AFFECTS_FILES[2]=""

# Step 3: Script Reference Validation
STEP_NAMES[3]="Script Reference Validation"
STEP_DESCRIPTIONS[3]="Validate shell script references and paths"
STEP_CATEGORIES[3]="validation"
STEP_CAN_SKIP[3]=true
STEP_CAN_PARALLELIZE[3]=true
STEP_REQUIRES_AI[3]=false
STEP_AFFECTS_FILES[3]=""

# Step 4: Directory Structure Validation
STEP_NAMES[4]="Directory Structure Validation"
STEP_DESCRIPTIONS[4]="Verify project directory structure and organization"
STEP_CATEGORIES[4]="validation"
STEP_CAN_SKIP[4]=true
STEP_CAN_PARALLELIZE[4]=true
STEP_REQUIRES_AI[4]=false
STEP_AFFECTS_FILES[4]=""

# Step 5: Test Review
STEP_NAMES[5]="Test Review"
STEP_DESCRIPTIONS[5]="Review existing tests for coverage and quality"
STEP_CATEGORIES[5]="testing"
STEP_CAN_SKIP[5]=true
STEP_CAN_PARALLELIZE[5]=true
STEP_REQUIRES_AI[5]=true
STEP_AFFECTS_FILES[5]=""

# Step 6: Test Generation
STEP_NAMES[6]="Test Generation"
STEP_DESCRIPTIONS[6]="Generate new tests with AI assistance"
STEP_CATEGORIES[6]="testing"
STEP_CAN_SKIP[6]=true
STEP_CAN_PARALLELIZE[6]=false
STEP_REQUIRES_AI[6]=true
STEP_AFFECTS_FILES[6]="tests/**/*.{sh,js,ts,py}"

# Step 7: Test Execution
STEP_NAMES[7]="Test Execution"
STEP_DESCRIPTIONS[7]="Execute full test suite and analyze results"
STEP_CATEGORIES[7]="testing"
STEP_CAN_SKIP[7]=false
STEP_CAN_PARALLELIZE[7]=false
STEP_REQUIRES_AI[7]=true
STEP_AFFECTS_FILES[7]=""

# Step 8: Dependency Validation
STEP_NAMES[8]="Dependency Validation"
STEP_DESCRIPTIONS[8]="Validate project dependencies and versions"
STEP_CATEGORIES[8]="validation"
STEP_CAN_SKIP[8]=true
STEP_CAN_PARALLELIZE[8]=true
STEP_REQUIRES_AI[8]=false
STEP_AFFECTS_FILES[8]=""

# Step 9: Code Quality Validation
STEP_NAMES[9]="Code Quality"
STEP_DESCRIPTIONS[9]="Analyze code quality and suggest improvements"
STEP_CATEGORIES[9]="quality"
STEP_CAN_SKIP[9]=true
STEP_CAN_PARALLELIZE[9]=true
STEP_REQUIRES_AI[9]=true
STEP_AFFECTS_FILES[9]="src/**/*.{sh,js,ts,py}"

# Step 10: Context Analysis
STEP_NAMES[10]="Context Analysis"
STEP_DESCRIPTIONS[10]="Synthesize workflow results and generate insights"
STEP_CATEGORIES[10]="analysis"
STEP_CAN_SKIP[10]=false
STEP_CAN_PARALLELIZE[10]=false
STEP_REQUIRES_AI[10]=true
STEP_AFFECTS_FILES[10]=""

# Step 11: Git Finalization
STEP_NAMES[11]="Git Finalization"
STEP_DESCRIPTIONS[11]="Generate commit message and finalize git operations"
STEP_CATEGORIES[11]="finalization"
STEP_CAN_SKIP[11]=false
STEP_CAN_PARALLELIZE[11]=false
STEP_REQUIRES_AI[11]=true
STEP_AFFECTS_FILES[11]=".git"

# Step 12: Markdown Linting
STEP_NAMES[12]="Markdown Linting"
STEP_DESCRIPTIONS[12]="Lint and format markdown documentation"
STEP_CATEGORIES[12]="quality"
STEP_CAN_SKIP[12]=true
STEP_CAN_PARALLELIZE[12]=true
STEP_REQUIRES_AI[12]=false
STEP_AFFECTS_FILES[12]="docs/**/*.md,README.md,*.md"

# Step 13: Prompt Engineer Analysis
STEP_NAMES[13]="Prompt Engineer Analysis"
STEP_DESCRIPTIONS[13]="Analyze and improve AI prompts used in workflow"
STEP_CATEGORIES[13]="quality"
STEP_CAN_SKIP[13]=true
STEP_CAN_PARALLELIZE[13]=true
STEP_REQUIRES_AI[13]=true
STEP_AFFECTS_FILES[13]=""

# Step 14: UX Analysis
STEP_NAMES[14]="UX Analysis"
STEP_DESCRIPTIONS[14]="Analyze user experience and accessibility"
STEP_CATEGORIES[14]="quality"
STEP_CAN_SKIP[14]=true
STEP_CAN_PARALLELIZE[14]=true
STEP_REQUIRES_AI[14]=true
STEP_AFFECTS_FILES[14]=""

# ==============================================================================
# METADATA QUERIES
# ==============================================================================

# Get step name
get_step_name() {
    local step_num="$1"
    echo "${STEP_NAMES[$step_num]:-Unknown}"
}

# Get step description
get_step_description() {
    local step_num="$1"
    echo "${STEP_DESCRIPTIONS[$step_num]:-No description}"
}

# Get step category
get_step_category() {
    local step_num="$1"
    echo "${STEP_CATEGORIES[$step_num]:-unknown}"
}

# Check if step can be skipped
can_skip_step() {
    local step_num="$1"
    local can_skip="${STEP_CAN_SKIP[$step_num]:-false}"
    [[ "$can_skip" == "true" ]]
}

# Check if step can be parallelized
can_parallelize_step() {
    local step_num="$1"
    local can_parallel="${STEP_CAN_PARALLELIZE[$step_num]:-false}"
    [[ "$can_parallel" == "true" ]]
}

# Check if step requires AI
requires_ai() {
    local step_num="$1"
    local needs_ai="${STEP_REQUIRES_AI[$step_num]:-false}"
    [[ "$needs_ai" == "true" ]]
}

# Get files affected by step
get_affected_files() {
    local step_num="$1"
    echo "${STEP_AFFECTS_FILES[$step_num]:-}"
}

# Get steps by category
get_steps_by_category() {
    local category="$1"
    local result=()
    
    for step in "${!STEP_CATEGORIES[@]}"; do
        if [[ "${STEP_CATEGORIES[$step]}" == "$category" ]]; then
            result+=("$step")
        fi
    done
    
    echo "${result[@]}" | tr ' ' '\n' | sort -n | tr '\n' ','
}

# Get skippable steps
get_skippable_steps() {
    local result=()
    
    for step in "${!STEP_CAN_SKIP[@]}"; do
        if [[ "${STEP_CAN_SKIP[$step]}" == "true" ]]; then
            result+=("$step")
        fi
    done
    
    echo "${result[@]}" | tr ' ' '\n' | sort -n | tr '\n' ','
}

# Get parallelizable steps
get_parallelizable_steps() {
    local result=()
    
    for step in "${!STEP_CAN_PARALLELIZE[@]}"; do
        if [[ "${STEP_CAN_PARALLELIZE[$step]}" == "true" ]]; then
            result+=("$step")
        fi
    done
    
    echo "${result[@]}" | tr ' ' '\n' | sort -n | tr '\n' ','
}

# Get AI-dependent steps
get_ai_dependent_steps() {
    local result=()
    
    for step in "${!STEP_REQUIRES_AI[@]}"; do
        if [[ "${STEP_REQUIRES_AI[$step]}" == "true" ]]; then
            result+=("$step")
        fi
    done
    
    echo "${result[@]}" | tr ' ' '\n' | sort -n | tr '\n' ','
}

# Generate step metadata report
generate_metadata_report() {
    echo "=== Workflow Step Metadata ==="
    echo
    
    for step in {0..14}; do
        # Skip step 11 position, show actual steps
        if [[ ! -v STEP_NAMES[$step] ]]; then
            continue
        fi
        
        echo "Step $step: ${STEP_NAMES[$step]}"
        echo "  Category: ${STEP_CATEGORIES[$step]}"
        echo "  Description: ${STEP_DESCRIPTIONS[$step]}"
        echo "  Can Skip: ${STEP_CAN_SKIP[$step]}"
        echo "  Can Parallelize: ${STEP_CAN_PARALLELIZE[$step]}"
        echo "  Requires AI: ${STEP_REQUIRES_AI[$step]}"
        
        local deps="${STEP_DEPENDENCIES[$step]:-}"
        if [[ -n "$deps" ]]; then
            echo "  Dependencies: $deps"
        else
            echo "  Dependencies: none"
        fi
        
        local files="${STEP_AFFECTS_FILES[$step]}"
        if [[ -n "$files" ]]; then
            echo "  Affects Files: $files"
        fi
        
        echo
    done
}

# Export functions
export -f get_step_name
export -f get_step_description
export -f get_step_category
export -f can_skip_step
export -f can_parallelize_step
export -f requires_ai
export -f get_affected_files
export -f get_steps_by_category
export -f get_skippable_steps
export -f get_parallelizable_steps
export -f get_ai_dependent_steps
export -f generate_metadata_report

################################################################################
# Module initialized
################################################################################
