#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 0b Parallel Bootstrap Module
# Version: 1.0.0
# Purpose: Parallel documentation generation for faster bootstrap
#
# Splits documentation generation into 5 parallel tasks:
#   1. API Documentation (functions, classes, REST APIs)
#   2. Architecture Documentation (system design, data flow, components)
#   3. User Guides (getting started, tutorials, how-to)
#   4. Developer Guides (contributing, testing, deployment)
#   5. Code Documentation (inline comments, docstrings, headers)
#
# Expected Performance:
#   - Sequential: ~301s (current)
#   - Parallel: ~90-120s (5 tasks × 60s / 5 cores)
#   - Savings: 151-211 seconds (50-70% faster)
################################################################################

# Get script directory
STEP0B_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${STEP0B_LIB_DIR}/../../lib"

# Source required modules
if [[ -f "${WORKFLOW_LIB_DIR}/ai_helpers.sh" ]]; then
    source "${WORKFLOW_LIB_DIR}/ai_helpers.sh"
fi

# ==============================================================================
# PARALLEL TASK FUNCTIONS
# ==============================================================================

# Task 1: Generate API Documentation
# Args: $1 = output file, $2 = project context
generate_api_documentation() {
    local output_file="$1"
    local project_name="${2:-Unknown Project}"
    local primary_language="${3:-}"
    
    local prompt=$(cat << EOF
You are a technical writer specializing in API documentation.

**PROJECT**: ${project_name}
**LANGUAGE**: ${primary_language}

**TASK**: Create comprehensive API documentation for this project.

**FOCUS ON**:
1. **Public Functions/Methods**: Document all public APIs with parameters, return values, and examples
2. **REST Endpoints**: Document HTTP endpoints if applicable (method, path, request/response)
3. **Classes/Modules**: Document exported classes and modules
4. **Usage Examples**: Provide code examples for common use cases
5. **Error Handling**: Document error codes and exception handling

**FORMAT**:
- Use Markdown with clear section headers
- Include code examples in appropriate language code blocks
- Add parameter tables where applicable
- Include return value documentation
- Link related APIs together

**IMPORTANT**: Focus ONLY on API documentation. Do not include architecture, user guides, or other documentation types.
EOF
)
    
    if declare -f call_ai_helper &>/dev/null; then
        call_ai_helper "technical_writer" "$prompt" "$output_file"
    else
        echo "# API Documentation" > "$output_file"
        echo "" >> "$output_file"
        echo "AI helper not available. API documentation generation skipped." >> "$output_file"
    fi
    
    return $?
}

# Task 2: Generate Architecture Documentation
# Args: $1 = output file, $2 = project context
generate_architecture_docs() {
    local output_file="$1"
    local project_name="${2:-Unknown Project}"
    local primary_language="${3:-}"
    
    local prompt=$(cat << EOF
You are a technical writer specializing in software architecture documentation.

**PROJECT**: ${project_name}
**LANGUAGE**: ${primary_language}

**TASK**: Create comprehensive architecture documentation for this project.

**FOCUS ON**:
1. **System Overview**: High-level architecture diagram and description
2. **Components**: Major system components and their responsibilities
3. **Data Flow**: How data moves through the system
4. **Design Patterns**: Architectural patterns used (MVC, microservices, etc.)
5. **Technology Stack**: Key technologies and frameworks
6. **Integration Points**: External systems and APIs

**FORMAT**:
- Use Markdown with clear section headers
- Include Mermaid diagrams where helpful (flowcharts, sequence diagrams)
- Organize hierarchically (system → subsystems → components)
- Keep it high-level (not implementation details)

**IMPORTANT**: Focus ONLY on architecture documentation. Do not include API details, user guides, or other documentation types.
EOF
)
    
    if declare -f call_ai_helper &>/dev/null; then
        call_ai_helper "technical_writer" "$prompt" "$output_file"
    else
        echo "# Architecture Documentation" > "$output_file"
        echo "" >> "$output_file"
        echo "AI helper not available. Architecture documentation generation skipped." >> "$output_file"
    fi
    
    return $?
}

