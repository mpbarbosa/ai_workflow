#!/bin/bash
set -euo pipefail

################################################################################
# Pre-Commit Hooks Module
# Version: 3.0.0
# Purpose: Fast validation checks before commits to prevent workflow failures
#
# Features:
#   - Sub-second syntax validation
#   - Auto-staging of generated files
#   - Project-type specific checks
#   - Configurable hook templates
#   - Easy installation and management
#
# Performance Target: < 1 second for all checks
################################################################################

# Set defaults
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
HOOKS_DIR="${PROJECT_ROOT}/.git/hooks"
HOOKS_TEMPLATE_DIR="${WORKFLOW_HOME}/templates/hooks"

# ==============================================================================
# HOOK TEMPLATES
# ==============================================================================

# Generate pre-commit hook template
# Args: $1 = project_kind (optional)
generate_precommit_template() {
    local project_kind="${1:-generic}"
    
    cat << 'EOF'
#!/usr/bin/env bash
# AI Workflow - Pre-Commit Hook
# Auto-generated - DO NOT EDIT MANUALLY
# Regenerate with: ./src/workflow/execute_tests_docs_workflow.sh --install-hooks

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

cd "$(git rev-parse --show-toplevel)"

echo -e "${CYAN}🔍 Running pre-commit checks...${NC}"

# Track failures
FAILED=false
START_TIME=$(date +%s)

# ==============================================================================
# FAST VALIDATION CHECKS (< 1 second)
# ==============================================================================

EOF
    
    # Add project-specific checks
    case "$project_kind" in
        shell*|bash*)
            cat << 'EOF'
# Shell script syntax check
if command -v shellcheck >/dev/null 2>&1; then
    echo -ne "  Checking shell syntax... "
    if git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' | xargs -r shellcheck -x 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${RED}Shell syntax errors detected. Fix with: shellcheck file.sh${NC}"
        FAILED=true
    fi
fi

EOF
            ;;
        nodejs*|javascript*|typescript*)
            cat << 'EOF'
# JavaScript/TypeScript syntax check
if command -v node >/dev/null 2>&1; then
    echo -ne "  Checking JS/TS syntax... "
    if git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|ts|jsx|tsx)$' | while read -r file; do
        node --check "$file" 2>/dev/null || exit 1
    done; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${RED}JavaScript/TypeScript syntax errors detected${NC}"
        FAILED=true
    fi
fi

# ESLint check (if available)
if command -v eslint >/dev/null 2>&1 && [[ -f .eslintrc.js || -f .eslintrc.json ]]; then
    echo -ne "  Running ESLint... "
    if git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|ts|jsx|tsx)$' | xargs -r eslint --max-warnings=0 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${RED}ESLint errors detected. Fix with: eslint --fix${NC}"
        FAILED=true
    fi
fi

EOF
            ;;
        python*)
            cat << 'EOF'
# Python syntax check
if command -v python3 >/dev/null 2>&1; then
    echo -ne "  Checking Python syntax... "
    if git diff --cached --name-only --diff-filter=ACM | grep '\.py$' | while read -r file; do
        python3 -m py_compile "$file" 2>/dev/null || exit 1
    done; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${RED}Python syntax errors detected${NC}"
        FAILED=true
    fi
fi

# Black formatting check (if available)
if command -v black >/dev/null 2>&1; then
    echo -ne "  Checking Python formatting... "
    if git diff --cached --name-only --diff-filter=ACM | grep '\.py$' | xargs -r black --check 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}⚠${NC}"
        echo -e "${YELLOW}Python formatting issues. Auto-fix with: black .${NC}"
        # Auto-fix and stage
        git diff --cached --name-only --diff-filter=ACM | grep '\.py$' | xargs -r black
        git diff --cached --name-only --diff-filter=ACM | grep '\.py$' | xargs git add
    fi
fi

EOF
            ;;
    esac
    
    # Common checks for all project types
    cat << 'EOF'
# Markdown syntax check (basic)
echo -ne "  Checking Markdown syntax... "
if git diff --cached --name-only --diff-filter=ACM | grep '\.md$' | while read -r file; do
    # Check for basic syntax issues
    if grep -q '```.*```' "$file" 2>/dev/null; then
        # Check for unclosed code blocks
        local backticks=$(grep -c '```' "$file")
        if (( backticks % 2 != 0 )); then
            echo -e "${RED}Unclosed code block in $file${NC}" >&2
            exit 1
        fi
    fi
done; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo -e "${RED}Markdown syntax errors detected${NC}"
    FAILED=true
fi

