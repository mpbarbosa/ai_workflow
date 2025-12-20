#!/bin/bash
set -euo pipefail

################################################################################
# Metrics Validation Library
# Purpose: Validate and verify project metrics consistency across documentation
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Version: 2.0.0
################################################################################

# Module version information
readonly METRICS_VALIDATION_VERSION="2.0.0"
readonly METRICS_VALIDATION_VERSION_MAJOR=2
readonly METRICS_VALIDATION_VERSION_MINOR=0
readonly METRICS_VALIDATION_VERSION_PATCH=0

################################################################################
# Standalone Print Functions (for use outside workflow context)
################################################################################

# Print functions compatible with workflow or standalone use
metrics_print_info() {
    if command -v print_info &> /dev/null; then
        print_info "$@"
    else
        echo "[INFO] $*"
    fi
}

metrics_print_success() {
    if command -v print_success &> /dev/null; then
        print_success "$@"
    else
        echo "[✓] $*"
    fi
}

metrics_print_warning() {
    if command -v print_warning &> /dev/null; then
        print_warning "$@"
    else
        echo "[!] $*" >&2
    fi
}

metrics_print_error() {
    if command -v print_error &> /dev/null; then
        print_error "$@"
    else
        echo "[✗] $*" >&2
    fi
}

metrics_print_header() {
    if command -v print_header &> /dev/null; then
        print_header "$@"
    else
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "  $*"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
    fi
}

################################################################################
# Core Metric Calculation Functions
################################################################################

