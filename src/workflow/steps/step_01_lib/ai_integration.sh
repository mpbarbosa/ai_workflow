#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 1 AI Integration Module
# Purpose: AI prompt building, Copilot CLI interaction, response processing
# Part of: Step 1 Refactoring Phase 4 - High Cohesion, Low Coupling
# Version: 2.0.0 - Migrated to centralized ai_helpers.yaml templates
################################################################################

# Get script directory for sourcing dependencies
STEP1_AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==============================================================================
# AI AVAILABILITY CHECKING
# ==============================================================================

# Check if GitHub Copilot CLI is available and authenticated
# Returns: 0 if available, 1 if not
check_copilot_available_step1() {
    # Check if copilot command exists
    if ! command -v copilot &>/dev/null; then
        return 1
    fi
    
    # Check if copilot is working (basic version check)
    if ! copilot --version &>/dev/null 2>&1; then
        return 1
    fi
    
    return 0
}

# Validate Copilot CLI with user-friendly messages
# Returns: 0 if ready, 1 if not
validate_copilot_step1() {
    if ! check_copilot_available_step1; then
        print_warning "GitHub Copilot CLI not available"
        print_info "Install with: gh extension install github/gh-copilot"
        print_info "Or visit: https://github.com/github/gh-copilot"
        return 1
    fi
    
    print_success "GitHub Copilot CLI detected and ready"
    return 0
}

# ==============================================================================
# PROMPT BUILDING - Uses Centralized Templates
# ==============================================================================

# Build documentation update prompt with context
# Usage: build_documentation_prompt_step1 <changed_files> <validation_results>
# Returns: Complete AI prompt string
# NOTE: This now delegates to centralized build_doc_analysis_prompt from ai_helpers.sh
build_documentation_prompt_step1() {
    local changed_files="$1"
    local validation_results="${2:-}"
    
    # Prepare documentation files list
    local doc_files="README.md .github/copilot-instructions.md"
    
    # Add validation results context if present
    if [[ -n "$validation_results" ]]; then
        changed_files="${changed_files}

## Documentation Issues Detected

Documentation validation found issues (see above)"
    fi
    
    # Use centralized prompt builder from ai_helpers.sh
    # This ensures we use the optimized ai_helpers.yaml templates with:
    # - role_prefix + behavioral_guidelines
    # - Language-specific context injection
    # - Structured task templates
    # - Complete approach methodology
    if command -v build_doc_analysis_prompt &>/dev/null; then
        build_doc_analysis_prompt "$changed_files" "$doc_files"
    else
        # Fallback if function not available (should not happen in normal workflow)
        print_error "build_doc_analysis_prompt function not found - ai_helpers.sh may not be sourced"
        return 1
    fi
}

# Build prompt for specific documentation file update
# Usage: build_file_update_prompt_step1 <file_path> <changes_context>
# Returns: Targeted AI prompt for single file
build_file_update_prompt_step1() {
    local file_path="$1"
    local changes_context="$2"
    local prompt=""
    
    prompt="Update ${file_path} based on the following code changes:\n\n"
    prompt+="${changes_context}\n\n"
    prompt+="Maintain the existing structure and style. "
    prompt+="Only update sections affected by these changes. "
    prompt+="Preserve all other content unchanged."
    
    echo -e "$prompt"
}

# Enhance prompt with validation context
# Usage: enhance_prompt_with_validation_step1 <base_prompt> <validation_results>
# Returns: Enhanced prompt with validation context
enhance_prompt_with_validation_step1() {
    local base_prompt="$1"
    local validation_results="$2"
    local enhanced=""
    
    enhanced="${base_prompt}\n\n"
    enhanced+="## Additional Context from Automated Validation\n"
    enhanced+="${validation_results}\n\n"
    enhanced+="Please address these validation findings in your documentation updates."
    
    echo -e "$enhanced"
}

# ==============================================================================
# AI EXECUTION
# ==============================================================================

# Execute AI documentation analysis with Copilot CLI
# Usage: execute_ai_documentation_analysis_step1 <prompt> [output_file]
# Returns: 0 on success, 1 on failure
execute_ai_documentation_analysis_step1() {
    local prompt="$1"
    local output_file="${2:-}"
    
    # Validate Copilot is available
    if ! check_copilot_available_step1; then
        print_warning "Copilot CLI not available - skipping AI analysis"
        return 1
    fi
    
    print_info "Executing GitHub Copilot CLI for documentation analysis..."
    
    # Use centralized execution function for consistent logging
    # This automatically logs the prompt to .ai_workflow/prompts/
    if command -v execute_copilot_prompt &>/dev/null; then
        # Use centralized function if available (logs prompts automatically)
        execute_copilot_prompt "$prompt" "$output_file" "step01" "documentation_specialist"
        return $?
    else
        # Fallback to direct execution (backward compatibility)
        if [[ -n "$output_file" ]]; then
            # Non-interactive mode with output capture
            copilot -p "$prompt" --allow-all-tools --allow-all-paths --enable-all-github-mcp-tools > "$output_file" 2>&1
            local exit_code=$?
            
            if [[ $exit_code -eq 0 ]]; then
                print_success "AI analysis saved to: $output_file"
                return 0
            else
                print_error "AI analysis failed with exit code: $exit_code"
                return 1
            fi
        else
            # Interactive mode
            copilot -p "$prompt" --allow-all-tools --allow-all-paths --enable-all-github-mcp-tools
            return $?
        fi
    fi
}

