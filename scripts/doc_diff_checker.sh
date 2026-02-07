#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Documentation Diff Checker
# Purpose: Compare code changes with documentation changes to detect drift
# Version: 1.0.0
# Created: 2026-02-07
################################################################################

# ANSI color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Counters
TOTAL_CHECKS=0
WARNINGS=0
SUGGESTIONS=0

# Output functions
error() { echo -e "${RED}✗ ERROR${NC}: $*" >&2; }
warning() { echo -e "${YELLOW}⚠ WARNING${NC}: $*" >&2; ((WARNINGS++)); }
suggestion() { echo -e "${CYAN}💡 SUGGESTION${NC}: $*"; ((SUGGESTIONS++)); }
success() { echo -e "${GREEN}✓${NC} $*"; }
info() { echo -e "${BLUE}ℹ${NC} $*"; }

################################################################################
# CHANGE DETECTION
################################################################################

# Get list of modified shell scripts
get_modified_scripts() {
    git diff --name-only HEAD 2>/dev/null | \
        grep -E '\.sh$' | \
        grep -v -E '^(tests/|scripts/validate|scripts/check)' || echo ""
}

# Get list of modified documentation files
get_modified_docs() {
    git diff --name-only HEAD 2>/dev/null | \
        grep -E '\.md$' || echo ""
}

# Get modified functions in a script
get_modified_functions() {
    local script="$1"
    
    if [[ ! -f "$script" ]]; then
        return 0
    fi
    
    # Get function names from diff
    git diff HEAD -- "$script" 2>/dev/null | \
        grep -E '^\+[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*\(\)' | \
        sed 's/^+[[:space:]]*//' | \
        sed 's/().*//' || echo ""
}

