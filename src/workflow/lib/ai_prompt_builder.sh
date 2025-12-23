#!/bin/bash
set -euo pipefail

################################################################################
# AI Prompt Builder Module
# Purpose: Structured AI prompt construction for various workflow steps
# Extracted from: ai_helpers.sh (Module Decomposition)
# Part of: Tests & Documentation Workflow Automation v2.4.0
################################################################################

# ==============================================================================
# CORE PROMPT BUILDING
# ==============================================================================

# Build a structured AI prompt with role, task, and standards
# Usage: build_ai_prompt <role> <task> <standards>
build_ai_prompt() {
    local role="$1"
    local task="$2"
    local standards="$3"
    
    cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${standards}
EOF
}

# Build a documentation analysis prompt
# Usage: build_doc_analysis_prompt <changed_files> <doc_files>
build_doc_analysis_prompt() {
    local changed_files="$1"
    local doc_files="$2"
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    local yaml_project_kind_file="${SCRIPT_DIR}/config/ai_prompts_project_kinds.yaml"

    local role=""
    local task_context=""
    local approach=""
    local task_template=""

    print_info "Building documentation analysis prompt"
    print_info "YAML Project Kind File: $yaml_project_kind_file"

    # Load role and approach from YAML
    if [[ -f "$yaml_file" ]]; then
        role=$(yq eval '.personas.documentation_specialist.role' "$yaml_file" 2>/dev/null || echo "")
        approach=$(yq eval '.personas.documentation_specialist.approach' "$yaml_file" 2>/dev/null || echo "")
        task_template=$(yq eval '.personas.documentation_specialist.task_template' "$yaml_file" 2>/dev/null || echo "")
    fi

    # Fallback values if YAML parsing fails
    if [[ -z "$role" || "$role" == "null" ]]; then
        role="You are a senior technical documentation specialist"
    fi
    if [[ -z "$approach" || "$approach" == "null" ]]; then
        approach="Follow documentation best practices"
    fi

    # Build task context with file information
    if [[ -n "$task_template" && "$task_template" != "null" ]]; then
        # Replace variables in template
        task_context="${task_template//\$\{changed_files\}/$changed_files}"
        task_context="${task_context//\$\{doc_files\}/$doc_files}"
    else
        task_context="Based on the recent changes to: ${changed_files}, update documentation in: ${doc_files}"
    fi

    build_ai_prompt "$role" "$task_context" "$approach"
}

# Build a consistency analysis prompt
# Usage: build_consistency_prompt <doc_directory>
build_consistency_prompt() {
    local doc_directory="$1"
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
    local role=""
    local task=""
    local approach=""
    
    # Load from YAML
    if [[ -f "$yaml_file" ]]; then
        role=$(yq eval '.personas.consistency_analyst.role' "$yaml_file" 2>/dev/null || echo "")
        approach=$(yq eval '.personas.consistency_analyst.approach' "$yaml_file" 2>/dev/null || echo "")
        
        local task_template
        task_template=$(yq eval '.personas.consistency_analyst.task_template' "$yaml_file" 2>/dev/null || echo "")
        
        if [[ -n "$task_template" && "$task_template" != "null" ]]; then
            task="${task_template//\$\{doc_directory\}/$doc_directory}"
        fi
    fi
    
    # Fallbacks
    if [[ -z "$role" || "$role" == "null" ]]; then
        role="You are a senior technical documentation analyst"
    fi
    if [[ -z "$task" || "$task" == "null" ]]; then
        task="Perform comprehensive consistency analysis on documentation in: ${doc_directory}"
    fi
    if [[ -z "$approach" || "$approach" == "null" ]]; then
        approach="Check cross-references, terminology, formatting, and completeness"
    fi
    
    build_ai_prompt "$role" "$task" "$approach"
}

