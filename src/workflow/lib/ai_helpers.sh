#!/bin/bash
################################################################################
# AI Helpers Module
# Purpose: AI prompt templates and Copilot CLI integration helpers
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

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
# Step 1: Build a documentation analysis prompt
# Build documentation analysis prompt
# Usage: build_doc_analysis_prompt <changed_files> <doc_files>
build_doc_analysis_prompt() {
    local changed_files="$1"
    local doc_files="$2"
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role (quoted string on same line)
        role=$(grep 'role:' "$yaml_file" | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
        # Extract task template (multiline after |)
        task_template=$(awk '/task_template: \|/{flag=1; next} /^[[:space:]]*approach:/{flag=0} flag && /^[[:space:]]{4}/' "$yaml_file" | sed 's/^[[:space:]]*//')
        
        # Extract approach (multiline after |)
        approach=$(awk '/approach: \|/{flag=1; next} /^$/{if(flag) exit} flag && /^[[:space:]]{4}/' "$yaml_file" | sed 's/^[[:space:]]*//')
        
        # Replace placeholders in task template
        local task="${task_template//\{changed_files\}/$changed_files}"
        task="${task//\{doc_files\}/$doc_files}"
        
        build_ai_prompt "$role" "$task" "$approach"
    else
        # Fallback to hardcoded strings if YAML not available
        build_ai_prompt \
            "You are a senior technical documentation specialist with expertise in software architecture documentation, API documentation, and developer experience (DX) optimization." \
            "Based on the recent changes to the following files: ${changed_files}

Please update all related documentation including:
1. .github/copilot-instructions.md - Update project overview, architecture patterns, key files
2. README.md - Update if public-facing features or setup instructions changed
3. /docs/ directory - Update technical documentation for architecture or feature changes
4. shell_scripts/README.md - Update if shell scripts were modified
5. Inline code comments - Add/update comments for complex logic

Documentation to review: ${doc_files}" \
            "- Analyze the git diff to understand what changed
- Update only the documentation sections affected by these changes
- Be surgical and precise - don't modify unrelated documentation
- Ensure consistency in terminology, formatting, and style
- Maintain professional technical writing standards"
    fi
}

# Build a consistency analysis prompt
# Usage: build_consistency_prompt <files_to_check>
# Step 2: Build a documentation consistency analysis prompt
build_consistency_prompt() {
    local files_to_check="$1"
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
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
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
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
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
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
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
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
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
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
        
        # Replace placeholders in task template
        local task="${task_template//\{doc_count\}/$doc_count}"
        task="${task//\{change_scope\}/$change_scope}"
        task="${task//\{modified_count\}/$modified_count}"
        task="${task//\{broken_refs_content\}/$broken_refs_content}"
        task="${task//\{doc_files\}/$doc_files}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        cat << EOF
**Role**: You are a senior technical documentation specialist and information architect with expertise in documentation quality assurance, technical writing standards, and cross-reference validation.

**Task**: Perform a comprehensive documentation consistency analysis for this project.

**Context:**
- Project: MP Barbosa Personal Website (static HTML with Material Design)
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
   - Compare .github/copilot-instructions.md with README.md
   - Check if shell_scripts/README.md matches actual scripts in shell_scripts/
   - Verify package.json scripts match documented commands

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
# Usage: build_step3_script_refs_prompt <script_count> <change_scope> <issues> <script_issues> <all_scripts>
build_step3_script_refs_prompt() {
    local script_count="$1"
    local change_scope="$2"
    local issues="$3"
    local script_issues_content="$4"
    local all_scripts="$5"
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
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
        
        # Replace placeholders in task template
        local task="${task_template//\{script_count\}/$script_count}"
        task="${task//\{change_scope\}/$change_scope}"
        task="${task//\{issues\}/$issues}"
        task="${task//\{script_issues_content\}/$script_issues_content}"
        task="${task//\{all_scripts\}/$all_scripts}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        cat << EOF
**Role**: You are a senior technical documentation specialist and DevOps documentation expert with expertise in shell script documentation, automation workflow documentation, and command-line tool reference guides.

**Task**: Perform comprehensive validation of shell script references and documentation quality for this project's automation scripts.

**Context:**
- Project: MP Barbosa Personal Website
- Shell Scripts Directory: shell_scripts/
- Total Scripts: ${script_count}
- Scope: ${change_scope}
- Issues Found in Phase 1: ${issues}

**Phase 1 Automated Findings:**
${script_issues_content}

**Available Scripts:**
${all_scripts}

**Validation Tasks:**

1. **Script-to-Documentation Mapping:**
   - Verify every script in shell_scripts/ is documented in shell_scripts/README.md
   - Check that documented scripts actually exist
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

4. **Shell Script Best Practices:**
   - Executable permissions properly documented
   - Shebang lines mentioned in documentation where relevant
   - Environment variable requirements documented
   - Error handling and exit codes documented

5. **Integration Documentation:**
   - Workflow relationships between scripts documented
   - Execution order or dependencies clarified
   - Common use cases and examples provided
   - Troubleshooting guidance available

**Files to Analyze:**
- shell_scripts/README.md
- All .sh files in shell_scripts/
- .github/copilot-instructions.md (for shell script references)
- Main README.md (for automation workflow mentions)

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
# Usage: build_step4_directory_prompt <dir_count> <change_scope> <missing_critical> <undocumented_dirs> <doc_mismatch> <structure_issues> <dir_tree>
build_step4_directory_prompt() {
    local dir_count="$1"
    local change_scope="$2"
    local missing_critical="$3"
    local undocumented_dirs="$4"
    local doc_structure_mismatch="$5"
    local structure_issues_content="$6"
    local dir_tree="$7"
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
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
        
        # Replace placeholders in task template
        local task="${task_template//\{dir_count\}/$dir_count}"
        task="${task//\{change_scope\}/$change_scope}"
        task="${task//\{missing_critical\}/$missing_critical}"
        task="${task//\{undocumented_dirs\}/$undocumented_dirs}"
        task="${task//\{doc_structure_mismatch\}/$doc_structure_mismatch}"
        task="${task//\{structure_issues_content\}/$structure_issues_content}"
        task="${task//\{dir_tree\}/$dir_tree}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        cat << EOF
**Role**: You are a senior software architect and technical documentation specialist with expertise in project structure conventions, architectural patterns, code organization best practices, and documentation alignment.

**Task**: Perform comprehensive validation of directory structure and architectural organization for this project.

**Context:**
- Project: MP Barbosa Personal Website (static HTML with Material Design + submodules)
- Total Directories: ${dir_count} (excluding node_modules, .git, coverage)
- Scope: ${change_scope}
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
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
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
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        cat << EOF
**Role**: You are a senior QA engineer and test automation specialist with expertise in testing strategies, Jest framework, code coverage analysis, test-driven development (TDD), behavior-driven development (BDD), and continuous integration best practices.

**Task**: Perform comprehensive review of existing tests and provide recommendations for test generation and coverage improvement.

**Context:**
- Project: MP Barbosa Personal Website (static HTML + JavaScript with ES Modules)
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
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
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
        
        # Replace placeholders in task template
        local task="${task_template//\{test_exit_code\}/$test_exit_code}"
        task="${task//\{tests_total\}/$tests_total}"
        task="${task//\{tests_passed\}/$tests_passed}"
        task="${task//\{tests_failed\}/$tests_failed}"
        task="${task//\{execution_summary\}/$execution_summary}"
        task="${task//\{test_output\}/$test_output}"
        task="${task//\{failed_test_list\}/$failed_test_list}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        cat << EOF
**Role**: You are a senior CI/CD engineer and test results analyst with expertise in test execution diagnostics, failure root cause analysis, code coverage interpretation, performance optimization, and continuous integration best practices.

**Task**: Analyze test execution results, diagnose failures, and provide actionable recommendations for improving test suite quality and CI/CD integration.

**Context:**
- Project: MP Barbosa Personal Website (static HTML + JavaScript with ES Modules)
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
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
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
        task="${task//\{outdated_list\}/$outdated_list}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        cat << EOF
**Role**: You are a senior DevOps engineer and package management specialist with expertise in npm/yarn ecosystem, security vulnerability assessment, version compatibility analysis, dependency tree optimization, and environment configuration best practices.

**Task**: Analyze project dependencies, assess security risks, evaluate version compatibility, and provide recommendations for dependency management and environment setup.

**Context:**
- Project: MP Barbosa Personal Website (static HTML + JavaScript with ES Modules)
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
build_step9_code_quality_prompt() {
    local total_files="$1"
    local js_files="$2"
    local html_files="$3"
    local css_files="$4"
    local quality_summary="$5"
    local quality_report_content="$6"
    local large_files_list="$7"
    local sample_code="$8"
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
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
        
        # Replace placeholders in task template
        local task="${task_template//\{total_files\}/$total_files}"
        task="${task//\{js_files\}/$js_files}"
        task="${task//\{html_files\}/$html_files}"
        task="${task//\{css_files\}/$css_files}"
        task="${task//\{quality_summary\}/$quality_summary}"
        task="${task//\{quality_report_content\}/$quality_report_content}"
        task="${task//\{large_files_list\}/$formatted_large_files}"
        task="${task//\{sample_code\}/$sample_code}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        cat << EOF
**Role**: You are a senior software quality engineer and code review specialist with expertise in code quality standards, static analysis, linting best practices, design patterns, maintainability assessment, and technical debt identification.

**Task**: Perform comprehensive code quality review, identify anti-patterns, assess maintainability, and provide recommendations for improving code quality and reducing technical debt.

**Context:**
- Project: MP Barbosa Personal Website (static HTML + JavaScript with ES Modules)
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
    local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"
    
    # Read from YAML config if available
    if [[ -f "$yaml_file" ]]; then
        local role
        local task_template
        local approach
        
        # Extract role from step11_git_commit_prompt section
        role=$(sed -n '/^step11_git_commit_prompt:/,/^[a-z_]/p' "$yaml_file" | grep 'role:' | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
        
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
        
        # Replace placeholders in task template
        local task="${task_template//\{script_version\}/$script_version}"
        task="${task//\{change_scope\}/${change_scope:-General updates}}"
        task="${task//\{git_context\}/$git_context}"
        task="${task//\{changed_files\}/$changed_files}"
        task="${task//\{diff_summary\}/$diff_summary}"
        task="${task//\{git_analysis_content\}/$git_analysis_content}"
        task="${task//\{diff_sample\}/$diff_sample}"
        
        # Replace placeholders in approach
        local final_approach="${approach//\{script_version\}/$script_version}"
        
        cat << EOF
**Role**: ${role}

**Task**: ${task}

**Approach**: ${final_approach}
EOF
    else
        # Fallback to hardcoded strings if YAML not available
        cat << EOF
**Role**: You are a senior git workflow specialist and technical communication expert with expertise in conventional commits, semantic versioning, git best practices, technical writing, and commit message optimization.

**Task**: Generate a professional conventional commit message that clearly communicates the changes, follows best practices, and provides useful context for code reviewers and future maintainers.

**Context:**
- Project: MP Barbosa Personal Website (static HTML + JavaScript with ES Modules)
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
# AI PROMPT EXECUTION
# ==============================================================================

# Execute a Copilot CLI prompt with proper error handling
# Usage: execute_copilot_prompt <prompt_text> [log_file]
execute_copilot_prompt() {
    local prompt_text="$1"
    local log_file="${2:-}"
    
    if [[ "$AUTO_MODE" == true ]]; then
        print_info "Auto mode: Skipping AI prompt execution"
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
    
    # Write prompt to temporary file to avoid ARG_MAX limit
    local temp_prompt_file
    temp_prompt_file=$(mktemp)
    echo "$prompt_text" > "$temp_prompt_file"
    
    if [[ -n "$log_file" ]]; then
        # Ensure the parent directory exists
        local log_dir
        log_dir=$(dirname "$log_file")
        mkdir -p "$log_dir"
        
        # Use stdin to avoid ARG_MAX: read prompt from file and pipe to copilot
        cat "$temp_prompt_file" | copilot --allow-all-tools 2>&1 | tee "$log_file"
    else
        cat "$temp_prompt_file" | copilot --allow-all-tools
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
            copilot -p "$extract_prompt" --allow-all-tools
            
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
