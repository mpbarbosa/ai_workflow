#!/bin/bash
set -euo pipefail

################################################################################
# Change Type Detection Module
# Purpose: Auto-detect docs-only, test-only, or full-stack changes
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Created: December 18, 2025
################################################################################

# ==============================================================================
# CHANGE CLASSIFICATION
# ==============================================================================

# Change type categories
declare -A CHANGE_TYPES
CHANGE_TYPES=(
    ["docs-only"]="Documentation changes only"
    ["tests-only"]="Test files only"
    ["config-only"]="Configuration files only"
    ["scripts-only"]="Shell scripts only"
    ["code-only"]="Source code only"
    ["full-stack"]="Multiple categories (full workflow required)"
    ["mixed"]="Mixed changes across categories"
    ["unknown"]="Unable to classify changes"
)

# File pattern categories
declare -A FILE_PATTERNS
FILE_PATTERNS=(
    ["docs"]="*.md|*.txt|*.rst|docs/*|README*|CHANGELOG*|LICENSE*"
    ["tests"]="*test*.js|*spec*.js|__tests__/*|*.test.mjs|*.spec.mjs"
    ["config"]="*.json|*.yaml|*.yml|*.toml|*.ini|.editorconfig|.gitignore|.nvmrc|.node-version|.mdlrc"
    ["scripts"]="*.sh|shell_scripts/*|Makefile"
    ["code"]="*.js|*.mjs|*.ts|*.tsx|*.jsx|*.css|*.html|*.php|*.py|*.go|*.rs"
    ["assets"]="*.png|*.jpg|*.jpeg|*.gif|*.svg|*.ico|*.woff|*.woff2|*.ttf|*.eot"
)

# Step execution recommendations based on change type
declare -A STEP_RECOMMENDATIONS
STEP_RECOMMENDATIONS=(
    ["docs-only"]="0,1,2,11,12"  # Pre-analysis, Docs, Consistency, Git, Markdown lint
    ["tests-only"]="0,5,6,7,11"  # Pre-analysis, Test review, Test gen, Test exec, Git
    ["config-only"]="0,8,11"     # Pre-analysis, Dependencies, Git
    ["scripts-only"]="0,3,4,11"  # Pre-analysis, Script refs, Directory, Git
    ["code-only"]="0,5,6,7,9,11" # Pre-analysis, Tests, Code quality, Git
    ["full-stack"]="0,1,2,3,4,5,6,7,8,9,10,11,12"  # All steps
)

# ==============================================================================
# CHANGE DETECTION
# ==============================================================================

# Detect change type from git status
# Usage: detect_change_type
# Returns: Change type category
detect_change_type() {
    local modified_files=$(git diff --name-only HEAD 2>/dev/null)
    local staged_files=$(git diff --cached --name-only 2>/dev/null)
    local untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null)
    
    # Combine all changed files
    local all_changes=$(echo -e "${modified_files}\n${staged_files}\n${untracked_files}" | sort -u | grep -v '^$')
    
    if [[ -z "${all_changes}" ]]; then
        echo "unknown"
        return
    fi
    
    # Count files in each category
    local docs_count=0
    local tests_count=0
    local config_count=0
    local scripts_count=0
    local code_count=0
    local assets_count=0
    local total_count=0
    
    while IFS= read -r file; do
        [[ -z "${file}" ]] && continue
        ((total_count++))
        
        if matches_pattern "${file}" "${FILE_PATTERNS[docs]}"; then
            ((docs_count++))
        elif matches_pattern "${file}" "${FILE_PATTERNS[tests]}"; then
            ((tests_count++))
        elif matches_pattern "${file}" "${FILE_PATTERNS[config]}"; then
            ((config_count++))
        elif matches_pattern "${file}" "${FILE_PATTERNS[scripts]}"; then
            ((scripts_count++))
        elif matches_pattern "${file}" "${FILE_PATTERNS[assets]}"; then
            ((assets_count++))
        elif matches_pattern "${file}" "${FILE_PATTERNS[code]}"; then
            ((code_count++))
        fi
    done <<< "${all_changes}"
    
    # Determine change type based on counts
    local categories_changed=0
    [[ ${docs_count} -gt 0 ]] && ((categories_changed++))
    [[ ${tests_count} -gt 0 ]] && ((categories_changed++))
    [[ ${config_count} -gt 0 ]] && ((categories_changed++))
    [[ ${scripts_count} -gt 0 ]] && ((categories_changed++))
    [[ ${code_count} -gt 0 ]] && ((categories_changed++))
    
    # Classification logic
    if [[ ${categories_changed} -eq 0 ]]; then
        echo "unknown"
    elif [[ ${categories_changed} -eq 1 ]]; then
        # Single category - determine which one
        if [[ ${docs_count} -eq ${total_count} ]]; then
            echo "docs-only"
        elif [[ ${tests_count} -eq ${total_count} ]]; then
            echo "tests-only"
        elif [[ ${config_count} -eq ${total_count} ]]; then
            echo "config-only"
        elif [[ ${scripts_count} -eq ${total_count} ]]; then
            echo "scripts-only"
        elif [[ ${code_count} -eq ${total_count} ]]; then
            echo "code-only"
        else
            echo "mixed"
        fi
    elif [[ ${categories_changed} -ge 3 ]]; then
        echo "full-stack"
    else
        echo "mixed"
    fi
}

