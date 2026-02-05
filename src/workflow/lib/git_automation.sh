#!/bin/bash
set -euo pipefail

################################################################################
# Git Automation and Post-Workflow Actions Module
# Version: 2.7.1
# Purpose: Intelligent post-workflow Git automation and artifact staging
#
# Features:
#   - Smart artifact detection and staging
#   - Conditional auto-staging based on workflow success
#   - Intelligent commit message generation
#   - Configurable staging rules
#   - Dry-run mode support
#
# Performance Target: Reduce manual Git operations by 80%
################################################################################

# Set defaults
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}
GIT_AUTOMATION_ENABLED=${GIT_AUTOMATION_ENABLED:-true}
AUTO_STAGE_ARTIFACTS=${AUTO_STAGE_ARTIFACTS:-true}

# ==============================================================================
# ARTIFACT DETECTION
# ==============================================================================

# Define artifact patterns for auto-staging
declare -A ARTIFACT_PATTERNS
ARTIFACT_PATTERNS=(
    # Workflow artifacts
    ["workflow_logs"]="src/workflow/logs/**/*.log"
    ["workflow_backlog"]="src/workflow/backlog/**/*.md"
    ["workflow_summaries"]="src/workflow/summaries/**/*.md"
    ["workflow_metrics"]="src/workflow/metrics/**/*.json"
    
    # Generated documentation
    ["generated_docs"]="docs/**/*.md"
    ["api_docs"]="docs/api/**/*"
    
    # Test artifacts
    ["test_results"]="test-results/**/*"
    ["coverage"]="coverage/**/*"
    
    # Build artifacts (selective)
    ["cdn_urls"]="cdn-urls.txt"
    ["build_manifest"]="build-manifest.json"
    
    # Configuration updates
    ["workflow_config"]=".workflow-config.yaml"
    ["tech_stack_config"]=".tech-stack.yaml"
)

# Patterns to EXCLUDE from auto-staging (sensitive/temporary)
declare -A EXCLUDE_PATTERNS
EXCLUDE_PATTERNS=(
    ["node_modules"]="**/node_modules/**"
    ["temp"]="**/.tmp/**"
    ["cache"]="**/.cache/**"
    ["secrets"]="**/*secret* **/*password* **/*.key **/*.pem"
    ["local_config"]="**/*.local.* **/local-*"
)

# Detect workflow artifacts that should be staged
# Returns: List of files to stage (newline-separated)
detect_workflow_artifacts() {
    local artifacts=""
    
    # Check each artifact pattern
    for artifact_type in "${!ARTIFACT_PATTERNS[@]}"; do
        local pattern="${ARTIFACT_PATTERNS[$artifact_type]}"
        
        # Find files matching pattern that are modified or new
        while IFS= read -r file; do
            [[ -z "$file" ]] && continue
            
            # Skip if matches exclude pattern
            local should_exclude=false
            for exclude_pattern in "${EXCLUDE_PATTERNS[@]}"; do
                if [[ "$file" == $exclude_pattern ]]; then
                    should_exclude=true
                    break
                fi
            done
            
            [[ "$should_exclude" == "true" ]] && continue
            
            # Add to artifacts list
            artifacts+="$file"$'\n'
        done < <(git ls-files --modified --deleted --others --exclude-standard "$pattern" 2>/dev/null || true)
    done
    
    echo "$artifacts" | sort -u | grep -v '^$'
}

