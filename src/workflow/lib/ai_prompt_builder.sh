#!/bin/bash
set -euo pipefail

################################################################################
# AI Prompt Builder Module
# Purpose: Structured AI prompt construction for various workflow steps
# Extracted from: ai_helpers.sh (Module Decomposition)
# Part of: Tests & Documentation Workflow Automation v2.7.0
################################################################################

# ==============================================================================
# LANGUAGE-SPECIFIC CONTENT EXTRACTION (v2.7.0 - NEW)
# ==============================================================================

# Get language-specific content from YAML and format for prompt
# Usage: get_language_specific_content <yaml_file> <section_name> <language>
# Example: get_language_specific_content "ai_helpers.yaml" "language_specific_documentation" "javascript"
get_language_specific_content() {
    local yaml_file="$1"
    local section_name="$2"
    local language="${3:-}"
    
    # Return empty if no language specified
    if [[ -z "$language" || "$language" == "null" ]]; then
        echo ""
        return 0
    fi
    
    # Normalize language name (lowercase)
    language=$(echo "$language" | tr '[:upper:]' '[:lower:]')
    
    # Try to extract language-specific content
    local key_points=""
    local doc_format=""
    local example_snippet=""
    
    # Extract key_points
    key_points=$(get_yq_value "$yaml_file" "${section_name}.${language}.key_points" 2>/dev/null || echo "")
    
    # If we got content, format it nicely
    if [[ -n "$key_points" && "$key_points" != "null" ]]; then
        echo "$key_points"
        
        # Try to get doc_format and example if available
        doc_format=$(get_yq_value "$yaml_file" "${section_name}.${language}.doc_format" 2>/dev/null || echo "")
        if [[ -n "$doc_format" && "$doc_format" != "null" ]]; then
            echo ""
            echo "**Documentation Format:** $doc_format"
        fi
        
        example_snippet=$(get_yq_value "$yaml_file" "${section_name}.${language}.example_snippet" 2>/dev/null || echo "")
        if [[ -n "$example_snippet" && "$example_snippet" != "null" ]]; then
            echo ""
            echo "**Example:**"
            echo '```'
            echo "$example_snippet"
            echo '```'
        fi
    else
        # No language-specific content found - return generic message
        echo "• Follow language best practices for documentation"
        echo "• Use consistent formatting and style"
        echo "• Include examples where appropriate"
    fi
}

# Substitute language-specific placeholders in prompt template
# Usage: substitute_language_placeholders <prompt_text> <yaml_file>
# Replaces: {language_specific_documentation}, {language_specific_testing_standards}, {language_specific_quality}
substitute_language_placeholders() {
    local prompt_text="$1"
    local yaml_file="$2"
    
    # Get PRIMARY_LANGUAGE from .workflow-config.yaml or environment
    local primary_language="${PRIMARY_LANGUAGE:-}"
    
    # Try to read from .workflow-config.yaml if not in environment
    if [[ -z "$primary_language" ]] && [[ -f "${PROJECT_ROOT}/.workflow-config.yaml" ]]; then
        primary_language=$(get_yq_value "${PROJECT_ROOT}/.workflow-config.yaml" "tech_stack.primary_language" 2>/dev/null || echo "")
    fi
    
    # If still no language, return prompt as-is with generic placeholders removed
    if [[ -z "$primary_language" || "$primary_language" == "null" ]]; then
        # Remove placeholder lines entirely
        prompt_text=$(echo "$prompt_text" | sed '/{language_specific_/d')
        echo "$prompt_text"
        return 0
    fi
    
    # Log language detection
    echo "[INFO] Detected PRIMARY_LANGUAGE: $primary_language" >&2
    
    # Substitute {language_specific_documentation}
    if echo "$prompt_text" | grep -q "{language_specific_documentation}"; then
        local doc_content
        doc_content=$(get_language_specific_content "$yaml_file" "language_specific_documentation" "$primary_language")
        # Replace placeholder with content (preserve newlines)
        prompt_text=$(echo "$prompt_text" | sed "/{language_specific_documentation}/{
r /dev/stdin
d
}" <<< "$doc_content")
    fi
    
    # Substitute {language_specific_testing_standards}
    if echo "$prompt_text" | grep -q "{language_specific_testing_standards}"; then
        local test_content
        test_content=$(get_language_specific_content "$yaml_file" "language_specific_testing" "$primary_language")
        prompt_text=$(echo "$prompt_text" | sed "/{language_specific_testing_standards}/{
r /dev/stdin
d
}" <<< "$test_content")
    fi
    
    # Substitute {language_specific_quality}
    if echo "$prompt_text" | grep -q "{language_specific_quality}"; then
        local quality_content
        quality_content=$(get_language_specific_content "$yaml_file" "language_specific_quality" "$primary_language")
        prompt_text=$(echo "$prompt_text" | sed "/{language_specific_quality}/{
r /dev/stdin
d
}" <<< "$quality_content")
    fi
    
    # Substitute {language_specific_directory_standards}
    if echo "$prompt_text" | grep -q "{language_specific_directory_standards}"; then
        local dir_content
        dir_content=$(get_language_specific_content "$yaml_file" "language_specific_directory" "$primary_language")
        prompt_text=$(echo "$prompt_text" | sed "/{language_specific_directory_standards}/{
r /dev/stdin
d
}" <<< "$dir_content")
    fi
    
    echo "$prompt_text"
}

