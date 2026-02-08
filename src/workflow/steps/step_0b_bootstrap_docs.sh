#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 0b: Documentation Gap Analysis & Generation
# Purpose: Identify missing documentation and generate it using AI
# Part of: Tests & Documentation Workflow Automation v5.0.0
# Version: 2.0.0 (Updated to focus on gap analysis)
#
# AI PERSONA: Technical Writer
# Use case: Analyze existing documentation, identify gaps, and generate missing pieces
# Complements:
#   - Step 1 (doc_analysis_prompt): Incremental change-driven documentation updates
#   - Step 2 (consistency_prompt): Documentation quality assurance and auditing
#
# Covers:
#   - Documentation gap analysis (what's missing or incomplete)
#   - API documentation (functions, classes, modules, REST APIs)
#   - Architecture documentation (system design, data flow, components)
#   - User guides (getting started, tutorials, how-to guides)
#   - Developer guides (contributing, testing, deployment)
#   - Code documentation (inline comments, docstrings, headers)
################################################################################

# Module version information
readonly STEP0B_VERSION="2.0.0"
readonly STEP0B_VERSION_MAJOR=1
readonly STEP0B_VERSION_MINOR=0
readonly STEP0B_VERSION_PATCH=0

# Get script directory for sourcing modules
STEP0B_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source core library modules
WORKFLOW_LIB_DIR="${STEP0B_DIR}/../lib"

# Source AI helpers module (required for technical_writer_prompt)
# shellcheck source=../lib/ai_helpers.sh
if [[ -f "${WORKFLOW_LIB_DIR}/ai_helpers.sh" ]]; then
    source "${WORKFLOW_LIB_DIR}/ai_helpers.sh"
fi

# Source tech stack detection (for language-specific documentation standards)
# shellcheck source=../lib/tech_stack.sh
if [[ -f "${WORKFLOW_LIB_DIR}/tech_stack.sh" ]]; then
    source "${WORKFLOW_LIB_DIR}/tech_stack.sh"
fi

# Source parallel bootstrap module (v3.3.0)
# shellcheck source=step_0b_lib/parallel_bootstrap.sh
if [[ -f "${STEP0B_DIR}/step_0b_lib/parallel_bootstrap.sh" ]]; then
    source "${STEP0B_DIR}/step_0b_lib/parallel_bootstrap.sh"
fi

# ==============================================================================
# VALIDATION FUNCTIONS
# ==============================================================================

# Validate if step 0b should run
# Returns: 0 if should run, 1 if should skip
validate_step_0b() {
    # Check if explicitly skipped
    if [[ "${SKIP_STEP_0B:-false}" == "true" ]]; then
        print_info "Step 0b skipped (SKIP_STEP_0B=true)"
        return 1
    fi
    
    # Check if bootstrapping is needed based on documentation count
    if declare -f count_documentation_files &>/dev/null; then
        local doc_count
        doc_count=$(count_documentation_files)
        
        # Skip if project has substantial documentation (5+ files)
        if [[ $doc_count -ge 5 ]]; then
            print_info "Step 0b: Sufficient documentation exists ($doc_count files) - skipping bootstrap"
            return 1
        fi
    fi
    
    return 0  # Ready to run
}

# Determine if documentation bootstrapping is needed
# Returns: 0 if should bootstrap, 1 otherwise
should_bootstrap() {
    local doc_count
    doc_count=$(count_documentation_files)
    
    # Check README.md
    if [[ ! -f "README.md" ]] || [[ $(wc -c < "README.md" 2>/dev/null || echo 0) -lt 500 ]]; then
        return 0  # Need to bootstrap
    fi
    
    # Check docs/ directory
    if [[ ! -d "docs" ]] || [[ $doc_count -lt 2 ]]; then
        return 0  # Need to bootstrap
    fi
    
    # Check CHANGELOG.md
    if [[ ! -f "CHANGELOG.md" ]]; then
        return 0  # Need to bootstrap
    fi
    
    return 1  # No bootstrap needed
}

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Get module version information
# Usage: step0b_get_version [--format=simple|full|semver]
# Returns: Version string
step0b_get_version() {
    local format="${1:---format=full}"
    format="${format#--format=}"
    
    case "$format" in
        simple)
            echo "$STEP0B_VERSION"
            ;;
        semver)
            echo "${STEP0B_VERSION_MAJOR}.${STEP0B_VERSION_MINOR}.${STEP0B_VERSION_PATCH}"
            ;;
        full|*)
            echo "Step 0b: Documentation Gap Analysis v${STEP0B_VERSION}"
            echo "  Major: $STEP0B_VERSION_MAJOR"
            echo "  Minor: $STEP0B_VERSION_MINOR"
            echo "  Patch: $STEP0B_VERSION_PATCH"
            echo "  Purpose: Identify and generate missing documentation"
            ;;
    esac
}

