#!/bin/bash
set -euo pipefail

################################################################################
# AI Personas Module
# Purpose: AI persona management and prompt generation
# Extracted from: ai_helpers.sh (Module Decomposition)
# Part of: Tests & Documentation Workflow Automation v2.4.0
################################################################################

# ==============================================================================
# PERSONA MANAGEMENT
# ==============================================================================

# Get project kind specific prompt from YAML configuration
# Usage: get_project_kind_prompt <persona_name> <project_kind>
# Returns: Prompt text or empty string if not found
get_project_kind_prompt() {
    local persona_name="$1"
    local project_kind="$2"
    local yaml_file="${SCRIPT_DIR}/config/ai_prompts_project_kinds.yaml"
    
    if [[ ! -f "$yaml_file" ]]; then
        return 1
    fi
    
    # Use yq to extract the prompt for the given persona and project kind
    local prompt
    prompt=$(yq eval ".personas.${persona_name}.project_kinds.${project_kind}" "$yaml_file" 2>/dev/null || echo "")
    
    if [[ -z "$prompt" || "$prompt" == "null" ]]; then
        return 1
    fi
    
    echo "$prompt"
    return 0
}

# Build project-kind aware prompt
# Usage: build_project_kind_prompt <persona_name> <project_kind> <fallback_prompt>
build_project_kind_prompt() {
    local persona_name="$1"
    local project_kind="$2"
    local fallback_prompt="$3"
    
    # Try to get project-kind specific prompt
    local prompt
    if prompt=$(get_project_kind_prompt "$persona_name" "$project_kind"); then
        echo "$prompt"
        return 0
    fi
    
    # Fall back to generic prompt
    echo "$fallback_prompt"
    return 0
}

# Build project-kind aware documentation prompt
# Usage: build_project_kind_doc_prompt <project_kind> <changed_files> <doc_files>
build_project_kind_doc_prompt() {
    local project_kind="$1"
    local changed_files="$2"
    local doc_files="$3"
    
    local role="You are a senior technical documentation specialist"
    local task="Based on the recent changes to: ${changed_files}, update documentation in: ${doc_files}"
    local approach=$(get_project_kind_prompt "documentation_specialist" "$project_kind" || echo "Follow best practices for $project_kind projects")
    
    build_ai_prompt "$role" "$task" "$approach"
}

# Build project-kind aware test prompt  
# Usage: build_project_kind_test_prompt <project_kind> <code_files>
build_project_kind_test_prompt() {
    local project_kind="$1"
    local code_files="$2"
    
    local role="You are a senior test engineer"
    local task="Generate comprehensive tests for: ${code_files}"
    local approach=$(get_project_kind_prompt "test_engineer" "$project_kind" || echo "Follow testing best practices for $project_kind projects")
    
    build_ai_prompt "$role" "$task" "$approach"
}

# Build project-kind aware code review prompt
# Usage: build_project_kind_review_prompt <project_kind> <code_files>
build_project_kind_review_prompt() {
    local project_kind="$1"
    local code_files="$2"
    
    local role="You are a senior code reviewer"
    local task="Review code quality and architecture for: ${code_files}"
    local approach=$(get_project_kind_prompt "code_reviewer" "$project_kind" || echo "Apply code quality standards for $project_kind projects")
    
    build_ai_prompt "$role" "$task" "$approach"
}

# Check if project-kind aware prompts should be used
# Usage: should_use_project_kind_prompts
# Returns: 0 if should use, 1 if not
should_use_project_kind_prompts() {
    local yaml_file="${SCRIPT_DIR}/config/ai_prompts_project_kinds.yaml"
    
    # Check if YAML file exists
    if [[ ! -f "$yaml_file" ]]; then
        return 1
    fi
    
    # Check if project kind is configured
    if [[ -z "${PROJECT_KIND:-}" ]]; then
        return 1
    fi
    
    return 0
}

# Generate adaptive prompt based on project configuration
# Usage: generate_adaptive_prompt <persona_name> <fallback_prompt> [additional_context]
generate_adaptive_prompt() {
    local persona_name="$1"
    local fallback_prompt="$2"
    local additional_context="${3:-}"
    
    # If project-kind prompts are available, use them
    if should_use_project_kind_prompts; then
        local prompt
        prompt=$(build_project_kind_prompt "$persona_name" "$PROJECT_KIND" "$fallback_prompt")
        
        if [[ -n "$additional_context" ]]; then
            echo "${prompt}${additional_context}"
        else
            echo "$prompt"
        fi
        return 0
    fi
    
    # Otherwise, use fallback prompt
    if [[ -n "$additional_context" ]]; then
        echo "${fallback_prompt}${additional_context}"
    else
        echo "$fallback_prompt"
    fi
    return 0
}

# ==============================================================================
# LANGUAGE-AWARE PROMPT HELPERS (LEGACY - Consider deprecation)
# ==============================================================================

# Get language-specific documentation conventions
# Usage: get_language_documentation_conventions <language>
get_language_documentation_conventions() {
    local language="$1"
    
    case "${language,,}" in
        javascript|typescript|node)
            echo "Use JSDoc format with @param, @returns, @throws tags"
            ;;
        python)
            echo "Use docstrings with Google or NumPy style"
            ;;
        shell|bash)
            echo "Use header comments with Usage, Parameters, Returns sections"
            ;;
        *)
            echo "Use clear inline comments and function documentation"
            ;;
    esac
}

# Get language-specific quality standards
# Usage: get_language_quality_standards <language>
get_language_quality_standards() {
    local language="$1"
    
    case "${language,,}" in
        javascript|typescript|node)
            echo "Follow ESLint, use strict mode, handle errors properly"
            ;;
        python)
            echo "Follow PEP 8, use type hints, handle exceptions properly"
            ;;
        shell|bash)
            echo "Use shellcheck, quote variables, use set -euo pipefail"
            ;;
        *)
            echo "Follow language best practices and style guides"
            ;;
    esac
}

# Get language-specific testing patterns
# Usage: get_language_testing_patterns <language>
get_language_testing_patterns() {
    local language="$1"
    
    case "${language,,}" in
        javascript|typescript|node)
            echo "Use Jest or Mocha, test edge cases, mock external dependencies"
            ;;
        python)
            echo "Use pytest or unittest, parametrize tests, use fixtures"
            ;;
        shell|bash)
            echo "Use BATS, test error conditions, verify exit codes"
            ;;
        *)
            echo "Use language-appropriate testing framework and patterns"
            ;;
    esac
}