# Calculate actual line counts for workflow modules
# Returns: Sets global variables with actual counts
calculate_workflow_metrics() {
    local workflow_dir="${1:-src/workflow}"
    
    # Library module line count
    if [[ -d "$workflow_dir/lib" ]]; then
        ACTUAL_LIB_LINES=$(wc -l "$workflow_dir"/lib/*.sh 2>/dev/null | tail -1 | awk '{print $1}')
        ACTUAL_LIB_COUNT=$(find "$workflow_dir/lib" -name "*.sh" -type f | wc -l)
    else
        ACTUAL_LIB_LINES=0
        ACTUAL_LIB_COUNT=0
    fi
    
    # Step module line count
    if [[ -d "$workflow_dir/steps" ]]; then
        ACTUAL_STEP_LINES=$(wc -l "$workflow_dir"/steps/*.sh 2>/dev/null | tail -1 | awk '{print $1}')
        ACTUAL_STEP_COUNT=$(find "$workflow_dir/steps" -name "*.sh" -type f | wc -l)
    else
        ACTUAL_STEP_LINES=0
        ACTUAL_STEP_COUNT=0
    fi
    
    # Total modular code lines
    ACTUAL_TOTAL_LINES=$((ACTUAL_LIB_LINES + ACTUAL_STEP_LINES))
    ACTUAL_TOTAL_MODULES=$((ACTUAL_LIB_COUNT + ACTUAL_STEP_COUNT))
    
    # Main workflow script line count
    if [[ -f "$workflow_dir/execute_tests_docs_workflow.sh" ]]; then
        ACTUAL_MAIN_LINES=$(wc -l "$workflow_dir/execute_tests_docs_workflow.sh" | awk '{print $1}')
    else
        ACTUAL_MAIN_LINES=0
    fi
}

# Format number with thousands separator (e.g., 6993 → 6,993)
format_number() {
    local num="$1"
    echo "$num" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'
}

################################################################################
# Documentation Validation Functions
################################################################################

# Validate line count references in a documentation file
# Arguments: $1 - file path, $2 - expected total lines, $3 - expected lib lines, $4 - expected step lines
# Returns: 0 if valid, 1 if inconsistencies found
validate_doc_metrics() {
    local doc_file="$1"
    local expected_total="$2"
    local expected_lib="$3"
    local expected_step="$4"
    
    local issues=0
    
    if [[ ! -f "$doc_file" ]]; then
        metrics_print_warning "Documentation file not found: $doc_file"
        return 1
    fi
    
    # Extract line count references from documentation
    local found_totals
    found_totals=$(grep -oP '\d{1,3}(,\d{3})*(?=\s+(lines|total lines))' "$doc_file" 2>/dev/null || true)
    
    # Check for incorrect total line counts
    while IFS= read -r found_count; do
        [[ -z "$found_count" ]] && continue
        
        # Remove commas for numeric comparison
        local found_numeric
        found_numeric=$(echo "$found_count" | tr -d ',')
        
        if [[ "$found_numeric" -ne "$expected_total" ]]; then
            metrics_print_warning "[$doc_file] Found incorrect line count: $found_count (expected: $(format_number "$expected_total"))"
            echo "  Line reference: $(grep -n "$found_count" "$doc_file" | head -1)"
            ((issues++))
        fi
    done <<< "$found_totals"
    
    # Check for specific lib/step breakdowns if provided
    if [[ -n "$expected_lib" ]] && grep -q "$expected_lib" "$doc_file" 2>/dev/null; then
        if ! grep -q "$(format_number "$expected_lib")" "$doc_file" 2>/dev/null; then
            metrics_print_warning "[$doc_file] Library line count mismatch"
            ((issues++))
        fi
    fi
    
    if [[ -n "$expected_step" ]] && grep -q "$expected_step" "$doc_file" 2>/dev/null; then
        if ! grep -q "$(format_number "$expected_step")" "$doc_file" 2>/dev/null; then
            metrics_print_warning "[$doc_file] Step line count mismatch"
            ((issues++))
        fi
    fi
    
    return "$issues"
}

# Validate module count references in a documentation file
# Arguments: $1 - file path, $2 - expected total modules, $3 - expected lib count, $4 - expected step count
# Returns: 0 if valid, 1 if inconsistencies found
validate_module_counts() {
    local doc_file="$1"
    local expected_total="$2"
    local expected_lib="$3"
    local expected_step="$4"
    
    local issues=0
    
    if [[ ! -f "$doc_file" ]]; then
        metrics_print_warning "Documentation file not found: $doc_file"
        return 1
    fi
    
    # Check total module count (e.g., "25 modules")
    local found_module_counts
    found_module_counts=$(grep -oP '\d+(?=\s+modules?)' "$doc_file" 2>/dev/null || true)
    
    while IFS= read -r found_count; do
        [[ -z "$found_count" ]] && continue
        
        if [[ "$found_count" -ne "$expected_total" ]] && [[ "$found_count" -ne "$expected_lib" ]] && [[ "$found_count" -ne "$expected_step" ]]; then
            # Check if it's a valid reference (could be lib or step count)
            if [[ "$found_count" -ne "$expected_total" ]]; then
                metrics_print_warning "[$doc_file] Found potentially incorrect module count: $found_count (expected total: $expected_total)"
                ((issues++))
            fi
        fi
    done <<< "$found_module_counts"
    
    return "$issues"
}

################################################################################
# Comprehensive Validation Functions
################################################################################

# Run comprehensive metrics validation across all documentation
# Returns: 0 if all valid, 1 if inconsistencies found
validate_all_documentation_metrics() {
    metrics_print_header "Documentation Metrics Validation"
    
    local project_root="${PROJECT_ROOT:-.}"
    cd "$project_root" || return 1
    
    # Calculate actual metrics (single source of truth)
    calculate_workflow_metrics "src/workflow"
    
    metrics_print_info "Actual Metrics (Source of Truth):"
    echo "  Library Modules: $(format_number "$ACTUAL_LIB_LINES") lines ($ACTUAL_LIB_COUNT files)"
    echo "  Step Modules: $(format_number "$ACTUAL_STEP_LINES") lines ($ACTUAL_STEP_COUNT files)"
    echo "  Total Modular Code: $(format_number "$ACTUAL_TOTAL_LINES") lines ($ACTUAL_TOTAL_MODULES modules)"
    echo "  Main Workflow Script: $(format_number "$ACTUAL_MAIN_LINES") lines"
    echo ""
    
    local total_issues=0
    
    # Documentation files to validate
    local doc_files=(
        ".github/copilot-instructions.md"
        "README.md"
        "shell_scripts/README.md"
        "src/workflow/README.md"
    )
    
    metrics_print_info "Validating documentation files..."
    
    for doc_file in "${doc_files[@]}"; do
        if [[ -f "$doc_file" ]]; then
            metrics_print_info "Checking: $doc_file"
            
            # Validate line count metrics
            if ! validate_doc_metrics "$doc_file" "$ACTUAL_TOTAL_LINES" "$ACTUAL_LIB_LINES" "$ACTUAL_STEP_LINES"; then
                ((total_issues++))
            fi
            
            # Validate module counts
            if ! validate_module_counts "$doc_file" "$ACTUAL_TOTAL_MODULES" "$ACTUAL_LIB_COUNT" "$ACTUAL_STEP_COUNT"; then
                ((total_issues++))
            fi
        else
            metrics_print_warning "Documentation file not found: $doc_file"
            ((total_issues++))
        fi
    done
    
    echo ""
    
    if [[ $total_issues -eq 0 ]]; then
        metrics_print_success "✅ All documentation metrics are consistent!"
        metrics_print_info "Source of truth: $(format_number "$ACTUAL_TOTAL_LINES") lines across $ACTUAL_TOTAL_MODULES modules"
        return 0
    else
        metrics_print_error "❌ Found $total_issues metric inconsistencies in documentation"
        metrics_print_info "Run automated fix to update documentation with actual counts"
        return 1
    fi
}

# Generate metrics report for documentation
# Returns: Formatted metrics report string
generate_metrics_report() {
    calculate_workflow_metrics "src/workflow"
    
    local report="### Workflow Automation Metrics (Actual Counts)

**Module Architecture:**
- Library Modules: $(format_number "$ACTUAL_LIB_LINES") lines ($ACTUAL_LIB_COUNT files)
- Step Modules: $(format_number "$ACTUAL_STEP_LINES") lines ($ACTUAL_STEP_COUNT files)
- Total Modular Code: $(format_number "$ACTUAL_TOTAL_LINES") lines ($ACTUAL_TOTAL_MODULES modules)
- Main Workflow Script: $(format_number "$ACTUAL_MAIN_LINES") lines

**Verification Command:**
\`\`\`bash
cd src/workflow
wc -l lib/*.sh steps/*.sh | tail -1
# Output: $(format_number "$ACTUAL_TOTAL_LINES") total
\`\`\`

**Generated:** $(date +"%Y-%m-%d %H:%M:%S")
**Source of Truth:** \`wc -l\` output"
    
    echo "$report"
}

# Export public functions
export -f calculate_workflow_metrics
export -f format_number
export -f validate_doc_metrics
export -f validate_module_counts
export -f validate_all_documentation_metrics
export -f generate_metrics_report

# Export metric variables (will be set after calculate_workflow_metrics is called)
export ACTUAL_LIB_LINES
export ACTUAL_LIB_COUNT
export ACTUAL_STEP_LINES
export ACTUAL_STEP_COUNT
export ACTUAL_TOTAL_LINES
export ACTUAL_TOTAL_MODULES
export ACTUAL_MAIN_LINES
