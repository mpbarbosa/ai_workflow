#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 2 AI Integration Module
# Purpose: AI prompt building and Copilot CLI integration for consistency analysis
# Part of: Step 2 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.0
################################################################################

# ==============================================================================
# PROMPT BUILDING
# ==============================================================================

# Filter broken references to remove false positives
# Usage: filter_broken_refs_step2 <broken_refs>
# Returns: Filtered broken references
filter_broken_refs_step2() {
    local broken_refs="$1"
    
    # Skip if no broken refs
    if [[ -z "$broken_refs" ]] || [[ "$broken_refs" == "No broken references detected" ]]; then
        echo "No broken references detected"
        return 0
    fi
    
    # Filter out regex patterns (sed/awk patterns that look like paths)
    # These typically contain: /^, /[, /, "", and other regex syntax
    local filtered=""
    while IFS= read -r line; do
        # Skip empty lines
        [[ -z "$line" ]] && continue
        
        # Skip lines containing regex patterns
        if echo "$line" | grep -qE '(\^|\[[:space:\]\]|/".*/"|yaml-parsing)'; then
            continue
        fi
        # Keep actual broken file references
        filtered+="$line"$'\n'
    done <<< "$broken_refs"
    
    # Return filtered results or default message
    if [[ -n "$filtered" ]]; then
        echo -n "$filtered"
    else
        echo "No broken references detected (false positives filtered)"
    fi
}

# Categorize documentation files by purpose
# Usage: categorize_docs_step2 <doc_files>
# Returns: Categorized documentation list
categorize_docs_step2() {
    local doc_files="$1"
    local categorized=""
    
    # Critical documentation (always review first)
    categorized+="**Critical Documentation (Priority 1):**\n"
    local critical_docs
    critical_docs=$(echo "$doc_files" | grep -E '^\./README\.md$|^\.github/copilot-instructions\.md$|^\./docs/PROJECT_REFERENCE\.md$' || true)
    if [[ -n "$critical_docs" ]]; then
        categorized+="$critical_docs\n"
    else
        categorized+="(none found)\n"
    fi
    categorized+="\n"
    
    # User-facing documentation
    categorized+="**User Documentation (Priority 2):**\n"
    local user_docs
    user_docs=$(echo "$doc_files" | grep -E 'docs/user-guide/|docs/reference/|CONTRIBUTING|CODE_OF_CONDUCT' || true)
    if [[ -n "$user_docs" ]]; then
        categorized+="$user_docs\n"
    else
        categorized+="(none found)\n"
    fi
    categorized+="\n"
    
    # Developer documentation
    categorized+="**Developer Documentation (Priority 3):**\n"
    local dev_docs
    dev_docs=$(echo "$doc_files" | grep -E 'docs/developer-guide/|docs/design/|src/.*/README\.md' || true)
    if [[ -n "$dev_docs" ]]; then
        categorized+="$dev_docs\n"
    else
        categorized+="(none found)\n"
    fi
    categorized+="\n"
    
    # Archive (lowest priority)
    categorized+="**Archive Documentation (Priority 4 - Review only if relevant):**\n"
    local archive_docs
    archive_docs=$(echo "$doc_files" | grep 'docs/archive/' || true)
    if [[ -n "$archive_docs" ]]; then
        local archive_count
        archive_count=$(echo "$archive_docs" | wc -l)
        categorized+="($archive_count files in archive - review only if explicitly referenced)\n"
    else
        categorized+="(none found)\n"
    fi
    
    echo -e "$categorized"
}

