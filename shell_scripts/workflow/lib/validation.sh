#!/bin/bash
################################################################################
# Validation Module
# Purpose: Pre-flight checks and dependency validation
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# ==============================================================================
# PRE-FLIGHT SYSTEM CHECKS
# ==============================================================================

check_prerequisites() {
    print_header "Pre-Flight System Checks"
    
    local checks_passed=true
    
    # Check 1: Verify project directory
    print_info "Checking project directory structure..."
    if [[ ! -d "$PROJECT_ROOT" ]]; then
        print_error "Project root not found: $PROJECT_ROOT"
        checks_passed=false
    else
        print_success "Project root: $PROJECT_ROOT"
    fi
    
    # Check 2: Verify src directory
    if [[ ! -d "$SRC_DIR" ]]; then
        print_error "Source directory not found: $SRC_DIR"
        checks_passed=false
    else
        print_success "Source directory: $SRC_DIR"
    fi
    
    # Check 3: Verify package.json exists
    if [[ ! -f "$SRC_DIR/package.json" ]]; then
        print_error "package.json not found in $SRC_DIR"
        checks_passed=false
    else
        print_success "package.json found"
    fi
    
    # Check 4: Verify Node.js/npm installation
    print_info "Checking Node.js and npm..."
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        checks_passed=false
    else
        local node_version=$(node --version)
        print_success "Node.js: $node_version"
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed"
        checks_passed=false
    else
        local npm_version=$(npm --version)
        print_success "npm: $npm_version"
    fi
    
    # Check 5: Verify git repository
    print_info "Checking git repository..."
    if ! git -C "$PROJECT_ROOT" rev-parse --git-dir &> /dev/null; then
        print_error "Not a git repository: $PROJECT_ROOT"
        checks_passed=false
    else
        print_success "Git repository validated"
    fi
    
    # Check 6: Check git working tree status
    if git -C "$PROJECT_ROOT" diff-index --quiet HEAD -- 2>/dev/null; then
        print_success "Git working tree is clean"
    else
        print_warning "Git working tree has uncommitted changes"
        print_info "Staging all changes with 'git add -A'..."
        
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY RUN] Would execute: git add -A"
        else
            git -C "$PROJECT_ROOT" add -A
            print_success "All changes staged successfully"
        fi
    fi
    
    # Check 7: Verify shell_scripts directory
    if [[ ! -d "$SHELL_SCRIPTS_DIR" ]]; then
        print_error "shell_scripts directory not found"
        checks_passed=false
    else
        print_success "shell_scripts directory found"
    fi
    
    # Check 8: Verify docs directory
    if [[ ! -d "$DOCS_DIR" ]]; then
        print_warning "docs directory not found - will be created if needed"
    else
        print_success "docs directory found"
    fi
    
    # Check 9: Optional - tree command
    if command -v tree &> /dev/null; then
        print_success "tree command available (optional)"
    else
        print_info "tree command not found (optional - some validation features limited)"
    fi
    
    # Final verdict
    echo ""
    if [[ "$checks_passed" == false ]]; then
        print_error "Pre-flight checks failed. Please resolve issues before continuing."
        exit 1
    else
        print_success "All pre-flight checks passed!"
    fi
}

# ==============================================================================
# DEPENDENCY VALIDATION
# ==============================================================================

validate_dependencies() {
    print_header "Validating Dependencies"
    
    cd "$SRC_DIR"
    
    # Check if node_modules exists
    if [[ ! -d "node_modules" ]]; then
        print_warning "node_modules not found. Installing dependencies..."
        
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY RUN] Would execute: npm install"
        else
            npm install
            print_success "Dependencies installed"
        fi
    else
        print_success "node_modules directory exists"
    fi
    
    # Verify Jest is available
    if [[ -f "node_modules/.bin/jest" ]]; then
        print_success "Jest is available"
    else
        print_error "Jest not found in node_modules"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
}

# Export validation functions
export -f check_prerequisites validate_dependencies
