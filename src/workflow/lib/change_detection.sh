#!/bin/bash
set -euo pipefail

################################################################################
# Change Type Detection Module
# Purpose: Auto-detect docs-only, test-only, or full-stack changes
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Created: December 18, 2025
################################################################################

# ==============================================================================
# EPHEMERAL FILE FILTERING
# ==============================================================================

# Workflow artifact patterns to exclude from change detection
# These are generated during workflow execution and should not trigger steps
declare -a WORKFLOW_ARTIFACTS
WORKFLOW_ARTIFACTS=(
    ".ai_workflow/backlog/*"
    ".ai_workflow/logs/*"
    ".ai_workflow/summaries/*"
    "src/workflow/metrics/*"
    "src/workflow/.checkpoints/*"
    "src/workflow/.ai_cache/*"
    ".ai_workflow/*"
    "src/workflow/backlog/*"
    "src/workflow/logs/*"
    "src/workflow/summaries/*"
    "src/workflow/metrics/*"
    "*.tmp"
    "*.bak"
    "*.swp"
    "*~"
    ".DS_Store"
    "Thumbs.db"
)

# Filter out ephemeral workflow artifacts from file list
# Usage: filter_workflow_artifacts <file_list>
# Returns: Filtered file list (one file per line)
filter_workflow_artifacts() {
    local file_list="$1"
    
    # Return empty if input is empty
    [[ -z "$file_list" ]] && return 0
    
    local filtered=""
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        local should_exclude=false
        
        # Check each artifact pattern
        for pattern in "${WORKFLOW_ARTIFACTS[@]}"; do
            # Convert glob pattern to regex for matching
            local regex_pattern="${pattern//\*/.*}"
            
            if [[ "$file" =~ ^${regex_pattern}$ ]]; then
                should_exclude=true
                break
            fi
        done
        
        # Include file if not excluded
        if [[ "$should_exclude" == false ]]; then
            filtered+="${file}"$'\n'
        fi
    done <<< "$file_list"
    
    # Remove trailing newline and output
    echo -n "$filtered"
}

# Check if a single file is a workflow artifact
# Usage: is_workflow_artifact <file_path>
# Returns: 0 (true) if artifact, 1 (false) otherwise
is_workflow_artifact() {
    local file="$1"
    
    for pattern in "${WORKFLOW_ARTIFACTS[@]}"; do
        local regex_pattern="${pattern//\*/.*}"
        
        if [[ "$file" =~ ^${regex_pattern}$ ]]; then
            return 0
        fi
    done
    
    return 1
}

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
    ["config"]="*.json|*.yaml|*.yml|*.toml|*.ini|.editorconfig|.gitignore|.nvmrc|.node-version|.mdlrc|.env.example|Dockerfile|docker-compose.yml|docker-compose.*.yml|.dockerignore|tsconfig.json|jsconfig.json|.eslintrc*|.prettierrc*|pyproject.toml|setup.cfg|tox.ini|Cargo.toml|go.mod|go.sum|.gitlab-ci.yml|Jenkinsfile|.circleci/config.yml|.github/workflows/*.yml|.github/workflows/*.yaml"
    ["scripts"]="*.sh|src/workflow/*|Makefile"
    ["code"]="*.js|*.mjs|*.ts|*.tsx|*.jsx|*.css|*.html|*.php|*.py|*.go|*.rs"
    ["assets"]="*.png|*.jpg|*.jpeg|*.gif|*.svg|*.ico|*.woff|*.woff2|*.ttf|*.eot"
)

