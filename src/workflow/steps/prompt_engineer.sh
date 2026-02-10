#!/bin/bash
################################################################################
# Step 14: Prompt Engineer Analysis
# Purpose: Analyze AI persona prompts and create GitHub issues for improvements
# Part of: Tests & Documentation Workflow Automation v3.0.7
# Version: 1.0.3
# Scope: Only runs on "bash-automation-framework" projects (ai_workflow)
################################################################################

# Module version information
readonly STEP14_VERSION="1.0.0"
readonly STEP14_VERSION_MAJOR=1
readonly STEP14_VERSION_MINOR=0
readonly STEP14_VERSION_PATCH=0

# ==============================================================================
# CLEANUP MANAGEMENT
# ==============================================================================

# Track temporary files for cleanup
declare -a STEP14_TEMP_FILES=()

# Register temp file for cleanup
track_step14_temp() {
    local temp_file="$1"
    [[ -n "$temp_file" ]] && STEP14_TEMP_FILES+=("$temp_file")
}

# Cleanup handler for step 14
cleanup_step14_files() {
    local file
    for file in "${STEP14_TEMP_FILES[@]}"; do
        [[ -f "$file" ]] && rm -f "$file" 2>/dev/null
    done
    STEP14_TEMP_FILES=()
}

# Configuration file path
readonly AI_HELPERS_YAML="${SCRIPT_DIR}/../../../.workflow_core/config/ai_helpers.yaml"

# Check if this step should run based on project type
# Returns: 0 if should run, 1 if should skip
should_run_prompt_engineer_step() {
    local project_type=""
    
    # Check .workflow-config.yaml for project type
    if [[ -f "${PROJECT_ROOT}/.workflow-config.yaml" ]]; then
        project_type=$(grep "type:" "${PROJECT_ROOT}/.workflow-config.yaml" | sed 's/^[[:space:]]*type:[[:space:]]*"\?\([^"]*\)"\?/\1/')
    fi
    
    # Only run on bash-automation-framework projects (ai_workflow itself)
    if [[ "$project_type" == "bash-automation-framework" ]]; then
        print_info "Project type: bash-automation-framework - prompt engineering analysis enabled"
        return 0
    else
        print_info "Project type: ${project_type:-unknown} - prompt engineering analysis skipped"
        print_info "This step only runs on ai_workflow_shell_automation projects"
        return 1
    fi
}

# Extract all persona names from ai_helpers.yaml
# Returns: Space-separated list of persona names
get_persona_names() {
    local yaml_file="$1"
    
    if [[ ! -f "$yaml_file" ]]; then
        print_error "AI helpers configuration not found: $yaml_file"
        return 1
    fi
    
    # Extract persona prompt section names (e.g., doc_analysis_prompt, step2_consistency_prompt)
    grep -oP '^[a-z0-9_]+_prompt:' "$yaml_file" | sed 's/:$//' | tr '\n' ' '
}

# Count total personas in configuration
# Returns: Number of personas
count_personas() {
    local yaml_file="$1"
    grep -c '^[a-z0-9_]*_prompt:' "$yaml_file" 2>/dev/null || echo "0"
}

# Extract full prompt content for AI analysis
# Returns: Complete prompt content formatted for analysis
extract_prompts_content() {
    local yaml_file="$1"
    
    if [[ ! -f "$yaml_file" ]]; then
        print_error "Configuration file not found: $yaml_file"
        return 1
    fi
    
    # Return entire file content for comprehensive analysis
    cat "$yaml_file"
}

