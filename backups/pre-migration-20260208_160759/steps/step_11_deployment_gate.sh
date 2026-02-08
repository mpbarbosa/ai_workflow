#!/bin/bash
set -euo pipefail

################################################################################
# Step 11: Deployment Readiness Gate
# Purpose: Validate deployment prerequisites before workflow completion
# Part of: Tests & Documentation Workflow Automation v3.3.0
# Version: 1.0.0
#
# Features:
#   - Mandatory checks: Tests passing, CHANGELOG.md updated
#   - Optional checks: Version bump, branch sync (warn only)
#   - Conditional execution: Only with --validate-release flag
#   - Strict mode: Blocks workflow on failure
#
# Integration: Runs between Step 10 and Step 11.5
################################################################################

# Module version information
readonly STEP11_VERSION="1.0.0"
readonly STEP11_VERSION_MAJOR=1
readonly STEP11_VERSION_MINOR=0
readonly STEP11_VERSION_PATCH=0

# Get workflow home directory
WORKFLOW_HOME="${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Source required library modules
source_step11_libraries() {
    local lib_dir="${WORKFLOW_HOME}/src/workflow/steps/step_11_lib"
    
    # Source validation modules
    if [[ -f "${lib_dir}/test_validation.sh" ]]; then
        source "${lib_dir}/test_validation.sh"
    else
        print_error "Missing required module: test_validation.sh"
        return 1
    fi
    
    if [[ -f "${lib_dir}/changelog_validation.sh" ]]; then
        source "${lib_dir}/changelog_validation.sh"
    else
        print_error "Missing required module: changelog_validation.sh"
        return 1
    fi
    
    if [[ -f "${lib_dir}/version_validation.sh" ]]; then
        source "${lib_dir}/version_validation.sh"
    else
        print_warning "Optional module not found: version_validation.sh"
    fi
    
    if [[ -f "${lib_dir}/branch_sync_validation.sh" ]]; then
        source "${lib_dir}/branch_sync_validation.sh"
    else
        print_warning "Optional module not found: branch_sync_validation.sh"
    fi
    
    return 0
}

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Configuration defaults
: "${VALIDATE_RELEASE:=false}"              # Enable deployment gate (set by flag)
: "${DEPLOYMENT_GATE_STRICT:=true}"         # Always block on failure
: "${CHECK_VERSION_BUMP:=true}"             # Enable version bump check
: "${CHECK_BRANCH_SYNC:=true}"              # Enable branch sync check

# ==============================================================================
# MAIN STEP FUNCTION
# ==============================================================================

