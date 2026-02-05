#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Batch AI Commit Message Generation Library
# Purpose: Generate AI-powered commit messages in non-interactive mode
# Version: 1.0.1 (v2.7.0-alpha)
# Created: 2025-12-31
################################################################################

# Module version
readonly BATCH_AI_COMMIT_VERSION="1.0.1"

################################################################################
# CONFIGURATION
################################################################################

# Default timeout for AI generation (seconds)
readonly AI_GENERATION_TIMEOUT=${AI_GENERATION_TIMEOUT:-30}

# Maximum diff lines to include in prompt
readonly MAX_DIFF_LINES=${MAX_DIFF_LINES:-200}

# Maximum files to list in context
readonly MAX_FILES_LIST=${MAX_FILES_LIST:-50}

################################################################################
# GIT CONTEXT ASSEMBLY
################################################################################

# Assemble comprehensive git context for AI commit message generation
# Returns: Context string suitable for AI prompt
# Usage: context=$(assemble_git_context_for_ai)
assemble_git_context_for_ai() {
    local context=""
    
    # Get repository name (from remote or directory name)
    local repo_name
    repo_name=$(basename "$(git rev-parse --show-toplevel)" 2>/dev/null || echo "repository")
    
    # Get current branch
    local branch
    branch=$(get_git_current_branch 2>/dev/null || echo "unknown")
    
    # Get commit statistics
    local commits_ahead
    commits_ahead=$(get_git_commits_ahead 2>/dev/null || echo "0")
    
    local commits_behind
    commits_behind=$(get_git_commits_behind 2>/dev/null || echo "0")
    
    # Get change counts
    local modified_count
    modified_count=$(get_git_modified_count 2>/dev/null || echo "0")
    
    local staged_count
    staged_count=$(get_git_staged_count 2>/dev/null || echo "0")
    
    local untracked_count
    untracked_count=$(get_git_untracked_count 2>/dev/null || echo "0")
    
    local deleted_count
    deleted_count=$(get_git_deleted_count 2>/dev/null || echo "0")
    
    local total_changes
    total_changes=$(get_git_total_changes 2>/dev/null || echo "0")
    
    # Categorize files
    local docs_modified
    docs_modified=$(get_git_docs_modified 2>/dev/null || echo "0")
    
    local tests_modified
    tests_modified=$(get_git_tests_modified 2>/dev/null || echo "0")
    
    local scripts_modified
    scripts_modified=$(get_git_scripts_modified 2>/dev/null || echo "0")
    
    local code_modified
    code_modified=$(get_git_code_modified 2>/dev/null || echo "0")
    
    # Infer commit type and scope
    local commit_type="chore"
    local commit_scope="updates"
    
    if [[ $code_modified -gt 0 ]] && [[ $tests_modified -gt 0 ]]; then
        commit_type="feat"
        commit_scope="implementation+tests"
    elif [[ $code_modified -gt 0 ]]; then
        commit_type="feat"
        commit_scope="implementation"
    elif [[ $tests_modified -gt 0 ]]; then
        commit_type="test"
        commit_scope="testing"
    elif [[ $docs_modified -gt 0 ]]; then
        commit_type="docs"
        commit_scope="documentation"
    elif [[ $scripts_modified -gt 0 ]]; then
        commit_type="chore"
        commit_scope="automation"
    fi
    
    # Get diff statistics
    local diff_stats
    diff_stats=$(git diff --stat HEAD 2>/dev/null | tail -1 || echo "No diff available")
    
    # Get changed files list (limited)
    local changed_files
    changed_files=$(git status --short 2>/dev/null | head -${MAX_FILES_LIST} || echo "")
    
    # Get diff sample (limited lines)
    local diff_sample
    diff_sample=$(git diff --unified=3 HEAD 2>/dev/null | head -${MAX_DIFF_LINES} || echo "")
    
    # Assemble context
    context="Repository: ${repo_name}
Branch: ${branch}
Commits: ahead ${commits_ahead}, behind ${commits_behind}

Change Summary:
- Total changes: ${total_changes} files
- Modified: ${modified_count}
- Staged: ${staged_count}
- Untracked: ${untracked_count}
- Deleted: ${deleted_count}

File Categories:
- Documentation: ${docs_modified} files
- Tests: ${tests_modified} files
- Scripts: ${scripts_modified} files
- Code: ${code_modified} files

Inferred Type: ${commit_type}(${commit_scope})

Diff Statistics:
${diff_stats}

Changed Files (top ${MAX_FILES_LIST}):
${changed_files}

Diff Sample (first ${MAX_DIFF_LINES} lines):
${diff_sample}"
    
    echo "$context"
}