# Step execution recommendations based on change type
declare -A STEP_RECOMMENDATIONS
STEP_RECOMMENDATIONS=(
    ["docs-only"]="0,1,2,12,13"  # Pre-analysis, Docs, Consistency, Git, Markdown lint
    ["tests-only"]="0,6,7,8,12"  # Pre-analysis, Test review, Test gen, Test exec, Git
    ["config-only"]="0,4,5,9,12"   # Pre-analysis, Config validation, Dependencies, Git (Step 4 will be new config step)
    ["scripts-only"]="0,3,5,12"  # Pre-analysis, Script refs, Directory, Git
    ["code-only"]="0,6,7,8,10,12" # Pre-analysis, Tests, Code quality, Git
    ["full-stack"]="0,1,2,3,4,5,6,7,8,9,10,11,12,13"  # All steps
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
    
    # Filter out workflow artifacts
    all_changes=$(filter_workflow_artifacts "$all_changes")
    
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
        ((total_count++)) || true
        
        if matches_pattern "${file}" "${FILE_PATTERNS[docs]}"; then
            ((docs_count++)) || true
        elif matches_pattern "${file}" "${FILE_PATTERNS[tests]}"; then
            ((tests_count++)) || true
        elif matches_pattern "${file}" "${FILE_PATTERNS[config]}"; then
            ((config_count++)) || true
        elif matches_pattern "${file}" "${FILE_PATTERNS[scripts]}"; then
            ((scripts_count++)) || true
        elif matches_pattern "${file}" "${FILE_PATTERNS[assets]}"; then
            ((assets_count++)) || true
        elif matches_pattern "${file}" "${FILE_PATTERNS[code]}"; then
            ((code_count++)) || true
        fi
    done <<< "${all_changes}"
    
    # Determine change type based on counts
    local categories_changed=0
    [[ ${docs_count} -gt 0 ]] && ((categories_changed++)) || true
    [[ ${tests_count} -gt 0 ]] && ((categories_changed++)) || true
    [[ ${config_count} -gt 0 ]] && ((categories_changed++)) || true
    [[ ${scripts_count} -gt 0 ]] && ((categories_changed++)) || true
    [[ ${code_count} -gt 0 ]] && ((categories_changed++)) || true
    
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
    
    # Filter out workflow artifacts
    local filtered_changes=$(filter_workflow_artifacts "$all_changes")
    local artifacts_filtered=$(($(echo "$all_changes" | wc -l) - $(echo "$filtered_changes" | wc -l)))
    
    echo "## Change Analysis"
    echo ""
    echo "**Total Files Changed:** $(echo "${filtered_changes}" | wc -l)"
    if [[ $artifacts_filtered -gt 0 ]]; then
        echo "**Workflow Artifacts Filtered:** ${artifacts_filtered}"
    fi
    echo ""
    
    # Count by category
    local docs_files=$(echo "${filtered_changes}" | while read -r f; do matches_pattern "$f" "${FILE_PATTERNS[docs]}" && echo "$f"; done)
    local tests_files=$(echo "${filtered_changes}" | while read -r f; do matches_pattern "$f" "${FILE_PATTERNS[tests]}" && echo "$f"; done)
    local config_files=$(echo "${filtered_changes}" | while read -r f; do matches_pattern "$f" "${FILE_PATTERNS[config]}" && echo "$f"; done)
    local scripts_files=$(echo "${filtered_changes}" | while read -r f; do matches_pattern "$f" "${FILE_PATTERNS[scripts]}" && echo "$f"; done)
    local code_files=$(echo "${filtered_changes}" | while read -r f; do matches_pattern "$f" "${FILE_PATTERNS[code]}" && echo "$f"; done)
    
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
    local all_files=$(git diff --name-only HEAD 2>/dev/null)
    local filtered_files=$(filter_workflow_artifacts "$all_files")
    local total_files=$(echo "$filtered_files" | grep -v '^$' | wc -l)
    
    # Count code files specifically
    local code_count=0
    local doc_count=0
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        if matches_pattern "$file" "${FILE_PATTERNS[code]}"; then
            ((code_count++)) || true
        elif matches_pattern "$file" "${FILE_PATTERNS[docs]}"; then
            ((doc_count++)) || true
        fi
    done <<< "$filtered_files"
    
    # Impact based on change type and file count
    # Calibrated thresholds (v2.3.1):
    # - Low: docs/config only with <= 50 files
    # - Medium: 1-5 code files OR 10+ test/script files
    # - High: 6+ code files OR 50+ total files with code OR breaking changes
    case "${change_type}" in
        docs-only|config-only)
            # Pure documentation/config changes
            if [[ ${doc_count} -gt 50 ]]; then
                echo "medium"
            else
                echo "low"
            fi
            ;;
        tests-only|scripts-only)
            # Test or script changes
            if [[ ${total_files} -gt 10 ]]; then
                echo "medium"
            else
                echo "low"
            fi
            ;;
        code-only|mixed)
            # Code changes: any code = medium minimum
            if [[ ${code_count} -gt 5 ]] || [[ ${total_files} -gt 50 ]]; then
                echo "high"
            elif [[ ${code_count} -gt 0 ]]; then
                # 1-5 code files = medium impact
                echo "medium"
            else
                # Fallback (shouldn't happen for code-only/mixed)
                echo "medium"
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

# ==============================================================================
# FILE CLASSIFICATION FOR MODEL SELECTION (v3.2.0)
# ==============================================================================

# Classify changed files into code, documentation, tests, and config
# Usage: classify_files_by_nature
# Returns: Four pipe-separated lists: "code_files|doc_files|test_files|config_files"
classify_files_by_nature() {
    local modified_files=$(git diff --name-only HEAD 2>/dev/null)
    local staged_files=$(git diff --cached --name-only 2>/dev/null)
    local untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null)
    
    # Combine all changed files
    local all_changes=$(echo -e "${modified_files}\n${staged_files}\n${untracked_files}" | sort -u | grep -v '^$')
    
    # Filter out workflow artifacts
    all_changes=$(filter_workflow_artifacts "$all_changes")
    
    local code_files=""
    local doc_files=""
    local test_files=""
    local config_files=""
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        # Priority: tests > docs > config > code (to handle ambiguous files)
        if matches_pattern "$file" "${FILE_PATTERNS[tests]}"; then
            test_files="${test_files}${file} "
        elif matches_pattern "$file" "${FILE_PATTERNS[docs]}"; then
            doc_files="${doc_files}${file} "
        elif matches_pattern "$file" "${FILE_PATTERNS[config]}"; then
            config_files="${config_files}${file} "
        elif matches_pattern "$file" "${FILE_PATTERNS[code]}"; then
            code_files="${code_files}${file} "
        elif matches_pattern "$file" "${FILE_PATTERNS[scripts]}"; then
            # Treat scripts as code
            code_files="${code_files}${file} "
        fi
    done <<< "$all_changes"
    
    # Trim trailing spaces
    code_files=$(echo "$code_files" | xargs)
    doc_files=$(echo "$doc_files" | xargs)
    test_files=$(echo "$test_files" | xargs)
    config_files=$(echo "$config_files" | xargs)
    
    # Return pipe-delimited with 4 categories
    echo "${code_files}|${doc_files}|${test_files}|${config_files}"
}

# Export functions for use in workflow
export -f filter_workflow_artifacts is_workflow_artifact
export -f detect_change_type analyze_changes get_recommended_steps
export -f should_execute_step display_execution_plan assess_change_impact
export -f generate_change_report classify_files_by_nature