# Main deployment readiness gate function
# Returns: 0 if all mandatory checks pass, 1 if any mandatory check fails
step11_deployment_gate() {
    print_step "11" "Deployment Readiness Gate"
    
    # Check if flag is set
    if [[ "${VALIDATE_RELEASE:-false}" != "true" ]]; then
        print_info "Skipping deployment gate (use --validate-release or --deployment-check to enable)"
        return 0
    fi
    
    cd "$PROJECT_ROOT" || return 1
    
    # Source library modules
    if ! source_step11_libraries; then
        print_error "Failed to load required modules"
        return 1
    fi
    
    local gate_report="${BACKLOG_DIR}/deployment_gate_report.md"
    local mandatory_passed=true
    local optional_warnings=0
    
    print_info "Running deployment readiness checks..."
    echo ""
    
    # ==============================================================================
    # MANDATORY CHECKS (block on failure)
    # ==============================================================================
    
    print_info "=== Mandatory Checks ==="
    
    # Check 1: Test execution status
    print_info "Checking test execution status..."
    if check_test_status; then
        print_success "  ✅ All tests passing"
    else
        print_error "  ❌ Tests are failing or did not complete"
        mandatory_passed=false
    fi
    echo ""
    
    # Check 2: CHANGELOG.md updated
    print_info "Checking CHANGELOG.md updates..."
    if check_changelog_updated; then
        print_success "  ✅ CHANGELOG.md updated"
    else
        print_error "  ❌ CHANGELOG.md not updated"
        mandatory_passed=false
    fi
    echo ""
    
    # ==============================================================================
    # OPTIONAL CHECKS (warn only)
    # ==============================================================================
    
    print_info "=== Optional Checks ==="
    
    # Check 3: Version bump (optional)
    if [[ "${CHECK_VERSION_BUMP}" == "true" ]]; then
        print_info "Checking version bump..."
        if check_version_bump; then
            print_success "  ✅ Version bump detected"
        else
            print_warning "  ⚠️  Version bump recommended before release"
            ((optional_warnings++))
        fi
        echo ""
    fi
    
    # Check 4: Branch sync (optional)
    if [[ "${CHECK_BRANCH_SYNC}" == "true" ]]; then
        print_info "Checking branch sync with origin..."
        if check_branch_sync; then
            print_success "  ✅ Branch up-to-date with origin"
        else
            print_warning "  ⚠️  Branch may be out of sync with origin"
            ((optional_warnings++))
        fi
        echo ""
    fi
    
    # ==============================================================================
    # GENERATE REPORT
    # ==============================================================================
    
    print_info "Generating deployment readiness report..."
    
    # Ensure directory exists
    mkdir -p "$(dirname "$gate_report")"
    
    cat > "$gate_report" << EOF
# Deployment Readiness Gate Report

**Generated**: $(date '+%Y-%m-%d %H:%M:%S')  
**Project**: ${PROJECT_ROOT}  
**Branch**: $(git branch --show-current 2>/dev/null || echo "unknown")

---

## Mandatory Checks

### 1. Test Execution Status
$(check_test_status &>/dev/null && echo "✅ **PASS** - All tests passing" || echo "❌ **FAIL** - Tests failing or incomplete")

### 2. CHANGELOG.md Updates
$(check_changelog_updated &>/dev/null && echo "✅ **PASS** - CHANGELOG.md updated" || echo "❌ **FAIL** - CHANGELOG.md not updated")

---

## Optional Checks

### 3. Version Bump
$(check_version_bump &>/dev/null && echo "✅ **PASS** - Version bump detected" || echo "⚠️ **WARN** - No version bump detected")

### 4. Branch Sync
$(check_branch_sync &>/dev/null && echo "✅ **PASS** - Branch up-to-date" || echo "⚠️ **WARN** - Branch may be out of sync")

---

## Summary

- **Mandatory Checks**: $([ "$mandatory_passed" == "true" ] && echo "✅ PASSED" || echo "❌ FAILED")
- **Optional Warnings**: ${optional_warnings}
- **Overall Status**: $([ "$mandatory_passed" == "true" ] && echo "✅ **READY FOR DEPLOYMENT**" || echo "❌ **NOT READY FOR DEPLOYMENT**")

---

## Recommendations

$(if [ "$mandatory_passed" == "false" ]; then
    echo "**Action Required**:"
    echo "1. Fix failing tests before deployment"
    echo "2. Update CHANGELOG.md with recent changes"
    echo ""
fi)

$(if [ $optional_warnings -gt 0 ]; then
    echo "**Recommended Actions**:"
    [ "${CHECK_VERSION_BUMP}" == "true" ] && ! check_version_bump &>/dev/null && echo "- Bump version number before release"
    [ "${CHECK_BRANCH_SYNC}" == "true" ] && ! check_branch_sync &>/dev/null && echo "- Sync branch with origin (pull/push)"
    echo ""
fi)

$(if [ "$mandatory_passed" == "true" ] && [ $optional_warnings -eq 0 ]; then
    echo "**All checks passed!** Your project is ready for deployment. 🚀"
fi)

EOF
    
    print_success "Report generated: $gate_report"
    echo ""
    
    # ==============================================================================
    # FINAL RESULT
    # ==============================================================================
    
    if [[ "$mandatory_passed" == "true" ]]; then
        print_success "========================================"
        print_success "✅ Deployment Readiness Gate: PASSED"
        print_success "========================================"
        
        if [[ $optional_warnings -gt 0 ]]; then
            print_warning "⚠️  ${optional_warnings} optional warning(s) - review recommended"
        fi
        
        return 0
    else
        print_error "========================================"
        print_error "❌ Deployment Readiness Gate: FAILED"
        print_error "========================================"
        print_error ""
        print_error "Workflow blocked due to failed mandatory checks."
        print_error "Review the report for details: $gate_report"
        print_error ""
        
        return 1
    fi
}

# Alias for backward compatibility
step10_5_deployment_gate() {
    step11_deployment_gate "$@"
}

# Export step function
export -f step11_deployment_gate step10_5_deployment_gate
