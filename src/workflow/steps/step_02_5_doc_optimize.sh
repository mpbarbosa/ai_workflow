#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 2.5: Documentation Optimization
# Purpose: Analyze, consolidate, and optimize documentation to reduce AI context
# Part of: Tests & Documentation Workflow Automation v3.2.1
# Version: 1.0.3
################################################################################
#
# This step optimizes the documentation base by:
# 1. Identifying redundant documents (exact duplicates + high similarity)
# 2. Detecting outdated documents (git history + version analysis)
# 3. Consolidating redundant content automatically (high confidence)
# 4. Archiving outdated/consolidated documents
# 5. Generating optimization report with metrics
#
# Benefits:
# - Reduced AI prompt context size
# - Lower GitHub Copilot costs
# - Improved documentation maintainability
# - Cleaner project structure
#
################################################################################

# Module version information
readonly STEP2_5_VERSION="1.0.0"
readonly STEP2_5_VERSION_MAJOR=1
readonly STEP2_5_VERSION_MINOR=0
readonly STEP2_5_VERSION_PATCH=0

# Get script directory for sourcing modules
STEP2_5_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${STEP2_5_DIR}/../lib"

# Source required library modules
source "${WORKFLOW_LIB_DIR}/colors.sh" 2>/dev/null || true
source "${WORKFLOW_LIB_DIR}/utils.sh" 2>/dev/null || true
source "${WORKFLOW_LIB_DIR}/ai_helpers.sh" 2>/dev/null || true
source "${WORKFLOW_LIB_DIR}/git_cache.sh" 2>/dev/null || true
source "${WORKFLOW_LIB_DIR}/metrics.sh" 2>/dev/null || true

# Source step-specific submodules
source "${STEP2_5_DIR}/step_02_5_lib/heuristics.sh"
source "${STEP2_5_DIR}/step_02_5_lib/git_analysis.sh"
source "${STEP2_5_DIR}/step_02_5_lib/version_analysis.sh"
source "${STEP2_5_DIR}/step_02_5_lib/ai_analyzer.sh"
source "${STEP2_5_DIR}/step_02_5_lib/consolidation.sh"
source "${STEP2_5_DIR}/step_02_5_lib/reporting.sh"

# Configuration defaults (can be overridden via .workflow-config.yaml)
readonly DEFAULT_OUTDATED_THRESHOLD_MONTHS=12
readonly DEFAULT_SIMILARITY_THRESHOLD=0.80
readonly DEFAULT_CONFIDENCE_AUTO=0.90
readonly DEFAULT_CONFIDENCE_AI=0.50
readonly DEFAULT_ARCHIVE_DIR="docs/.archive"

# Global state
declare -A DOC_HASHES            # SHA256 hashes of all documents
declare -A DOC_SIMILARITIES      # Similarity scores between document pairs
declare -A DOC_LAST_MODIFIED     # Last git modification timestamp
declare -A DOC_VERSION_REFS      # Extracted version references
declare -a EXACT_DUPLICATES      # Array of exact duplicate file paths
declare -a REDUNDANT_PAIRS       # Array of redundant document pairs
declare -a OUTDATED_FILES        # Array of outdated file paths
declare -a DOC_EXCLUDE_PATTERNS      # Patterns to exclude from analysis

DOCS_DIR=""
ARCHIVE_DIR=""
DRY_RUN=false
INTERACTIVE=true
TOTAL_FILES=0
TOTAL_SIZE_BEFORE=0
TOTAL_SIZE_AFTER=0

