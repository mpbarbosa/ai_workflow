#!/bin/bash
set -euo pipefail

################################################################################
# AI Helpers Module
# Purpose: AI prompt templates and Copilot CLI integration helpers
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Enhancement: Project-aware personas via project_kinds.yaml (2025-12-19)
################################################################################

# Determine the directory of this module for config file resolution
# This ensures paths are correct regardless of where this module is sourced from
AI_HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_HELPERS_WORKFLOW_DIR="$(cd "${AI_HELPERS_DIR}/.." && pwd)"

# ==============================================================================
# CLEANUP MANAGEMENT
# ==============================================================================

# Track temporary files for cleanup
declare -a AI_HELPERS_TEMP_FILES=()

# Register temp file for cleanup
track_ai_helpers_temp() {
    local temp_file="$1"
    [[ -n "$temp_file" ]] && AI_HELPERS_TEMP_FILES+=("$temp_file")
}

# Cleanup handler for AI helpers
cleanup_ai_helpers_files() {
    local file
    for file in "${AI_HELPERS_TEMP_FILES[@]}"; do
        [[ -f "$file" ]] && rm -f "$file" 2>/dev/null
    done
    AI_HELPERS_TEMP_FILES=()
}

# ==============================================================================
# COPILOT CLI DETECTION AND VALIDATION
# ==============================================================================

# Check if Copilot CLI is available
# Returns: 0 if available, 1 if not
is_copilot_available() {
    command -v copilot &> /dev/null
}

# Check if Copilot CLI is authenticated
# Returns: 0 if authenticated, 1 if not
is_copilot_authenticated() {
    if ! is_copilot_available; then
        return 1
    fi
    
    # Test authentication by running a simple command
    # Redirect stderr to capture authentication errors
    local auth_test
    auth_test=$(copilot --version 2>&1)
    
    # Check for authentication error messages
    if echo "$auth_test" | grep -q "No authentication information found"; then
        return 1
    fi
    
    return 0
}

# Validate Copilot CLI and provide user feedback
# Usage: validate_copilot_cli
validate_copilot_cli() {
    if ! is_copilot_available; then
        print_warning "GitHub Copilot CLI not found"
        print_info "Install with: npm install -g @githubnext/github-copilot-cli"
        return 1
    fi
    
    if ! is_copilot_authenticated; then
        print_warning "GitHub Copilot CLI is not authenticated"
        print_info "Authentication options:"
        print_info "  • Run 'copilot' and use the '/login' command"
        print_info "  • Set COPILOT_GITHUB_TOKEN, GH_TOKEN, or GITHUB_TOKEN environment variable"
        print_info "  • Run 'gh auth login' to authenticate with GitHub CLI"
        return 1
    fi
    
    print_success "GitHub Copilot CLI detected and authenticated"
    return 0
}

# ==============================================================================
# AI PROMPT BUILDING
# ==============================================================================

# Get project metadata from configuration
# Returns: pipe-delimited string with project_name|project_description|primary_language
get_project_metadata() {
    local project_name=""
    local project_description=""
    local primary_language=""
    local config_file=""
    
    # Determine which directory to check (prioritize PROJECT_ROOT, then TARGET_DIR, then current dir)
    local check_dir="${PROJECT_ROOT:-${TARGET_DIR:-.}}"
    config_file="${check_dir}/.workflow-config.yaml"
    
    # Try to load from tech stack config first
    if command -v get_config_value &> /dev/null; then
        project_name=$(get_config_value "project.name" "")
        project_description=$(get_config_value "project.description" "")
        primary_language=$(get_config_value "tech_stack.primary_language" "")
    fi
    
    # Fallback to manual YAML parsing if get_config_value not available or returned empty
    if [[ -z "$project_name" ]] && [[ -f "$config_file" ]]; then
        project_name=$(awk '/^project:/{flag=1} flag && /^  name:/{sub(/^[^:]+:[[:space:]]*/, ""); gsub(/"/, ""); print; exit}' "$config_file")
        project_description=$(awk '/^project:/{flag=1} flag && /^  description:/{sub(/^[^:]+:[[:space:]]*/, ""); gsub(/"/, ""); print; exit}' "$config_file")
        primary_language=$(awk '/^tech_stack:/{flag=1} flag && /^  primary_language:/{sub(/^[^:]+:[[:space:]]*/, ""); gsub(/"/, ""); print; exit}' "$config_file")
    fi
    
    # If still empty, try to detect from package.json or other indicators
    if [[ -z "$project_name" ]] && [[ -f "${check_dir}/package.json" ]]; then
        project_name=$(grep -m1 '"name":' "${check_dir}/package.json" | sed 's/.*"name":[[:space:]]*"\([^"]*\)".*/\1/')
        project_description=$(grep -m1 '"description":' "${check_dir}/package.json" | sed 's/.*"description":[[:space:]]*"\([^"]*\)".*/\1/')
    fi
    
    # Detect primary language if not set
    if [[ -z "$primary_language" ]]; then
        if [[ -f "${check_dir}/package.json" ]]; then
            primary_language="javascript"
        elif [[ -f "${check_dir}/requirements.txt" ]] || [[ -f "${check_dir}/setup.py" ]]; then
            primary_language="python"
        elif [[ -f "${check_dir}/go.mod" ]]; then
            primary_language="go"
        elif [[ -f "${check_dir}/Cargo.toml" ]]; then
            primary_language="rust"
        elif ls "${check_dir}"/*.sh &>/dev/null; then
            primary_language="bash"
        fi
    fi
    
    # Use defaults if still empty
    project_name="${project_name:-Unknown Project}"
    project_description="${project_description:-No description available}"
    primary_language="${primary_language:-Unknown}"
    
    echo "$project_name|$project_description|$primary_language"
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

# ==============================================================================
# YAML ANCHOR SUPPORT FOR TOKEN EFFICIENCY
# ==============================================================================

# Compose role from role_prefix and behavioral_guidelines if available
# Falls back to legacy 'role' field for backward compatibility
# Usage: compose_role_from_yaml <yaml_file> <prompt_section>
# Returns: Complete role text
compose_role_from_yaml() {
    local yaml_file="$1"
    local prompt_section="$2"
    
    # Try to extract role_prefix and behavioral_guidelines using Python
    # This provides cleaner YAML parsing with anchor resolution
    if command -v python3 &>/dev/null; then
        local composed_role
        composed_role=$(python3 << EOF
import yaml
import sys

try:
    with open('$yaml_file', 'r') as f:
        data = yaml.safe_load(f)
    
    section = data.get('$prompt_section', {})
    
    # Check if we have the new format (role_prefix + behavioral_guidelines)
    if 'role_prefix' in section and 'behavioral_guidelines' in section:
        role_prefix = section['role_prefix'].strip()
        guidelines = section['behavioral_guidelines'].strip()
        print(f"{role_prefix}\\n\\n{guidelines}")
    elif 'role' in section:
        # Fallback to legacy format
        print(section['role'])
    else:
        sys.exit(1)
except Exception:
    sys.exit(1)
EOF
)
        if [[ $? -eq 0 && -n "$composed_role" ]]; then
            echo "$composed_role"
            return 0
        fi
    fi
    
    # Fallback: extract legacy 'role' field using awk
    local role
    role=$(awk -v section="^${prompt_section}:" '
        $0 ~ section { in_section=1; next }
        in_section && /role: \|/ { in_role=1; next }
        in_section && in_role && /^  [a-z_]/ { exit }
        in_section && in_role && /^    / {
            sub(/^    /, "");
            if (NR > 1) printf "\n";
            printf "%s", $0
        }
    ' "$yaml_file")
    
    if [[ -n "$role" ]]; then
        echo "$role"
        return 0
    fi
    
    return 1
}

# ==============================================================================
# PROMPT BUILDING FUNCTIONS
# ==============================================================================

# Build a documentation analysis prompt
# Usage: build_doc_analysis_prompt <changed_files> <doc_files>
# Step 1: Build a documentation analysis prompt
# Build documentation analysis prompt
# Usage: build_doc_analysis_prompt <changed_files> <doc_files>
build_doc_analysis_prompt() {
    local changed_files="$1"
    local doc_files="$2"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    local yaml_project_kind_file="${AI_HELPERS_WORKFLOW_DIR}/../../.workflow_core/config/ai_prompts_project_kinds.yaml"

    local role=""
    local task_context=""
    local approach=""
    local task_template=""
    local prompt_type="generic"  # Track which type of prompt is being used

    print_info "Building documentation analysis prompt" >&2
    print_info "YAML Project Kind File: $yaml_project_kind_file" >&2
    
    # Validate inputs - provide clear guidance if empty
    if [[ -z "$changed_files" || "$changed_files" == " " ]]; then
        print_warning "No changed files detected - using generic documentation review prompt" >&2
        changed_files="(No specific file changes detected - performing general documentation review)"
    fi
    
    if [[ -z "$doc_files" || "$doc_files" == " " ]]; then
        print_warning "No documentation files specified - using all common docs" >&2
        doc_files="README.md, docs/, .github/copilot-instructions.md"
    fi
    
    # Count changed files and provide summary if too many
    local file_count
    file_count=$(echo "$changed_files" | wc -w)
    if [[ $file_count -gt 20 ]]; then
        print_info "Large number of changes detected ($file_count files)" >&2
        # Provide summary instead of full list
        local file_summary="$file_count files changed across multiple directories"
        local dir_summary
        dir_summary=$(echo "$changed_files" | tr ' ' '\n' | xargs -I {} dirname {} | sort -u | head -10 | tr '\n' ', ')
        changed_files="**Change Summary**: ${file_summary}
**Affected directories**: ${dir_summary}
**Action Required**: Review documentation for consistency with these widespread changes.

For detailed file list, check git status or workflow logs."
    fi
    
    # Read project kind from config if available
    if [[ -f "$yaml_project_kind_file" ]]; then
        print_info "Reading project kind from config" >&2
        local project_kind=""
        
        # Try to get project kind, with proper error handling
        if command -v get_project_kind &>/dev/null; then
            project_kind=$(get_project_kind 2>/dev/null || echo "")
        fi
        
        # Fallback to detection if get_project_kind failed
        if [[ -z "$project_kind" ]] && command -v detect_project_kind &>/dev/null; then
            project_kind=$(detect_project_kind 2>/dev/null | jq -r '.kind' 2>/dev/null || echo "generic")
        fi
        
        # Final fallback
        if [[ -z "$project_kind" ]]; then
            project_kind="generic"
        fi
        
        print_info "Detected project kind: $project_kind" >&2
        
        if [[ -n "$project_kind" && "$project_kind" != "generic" && "$project_kind" != "null" ]]; then
            print_success "Using PROJECT KIND-SPECIFIC prompt for: $project_kind" >&2
            prompt_type="project_kind_specialized ($project_kind)"
            
            role=$(get_project_kind_prompt "$project_kind" "documentation_specialist" "role")
            local base_task_context
            base_task_context=$(get_project_kind_prompt "$project_kind" "documentation_specialist" "task_context")
            # Include changed files in task_context with proper formatting
            task_context="**Task**: Update documentation based on recent code changes

**Changes Detected**:
${changed_files}

**Specific Instructions**:
${base_task_context}"
            approach=$(get_project_kind_prompt "$project_kind" "documentation_specialist" "approach")
        else
            print_info "Project kind is generic - using standard prompt" >&2
            prompt_type="generic"
        fi
    else
        print_info "Project kind config not found - using generic prompt" >&2
        prompt_type="generic"
    fi

    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then

        #IF role is still empty, extract from doc_analysis_prompt section   
        if [[ -z "$role" ]]; then
            # Try new compose function for token efficiency (supports YAML anchors)
            role=$(compose_role_from_yaml "$yaml_file" "doc_analysis_prompt" 2>/dev/null)
            
            # Fallback: legacy extraction if compose fails
            if [[ -z "$role" ]]; then
                role=$(awk '/^doc_analysis_prompt:/,/^  task/ {
                    if (/role: \|/) { in_role=1; next }
                    if (in_role && /^  [a-z]/) { exit }
                    if (in_role && /^    /) { 
                        sub(/^    /, ""); 
                        if (NR > 1) printf "\n";
                        printf "%s", $0
                    }
                }' "$yaml_file")
                
                # Double fallback: try quoted format
                if [[ -z "$role" ]]; then
                    role=$(sed -n '/^doc_analysis_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
                fi
            fi
        fi
        
        # If task_context is still empty, extract task_template from YAML
        if [[ -z "$task_context" ]]; then
            task_template=$(awk '/task_template: \|/{flag=1; next} /^[[:space:]]*approach:/{flag=0} flag && /^[[:space:]]{4}/' "$yaml_file" | sed 's/^[[:space:]]*//')
        fi
        
        # If approach is still empty, extract from doc_analysis_prompt section
        if [[ -z "$approach" ]]; then
            approach=$(awk '/approach: \|/{flag=1; next} /^$/{if(flag) exit} flag && /^[[:space:]]{4}/' "$yaml_file" | sed 's/^[[:space:]]*//')
        fi
        
        # Build task from template or use task_context directly
        # Priority: task_context (project-kind aware + enhanced) > task_template > fallback
        local task
        if [[ -n "$task_context" ]]; then
            # Use task_context from project kind (already includes changed files + enhancements)
            task="${task_context}

**Documentation Files to Review**:
${doc_files}

**Required Actions** (Complete ALL steps):
1. Review each documentation file for accuracy against code changes
2. Update any outdated sections, examples, or references
3. Ensure consistency across all documentation
4. Verify cross-references and links are still valid
5. Update version numbers if applicable
6. Maintain existing style and formatting

**Default Action**: If changes are widespread and not specifically code-related, focus on:
- Validating all documentation is still accurate
- Checking for broken references or outdated information
- Ensuring consistency in terminology and formatting
- NO changes are needed if documentation is already accurate

**Output Format**: Provide specific changes as unified diffs or describe what needs updating."
        elif [[ -n "$task_template" ]]; then
            # Use task_template from YAML (legacy support)
            task="${task_template//\{changed_files\}/$changed_files}"
            task="${task//\{doc_files\}/$doc_files}"
        else
            # Enhanced fallback task with clearer instructions and default action
            task="**Documentation Update Request**

**Changed Files**:
${changed_files}

**Documentation to Review and Update**:
${doc_files}

**PRIMARY TASK**: 
Review the listed documentation files and determine if they need updates based on the changed files above.

**Step-by-Step Instructions**:
1. **Analyze Changes**: Review what changed in the code/documentation files
2. **Identify Impact**: Determine which documentation sections are affected
3. **Make Updates**: Update ONLY the specific sections that are outdated or incorrect
4. **Validate References**: Ensure all cross-references, examples, and links remain valid
5. **Maintain Style**: Keep consistent terminology, formatting, and writing style

**When to Update vs. Not Update**:
- ✅ UPDATE if: Code behavior changed, APIs modified, new features added, examples are outdated
- ❌ DON'T UPDATE if: Documentation is already accurate and complete
- ⚠️  NOTE: Many file changes doesn't always mean documentation needs changes

**Default Action for Widespread Changes**:
If the changeset is large and documentation-focused (not code changes):
1. Validate existing documentation is still accurate
2. Check for consistency across all docs
3. Report \"No updates needed\" if documentation is already correct
4. Only update if you find actual inaccuracies

**Output Format Required**:
Provide one of:
- Specific documentation updates as unified diffs
- List of files with descriptions of needed changes
- Statement \"No documentation updates needed\" with brief explanation

**Important**: Be specific and surgical - don't suggest changes just because files were modified. Only update if documentation is actually incorrect or incomplete."
        fi
        
        # Expand language-specific placeholders in approach if present
        if echo "$approach" | grep -q "{language_specific_documentation}"; then
            local primary_language="${PRIMARY_LANGUAGE:-}"
            local language_standards=""
            
            # Try to get language-specific documentation standards
            if [[ -n "$primary_language" ]]; then
                # Source ai_prompt_builder if available for language-specific content
                local prompt_builder="${AI_HELPERS_DIR}/ai_prompt_builder.sh"
                if [[ -f "$prompt_builder" ]]; then
                    # shellcheck source=./ai_prompt_builder.sh
                    source "$prompt_builder"
                    language_standards=$(get_language_specific_content "$yaml_file" "language_specific_documentation" "$primary_language" 2>/dev/null || echo "")
                fi
            fi
            
            if [[ -n "$language_standards" ]]; then
                approach="${approach//\{language_specific_documentation\}/$language_standards}"
            else
                approach="${approach//\{language_specific_documentation\}/No language-specific standards available}"
            fi
        fi
        
        build_ai_prompt "$role" "$task" "$approach"
        
        # Display prompt type indicator (to stderr to avoid capturing in prompt variable)
        echo "" >&2
        print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
        if [[ "$prompt_type" == "generic" ]]; then
            print_warning "📋 Prompt Type: GENERIC (no project kind customization)" >&2
        else
            print_success "🎯 Prompt Type: ${prompt_type^^}" >&2
        fi
        print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
        echo "" >&2
    else
        # Fallback to hardcoded strings if YAML not available
        prompt_type="generic (yaml not found)"
        print_warning "YAML config not available - using hardcoded generic prompt" >&2
        build_ai_prompt \
            "You are a senior technical documentation specialist with expertise in software architecture documentation, API documentation, and developer experience (DX) optimization." \
            "Based on the recent changes to the following files: ${changed_files}

Please update all related documentation including:
1. .github/copilot-instructions.md - Update project overview, architecture patterns, key files
2. README.md - Update if public-facing features or setup instructions changed
3. /docs/ directory - Update technical documentation for architecture or feature changes
4. Component/module README files - Update if code structure or APIs were modified
5. Inline code comments - Add/update comments for complex logic

Documentation to review: ${doc_files}" \
            "- Analyze the git diff to understand what changed
- Update only the documentation sections affected by these changes
- Be surgical and precise - don't modify unrelated documentation
- Ensure consistency in terminology, formatting, and style
- Maintain professional technical writing standards"
        
        # Display prompt type for hardcoded fallback (to stderr)
        echo "" >&2
        print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
        print_warning "📋 Prompt Type: ${prompt_type^^}" >&2
        print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
        echo "" >&2
    fi
}