################################################################################
# AI PROMPT CONSTRUCTION
################################################################################

# Build AI prompt for commit message generation
# Args: $1 - git context
# Returns: Formatted prompt for Copilot CLI
build_batch_commit_prompt() {
    local git_context="$1"
    
    local prompt="You are an expert Git workflow specialist. Generate a professional conventional commit message for the following changes.

${git_context}

REQUIREMENTS:
1. Follow Conventional Commits specification strictly
2. Format: <type>(<scope>): <subject>
3. Subject line maximum 72 characters
4. Include detailed body with:
   - What changed and why (not how)
   - Key changes as bullet points
   - Reference affected files/modules
5. Use present tense (\"add\" not \"added\")
6. Be specific and descriptive
7. Focus on user-facing changes and business value

COMMIT MESSAGE STRUCTURE:
<type>(<scope>): <clear, descriptive subject line>

<detailed body paragraph explaining what and why>

Key Changes:
- <important change 1>
- <important change 2>
- <important change 3>

Affected: <list key files or modules>

Generate ONLY the commit message, no additional commentary."
    
    echo "$prompt"
}

################################################################################
# AI INVOCATION (NON-INTERACTIVE)
################################################################################

# Generate commit message using AI in non-interactive mode
# Returns: 0 on success with message in stdout, 1 on failure
# Usage: ai_message=$(generate_ai_commit_message_batch)
generate_ai_commit_message_batch() {
    # Check if Copilot CLI is available
    if ! command -v copilot &> /dev/null; then
        echo "ERROR: Copilot CLI not available" >&2
        return 1
    fi
    
    # Assemble git context
    local git_context
    git_context=$(assemble_git_context_for_ai)
    
    if [[ -z "$git_context" ]]; then
        echo "ERROR: Failed to assemble git context" >&2
        return 1
    fi
    
    # Build prompt
    local prompt
    prompt=$(build_batch_commit_prompt "$git_context")
    
    # Create temporary output file
    local output_file
    output_file=$(mktemp)
    
    # Log prompt (if logging enabled)
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "[DEBUG] AI Prompt length: ${#prompt} chars" >&2
    fi
    
    # Execute Copilot CLI with timeout
    local start_time
    start_time=$(date +%s)
    
    local success=false
    if timeout ${AI_GENERATION_TIMEOUT} bash -c "echo '$prompt' | copilot -p 'git_workflow_specialist' > '$output_file' 2>&1"; then
        success=true
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "[DEBUG] AI generation took ${duration}s" >&2
    fi
    
    if [[ "$success" != "true" ]]; then
        echo "ERROR: AI generation failed or timed out after ${duration}s" >&2
        rm -f "$output_file"
        return 1
    fi
    
    # Read response
    local ai_response
    ai_response=$(cat "$output_file" 2>/dev/null || echo "")
    rm -f "$output_file"
    
    if [[ -z "$ai_response" ]]; then
        echo "ERROR: AI returned empty response" >&2
        return 1
    fi
    
    # Parse response
    local commit_message
    commit_message=$(parse_ai_commit_response "$ai_response")
    
    if [[ -z "$commit_message" ]]; then
        echo "ERROR: Failed to parse AI response" >&2
        return 1
    fi
    
    # Output the commit message
    echo "$commit_message"
    return 0
}

################################################################################
# AI RESPONSE PARSING
################################################################################

# Parse AI response to extract clean commit message
# Args: $1 - raw AI response
# Returns: Cleaned commit message
parse_ai_commit_response() {
    local ai_response="$1"
    
    # Remove common AI conversational wrappers
    local cleaned
    cleaned=$(echo "$ai_response" | \
        sed '/^Here/d' | \
        sed '/^I.*generated/d' | \
        sed '/^I.*created/d' | \
        sed '/^Based on/d' | \
        sed '/^Let me/d' | \
        sed '/^```text/d' | \
        sed '/^```markdown/d' | \
        sed '/^```$/d')
    
    # Try to find conventional commit pattern
    local commit_msg
    commit_msg=$(echo "$cleaned" | \
        awk '/^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert).*:/{flag=1} flag' | \
        sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    
    # If parsing failed, try alternative approach (take everything after first meaningful line)
    if [[ -z "$commit_msg" ]]; then
        commit_msg=$(echo "$cleaned" | \
            grep -v '^$' | \
            grep -v '^---' | \
            sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    fi
    
    # Final validation: check if it looks like a commit message
    if [[ "$commit_msg" =~ ^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert) ]]; then
        echo "$commit_msg"
        return 0
    fi
    
    # If still not valid, return empty (caller will use fallback)
    echo ""
    return 1
}

################################################################################
# ENHANCED FALLBACK MESSAGE
################################################################################

# Generate enhanced fallback commit message with context
# Returns: Enhanced conventional commit message
generate_enhanced_fallback_message() {
    # Get basic stats
    local total_changes
    total_changes=$(get_git_total_changes 2>/dev/null || echo "0")
    
    local docs_modified
    docs_modified=$(get_git_docs_modified 2>/dev/null || echo "0")
    
    local tests_modified
    tests_modified=$(get_git_tests_modified 2>/dev/null || echo "0")
    
    local code_modified
    code_modified=$(get_git_code_modified 2>/dev/null || echo "0")
    
    # Infer type and scope
    local commit_type="chore"
    local commit_scope="updates"
    
    if [[ $code_modified -gt 0 ]] && [[ $tests_modified -gt 0 ]]; then
        commit_type="feat"
        commit_scope="implementation+tests"
    elif [[ $code_modified -gt 0 ]]; then
        commit_type="feat"
        commit_scope="implementation"
    elif [[ $tests_modified -gt 0 ]]; then
        commit_type="test"
        commit_scope="testing"
    elif [[ $docs_modified -gt 0 ]]; then
        commit_type="docs"
        commit_scope="documentation"
    fi
    
    # Get top changed files
    local top_files
    top_files=$(git status --short 2>/dev/null | head -3 | awk '{print "- " $2}' || echo "")
    
    # Get diff stats
    local insertions
    insertions=$(git diff --shortstat HEAD 2>/dev/null | grep -oP '\d+(?= insertion)' || echo "0")
    
    local deletions
    deletions=$(git diff --shortstat HEAD 2>/dev/null | grep -oP '\d+(?= deletion)' || echo "0")
    
    # Build enhanced message
    local message="${commit_type}(${commit_scope}): automated workflow updates

Workflow automation completed comprehensive validation and updates
across ${total_changes} files.

Key Changes:
${top_files}

Categories:
- Documentation: ${docs_modified} files
- Tests: ${tests_modified} files
- Code: ${code_modified} files

Diff: +${insertions} -${deletions}

[workflow-automation ${SCRIPT_VERSION:-v2.7.0} - batch mode]"
    
    echo "$message"
}

################################################################################
# MAIN BATCH GENERATION FUNCTION
################################################################################

# Main function to generate commit message in batch mode
# Tries AI generation first, falls back to enhanced message if needed
# Returns: 0 on success with message in stdout, 1 on failure
generate_batch_ai_commit_message() {
    local log_prefix="[Batch AI Commit]"
    
    print_info "${log_prefix} Starting AI commit message generation..."
    log_to_workflow "INFO" "Batch AI commit generation started"
    
    # Try AI generation
    local ai_message
    local generation_start
    generation_start=$(date +%s)
    
    if ai_message=$(generate_ai_commit_message_batch 2>&1); then
        local generation_end
        generation_end=$(date +%s)
        local generation_time=$((generation_end - generation_start))
        
        print_success "${log_prefix} AI generated commit message in ${generation_time}s"
        log_to_workflow "SUCCESS" "AI commit message generated (${generation_time}s)"
        
        # Display the message
        echo ""
        print_info "AI-Generated Commit Message:"
        echo -e "${CYAN}${ai_message}${NC}"
        echo ""
        
        # Output the message
        echo "$ai_message"
        return 0
    else
        # AI generation failed, use enhanced fallback
        print_warning "${log_prefix} AI generation failed, using enhanced fallback"
        log_to_workflow "WARNING" "AI generation failed: $ai_message"
        
        local fallback_message
        fallback_message=$(generate_enhanced_fallback_message)
        
        print_info "Enhanced Fallback Commit Message:"
        echo -e "${YELLOW}${fallback_message}${NC}"
        echo ""
        
        # Output the fallback message
        echo "$fallback_message"
        return 0
    fi
}

################################################################################
# EXPORTS
################################################################################

export -f assemble_git_context_for_ai
export -f build_batch_commit_prompt
export -f generate_ai_commit_message_batch
export -f parse_ai_commit_response
export -f generate_enhanced_fallback_message
export -f generate_batch_ai_commit_message
