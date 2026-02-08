#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 1.5: API Coverage Report
# Version"1.0.5
# Purpose: Validate API documentation completeness with optional commit blocking
# Part of: Tests & Documentation Workflow Automation v3.3.0
#
# Position: After Step 1 (Documentation Updates), Before Step 2 (Consistency)
#
# Features:
#   - Check all exported functions/classes have API documentation
#   - Generate coverage report (e.g., "87% documented, 13% missing")
#   - Optional threshold enforcement (block commits if < threshold)
#   - Smart execution compatible (changed files only)
#   - AI-enhanced documentation suggestions
#
# Dependencies:
#   - lib/api_coverage.sh (core functionality)
#   - lib/change_detection.sh (smart execution)
#   - lib/ai_helpers.sh (AI suggestions)
################################################################################

# Module version information
readonly STEP1_5_VERSION"1.0.5"
readonly STEP1_5_VERSION_MAJOR=1
readonly STEP1_5_VERSION_MINOR=0
readonly STEP1_5_VERSION_PATCH=0

# Get script directory
STEP1_5_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${STEP1_5_DIR}/../lib"

# Source required modules
source "${WORKFLOW_LIB_DIR}/colors.sh" 2>/dev/null || true
source "${WORKFLOW_LIB_DIR}/utils.sh" 2>/dev/null || true
source "${WORKFLOW_LIB_DIR}/api_coverage.sh"
source "${WORKFLOW_LIB_DIR}/change_detection.sh" 2>/dev/null || true
source "${WORKFLOW_LIB_DIR}/ai_helpers.sh" 2>/dev/null || true

# Source step-specific libraries
if [[ -f "${STEP1_5_DIR}/step_01_5_lib/coverage_threshold.sh" ]]; then
    source "${STEP1_5_DIR}/step_01_5_lib/coverage_threshold.sh"
fi

if [[ -f "${STEP1_5_DIR}/step_01_5_lib/incremental.sh" ]]; then
    source "${STEP1_5_DIR}/step_01_5_lib/incremental.sh"
fi

if [[ -f "${STEP1_5_DIR}/step_01_5_lib/reporting.sh" ]]; then
    source "${STEP1_5_DIR}/step_01_5_lib/reporting.sh"
fi

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Coverage threshold (default: 80%)
readonly API_COVERAGE_THRESHOLD="${API_COVERAGE_THRESHOLD:-80}"

# Strict mode - block commits below threshold (default: false)
readonly API_COVERAGE_STRICT="${API_COVERAGE_STRICT:-false}"

# Minimum APIs required for validation (default: 5)
readonly API_COVERAGE_MIN_APIS="${API_COVERAGE_MIN_APIS:-5}"

# Include private functions (default: false)
readonly API_COVERAGE_INCLUDE_PRIVATE="${API_COVERAGE_INCLUDE_PRIVATE:-false}"

# AI enhancement for suggestions (default: true)
readonly API_COVERAGE_AI_SUGGESTIONS="${API_COVERAGE_AI_SUGGESTIONS:-true}"

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Count total public APIs in project
# Returns: API count
count_total_apis() {
    local source_dir="${1:-src}"
    local total=0
    
    # Find all source files based on detected languages
    local patterns=("*.sh" "*.py" "*.js" "*.ts" "*.jsx" "*.tsx" "*.go" "*.java")
    
    for pattern in "${patterns[@]}"; do
        while IFS= read -r file; do
            local apis
            apis=$(extract_source_apis "$file" 2>/dev/null || echo "")
            if [[ -n "$apis" ]]; then
                local count=$(echo "$apis" | wc -l)
                ((total += count))
            fi
        done < <(find "$source_dir" -name "$pattern" -type f \
            ! -path "*/node_modules/*" \
            ! -path "*/.git/*" \
            ! -path "*/vendor/*" \
            ! -path "*/test/*" \
            ! -path "*/tests/*" \
            2>/dev/null || true)
    done
    
    echo "$total"
}

# Generate AI documentation suggestions for undocumented APIs
# Args: $1 = report file with undocumented APIs
generate_ai_doc_suggestions() {
    local report_file="$1"
    local suggestions_file="${BACKLOG_RUN_DIR}/step01_5_ai_doc_suggestions.md"
    
    # Check if AI is available
    if ! declare -f call_ai_helper &>/dev/null; then
        print_info "AI helper not available - skipping documentation suggestions"
        return 0
    fi
    
    # Extract undocumented APIs from report
    local undocumented_list=""
    if [[ -f "$report_file" ]]; then
        undocumented_list=$(grep "Undocumented API:" "$report_file" | head -10)
    fi
    
    if [[ -z "$undocumented_list" ]]; then
        return 0
    fi
    
    print_info "Generating AI documentation suggestions..."
    
    # Build AI prompt
    local prompt="You are a technical writer helping document undocumented APIs.

**TASK**: Generate concise API documentation for these undocumented functions/methods:

${undocumented_list}

For each API:
1. **Purpose**: Brief description of what it does (1 sentence)
2. **Parameters**: Name, type, description
3. **Returns**: Return value type and description
4. **Example**: Simple usage example
5. **Format**: Use appropriate doc format (JSDoc for JS/TS, docstring for Python, comment for Bash)

Keep documentation concise, accurate, and professional."
    
    # Call AI helper
    if call_ai_helper "technical_writer" "$prompt" "$suggestions_file" 2>/dev/null; then
        print_success "AI documentation suggestions generated: $suggestions_file"
    else
        print_info "AI documentation suggestions unavailable"
    fi
    
    return 0
}

# ==============================================================================
# MAIN STEP FUNCTION
# ==============================================================================