# ==============================================================================
# CORE PROMPT BUILDING
# ==============================================================================

# Get YAML value with version detection
# Usage: get_yq_value <yaml_file> <yaml_path>
get_yq_value() {
    local yaml_file="$1"
    local yaml_path="$2"
    local yq_version=$(yq --version 2>&1 | head -1)
    
    if echo "$yq_version" | grep -qE "mikefarah.*version [4-9]"; then
        # mikefarah yq v4+ syntax
        yq eval ".${yaml_path}" "$yaml_file" 2>/dev/null || echo ""
    elif echo "$yq_version" | grep -q "mikefarah"; then
        # mikefarah yq v3 syntax
        yq r "$yaml_file" "${yaml_path}" 2>/dev/null || echo ""
    else
        # Python yq (kislyuk) - jq syntax
        yq -r ".${yaml_path}" "$yaml_file" 2>/dev/null || echo ""
    fi
}

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
    local yaml_file="${SCRIPT_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    local yaml_project_kind_file="${SCRIPT_DIR}/../../../.workflow_core/config/ai_prompts_project_kinds.yaml"

    local role_prefix=""
    local behavioral_guidelines=""
    local role=""
    local task_context=""
    local approach=""
    local task_template=""

    # Log to stderr, not to prompt output
    echo "[INFO] Building documentation analysis prompt" >&2
    echo "[INFO] YAML File: $yaml_file" >&2

    # Load role and approach from YAML with correct path
    if [[ -f "$yaml_file" ]]; then
        role_prefix=$(get_yq_value "$yaml_file" "doc_analysis_prompt.role_prefix")
        task_template=$(get_yq_value "$yaml_file" "doc_analysis_prompt.task_template")
        approach=$(get_yq_value "$yaml_file" "doc_analysis_prompt.approach")
        
        # Get behavioral guidelines (YAML anchor reference)
        behavioral_guidelines=$(get_yq_value "$yaml_file" "_behavioral_actionable")
        
        # Combine role_prefix + behavioral_guidelines
        if [[ -n "$role_prefix" && "$role_prefix" != "null" ]]; then
            role="$role_prefix"
            if [[ -n "$behavioral_guidelines" && "$behavioral_guidelines" != "null" ]]; then
                role="${role}

${behavioral_guidelines}"
            fi
        fi
    fi

    # Fallback values if YAML parsing fails
    if [[ -z "$role" || "$role" == "null" ]]; then
        role="You are a senior technical documentation specialist with expertise in software architecture documentation, API documentation, and developer experience (DX) optimization.

**Critical Behavioral Guidelines**:
- ALWAYS provide concrete, actionable output (never ask clarifying questions)
- If documentation is accurate, explicitly say \"No updates needed - documentation is current\"
- Only update what is truly outdated or incorrect
- Make informed decisions based on available context
- Default to \"no changes\" rather than making unnecessary modifications"
    fi
    
    if [[ -z "$approach" || "$approach" == "null" ]]; then
        approach="**Methodology**:
1. **Analyze Changes**: Examine what was modified in each changed file
2. **Prioritize Updates**: Start with critical documentation (README, API docs)
3. **Edit Surgically**: Provide EXACT text changes only where needed
4. **Verify Consistency**: Maintain project standards

**Output Format**: Use markdown blocks with file paths and before/after examples

