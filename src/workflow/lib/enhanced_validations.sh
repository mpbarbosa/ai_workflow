#!/bin/bash
set -euo pipefail

################################################################################
# Enhanced Validation Module
# Version: 1.0.1
# Purpose: Additional validation checks for production workflows
# Part of: Tests & Documentation Workflow Automation v2.7.0
# Created: December 31, 2025
################################################################################

# ==============================================================================
# PRE-COMMIT LINT VALIDATION
# ==============================================================================

# Check if npm run lint is available and execute it
# Returns: 0 if linting passes or not available, 1 if linting fails
validate_pre_commit_lint() {
    local package_json="${PROJECT_ROOT}/package.json"
    
    # Check if package.json exists
    if [[ ! -f "$package_json" ]]; then
        print_info "Skipping pre-commit lint: No package.json found"
        return 0
    fi
    
    # Check if lint script exists
    if ! grep -q '"lint"' "$package_json" 2>/dev/null; then
        print_info "Skipping pre-commit lint: No 'lint' script in package.json"
        return 0
    fi
    
    print_info "Running pre-commit lint (npm run lint)..."
    
    cd "$PROJECT_ROOT"
    
    local lint_output
    local lint_exit_code
    
    if lint_output=$(npm run lint 2>&1); then
        lint_exit_code=0
        print_success "Pre-commit lint passed ✅"
        return 0
    else
        lint_exit_code=$?
        print_warning "Pre-commit lint failed ⚠️"
        echo "Lint output:"
        echo "$lint_output" | tail -20
        
        # Return failure to halt workflow if desired
        return 1
    fi
}

# ==============================================================================
# CHANGELOG VALIDATION
# ==============================================================================

# Verify CHANGELOG.md is updated for version changes
# Returns: 0 if valid or not applicable, 1 if validation fails
validate_changelog() {
    local changelog="${PROJECT_ROOT}/CHANGELOG.md"
    local package_json="${PROJECT_ROOT}/package.json"
    
    # Check if CHANGELOG.md exists
    if [[ ! -f "$changelog" ]]; then
        print_info "Skipping changelog validation: No CHANGELOG.md found"
        return 0
    fi
    
    print_info "Validating CHANGELOG.md..."
    
    # Check if package.json exists and has version changes
    if [[ -f "$package_json" ]]; then
        # Check if package.json is modified
        if git diff --cached --name-only 2>/dev/null | grep -q "package.json"; then
            print_info "package.json is modified - checking for version change..."
            
            # Extract current and staged versions
            local current_version
            local staged_version
            
            current_version=$(git show HEAD:package.json 2>/dev/null | grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4 || echo "unknown")
            staged_version=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$package_json" | cut -d'"' -f4 || echo "unknown")
            
            if [[ "$current_version" != "$staged_version" && "$current_version" != "unknown" ]]; then
                print_info "Version changed: $current_version → $staged_version"
                
                # Check if CHANGELOG.md is also modified
                if git diff --cached --name-only 2>/dev/null | grep -q "CHANGELOG.md"; then
                    # Check if the new version is mentioned in the staged CHANGELOG
                    if grep -q "$staged_version" "$changelog"; then
                        print_success "CHANGELOG.md contains new version $staged_version ✅"
                        return 0
                    else
                        print_warning "CHANGELOG.md does not mention new version $staged_version ⚠️"
                        print_info "Please update CHANGELOG.md with version $staged_version"
                        return 1
                    fi
                else
                    print_warning "Version changed but CHANGELOG.md not updated ⚠️"
                    print_info "Please stage CHANGELOG.md with version $staged_version"
                    return 1
                fi
            fi
        fi
    fi
    
    print_success "Changelog validation passed ✅"
    return 0
}

# ==============================================================================
# CDN READINESS CHECK
# ==============================================================================

# Validate cdn-urls.txt matches package.json version
# Returns: 0 if valid or not applicable, 1 if validation fails
validate_cdn_readiness() {
    local cdn_urls="${PROJECT_ROOT}/cdn-urls.txt"
    local package_json="${PROJECT_ROOT}/package.json"
    
    # Check if cdn-urls.txt exists
    if [[ ! -f "$cdn_urls" ]]; then
        print_info "Skipping CDN readiness: No cdn-urls.txt found"
        return 0
    fi
    
    # Check if package.json exists
    if [[ ! -f "$package_json" ]]; then
        print_info "Skipping CDN readiness: No package.json found"
        return 0
    fi
    
    print_info "Validating CDN readiness (version consistency)..."
    
    # Extract version from package.json
    local package_version
    package_version=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$package_json" | cut -d'"' -f4)
    
    if [[ -z "$package_version" ]]; then
        print_warning "Could not extract version from package.json"
        return 1
    fi
    
    print_info "Package version: $package_version"
    
    # Check if cdn-urls.txt contains the current version
    if grep -q "$package_version" "$cdn_urls"; then
        print_success "CDN URLs contain version $package_version ✅"
        
        # Additional check: Count how many URLs contain the version
        local version_count
        version_count=$(grep -c "$package_version" "$cdn_urls" || echo "0")
        print_info "Found $version_count CDN URL(s) with version $package_version"
        
        return 0
    else
        print_warning "CDN URLs do not contain version $package_version ⚠️"
        print_info "Please update cdn-urls.txt with the current package version"
        
        # Show what versions are in cdn-urls.txt
        echo ""
        echo "Current cdn-urls.txt content:"
        head -5 "$cdn_urls"
        
        return 1
    fi
}

# ==============================================================================
# METRICS HEALTH CHECK
# ==============================================================================