# Main entry point for Step 1.5
# Returns: 0 on success, 1 if strict mode fails
step_01_5_api_coverage() {
    print_section "Step 1.5: API Coverage Report"
    
    # Configuration summary
    print_info "Configuration:"
    print_info "  Threshold: ${API_COVERAGE_THRESHOLD}%"
    print_info "  Strict Mode: ${API_COVERAGE_STRICT}"
    print_info "  AI Suggestions: ${API_COVERAGE_AI_SUGGESTIONS}"
    
    # Determine source directory
    local source_dir="src"
    if [[ ! -d "$source_dir" ]]; then
        # Fallback to common alternatives
        if [[ -d "lib" ]]; then
            source_dir="lib"
        elif [[ -d "app" ]]; then
            source_dir="app"
        else
            source_dir="."
        fi
    fi
    
    local docs_dir="${PROJECT_ROOT:-$(pwd)}/docs"
    
    print_info "Analyzing API documentation coverage..."
    print_info "  Source directory: $source_dir"
    print_info "  Documentation directory: $docs_dir"
    
    # Count total APIs
    local total_apis
    total_apis=$(count_total_apis "$source_dir")
    
    # Check minimum API threshold
    if [[ $total_apis -lt $API_COVERAGE_MIN_APIS ]]; then
        print_info "Found $total_apis APIs (< ${API_COVERAGE_MIN_APIS} minimum)"
        print_info "Skipping API coverage validation (too few APIs)"
        
        # Generate minimal report
        if declare -f save_step_summary &>/dev/null; then
            save_step_summary "1.5" "API_Coverage" \
                "Skipped: Only ${total_apis} APIs found (minimum: ${API_COVERAGE_MIN_APIS})" "⏭️"
        fi
        
        return 0
    fi
    
    print_info "Found $total_apis public APIs"
    
    # Run coverage analysis
    local report_file="${BACKLOG_RUN_DIR}/step01_5_api_coverage_report.txt"
    local summary_file="${BACKLOG_RUN_DIR}/step01_5_api_coverage_summary.md"
    
    # Initialize report file
    > "$report_file"
    
    # Analyze coverage
    local undocumented=0
    analyze_project_api_coverage "$source_dir" "$docs_dir" "$report_file" || undocumented=$?
    
    # Calculate metrics
    local documented_apis=$((total_apis - undocumented))
    local coverage=0
    if [[ $total_apis -gt 0 ]]; then
        coverage=$((100 * documented_apis / total_apis))
    fi
    
    print_info "  Documented APIs: $documented_apis"
    print_info "  Undocumented APIs: $undocumented"
    
    # Generate summary report
    generate_api_coverage_summary "$report_file" "$summary_file" "$total_apis" "$undocumented"
    
    # Display results
    echo ""
    if [[ $coverage -ge $API_COVERAGE_THRESHOLD ]]; then
        print_success "API coverage ${coverage}% meets threshold ${API_COVERAGE_THRESHOLD}%"
        local status="✅"
        local result="pass"
    else
        print_warning "API coverage ${coverage}% is below threshold ${API_COVERAGE_THRESHOLD}%"
        
        if [[ "$API_COVERAGE_STRICT" == "true" ]]; then
            print_error "STRICT MODE: Blocking commit due to insufficient API coverage"
            echo ""
            print_info "Required actions:"
            print_info "  1. Document $(( (API_COVERAGE_THRESHOLD * total_apis / 100) - documented_apis )) more APIs to reach ${API_COVERAGE_THRESHOLD}% threshold"
            print_info "  2. Or adjust threshold: API_COVERAGE_THRESHOLD=${coverage}"
            print_info "  3. Or disable strict mode: API_COVERAGE_STRICT=false"
            echo ""
            print_info "See detailed report: $report_file"
            
            local status="❌"
            local result="fail"
        else
            print_warning "Continuing with warning (use API_COVERAGE_STRICT=true to block)"
            local status="⚠️"
            local result="warning"
        fi
    fi
    
    # Show top undocumented files
    if [[ $undocumented -gt 0 ]]; then
        echo ""
        print_info "Top files with undocumented APIs:"
        grep "Undocumented API:" "$report_file" 2>/dev/null | \
            awk -F: '{print $1}' | sort | uniq -c | sort -rn | head -5 | \
            while read -r count file; do
                echo "  - ${file}: ${count} undocumented"
            done || true
    fi
    
    # AI suggestions (if enabled and needed)
    if [[ "$API_COVERAGE_AI_SUGGESTIONS" == "true" ]] && [[ $undocumented -gt 0 ]]; then
        echo ""
        generate_ai_doc_suggestions "$report_file"
    fi
    
    echo ""
    print_info "Results saved to:"
    print_info "  Report: $report_file"
    print_info "  Summary: $summary_file"
    
    # Save step summary
    if declare -f save_step_summary &>/dev/null; then
        local summary_text="API Coverage: ${coverage}% (${documented_apis}/${total_apis} documented). Threshold: ${API_COVERAGE_THRESHOLD}%."
        save_step_summary "1.5" "API_Coverage" "$summary_text" "$status"
    fi
    
    # Save metrics
    if declare -f save_step_metrics &>/dev/null; then
        save_step_metrics "1.5" "api_coverage" "$coverage" "$undocumented" "$total_apis"
    fi
    
    # Return based on result
    if [[ "$result" == "fail" ]]; then
        return 1
    else
        return 0
    fi
}

# Get version information
step_01_5_get_version() {
    echo "${STEP1_5_VERSION}"
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f step_01_5_api_coverage
export -f step_01_5_get_version
export -f count_total_apis
export -f generate_ai_doc_suggestions