**Critical**: ALWAYS provide specific edits OR state \"No updates needed\""
    fi

    # Build task context with file information
    if [[ -n "$task_template" && "$task_template" != "null" ]]; then
        # Replace variables in template (handle both ${var} and {var} formats)
        task_context="${task_template//\{changed_files\}/$changed_files}"
        task_context="${task_context//\{doc_files\}/$doc_files}"
        task_context="${task_context//\$\{changed_files\}/$changed_files}"
        task_context="${task_context//\$\{doc_files\}/$doc_files}"
    else
        task_context="Based on the recent changes to: ${changed_files}, update documentation in: ${doc_files}"
    fi

    # Build the prompt
    local prompt
    prompt=$(build_ai_prompt "$role" "$task_context" "$approach")
    
    # Substitute language-specific placeholders (v2.7.0 - NEW)
    prompt=$(substitute_language_placeholders "$prompt" "$yaml_file")
    
    echo "$prompt"
}

# Build a consistency analysis prompt
# Usage: build_consistency_prompt <doc_directory>
build_consistency_prompt() {
    local doc_directory="$1"
    local yaml_file="${SCRIPT_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    local role_prefix=""
    local behavioral_guidelines=""
    local role=""
    local task=""
    local approach=""
    
    echo "[INFO] Building consistency analysis prompt" >&2
    
    # Load from YAML with correct paths
    if [[ -f "$yaml_file" ]]; then
        role_prefix=$(get_yq_value "$yaml_file" "consistency_prompt.role_prefix")
        approach=$(get_yq_value "$yaml_file" "consistency_prompt.approach")
        
        local task_template
        task_template=$(get_yq_value "$yaml_file" "consistency_prompt.task_template")
        
        # Get behavioral guidelines (YAML anchor)
        behavioral_guidelines=$(get_yq_value "$yaml_file" "_behavioral_structured")
        
        # Combine role_prefix + behavioral_guidelines
        if [[ -n "$role_prefix" && "$role_prefix" != "null" ]]; then
            role="$role_prefix"
            if [[ -n "$behavioral_guidelines" && "$behavioral_guidelines" != "null" ]]; then
                role="${role}

${behavioral_guidelines}"
            fi
        fi
        
        if [[ -n "$task_template" && "$task_template" != "null" ]]; then
            task="${task_template//\{doc_directory\}/$doc_directory}"
            task="${task//\$\{doc_directory\}/$doc_directory}"
        fi
    fi
    
    # Fallbacks
    if [[ -z "$role" || "$role" == "null" ]]; then
        role="You are a senior technical documentation specialist and information architect with expertise in documentation quality assurance, technical writing standards, and cross-reference validation.

**Critical Behavioral Guidelines**:
- ALWAYS provide structured, prioritized analysis (never general observations)
- Identify specific files, line numbers, and exact issues
- Include concrete recommended fixes for each problem
- Prioritize issues by severity and impact on user experience
- Focus on accuracy and consistency over style preferences"
    fi
    
    if [[ -z "$task" || "$task" == "null" ]]; then
        task="Perform comprehensive consistency analysis on documentation in: ${doc_directory}"
    fi
    
    if [[ -z "$approach" || "$approach" == "null" ]]; then
        approach="**Analysis Methodology**:
1. **Prioritize by Category**: Focus on Critical and User documentation first
2. **Systematic Validation**: Check cross-references, terminology, versions, examples
3. **Structured Reporting**: Organize by severity (Critical > High > Medium > Low)
4. **Actionable Recommendations**: For each issue provide file:line, problem, fix, impact

Check for: broken references, version mismatches, terminology inconsistencies, format violations"
    fi
    
    # Build and substitute language-specific content (v2.7.0)
    local prompt
    prompt=$(build_ai_prompt "$role" "$task" "$approach")
    prompt=$(substitute_language_placeholders "$prompt" "$yaml_file")
    
    echo "$prompt"
}