# Count existing documentation files
# Returns: Number of markdown files (excluding node_modules, .git, etc.)
count_documentation_files() {
    local doc_count=0
    
    # Count markdown files
    if command -v find_with_exclusions &>/dev/null; then
        doc_count=$(find_with_exclusions "." "*.md" 10 | wc -l)
    else
        doc_count=$(find . -name "*.md" -type f \
            ! -path "*/node_modules/*" \
            ! -path "*/.git/*" \
            ! -path "*/venv/*" \
            ! -path "*/vendor/*" \
            ! -path "*/build/*" \
            ! -path "*/dist/*" \
            2>/dev/null | wc -l || echo "0")
    fi
    
    echo "$doc_count"
}

# Get source file count for context
# Returns: Number of source code files
count_source_files() {
    local source_count=0
    
    # Count common source file extensions
    if command -v find_with_exclusions &>/dev/null; then
        source_count=$(find_with_exclusions "." "*.js" 10 | wc -l)
        source_count=$((source_count + $(find_with_exclusions "." "*.py" 10 | wc -l)))
        source_count=$((source_count + $(find_with_exclusions "." "*.sh" 10 | wc -l)))
        source_count=$((source_count + $(find_with_exclusions "." "*.ts" 10 | wc -l)))
        source_count=$((source_count + $(find_with_exclusions "." "*.go" 10 | wc -l)))
        source_count=$((source_count + $(find_with_exclusions "." "*.java" 10 | wc -l)))
    else
        source_count=$(find . \( -name "*.js" -o -name "*.py" -o -name "*.sh" -o -name "*.ts" -o -name "*.go" -o -name "*.java" \) -type f \
            ! -path "*/node_modules/*" \
            ! -path "*/.git/*" \
            ! -path "*/venv/*" \
            ! -path "*/vendor/*" \
            ! -path "*/build/*" \
            ! -path "*/dist/*" \
            2>/dev/null | wc -l || echo "0")
    fi
    
    echo "$source_count"
}