# Build a test strategy prompt
# Usage: build_test_strategy_prompt <code_files> <test_framework>
build_test_strategy_prompt() {
    local code_files="$1"
    local test_framework="${2:-}"
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
    local role=""
    local task=""
    local approach=""
    
    # Load from YAML
    if [[ -f "$yaml_file" ]]; then
        role=$(yq eval '.personas.test_engineer.role' "$yaml_file" 2>/dev/null || echo "")
        approach=$(yq eval '.personas.test_engineer.approach' "$yaml_file" 2>/dev/null || echo "")
        
        local task_template
        task_template=$(yq eval '.personas.test_engineer.task_template' "$yaml_file" 2>/dev/null || echo "")
        
        if [[ -n "$task_template" && "$task_template" != "null" ]]; then
            task="${task_template//\$\{code_files\}/$code_files}"
            if [[ -n "$test_framework" ]]; then
                task="${task} using ${test_framework} framework"
            fi
        fi
    fi
    
    # Fallbacks
    if [[ -z "$role" || "$role" == "null" ]]; then
        role="You are a senior test engineer and quality assurance specialist"
    fi
    if [[ -z "$task" || "$task" == "null" ]]; then
        if [[ -n "$test_framework" ]]; then
            task="Generate comprehensive test cases for: ${code_files} using ${test_framework} framework"
        else
            task="Generate comprehensive test cases for: ${code_files}"
        fi
    fi
    if [[ -z "$approach" || "$approach" == "null" ]]; then
        approach="Cover edge cases, error conditions, and integration scenarios"
    fi
    
    build_ai_prompt "$role" "$task" "$approach"
}

# Build a code quality review prompt
# Usage: build_quality_prompt <code_files> <language>
build_quality_prompt() {
    local code_files="$1"
    local language="${2:-}"
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
    local role=""
    local task=""
    local approach=""
    
    # Load from YAML
    if [[ -f "$yaml_file" ]]; then
        role=$(yq eval '.personas.code_reviewer.role' "$yaml_file" 2>/dev/null || echo "")
        approach=$(yq eval '.personas.code_reviewer.approach' "$yaml_file" 2>/dev/null || echo "")
        
        local task_template
        task_template=$(yq eval '.personas.code_reviewer.task_template' "$yaml_file" 2>/dev/null || echo "")
        
        if [[ -n "$task_template" && "$task_template" != "null" ]]; then
            task="${task_template//\$\{code_files\}/$code_files}"
            if [[ -n "$language" ]]; then
                task="${task} (${language} code)"
            fi
        fi
    fi
    
    # Fallbacks
    if [[ -z "$role" || "$role" == "null" ]]; then
        role="You are a senior code reviewer and software architect"
    fi
    if [[ -z "$task" || "$task" == "null" ]]; then
        if [[ -n "$language" ]]; then
            task="Review code quality and architecture for ${language} code in: ${code_files}"
        else
            task="Review code quality and architecture for: ${code_files}"
        fi
    fi
    if [[ -z "$approach" || "$approach" == "null" ]]; then
        approach="Focus on maintainability, performance, security, and best practices"
    fi
    
    build_ai_prompt "$role" "$task" "$approach"
}

# Build an issue extraction prompt
# Usage: build_issue_extraction_prompt <log_file>
build_issue_extraction_prompt() {
    local log_file="$1"
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
    local role=""
    local task=""
    local approach=""
    
    # Load from YAML
    if [[ -f "$yaml_file" ]]; then
        role=$(yq eval '.personas.issue_extractor.role' "$yaml_file" 2>/dev/null || echo "")
        approach=$(yq eval '.personas.issue_extractor.approach' "$yaml_file" 2>/dev/null || echo "")
        
        local task_template
        task_template=$(yq eval '.personas.issue_extractor.task_template' "$yaml_file" 2>/dev/null || echo "")
        
        if [[ -n "$task_template" && "$task_template" != "null" ]]; then
            task="${task_template//\$\{log_file\}/$log_file}"
        fi
    fi
    
    # Fallbacks
    if [[ -z "$role" || "$role" == "null" ]]; then
        role="You are a technical analyst specializing in log analysis"
    fi
    if [[ -z "$task" || "$task" == "null" ]]; then
        task="Extract and categorize issues from log file: ${log_file}"
    fi
    if [[ -z "$approach" || "$approach" == "null" ]]; then
        approach="Identify errors, warnings, and actionable improvements"
    fi
    
    build_ai_prompt "$role" "$task" "$approach"
}