# Build a test strategy prompt
# Usage: build_test_strategy_prompt <code_files> <test_framework>
build_test_strategy_prompt() {
    local code_files="$1"
    local test_framework="${2:-}"
    local yaml_file="${SCRIPT_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    local role_prefix=""
    local behavioral_guidelines=""
    local role=""
    local task=""
    local approach=""
    
    echo "[INFO] Building test strategy prompt" >&2
    
    # Load from YAML with correct paths
    if [[ -f "$yaml_file" ]]; then
        role_prefix=$(get_yq_value "$yaml_file" "test_strategy_prompt.role_prefix")
        approach=$(get_yq_value "$yaml_file" "test_strategy_prompt.approach")
        
        local task_template
        task_template=$(get_yq_value "$yaml_file" "test_strategy_prompt.task_template")
        
        # Get behavioral guidelines (YAML anchor)
        behavioral_guidelines=$(get_yq_value "$yaml_file" "_behavioral_structured")
        
        # Combine role_prefix + behavioral_guidelines
        if [[ -n "$role_prefix" && "$role_prefix" != "null" ]]; then
            role="$role_prefix"
            if [[ -n "$behavioral_guidelines" && "$behavioral_guidelines" != "null" ]]; then
                role="${role}

${behavioral_guidelines}"
            fi
        fi
        
        if [[ -n "$task_template" && "$task_template" != "null" ]]; then
            task="${task_template//\{code_files\}/$code_files}"
            task="${task//\$\{code_files\}/$code_files}"
            if [[ -n "$test_framework" ]]; then
                task="${task} using ${test_framework} framework"
            fi
        fi
    fi
    
    # Fallbacks
    if [[ -z "$role" || "$role" == "null" ]]; then
        role="You are a test strategy architect specializing in coverage analysis and test planning. You identify WHAT to test and WHY (gaps, priorities, risks), not HOW to implement tests. Focus on strategic portfolio-level recommendations, not tactical test code.

**Critical Behavioral Guidelines**:
- ALWAYS provide structured, prioritized analysis (never general observations)
- Identify specific coverage gaps with severity levels
- Include concrete test recommendations with effort estimates
- Focus on portfolio-level strategy, not implementation details"
    fi
    
    if [[ -z "$task" || "$task" == "null" ]]; then
        if [[ -n "$test_framework" ]]; then
            task="Analyze test coverage and provide strategic recommendations for: ${code_files} using ${test_framework} framework"
        else
            task="Analyze test coverage and provide strategic recommendations for: ${code_files}"
        fi
    fi
    
    if [[ -z "$approach" || "$approach" == "null" ]]; then
        approach="**Strategic Focus**:
1. **Coverage Gap Identification**: Identify untested code paths, low coverage modules
2. **Test Prioritization**: Prioritize by business criticality and risk
3. **Portfolio Balance**: Evaluate unit vs integration vs e2e distribution
4. **Recommendations**: WHAT to test and WHY, not HOW to implement

Focus on portfolio-level strategy, not tactical implementation"
    fi
    
    # Build and substitute language-specific content (v2.7.0)
    local prompt
    prompt=$(build_ai_prompt "$role" "$task" "$approach")
    prompt=$(substitute_language_placeholders "$prompt" "$yaml_file")
    
    echo "$prompt"
}