# Categorize artifacts by type
# Args: $@ = file paths
# Returns: JSON with categorized files
categorize_artifacts() {
    local docs=()
    local tests=()
    local logs=()
    local config=()
    local other=()
    
    for file in "$@"; do
        case "$file" in
            docs/*|*.md)
                docs+=("$file")
                ;;
            test-results/*|coverage/*)
                tests+=("$file")
                ;;
            src/workflow/logs/*|src/workflow/backlog/*|src/workflow/summaries/*)
                logs+=("$file")
                ;;
            *config*.yaml|*config*.json)
                config+=("$file")
                ;;
            *)
                other+=("$file")
                ;;
        esac
    done
    
    # Convert to JSON
    local docs_json=$(printf '%s\n' "${docs[@]}" 2>/dev/null | jq -R . | jq -s . || echo "[]")
    local tests_json=$(printf '%s\n' "${tests[@]}" 2>/dev/null | jq -R . | jq -s . || echo "[]")
    local logs_json=$(printf '%s\n' "${logs[@]}" 2>/dev/null | jq -R . | jq -s . || echo "[]")
    local config_json=$(printf '%s\n' "${config[@]}" 2>/dev/null | jq -R . | jq -s . || echo "[]")
    local other_json=$(printf '%s\n' "${other[@]}" 2>/dev/null | jq -R . | jq -s . || echo "[]")
    
    cat << EOF
{
  "docs": $docs_json,
  "tests": $tests_json,
  "logs": $logs_json,
  "config": $config_json,
  "other": $other_json
}
EOF
}

# ==============================================================================
# INTELLIGENT STAGING
# ==============================================================================

# Stage workflow artifacts based on success/failure
# Args: $1 = workflow_status (success/failure)
stage_workflow_artifacts() {
    local status="${1:-success}"
    
    if [[ "${AUTO_STAGE_ARTIFACTS}" != "true" ]]; then
        return 0
    fi
    
    print_header "Git Automation: Staging Workflow Artifacts"
    
    # Detect artifacts
    local artifacts=$(detect_workflow_artifacts)
    
    if [[ -z "$artifacts" ]]; then
        print_info "No workflow artifacts to stage"
        return 0
    fi
    
    local artifact_count=$(echo "$artifacts" | wc -l)
    print_success "Detected $artifact_count workflow artifact(s)"
    
    # Categorize for reporting
    local categories=$(categorize_artifacts $artifacts)
    local docs_count=$(echo "$categories" | jq -r '.docs | length')
    local tests_count=$(echo "$categories" | jq -r '.tests | length')
    local logs_count=$(echo "$categories" | jq -r '.logs | length')
    local config_count=$(echo "$categories" | jq -r '.config | length')
    
    print_info "Artifact breakdown:"
    [[ $docs_count -gt 0 ]] && print_info "  • Documentation: $docs_count files"
    [[ $tests_count -gt 0 ]] && print_info "  • Test results: $tests_count files"
    [[ $logs_count -gt 0 ]] && print_info "  • Workflow logs: $logs_count files"
    [[ $config_count -gt 0 ]] && print_info "  • Configuration: $config_count files"
    
    # Conditional staging based on status
    if [[ "$status" == "success" ]]; then
        # Stage all artifacts on success
        if [[ "${DRY_RUN:-false}" == "true" ]]; then
            print_info "[DRY RUN] Would stage $artifact_count artifacts"
            while IFS= read -r file; do
                echo "  - $file"
            done <<< "$artifacts"
        else
            print_info "Staging artifacts..."
            while IFS= read -r file; do
                [[ -z "$file" ]] && continue
                if git add "$file" 2>/dev/null; then
                    print_success "  ✓ Staged: $file"
                else
                    print_warning "  ⚠ Could not stage: $file"
                fi
            done <<< "$artifacts"
            
            print_success "All artifacts staged successfully"
        fi
    else
        # On failure, only stage logs for debugging
        print_warning "Workflow failed - staging only logs for debugging"
        
        local log_files=$(echo "$categories" | jq -r '.logs[]' 2>/dev/null)
        
        if [[ -n "$log_files" ]]; then
            if [[ "${DRY_RUN:-false}" == "true" ]]; then
                print_info "[DRY RUN] Would stage log files"
            else
                while IFS= read -r file; do
                    [[ -z "$file" ]] && continue
                    git add "$file" 2>/dev/null && print_success "  ✓ Staged log: $file"
                done <<< "$log_files"
            fi
        fi
    fi
    
    # Log staging action
    if type -t log_to_workflow > /dev/null; then
        log_to_workflow "INFO" "Auto-staged $artifact_count workflow artifacts (status: $status)"
    fi
}

# ==============================================================================
# SMART COMMIT MESSAGE GENERATION
# ==============================================================================

# Generate context-aware commit message for workflow artifacts
# Returns: Commit message
generate_artifact_commit_message() {
    local status="${1:-success}"
    
    # Get artifact summary
    local artifacts=$(detect_workflow_artifacts)
    local artifact_count=$(echo "$artifacts" | wc -l 2>/dev/null || echo "0")
    
    if [[ $artifact_count -eq 0 ]]; then
        echo "chore: update workflow artifacts"
        return 0
    fi
    
    # Categorize artifacts
    local categories=$(categorize_artifacts $artifacts)
    local docs_count=$(echo "$categories" | jq -r '.docs | length')
    local tests_count=$(echo "$categories" | jq -r '.tests | length')
    local logs_count=$(echo "$categories" | jq -r '.logs | length')
    local config_count=$(echo "$categories" | jq -r '.config | length')
    
    # Generate commit message based on primary artifact type
    local message=""
    local scope=""
    
    # Determine primary type
    if [[ $docs_count -gt 0 && $docs_count -ge $((artifact_count / 2)) ]]; then
        scope="docs"
        message="docs: update documentation artifacts"
    elif [[ $tests_count -gt 0 && $tests_count -ge $((artifact_count / 2)) ]]; then
        scope="test"
        message="test: update test results and coverage"
    elif [[ $logs_count -gt 0 ]]; then
        scope="workflow"
        message="chore(workflow): add execution logs and metrics"
    elif [[ $config_count -gt 0 ]]; then
        scope="config"
        message="chore(config): update workflow configuration"
    else
        scope="workflow"
        message="chore: update workflow artifacts"
    fi
    
    # Add details
    local details=""
    [[ $docs_count -gt 0 ]] && details+="- Documentation: $docs_count files"$'\n'
    [[ $tests_count -gt 0 ]] && details+="- Test results: $tests_count files"$'\n'
    [[ $logs_count -gt 0 ]] && details+="- Workflow logs: $logs_count files"$'\n'
    [[ $config_count -gt 0 ]] && details+="- Configuration: $config_count files"$'\n'
    
    # Add status indicator
    if [[ "$status" == "failure" ]]; then
        message+=" [workflow failed]"
    fi
    
    # Complete message
    cat << EOF
$message

Workflow artifacts generated:
$details
Total: $artifact_count files

Generated by: AI Workflow Automation v2.7.1
EOF
}

# ==============================================================================
# POST-WORKFLOW ACTIONS
# ==============================================================================

# Execute post-workflow automation
# Args: $1 = workflow_status (success/failure)
execute_post_workflow_actions() {
    local status="${1:-success}"
    
    if [[ "${GIT_AUTOMATION_ENABLED}" != "true" ]]; then
        print_info "Git automation disabled - skipping post-workflow actions"
        return 0
    fi
    
    print_header "Post-Workflow Git Automation"
    
    # Stage artifacts
    stage_workflow_artifacts "$status"
    
    # Check if auto-commit is enabled
    if [[ "${AUTO_COMMIT:-false}" == "true" ]]; then
        # Check if there are staged changes
        if git diff --cached --quiet; then
            print_info "No staged changes to commit"
            return 0
        fi
        
        # Generate commit message
        local commit_message=$(generate_artifact_commit_message "$status")
        
        if [[ "${DRY_RUN:-false}" == "true" ]]; then
            print_info "[DRY RUN] Would commit with message:"
            echo "$commit_message" | sed 's/^/  | /'
        else
            # Commit staged artifacts
            if git commit -m "$commit_message" 2>/dev/null; then
                print_success "✓ Auto-committed workflow artifacts"
                
                # Show commit hash
                local commit_hash=$(git rev-parse --short HEAD)
                print_info "Commit: $commit_hash"
            else
                print_warning "Could not commit artifacts (nothing to commit or error occurred)"
            fi
        fi
    else
        print_info "Auto-commit disabled - artifacts staged but not committed"
        print_info "Tip: Use --auto-commit flag to automatically commit artifacts"
    fi
}

# ==============================================================================
# CONFIGURATION HELPERS
# ==============================================================================

# Show current Git automation configuration
show_git_automation_config() {
    print_header "Git Automation Configuration"
    
    echo "Git Automation:"
    echo "  Enabled:           ${GIT_AUTOMATION_ENABLED}"
    echo "  Auto-stage:        ${AUTO_STAGE_ARTIFACTS}"
    echo "  Auto-commit:       ${AUTO_COMMIT:-false}"
    echo ""
    
    echo "Artifact Patterns (${#ARTIFACT_PATTERNS[@]} types):"
    for type in "${!ARTIFACT_PATTERNS[@]}"; do
        echo "  • $type: ${ARTIFACT_PATTERNS[$type]}"
    done
    echo ""
    
    echo "Exclude Patterns (${#EXCLUDE_PATTERNS[@]} types):"
    for type in "${!EXCLUDE_PATTERNS[@]}"; do
        echo "  • $type: ${EXCLUDE_PATTERNS[$type]}"
    done
}

# Enable Git automation
enable_git_automation() {
    export GIT_AUTOMATION_ENABLED=true
    export AUTO_STAGE_ARTIFACTS=true
    print_success "Git automation enabled"
}

# Disable Git automation
disable_git_automation() {
    export GIT_AUTOMATION_ENABLED=false
    export AUTO_STAGE_ARTIFACTS=false
    print_info "Git automation disabled"
}

# ==============================================================================
# INTEGRATION HOOKS
# ==============================================================================

# Hook for workflow start
on_workflow_start() {
    if [[ "${GIT_AUTOMATION_ENABLED}" == "true" ]]; then
        print_info "Git automation enabled - artifacts will be auto-staged on completion"
        
        if [[ "${AUTO_COMMIT:-false}" == "true" ]]; then
            print_info "Auto-commit enabled - artifacts will be committed automatically"
        fi
    fi
}

# Hook for workflow completion
on_workflow_complete() {
    local status="${1:-success}"
    execute_post_workflow_actions "$status"
}

# Hook for workflow failure
on_workflow_failure() {
    execute_post_workflow_actions "failure"
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f detect_workflow_artifacts
export -f categorize_artifacts
export -f stage_workflow_artifacts
export -f generate_artifact_commit_message
export -f execute_post_workflow_actions
export -f show_git_automation_config
export -f enable_git_automation
export -f disable_git_automation
export -f on_workflow_start
export -f on_workflow_complete
export -f on_workflow_failure

################################################################################
# End of Git Automation Module
################################################################################