# Task 3: Generate User Guides
# Args: $1 = output file, $2 = project context
generate_user_guides() {
    local output_file="$1"
    local project_name="${2:-Unknown Project}"
    local primary_language="${3:-}"
    
    local prompt=$(cat << EOF
You are a technical writer specializing in user-facing documentation.

**PROJECT**: ${project_name}
**LANGUAGE**: ${primary_language}

**TASK**: Create comprehensive user guides for this project.

**FOCUS ON**:
1. **Getting Started**: Installation, setup, and first use
2. **Tutorials**: Step-by-step guides for common tasks
3. **How-To Guides**: Task-oriented instructions
4. **Configuration**: How to configure the application
5. **Troubleshooting**: Common issues and solutions
6. **FAQ**: Frequently asked questions

**FORMAT**:
- Use Markdown with clear section headers
- Include numbered steps for procedures
- Add screenshots or CLI examples where helpful
- Write for non-technical users when possible
- Include prerequisites and requirements

**IMPORTANT**: Focus ONLY on user guides. Do not include API documentation, architecture details, or developer guides.
EOF
)
    
    if declare -f call_ai_helper &>/dev/null; then
        call_ai_helper "technical_writer" "$prompt" "$output_file"
    else
        echo "# User Guides" > "$output_file"
        echo "" >> "$output_file"
        echo "AI helper not available. User guide generation skipped." >> "$output_file"
    fi
    
    return $?
}

# Task 4: Generate Developer Guides
# Args: $1 = output file, $2 = project context
generate_developer_guides() {
    local output_file="$1"
    local project_name="${2:-Unknown Project}"
    local primary_language="${3:-}"
    
    local prompt=$(cat << EOF
You are a technical writer specializing in developer documentation.

**PROJECT**: ${project_name}
**LANGUAGE**: ${primary_language}

**TASK**: Create comprehensive developer guides for this project.

**FOCUS ON**:
1. **Contributing**: How to contribute to the project
2. **Development Setup**: Local development environment setup
3. **Testing**: How to run and write tests
4. **Building**: Build process and tooling
5. **Deployment**: Deployment procedures and best practices
6. **Code Style**: Coding standards and conventions
7. **Pull Request Process**: How to submit changes

**FORMAT**:
- Use Markdown with clear section headers
- Include command examples
- Add code snippets for common development tasks
- Link to relevant tools and resources
- Include CI/CD information if applicable

**IMPORTANT**: Focus ONLY on developer guides. Do not include user guides, API documentation, or architecture details.
EOF
)
    
    if declare -f call_ai_helper &>/dev/null; then
        call_ai_helper "technical_writer" "$prompt" "$output_file"
    else
        echo "# Developer Guides" > "$output_file"
        echo "" >> "$output_file"
        echo "AI helper not available. Developer guide generation skipped." >> "$output_file"
    fi
    
    return $?
}

# Task 5: Generate Code Documentation Review
# Args: $1 = output file, $2 = project context
generate_code_docs() {
    local output_file="$1"
    local project_name="${2:-Unknown Project}"
    local primary_language="${3:-}"
    
    local prompt=$(cat << EOF
You are a technical writer reviewing code documentation quality.

**PROJECT**: ${project_name}
**LANGUAGE**: ${primary_language}

**TASK**: Analyze code documentation and provide recommendations.

**FOCUS ON**:
1. **Inline Comments**: Review quality of code comments
2. **Docstrings/JSDoc**: Check function documentation
3. **File Headers**: Verify file-level documentation
4. **Module Documentation**: Check module/package docs
5. **Missing Documentation**: Identify undocumented areas
6. **Recommendations**: Suggest improvements

**FORMAT**:
- Use Markdown with clear section headers
- Provide specific examples of good/bad documentation
- Include actionable recommendations
- Prioritize high-impact improvements
- Reference specific files where possible

**IMPORTANT**: Focus ONLY on code documentation review. Do not include user guides, API docs, or architecture details.
EOF
)
    
    if declare -f call_ai_helper &>/dev/null; then
        call_ai_helper "technical_writer" "$prompt" "$output_file"
    else
        echo "# Code Documentation Review" > "$output_file"
        echo "" >> "$output_file"
        echo "AI helper not available. Code documentation review skipped." >> "$output_file"
    fi
    
    return $?
}

# ==============================================================================
# PARALLEL EXECUTION
# ==============================================================================