# Build technical writer prompt using template from ai_helpers.yaml
# Usage: build_technical_writer_prompt
# Returns: Complete AI prompt string
build_technical_writer_prompt() {
    local project_name="${PROJECT_NAME:-Unknown Project}"
    local project_description="${PROJECT_DESCRIPTION:-No description available}"
    local primary_language="${PRIMARY_LANGUAGE:-Not detected}"
    local doc_count
    local source_count
    
    doc_count=$(count_documentation_files)
    source_count=$(count_source_files)
    
    # Get project metadata if available
    if declare -f get_project_metadata &>/dev/null; then
        local metadata
        metadata=$(get_project_metadata)
        if [[ -n "$metadata" ]]; then
            project_name=$(echo "$metadata" | cut -d'|' -f1)
            project_description=$(echo "$metadata" | cut -d'|' -f2)
            primary_language=$(echo "$metadata" | cut -d'|' -f3)
        fi
    fi
    
    # Get language-specific documentation standards if available
    local language_standards=""
    if declare -f get_language_specific_documentation &>/dev/null && [[ -n "$primary_language" ]]; then
        language_standards=$(get_language_specific_documentation "$primary_language")
    fi
    
    # Load technical_writer_prompt template from ai_helpers.yaml
    local config_file="${AI_HELPERS_WORKFLOW_DIR}/../.workflow_core/config/ai_helpers.yaml"
    local role=""
    local task=""
    local approach=""
    
    if [[ -f "$config_file" ]]; then
        # Extract role (using role_prefix if available, fallback to role)
        role=$(awk '/^technical_writer_prompt:/,/^[a-z_]+_prompt:/{
            if (/^  role_prefix:/) {
                flag=1; next
            }
            if (flag && /^  [a-z]/) {
                exit
            }
            if (flag && /^    /) {
                sub(/^    /, ""); print
            }
        }' "$config_file")
        
        # If role_prefix is empty, try legacy role field
        if [[ -z "$role" ]]; then
            role=$(awk '/^technical_writer_prompt:/,/^[a-z_]+_prompt:/{
                if (/^  role:/) {
                    flag=1; next
                }
                if (flag && /^  [a-z]/) {
                    exit
                }
                if (flag && /^    /) {
                    sub(/^    /, ""); print
                }
            }' "$config_file")
        fi
        
        # Extract task_template
        task=$(awk '/^technical_writer_prompt:/,/^[a-z_]+_prompt:/{
            if (/^  task_template:/) {
                flag=1; next
            }
            if (flag && /^  [a-z]/) {
                exit
            }
            if (flag && /^    /) {
                sub(/^    /, ""); print
            }
        }' "$config_file")
        
        # Extract approach
        approach=$(awk '/^technical_writer_prompt:/,/^[a-z_]+_prompt:/{
            if (/^  approach:/) {
                flag=1; next
            }
            if (flag && /^  [a-z]/ && !/^    /) {
                exit
            }
            if (flag && /^    /) {
                sub(/^    /, ""); print
            }
        }' "$config_file")
    fi
    
    # Fallback if template loading failed
    if [[ -z "$role" ]]; then
        role="You are a senior technical writer and documentation architect with expertise in creating comprehensive documentation from scratch for undocumented codebases."
    fi
    
    if [[ -z "$task" ]]; then
        task="Create comprehensive documentation for this project. Focus on API documentation, architecture guides, user guides, and developer documentation."
    fi
    
    if [[ -z "$approach" ]]; then
        approach="Analyze the codebase, prioritize high-impact documentation, create content systematically, and ensure accuracy with proper examples."
    fi
    
    # Substitute placeholders in task template
    task="${task//\{project_name\}/$project_name}"
    task="${task//\{project_description\}/$project_description}"
    task="${task//\{primary_language\}/$primary_language}"
    task="${task//\{doc_count\}/$doc_count}"
    task="${task//\{source_files\}/$source_count}"
    
    # Substitute language-specific standards in approach
    if [[ -n "$language_standards" ]]; then
        approach="${approach//\{language_specific_documentation\}/$language_standards}"
    else
        approach="${approach//\{language_specific_documentation\}/No language-specific standards available}"
    fi
    
    # Build complete prompt using ai_helpers pattern
    if declare -f build_ai_prompt &>/dev/null; then
        build_ai_prompt "$role" "$task" "$approach"
    else
        # Fallback: simple concatenation
        cat <<EOF
**ROLE:**
$role

**TASK:**
$task

**APPROACH:**
$approach
EOF
    fi
}