# Build a code quality review prompt
# Usage: build_quality_prompt <code_files> <language>
build_quality_prompt() {
    local code_files="$1"
    local language="${2:-}"
    local yaml_file="${SCRIPT_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    local role_prefix=""
    local behavioral_guidelines=""
    local role=""
    local task=""
    local approach=""
    
    echo "[INFO] Building quality review prompt" >&2
    
    # Load from YAML with correct paths
    if [[ -f "$yaml_file" ]]; then
        role_prefix=$(get_yq_value "$yaml_file" "quality_prompt.role_prefix")
        approach=$(get_yq_value "$yaml_file" "quality_prompt.approach")
        
        local task_template
        task_template=$(get_yq_value "$yaml_file" "quality_prompt.task_template")
        
        # Get behavioral guidelines (YAML anchor)
        behavioral_guidelines=$(get_yq_value "$yaml_file" "_behavioral_actionable")
        
        # Combine role_prefix + behavioral_guidelines
        if [[ -n "$role_prefix" && "$role_prefix" != "null" ]]; then
            role="$role_prefix"
            if [[ -n "$behavioral_guidelines" && "$behavioral_guidelines" != "null" ]]; then
                role="${role}

${behavioral_guidelines}"
            fi
        fi
        
        if [[ -n "$task_template" && "$task_template" != "null" ]]; then
            task="${task_template//\{files_to_review\}/$code_files}"
            task="${task//\$\{files_to_review\}/$code_files}"
            if [[ -n "$language" ]]; then
                task="${task} (${language} code)"
            fi
        fi
    fi
    
    # Fallbacks
    if [[ -z "$role" || "$role" == "null" ]]; then
        role="You are a senior code review specialist with 10+ years experience in targeted file-level quality assessments.

**Critical Behavioral Guidelines**:
- ALWAYS provide concrete, actionable output (never ask clarifying questions)
- Identify specific issues with file names and line numbers
- Suggest concrete improvements with code examples
- Prioritize findings by severity"
    fi
    
    if [[ -z "$task" || "$task" == "null" ]]; then
        if [[ -n "$language" ]]; then
            task="Review the following ${language} files for code quality: ${code_files}"
        else
            task="Review the following files for code quality: ${code_files}"
        fi
        task="${task}

Analyze:
1. **Code Organization** - Logical structure and separation of concerns
2. **Naming Conventions** - Clear, consistent, and descriptive names
3. **Error Handling** - Proper error handling and edge cases
4. **Documentation** - Inline comments and function documentation
5. **Best Practices** - Following language-specific best practices
6. **Potential Issues** - Security concerns, performance issues, bugs"
    fi
    
    if [[ -z "$approach" || "$approach" == "null" ]]; then
        approach="**Review Process**:
- Review each file systematically
- Identify specific issues with file names and line numbers
- Suggest concrete improvements
- Prioritize findings by severity
- Provide code examples for recommended fixes"
    fi
    
    # Build and substitute language-specific content (v2.7.0)
    local prompt
    prompt=$(build_ai_prompt "$role" "$task" "$approach")
    prompt=$(substitute_language_placeholders "$prompt" "$yaml_file")
    
    echo "$prompt"
}

# Build an issue extraction prompt
# Usage: build_issue_extraction_prompt <log_file>
build_issue_extraction_prompt() {
    local log_file="$1"
    local yaml_file="${SCRIPT_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    local role_prefix=""
    local behavioral_guidelines=""
    local role=""
    local task=""
    local approach=""
    
    echo "[INFO] Building issue extraction prompt" >&2
    
    # Load from YAML with correct paths
    if [[ -f "$yaml_file" ]]; then
        role_prefix=$(get_yq_value "$yaml_file" "issue_extraction_prompt.role_prefix")
        approach=$(get_yq_value "$yaml_file" "issue_extraction_prompt.approach")
        
        local task_template
        task_template=$(get_yq_value "$yaml_file" "issue_extraction_prompt.task_template")
        
        # Get behavioral guidelines (YAML anchor)
        behavioral_guidelines=$(get_yq_value "$yaml_file" "_behavioral_structured")
        
        # Combine role_prefix + behavioral_guidelines
        if [[ -n "$role_prefix" && "$role_prefix" != "null" ]]; then
            role="$role_prefix"
            if [[ -n "$behavioral_guidelines" && "$behavioral_guidelines" != "null" ]]; then
                role="${role}

${behavioral_guidelines}"
            fi
        fi
        
        if [[ -n "$task_template" && "$task_template" != "null" ]]; then
            task="${task_template//\{log_file\}/$log_file}"
            task="${task//\$\{log_file\}/$log_file}"
        fi
    fi
    
    # Fallbacks
    if [[ -z "$role" || "$role" == "null" ]]; then
        role="You are a technical project manager specialized in issue extraction, categorization, and documentation organization.

**Critical Behavioral Guidelines**:
- ALWAYS provide structured, prioritized analysis (never general observations)
- Group findings by severity (Critical > High > Medium > Low)
- For each issue: include description, priority, and affected files
- End with actionable recommendations"
    fi
    
    if [[ -z "$task" || "$task" == "null" ]]; then
        task="Analyze the following log from a documentation update workflow and extract all issues, recommendations, and action items.

**Log File**: ${log_file}

**Output Requirements**:
- Group findings by severity (Critical > High > Medium > Low)
- For each issue: include description, priority, and affected files
- End with actionable recommendations
- Use markdown headings for structure"
    fi
    
    if [[ -z "$approach" || "$approach" == "null" ]]; then
        approach="**Extraction Process**:
- Extract all issues, warnings, and recommendations from the log
- Categorize by severity and impact
- Include affected files/sections mentioned in the log
- Prioritize actionable items
- Add context for ambiguous issues
- If no issues found, state 'No issues identified'"
    fi
    
    build_ai_prompt "$role" "$task" "$approach"
}
