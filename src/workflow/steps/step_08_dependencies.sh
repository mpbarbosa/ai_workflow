#!/bin/bash
set -euo pipefail

################################################################################
# Step 8: AI-Powered Dependency Validation
# Purpose: Validate dependencies and environment configuration (adaptive)
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Version: 2.1.0
################################################################################

# Module version information
readonly STEP8_VERSION="2.1.0"
readonly STEP8_VERSION_MAJOR=2
readonly STEP8_VERSION_MINOR=1
readonly STEP8_VERSION_PATCH=0

# Detect project tech stack
detect_project_tech_stack_step8() {
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
    
    # If no specific tech detected, assume shell/bash project
    if [[ ${#tech_stack[@]} -eq 0 ]]; then
        tech_stack+=("shell")
    fi
    
    echo "${tech_stack[@]}"
}

# Main step function - validates dependencies with AI assistance (adaptive - Phase 3)
# Returns: 0 for success, 1 for failure
step8_validate_dependencies() {
    print_step "8" "Validate Dependencies & Environment"
    
    # Use global tech stack detection from Phase 3
    local language="${PRIMARY_LANGUAGE:-javascript}"
    local build_system="${BUILD_SYSTEM:-npm}"
    local package_file="${TECH_STACK_CONFIG[package_file]:-package.json}"
    
    # If config file exists, read directly from it as fallback
    if [[ -f "$PROJECT_ROOT/.workflow-config.yaml" ]]; then
        local config_language=$(grep "primary_language:" "$PROJECT_ROOT/.workflow-config.yaml" | awk -F':' '{print $2}' | tr -d ' "' | head -1)
        local config_build=$(grep "build_system:" "$PROJECT_ROOT/.workflow-config.yaml" | awk -F':' '{print $2}' | tr -d ' "' | head -1)
        
        # Override if found in config
        if [[ -n "$config_language" ]]; then
            language="$config_language"
            print_info "Loaded language from config: ${language}"
        fi
        if [[ -n "$config_build" ]]; then
            build_system="$config_build"
            print_info "Loaded build system from config: ${build_system}"
        fi
    fi
    
    print_info "Tech Stack: ${language}/${build_system}"
    print_info "Package file: ${package_file}"
    
    # DEBUG: Show actual values being checked
    print_info "DEBUG: language='${language}' build_system='${build_system}'"
    
    # Skip dependency validation for shell/bash projects
    # IMPORTANT: Check build_system FIRST as it's the most reliable indicator
    if [[ "$build_system" == "none" ]] || [[ "$language" == "bash" ]] || [[ "$language" == "shell" ]] || [[ "$language" == "sh" ]]; then
        print_info "Shell/Bash project detected - no package dependencies to validate"
        
        local step_summary="### Dependency Validation - Shell Project

**Tech Stack:** Shell/Bash
**Status:** ✅ SKIPPED (No package dependencies)

Shell/Bash projects don't require package manager dependencies.
Validation focused on system tools and git repository health.
"
        save_step_issues "8" "Dependency_Validation" "$step_summary"
        save_step_summary "8" "Dependency_Validation" "Shell project - no dependencies to validate" "✅"
        update_workflow_status "step8" "✅"
        
        cd "$PROJECT_ROOT" || return 1
        return 0
    fi
    
    # Determine working directory based on tech stack
    # For JavaScript/Node.js projects, check PROJECT_ROOT (set by --target)
    local work_dir="$PROJECT_ROOT"
    
    # Verify package.json exists before proceeding
    if [[ "$language" =~ ^(javascript|typescript|nodejs)$ ]]; then
        if [[ ! -f "${work_dir}/package.json" ]]; then
            # Try SRC_DIR as fallback
            if [[ -f "${SRC_DIR}/package.json" ]]; then
                work_dir="$SRC_DIR"
            fi
        fi
    fi
    
    print_info "Working directory: $work_dir"
    print_info "DEBUG: Checking for package.json at: ${work_dir}/${package_file}"
    
    cd "$work_dir" || {
        print_error "Cannot navigate to working directory: $work_dir"
        return 1
    }
    
    local issues=0
    local dependency_report
    dependency_report=$(mktemp)
    TEMP_FILES+=("$dependency_report")
    
    # PHASE 1: Automated dependency analysis (ADAPTIVE - Phase 3)
    print_info "Phase 1: Automated dependency analysis (${language})..."
    
    case "$language" in
        javascript|typescript|nodejs)
            # JavaScript/Node.js dependency validation
            print_info "Validating ${package_file}..."
            if [[ ! -f "$package_file" ]]; then
                print_error "${package_file} not found!"
                echo "CRITICAL: Missing ${package_file}" >> "$dependency_report"
                ((issues++))
                
                # Save error to backlog before returning
                local step_issues="### Dependency Validation - CRITICAL ERROR

**Total Issues:** ${issues}
**Status:** ❌ FAILED

CRITICAL: Missing ${package_file} file. Cannot validate dependencies.
"
                save_step_issues "8" "Dependency_Validation" "$step_issues"
                save_step_summary "8" "Dependency_Validation" "CRITICAL: Missing ${package_file} file." "❌"
                
                cd "$PROJECT_ROOT" || return 1
                update_workflow_status "step8" "❌"
                return 1
            fi
            
            # Validate JSON syntax
            if jq empty "$package_file" &>/dev/null; then
                print_success "${package_file} is valid JSON"
            else
                print_error "${package_file} contains invalid JSON"
                echo "CRITICAL: Invalid ${package_file} syntax" >> "$dependency_report"
                ((issues++))
                
                # Save error to backlog before returning
                local step_issues="### Dependency Validation - CRITICAL ERROR

**Total Issues:** ${issues}
**Status:** ❌ FAILED

CRITICAL: Invalid ${package_file} syntax. Cannot validate dependencies.
"
                save_step_issues "8" "Dependency_Validation" "$step_issues"
                save_step_summary "8" "Dependency_Validation" "CRITICAL: Invalid ${package_file} syntax." "❌"
                
                cd "$PROJECT_ROOT" || return 1
                update_workflow_status "step8" "❌"
                return 1
            fi
    # Check 2: Run npm audit for security vulnerabilities
    print_info "Running npm audit for security vulnerabilities..."
    local audit_output
    audit_output=$(mktemp)
    TEMP_FILES+=("$audit_output")
    
    local vuln_count=0
    if npm audit --json > "$audit_output" 2>&1; then
        print_success "No security vulnerabilities found"
    else
        local vulnerabilities
        vulnerabilities=$(jq -r '.metadata.vulnerabilities | to_entries[] | "\(.key): \(.value)"' "$audit_output" 2>/dev/null || echo "Unable to parse")
        vuln_count=$(echo "$vulnerabilities" | grep -c ":" || echo "0")
        print_warning "Security vulnerabilities detected"
        echo "Security vulnerabilities:" >> "$dependency_report"
        echo "$vulnerabilities" >> "$dependency_report"
        ((issues++))
    fi
    
    print_info "Checking for outdated packages..."
    local outdated_output
    outdated_output=$(mktemp)
    TEMP_FILES+=("$outdated_output")
    
    local outdated_count=0
    if npm outdated --json > "$outdated_output" 2>&1; then
        print_success "All packages are up to date"
    else
        outdated_count=$(jq 'length' "$outdated_output" 2>/dev/null || echo "0")
        if [[ $outdated_count -gt 0 ]]; then
            print_warning "$outdated_count packages are outdated"
            echo "Outdated packages: $outdated_count" >> "$dependency_report"
            jq -r 'to_entries[] | "\(.key): \(.value.current) -> \(.value.latest)"' "$outdated_output" >> "$dependency_report" 2>/dev/null
        fi
    fi
    
    # Check 4: Verify lockfile integrity
    print_info "Verifying package-lock.json integrity..."
    if [[ -f "package-lock.json" ]]; then
        if npm ls &>/dev/null; then
            print_success "Lockfile integrity verified"
        else
            print_warning "Dependency tree has issues - may need npm install"
            echo "Lockfile issues: Dependency tree inconsistent" >> "$dependency_report"
            ((issues++))
        fi
    else
        print_warning "package-lock.json not found"
        echo "Missing lockfile: Recommended to commit package-lock.json" >> "$dependency_report"
    fi
    
    # Check 5: Verify Node.js and npm versions
    print_info "Checking Node.js and npm versions..."
    local node_version
    local npm_version
    node_version=$(node --version 2>/dev/null || echo "not installed")
    npm_version=$(npm --version 2>/dev/null || echo "not installed")
    
    print_info "Node.js: $node_version, npm: $npm_version"
    echo "Environment: Node.js $node_version, npm $npm_version" >> "$dependency_report"
    
    # Check 6: Analyze dependency count and size
    print_info "Analyzing dependency footprint..."
    local dep_count
    dep_count=$(jq -r '.dependencies // {} | length' package.json 2>/dev/null || echo "0")
    local dev_dep_count
    dev_dep_count=$(jq -r '.devDependencies // {} | length' package.json 2>/dev/null || echo "0")
    local total_deps=$((dep_count + dev_dep_count))
    
    print_info "Dependencies: $dep_count, DevDependencies: $dev_dep_count (Total: $total_deps)"
    echo "Dependency count: $dep_count prod, $dev_dep_count dev, $total_deps total" >> "$dependency_report"
            ;;
            
        python)
            # Python dependency validation
            print_info "Validating Python dependencies..."
            if [[ -f "requirements.txt" ]]; then
                print_success "requirements.txt found"
                local req_count
                req_count=$(grep -v "^#" requirements.txt | grep -v "^$" | wc -l)
                print_info "Requirements: $req_count packages"
                echo "Python requirements: $req_count packages" >> "$dependency_report"
            elif [[ -f "pyproject.toml" ]]; then
                print_success "pyproject.toml found (Poetry)"
                echo "Python project using Poetry" >> "$dependency_report"
            else
                print_warning "No Python dependency file found"
                echo "Warning: No requirements.txt or pyproject.toml" >> "$dependency_report"
            fi
            ;;
            
        go)
            # Go dependency validation
            print_info "Validating Go modules..."
            if [[ -f "go.mod" ]]; then
                print_success "go.mod found"
                if command -v go &> /dev/null; then
                    if go mod verify &> /dev/null; then
                        print_success "Go modules verified"
                    else
                        print_warning "Go module verification failed"
                        echo "Warning: go mod verify failed" >> "$dependency_report"
                        ((issues++))
                    fi
                fi
            else
                print_warning "go.mod not found"
                echo "Warning: No go.mod file" >> "$dependency_report"
            fi
            ;;
            
        java)
            # Java dependency validation
            print_info "Validating Java dependencies..."
            if [[ -f "pom.xml" ]]; then
                print_success "pom.xml found (Maven)"
                echo "Java project using Maven" >> "$dependency_report"
            elif [[ -f "build.gradle" ]]; then
                print_success "build.gradle found (Gradle)"
                echo "Java project using Gradle" >> "$dependency_report"
            else
                print_warning "No Java build file found"
                echo "Warning: No pom.xml or build.gradle" >> "$dependency_report"
            fi
            ;;
            
        ruby)
            # Ruby dependency validation
            print_info "Validating Ruby gems..."
            if [[ -f "Gemfile" ]]; then
                print_success "Gemfile found"
                if [[ -f "Gemfile.lock" ]]; then
                    print_success "Gemfile.lock found"
                else
                    print_warning "Gemfile.lock not found"
                    echo "Warning: Missing Gemfile.lock" >> "$dependency_report"
                fi
            else
                print_warning "Gemfile not found"
                echo "Warning: No Gemfile" >> "$dependency_report"
            fi
            ;;
            
        rust)
            # Rust dependency validation
            print_info "Validating Rust dependencies..."
            if [[ -f "Cargo.toml" ]]; then
                print_success "Cargo.toml found"
                if [[ -f "Cargo.lock" ]]; then
                    print_success "Cargo.lock found"
                else
                    print_warning "Cargo.lock not found"
                    echo "Warning: Missing Cargo.lock" >> "$dependency_report"
                fi
            else
                print_warning "Cargo.toml not found"
                echo "Warning: No Cargo.toml" >> "$dependency_report"
            fi
            ;;
            
        cpp)
            # C++ dependency validation
            print_info "Validating C++ build configuration..."
            if [[ -f "CMakeLists.txt" ]]; then
                print_success "CMakeLists.txt found"
                echo "C++ project using CMake" >> "$dependency_report"
            elif [[ -f "Makefile" ]]; then
                print_success "Makefile found"
                echo "C++ project using Make" >> "$dependency_report"
            else
                print_warning "No C++ build file found"
                echo "Warning: No CMakeLists.txt or Makefile" >> "$dependency_report"
            fi
            ;;
            
        *)
            print_info "No language-specific dependency validation for: $language"
            echo "Language: $language (no specific validation)" >> "$dependency_report"
            ;;
    esac
    
    # PHASE 2: AI-powered dependency strategy analysis
    print_info "Phase 2: Preparing AI-powered dependency analysis..."
    
    # Build dependency summary
    local dependency_summary
    dependency_summary="Dependency Analysis Summary:
- Production Dependencies: $dep_count
- Development Dependencies: $dev_dep_count
- Total Packages: $total_deps
- Node.js Version: $node_version
- npm Version: $npm_version
- Security Issues: $(grep -c "Security" "$dependency_report" 2>/dev/null || echo "0")
- Outdated Packages: $(grep -c "Outdated" "$dependency_report" 2>/dev/null || echo "0")"
    
    # Extract actual dependencies
    local prod_deps
    # Increased from 20 to 50 lines (Dec 15, 2025) for comprehensive dependency analysis
    prod_deps=$(jq -r '.dependencies // {} | to_entries[] | "\(.key)@\(.value)"' package.json 2>/dev/null | head -50)
    local dev_deps
    dev_deps=$(jq -r '.devDependencies // {} | to_entries[] | "\(.key)@\(.value)"' package.json 2>/dev/null)
    
    local dependency_report_content
    dependency_report_content=$(cat "$dependency_report" 2>/dev/null || echo "   No critical issues detected")
    local audit_summary
    audit_summary=$(cat "$audit_output" 2>/dev/null | jq -r '.metadata // "No data"' || echo "Unable to parse audit results")
    local outdated_list
    # Increased from 10 to 20 lines (Dec 15, 2025) for better outdated package visibility
    outdated_list=$(cat "$outdated_output" 2>/dev/null | jq -r 'to_entries[] | "\(.key): \(.value.current) -> \(.value.latest) (wanted: \(.value.wanted))"' | head -20 || echo "None or unable to parse")
    
    # Build comprehensive dependency analysis prompt using AI helper function
    local copilot_prompt
    copilot_prompt=$(build_step8_dependencies_prompt \
        "$node_version" \
        "$npm_version" \
        "$dep_count" \
        "$dev_dep_count" \
        "$total_deps" \
        "$dependency_summary" \
        "$dependency_report_content" \
        "$prod_deps" \
        "$dev_deps" \
        "$audit_summary" \
        "$outdated_list")

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Dependency Analysis Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # PHASE 2: Execute AI analysis with manual issue tracking
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would invoke: copilot -p with dependency analysis prompt"
    else
        if confirm_action "Run GitHub Copilot CLI to analyze dependencies?" "y"; then
            # Save prompt to temporary file for tracking
            local temp_prompt_file
            temp_prompt_file=$(mktemp)
            TEMP_FILES+=("$temp_prompt_file")
            echo "$copilot_prompt" > "$temp_prompt_file"
            
            # Invoke Copilot CLI
            print_info "Starting Copilot CLI session..."
            
            # Create log file with unique timestamp
            local log_timestamp
            log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
            local log_file="${LOGS_RUN_DIR}/step8_copilot_dependency_analysis_${log_timestamp}.log"
            print_info "Logging output to: $log_file"
            
            # Execute Copilot prompt
            execute_copilot_prompt "$copilot_prompt" "$log_file"
            
            print_success "GitHub Copilot CLI session completed"
            print_info "Full session log saved to: $log_file"
            
            # Extract and save issues using library function
            extract_and_save_issues_from_log "8" "Dependency_Validation" "$log_file"
        else
            print_warning "Skipped GitHub Copilot CLI - using manual review"
        fi
    fi
    
    # Handle critical dependency issues
    if [[ $issues -gt 0 ]]; then
        if confirm_action "Critical dependency issues found - continue workflow?"; then
            print_warning "Continuing despite dependency issues"
        else
            print_error "Workflow paused - resolve dependency issues first"
            cd "$PROJECT_ROOT"
            return 1
        fi
    fi
    
    # Save step results using shared library
    save_step_results \
        "8" \
        "Dependency_Validation" \
        "$issues" \
        "Dependency validation passed ($total_deps packages healthy)" \
        "Found ${issues} dependency issues. Review vulnerabilities and outdated packages." \
        "$audit_output" \
        "$total_deps"
    
    cd "$PROJECT_ROOT" || return 1
    update_workflow_status "step8" "✅"
}

# Export step functions
export -f detect_project_tech_stack_step8 step8_validate_dependencies
