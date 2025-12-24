#!/usr/bin/env bash
# Documentation Example Validator
# Validates that code examples in documentation remain accurate and functional
#
# Usage: ./scripts/validate_doc_examples.sh [--fix] [--verbose]

set -euo pipefail

# Source colors for output
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Options
FIX_MODE=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --fix)
            FIX_MODE=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--fix] [--verbose]"
            echo ""
            echo "Options:"
            echo "  --fix       Attempt to fix issues automatically"
            echo "  --verbose   Show detailed output"
            echo "  --help      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $*"
    PASSED_CHECKS=$((PASSED_CHECKS + 1)) || true
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
    WARNINGS=$((WARNINGS + 1)) || true
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $*"
    FAILED_CHECKS=$((FAILED_CHECKS + 1)) || true
}

check_command() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1)) || true
    if command -v "$1" &>/dev/null; then
        [[ "$VERBOSE" == "true" ]] && log_success "Command '$1' is available"
        return 0
    else
        log_warning "Command '$1' not found (optional)"
        return 1
    fi
}

# Validation functions

validate_file_paths() {
    log_info "Validating file paths in documentation..."
    local failed=0
    
    # Extract file paths from code blocks and inline code
    while IFS= read -r file; do
        local doc_file="${file%%:*}"
        local path="${file#*:}"
        
        # Skip URLs and placeholders
        [[ "$path" =~ ^http ]] && continue
        [[ "$path" =~ /path/to/ ]] && continue
        [[ "$path" =~ \$\{ ]] && continue
        [[ "$path" =~ "<" ]] && continue
        
        # Make path absolute if relative
        local full_path="$path"
        if [[ ! "$path" =~ ^/ ]]; then
            full_path="${PROJECT_ROOT}/${path}"
        fi
        
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if [[ -e "$full_path" ]]; then
            [[ "$VERBOSE" == "true" ]] && log_success "Path exists: $path (in $doc_file)"
        else
            log_error "Path not found: $path (referenced in $doc_file)"
            failed=$((failed + 1))
        fi
    done < <(grep -r '[a-z]*\.\(sh\|md\|yaml\|json\)' "${PROJECT_ROOT}/docs" "${PROJECT_ROOT}/README.md" 2>/dev/null | \
             sed 's/.*[\`"]\([^`"]*\.[a-z]*\)[\`"].*/\1/' | sort -u | head -100)
    
    return $failed
}

validate_script_examples() {
    log_info "Validating script path examples..."
    local failed=0
    
    # Check execute_tests_docs_workflow.sh references
    local main_script="${PROJECT_ROOT}/src/workflow/execute_tests_docs_workflow.sh"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1)) || true
    if [[ -x "$main_script" ]]; then
        log_success "Main workflow script exists and is executable"
    else
        log_error "Main workflow script not found or not executable: $main_script"
        failed=$((failed + 1)) || true
    fi
    
    # Check lib directory structure
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1)) || true
    if [[ -d "${PROJECT_ROOT}/src/workflow/lib" ]]; then
        local lib_count=$(find "${PROJECT_ROOT}/src/workflow/lib" -name "*.sh" -type f | wc -l)
        if [[ $lib_count -ge 25 ]]; then
            log_success "Library modules found: $lib_count files"
        else
            log_warning "Expected 28+ library modules, found: $lib_count"
        fi
    else
        log_error "Library directory not found: src/workflow/lib"
        failed=$((failed + 1)) || true
    fi
    
    # Check step modules
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1)) || true
    if [[ -d "${PROJECT_ROOT}/src/workflow/steps" ]]; then
        local step_count=$(find "${PROJECT_ROOT}/src/workflow/steps" -name "step_*.sh" -type f | wc -l)
        if [[ $step_count -eq 15 ]]; then
            log_success "Step modules found: $step_count files - expected 15"
        else
            log_warning "Expected 15 step modules, found: $step_count"
        fi
    else
        log_error "Steps directory not found: src/workflow/steps"
        failed=$((failed + 1)) || true
    fi
    
    return $failed
}

validate_command_examples() {
    log_info "Validating command-line examples..."
    local failed=0
    
    # Extract bash commands from code blocks  
    local temp_file
    temp_file=$(mktemp)
    # Use a different pattern to avoid backtick issues
    grep -rh 'bash$' -A 20 "${PROJECT_ROOT}/docs" "${PROJECT_ROOT}/README.md" 2>/dev/null | \
        grep "execute_tests_docs_workflow.sh" > "$temp_file" || true
    
    # Check for valid flags
    local valid_flags=(
        "--smart-execution"
        "--parallel"
        "--auto"
        "--target"
        "--no-resume"
        "--show-graph"
        "--init-config"
        "--show-tech-stack"
        "--config-file"
        "--steps"
        "--dry-run"
        "--no-ai-cache"
    )
    
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        
        # Extract flags from line
        for flag in "${valid_flags[@]}"; do
            if [[ "$line" =~ $flag ]]; then
                TOTAL_CHECKS=$((TOTAL_CHECKS + 1)) || true
                # Verify flag is still valid
                if "${PROJECT_ROOT}/src/workflow/execute_tests_docs_workflow.sh" --help 2>&1 | grep -q "$flag"; then
                    [[ "$VERBOSE" == "true" ]] && log_success "Flag '$flag' is valid"
                else
                    log_error "Flag '$flag' not recognized in --help output"
                    failed=$((failed + 1)) || true
                fi
            fi
        done
    done < "$temp_file"
    
    rm -f "$temp_file"
    return $failed
}