# Check if file matches pattern
# Usage: matches_pattern <file> <pattern>
matches_pattern() {
    local file="$1"
    local patterns="$2"
    
    # Split patterns by pipe and check each
    IFS='|' read -ra PATTERN_ARRAY <<< "${patterns}"
    for pattern in "${PATTERN_ARRAY[@]}"; do
        if [[ "${file}" == ${pattern} ]] || [[ "${file}" == *"${pattern}"* ]]; then
            return 0
        fi
    done
    
    return 1
}

# ==============================================================================
# CHANGE ANALYSIS
# ==============================================================================

# Get detailed change analysis
# Usage: analyze_changes
# Prints detailed breakdown of changes by category
analyze_changes() {
    local modified_files=$(git diff --name-only HEAD 2>/dev/null)
    local staged_files=$(git diff --cached --name-only 2>/dev/null)
    local untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null)
    
    local all_changes=$(echo -e "${modified_files}\n${staged_files}\n${untracked_files}" | sort -u | grep -v '^$')
    
    echo "## Change Analysis"
    echo ""
    echo "**Total Files Changed:** $(echo "${all_changes}" | wc -l)"
    echo ""
    
    # Count by category
    local docs_files=$(echo "${all_changes}" | while read -r f; do matches_pattern "$f" "${FILE_PATTERNS[docs]}" && echo "$f"; done)
    local tests_files=$(echo "${all_changes}" | while read -r f; do matches_pattern "$f" "${FILE_PATTERNS[tests]}" && echo "$f"; done)
    local config_files=$(echo "${all_changes}" | while read -r f; do matches_pattern "$f" "${FILE_PATTERNS[config]}" && echo "$f"; done)
    local scripts_files=$(echo "${all_changes}" | while read -r f; do matches_pattern "$f" "${FILE_PATTERNS[scripts]}" && echo "$f"; done)
    local code_files=$(echo "${all_changes}" | while read -r f; do matches_pattern "$f" "${FILE_PATTERNS[code]}" && echo "$f"; done)
    
    # Display breakdown
    echo "### By Category"
    echo ""
    [[ -n "${docs_files}" ]] && echo "- **Documentation:** $(echo "${docs_files}" | wc -l) files"
    [[ -n "${tests_files}" ]] && echo "- **Tests:** $(echo "${tests_files}" | wc -l) files"
    [[ -n "${config_files}" ]] && echo "- **Configuration:** $(echo "${config_files}" | wc -l) files"
    [[ -n "${scripts_files}" ]] && echo "- **Scripts:** $(echo "${scripts_files}" | wc -l) files"
    [[ -n "${code_files}" ]] && echo "- **Code:** $(echo "${code_files}" | wc -l) files"
    echo ""
    
    # Determine change type
    local change_type=$(detect_change_type)
    echo "### Classification"
    echo ""
    echo "**Change Type:** ${change_type}"
    echo "**Description:** ${CHANGE_TYPES[${change_type}]}"
    echo ""
}

# ==============================================================================
# STEP RECOMMENDATIONS
# ==============================================================================