# Build a consistency analysis prompt
# Usage: build_consistency_prompt <files_to_check>
# Step 2: Build a documentation consistency analysis prompt
build_consistency_prompt() {
    local files_to_check="$1"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from consistency_prompt section (use sed with line numbers)
        role=$(sed -n '/^consistency_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template
        task_template=$(sed -n '/^consistency_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^consistency_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /approach: \|/ {flag=1; next}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Replace placeholders in task template
        local task="${task_template//\{files_to_check\}/$files_to_check}"
        
        build_ai_prompt "$role" "$task" "$approach"
    else
        # Fallback to hardcoded strings if YAML not available
        build_ai_prompt \
            "You are a documentation specialist and information architect with expertise in content consistency, cross-reference validation, and documentation quality assurance." \
            "Perform a deep consistency analysis across the following documentation files: ${files_to_check}

Check for:
1. **Cross-Reference Accuracy** - All links and references point to correct locations
2. **Version Consistency** - Version numbers match across all files
3. **Terminology Consistency** - Same concepts use same terms throughout
4. **Format Consistency** - Headings, lists, code blocks follow same patterns
5. **Content Completeness** - No missing sections or incomplete information" \
            "- Read all documentation files thoroughly
- Create a comprehensive consistency report
- Identify specific inconsistencies with file names and line numbers
- Suggest fixes for each inconsistency found
- Prioritize issues by severity (Critical, High, Medium, Low)"
    fi
}

# Build a test strategy analysis prompt
# Usage: build_test_strategy_prompt <coverage_stats> <test_files>
build_test_strategy_prompt() {
    local coverage_stats="$1"
    local test_files="$2"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from test_strategy_prompt section
        role=$(sed -n '/^test_strategy_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template
        task_template=$(sed -n '/^test_strategy_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^test_strategy_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /approach: \|/ {flag=1; next}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Replace placeholders in task template
        local task="${task_template//\{coverage_stats\}/$coverage_stats}"
        task="${task//\{test_files\}/$test_files}"
        
        build_ai_prompt "$role" "$task" "$approach"
    else
        # Fallback to hardcoded strings if YAML not available
        build_ai_prompt \
            "You are a QA engineer and test automation specialist with expertise in test strategy, coverage analysis, and test-driven development (TDD)." \
            "Based on the current test coverage statistics: ${coverage_stats}

And existing test files: ${test_files}

Recommend:
1. **New tests to generate** - Identify untested or undertested code paths
2. **Test improvements** - Suggest enhancements to existing tests
3. **Coverage gaps** - Highlight areas with low or missing coverage
4. **Test patterns** - Recommend best practices for this codebase" \
            "- Analyze coverage reports to identify gaps
- Consider edge cases and error scenarios
- Recommend specific test cases with clear descriptions
- Prioritize tests by importance and coverage impact
- Follow Jest testing patterns and best practices"
    fi
}

# Build a code quality validation prompt
# Usage: build_quality_prompt <files_to_review>
build_quality_prompt() {
    local files_to_review="$1"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from quality_prompt section
        role=$(sed -n '/^quality_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template
        task_template=$(sed -n '/^quality_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^quality_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /approach: \|/ {flag=1; next}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Replace placeholders in task template
        local task="${task_template//\{files_to_review\}/$files_to_review}"
        
        build_ai_prompt "$role" "$task" "$approach"
    else
        # Fallback to hardcoded strings if YAML not available
        build_ai_prompt \
            "You are a software quality engineer and code review specialist with expertise in code quality standards, best practices, and maintainability." \
            "Review the following files for code quality: ${files_to_review}

Analyze:
1. **Code Organization** - Logical structure and separation of concerns
2. **Naming Conventions** - Clear, consistent, and descriptive names
3. **Error Handling** - Proper error handling and edge cases
4. **Documentation** - Inline comments and function documentation
5. **Best Practices** - Following language-specific best practices
6. **Potential Issues** - Security concerns, performance issues, bugs" \
            "- Review each file systematically
- Identify specific issues with file names and line numbers
- Suggest concrete improvements
- Prioritize findings by severity
- Provide code examples for recommended fixes"
    fi
}

# Build an issue extraction prompt for Copilot session logs
# Usage: build_issue_extraction_prompt <log_file> <log_content>
build_issue_extraction_prompt() {
    local log_file="$1"
    local log_content="$2"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from issue_extraction_prompt section
        role=$(sed -n '/^issue_extraction_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template
        task_template=$(sed -n '/^issue_extraction_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^issue_extraction_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /approach: \|/ {flag=1; next}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Replace placeholders in task template
        local task="${task_template//\{log_file\}/$log_file}"
        task="${task//\{log_content\}/$log_content}"
        
        build_ai_prompt "$role" "$task" "$approach"
    else
        # Fallback to hardcoded strings if YAML not available
        build_ai_prompt \
            "You are a technical project manager specialized in issue extraction, categorization, and documentation organization." \
            "Analyze the following GitHub Copilot session log from a documentation update workflow and extract all issues, recommendations, and action items.

**Session Log File**: ${log_file}

**Log Content**:
\`\`\`
${log_content}
\`\`\`

**Required Output Format**:
### Critical Issues
- [Issue description with priority and affected files]

### High Priority Issues
- [Issue description with priority and affected files]

### Medium Priority Issues
- [Issue description with priority and affected files]

### Low Priority Issues
- [Issue description with priority and affected files]

### Recommendations
- [Improvement suggestions]" \
            "- Extract all issues, warnings, and recommendations from the log
- Categorize by severity and impact
- Include affected files/sections mentioned in the log
- Prioritize actionable items
- Add context where needed
- If no issues found, state 'No issues identified'"
    fi
}

# Build a documentation consistency analysis prompt (Step 2)
# Usage: build_step2_consistency_prompt <doc_count> <change_scope> <modified_count> <broken_refs> <doc_files>
build_step2_consistency_prompt() {
    local doc_count="$1"
    local change_scope="$2"
    local modified_count="$3"
    local broken_refs_content="$4"
    local doc_files="$5"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from step2_consistency_prompt section
        role=$(sed -n '/^step2_consistency_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template
        task_template=$(sed -n '/^step2_consistency_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^step2_consistency_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /approach: \|/ {flag=1; next}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Get project metadata
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        # Replace placeholders in task template
        local task="${task_template//\{doc_count\}/$doc_count}"
        task="${task//\{change_scope\}/$change_scope}"
        task="${task//\{modified_count\}/$modified_count}"
        task="${task//\{broken_refs_content\}/$broken_refs_content}"
        task="${task//\{doc_files\}/$doc_files}"
        task="${task//\{project_name\}/$project_name}"
        task="${task//\{project_description\}/$project_description}"
        task="${task//\{primary_language\}/$primary_language}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        # Get project metadata for dynamic context
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        cat << EOF
**Role**: You are a senior technical documentation specialist and information architect with expertise in documentation quality assurance, technical writing standards, and cross-reference validation.

**Task**: Perform a comprehensive documentation consistency analysis for this project.

**Context:**
- Project: ${project_name} (${project_description})
- Primary Language: ${primary_language}
- Documentation files: ${doc_count} markdown files
- Scope: ${change_scope}
- Recent changes: ${modified_count} files modified

**Analysis Tasks:**

1. **Cross-Reference Validation:**
   - Check if all referenced files/directories exist
   - Verify version numbers follow semantic versioning (MAJOR.MINOR.PATCH)
   - Ensure version consistency across documentation and package.json
   - Validate command examples match actual scripts

2. **Content Synchronization:**
   - Compare primary documentation files (README, copilot-instructions)
   - Check if module/component docs match actual code structure
   - Verify build/package configuration matches documented commands

3. **Architecture Consistency:**
   - Validate directory structure matches documented structure
   - Check if deployment steps in docs match actual deployment scripts
   - Verify submodule references are accurate

4. **Broken References Found:**
${broken_refs_content}

5. **Quality Checks:**
   - Missing documentation for new features
   - Outdated version numbers or dates
   - Inconsistent terminology or naming conventions
   - Missing cross-references between related docs

**Files to Analyze:**
${doc_files}

**Expected Output:**
- List of inconsistencies found with specific file:line references
- Recommendations for fixes with rationale
- Priority level (Critical/High/Medium/Low) for each issue
- Actionable remediation steps

**Documentation Standards to Apply:**
- Technical accuracy and precision
- Consistency in terminology and formatting
- Completeness of cross-references
- Version number accuracy across all files

Please analyze the documentation files and provide a detailed consistency report.
EOF
    fi
}

# Build a shell script reference validation prompt (Step 3)
# Usage: build_step3_script_refs_prompt <script_count> <change_scope> <issues> <script_issues> <all_scripts> <modified_count>
build_step3_script_refs_prompt() {
    local script_count="$1"
    local change_scope="$2"
    local issues="$3"
    local script_issues_content="$4"
    local all_scripts="$5"
    local modified_count="${6:-0}"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from step3_script_refs_prompt section
        role=$(sed -n '/^step3_script_refs_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template
        task_template=$(sed -n '/^step3_script_refs_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^step3_script_refs_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /approach: \|/ {flag=1; next}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Get project metadata
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        # Replace placeholders in task template
        local task="${task_template//\{script_count\}/$script_count}"
        task="${task//\{change_scope\}/$change_scope}"
        task="${task//\{issues\}/$issues}"
        task="${task//\{script_issues_content\}/$script_issues_content}"
        task="${task//\{all_scripts\}/$all_scripts}"
        task="${task//\{project_name\}/$project_name}"
        task="${task//\{project_description\}/$project_description}"
        task="${task//\{primary_language\}/$primary_language}"
        task="${task//\{scripts_dir\}/${SHELL_SCRIPTS_DIR:-scripts}}"
        task="${task//\{modified_count\}/$modified_count}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        # Get project metadata for dynamic context
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        cat << EOF
**Role**: You are a senior technical documentation specialist and DevOps documentation expert with expertise in shell script documentation, automation workflow documentation, and command-line tool reference guides.

**Task**: Perform comprehensive validation of shell script references and documentation quality for this project's automation scripts.

**Context:**
- Project: ${project_name} (${project_description})
- Primary Language: ${primary_language}
- Shell Scripts Directory: ${SHELL_SCRIPTS_DIR:-scripts}
- Total Scripts: ${script_count}
- Scope: ${change_scope}
- Modified Files: ${modified_count}
- Issues Found in Phase 1: ${issues}

**Phase 1 Automated Findings:**
${script_issues_content}

**Available Scripts:**
${all_scripts}

**Validation Tasks:**

1. **Script-to-Documentation Mapping:**
   - Verify every executable script in the project is documented in project README or script documentation
   - Check that documented scripts/executables actually exist at specified paths
   - Validate script descriptions match actual functionality
   - Ensure usage examples are accurate and complete

2. **Reference Accuracy:**
   - Validate command-line arguments in documentation match script implementation
   - Check script version numbers are consistent
   - Verify cross-references between scripts are accurate
   - Validate file path references in script comments

3. **Documentation Completeness:**
   - Missing purpose/description for any scripts
   - Missing usage examples or command syntax
   - Missing prerequisite or dependency information
   - Missing output/return value documentation

4. **Script Best Practices (Project-Specific):**
   - Executable permissions properly documented
   - Entry points (shebangs, main functions) mentioned in documentation where relevant
   - Environment variable requirements documented
   - Error handling and exit codes documented

5. **Integration Documentation:**
   - Workflow relationships between components documented
   - Execution order or dependencies clarified
   - Common use cases and examples provided
   - Troubleshooting guidance available

6. **DevOps Integration Documentation** (when applicable):
   - CI/CD pipeline references (GitHub Actions, Jenkins, GitLab CI, CircleCI)
   - Container/orchestration scripts (Docker, Kubernetes manifests, docker-compose)
   - Deployment automation documentation (deploy scripts, infrastructure provisioning)
   - Infrastructure-as-code script references (Terraform, Ansible, CloudFormation)
   - Monitoring/observability script documentation (health checks, metrics collection)
   - Build/release automation scripts (packaging, versioning, artifact management)

**Files to Analyze:**
- Project README.md and any module/component README files
- All executable files (shell scripts, Python scripts, Node.js scripts, etc.)
- .github/copilot-instructions.md (for automation/script references)
- Configuration files that define entry points or commands
- CI/CD configuration files (.github/workflows/, .gitlab-ci.yml, Jenkinsfile, .circleci/)

**Expected Output:**
- List of script reference issues with file:line locations
- Missing or incomplete script documentation
- Inconsistencies between code and documentation
- Recommendations for improving script documentation
- Priority level (Critical/High/Medium/Low) for each issue
- Actionable remediation steps with examples

**Documentation Standards to Apply:**
- Clear and concise command syntax documentation
- Comprehensive usage examples for each script
- Accurate parameter and option descriptions
- Proper shell script documentation conventions
- Integration and workflow clarity

Please analyze the shell script references and provide a detailed validation report with specific recommendations for documentation improvements.
EOF
    fi
}

# Build a directory structure validation prompt (Step 4)
# Usage: build_step4_directory_prompt <dir_count> <change_scope> <missing_critical> <undocumented_dirs> <doc_mismatch> <structure_issues> <dir_tree> [modified_count]
build_step4_directory_prompt() {
    local dir_count="$1"
    local change_scope="$2"
    local missing_critical="$3"
    local undocumented_dirs="$4"
    local doc_structure_mismatch="$5"
    local structure_issues_content="$6"
    local dir_tree="$7"
    local modified_count="${8:-0}"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    # Calculate modified_count if not provided or is 0
    if [[ "$modified_count" == "0" ]] && command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null 2>&1; then
        modified_count=$(git diff --name-only 2>/dev/null | wc -l || echo "0")
    fi
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from step4_directory_prompt section
        role=$(sed -n '/^step4_directory_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template
        task_template=$(sed -n '/^step4_directory_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^step4_directory_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /approach: \|/ {flag=1; next}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Get project metadata
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        # Replace placeholders in task template
        local task="${task_template//\{dir_count\}/$dir_count}"
        task="${task//\{change_scope\}/$change_scope}"
        task="${task//\{missing_critical\}/$missing_critical}"
        task="${task//\{undocumented_dirs\}/$undocumented_dirs}"
        task="${task//\{doc_structure_mismatch\}/$doc_structure_mismatch}"
        task="${task//\{structure_issues_content\}/$structure_issues_content}"
        task="${task//\{dir_tree\}/$dir_tree}"
        task="${task//\{project_name\}/$project_name}"
        task="${task//\{project_description\}/$project_description}"
        task="${task//\{primary_language\}/$primary_language}"
        task="${task//\{modified_count\}/$modified_count}"
        
        # Handle language-specific directory standards if present
        if echo "$task" | grep -q "{language_specific_directory_standards}"; then
            # Source ai_prompt_builder if available
            local prompt_builder="${AI_HELPERS_DIR}/ai_prompt_builder.sh"
            if [[ -f "$prompt_builder" ]]; then
                # shellcheck source=./ai_prompt_builder.sh
                source "$prompt_builder"
                local dir_standards
                dir_standards=$(get_language_specific_content "$yaml_file" "language_specific_directory" "$primary_language" 2>/dev/null || echo "")
                if [[ -n "$dir_standards" ]]; then
                    # Replace the placeholder with the content (preserving indentation)
                    task=$(echo "$task" | awk -v repl="$dir_standards" '
                        /{language_specific_directory_standards}/ {
                            indent = match($0, /[^ ]/)
                            gsub(/{language_specific_directory_standards}/, "")
                            if (indent > 1) {
                                spaces = substr($0, 1, indent-1)
                                # Print each line of replacement with proper indentation
                                n = split(repl, lines, "\n")
                                for (i=1; i<=n; i++) {
                                    if (lines[i] != "") print spaces lines[i]
                                }
                            } else {
                                print repl
                            }
                            next
                        }
                        { print }
                    ')
                else
                    # If no language-specific standards found, just remove the placeholder
                    task="${task//\{language_specific_directory_standards\}/}"
                fi
            else
                # If prompt builder not available, just remove the placeholder
                task="${task//\{language_specific_directory_standards\}/}"
            fi
        fi
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        # Get project metadata for dynamic context
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        cat << EOF
**Role**: You are a senior software architect and technical documentation specialist with expertise in project structure conventions, architectural patterns, code organization best practices, and documentation alignment.

**Task**: Perform comprehensive validation of directory structure and architectural organization for this project.

**Context:**
- Project: ${project_name} (${project_description})
- Primary Language: ${primary_language}
- Total Directories: ${dir_count} (excluding node_modules, .git, coverage)
- Scope: ${change_scope}
- Modified Files: ${modified_count}
- Critical Directories Missing: ${missing_critical}
- Undocumented Directories: ${undocumented_dirs}
- Documentation Mismatches: ${doc_structure_mismatch}

**Phase 1 Automated Findings:**
${structure_issues_content}

**Current Directory Structure:**
${dir_tree}

**Validation Tasks:**

1. **Structure-to-Documentation Mapping:**
   - Verify directory structure matches documented architecture
   - Check that README.md and .github/copilot-instructions.md describe actual structure
   - Validate directory purposes are clearly documented
   - Ensure new directories have documentation explaining their role

2. **Architectural Pattern Validation:**
   - Assess if directory organization follows web development best practices
   - Validate separation of concerns (src/, public/, docs/, etc.)
   - Check for proper asset organization (images/, styles/, scripts/)
   - Verify submodule structure is logical and documented

3. **Naming Convention Consistency:**
   - Validate directory names follow consistent conventions
   - Check for naming pattern consistency across similar directories
   - Verify no ambiguous or confusing directory names
   - Ensure directory names are descriptive and self-documenting

4. **Best Practice Compliance:**
   - Static site project structure conventions
   - Source vs distribution directory separation (src/ vs public/)
   - Documentation organization (docs/ location and structure)
   - Configuration file locations (.github/, root config files)
   - Build artifact locations (coverage/, node_modules/)

5. **Scalability and Maintainability Assessment:**
   - Directory depth appropriate (not too deep or too flat)
   - Related files properly grouped
   - Clear boundaries between modules/components
   - Easy to navigate structure for new developers
   - Potential restructuring recommendations

**Expected Output:**
- List of structure issues with specific directory paths
- Documentation mismatches (documented but missing, or undocumented but present)
- Architectural pattern violations or inconsistencies
- Naming convention issues
- Best practice recommendations
- Priority level (Critical/High/Medium/Low) for each issue
- Actionable remediation steps with rationale
- Suggested restructuring if needed (with migration impact assessment)

Please analyze the directory structure and provide a detailed architectural validation report.
EOF
    fi
}

# Build a test review and recommendations prompt (Step 5)
# Usage: build_step5_test_review_prompt <test_framework> <test_env> <test_count> <code_files> <tests_in_dir> <tests_colocated> <coverage_exists> <test_issues> <test_files>
build_step5_test_review_prompt() {
    local test_framework="$1"
    local test_env="$2"
    local test_count="$3"
    local code_files="$4"
    local tests_in_tests_dir="$5"
    local tests_colocated="$6"
    local coverage_exists="$7"
    local test_issues_content="$8"
    local test_files="$9"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from step5_test_review_prompt section
        role=$(sed -n '/^step5_test_review_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template
        task_template=$(sed -n '/^step5_test_review_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^step5_test_review_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /approach: \|/ {flag=1; next}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Get project metadata
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        # Replace placeholders in task template
        local task="${task_template//\{test_framework\}/$test_framework}"
        task="${task//\{test_env\}/$test_env}"
        task="${task//\{test_count\}/$test_count}"
        task="${task//\{code_files\}/$code_files}"
        task="${task//\{tests_in_tests_dir\}/$tests_in_tests_dir}"
        task="${task//\{tests_colocated\}/$tests_colocated}"
        task="${task//\{coverage_exists\}/$coverage_exists}"
        task="${task//\{test_issues_content\}/$test_issues_content}"
        task="${task//\{test_files\}/$test_files}"
        task="${task//\{project_name\}/$project_name}"
        task="${task//\{project_description\}/$project_description}"
        task="${task//\{primary_language\}/$primary_language}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        # Get project metadata for dynamic context
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        cat << EOF
**Role**: You are a senior QA engineer and test automation specialist with expertise in testing strategies, Jest framework, code coverage analysis, test-driven development (TDD), behavior-driven development (BDD), and continuous integration best practices.

**Task**: Perform comprehensive review of existing tests and provide recommendations for test generation and coverage improvement.

**Context:**
- Project: ${project_name} (${project_description})
- Primary Language: ${primary_language}
- Test Framework: ${test_framework}
- Test Environment: ${test_env}
- Total Test Files: ${test_count}
- Code Files: ${code_files}
- Tests in __tests__/: ${tests_in_tests_dir}
- Co-located Tests: ${tests_colocated}
- Coverage Report Available: ${coverage_exists}

**Phase 1 Automated Findings:**
${test_issues_content}

**Existing Test Files:**
${test_files}

**Test Configuration (from package.json):**
- Test Command: npm test (with experimental VM modules for ES6)
- Test Environment: jsdom (for DOM testing)
- Coverage: Available via npm run test:coverage
- Watch Mode: Available for development

**Analysis Tasks:**

1. **Existing Test Quality Assessment:**
   - Review test file naming conventions (should match *.test.js pattern)
   - Assess test organization (__tests__/ directory vs co-located)
   - Evaluate test structure (describe blocks, test cases, assertions)
   - Check for proper use of Jest matchers and assertions
   - Validate async/await handling in tests

2. **Coverage Gap Identification:**
   - Identify which JavaScript modules/functions lack tests
   - Determine critical paths that need test coverage
   - Assess edge cases and error handling coverage
   - Evaluate DOM manipulation test coverage
   - Check for integration test coverage

3. **Test Case Generation Recommendations:**
   - Suggest specific test cases for untested code
   - Recommend unit tests for utility functions
   - Propose integration tests for workflows
   - Suggest DOM manipulation tests for UI components
   - Recommend edge case and error scenario tests

4. **Testing Best Practices Validation:**
   - Test isolation and independence
   - Proper setup/teardown (beforeEach, afterEach)
   - Mock usage for external dependencies
   - Assertion clarity and specificity
   - Test naming conventions (should describe behavior)
   - DRY principle in tests

5. **CI/CD Integration Readiness:**
   - Tests run in CI environment compatibility
   - Test execution speed (avoid slow tests)
   - Deterministic tests (no flakiness)
   - Coverage threshold recommendations
   - Pre-commit hook integration

**Expected Output:**
- List of test quality issues with specific file:line references
- Coverage gaps with priority (Critical/High/Medium/Low)
- Specific test case recommendations with examples
- Missing test scenarios for each untested module
- Code snippets for recommended tests
- Best practice violations and fixes
- CI/CD integration recommendations
- Coverage improvement action plan

**Testing Standards to Apply:**
- Jest best practices for ES Modules
- AAA pattern (Arrange-Act-Assert)
- Clear test descriptions (behavior-focused)
- Proper async/await handling
- Mock isolation for unit tests
- Integration test coverage for workflows
- Minimum 80% code coverage target

Please analyze the existing tests and provide a detailed test strategy report with specific, actionable recommendations for improving test coverage and quality.
EOF
    fi
}

# Build a test execution analysis prompt (Step 7)
# Usage: build_step7_test_exec_prompt <test_exit_code> <tests_total> <tests_passed> <tests_failed> <exec_summary> <test_output> <failed_tests>
build_step7_test_exec_prompt() {
    local test_exit_code="$1"
    local tests_total="$2"
    local tests_passed="$3"
    local tests_failed="$4"
    local execution_summary="$5"
    local test_output="$6"
    local failed_test_list="$7"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from step7_test_exec_prompt section
        role=$(sed -n '/^step7_test_exec_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template
        task_template=$(sed -n '/^step7_test_exec_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^step7_test_exec_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /approach: \|/ {flag=1; next}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Get project metadata
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        # Replace placeholders in task template
        local task="${task_template//\{test_exit_code\}/$test_exit_code}"
        task="${task//\{tests_total\}/$tests_total}"
        task="${task//\{tests_passed\}/$tests_passed}"
        task="${task//\{tests_failed\}/$tests_failed}"
        task="${task//\{execution_summary\}/$execution_summary}"
        task="${task//\{test_output\}/$test_output}"
        task="${task//\{failed_test_list\}/$failed_test_list}"
        task="${task//\{project_name\}/$project_name}"
        task="${task//\{project_description\}/$project_description}"
        task="${task//\{primary_language\}/$primary_language}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        # Get project metadata for dynamic context
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        cat << EOF
**Role**: You are a senior CI/CD engineer and test results analyst with expertise in test execution diagnostics, failure root cause analysis, code coverage interpretation, performance optimization, and continuous integration best practices.

**Task**: Analyze test execution results, diagnose failures, and provide actionable recommendations for improving test suite quality and CI/CD integration.

**Context:**
- Project: ${project_name} (${project_description})
- Primary Language: ${primary_language}
- Test Framework: Jest with ES Modules (experimental-vm-modules)
- Test Command: npm run test:coverage
- Exit Code: ${test_exit_code}
- Total Tests: ${tests_total}
- Passed: ${tests_passed}
- Failed: ${tests_failed}

**Test Execution Results:**
${execution_summary}

**Test Output:**
${test_output}

**Failed Tests:**
${failed_test_list}

**Analysis Tasks:**

1. **Test Failure Root Cause Analysis:**
   - Identify why tests failed (assertion errors, runtime errors, timeouts)
   - Determine if failures are code bugs or test issues
   - Categorize failures (breaking changes, environment issues, flaky tests)
   - Provide specific fix recommendations for each failure
   - Priority level (Critical/High/Medium/Low) for each failure

2. **Coverage Gap Interpretation:**
   - Analyze coverage metrics (statements, branches, functions, lines)
   - Identify which modules have low coverage
   - Determine if coverage meets 80% target
   - Recommend areas for additional test coverage
   - Prioritize coverage improvements

3. **Performance Bottleneck Detection:**
   - Identify slow-running tests (if timing data available)
   - Detect tests with heavy setup/teardown
   - Find tests that could be parallelized
   - Recommend test execution optimizations
   - Suggest mocking strategies for faster tests

4. **Flaky Test Identification:**
   - Detect non-deterministic test behavior
   - Identify timing-dependent tests
   - Find tests with external dependencies
   - Recommend fixes for flaky tests
   - Suggest test isolation improvements

5. **CI/CD Optimization Recommendations:**
   - Suggest test splitting strategies for CI
   - Recommend caching strategies
   - Propose pre-commit hook configurations
   - Suggest coverage thresholds for CI gates
   - Recommend test parallelization approaches

**Expected Output:**
- Root cause analysis for each failure with file:line:test references
- Specific code fixes or test modifications needed
- Coverage improvement action plan
- Performance optimization recommendations
- Flaky test remediation steps
- CI/CD integration best practices
- Priority-ordered action items
- Estimated effort for each fix

Please provide a comprehensive test results analysis with specific, actionable recommendations.
EOF
    fi
}

# Build a dependency management analysis prompt (Step 8)
# Usage: build_step8_dependencies_prompt <node_version> <npm_version> <dep_count> <dev_dep_count> <total_deps> <dep_summary> <dep_report> <prod_deps> <dev_deps> <audit_summary> <outdated_list>
build_step8_dependencies_prompt() {
    local node_version="$1"
    local npm_version="$2"
    local dep_count="$3"
    local dev_dep_count="$4"
    local total_deps="$5"
    local dependency_summary="$6"
    local dependency_report_content="$7"
    local prod_deps="$8"
    local dev_deps="$9"
    local audit_summary="${10}"
    local outdated_list="${11}"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from step8_dependencies_prompt section
        role=$(sed -n '/^step8_dependencies_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template
        task_template=$(sed -n '/^step8_dependencies_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^step8_dependencies_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /approach: \|/ {flag=1; next}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Get project metadata
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        # Replace placeholders in task template
        local task="${task_template//\{node_version\}/$node_version}"
        task="${task//\{npm_version\}/$npm_version}"
        task="${task//\{dep_count\}/$dep_count}"
        task="${task//\{dev_dep_count\}/$dev_dep_count}"
        task="${task//\{total_deps\}/$total_deps}"
        task="${task//\{dependency_summary\}/$dependency_summary}"
        task="${task//\{dependency_report_content\}/$dependency_report_content}"
        task="${task//\{prod_deps\}/$prod_deps}"
        task="${task//\{dev_deps\}/$dev_deps}"
        task="${task//\{audit_summary\}/$audit_summary}"
        task="${task//\{project_name\}/$project_name}"
        task="${task//\{project_description\}/$project_description}"
        task="${task//\{primary_language\}/$primary_language}"
        task="${task//\{outdated_list\}/$outdated_list}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        # Get project metadata for dynamic context
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        cat << EOF
**Role**: You are a senior DevOps engineer and package management specialist with expertise in npm/yarn ecosystem, security vulnerability assessment, version compatibility analysis, dependency tree optimization, and environment configuration best practices.

**Task**: Analyze project dependencies, assess security risks, evaluate version compatibility, and provide recommendations for dependency management and environment setup.

**Context:**
- Project: ${project_name} (${project_description})
- Primary Language: ${primary_language}
- Package Manager: npm
- Node.js Version: ${node_version}
- npm Version: ${npm_version}
- Production Dependencies: ${dep_count}
- Development Dependencies: ${dev_dep_count}
- Total Packages: ${total_deps}

**Dependency Analysis Results:**
${dependency_summary}

**Automated Findings:**
${dependency_report_content}

**Production Dependencies:**
${prod_deps}

**Development Dependencies:**
${dev_deps}

**npm Audit Summary:**
${audit_summary}

**Outdated Packages:**
${outdated_list}

**Analysis Tasks:**

1. **Security Vulnerability Assessment:**
   - Review npm audit results
   - Identify critical/high severity vulnerabilities
   - Assess exploitability and impact
   - Provide immediate remediation steps
   - Recommend long-term security strategy
   - Consider transitive dependencies

2. **Version Compatibility Analysis:**
   - Check for breaking changes in outdated packages
   - Identify version conflicts
   - Assess compatibility with Node.js version
   - Review semver ranges (^, ~, exact versions)
   - Recommend version pinning strategy

3. **Dependency Tree Optimization:**
   - Identify unused dependencies
   - Detect duplicate packages in tree
   - Find opportunities to reduce bundle size
   - Recommend consolidation strategies
   - Suggest peer dependency resolution

4. **Environment Configuration Review:**
   - Validate Node.js version compatibility
   - Check npm version requirements
   - Review engine specifications in package.json
   - Assess development vs production dependencies
   - Recommend .nvmrc or .node-version file

5. **Update Strategy Recommendations:**
   - Prioritize updates (security > bug fixes > features)
   - Create phased update plan
   - Identify breaking changes to watch
   - Recommend testing strategy for updates
   - Suggest automation (Dependabot, Renovate)

**Expected Output:**
- Security vulnerability assessment with severity levels
- Immediate action items for critical vulnerabilities
- Safe update path for outdated packages
- Version compatibility matrix
- Dependency optimization recommendations
- Environment configuration best practices
- Automated dependency management setup
EOF
    fi
}

# Build a code quality assessment prompt (Step 9)
# Usage: build_step9_code_quality_prompt <total_files> <js_files> <html_files> <css_files> <quality_summary> <quality_report> <large_files> <sample_code>
# Phase 4: Now includes language-aware enhancements
build_step9_code_quality_prompt() {
    local total_files="$1"
    local js_files="$2"
    local html_files="$3"
    local css_files="$4"
    local quality_summary="$5"
    local quality_report_content="$6"
    local large_files_list="$7"
    local sample_code="$8"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    local language="${PRIMARY_LANGUAGE:-javascript}"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from step9_code_quality_prompt section
        role=$(sed -n '/^step9_code_quality_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template
        task_template=$(sed -n '/^step9_code_quality_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^step9_code_quality_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /approach: \|/ {flag=1; next}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Format large files list (handle both echo and direct variable)
        local formatted_large_files
        if [[ -n "$large_files_list" ]]; then
            formatted_large_files=$(echo -e "${large_files_list}" | head -10 || echo "None")
        else
            formatted_large_files="None"
        fi
        
        # Get project metadata
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        # Replace placeholders in task template
        local task="${task_template//\{total_files\}/$total_files}"
        task="${task//\{js_files\}/$js_files}"
        task="${task//\{html_files\}/$html_files}"
        task="${task//\{css_files\}/$css_files}"
        task="${task//\{quality_summary\}/$quality_summary}"
        task="${task//\{quality_report_content\}/$quality_report_content}"
        task="${task//\{large_files_list\}/$formatted_large_files}"
        task="${task//\{sample_code\}/$sample_code}"
        task="${task//\{project_name\}/$project_name}"
        task="${task//\{project_description\}/$project_description}"
        task="${task//\{primary_language\}/$primary_language}"
        
        local base_prompt=$(cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
)
        
        # Phase 4: Add language-specific quality standards
        if should_use_language_aware_prompts && command -v get_language_quality_standards &>/dev/null; then
            local quality_standards=$(get_language_quality_standards "${PRIMARY_LANGUAGE:-bash}")
            if [[ -n "$quality_standards" ]]; then
                echo "$base_prompt"
                echo ""
                echo "**${language^} Quality Standards:**"
                echo "$quality_standards"
            else
                echo "$base_prompt"
            fi
        else
            echo "$base_prompt"
        fi
    else
        # Fallback to hardcoded strings if YAML not available
        # Get project metadata for dynamic context
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        cat << EOF
**Role**: You are a senior software quality engineer and code review specialist with expertise in code quality standards, static analysis, linting best practices, design patterns, maintainability assessment, and technical debt identification.

**Task**: Perform comprehensive code quality review, identify anti-patterns, assess maintainability, and provide recommendations for improving code quality and reducing technical debt.

**Context:**
- Project: ${project_name} (${project_description})
- Primary Language: ${primary_language}
- Technology Stack: HTML5, CSS3, JavaScript ES6+, ES Modules
- Testing: Jest with jsdom
- Code Files: ${total_files} total (${js_files} JavaScript, ${html_files} HTML, ${css_files} CSS)

**Code Quality Analysis Results:**
${quality_summary}

**Automated Findings:**
${quality_report_content}

**Large Files Requiring Review:**
$(echo -e "${large_files_list}" | head -10 || echo "None")

**Code Samples for Review:**
${sample_code}

**Analysis Tasks:**

1. **Code Standards Compliance Assessment:**
   - Evaluate JavaScript coding standards (ES6+ features)
   - Check HTML5 semantic markup usage
   - Review CSS organization and naming (BEM, OOCSS, etc.)
   - Assess consistent indentation and formatting
   - Validate JSDoc/comment quality
   - Check error handling patterns

2. **Best Practices Validation:**
   - Verify separation of concerns (HTML/CSS/JS)
   - Check for proper event handling
   - Assess DOM manipulation patterns
   - Review async/await vs promises usage
   - Validate proper use of const/let (no var)
   - Check for magic numbers/strings

3. **Maintainability & Readability Analysis:**
   - Assess function complexity (cyclomatic complexity)
   - Evaluate function length (should be < 50 lines)
   - Check variable naming clarity
   - Review code organization and structure
   - Assess comment quality and documentation
   - Identify overly complex logic

4. **Anti-Pattern Detection:**
   - Identify code smells (duplicated code, long functions)
   - Detect callback hell or promise anti-patterns
   - Find global variable pollution
   - Spot tight coupling between modules
   - Identify monolithic functions
   - Detect violation of DRY principle

5. **Refactoring Recommendations:**
   - Suggest modularization opportunities
   - Recommend function extraction for clarity
   - Propose design pattern applications
   - Suggest performance optimizations
   - Recommend code reuse strategies
   - Identify technical debt priorities

**Expected Output:**
- Code quality grade (A-F) with justification
- Standards compliance checklist
- Anti-patterns detected with file:line references
- Maintainability score and improvement areas
- Top 5 refactoring priorities with effort estimates
- Best practice violations and fixes
- Technical debt assessment
- Specific code improvement recommendations
- Quick wins vs long-term improvements

Please provide a comprehensive code quality assessment with specific, actionable recommendations.
EOF
    fi
}

# Build a git commit message generation prompt (Step 11)
# Usage: build_step11_git_commit_prompt <script_version> <change_scope> <git_context> <changed_files> <diff_summary> <git_analysis> <diff_sample>
build_step11_git_commit_prompt() {
    local script_version="$1"
    local change_scope="$2"
    local git_context="$3"
    local changed_files="$4"
    local diff_summary="$5"
    local git_analysis_content="$6"
    local diff_sample="$7"
    local yaml_file="${AI_HELPERS_DIR}/../../../.workflow_core/config/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local commit_types
        local task_template
        local approach
        
        # Extract role from step11_git_commit_prompt section
        role=$(sed -n '/^step11_git_commit_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract commit_types
        commit_types=$(sed -n '/^step11_git_commit_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /commit_types: \|/ {flag=1; next}
            /^[[:space:]]+task_template:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract task template
        task_template=$(sed -n '/^step11_git_commit_prompt:/,/^[a-z_]/p' "$yaml_file" | awk '
            /task_template: \|/ {flag=1; next}
            /^[[:space:]]+approach:/ {flag=0}
            flag && /^[[:space:]]{4}/ {
                sub(/^[[:space:]]{4}/, "");
                print
            }
        ')
        
        # Extract approach
        approach=$(sed -n '/^step11_git_commit_prompt:/,/^$/ {
            /approach: \|/,/^$/ {
                /approach: \|/d
                /^$/d
                s/^[[:space:]]{4}//
                p
            }
        }' "$yaml_file")
        
        # Get project metadata
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        # Replace placeholders in task template
        local task="${task_template//\{commit_types\}/$commit_types}"
        task="${task//\{script_version\}/$script_version}"
        task="${task//\{change_scope\}/${change_scope:-General updates}}"
        task="${task//\{git_context\}/$git_context}"
        task="${task//\{changed_files\}/$changed_files}"
        task="${task//\{diff_summary\}/$diff_summary}"
        task="${task//\{git_analysis_content\}/$git_analysis_content}"
        task="${task//\{diff_sample\}/$diff_sample}"
        task="${task//\{project_name\}/$project_name}"
        task="${task//\{project_description\}/$project_description}"
        task="${task//\{primary_language\}/$primary_language}"
        
        # Replace placeholders in approach
        local final_approach="${approach//\{script_version\}/$script_version}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${final_approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        # Get project metadata for dynamic context
        local metadata
        metadata=$(get_project_metadata)
        local project_name="${metadata%%|*}"
        local temp="${metadata#*|}"
        local project_description="${temp%%|*}"
        local primary_language="${temp#*|}"
        
        cat << EOF
**Role**: You are a senior git workflow specialist and technical communication expert with expertise in conventional commits, semantic versioning, git best practices, technical writing, and commit message optimization.

**Task**: Generate a professional conventional commit message that clearly communicates the changes, follows best practices, and provides useful context for code reviewers and future maintainers.

**Context:**
- Project: ${project_name} (${project_description})
- Primary Language: ${primary_language}
- Workflow: Tests & Documentation Automation v${script_version}
- Change Scope: ${change_scope:-General updates}

**Git Repository Analysis:**
${git_context}

**Changed Files:**
${changed_files}

**Diff Statistics:**
${diff_summary}

**Detailed Context:**
${git_analysis_content}

**Diff Sample (first 100 lines):**
${diff_sample}

**Commit Message Generation Tasks:**

1. **Conventional Commit Message Crafting:**
   - Select appropriate type: feat|fix|docs|style|refactor|test|chore
   - Define clear scope (e.g., deployment, testing, documentation)
   - Write concise subject line (<50 chars if possible, max 72)
   - Follow format: type(scope): subject
   - Use imperative mood ("add" not "added" or "adds")
   - Don't end subject with period

2. **Semantic Context Integration:**
   - Analyze what changed and why
   - Identify the business value or technical benefit
   - Connect changes to workflow or project goals
   - Reference workflow automation context
   - Note automation tool version

3. **Change Impact Description:**
   - Describe what was changed (files, features, functionality)
   - Explain why changes were made
   - Note any architectural or structural improvements
   - Highlight test coverage or documentation updates
   - Mention dependency or quality improvements

4. **Breaking Change Detection:**
   - Identify any breaking changes (API, behavior, interface)
   - Flag deprecations or removals
   - Note migration steps if applicable
   - Assess backward compatibility

5. **Commit Body & Footer Generation:**
   - Provide detailed multi-line body if needed
   - List key changes as bullet points
   - Include relevant issue/PR references
   - Add footer metadata (automation info, breaking changes)
   - Follow 72-character line wrap

**Expected Output Format:**

\`\`\`
type(scope): subject line here

Optional body paragraph explaining what and why, not how.
Wrap at 72 characters per line.

- List key changes as bullet points
- Each bullet should be clear and actionable
- Focus on user/developer impact

BREAKING CHANGE: describe any breaking changes
Refs: #issue-number (if applicable)
[workflow-automation v${script_version}]
\`\`\`

**Conventional Commit Types:**
- feat: New feature or functionality
- fix: Bug fix
- docs: Documentation changes
- style: Code style/formatting (no logic change)
- refactor: Code restructuring (no behavior change)
- test: Adding or updating tests
- chore: Maintenance tasks (build, tools, dependencies)
- perf: Performance improvements
- ci: CI/CD changes

**Best Practices:**
- Subject line: imperative mood, lowercase, no period, <72 chars
- Body: explain WHAT and WHY, not HOW
- Footer: metadata, breaking changes, references
- Be specific but concise
- Focus on impact and intent
- Conventional commits enable automated changelogs
- Think about future maintainers reading this

Please generate a complete conventional commit message following these standards. Provide ONLY the commit message text (no explanations, no markdown code blocks, just the raw commit message).
EOF
    fi
}

# ==============================================================================
# AI PROMPT LOGGING
# ==============================================================================

# Log executed AI prompt to prompts directory
# Usage: log_ai_prompt <step_name> <persona> <prompt_text>
log_ai_prompt() {
    local step_name="$1"
    local persona="$2"
    local prompt_text="$3"
    
    # Use PROMPTS_RUN_DIR which follows the per-workflow-run pattern
    # Falls back to .ai_workflow/prompts if not set
    local prompts_dir="${PROMPTS_RUN_DIR:-${PROJECT_ROOT:-.}/.ai_workflow/prompts/${WORKFLOW_RUN_ID}}"
    
    # Create prompts directory if it doesn't exist
    mkdir -p "$prompts_dir"
    
    # Create timestamped log file
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local log_file="${prompts_dir}/${step_name}_${persona}_${timestamp}.md"
    
    # Write prompt with metadata
    cat > "$log_file" << EOF
# AI Prompt Log

**Step**: ${step_name}
**Persona**: ${persona}
**Timestamp**: $(date '+%Y-%m-%d %H:%M:%S')
**Workflow Run**: ${WORKFLOW_RUN_ID}

---

## Prompt Content

${prompt_text}

---

*Generated by AI Workflow Automation v2.3.1*
EOF
    
    # Make log file read-only to prevent accidental modification
    chmod 444 "$log_file"
    
    print_info "Prompt logged to: ${log_file}"
}

# ==============================================================================
# AI PROMPT EXECUTION
# ==============================================================================

# Execute a Copilot CLI prompt with proper error handling
# ==============================================================================
# BATCH AI EXECUTION
# ==============================================================================

# Execute Copilot prompt in batch (non-interactive) mode
# This function runs AI analysis without user interaction, capturing the full response
# ==============================================================================
# MODEL SELECTION SUPPORT (v3.2.0)
# ==============================================================================

# Normalize step ID to match model_definitions.json keys
# Usage: normalize_step_id <step_id>
# Returns: normalized step ID (e.g., "0b" → "bootstrap_docs", "step01" → "documentation")
normalize_step_id() {
    local step_id="$1"
    
    # If already in full format (step_XX_name), return as-is
    if [[ "$step_id" =~ ^step_[0-9]+[a-z]?_.+ ]]; then
        echo "$step_id"
        return 0
    fi
    
    # Map short IDs to full step names
    case "$step_id" in
        "0a"|"step_0a") echo "version_update" ;;
        "0b"|"step_0b") echo "bootstrap_docs" ;;
        "00"|"step_00") echo "step_00_pre_analysis" ;;
        "01"|"step_01"|"step01") echo "documentation" ;;
        "02"|"step_02"|"step02") echo "consistency" ;;
        "03"|"step_03"|"step03") echo "script_refs" ;;
        "04"|"step_04"|"step04") echo "config_validation" ;;
        "05"|"step_05"|"step05") echo "step_05_test_review" ;;
        "06"|"step_06"|"step06") echo "step_06_test_gen" ;;
        "07"|"step_07"|"step07") echo "step_07_test_exec" ;;
        "08"|"step_08"|"step08") echo "step_08_test_exec" ;;
        "09"|"step_09"|"step09") echo "step_09_code_quality" ;;
        "10"|"step_10"|"step10") echo "step_10_code_quality" ;;
        "11"|"step_11"|"step11") echo "step_11_context" ;;
        "12"|"step_12"|"step12") echo "step_12_markdown_lint" ;;
        "13"|"step_13"|"step13") echo "step_13_prompt_engineer" ;;
        "14"|"step_14"|"step14") echo "step_14_ux_analysis" ;;
        "15"|"step_15"|"step15") echo "step_15_version_update" ;;
        "16"|"step_16"|"step16") echo "step_16_git_finalization" ;;
        *) echo "$step_id" ;;  # Return original if no match
    esac
}

# Get model for specific workflow step from model definitions
# Usage: get_model_for_step <step_id>
# Returns: model name or "default"
get_model_for_step() {
    local step_id="$1"
    local definitions_file="${PROJECT_ROOT:-.}/.ai_workflow/model_definitions.json"
    
    # Check for override first
    if [[ -n "${FORCE_MODEL:-}" ]]; then
        echo "$FORCE_MODEL"
        return 0
    fi
    
    # Normalize step ID to match model_definitions.json keys
    local normalized_id=$(normalize_step_id "$step_id")
    
    # Load from JSON if available
    if [[ -f "$definitions_file" ]]; then
        if command -v jq &>/dev/null; then
            local model=$(jq -r ".model_definitions[\"$normalized_id\"].model // \"default\"" "$definitions_file" 2>/dev/null || echo "default")
            if [[ "$model" != "null" ]] && [[ "$model" != "default" ]]; then
                echo "$model"
                return 0
            fi
        fi
    fi
    
    echo "default"
}

# Get current step ID from environment or call stack
# Usage: get_current_step_id
# Returns: step ID (e.g., "documentation")
get_current_step_id() {
    # Try to extract from CURRENT_STEP environment variable
    if [[ -n "${CURRENT_STEP:-}" ]]; then
        echo "$CURRENT_STEP"
        return 0
    fi
    
    # Try to extract from caller script name
    local caller_script="${BASH_SOURCE[2]:-}"
    if [[ -n "$caller_script" ]]; then
        local step_name=$(basename "$caller_script" .sh)
        if [[ "$step_name" =~ ^step_[0-9]+[a-z]?_.* ]]; then
            echo "$step_name"
            return 0
        fi
    fi
    
    echo "unknown_step"
}

# ==============================================================================
# AI EXECUTION WITH MODEL SELECTION
# ==============================================================================

# Usage: execute_copilot_batch <prompt_text> <log_file> [timeout_seconds] [step_name] [persona]
execute_copilot_batch() {
    local prompt_text="$1"
    local log_file="$2"
    local timeout="${3:-300}"  # Default 5 minute timeout
    local step_name="${4:-unknown}"
    local persona="${5:-unknown}"
    
    if ! is_copilot_available; then
        print_warning "Copilot CLI not available, skipping AI analysis"
        return 1
    fi
    
    if ! is_copilot_authenticated; then
        print_error "Copilot CLI is not authenticated"
        return 1
    fi
    
    # Get model for this step (NEW in v3.2.0)
    local model=$(get_model_for_step "$step_name")
    local model_flag=""
    local model_display=""
    
    if [[ "$model" != "default" ]]; then
        model_flag="--model $model"
        model_display="$model"
        print_info "🤖 AI Model: $model (configured for $step_name)"
    else
        # No model flag means GitHub Copilot CLI will use its default
        # As of v0.0.406, the default is typically claude-sonnet-4.5
        model_display="claude-sonnet-4.5 (default)"
        print_info "🤖 AI Model: claude-sonnet-4.5 (default)"
    fi
    
    # Log model selection
    log_to_workflow "INFO" "AI Model: $model_display for step: $step_name"
    
    print_info "Executing AI analysis in batch mode (timeout: ${timeout}s)..."
    
    # Log the prompt before execution
    log_ai_prompt "$step_name" "$persona" "$prompt_text"
    
    # Ensure log directory exists
    mkdir -p "$(dirname "$log_file")"
    
    # Write prompt to temporary file
    local temp_prompt_file
    temp_prompt_file=$(mktemp)
    track_ai_helpers_temp "$temp_prompt_file"
    echo "$prompt_text" > "$temp_prompt_file"
    
    # Execute with timeout, model selection, and non-interactive flags
    local exit_code=0
    if timeout "${timeout}s" bash -c "cat '$temp_prompt_file' | copilot $model_flag --allow-all-tools --allow-all-paths --enable-all-github-mcp-tools 2>&1 | tee '$log_file'"; then
        print_success "AI batch analysis completed"
        exit_code=0
    else
        local timeout_exit=$?
        if [[ $timeout_exit -eq 124 ]]; then
            print_warning "AI batch analysis timed out after ${timeout}s"
            echo "# TIMEOUT: Analysis exceeded ${timeout}s" >> "$log_file"
        else
            print_error "AI batch analysis failed (exit code: $timeout_exit)"
        fi
        exit_code=1
    fi
    
    # Clean up
    rm -f "$temp_prompt_file"
    
    return $exit_code
}

# Enhanced execute_copilot_prompt with batch mode support
# Usage: execute_copilot_prompt <prompt_text> [log_file] [step_name] [persona]
execute_copilot_prompt() {
    local prompt_text="$1"
    local log_file="${2:-}"
    local step_name="${3:-unknown}"
    local persona="${4:-unknown}"
    
    # Check for batch mode (hybrid auto mode)
    if [[ "${AI_BATCH_MODE:-false}" == "true" ]]; then
        if [[ -n "$log_file" ]]; then
            execute_copilot_batch "$prompt_text" "$log_file" "300" "$step_name" "$persona"
            return $?
        else
            print_warning "Batch mode requires log file - skipping AI analysis"
            return 1
        fi
    fi
    
    if [[ "$AUTO_MODE" == true ]]; then
        print_info "Auto mode: Skipping AI prompt execution"
        # Create empty log file to prevent downstream errors
        if [[ -n "$log_file" ]]; then
            mkdir -p "$(dirname "$log_file")"
            echo "# Auto mode - AI prompt execution skipped" > "$log_file"
            echo "# Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"
        fi
        return 0
    fi
    
    if ! is_copilot_available; then
        print_warning "Copilot CLI not available, skipping AI analysis"
        return 1
    fi
    
    if ! is_copilot_authenticated; then
        print_error "Copilot CLI is not authenticated"
        print_info "Authentication options:"
        print_info "  • Run 'copilot' and use the '/login' command"
        print_info "  • Set COPILOT_GITHUB_TOKEN, GH_TOKEN, or GITHUB_TOKEN environment variable"
        print_info "  • Run 'gh auth login' to authenticate with GitHub CLI"
        return 1
    fi
    
    print_info "Executing Copilot CLI prompt..."
    
    # Get model for this step (NEW in v3.2.0)
    local model=$(get_model_for_step "$step_name")
    local model_flag=""
    local model_display=""
    
    if [[ "$model" != "default" ]]; then
        model_flag="--model $model"
        model_display="$model"
        print_info "🤖 AI Model: $model (configured for $step_name)"
    else
        # No model flag means GitHub Copilot CLI will use its default
        # As of v0.0.406, the default is typically claude-sonnet-4.5
        model_display="claude-sonnet-4.5 (default)"
        print_info "🤖 AI Model: claude-sonnet-4.5 (default)"
    fi
    
    # Log model selection
    log_to_workflow "INFO" "AI Model: $model_display for step: $step_name"
    
    # Log the prompt before execution
    log_ai_prompt "$step_name" "$persona" "$prompt_text"
    
    # Write prompt to temporary file to avoid ARG_MAX limit
    local temp_prompt_file
    temp_prompt_file=$(mktemp)
    track_ai_helpers_temp "$temp_prompt_file"
    echo "$prompt_text" > "$temp_prompt_file"
    
    if [[ -n "$log_file" ]]; then
        # Ensure the parent directory exists
        local log_dir
        log_dir=$(dirname "$log_file")
        mkdir -p "$log_dir"
        
        # Use stdin to avoid ARG_MAX: read prompt from file and pipe to copilot
        # Use --allow-all-paths to enable access to target project files
        # Use --enable-all-github-mcp-tools for repository analysis capabilities
        cat "$temp_prompt_file" | copilot $model_flag --allow-all-tools --allow-all-paths --enable-all-github-mcp-tools 2>&1 | tee "$log_file"
    else
        cat "$temp_prompt_file" | copilot $model_flag --allow-all-tools --allow-all-paths --enable-all-github-mcp-tools
    fi
    
    local exit_code=$?
    
    # Clean up temporary file
    rm -f "$temp_prompt_file"
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "Copilot CLI analysis completed"
        return 0
    else
        print_error "Copilot CLI execution failed (exit code: $exit_code)"
        return 1
    fi
}

export -f log_ai_prompt
export -f get_model_for_step
export -f normalize_step_id
export -f get_current_step_id
export -f execute_copilot_batch

# Trigger an AI-enhanced step with confirmation
# Usage: trigger_ai_step <step_name> <prompt_builder_function> <args...>
trigger_ai_step() {
    local step_name="$1"
    local prompt_builder="$2"
    shift 2
    local args=("$@")
    
    if [[ "$AUTO_MODE" == true ]]; then
        print_info "Auto mode: Skipping AI step for ${step_name}"
        return 0
    fi
    
    if ! is_copilot_available; then
        print_info "Copilot CLI not available for ${step_name}"
        return 1
    fi
    
    if ! is_copilot_authenticated; then
        print_warning "Copilot CLI not authenticated for ${step_name}"
        print_info "Run 'copilot' and use '/login' or set COPILOT_GITHUB_TOKEN"
        return 1
    fi
    
    if ! confirm_action "Run Copilot CLI for ${step_name}?" "y"; then
        print_info "Skipped AI analysis for ${step_name}"
        return 0
    fi
    
    local prompt
    prompt=$("$prompt_builder" "${args[@]}")
    execute_copilot_prompt "$prompt"
}

# Export all AI helper functions
export -f is_copilot_available
export -f is_copilot_authenticated
export -f validate_copilot_cli
export -f compose_role_from_yaml  # NEW: YAML anchor support
export -f build_ai_prompt
export -f build_doc_analysis_prompt
export -f build_consistency_prompt
export -f build_test_strategy_prompt
export -f build_quality_prompt
export -f build_issue_extraction_prompt
export -f build_step2_consistency_prompt
export -f build_step3_script_refs_prompt
export -f build_step4_directory_prompt
export -f build_step5_test_review_prompt
export -f build_step7_test_exec_prompt
export -f build_step8_dependencies_prompt
export -f build_step9_code_quality_prompt
export -f build_step11_git_commit_prompt
export -f execute_copilot_prompt
export -f trigger_ai_step

# ============================================================================
# Issue Extraction Workflow
# ============================================================================

# Execute issue extraction workflow from Copilot session logs
# This function handles the complete workflow of extracting issues from a
# Copilot CLI session log file and saving them to the backlog.
#
# Supports two modes:
#   - AUTO_MODE: Automatically parses log file for issues (no user interaction)
#   - INTERACTIVE: Uses Copilot CLI for extraction with user confirmation
#
# Usage: extract_and_save_issues_from_log <step_number> <step_name> <log_file>
#
# Parameters:
#   step_number - The workflow step number (e.g., "2", "3")
#   step_name   - The step name for backlog organization (e.g., "Consistency_Analysis")
#   log_file    - Path to the Copilot session log file
#
# Returns:
#   0 on success, 1 on error
#
# Workflow (AUTO_MODE):
#   1. Automatically parses log file for issues
#   2. Extracts key sections (changes, recommendations, warnings)
#   3. Saves formatted issues to backlog
#
# Workflow (INTERACTIVE):
#   1. Prompts user to confirm issue extraction
#   2. Builds issue extraction prompt
#   3. Executes Copilot CLI with the prompt
#   4. Accepts multi-line user input of organized issues
#   5. Saves issues to backlog
extract_and_save_issues_from_log() {
    local step_number="$1"
    local step_name="$2"
    local log_file="$3"
    
    # Validate parameters
    if [[ -z "$step_number" || -z "$step_name" || -z "$log_file" ]]; then
        print_error "Usage: extract_and_save_issues_from_log <step_number> <step_name> <log_file>"
        return 1
    fi
    
    # Check if log file exists
    if [[ ! -f "$log_file" ]]; then
        print_error "Log file not found: $log_file"
        return 1
    fi
    
    # AUTO MODE: Automatic issue extraction from log file
    if [[ "${AUTO_MODE:-false}" == "true" ]]; then
        print_info "AUTO MODE: Automatically extracting issues from log file..."
        
        local log_content
        log_content=$(cat "$log_file")
        
        # Build automatic issue summary from log content
        local auto_issues="## Automated Issue Extraction from Copilot Session\n\n"
        auto_issues+="**Timestamp**: $(date '+%Y-%m-%d %H:%M:%S')\n"
        auto_issues+="**Log File**: $(basename "$log_file")\n"
        auto_issues+="**Step**: $step_number - $step_name\n\n"
        
        # Extract key sections from log
        local has_content=false
        
        # Extract changes made
        if echo "$log_content" | grep -qi "change\|update\|modif\|edit\|add\|remove"; then
            auto_issues+="### Changes Detected\n\n"
            echo "$log_content" | grep -i "change\|update\|modif\|edit" | head -10 | while read -r line; do
                auto_issues+="- $line\n"
            done
            auto_issues+="\n"
            has_content=true
        fi
        
        # Extract recommendations
        if echo "$log_content" | grep -qi "recommend\|should\|consider\|suggest"; then
            auto_issues+="### Recommendations\n\n"
            echo "$log_content" | grep -i "recommend\|should\|consider\|suggest" | head -10 | while read -r line; do
                auto_issues+="- $line\n"
            done
            auto_issues+="\n"
            has_content=true
        fi
        
        # Extract warnings or issues
        if echo "$log_content" | grep -qi "warning\|issue\|problem\|error\|fix"; then
            auto_issues+="### Issues and Warnings\n\n"
            echo "$log_content" | grep -i "warning\|issue\|problem\|error\|fix" | head -10 | while read -r line; do
                auto_issues+="- $line\n"
            done
            auto_issues+="\n"
            has_content=true
        fi
        
        # Add note about full log
        auto_issues+="### Full Details\n\n"
        auto_issues+="Complete session log available at: \`$log_file\`\n\n"
        auto_issues+="Review the full log file for detailed context and complete output.\n"
        
        # Save to backlog if content was found
        if [[ "$has_content" == true ]]; then
            save_step_issues "$step_number" "$step_name" "$(echo -e "$auto_issues")"
            print_success "Issues automatically extracted and saved to backlog"
        else
            print_info "No significant issues detected in log file"
            # Save minimal report
            auto_issues+="No significant issues or warnings detected in automated scan.\n"
            save_step_issues "$step_number" "$step_name" "$(echo -e "$auto_issues")"
        fi
        
        return 0
    fi
    
    # INTERACTIVE MODE: User-assisted issue extraction
    # Check if user wants to save issues
    if confirm_action "Do you want to save issues from the Copilot session to the backlog?" "n"; then
        local log_content
        log_content=$(cat "$log_file")
        
        # Build issue extraction prompt using helper function
        local extract_prompt
        extract_prompt=$(build_issue_extraction_prompt "$log_file" "$log_content")

        echo -e "\n${CYAN}Issue Extraction Prompt:${NC}"
        echo -e "${YELLOW}${extract_prompt}${NC}\n"
        
        if confirm_action "Run GitHub Copilot CLI to extract and organize issues from the log?" "y"; then
            sleep 1
            print_info "Starting Copilot CLI session for issue extraction..."
            print_info "🤖 AI Model: claude-sonnet-4.5 (default) - Interactive mode"
            # Use --allow-all-paths to enable access to target project files
            # Use --enable-all-github-mcp-tools for repository analysis capabilities
            copilot -p "$extract_prompt" --allow-all-tools --allow-all-paths --enable-all-github-mcp-tools
            
            # Collect organized issues using reusable function
            local organized_issues
            organized_issues=$(collect_ai_output "Please copy the organized issues from Copilot output." "multi")
            
            if [[ -n "$organized_issues" ]]; then
                save_step_issues "$step_number" "$step_name" "$organized_issues"
                print_success "Issues extracted from log and saved to backlog"
            else
                print_warning "No organized issues provided - skipping backlog save"
            fi
        else
            print_warning "Skipped issue extraction - no backlog file created"
        fi
    fi
    
    return 0
}

export -f extract_and_save_issues_from_log

################################################################################
# PHASE 4: LANGUAGE-SPECIFIC PROMPT GENERATION
# Version: 5.0.5
# Added: 2025-12-18
################################################################################

#######################################
# Load language-specific documentation conventions
# Globals:
#   PRIMARY_LANGUAGE
# Arguments:
#   None
# Returns:
#   Language-specific documentation conventions
#######################################
get_language_documentation_conventions() {
    local language="${PRIMARY_LANGUAGE:-javascript}"
    local yaml_file="${LIB_DIR}/ai_helpers.yaml"
    
    if [[ ! -f "$yaml_file" ]]; then
        echo ""
        return 1
    fi
    
    # Extract conventions for the language
    # Simple extraction - look for the language section under language_specific_documentation
    awk -v lang="$language" '
    /^  '"$language"':/ { found=1; next }
    found && /^    conventions:/ { in_conv=1; next }
    found && in_conv && /^    [a-z_]+:/ { exit }
    found && in_conv && /^      - / { print; next }
    found && in_conv && /^      [A-Za-z]/ { print "      " $0; next }
    ' "$yaml_file" | sed 's/^      - //'
}

#######################################
# Load language-specific quality standards
# Globals:
#   PRIMARY_LANGUAGE
# Returns:
#   Language-specific quality focus areas and best practices
#######################################
get_language_quality_standards() {
    local language="${PRIMARY_LANGUAGE:-javascript}"
    local yaml_file="${LIB_DIR}/ai_helpers.yaml"
    
    if [[ ! -f "$yaml_file" ]]; then
        echo ""
        return 1
    fi
    
    # Extract quality standards from language_specific_quality section
    awk -v lang="$language" '
    BEGIN { in_section=0; in_lang=0 }
    /^language_specific_quality:/ { in_section=1; next }
    in_section && /^  '"$language"':/ { in_lang=1; next }
    in_section && in_lang && /^    focus_areas:/ { print "**Focus Areas:**"; next }
    in_section && in_lang && /^    best_practices:/ { print "\n**Best Practices:**"; next }
    in_section && in_lang && /^  [a-z_]+:/ { exit }
    in_section && in_lang && /^      - / { print "  " $0; next }
    ' "$yaml_file" | sed 's/^      - /- /'
}

#######################################
# Load language-specific testing patterns
# Globals:
#   PRIMARY_LANGUAGE
# Returns:
#   Language-specific test framework and patterns
#######################################
get_language_testing_patterns() {
    local language="${PRIMARY_LANGUAGE:-javascript}"
    local yaml_file="${LIB_DIR}/ai_helpers.yaml"
    
    if [[ ! -f "$yaml_file" ]]; then
        echo ""
        return 1
    fi
    
    # Extract testing patterns from language_specific_testing section
    awk -v lang="$language" '
    BEGIN { in_section=0; in_lang=0 }
    /^language_specific_testing:/ { in_section=1; next }
    in_section && /^  '"$language"':/ { in_lang=1; next }
    in_section && in_lang && /^    framework:/ { print; next }
    in_section && in_lang && /^    patterns:/ { print "\nPatterns:"; next }
    in_section && in_lang && /^  [a-z_]+:/ { exit }
    in_section && in_lang && /^      - / { print "  " $0; next }
    ' "$yaml_file"
}

#######################################
# Generate language-aware AI prompt
# Arguments:
#   $1 - Base prompt (from existing functions)
#   $2 - Prompt type (documentation|quality|testing)
# Globals:
#   PRIMARY_LANGUAGE
#   BUILD_SYSTEM
#   TEST_FRAMEWORK
# Returns:
#   Enhanced prompt with language-specific context
#######################################
generate_language_aware_prompt() {
    local base_prompt="$1"
    local prompt_type="$2"
    local language="${PRIMARY_LANGUAGE:-javascript}"
    local build_system="${BUILD_SYSTEM:-npm}"
    local test_framework="${TEST_FRAMEWORK:-jest}"
    
    # Add language context header
    local enhanced_prompt="$base_prompt

**Project Technology Stack:**
- Primary Language: ${language}
- Build System: ${build_system}
- Test Framework: ${test_framework}
"
    
    # Add language-specific guidelines based on prompt type
    case "$prompt_type" in
        documentation)
            local conventions=$(get_language_documentation_conventions)
            if [[ -n "$conventions" ]]; then
                enhanced_prompt+="
**${language^} Documentation Guidelines:**
${conventions}
"
            fi
            ;;
        
        quality)
            local standards=$(get_language_quality_standards)
            if [[ -n "$standards" ]]; then
                enhanced_prompt+="
**${language^} Quality Standards:**
${standards}
"
            fi
            ;;
        
        testing)
            local patterns=$(get_language_testing_patterns "${PRIMARY_LANGUAGE:-bash}")
            if [[ -n "$patterns" ]]; then
                enhanced_prompt+="
**${language^} Testing Framework:**
${patterns}
"
            fi
            ;;
    esac
    
    # Add custom context from config if available
    # Note: Using variable expansion instead of array syntax due to Bash limitations
    local custom_context=""
    if [[ -n "${TECH_STACK_CONFIG:-}" ]]; then
        custom_context="${TECH_STACK_CONFIG[language_context]:-}"
    fi
    
    if [[ -n "$custom_context" ]]; then
        enhanced_prompt+="
**Project-Specific Context:**
$custom_context
"
    fi
    
    echo "$enhanced_prompt"
}

#######################################
# Build language-aware documentation prompt
# Enhanced version of build_doc_analysis_prompt
# Arguments:
#   $1 - changed_files
#   $2 - doc_files
# Returns:
#   Language-aware documentation prompt
#######################################
build_language_aware_doc_prompt() {
    local changed_files="$1"
    local doc_files="$2"
    
    # Get base prompt
    local base_prompt
    base_prompt=$(build_doc_analysis_prompt "$changed_files" "$doc_files")
    
    # Enhance with language-specific context
    generate_language_aware_prompt "$base_prompt" "documentation"
}

#######################################
# Build language-aware quality prompt
# Enhanced version of build_quality_prompt
# Arguments:
#   $1 - files_to_review
# Returns:
#   Language-aware quality prompt
#######################################
build_language_aware_quality_prompt() {
    local files_to_review="$1"
    
    # Get base prompt
    local base_prompt
    base_prompt=$(build_quality_prompt "$files_to_review")
    
    # Enhance with language-specific context
    generate_language_aware_prompt "$base_prompt" "quality"
}

#######################################
# Build language-aware test strategy prompt
# Enhanced version of build_test_strategy_prompt
# Arguments:
#   $1 - coverage_stats
#   $2 - test_files
# Returns:
#   Language-aware test strategy prompt
#######################################
build_language_aware_test_prompt() {
    local coverage_stats="$1"
    local test_files="$2"
    
    # Get base prompt
    local base_prompt
    base_prompt=$(build_test_strategy_prompt "$coverage_stats" "$test_files")
    
    # Enhance with language-specific context
    generate_language_aware_prompt "$base_prompt" "testing"
}

#######################################
# Check if language-aware prompts should be used
# Returns:
#   0 if language-aware prompts should be used, 1 otherwise
#######################################
should_use_language_aware_prompts() {
    # Use language-aware prompts if:
    # 1. Tech stack is detected/configured
    # 2. PRIMARY_LANGUAGE is set
    # 3. Not explicitly disabled
    
    if [[ -z "${PRIMARY_LANGUAGE:-}" ]]; then
        return 1
    fi
    
    if [[ "${USE_LANGUAGE_AWARE_PROMPTS:-true}" == "false" ]]; then
        return 1
    fi
    
    return 0
}

# Export Phase 4 functions
export -f get_language_documentation_conventions
export -f get_language_quality_standards
export -f get_language_testing_patterns
export -f generate_language_aware_prompt
export -f build_language_aware_doc_prompt
export -f build_language_aware_quality_prompt
export -f build_language_aware_test_prompt
export -f should_use_language_aware_prompts

################################################################################
# PROJECT KIND-AWARE AI PROMPTS (Phase 4)
# Purpose: Load and apply project kind-specific AI prompt templates
################################################################################

#######################################
# Load project kind-specific prompt template
# Arguments:
#   $1 - project_kind (e.g., "shell_automation", "nodejs_api")
#   $2 - persona (e.g., "documentation_specialist", "test_engineer", "code_reviewer")
#   $3 - field (e.g., "role", "task_context", "approach")
# Returns:
#   Prompt template text
#######################################
get_project_kind_prompt() {
    local project_kind="$1"
    local persona="$2"
    local field="$3"
    local yaml_file="${AI_HELPERS_WORKFLOW_DIR}/../../.workflow_core/config/ai_prompts_project_kinds.yaml"
    
    if [[ ! -f "$yaml_file" ]]; then
        return 1
    fi
    
    # Use awk to extract the specific field
    awk -v kind="$project_kind" -v pers="$persona" -v fld="$field" '
        BEGIN { in_kind=0; in_persona=0; in_field=0 }
        
        # Match project kind section
        $0 ~ "^" kind ":" { in_kind=1; next }
        
        # Reset on new top-level section
        /^[a-z_]+:/ && NF==1 && in_kind { in_kind=0 }
        
        # Match persona within kind
        in_kind && $0 ~ "^  " pers ":" { in_persona=1; next }
        
        # Reset on new persona
        in_kind && /^  [a-z_]+:/ && in_persona { in_persona=0 }
        
        # Match field within persona
        in_kind && in_persona && $0 ~ "^    " fld ":" {
            in_field=1
            # Check if single-line value
            if ($0 ~ /"/) {
                # Extract quoted value
                match($0, /"([^"]*)"/, arr)
                print arr[1]
                in_field=0
                next
            }
            # Multi-line value with |
            next
        }
        
        # Collect multi-line field content
        in_field && /^      / {
            sub(/^      /, "")
            print
            next
        }
        
        # End of multi-line field
        in_field && /^    [a-z_]+:/ { in_field=0 }
    ' "$yaml_file"
}

#######################################
# Build project kind-aware AI prompt
# Arguments:
#   $1 - project_kind
#   $2 - persona
#   $3 - task_description (specific task details to append)
# Returns:
#   Complete AI prompt
#######################################
build_project_kind_prompt() {
    local project_kind="$1"
    local persona="$2"
    local task_description="$3"
    
    local role=$(get_project_kind_prompt "$project_kind" "$persona" "role")
    local task_context=$(get_project_kind_prompt "$project_kind" "$persona" "task_context")
    local approach=$(get_project_kind_prompt "$project_kind" "$persona" "approach")
    
    # If project kind not found, try default
    if [[ -z "$role" ]]; then
        role=$(get_project_kind_prompt "default" "$persona" "role")
        task_context=$(get_project_kind_prompt "default" "$persona" "task_context")
        approach=$(get_project_kind_prompt "default" "$persona" "approach")
    fi
    
    # Build complete prompt
    cat << EOF
**Role**: ${role}

**Project Context**: ${task_context}

**Task**: ${task_description}

**Approach**: ${approach}
EOF
}

#######################################
# Get project kind-aware documentation prompt
# Arguments:
#   $1 - changed_files
#   $2 - doc_files
# Returns:
#   Project kind-aware documentation prompt
#######################################
build_project_kind_doc_prompt() {
    local changed_files="$1"
    local doc_files="$2"
    
    # Get project kind from detection
    local project_kind="${PRIMARY_PROJECT_KIND:-default}"
    
    local task="Based on the recent changes to the following files: ${changed_files}

Please update all related documentation including:
1. Project README and setup instructions
2. Architecture and design documentation
3. API/interface documentation
4. Usage examples and tutorials
5. Inline code comments for complex logic

Documentation to review: ${doc_files}"
    
    build_project_kind_prompt "$project_kind" "documentation_specialist" "$task"
}

#######################################
# Get project kind-aware test prompt
# Arguments:
#   $1 - coverage_stats
#   $2 - test_files
# Returns:
#   Project kind-aware test prompt
#######################################
build_project_kind_test_prompt() {
    local coverage_stats="$1"
    local test_files="$2"
    
    # Get project kind from detection
    local project_kind="${PRIMARY_PROJECT_KIND:-default}"
    
    local task="Based on the current test coverage statistics: ${coverage_stats}

And existing test files: ${test_files}

Recommend:
1. New tests to generate for untested code paths
2. Improvements to existing tests
3. Coverage gaps to address
4. Test patterns and best practices for this project"
    
    build_project_kind_prompt "$project_kind" "test_engineer" "$task"
}

#######################################
# Get project kind-aware code review prompt
# Arguments:
#   $1 - files_to_review
#   $2 - review_focus (optional: "security", "performance", "maintainability")
# Returns:
#   Project kind-aware code review prompt
#######################################
build_project_kind_review_prompt() {
    local files_to_review="$1"
    local review_focus="${2:-general}"
    
    # Get project kind from detection
    local project_kind="${PRIMARY_PROJECT_KIND:-default}"
    
    local task="Review the following files: ${files_to_review}

Focus areas:
1. Code quality and maintainability
2. Best practices for this project type
3. Error handling and edge cases
4. Security considerations
5. Performance optimization opportunities"
    
    if [[ "$review_focus" != "general" ]]; then
        task="${task}

Special focus: ${review_focus}"
    fi
    
    build_project_kind_prompt "$project_kind" "code_reviewer" "$task"
}

#######################################
# Check if project kind-aware prompts should be used
# Returns:
#   0 if should use, 1 otherwise
#######################################
should_use_project_kind_prompts() {
    # Use project kind prompts if:
    # 1. Project kind is detected
    # 2. Not explicitly disabled
    
    if [[ -z "${PRIMARY_PROJECT_KIND:-}" ]]; then
        return 1
    fi
    
    if [[ "${USE_PROJECT_KIND_PROMPTS:-true}" == "false" ]]; then
        return 1
    fi
    
    return 0
}

#######################################
# Get combined language and project kind-aware prompt
# Arguments:
#   $1 - base_prompt
#   $2 - context_type ("documentation", "testing", "quality")
# Returns:
#   Enhanced prompt with both language and project kind awareness
#######################################
generate_adaptive_prompt() {
    local base_prompt="$1"
    local context_type="$2"
    
    local enhanced_prompt="$base_prompt"
    
    # Add language-specific context if available
    if should_use_language_aware_prompts; then
        enhanced_prompt=$(generate_language_aware_prompt "$enhanced_prompt" "$context_type")
    fi
    
    # Add project kind context if available
    if should_use_project_kind_prompts; then
        local project_kind="${PRIMARY_PROJECT_KIND:-default}"
        local kind_context=$(get_project_kind_prompt "$project_kind" "documentation_specialist" "task_context")
        
        if [[ -n "$kind_context" ]]; then
            enhanced_prompt="${enhanced_prompt}

**Project Kind Context**:
${kind_context}"
        fi
    fi
    
    echo "$enhanced_prompt"
}

# Export Phase 4 project kind functions
export -f get_project_kind_prompt
export -f build_project_kind_prompt
export -f build_project_kind_doc_prompt
export -f build_project_kind_test_prompt
export -f build_project_kind_review_prompt
export -f should_use_project_kind_prompts
export -f generate_adaptive_prompt
export -f track_ai_helpers_temp
export -f cleanup_ai_helpers_files

# ==============================================================================
# CLEANUP TRAP
# ==============================================================================

# Ensure cleanup runs on exit
trap cleanup_ai_helpers_files EXIT INT TERM