validate_version_references() {
    log_info "Validating version references..."
    local failed=0
    
    # Get current version from PROJECT_REFERENCE.md
    local current_version
    if [[ -f "${PROJECT_ROOT}/docs/PROJECT_REFERENCE.md" ]]; then
        current_version=$(grep "^- \*\*Current Version\*\*:" "${PROJECT_ROOT}/docs/PROJECT_REFERENCE.md" | sed 's/.*v\([0-9.]*\).*/\1/')
    else
        current_version="2.4.0"  # fallback
    fi
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1)) || true
    if [[ -n "$current_version" ]]; then
        log_success "Current version identified: v$current_version"
        
        # Check for outdated version references
        local outdated=$(grep -r "v2\.[0-2]\." "${PROJECT_ROOT}/docs" "${PROJECT_ROOT}/README.md" 2>/dev/null | \
                        grep -v "RELEASE_NOTES" | \
                        grep -v "MIGRATION" | \
                        grep -v "archive/" | \
                        wc -l)
        
        if [[ $outdated -gt 0 ]]; then
            log_warning "Found $outdated potentially outdated version references - v2.0-v2.2"
        fi
    else
        log_error "Could not determine current version"
        failed=$((failed + 1)) || true
    fi
    
    return $failed
}

validate_example_files() {
    log_info "Validating example files..."
    local failed=0
    
    # Check examples directory
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1)) || true
    if [[ -d "${PROJECT_ROOT}/examples" ]]; then
        log_success "Examples directory exists"
        
        # Check example scripts are valid shell scripts
        while IFS= read -r example_file; do
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1)) || true
            if bash -n "$example_file" 2>/dev/null; then
                [[ "$VERBOSE" == "true" ]] && log_success "Valid shell script: $(basename "$example_file")"
            else
                log_error "Invalid shell script: $example_file"
                failed=$((failed + 1)) || true
            fi
        done < <(find "${PROJECT_ROOT}/examples" -name "*.sh" -type f)
    else
        log_warning "No examples directory found"
    fi
    
    return $failed
}

validate_documentation_structure() {
    log_info "Validating documentation structure..."
    local failed=0
    
    # Key documentation files that should exist
    local key_docs=(
        "README.md"
        "docs/PROJECT_REFERENCE.md"
        "docs/V2.4.0_COMPLETE_FEATURE_GUIDE.md"
        "docs/EXAMPLE_PROJECTS_GUIDE.md"
        "docs/QUICK_START_GUIDE.md"
        "docs/TARGET_PROJECT_FEATURE.md"
        ".github/copilot-instructions.md"
    )
    
    for doc in "${key_docs[@]}"; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1)) || true
        if [[ -f "${PROJECT_ROOT}/${doc}" ]]; then
            [[ "$VERBOSE" == "true" ]] && log_success "Found: $doc"
        else
            log_error "Missing key documentation: $doc"
            failed=$((failed + 1)) || true
        fi
    done
    
    return $failed
}

validate_code_block_syntax() {
    log_info "Validating code block syntax..."
    local failed=0
    
    # Check for unclosed code blocks
    while IFS= read -r file; do
        local backticks
        backticks=$(grep -c '^```' "$file" 2>/dev/null || echo "0")
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        
        if [[ $((backticks % 2)) -eq 0 ]]; then
            [[ "$VERBOSE" == "true" ]] && log_success "Code blocks balanced in $(basename "$file")"
        else
            log_error "Unclosed code blocks in $file - found $backticks code fences"
            failed=$((failed + 1))
        fi
    done < <(find "${PROJECT_ROOT}/docs" "${PROJECT_ROOT}" -maxdepth 1 -name "*.md" -type f)
    
    return $failed
}

generate_report() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}DOCUMENTATION VALIDATION REPORT${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Total Checks:    $TOTAL_CHECKS"
    echo -e "Passed:          ${GREEN}$PASSED_CHECKS${NC}"
    echo -e "Failed:          ${RED}$FAILED_CHECKS${NC}"
    echo -e "Warnings:        ${YELLOW}$WARNINGS${NC}"
    echo ""
    
    local success_rate=0
    if [[ $TOTAL_CHECKS -gt 0 ]]; then
        success_rate=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
    fi
    
    echo "Success Rate:    ${success_rate}%"
    echo ""
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo -e "${GREEN}✅ All validation checks passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ Some validation checks failed${NC}"
        echo ""
        echo "Recommendations:"
        echo "1. Review failed checks above"
        echo "2. Update outdated documentation"
        echo "3. Fix broken references"
        echo "4. Run tests to verify changes"
        return 1
    fi
}

# Main execution
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Documentation Example Validator"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    cd "${PROJECT_ROOT}"
    
    # Run validations
    validate_documentation_structure
    validate_file_paths
    validate_script_examples
    validate_command_examples
    validate_version_references
    validate_example_files
    validate_code_block_syntax
    
    # Generate report
    generate_report
}

main "$@"