# Get recommended steps for detected change type
# Usage: get_recommended_steps
# Returns: Comma-separated list of step numbers
get_recommended_steps() {
    local change_type=$(detect_change_type)
    
    # Return recommendation or full workflow as fallback
    echo "${STEP_RECOMMENDATIONS[${change_type}]:-${STEP_RECOMMENDATIONS[full-stack]}}"
}

# Check if step should be executed based on change type
# Usage: should_execute_step <step_number>
# Returns: 0 (true) if step should run, 1 (false) otherwise
should_execute_step() {
    local step_num="$1"
    local recommended_steps=$(get_recommended_steps)
    
    # Check if step is in recommended list
    if echo ",${recommended_steps}," | grep -q ",${step_num},"; then
        return 0
    else
        return 1
    fi
}

# Display step execution plan based on change detection
display_execution_plan() {
    local change_type=$(detect_change_type)
    local recommended_steps=$(get_recommended_steps)
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║             WORKFLOW EXECUTION PLAN                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Change Type: ${change_type}"
    echo "Description: ${CHANGE_TYPES[${change_type}]}"
    echo ""
    echo "Recommended Steps:"
    
    IFS=',' read -ra STEPS <<< "${recommended_steps}"
    for step in "${STEPS[@]}"; do
        local step_name=$(get_step_name_for_display "${step}")
        printf "  ✓ Step %2d: %s\n" "${step}" "${step_name}"
    done
    
    echo ""
    echo "Steps that can be skipped:"
    
    for i in {0..12}; do
        if ! should_execute_step "${i}"; then
            local step_name=$(get_step_name_for_display "${i}")
            printf "  ⏭️  Step %2d: %s\n" "${i}" "${step_name}"
        fi
    done
    
    echo ""
}

# Get human-readable step name for display
get_step_name_for_display() {
    local step_num="$1"
    
    case "${step_num}" in
        0) echo "Pre-Analysis" ;;
        1) echo "Documentation Updates" ;;
        2) echo "Consistency Analysis" ;;
        3) echo "Script Reference Validation" ;;
        4) echo "Directory Structure Validation" ;;
        5) echo "Test Review" ;;
        6) echo "Test Generation" ;;
        7) echo "Test Execution" ;;
        8) echo "Dependency Validation" ;;
        9) echo "Code Quality Validation" ;;
        10) echo "Context Analysis" ;;
        11) echo "Git Finalization" ;;
        12) echo "Markdown Linting" ;;
        *) echo "Unknown Step" ;;
    esac
}

# ==============================================================================
# CHANGE IMPACT ASSESSMENT
# ==============================================================================

# Assess change impact for risk analysis
# Returns: low, medium, high
assess_change_impact() {
    local change_type=$(detect_change_type)
    local total_files=$(git diff --name-only HEAD 2>/dev/null | wc -l)
    
    # Impact based on change type and file count
    case "${change_type}" in
        docs-only|config-only)
            echo "low"
            ;;
        tests-only|scripts-only)
            if [[ ${total_files} -gt 10 ]]; then
                echo "medium"
            else
                echo "low"
            fi
            ;;
        code-only|mixed)
            if [[ ${total_files} -gt 20 ]]; then
                echo "high"
            elif [[ ${total_files} -gt 10 ]]; then
                echo "medium"
            else
                echo "low"
            fi
            ;;
        full-stack)
            echo "high"
            ;;
        *)
            echo "medium"
            ;;
    esac
}

# Generate change summary report
generate_change_report() {
    local output_file="${BACKLOG_RUN_DIR}/CHANGE_DETECTION_REPORT.md"
    
    mkdir -p "${BACKLOG_RUN_DIR}"
    
    cat > "${output_file}" << EOF
# Change Detection Report

**Workflow Run:** ${WORKFLOW_RUN_ID}
**Generated:** $(date '+%Y-%m-%d %H:%M:%S')

---

$(analyze_changes)

### Change Impact

**Risk Level:** $(assess_change_impact)

### Recommended Workflow

$(get_recommended_steps | tr ',' '\n' | while read -r step; do
    echo "- Step ${step}: $(get_step_name_for_display "${step}")"
done)

---

*Generated by Change Detection Module v2.0.0*
EOF
    
    echo "${output_file}"
}

# Export functions for use in workflow
export -f detect_change_type analyze_changes get_recommended_steps
export -f should_execute_step display_execution_plan assess_change_impact
export -f generate_change_report