# Check for merge conflict markers
echo -ne "  Checking for merge conflicts... "
if git diff --cached --name-only --diff-filter=ACM | xargs -r grep -n '<<<<<<< \|=======$\|>>>>>>> ' 2>/dev/null; then
    echo -e "${RED}✗${NC}"
    echo -e "${RED}Merge conflict markers found. Resolve conflicts before committing.${NC}"
    FAILED=true
else
    echo -e "${GREEN}✓${NC}"
fi

# Check for debug statements
echo -ne "  Checking for debug statements... "
if git diff --cached --name-only --diff-filter=ACM | xargs -r grep -n 'console\.log\|debugger\|TODO.*REMOVE' 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC}"
    echo -e "${YELLOW}Debug statements found. Consider removing before commit.${NC}"
    # Don't fail, just warn
else
    echo -e "${GREEN}✓${NC}"
fi

# Check for large files (> 1MB)
echo -ne "  Checking file sizes... "
LARGE_FILES=$(git diff --cached --name-only --diff-filter=ACM | while read -r file; do
    if [[ -f "$file" ]]; then
        size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
        if (( size > 1048576 )); then
            echo "$file ($(( size / 1024 / 1024 ))MB)"
        fi
    fi
done)

if [[ -n "$LARGE_FILES" ]]; then
    echo -e "${YELLOW}⚠${NC}"
    echo -e "${YELLOW}Large files detected:${NC}"
    echo "$LARGE_FILES"
    echo -e "${YELLOW}Consider using Git LFS for large files.${NC}"
else
    echo -e "${GREEN}✓${NC}"
fi

# ==============================================================================
# AUTO-STAGING GENERATED FILES
# ==============================================================================

# Check for generated files that need staging
GENERATED_FILES=(
    "cdn-urls.txt"
    "package-lock.json"
    "yarn.lock"
    "composer.lock"
    "Gemfile.lock"
    "poetry.lock"
)

for file in "${GENERATED_FILES[@]}"; do
    if [[ -f "$file" ]] && git diff --name-only "$file" >/dev/null 2>&1; then
        if ! git diff --cached --name-only | grep -q "^$file$"; then
            echo -e "${CYAN}  Auto-staging generated file: $file${NC}"
            git add "$file"
        fi
    fi
done

# ==============================================================================
# COMPLETION
# ==============================================================================

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [[ "$FAILED" == "true" ]]; then
    echo ""
    echo -e "${RED}❌ Pre-commit checks failed${NC}"
    echo -e "${RED}Fix the issues above and try again${NC}"
    echo ""
    echo "To skip these checks (not recommended):"
    echo "  git commit --no-verify"
    exit 1
else
    echo ""
    echo -e "${GREEN}✅ All pre-commit checks passed${NC} (${DURATION}s)"
    exit 0
fi
EOF
}

# ==============================================================================
# HOOK INSTALLATION
# ==============================================================================

# Install pre-commit hook
# Args: $1 = project_kind (optional)
install_precommit_hook() {
    local project_kind="${1:-}"
    
    # Detect project kind if not provided
    if [[ -z "$project_kind" ]]; then
        project_kind=$(detect_project_kind 2>/dev/null || echo "generic")
    fi
    
    print_header "Installing Pre-Commit Hook"
    
    # Create hooks directory if it doesn't exist
    if [[ ! -d "$HOOKS_DIR" ]]; then
        print_error "Not a git repository or .git/hooks directory not found"
        return 1
    fi
    
    local hook_file="${HOOKS_DIR}/pre-commit"
    
    # Backup existing hook if present
    if [[ -f "$hook_file" ]]; then
        local backup="${hook_file}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$hook_file" "$backup"
        print_info "Existing hook backed up to: $backup"
    fi
    
    # Generate and install new hook
    generate_precommit_template "$project_kind" > "$hook_file"
    chmod +x "$hook_file"
    
    print_success "Pre-commit hook installed for project type: $project_kind"
    print_info "Hook location: $hook_file"
    
    # Show what the hook does
    echo ""
    echo "The hook will:"
    echo "  • Run syntax validation (< 1 second)"
    echo "  • Check for merge conflicts"
    echo "  • Warn about debug statements"
    echo "  • Auto-stage generated files"
    echo ""
    echo "To skip the hook: git commit --no-verify"
    
    return 0
}

# Uninstall pre-commit hook
uninstall_precommit_hook() {
    local hook_file="${HOOKS_DIR}/pre-commit"
    
    if [[ ! -f "$hook_file" ]]; then
        print_warning "No pre-commit hook installed"
        return 0
    fi
    
    # Check if it's our hook
    if grep -q "AI Workflow - Pre-Commit Hook" "$hook_file"; then
        rm "$hook_file"
        print_success "Pre-commit hook uninstalled"
    else
        print_warning "Pre-commit hook not managed by AI Workflow (not removing)"
        return 1
    fi
}