# Execute AI with retry logic for robustness
# Usage: execute_ai_with_retry_step1 <prompt> <output_file> [max_retries]
# Returns: 0 on success, 1 on failure after all retries
execute_ai_with_retry_step1() {
    local prompt="$1"
    local output_file="$2"
    local max_retries="${3:-3}"
    local attempt=1
    
    while [[ $attempt -le $max_retries ]]; do
        print_info "AI execution attempt $attempt of $max_retries..."
        
        if execute_ai_documentation_analysis_step1 "$prompt" "$output_file"; then
            return 0
        fi
        
        if [[ $attempt -lt $max_retries ]]; then
            print_warning "Attempt $attempt failed, retrying in 2 seconds..."
            sleep 2
        fi
        
        ((attempt++))
    done
    
    print_error "AI execution failed after $max_retries attempts"
    return 1
}

# ==============================================================================
# RESPONSE PROCESSING
# ==============================================================================

# Process AI response and extract documentation updates
# Usage: process_ai_response_step1 <response_file>
# Returns: Extracted documentation content
process_ai_response_step1() {
    local response_file="$1"
    
    if [[ ! -f "$response_file" ]]; then
        print_error "Response file not found: $response_file"
        return 1
    fi
    
    # Extract the main content (remove command prompts and metadata)
    local content
    content=$(cat "$response_file")
    
    # Remove common Copilot CLI output artifacts
    content=$(echo "$content" | sed '/^Suggestion:/d' | sed '/^Command:/d' | sed '/^$/d')
    
    echo "$content"
}

# Extract specific documentation section from AI response
# Usage: extract_documentation_section_step1 <response_file> <section_name>
# Returns: Content of specified section
extract_documentation_section_step1() {
    local response_file="$1"
    local section_name="$2"
    
    if [[ ! -f "$response_file" ]]; then
        print_error "Response file not found: $response_file"
        return 1
    fi
    
    # Extract section between markdown headers
    local section_pattern="## ${section_name}"
    awk "/${section_pattern}/,/^## / {print}" "$response_file" | sed '$d'
}

# Validate AI response quality
# Usage: validate_ai_response_step1 <response_file>
# Returns: 0 if valid, 1 if suspicious or empty
validate_ai_response_step1() {
    local response_file="$1"
    
    if [[ ! -f "$response_file" ]]; then
        print_error "Response file not found: $response_file"
        return 1
    fi
    
    # Check if file is empty
    if [[ ! -s "$response_file" ]]; then
        print_warning "AI response is empty"
        return 1
    fi
    
    # Check for error messages
    if grep -qi "error\|failed\|unable" "$response_file"; then
        print_warning "AI response may contain errors"
        return 1
    fi
    
    # Check for minimum content length (at least 50 characters)
    local content_length
    content_length=$(wc -c < "$response_file")
    if [[ $content_length -lt 50 ]]; then
        print_warning "AI response is too short (${content_length} bytes)"
        return 1
    fi
    
    print_success "AI response validation passed"
    return 0
}

# ==============================================================================
# HIGH-LEVEL WORKFLOW FUNCTIONS
# ==============================================================================

# Run complete AI documentation analysis workflow
# Usage: run_ai_documentation_workflow_step1 <changed_files> <validation_results> <output_dir>
# Returns: 0 on success, 1 on failure
run_ai_documentation_workflow_step1() {
    local changed_files="$1"
    local validation_results="${2:-}"
    local output_dir="${3:-.}"
    
    # Create output dir
    mkdir -p "$output_dir"
    
    # Build prompt using centralized function with full persona definition
    print_info "Building AI prompt with full persona context..."
    local prompt
    
    # Determine documentation files to review
    local doc_files=""
    if [[ -d "${PROJECT_ROOT:-${TARGET_DIR:-.}}/docs" ]]; then
        doc_files=$(find "${PROJECT_ROOT:-${TARGET_DIR:-.}}/docs" -name "*.md" -type f | head -20 | xargs echo)
    fi
    doc_files+=" README.md .github/copilot-instructions.md"
    
    # Use centralized build_doc_analysis_prompt if available (includes full persona)
    if command -v build_doc_analysis_prompt &>/dev/null; then
        # Simply call the function - diagnostic output goes to stderr naturally
        prompt=$(build_doc_analysis_prompt "$changed_files" "$doc_files")
        
        # Append validation results if present
        if [[ -n "$validation_results" ]]; then
            prompt+="

## Documentation Issues Detected

${validation_results}
"
        fi
    else
        # Fallback to simplified prompt if centralized function unavailable
        print_warning "Centralized prompt builder not available, using simplified prompt"
        prompt=$(build_documentation_prompt_step1 "$changed_files" "$validation_results")
    fi
    
    # Execute AI analysis
    local response_file="${output_dir}/ai_documentation_analysis.txt"
    if ! execute_ai_with_retry_step1 "$prompt" "$response_file"; then
        print_error "AI documentation analysis failed"
        return 1
    fi
    
    # Validate response
    if ! validate_ai_response_step1 "$response_file"; then
        print_warning "AI response validation failed, but continuing..."
    fi
    
    # Process response
    print_info "Processing AI response..."
    local processed_content
    processed_content=$(process_ai_response_step1 "$response_file")
    
    # Save processed content
    local output_file="${output_dir}/documentation_updates.md"
    echo "$processed_content" > "$output_file"
    
    print_success "AI documentation workflow completed"
    print_info "Results saved to: $output_file"
    
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

# Export all functions for use by main step script
export -f check_copilot_available_step1
export -f validate_copilot_step1
export -f build_documentation_prompt_step1
export -f build_file_update_prompt_step1
export -f enhance_prompt_with_validation_step1
export -f execute_ai_documentation_analysis_step1
export -f execute_ai_with_retry_step1
export -f process_ai_response_step1
export -f extract_documentation_section_step1
export -f validate_ai_response_step1
export -f run_ai_documentation_workflow_step1