# Execute AI documentation generation
# Usage: execute_ai_bootstrap_documentation <output_file> <log_file>
# Returns: 0 on success, 1 on failure
execute_ai_bootstrap_documentation() {
    local output_file="${1:-${BACKLOG_RUN_DIR}/step0b_bootstrap_documentation.md}"
    local log_file="${2:-}"
    
    # Build AI prompt
    local prompt
    prompt=$(build_technical_writer_prompt)
    
    if [[ -z "$prompt" ]]; then
        print_error "Failed to build AI prompt"
        return 1
    fi
    
    print_info "Executing AI documentation gap analysis..."
    print_info "Output will be saved to: $output_file"
    if [[ -n "$log_file" ]]; then
        print_info "Log file: $log_file"
    fi
    
    # Use AI cache if available
    local cache_key=""
    if declare -f generate_cache_key &>/dev/null; then
        cache_key=$(generate_cache_key "technical_writer" "$prompt")
    fi
    
    # Check cache first
    if [[ -n "$cache_key" ]] && declare -f get_cached_response &>/dev/null; then
        local cached_response
        if cached_response=$(get_cached_response "$cache_key"); then
            print_success "Using cached AI response"
            echo "$cached_response" > "$output_file"
            return 0
        fi
    fi
    
    # Use standard execute_copilot_prompt function for consistency
    # This handles AUTO_MODE, logging, and error handling
    if declare -f execute_copilot_prompt &>/dev/null; then
        if execute_copilot_prompt "$prompt" "$log_file" "0b" "technical_writer"; then
            # If log file was created, save it to output file as well
            if [[ -n "$log_file" && -f "$log_file" ]]; then
                cp "$log_file" "$output_file"
            fi
            print_success "AI documentation gap analysis completed"
            return 0
        else
            print_warning "AI analysis not available or failed"
            # Fall through to create placeholder
        fi
    fi
    
    # Fallback: Create placeholder report if Copilot not available
    print_warning "GitHub Copilot CLI not available"
    print_info "Creating placeholder documentation gap report"
    
    cat > "$output_file" <<EOF
# Documentation Gap Analysis - Step 0b

**Status**: ⚠️ Skipped (Copilot CLI not available)

## Project Context
- Project: ${PROJECT_NAME:-Unknown}
- Primary Language: ${PRIMARY_LANGUAGE:-Not detected}
- Documentation Files: $(count_documentation_files)
- Source Files: $(count_source_files)

## Action Required
GitHub Copilot CLI is not available. To enable AI-powered documentation gap analysis:
1. Install Copilot CLI: \`npm install -g @githubnext/github-copilot-cli\`
2. Authenticate: Run \`copilot\` and use the \`/login\` command
3. Re-run this workflow

## Manual Gap Analysis Checklist
Consider reviewing these common documentation gaps:
- [ ] README.md completeness (overview, installation, usage, examples)
- [ ] docs/ARCHITECTURE.md with system design and components
- [ ] docs/API.md with comprehensive function/class/module documentation
- [ ] docs/CONTRIBUTING.md with development setup and guidelines
- [ ] docs/DEPLOYMENT.md with build and release process
- [ ] Inline code comments for complex logic
- [ ] User guides and tutorials
- [ ] Troubleshooting and FAQ sections
EOF
    return 0
}

# ==============================================================================
# MAIN STEP FUNCTION
# ==============================================================================

# Main entry point for Step 0b
# Purpose: Analyze documentation gaps and generate missing documentation using technical_writer AI persona
# Returns: 0 on success, non-zero on failure
step0b_bootstrap_documentation() {
    print_section "Step 0b: Documentation Gap Analysis & Generation"
    
    # Set up cleanup for temporary files
    local temp_files=()
    
    # Cleanup function
    cleanup_step0b() {
        for file in "${temp_files[@]}"; do
            rm -f "$file" 2>/dev/null || true
        done
    }
    trap cleanup_step0b EXIT
    
    # Get project context
    local doc_count
    local source_count
    doc_count=$(count_documentation_files)
    source_count=$(count_source_files)
    
    print_info "Documentation files found: $doc_count"
    print_info "Source files found: $source_count"
    print_info "Primary language: ${PRIMARY_LANGUAGE:-Not detected}"
    
    # Determine if bootstrapping is needed
    local bootstrap_needed=false
    if should_bootstrap; then
        bootstrap_needed=true
        print_warning "No documentation found - will generate from scratch"
    else
        print_info "Analyzing existing documentation for gaps..."
    fi
    
    # Check if Copilot is available
    if ! is_copilot_available; then
        print_warning "GitHub Copilot CLI not available"
        print_info "Step 0b will create a placeholder report"
        print_info "Install Copilot CLI to enable AI-powered documentation gap analysis"
    else
        print_success "GitHub Copilot CLI detected"
    fi
    
    # Determine output directories (use BACKLOG_RUN_DIR, not BACKLOG_STEP_DIR)
    local output_dir="${BACKLOG_RUN_DIR:-.}"
    local log_dir="${LOGS_RUN_DIR:-.}"
    local output_file="${output_dir}/step0b_bootstrap_documentation.md"
    
    # Create log file with unique timestamp (following standard pattern)
    local log_timestamp
    log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
    local log_file="${log_dir}/step0b_copilot_bootstrap_docs_${log_timestamp}.log"
    
    # Create output directories if they don't exist
    mkdir -p "$output_dir" 2>/dev/null || true
    mkdir -p "$log_dir" 2>/dev/null || true
    
    # Execute AI bootstrap analysis with log file
    local execution_status="✅"
    local status_message=""
    
    # Check if parallel bootstrap is enabled and available
    local use_parallel="${USE_PARALLEL_BOOTSTRAP:-true}"  # Default to parallel for performance
    if [[ "$use_parallel" == "true" ]] && declare -f execute_parallel_bootstrap &>/dev/null; then
        print_info "Using parallel bootstrap (5 concurrent tasks)..."
        
        local parallel_dir="${output_dir}/parallel_bootstrap_temp"
        mkdir -p "$parallel_dir"
        
        # Execute parallel bootstrap
        if execute_parallel_bootstrap "$parallel_dir" "${PROJECT_NAME:-Unknown Project}" "$PRIMARY_LANGUAGE"; then
            # Aggregate results
            if aggregate_bootstrap_results "$parallel_dir" "$output_file"; then
                print_success "Parallel documentation bootstrap completed"
                execution_status="✅"
                if [[ "$bootstrap_needed" == true ]]; then
                    status_message="Generated bootstrap documentation (parallel) for project with ${doc_count} existing doc files"
                else
                    status_message="Analyzed ${doc_count} documentation files in parallel, identified gaps and provided recommendations"
                fi
            else
                print_warning "Parallel bootstrap aggregation failed, falling back to sequential"
                use_parallel="false"
            fi
        else
            print_warning "Parallel bootstrap encountered issues, falling back to sequential"
            use_parallel="false"
        fi
    else
        use_parallel="false"
    fi
    
    # Fall back to sequential if parallel was disabled or failed
    if [[ "$use_parallel" == "false" ]]; then
        if execute_ai_bootstrap_documentation "$output_file" "$log_file"; then
        print_success "Documentation gap analysis completed"
        print_info "Results saved to: $output_file"
        if [[ -f "$log_file" ]]; then
            print_info "Session log: $log_file"
        fi
        
        execution_status="✅"
        if [[ "$bootstrap_needed" == true ]]; then
            status_message="Generated bootstrap documentation for project with ${doc_count} existing doc files"
        else
            status_message="Analyzed ${doc_count} documentation files, identified gaps and provided recommendations"
        fi
    else
        print_warning "Documentation gap analysis encountered issues"
        print_info "Check the output file for details: $output_file"
        execution_status="⚠️"
        status_message="Documentation gap analysis completed with warnings (Copilot may not be available)"
    fi
    fi  # End of parallel fallback
    
    # Generate standardized step summary
    if declare -f save_step_summary &>/dev/null; then
        local summary_content
        summary_content="Documentation Analysis: ${doc_count} doc files, ${source_count} source files. ${status_message}. Primary language: ${PRIMARY_LANGUAGE:-Not detected}."
        save_step_summary "0b" "Bootstrap_Documentation" "$summary_content" "$execution_status"
    fi
    
    # User confirmation (if interactive mode)
    if [[ "${INTERACTIVE:-false}" == "true" ]]; then
        if declare -f prompt_for_continuation &>/dev/null; then
            prompt_for_continuation
        else
            echo ""
            read -p "Press Enter to continue to next step... " -r
        fi
    fi
    
    # Return success (step completed, even if with warnings)
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

# Export primary step functions
export -f step0b_bootstrap_documentation
export -f validate_step_0b
export -f should_bootstrap
export -f step0b_get_version
export -f build_technical_writer_prompt
export -f execute_ai_bootstrap_documentation
export -f count_documentation_files
export -f count_source_files