# Get module category (core/supporting/step/orchestrator)
get_module_category() {
    local script="$1"
    
    case "$script" in
        src/workflow/lib/*.sh)
            # Check if it's a core module
            if grep -qE '^(ai_helpers|tech_stack|workflow_optimization|change_detection|metrics|performance)\.sh$' <<< "$(basename "$script")"; then
                echo "core"
            else
                echo "supporting"
            fi
            ;;
        src/workflow/steps/*.sh)
            echo "step"
            ;;
        src/workflow/orchestrators/*.sh)
            echo "orchestrator"
            ;;
        *)
            echo "other"
            ;;
    esac
}

################################################################################
# DOCUMENTATION MAPPING
################################################################################

# Map script to expected documentation file
map_script_to_docs() {
    local script="$1"
    local category="$2"
    local docs=()
    
    case "$category" in
        core)
            # Core modules should have API docs
            local basename=$(basename "$script" .sh)
            docs+=("docs/api/core/${basename}.md")
            ;;
        supporting)
            # Supporting modules should have API docs
            local basename=$(basename "$script" .sh)
            docs+=("docs/api/supporting/${basename}.md")
            ;;
        step)
            # Step modules should have step docs
            local step_num=$(basename "$script" .sh | grep -oE 'step_[0-9]+[a-z]?' | sed 's/step_//')
            docs+=("docs/reference/API_STEP_MODULES.md")
            ;;
        orchestrator)
            # Orchestrators should have orchestrator docs
            docs+=("docs/reference/API_ORCHESTRATORS.md")
            ;;
    esac
    
    # Always check PROJECT_REFERENCE.md for major changes
    docs+=("docs/PROJECT_REFERENCE.md")
    
    printf '%s\n' "${docs[@]}"
}

# Check if documentation file was modified
doc_was_modified() {
    local doc_file="$1"
    local modified_docs="$2"
    
    grep -qF "$doc_file" <<< "$modified_docs"
}

################################################################################
# DRIFT ANALYSIS
################################################################################

# Analyze drift for a single script
analyze_script_drift() {
    local script="$1"
    local modified_docs="$2"
    
    ((TOTAL_CHECKS++))
    
    info "Analyzing: $script"
    
    # Get module category
    local category
    category=$(get_module_category "$script")
    
    # Get expected documentation files
    local expected_docs
    expected_docs=$(map_script_to_docs "$script" "$category")
    
    # Check if any expected docs were modified
    local docs_updated=false
    while IFS= read -r doc_file; do
        if [[ -n "$doc_file" ]] && doc_was_modified "$doc_file" "$modified_docs"; then
            docs_updated=true
            success "  → Documentation updated: $doc_file"
            break
        fi
    done <<< "$expected_docs"
    
    # If docs weren't updated, suggest what to update
    if [[ "$docs_updated" == "false" ]]; then
        warning "  → Code changed but documentation may need updates"
        
        # Get modified functions
        local modified_functions
        modified_functions=$(get_modified_functions "$script")
        
        if [[ -n "$modified_functions" ]]; then
            info "  → Modified functions:"
            while IFS= read -r func; do
                [[ -z "$func" ]] && continue
                echo "      - ${func}()"
            done <<< "$modified_functions"
        fi
        
        # Suggest documentation updates
        echo ""
        suggestion "  Consider updating:"
        while IFS= read -r doc_file; do
            [[ -z "$doc_file" ]] && continue
            if [[ -f "$doc_file" ]]; then
                echo "      - $doc_file (exists)"
            else
                echo "      - $doc_file (create new)"
            fi
        done <<< "$expected_docs"
        echo ""
    fi
}

################################################################################
# SUGGESTION ENGINE
################################################################################

# Generate specific suggestions based on change type
generate_suggestions() {
    local script="$1"
    local category="$2"
    
    # Analyze what changed
    local diff_stats
    diff_stats=$(git diff --shortstat HEAD -- "$script" 2>/dev/null || echo "")
    
    if [[ -z "$diff_stats" ]]; then
        return 0
    fi
    
    # Extract insertions/deletions
    local insertions=$(echo "$diff_stats" | grep -oP '\d+(?= insertion)' || echo "0")
    local deletions=$(echo "$diff_stats" | grep -oP '\d+(?= deletion)' || echo "0")
    
    # Suggest based on magnitude of change
    if [[ $insertions -gt 50 ]] || [[ $deletions -gt 50 ]]; then
        suggestion "Major changes detected ($insertions+ $deletions-)"
        echo "  → Consider: Full API documentation review"
        echo "  → Update: Function signatures, parameters, return values"
        echo "  → Add: New usage examples"
    elif [[ $insertions -gt 10 ]] || [[ $deletions -gt 10 ]]; then
        suggestion "Moderate changes detected ($insertions+ $deletions-)"
        echo "  → Update: Affected function documentation"
        echo "  → Verify: Existing examples still valid"
    else
        suggestion "Minor changes detected ($insertions+ $deletions-)"
        echo "  → Review: Quick documentation scan sufficient"
    fi
    
    echo ""
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║      Documentation Diff Checker v1.0.0                ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    
    cd "$PROJECT_ROOT" || exit 1
    
    # Get modified files
    info "Detecting code and documentation changes..."
    echo ""
    
    local modified_scripts
    modified_scripts=$(get_modified_scripts)
    
    local modified_docs
    modified_docs=$(get_modified_docs)
    
    local script_count
    script_count=$(echo "$modified_scripts" | grep -c . || echo "0")
    
    local doc_count
    doc_count=$(echo "$modified_docs" | grep -c . || echo "0")
    
    info "Modified scripts: $script_count"
    info "Modified docs:    $doc_count"
    echo ""
    
    if [[ $script_count -eq 0 ]]; then
        success "No code changes detected - documentation drift check skipped"
        return 0
    fi
    
    # Analyze each modified script
    echo "═══ Drift Analysis ═══"
    while IFS= read -r script; do
        [[ -z "$script" ]] && continue
        
        analyze_script_drift "$script" "$modified_docs"
        
        local category
        category=$(get_module_category "$script")
        generate_suggestions "$script" "$category"
        
    done <<< "$modified_scripts"
    
    # Summary
    echo "═══ Summary ═══"
    echo "Scripts analyzed: $TOTAL_CHECKS"
    echo "Warnings:         $WARNINGS"
    echo "Suggestions:      $SUGGESTIONS"
    echo ""
    
    if [[ $WARNINGS -eq 0 ]]; then
        success "All code changes have corresponding documentation updates!"
        return 0
    else
        warning "$WARNINGS potential documentation drifts detected"
        info "Review suggestions above to keep documentation synchronized"
        return 0  # Don't fail - warnings only
    fi
}

# Run main function
main "$@"