# Ensure history.jsonl receives data from workflow execution
# Returns: 0 if valid, 1 if validation fails
# Mitigation Strategy: Validates history.jsonl has content (test -s)
validate_metrics_health() {
    local metrics_dir="${METRICS_DIR:-${PROJECT_ROOT}/.ai_workflow/metrics}"
    local history_file="${metrics_dir}/history.jsonl"
    local current_file="${metrics_dir}/current_run.json"
    
    print_info "Validating metrics health..."
    
    # Check 1: Metrics directory exists
    if [[ ! -d "$metrics_dir" ]]; then
        print_warning "Metrics directory not found: $metrics_dir"
        print_info "Metrics collection may not be initialized"
        return 1
    fi
    
    print_success "Metrics directory exists: $metrics_dir"
    
    # Check 2: current_run.json exists and has content
    if [[ ! -f "$current_file" ]]; then
        print_warning "Current run metrics file not found: $current_file"
        return 1
    fi
    
    if [[ ! -s "$current_file" ]]; then
        print_warning "Current run metrics file is empty: $current_file"
        return 1
    fi
    
    # Validate JSON structure
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$current_file" 2>/dev/null; then
            print_success "Current run metrics file is valid JSON ✅"
            
            # Extract key metrics
            local workflow_id
            local step_count
            workflow_id=$(jq -r '.workflow_run_id // "unknown"' "$current_file" 2>/dev/null)
            step_count=$(jq '.steps | length // 0' "$current_file" 2>/dev/null)
            
            print_info "Workflow ID: $workflow_id"
            print_info "Steps recorded: $step_count"
        else
            print_warning "Current run metrics file is not valid JSON"
            return 1
        fi
    else
        print_info "jq not available - skipping JSON validation"
    fi
    
    # Check 3: history.jsonl exists
    if [[ ! -f "$history_file" ]]; then
        print_warning "History file not found: $history_file"
        print_info "This is normal for first workflow run"
        return 0  # Don't fail on first run
    fi
    
    # Check 4: history.jsonl has content (MITIGATION STRATEGY)
    # Implements: test -s history.jsonl || exit 1
    if [[ ! -s "$history_file" ]]; then
        print_warning "History file is empty: $history_file"
        print_info "Metrics may not be finalized yet"
        print_info "Run 'finalize_metrics' to populate history"
        return 1
    fi
    
    # Count entries in history
    local entry_count
    entry_count=$(wc -l < "$history_file" 2>/dev/null || echo "0")
    print_success "History file contains $entry_count workflow run(s) ✅"
    
    # Additional validation: Verify file is not corrupted
    if [[ $entry_count -eq 0 ]]; then
        print_error "History file exists but has no entries (possible corruption)"
        return 1
    fi
    
    # Validate recent entry if jq available
    if command -v jq >/dev/null 2>&1 && [[ $entry_count -gt 0 ]]; then
        local last_entry
        last_entry=$(tail -1 "$history_file")
        
        if echo "$last_entry" | jq empty 2>/dev/null; then
            local last_run_id
            local last_status
            last_run_id=$(echo "$last_entry" | jq -r '.workflow_run_id // "unknown"')
            last_status=$(echo "$last_entry" | jq -r '.status // "unknown"')
            
            print_info "Last run: $last_run_id (status: $last_status)"
        else
            print_warning "Last entry in history is not valid JSON"
            return 1
        fi
    fi
    
    print_success "Metrics health check passed ✅"
    return 0
}

# ==============================================================================
# COMBINED VALIDATION RUNNER
# ==============================================================================

# Run all enhanced validations
# Usage: run_enhanced_validations [--strict]
# Returns: 0 if all pass or non-strict, 1 if any fail in strict mode
run_enhanced_validations() {
    local strict_mode=false
    
    if [[ "${1:-}" == "--strict" ]]; then
        strict_mode=true
    fi
    
    print_header "Enhanced Validation Checks"
    echo ""
    
    local validation_results=()
    local all_passed=true
    
    # Validation 1: Pre-commit Lint
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. Pre-Commit Lint Validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if validate_pre_commit_lint; then
        validation_results+=("pre_commit_lint:PASS")
    else
        validation_results+=("pre_commit_lint:FAIL")
        all_passed=false
    fi
    echo ""
    
    # Validation 2: Changelog
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "2. Changelog Validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if validate_changelog; then
        validation_results+=("changelog:PASS")
    else
        validation_results+=("changelog:FAIL")
        all_passed=false
    fi
    echo ""
    
    # Validation 3: CDN Readiness
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "3. CDN Readiness Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if validate_cdn_readiness; then
        validation_results+=("cdn_readiness:PASS")
    else
        validation_results+=("cdn_readiness:FAIL")
        all_passed=false
    fi
    echo ""
    
    # Validation 4: Metrics Health
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "4. Metrics Health Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if validate_metrics_health; then
        validation_results+=("metrics_health:PASS")
    else
        validation_results+=("metrics_health:FAIL")
        all_passed=false
    fi
    echo ""
    
    # Summary
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Validation Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    for result in "${validation_results[@]}"; do
        local check_name="${result%%:*}"
        local check_status="${result##*:}"
        
        if [[ "$check_status" == "PASS" ]]; then
            echo "✅ $check_name"
        else
            echo "❌ $check_name"
        fi
    done
    
    echo ""
    
    if [[ "$all_passed" == true ]]; then
        print_success "All enhanced validations passed ✅"
        return 0
    else
        if [[ "$strict_mode" == true ]]; then
            print_error "Some validations failed (strict mode)"
            return 1
        else
            print_warning "Some validations failed (non-strict mode - continuing)"
            return 0
        fi
    fi
}

# ==============================================================================
# EXPORT FUNCTIONS
# ==============================================================================

export -f validate_pre_commit_lint
export -f validate_changelog
export -f validate_cdn_readiness
export -f validate_metrics_health
export -f run_enhanced_validations