# Build Step 2 consistency analysis prompt with enhanced context
# Usage: build_consistency_prompt_step2 <doc_count> <change_scope> <modified_files> <broken_refs> <doc_files>
# Returns: Complete AI prompt
build_consistency_prompt_step2() {
    local doc_count="$1"
    local change_scope="${2:-unknown}"
    local modified_files="${3:-none}"
    local broken_refs="${4:-No broken references detected}"
    local doc_files="${5:-}"
    
    # Get tech stack info if available
    local project_kind="${PROJECT_KIND:-shell_automation}"
    local primary_language="${PRIMARY_LANGUAGE:-bash}"
    local project_name="${PROJECT_NAME:-this project}"
    
    local prompt=""
    
    # Header with project context
    prompt="## Documentation Consistency Analysis Request\n\n"
    prompt+="Analyze documentation consistency for **${project_name}**, a ${project_kind} project written in ${primary_language}.\n\n"
    
    # Project context with tech stack
    prompt+="### Project Context\n"
    prompt+="- **Project Type**: ${project_kind}\n"
    prompt+="- **Primary Language**: ${primary_language}\n"
    prompt+="- **Total Documentation Files**: ${doc_count}\n"
    prompt+="- **Change Scope**: ${change_scope}\n"
    prompt+="- **Modified Files Count**: ${modified_files}\n\n"
    
    # Filter broken references to remove false positives
    local filtered_refs
    filtered_refs=$(filter_broken_refs_step2 "$broken_refs")
    
    # Automated checks results
    prompt+="### Automated Checks Results\n\n"
    prompt+="**Broken References Found:**\n"
    if [[ "$filtered_refs" == *"No broken references"* ]]; then
        prompt+="✓ No broken file references detected\n\n"
    else
        prompt+="$filtered_refs\n"
        prompt+="**Action Required**: Verify these references exist or update documentation to correct paths.\n\n"
    fi
    
    # Categorized documentation inventory
    if [[ -n "$doc_files" ]]; then
        prompt+="### Documentation Inventory\n\n"
        prompt+=$(categorize_docs_step2 "$doc_files")
        prompt+="\n"
    fi
    
    # Analysis instructions with clear priorities
    prompt+="### Analysis Instructions\n\n"
    prompt+="Perform a comprehensive documentation consistency analysis focusing on:\n\n"
    
    prompt+="#### 1. Consistency Issues (High Priority)\n"
    prompt+="   - **Cross-references**: Verify all internal links point to existing files/sections\n"
    prompt+="   - **Terminology**: Ensure consistent naming (e.g., 'workflow step' vs 'pipeline stage')\n"
    prompt+="   - **Version numbers**: Check alignment across README, changelogs, and source files\n"
    prompt+="   - **Format patterns**: Verify headings, code blocks, and lists follow project standards\n\n"
    
    prompt+="#### 2. Completeness Gaps (Medium Priority)\n"
    prompt+="   - **New features**: Check if recent code changes have corresponding documentation\n"
    prompt+="   - **API documentation**: Verify all public functions/modules are documented\n"
    prompt+="   - **Examples**: Ensure code examples exist for key features\n"
    prompt+="   - **Prerequisites**: Verify setup/installation instructions are complete\n\n"
    
    prompt+="#### 3. Accuracy Verification (High Priority)\n"
    prompt+="   - **Code alignment**: Documentation examples match actual implementation\n"
    prompt+="   - **Version accuracy**: Current version matches across all files\n"
    prompt+="   - **Feature status**: Documented features actually exist in codebase\n"
    prompt+="   - **Deprecated content**: Identify outdated information requiring updates\n\n"
    
    prompt+="#### 4. Quality & Usability (Low Priority)\n"
    prompt+="   - **Clarity**: Identify unclear or ambiguous documentation\n"
    prompt+="   - **Structure**: Suggest organizational improvements\n"
    prompt+="   - **Navigation**: Recommend better cross-linking between related docs\n"
    prompt+="   - **Accessibility**: Check for proper heading hierarchy and alt text\n\n"
    
    # Output format requirements
    prompt+="### Output Requirements\n\n"
    prompt+="Provide a structured analysis report with:\n"
    prompt+="1. **Executive Summary**: High-level findings (2-3 sentences)\n"
    prompt+="2. **Critical Issues**: Must-fix problems (broken refs, version mismatches)\n"
    prompt+="3. **High Priority Recommendations**: Important improvements (missing docs, outdated examples)\n"
    prompt+="4. **Medium Priority Suggestions**: Nice-to-have enhancements (clarity, structure)\n"
    prompt+="5. **Low Priority Notes**: Optional improvements (formatting, style)\n\n"
    
    prompt+="For each issue, include:\n"
    prompt+="- File path and line number (if applicable)\n"
    prompt+="- Clear description of the problem\n"
    prompt+="- Specific recommended fix or action\n"
    prompt+="- Priority level (Critical/High/Medium/Low)\n\n"
    
    prompt+="**Focus Areas Based on Change Scope**: ${change_scope}\n"
    if [[ "$change_scope" == *"documentation"* ]]; then
        prompt+="- Prioritize documentation-related consistency checks\n"
        prompt+="- Verify cross-references between updated docs\n"
    elif [[ "$change_scope" == *"code"* ]]; then
        prompt+="- Focus on code-documentation alignment\n"
        prompt+="- Check if API docs match new implementations\n"
    else
        prompt+="- Perform comprehensive analysis across all categories\n"
    fi
    
    echo -e "$prompt"
}