################################################################################
# Main entry point for Step 2.5
# Analyzes and optimizes documentation base
# Returns: 0 for success, 1 for failure
################################################################################
step2_5_doc_optimize() {
    local start_time
    start_time=$(date +%s)
    
    print_step_header "2.5" "Documentation Optimization"
    
    # Change to project root
    cd "$PROJECT_ROOT" || {
        print_error "Failed to change to project root: $PROJECT_ROOT"
        return 1
    }
    
    # Load configuration
    load_doc_optimize_config
    
    # Check if documentation directory exists
    if [[ ! -d "$DOCS_DIR" ]]; then
        print_info "No documentation directory found ($DOCS_DIR). Skipping optimization."
        return 0
    fi
    
    # Count documentation files
    TOTAL_FILES=$(find "$DOCS_DIR" -name "*.md" -type f | wc -l)
    
    if [[ $TOTAL_FILES -lt 5 ]]; then
        print_info "Documentation base is small ($TOTAL_FILES files). Skipping optimization."
        return 0
    fi
    
    print_info "Analyzing $TOTAL_FILES documentation files..."
    
    # Phase 1: Heuristics-based analysis
    print_section "Phase 1: Heuristics Analysis"
    if ! analyze_documentation_heuristics; then
        print_error "Heuristics analysis failed"
        return 1
    fi
    
    # Phase 2: Git history analysis
    print_section "Phase 2: Git History Analysis"
    if ! analyze_documentation_git_history; then
        print_warning "Git history analysis failed (non-fatal)"
    fi
    
    # Phase 3: Version reference analysis
    print_section "Phase 3: Version Reference Analysis"
    if ! analyze_documentation_versions; then
        print_warning "Version analysis failed (non-fatal)"
    fi
    
    # Phase 4: AI-powered edge case analysis
    if [[ ${#REDUNDANT_PAIRS[@]} -gt 0 ]]; then
        print_section "Phase 4: AI Edge Case Analysis"
        if ! analyze_edge_cases_with_ai; then
            print_warning "AI analysis skipped or failed (non-fatal)"
        fi
    fi
    
    # Phase 5: Display findings
    print_section "Phase 5: Optimization Summary"
    display_optimization_findings
    
    # Phase 6: Execute optimizations (if not dry-run)
    if [[ "$DRY_RUN" == "false" ]]; then
        print_section "Phase 6: Applying Optimizations"
        
        if ! execute_optimizations; then
            print_error "Optimization execution failed"
            return 1
        fi
    else
        print_info "Dry-run mode: No changes applied"
    fi
    
    # Phase 7: Generate report
    print_section "Phase 7: Generating Report"
    if ! generate_optimization_report; then
        print_warning "Report generation failed (non-fatal)"
    fi
    
    # Calculate and display metrics
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_success "Documentation optimization complete in ${duration}s"
    
    return 0
}

################################################################################
# Load configuration from .workflow-config.yaml
# Sets global configuration variables
################################################################################
load_doc_optimize_config() {
    local config_file="$PROJECT_ROOT/.workflow-config.yaml"
    
    # Set defaults
    DOCS_DIR="${PROJECT_ROOT}/docs"
    ARCHIVE_DIR="${PROJECT_ROOT}/${DEFAULT_ARCHIVE_DIR}"
    local outdated_threshold=$DEFAULT_OUTDATED_THRESHOLD_MONTHS
    local similarity_threshold=$DEFAULT_SIMILARITY_THRESHOLD
    
    # Load from config if exists
    if [[ -f "$config_file" ]] && command -v yq &>/dev/null; then
        local enabled
        enabled=$(yq eval '.documentation_optimization.enabled // true' "$config_file" 2>/dev/null)
        
        if [[ "$enabled" == "false" ]]; then
            print_info "Documentation optimization disabled in config"
            return 1
        fi
        
        # Load other settings
        outdated_threshold=$(yq eval '.documentation_optimization.outdated_threshold_months // 12' "$config_file" 2>/dev/null)
        similarity_threshold=$(yq eval '.documentation_optimization.similarity_threshold // 0.80' "$config_file" 2>/dev/null)
        
        # Load exclude patterns
        local patterns
        patterns=$(yq eval '.documentation_optimization.exclude_patterns[]' "$config_file" 2>/dev/null)
        if [[ -n "$patterns" ]]; then
            while IFS= read -r pattern; do
                DOC_EXCLUDE_PATTERNS+=("$pattern")
            done <<< "$patterns"
        fi
    fi
    
    # Add default excludes
    DOC_EXCLUDE_PATTERNS+=(
        "CHANGELOG.md"
        "LICENSE*"
        "CONTRIBUTING.md"
        "CODE_OF_CONDUCT.md"
    )
    
    # Check for command-line flags
    for arg in "$@"; do
        case "$arg" in
            --dry-run)
                DRY_RUN=true
                ;;
            --no-interactive)
                INTERACTIVE=false
                ;;
        esac
    done
    
    print_debug "Configuration loaded:"
    print_debug "  Docs directory: $DOCS_DIR"
    print_debug "  Archive directory: $ARCHIVE_DIR"
    print_debug "  Outdated threshold: ${outdated_threshold} months"
    print_debug "  Similarity threshold: ${similarity_threshold}"
    print_debug "  Dry-run: $DRY_RUN"
    print_debug "  Interactive: $INTERACTIVE"
    
    return 0
}

################################################################################
# Print step header with formatting
################################################################################
print_step_header() {
    local step_num="$1"
    local step_name="$2"
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  STEP $step_num: $step_name"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
}

################################################################################
# Print section header
################################################################################
print_section() {
    local section_name="$1"
    echo ""
    echo "──────────────────────────────────────────────────────────────"
    echo "  $section_name"
    echo "──────────────────────────────────────────────────────────────"
}

################################################################################
# Display optimization findings summary
################################################################################
display_optimization_findings() {
    echo ""
    echo "📊 Analysis Results:"
    echo "───────────────────"
    echo "  Total files analyzed: $TOTAL_FILES"
    echo "  Exact duplicates: ${#EXACT_DUPLICATES[@]}"
    echo "  Redundant pairs: ${#REDUNDANT_PAIRS[@]}"
    echo "  Outdated files: ${#OUTDATED_FILES[@]}"
    echo ""
    
    if [[ ${#EXACT_DUPLICATES[@]} -gt 0 ]]; then
        echo "Exact Duplicates (will be consolidated):"
        for file in "${EXACT_DUPLICATES[@]}"; do
            echo "  • $file"
        done
        echo ""
    fi
    
    if [[ ${#OUTDATED_FILES[@]} -gt 0 ]]; then
        echo "Outdated Files (candidates for archiving):"
        for file in "${OUTDATED_FILES[@]}"; do
            echo "  • $file"
        done
        echo ""
    fi
}

################################################################################
# Execute optimizations (consolidation, archiving)
################################################################################
execute_optimizations() {
    # Create archive directory
    if ! create_archive_directory; then
        print_error "Failed to create archive directory"
        return 1
    fi
    
    # Consolidate exact duplicates
    if [[ ${#EXACT_DUPLICATES[@]} -gt 0 ]]; then
        print_info "Consolidating ${#EXACT_DUPLICATES[@]} duplicate files..."
        if ! consolidate_duplicates; then
            print_error "Duplicate consolidation failed"
            return 1
        fi
    fi
    
    # Handle redundant pairs
    if [[ ${#REDUNDANT_PAIRS[@]} -gt 0 ]]; then
        print_info "Processing ${#REDUNDANT_PAIRS[@]} redundant document pairs..."
        if ! consolidate_redundant_pairs; then
            print_warning "Some redundant pairs could not be consolidated"
        fi
    fi
    
    # Archive outdated files (with user confirmation)
    if [[ ${#OUTDATED_FILES[@]} -gt 0 ]] && [[ "$INTERACTIVE" == "true" ]]; then
        if ! prompt_archive_outdated; then
            print_info "Skipped archiving outdated files"
        fi
    fi
    
    return 0
}

################################################################################
# Placeholder functions (implemented in submodules)
################################################################################
analyze_documentation_heuristics() {
    # Implemented in step_02_5_lib/heuristics.sh
    return 0
}

analyze_documentation_git_history() {
    # Implemented in step_02_5_lib/git_analysis.sh
    return 0
}

analyze_documentation_versions() {
    # Implemented in step_02_5_lib/version_analysis.sh
    return 0
}

analyze_edge_cases_with_ai() {
    # Implemented in step_02_5_lib/ai_analyzer.sh
    return 0
}

consolidate_duplicates() {
    # Implemented in step_02_5_lib/consolidation.sh
    return 0
}

consolidate_redundant_pairs() {
    # Implemented in step_02_5_lib/consolidation.sh
    return 0
}

prompt_archive_outdated() {
    # Implemented in step_02_5_lib/consolidation.sh
    return 0
}

create_archive_directory() {
    # Implemented in step_02_5_lib/consolidation.sh
    return 0
}

generate_optimization_report() {
    # Implemented in step_02_5_lib/reporting.sh
    return 0
}

# Export main function
export -f step2_5_doc_optimize

################################################################################
# Execute step if run directly
################################################################################
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Check for required environment variables
    if [[ -z "${PROJECT_ROOT:-}" ]]; then
        echo "Error: PROJECT_ROOT not set"
        exit 1
    fi
    
    # Run step
    step2_5_doc_optimize "$@"
fi