# ==============================================================================
# HOOK TESTING
# ==============================================================================

# Test pre-commit hook without committing
test_precommit_hook() {
    local hook_file="${HOOKS_DIR}/pre-commit"
    
    if [[ ! -f "$hook_file" ]]; then
        print_error "No pre-commit hook installed"
        return 1
    fi
    
    print_header "Testing Pre-Commit Hook"
    
    # Run the hook in test mode
    if bash "$hook_file"; then
        print_success "Pre-commit hook test passed"
        return 0
    else
        print_error "Pre-commit hook test failed"
        return 1
    fi
}

# ==============================================================================
# FAST VALIDATION FUNCTIONS
# ==============================================================================

# Fast syntax check for shell scripts
# Returns: 0 if all valid, 1 if errors found
validate_shell_syntax() {
    if ! command -v shellcheck >/dev/null 2>&1; then
        print_warning "shellcheck not installed, skipping shell validation"
        return 0
    fi
    
    local files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' || true)
    
    [[ -z "$files" ]] && return 0
    
    echo "$files" | xargs shellcheck -x 2>&1
}

# Fast syntax check for JavaScript/TypeScript
validate_js_syntax() {
    if ! command -v node >/dev/null 2>&1; then
        return 0
    fi
    
    local files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|ts|jsx|tsx)$' || true)
    
    [[ -z "$files" ]] && return 0
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        node --check "$file" 2>&1 || return 1
    done <<< "$files"
    
    return 0
}

# Fast syntax check for Python
validate_python_syntax() {
    if ! command -v python3 >/dev/null 2>&1; then
        return 0
    fi
    
    local files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$' || true)
    
    [[ -z "$files" ]] && return 0
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        python3 -m py_compile "$file" 2>&1 || return 1
    done <<< "$files"
    
    return 0
}

# Check for merge conflict markers
check_merge_conflicts() {
    local files=$(git diff --cached --name-only --diff-filter=ACM || true)
    
    [[ -z "$files" ]] && return 0
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        if grep -q '<<<<<<< \|=======$\|>>>>>>> ' "$file" 2>/dev/null; then
            echo "Merge conflict markers found in: $file"
            return 1
        fi
    done <<< "$files"
    
    return 0
}

# ==============================================================================
# AUTO-STAGING
# ==============================================================================

# Auto-stage generated files
auto_stage_generated_files() {
    local staged=0
    
    local generated_files=(
        "cdn-urls.txt"
        "package-lock.json"
        "yarn.lock"
        "composer.lock"
        "Gemfile.lock"
        "poetry.lock"
        "Pipfile.lock"
    )
    
    for file in "${generated_files[@]}"; do
        if [[ -f "$file" ]] && git diff --name-only "$file" >/dev/null 2>&1; then
            if ! git diff --cached --name-only | grep -q "^$file$"; then
                git add "$file"
                print_info "Auto-staged: $file"
                ((staged++))
            fi
        fi
    done
    
    if [[ $staged -gt 0 ]]; then
        print_success "Auto-staged $staged generated file(s)"
    fi
    
    return 0
}

# ==============================================================================
# HOOK CONFIGURATION
# ==============================================================================

# Create hook configuration file
create_hook_config() {
    local config_file="${PROJECT_ROOT}/.pre-commit-config.yaml"
    
    cat > "$config_file" << 'EOF'
# AI Workflow Pre-Commit Configuration
# Version: 3.0.0

# Enable/disable specific checks
checks:
  syntax: true
  merge_conflicts: true
  debug_statements: true
  file_size: true
  formatting: false  # Enable to auto-format code

# File size limits
file_size:
  max_mb: 1
  warn_only: true

# Auto-staging
auto_stage:
  enabled: true
  files:
    - cdn-urls.txt
    - "*.lock"

# Performance
timeout_seconds: 2
fail_fast: false

# Exclusions
exclude:
  - node_modules/
  - .git/
  - coverage/
  - dist/
  - build/
EOF
    
    print_success "Created hook configuration: $config_file"
    echo "$config_file"
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f generate_precommit_template
export -f install_precommit_hook
export -f uninstall_precommit_hook
export -f test_precommit_hook
export -f validate_shell_syntax
export -f validate_js_syntax
export -f validate_python_syntax
export -f check_merge_conflicts
export -f auto_stage_generated_files
export -f create_hook_config

################################################################################
# End of Pre-Commit Hooks Module
################################################################################