# Enhance prompt with language-specific conventions
# Usage: enhance_consistency_prompt_with_language_step2 <base_prompt> <language>
# Returns: Enhanced prompt
enhance_consistency_prompt_with_language_step2() {
    local base_prompt="$1"
    local language="${2:-bash}"
    local enhanced="$base_prompt"
    
    # Apply language-specific documentation conventions if available
    if command -v should_use_language_aware_prompts &>/dev/null; then
        if should_use_language_aware_prompts; then
            if command -v get_language_documentation_conventions &>/dev/null; then
                local lang_conventions
                lang_conventions=$(get_language_documentation_conventions "$language")
                
                if [[ -n "$lang_conventions" ]] && [[ "$lang_conventions" != "No language specified" ]]; then
                    enhanced+="\n\n**${language^} Documentation Standards:**\n"
                    enhanced+="$lang_conventions\n"
                    # Language-aware enhancements applied silently
                fi
            fi
        fi
    fi
    
    echo -e "$enhanced"
}

# ==============================================================================
# AI EXECUTION
# ==============================================================================

# Execute Copilot CLI for consistency analysis
# Usage: execute_consistency_analysis_step2 <prompt> <log_file>
# Returns: 0 on success, 1 on failure
execute_consistency_analysis_step2() {
    local prompt="$1"
    local log_file="$2"
    
    # Display prompt
    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Consistency Analysis Prompt:${NC}"
    echo -e "${YELLOW}${prompt}${NC}\n"
    
    # Check if in dry run mode
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        print_info "[DRY RUN] Would invoke: copilot with consistency analysis prompt"
        return 0
    fi
    
    # Confirm execution
    if ! confirm_action "Run GitHub Copilot CLI to analyze documentation consistency?" "y"; then
        print_warning "Skipped GitHub Copilot CLI - using manual review"
        return 1
    fi
    
    # Save prompt to temporary file
    local temp_prompt_file
    temp_prompt_file=$(mktemp)
    TEMP_FILES+=("$temp_prompt_file")
    echo "$prompt" > "$temp_prompt_file"
    
    # Execute Copilot CLI
    print_info "Starting Copilot CLI session..."
    print_info "Logging output to: $log_file"
    
    # Call execute_copilot_prompt if available, otherwise fallback
    if command -v execute_copilot_prompt &>/dev/null; then
        execute_copilot_prompt "$prompt" "$log_file" "step02" "documentation_specialist"
    else
        # Fallback execution with comprehensive flags
        copilot -p "$prompt" --allow-all-tools --allow-all-paths --enable-all-github-mcp-tools 2>&1 | tee "$log_file"
    fi
    
    print_success "GitHub Copilot CLI session completed"
    print_info "Full session log saved to: $log_file"
    
    return 0
}

# Extract and save issues from Copilot log
# Usage: process_copilot_results_step2 <log_file>
# Returns: 0 on success
process_copilot_results_step2() {
    local log_file="$1"
    
    if [[ ! -f "$log_file" ]]; then
        print_warning "Log file not found: $log_file"
        return 1
    fi
    
    # Use library function if available
    if command -v extract_and_save_issues_from_log &>/dev/null; then
        extract_and_save_issues_from_log "2" "Consistency_Analysis" "$log_file"
    else
        print_info "Issues extraction skipped - library function not available"
    fi
    
    return 0
}

# ==============================================================================
# HIGH-LEVEL WORKFLOW
# ==============================================================================

# Run complete AI consistency analysis workflow
# Usage: run_ai_consistency_workflow_step2 <doc_count> <broken_refs> <doc_files>
# Returns: 0 on success, 1 if skipped
run_ai_consistency_workflow_step2() {
    local doc_count="$1"
    local broken_refs="$2"
    local doc_files="$3"
    
    # Build prompt
    local prompt
    prompt=$(build_consistency_prompt_step2 \
        "$doc_count" \
        "${CHANGE_SCOPE:-unknown}" \
        "${ANALYSIS_MODIFIED:-none}" \
        "$broken_refs" \
        "$doc_files")
    
    # Enhance with language-specific conventions if available
    prompt=$(enhance_consistency_prompt_with_language_step2 "$prompt" "${PRIMARY_LANGUAGE:-bash}")
    
    # Create log file
    local log_timestamp
    log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
    local log_file="${LOGS_RUN_DIR:-./logs}/step2_copilot_consistency_analysis_${log_timestamp}.log"
    
    # Execute analysis
    if ! execute_consistency_analysis_step2 "$prompt" "$log_file"; then
        return 1
    fi
    
    # Process results
    process_copilot_results_step2 "$log_file"
    
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f filter_broken_refs_step2
export -f categorize_docs_step2
export -f build_consistency_prompt_step2
export -f enhance_consistency_prompt_with_language_step2
export -f execute_consistency_analysis_step2
export -f process_copilot_results_step2
export -f run_ai_consistency_workflow_step2