# Build AI prompt for prompt engineering analysis
# Returns: Formatted prompt string
build_prompt_engineer_analysis_prompt() {
    local personas_list="$1"
    local persona_count="$2"
    local prompts_content="$3"
    
    local yaml_file="$AI_HELPERS_YAML"
    
    # Read from YAML config
    if [[ ! -f "$yaml_file" ]]; then
        print_error "AI helpers configuration not found: $yaml_file"
        return 1
    fi
    
    # Extract role (multiline YAML block scalar format with 2-space indent)
    local role=$(awk '
        /^step14_prompt_engineer_prompt:$/ { in_section=1; next }
        in_section && /^[a-z]/ { exit }
        in_section && /^[[:space:]]{2}role:[[:space:]]*\|/ { in_role=1; next }
        in_section && in_role {
            # Stop at next field (at same or lower indent level)
            if ($0 ~ /^[[:space:]]{0,2}[a-z_]+:/) { in_role=0; next }
            # Capture content (remove 4-space indent from content lines)
            if ($0 ~ /^[[:space:]]{4}/) {
                sub(/^[[:space:]]{4}/, "")
                print
            }
        }
    ' "$yaml_file")
    
    # Extract task template (multiline YAML block scalar format with 2-space indent)
    local task_template=$(awk '
        /^step14_prompt_engineer_prompt:$/ { in_section=1; next }
        in_section && /^[a-z]/ { exit }
        in_section && /^[[:space:]]{2}task_template:[[:space:]]*\|/ { in_task=1; next }
        in_section && in_task {
            # Stop at next field (at same or lower indent level)
            if ($0 ~ /^[[:space:]]{0,2}[a-z_]+:/) { in_task=0; next }
            # Capture content (remove 4-space indent from content lines)
            if ($0 ~ /^[[:space:]]{4}/) {
                sub(/^[[:space:]]{4}/, "")
                print
            }
        }
    ' "$yaml_file")
    
    # Substitute variables in task template
    task_template=$(echo "$task_template" | sed "s/{persona_count}/${persona_count}/g")
    task_template=$(echo "$task_template" | sed "s|{personas_list}|${personas_list}|g")
    
    # Note: prompts_content is appended at the end of the prompt (after approach section)
    # to avoid sed issues with large YAML content containing special characters
    
    # Extract approach (multiline YAML block scalar format with 2-space indent)
    local approach=$(awk '
        /^step14_prompt_engineer_prompt:$/ { in_section=1; next }
        in_section && /^[a-z]/ { exit }
        in_section && /^[[:space:]]{2}approach:[[:space:]]*\|/ { in_approach=1; next }
        in_section && in_approach {
            # Stop at next field (at same or lower indent level) or next persona
            if ($0 ~ /^[[:space:]]{0,2}[a-z_]+:/) { in_approach=0; next }
            # Capture content (remove 4-space indent from content lines)
            if ($0 ~ /^[[:space:]]{4}/) {
                sub(/^[[:space:]]{4}/, "")
                print
            }
        }
    ' "$yaml_file")
    
    # Build complete prompt
    cat << EOF
**Role**: ${role}

**Task**: ${task_template}

**Approach**: ${approach}

**Prompt Content to Analyze:**
\`\`\`yaml
${prompts_content}
\`\`\`
EOF
}

# Parse AI response to extract improvement opportunities
# Usage: parse_improvement_opportunities <ai_output_file>
# Returns: 0 if opportunities found, 1 otherwise
parse_improvement_opportunities() {
    local ai_output="$1"
    local opportunities_file="$2"
    
    if [[ ! -f "$ai_output" ]]; then
        print_error "AI output file not found: $ai_output"
        return 1
    fi
    
    # Extract improvement opportunities from markdown format
    # Look for sections starting with "## Improvement Opportunity"
    local improvement_count=0
    local current_opportunity=""
    local in_opportunity=false
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^##[[:space:]]*Improvement[[:space:]]Opportunity ]]; then
            # Save previous opportunity if exists
            if [[ -n "$current_opportunity" ]]; then
                echo "$current_opportunity" >> "$opportunities_file"
                echo "---" >> "$opportunities_file"
                ((improvement_count++))
            fi
            # Start new opportunity
            current_opportunity="$line"$'\n'
            in_opportunity=true
        elif [[ "$in_opportunity" == true ]]; then
            # Check if we've reached the next section or end
            if [[ "$line" =~ ^#[[:space:]] ]] && [[ ! "$line" =~ ^###[[:space:]] ]]; then
                # Save current and exit opportunity mode
                if [[ -n "$current_opportunity" ]]; then
                    echo "$current_opportunity" >> "$opportunities_file"
                    echo "---" >> "$opportunities_file"
                    ((improvement_count++))
                fi
                current_opportunity=""
                in_opportunity=false
            else
                # Accumulate opportunity content
                current_opportunity+="$line"$'\n'
            fi
        fi
    done < "$ai_output"
    
    # Save last opportunity if exists
    if [[ -n "$current_opportunity" ]]; then
        echo "$current_opportunity" >> "$opportunities_file"
        ((improvement_count++))
    fi
    
    print_info "Parsed $improvement_count improvement opportunities"
    return $improvement_count
}

# Create GitHub issue for an improvement opportunity
# Usage: create_github_issue <opportunity_text> <issue_number>
# Returns: 0 for success, 1 for failure
create_github_issue() {
    local opportunity_text="$1"
    local issue_num="$2"
    
    # Extract key information from opportunity text
    local persona_name=$(echo "$opportunity_text" | grep -oP '^\*\*Persona\*\*:[[:space:]]*\K.*' | head -1)
    local category=$(echo "$opportunity_text" | grep -oP '^\*\*Category\*\*:[[:space:]]*\K.*' | head -1)
    local severity=$(echo "$opportunity_text" | grep -oP '^\*\*Severity\*\*:[[:space:]]*\K.*' | head -1)
    
    # Build issue title
    local issue_title="[Prompt Engineering] Improve ${persona_name} persona - ${category}"
    
    # Build issue body
    local issue_body="## Prompt Engineering Improvement Opportunity

**Generated by**: Workflow Step 13 - Prompt Engineer Analysis
**Analysis Date**: $(date '+%Y-%m-%d')
**Configuration File**: \`.workflow_core/config/ai_helpers.yaml\`

---

${opportunity_text}

---

## Implementation Checklist

- [ ] Review the recommendation
- [ ] Update \`.workflow_core/config/ai_helpers.yaml\`
- [ ] Test the improved prompt with relevant workflow step
- [ ] Validate output quality improvement
- [ ] Update documentation if needed

## Labels

\`prompt-engineering\` \`ai-optimization\` \`severity:${severity,,}\` \`${category,,}\`
"
    
    # Check if gh CLI is available
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) not found - cannot create issue"
        print_info "Install from: https://cli.github.com/"
        print_info "Issue would be: $issue_title"
        echo "$issue_body" > "${BACKLOG_RUN_DIR}/issue_${issue_num}.md"
        print_info "Issue content saved to: ${BACKLOG_RUN_DIR}/issue_${issue_num}.md"
        return 1
    fi
    
    # Check if gh is authenticated
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI not authenticated - cannot create issue"
        print_info "Authenticate with: gh auth login"
        print_info "Issue would be: $issue_title"
        echo "$issue_body" > "${BACKLOG_RUN_DIR}/issue_${issue_num}.md"
        print_info "Issue content saved to: ${BACKLOG_RUN_DIR}/issue_${issue_num}.md"
        return 1
    fi
    
    # Create the issue
    print_info "Creating GitHub issue: $issue_title"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would create issue:"
        print_info "  Title: $issue_title"
        print_info "  Labels: prompt-engineering, ai-optimization, severity:${severity,,}"
        echo "$issue_body" > "${BACKLOG_RUN_DIR}/issue_${issue_num}_dryrun.md"
        print_info "  Body saved to: ${BACKLOG_RUN_DIR}/issue_${issue_num}_dryrun.md"
        return 0
    fi
    
    # Create issue with gh CLI
    local issue_url=""
    if issue_url=$(gh issue create \
        --title "$issue_title" \
        --body "$issue_body" \
        --label "prompt-engineering,ai-optimization,severity:${severity,,}" 2>&1); then
        print_success "✅ Created GitHub issue: $issue_url"
        echo "$issue_url" >> "${BACKLOG_RUN_DIR}/created_issues.txt"
        return 0
    else
        print_error "Failed to create GitHub issue: $issue_url"
        echo "$issue_body" > "${BACKLOG_RUN_DIR}/issue_${issue_num}_failed.md"
        print_info "Issue content saved to: ${BACKLOG_RUN_DIR}/issue_${issue_num}_failed.md"
        return 1
    fi
}

# Main step function - analyzes AI prompts and creates improvement issues
# Returns: 0 for success, 1 for failure
step14_prompt_engineer_analysis() {
    print_step "13" "Prompt Engineer Analysis"
    
    cd "$PROJECT_ROOT" || return 1
    
    # Check if this step should run for this project type
    if ! should_run_prompt_engineer_step; then
        print_info "Skipping prompt engineer analysis for this project type"
        save_step_summary "13" "Prompt_Engineer_Analysis" \
            "Skipped - only runs on bash-automation-framework projects" "⏭️"
        update_workflow_status "step14" "⏭️ SKIP"
        return 0
    fi
    
    # Verify AI helpers configuration exists
    if [[ ! -f "$AI_HELPERS_YAML" ]]; then
        print_error "AI helpers configuration not found: $AI_HELPERS_YAML"
        save_step_summary "13" "Prompt_Engineer_Analysis" \
            "Failed - configuration file not found" "❌"
        update_workflow_status "step14" "❌ FAIL"
        return 1
    fi
    
    print_info "Analyzing AI persona prompts in: $AI_HELPERS_YAML"
    
    # PHASE 1: Extract and analyze personas
    print_info "Phase 1: Extracting persona information..."
    
    local persona_count=$(count_personas "$AI_HELPERS_YAML")
    print_info "Found $persona_count AI personas to analyze"
    
    local personas_list=$(get_persona_names "$AI_HELPERS_YAML")
    print_info "Personas: $personas_list"
    
    # Extract complete prompt content
    local prompts_content=$(extract_prompts_content "$AI_HELPERS_YAML")
    
    # PHASE 2: AI-powered analysis
    print_info ""
    print_info "Phase 2: AI-powered prompt quality analysis..."
    
    # Check if Copilot CLI is available
    if ! validate_copilot_cli; then
        print_warning "GitHub Copilot CLI not available - skipping AI analysis"
        save_step_summary "13" "Prompt_Engineer_Analysis" \
            "Skipped - Copilot CLI not available" "⚠️"
        update_workflow_status "step14" "⚠️ SKIP"
        return 0
    fi
    
    # Build AI prompt
    local ai_prompt=$(build_prompt_engineer_analysis_prompt "$personas_list" "$persona_count" "$prompts_content")
    
    # Create temporary files
    local ai_output=$(mktemp)
    local opportunities_file=$(mktemp)
    track_step14_temp "$ai_output"
    track_step14_temp "$opportunities_file"
    
    # Execute AI analysis
    print_info "Executing AI analysis..."
    local log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
    local log_file="${LOGS_RUN_DIR}/step14_prompt_analysis_${log_timestamp}.log"
    
    if [[ "$INTERACTIVE_MODE" == true ]] && [[ "$AUTO_MODE" == false ]]; then
        print_info "Invoking GitHub Copilot CLI for interactive analysis..."
        execute_copilot_prompt "$ai_prompt" "$log_file" "step14" "prompt_engineer"
        
        # Copy log output to ai_output for parsing
        cp "$log_file" "$ai_output"
        print_success "AI analysis completed"
    else
        print_info "Auto mode or non-interactive - generating analysis report..."
        echo "$ai_prompt" > "$ai_output"
        print_info "Prompt saved for manual review: $ai_output"
    fi
    
    # PHASE 3: Parse improvement opportunities
    print_info ""
    print_info "Phase 3: Parsing improvement opportunities..."
    
    local opportunity_count=0
    parse_improvement_opportunities "$ai_output" "$opportunities_file"
    opportunity_count=$?
    
    if [[ $opportunity_count -eq 0 ]]; then
        print_success "No improvement opportunities identified - all prompts are well-designed!"
        save_step_summary "13" "Prompt_Engineer_Analysis" \
            "Analyzed $persona_count personas - no improvements needed" "✅"
        
        local step_issues="### Prompt Engineering Analysis

**Personas Analyzed:** $persona_count
**Improvement Opportunities:** 0
**Status:** ✅ All prompts are well-designed

All AI persona prompts meet quality standards. No issues to create.
"
        save_step_issues "13" "Prompt_Engineer_Analysis" "$step_issues"
        update_workflow_status "step14" "✅"
        return 0
    fi
    
    print_info "Found $opportunity_count improvement opportunities"
    
    # PHASE 4: Create GitHub issues for each opportunity
    print_info ""
    print_info "Phase 4: Creating GitHub issues for improvements..."
    
    local issues_created=0
    local issues_failed=0
    local issue_num=1
    
    # Split opportunities and create issues
    local current_opportunity=""
    while IFS= read -r line; do
        if [[ "$line" == "---" ]]; then
            # Process accumulated opportunity
            if [[ -n "$current_opportunity" ]]; then
                if create_github_issue "$current_opportunity" "$issue_num"; then
                    ((issues_created++))
                else
                    ((issues_failed++))
                fi
                ((issue_num++))
                current_opportunity=""
            fi
        else
            current_opportunity+="$line"$'\n'
        fi
    done < "$opportunities_file"
    
    # Process last opportunity if exists
    if [[ -n "$current_opportunity" ]]; then
        if create_github_issue "$current_opportunity" "$issue_num"; then
            ((issues_created++))
        else
            ((issues_failed++))
        fi
    fi
    
    # PHASE 5: Generate summary
    print_info ""
    print_info "Phase 5: Generating summary..."
    
    local summary_text="Analyzed $persona_count AI personas. Created $issues_created GitHub issues for prompt improvements."
    local status_icon="✅"
    
    if [[ $issues_failed -gt 0 ]]; then
        summary_text+=" ($issues_failed failed)"
        status_icon="⚠️"
    fi
    
    save_step_summary "13" "Prompt_Engineer_Analysis" "$summary_text" "$status_icon"
    
    # Save detailed backlog
    local step_backlog="### Prompt Engineering Analysis Summary

**Personas Analyzed:** $persona_count
**Improvement Opportunities Found:** $opportunity_count
**GitHub Issues Created:** $issues_created
**Failed Issue Creation:** $issues_failed
**Status:** $status_icon Complete

### Personas Analyzed

$personas_list

### Created Issues

"
    if [[ -f "${BACKLOG_RUN_DIR}/created_issues.txt" ]]; then
        while IFS= read -r issue_url; do
            step_backlog+="- $issue_url"$'\n'
        done < "${BACKLOG_RUN_DIR}/created_issues.txt"
    else
        step_backlog+="No issues created (see logs for details)"$'\n'
    fi
    
    step_backlog+="

### Analysis Details

Full AI analysis saved to: \`$log_file\`
Parsed opportunities saved to: \`$opportunities_file\`
"
    
    save_step_issues "13" "Prompt_Engineer_Analysis" "$step_backlog"
    
    # Update workflow status
    if [[ $issues_failed -eq 0 ]]; then
        update_workflow_status "step14" "✅"
        print_success "Prompt engineering analysis complete - created $issues_created issues"
    else
        update_workflow_status "step14" "⚠️"
        print_warning "Prompt engineering analysis complete with warnings"
    fi
    
    prompt_for_continuation
}

# Export cleanup functions
export -f track_step14_temp
export -f cleanup_step14_files

# Export step function
export -f step14_prompt_engineer_analysis
export -f should_run_prompt_engineer_step
export -f get_persona_names
export -f count_personas
export -f extract_prompts_content
export -f build_prompt_engineer_analysis_prompt
export -f parse_improvement_opportunities
export -f create_github_issue

# ==============================================================================
# CLEANUP TRAP
# ==============================================================================

# Ensure cleanup runs on exit
trap cleanup_step14_files EXIT INT TERM