# Execute all 5 documentation tasks in parallel
# Args: $1 = output directory, $2 = project name, $3 = primary language
# Returns: 0 on success, 1 on failure
execute_parallel_bootstrap() {
    local output_dir="$1"
    local project_name="${2:-Unknown Project}"
    local primary_language="${3:-}"
    
    print_info "Launching 5 parallel documentation generation tasks..."
    
    # Create output directory
    mkdir -p "$output_dir"
    
    # Task definitions
    declare -a tasks=(
        "api:generate_api_documentation"
        "architecture:generate_architecture_docs"
        "user:generate_user_guides"
        "developer:generate_developer_guides"
        "code:generate_code_docs"
    )
    
    # Launch all tasks in parallel
    local task_pids=()
    for task in "${tasks[@]}"; do
        IFS=':' read -r name func <<< "$task"
        local task_output="${output_dir}/${name}_docs.md"
        local task_log="${output_dir}/${name}_task.log"
        
        (
            print_info "Task ${name}: Starting..."
            if $func "$task_output" "$project_name" "$primary_language" > "$task_log" 2>&1; then
                print_success "Task ${name}: Complete"
                echo "SUCCESS" > "${output_dir}/${name}_status.txt"
            else
                print_error "Task ${name}: Failed"
                echo "FAILED" > "${output_dir}/${name}_status.txt"
            fi
        ) &
        
        task_pids+=($!)
    done
    
    # Wait for all tasks to complete
    print_info "Waiting for all ${#tasks[@]} tasks to complete..."
    local failed_count=0
    
    for pid in "${task_pids[@]}"; do
        if ! wait "$pid"; then
            ((failed_count++))
        fi
    done
    
    # Check results
    if [[ $failed_count -gt 0 ]]; then
        print_warning "$failed_count task(s) failed"
        return 1
    else
        print_success "All ${#tasks[@]} tasks completed successfully"
        return 0
    fi
}

# ==============================================================================
# RESULT AGGREGATION
# ==============================================================================

# Aggregate parallel bootstrap results into single report
# Args: $1 = output directory, $2 = final output file
aggregate_bootstrap_results() {
    local output_dir="$1"
    local final_output="${2:-${output_dir}/step0b_bootstrap_documentation.md}"
    
    print_info "Aggregating parallel documentation results..."
    
    # Create final output file with header
    cat > "$final_output" << 'EOF'
# Documentation Bootstrap Report

**Generated**: $(date '+%Y-%m-%d %H:%M:%S')
**Method**: Parallel Generation (5 concurrent tasks)

---

EOF
    
    # Aggregate each category
    local categories=("api" "architecture" "user" "developer" "code")
    local category_names=("API Documentation" "Architecture Documentation" "User Guides" "Developer Guides" "Code Documentation Review")
    
    for i in "${!categories[@]}"; do
        local category="${categories[$i]}"
        local category_name="${category_names[$i]}"
        local doc_file="${output_dir}/${category}_docs.md"
        local status_file="${output_dir}/${category}_status.txt"
        
        # Add section header
        echo "## ${category_name}" >> "$final_output"
        echo "" >> "$final_output"
        
        # Check if task succeeded
        if [[ -f "$status_file" ]] && [[ "$(cat "$status_file")" == "SUCCESS" ]]; then
            if [[ -f "$doc_file" ]]; then
                # Append documentation (skip the first heading line to avoid duplication)
                tail -n +2 "$doc_file" >> "$final_output"
            else
                echo "*Documentation file not found*" >> "$final_output"
            fi
        else
            echo "*Task failed or did not complete*" >> "$final_output"
        fi
        
        echo "" >> "$final_output"
        echo "---" >> "$final_output"
        echo "" >> "$final_output"
    done
    
    # Add footer
    cat >> "$final_output" << 'EOF'

## Generation Summary

This documentation was automatically generated using parallel AI processing:
- 5 concurrent documentation tasks
- Estimated time: 90-120 seconds (vs 301 seconds sequential)
- Savings: 50-70% faster

**Quality Note**: Review and refine generated content before publishing.

---

*Generated by AI Workflow Automation - Step 0b Parallel Bootstrap*
EOF
    
    print_success "Aggregated results: $final_output"
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f generate_api_documentation
export -f generate_architecture_docs
export -f generate_user_guides
export -f generate_developer_guides
export -f generate_code_docs
export -f execute_parallel_bootstrap
export -f aggregate_bootstrap_results
