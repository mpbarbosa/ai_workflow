#!/bin/bash
set -euo pipefail

################################################################################
# Validation Module
# Purpose: Pre-flight checks and dependency validation
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# ==============================================================================
# PROJECT TECH STACK DETECTION
# ==============================================================================

detect_project_tech_stack() {
    local tech_stack=()
    
    # Check for Node.js/JavaScript/TypeScript
    if [[ -f "$SRC_DIR/package.json" ]] || [[ -f "$PROJECT_ROOT/package.json" ]]; then
        tech_stack+=("nodejs")
    fi
    
    # Check for Python
    if [[ -f "$PROJECT_ROOT/requirements.txt" ]] || [[ -f "$PROJECT_ROOT/setup.py" ]] || \
       [[ -f "$PROJECT_ROOT/pyproject.toml" ]] || [[ -f "$PROJECT_ROOT/Pipfile" ]]; then
        tech_stack+=("python")
    fi
    
    # Check for Ruby
    if [[ -f "$PROJECT_ROOT/Gemfile" ]]; then
        tech_stack+=("ruby")
    fi
    
    # Check for Go
    if [[ -f "$PROJECT_ROOT/go.mod" ]]; then
        tech_stack+=("go")
    fi
    
    # Check for Rust
    if [[ -f "$PROJECT_ROOT/Cargo.toml" ]]; then
        tech_stack+=("rust")
    fi
    
    # Check for Java/Maven
    if [[ -f "$PROJECT_ROOT/pom.xml" ]]; then
        tech_stack+=("java-maven")
    fi
    
    # Check for Java/Gradle
    if [[ -f "$PROJECT_ROOT/build.gradle" ]] || [[ -f "$PROJECT_ROOT/build.gradle.kts" ]]; then
        tech_stack+=("java-gradle")
    fi
    
    # If no specific tech detected, assume it's a shell/bash project
    if [[ ${#tech_stack[@]} -eq 0 ]]; then
        tech_stack+=("shell")
    fi
    
    echo "${tech_stack[@]}"
}

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
    
    # Check 2: Verify src directory (optional for some projects)
    if [[ ! -d "$SRC_DIR" ]]; then
        print_warning "Source directory not found: $SRC_DIR (may not be required)"
    else
        print_success "Source directory: $SRC_DIR"
    fi
    
    # Detect project tech stack
    print_info "Detecting project technology stack..."
    local tech_stack=($(detect_project_tech_stack))
    if [[ ${#tech_stack[@]} -gt 0 ]]; then
        print_success "Tech stack detected: ${tech_stack[*]}"
    else
        print_info "No specific tech stack detected, assuming generic project"
    fi
    
    # Check 3: Verify package.json exists (only for Node.js projects)
    if [[ " ${tech_stack[*]} " =~ " nodejs " ]]; then
        if [[ ! -f "$SRC_DIR/package.json" ]] && [[ ! -f "$PROJECT_ROOT/package.json" ]]; then
            print_error "package.json not found (required for Node.js projects)"
            checks_passed=false
        else
            print_success "package.json found"
        fi
        
        # Check 4: Verify Node.js/npm installation (only for Node.js projects)
        print_info "Checking Node.js and npm..."
        if ! command -v node &> /dev/null; then
            print_error "Node.js is not installed (required for this project)"
            checks_passed=false
        else
            local node_version=$(node --version)
            print_success "Node.js: $node_version"
        fi
        
        if ! command -v npm &> /dev/null; then
            print_error "npm is not installed (required for this project)"
            checks_passed=false
        else
            local npm_version=$(npm --version)
            print_success "npm: $npm_version"
        fi
    else
        # Optional checks for non-Node.js projects
        if command -v node &> /dev/null; then
            local node_version=$(node --version)
            print_info "Node.js available: $node_version (not required)"
        fi
        
        if command -v npm &> /dev/null; then
            local npm_version=$(npm --version)
            print_info "npm available: $npm_version (not required)"
        fi
    fi
    
    # Additional tech-specific checks
    if [[ " ${tech_stack[*]} " =~ " python " ]]; then
        if command -v python3 &> /dev/null; then
            local python_version=$(python3 --version)
            print_success "Python: $python_version"
        else
            print_warning "Python3 not found (may be required)"
        fi
    fi
    
    if [[ " ${tech_stack[*]} " =~ " ruby " ]]; then
        if command -v ruby &> /dev/null; then
            local ruby_version=$(ruby --version | awk '{print $2}')
            print_success "Ruby: $ruby_version"
        else
            print_warning "Ruby not found (may be required)"
        fi
    fi
    
    if [[ " ${tech_stack[*]} " =~ " go " ]]; then
        if command -v go &> /dev/null; then
            local go_version=$(go version | awk '{print $3}')
            print_success "Go: $go_version"
        else
            print_warning "Go not found (may be required)"
        fi
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
    
    # Check 7: Verify docs directory
    if [[ ! -d "$DOCS_DIR" ]]; then
        print_warning "docs directory not found - will be created if needed"
    else
        print_success "docs directory found"
    fi
    
    # Check 8: Optional - tree command
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
    
    # Detect project tech stack
    local tech_stack=($(detect_project_tech_stack))
    
    # Only validate dependencies for projects that need them
    if [[ " ${tech_stack[*]} " =~ " nodejs " ]]; then
        print_info "Node.js project detected - validating npm dependencies..."
        
        # Determine package.json location
        local pkg_dir="$SRC_DIR"
        if [[ ! -f "$SRC_DIR/package.json" ]] && [[ -f "$PROJECT_ROOT/package.json" ]]; then
            pkg_dir="$PROJECT_ROOT"
        fi
        
        cd "$pkg_dir"
        
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
        
        # Verify Jest is available (if package.json has it as dependency)
        if grep -q '"jest"' package.json 2>/dev/null; then
            if [[ -f "node_modules/.bin/jest" ]]; then
                print_success "Jest is available"
            else
                print_warning "Jest not found in node_modules (may need npm install)"
            fi
        fi
        
        cd "$PROJECT_ROOT"
        
    elif [[ " ${tech_stack[*]} " =~ " python " ]]; then
        print_info "Python project detected - dependency validation via pip/pipenv would go here"
        print_success "Python project validation skipped (not implemented)"
        
    elif [[ " ${tech_stack[*]} " =~ " ruby " ]]; then
        print_info "Ruby project detected - dependency validation via bundler would go here"
        print_success "Ruby project validation skipped (not implemented)"
        
    elif [[ " ${tech_stack[*]} " =~ " go " ]]; then
        print_info "Go project detected - dependency validation via go mod would go here"
        print_success "Go project validation skipped (not implemented)"
        
    elif [[ " ${tech_stack[*]} " =~ " shell " ]]; then
        print_info "Shell/Bash project detected - no dependency installation needed"
        print_success "Shell project validation complete"
        
    else
        print_info "Generic project - no dependency validation needed"
        print_success "Dependency validation skipped"
    fi
}

# Export validation functions
export -f detect_project_tech_stack check_prerequisites validate_dependencies
