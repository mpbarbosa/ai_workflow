# 📋 Tests & Documentation Update Automation Script - Comprehensive Development Plan

**Document Version**: 1.0.0
**Date Created**: 2025-11-06
**Related Workflow**: `/prompts/tests_documentation_update_enhanced.txt`
**Target Script**: `/shell_scripts/workflow/execute_tests_docs_workflow.sh`

---

## 📋 **COMPREHENSIVE PLAN: Tests & Documentation Update Automation Script**

### **Script Name**: `execute_tests_docs_workflow.sh`

### **🎯 Design Philosophy**
- **Modular Architecture**: Function-based design matching existing scripts (`sync_to_public.sh` pattern)
- **Fail-Safe First**: Every step has validation with automatic rollback capability
- **User Interaction**: Interactive mode with confirmations and dry-run support
- **Comprehensive Logging**: Color-coded output with detailed progress tracking
- **Error Recovery**: Graceful failure handling with clear recovery instructions

---

## **📐 ARCHITECTURE OVERVIEW**

### **Phase 1: Script Foundation** (Days 1-2)
**Core Infrastructure Development**

#### 1.1 **Configuration & Constants**
```bash
#!/bin/bash
# Script metadata
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Tests & Documentation Workflow Automation"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Color codes (matching existing scripts)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Workflow tracking
declare -A WORKFLOW_STATUS
TOTAL_STEPS=13  # Including substeps
```

#### 1.2 **Utility Functions** (Reuse patterns from `sync_to_public.sh`)
- `print_header()` - Styled section headers
- `print_success()` - Success messages with ✅
- `print_error()` - Error messages with ❌
- `print_warning()` - Warning messages with ⚠️
- `print_info()` - Information messages with ℹ️
- `confirm_action()` - User confirmation prompts
- `update_workflow_status()` - Track completion state
- `validate_dependencies()` - Check npm, git, jest availability

#### 1.3 **Pre-Flight Checks**
```bash
check_prerequisites() {
    # Verify we're in correct directory
    # Validate Node.js/npm installed
    # Confirm git repository is clean (warn if dirty)
    # Check src/package.json exists
    # Verify shell_scripts directory structure
}
```

---

### **Phase 2: Core Workflow Functions** (Days 3-5)

#### 2.1 **Step 0: Pre-Analysis Phase**
```bash
step0_analyze_changes() {
    print_header "Step 0: Analyzing Recent Changes"

    # Execute git commands
    local commits_ahead=$(git rev-list --count @{u}.. 2>/dev/null || echo "0")
    local modified_files=$(git status --porcelain | wc -l)

    # Display git log
    git log --oneline -10
    git status

    # Store analysis results
    ANALYSIS_COMMITS=$commits_ahead
    ANALYSIS_MODIFIED=$modified_files

    # Interactive scope definition
    read -p "Enter scope of changes (e.g., 'shell_scripts', 'documentation', 'tests'): " CHANGE_SCOPE

    update_workflow_status "step0" "✅"
}
```

#### 2.2 **Steps 1-4: Documentation Updates Phase**
```bash
step1_update_documentation() {
    print_header "Step 1: Update Related Documentation"

    # Identify affected docs based on git diff
    local changed_files=$(git diff --name-only HEAD~1 2>/dev/null)

    # Map files to documentation
    # - shell_scripts/*.sh → /docs/SHELL_SCRIPTS_README.md
    # - src/scripts/*.js → README.md + /docs/

    # Interactive review
    echo "Changed files detected:"
    echo "$changed_files"

    if confirm_action "Open documentation files for editing?"; then
        # Launch editor with relevant docs
        ${EDITOR:-nano} docs/README.md  # Example
    fi

    update_workflow_status "step1" "✅"
}

step2_check_consistency() {
    # Automated checks:
    # - Cross-reference validation (grep for broken links)
    # - Terminology consistency (shared glossary check)
    # Manual review prompt with specific checklist
}

step3_validate_script_references() {
    # Parse all .md files
    # Extract file paths and script references
    # Verify each exists in filesystem
    # Report broken references
}

step4_validate_directory_structure() {
    # Compare README.md structure section with `tree` output
    # Flag discrepancies
    # Suggest updates
}
```

#### 2.3 **Steps 5-7: Test Management Phase**
```bash
step5_review_existing_tests() {
    print_header "Step 5: Review Existing Jest Tests"

    cd "$PROJECT_ROOT/src" || exit 1

    # List all test files
    find __tests__ -name "*.test.js" -type f

    # Run tests individually to identify failures
    npm test -- --listTests

    # Run all tests
    if ! npm test; then
        print_error "Existing tests failing - review needed"
        return 1
    fi

    update_workflow_status "step5" "✅"
}

step6_generate_new_tests() {
    # Check if new functionality added (git diff analysis)
    # Prompt for test creation
    # Provide template for new tests
    # Validate ES module patterns
}

step7_execute_test_suite() {
    print_header "Step 7: Execute Full Test Suite"

    cd "$PROJECT_ROOT/src" || exit 1

    # Run with coverage
    if npm run test:coverage; then
        print_success "All tests passed ✅"
        update_workflow_status "step7" "✅"
    else
        print_error "Test suite failed ❌"
        exit 1
    fi
}
```

#### 2.4 **Steps 8-9: Dependency & Code Quality**
```bash
step8_validate_dependencies() {
    # Compare package.json with documented dependencies
    # Check for outdated packages (npm outdated)
    # Validate README.md lists all required tools
}

step9_code_quality_validation() {
    print_header "Step 9: Code Quality Validation"

    # Shell script syntax check
    cd "$PROJECT_ROOT/shell_scripts" || exit 1
    find . -name "*.sh" -exec bash -n {} \; || {
        print_error "Shell script syntax errors detected"
        return 1
    }

    # JavaScript validation via Jest (already done in step7)

    # Optional: Run prettier/eslint if configured

    update_workflow_status "step9" "✅"
}
```

#### 2.5 **Steps 10-11: Finalization**
```bash
step10_context_analysis() {
    # Interactive review of workflow discoveries
    # Prompt to update .github/copilot-instructions.md
    # Generate summary report
}

step11_git_finalization() {
    print_header "Step 11: Git Operations (CRITICAL)"

    # 11a: Commit
    git add .
    read -p "Enter commit message (conventional format): " commit_msg
    git commit -m "$commit_msg"

    # 11b: CRITICAL PUSH
    print_warning "🔴 CRITICAL: Pushing to origin..."
    if git push origin main; then
        print_success "Successfully pushed to origin ✅"
        update_workflow_status "step11b" "✅"
    else
        print_error "PUSH FAILED - workflow incomplete ❌"
        exit 1
    fi

    # 11c: Permissions
    cd "$PROJECT_ROOT/shell_scripts" || exit 1
    find . -name "*.sh" -exec chmod +x {} \;

    update_workflow_status "step11" "✅"
}
```

---

### **Phase 3: User Interface & Controls** (Days 6-7)

#### 3.1 **Command-Line Arguments**
```bash
# Supported flags:
--dry-run          # Preview actions without execution
--interactive      # Prompt for confirmation at each step
--auto             # Automatic mode (no prompts, fails on error)
--skip-tests       # Skip test execution (use with caution)
--skip-docs        # Skip documentation updates
--steps "1,2,5"    # Run specific steps only
--verbose          # Detailed logging
--help             # Display usage information
```

#### 3.2 **Interactive Checklist Display**
```bash
display_workflow_checklist() {
    clear
    echo "========================================="
    echo "  WORKFLOW PROGRESS TRACKER"
    echo "========================================="
    for step in "${!WORKFLOW_STATUS[@]}"; do
        echo "  $step: ${WORKFLOW_STATUS[$step]}"
    done
    echo "========================================="
}
```

#### 3.3 **Progress Persistence**
```bash
# Save progress to .workflow_state.json
save_workflow_state() {
    local state_file="$PROJECT_ROOT/.workflow_state.json"
    # Save WORKFLOW_STATUS array
    # Save ANALYSIS_COMMITS, CHANGE_SCOPE
    # Timestamp
}

# Resume from saved state
resume_workflow() {
    # Load .workflow_state.json
    # Skip completed steps
    # Continue from last incomplete step
}
```

---

### **Phase 4: Validation & Safety** (Days 8-9)

#### 4.1 **Final Validation Suite**
```bash
final_validation_check() {
    print_header "🚨 CRITICAL SUCCESS VALIDATION"

    # Git status check
    if git status | grep -q "up to date with 'origin/main'"; then
        print_success "✅ Repository synced with origin"
    else
        print_error "❌ NOT up to date with origin"
        return 1
    fi

    # Working tree clean
    if git status | grep -q "working tree clean"; then
        print_success "✅ Working tree clean"
    else
        print_warning "⚠️ Uncommitted changes remain"
    fi

    # Tests still pass
    cd "$PROJECT_ROOT/src" && npm test --silent || {
        print_error "❌ Tests failing after workflow"
        return 1
    }

    # Shell script permissions
    local non_exec=$(find "$PROJECT_ROOT/shell_scripts" -name "*.sh" -not -executable)
    if [[ -z "$non_exec" ]]; then
        print_success "✅ All scripts executable"
    else
        print_error "❌ Non-executable scripts found:"
        echo "$non_exec"
        return 1
    fi

    print_success "🎉 WORKFLOW SUCCESSFULLY COMPLETED!"
}
```

#### 4.2 **Rollback Mechanisms**
```bash
create_backup() {
    # Create git stash before starting
    git stash push -m "workflow_backup_$(date +%s)"
}

rollback_changes() {
    print_warning "Rolling back changes..."
    git stash pop
    print_info "Restored previous state"
}
```

---

### **Phase 5: Documentation & Testing** (Days 10-11)

#### 5.1 **Script Self-Documentation**
```bash
show_help() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION

USAGE:
    ./execute_tests_docs_workflow.sh [OPTIONS]

OPTIONS:
    --dry-run         Preview actions without making changes
    --interactive     Prompt for confirmation at each step (default)
    --auto            Automatic mode with no user prompts
    --steps NUMS      Run specific steps (e.g., "1,2,5" or "1-4")
    --skip-tests      Skip test execution phase
    --skip-docs       Skip documentation update phase
    --resume          Resume from saved workflow state
    --verbose         Enable detailed logging
    --help            Display this help message

EXAMPLES:
    # Run full workflow interactively
    ./execute_tests_docs_workflow.sh --interactive

    # Dry-run to preview actions
    ./execute_tests_docs_workflow.sh --dry-run

    # Run only documentation steps
    ./execute_tests_docs_workflow.sh --steps 1-4

    # Automatic mode (CI/CD compatible)
    ./execute_tests_docs_workflow.sh --auto

For detailed workflow documentation, see:
    /prompts/tests_documentation_update_enhanced.txt
EOF
}
```

#### 5.2 **Script Testing**
- Test in dry-run mode extensively
- Test each step independently
- Test with failing tests scenario
- Test with dirty git tree
- Test rollback mechanism
- Test resume functionality

---

## **🔧 IMPLEMENTATION ROADMAP**

### **Week 1: Core Development**
- **Days 1-2**: Foundation & utilities
  - Set up script structure with constants and color codes
  - Implement utility functions (print_*, confirm_action, etc.)
  - Create prerequisite checks

- **Days 3-5**: Implement all 11 workflow steps
  - Step 0: Git analysis and scope definition
  - Steps 1-4: Documentation update automation
  - Steps 5-7: Test management and execution
  - Steps 8-9: Dependency and code quality validation
  - Steps 10-11: Context analysis and git finalization

- **Days 6-7**: CLI interface & user controls
  - Argument parsing for all flags
  - Interactive checklist display
  - Progress persistence system

### **Week 2: Refinement**
- **Days 8-9**: Validation, safety, error handling
  - Final validation suite implementation
  - Rollback mechanism
  - Comprehensive error handling and recovery

- **Days 10-11**: Documentation, testing, polish
  - Self-documentation (--help)
  - Testing all modes and scenarios
  - Code cleanup and optimization

### **Week 3: Integration**
- Test with real workflow scenarios
- Integrate with existing scripts
- Update `/shell_scripts/README.md`
- Update `.github/copilot-instructions.md`
- Final acceptance testing

---

## **🎯 SUCCESS CRITERIA**

✅ **Script executes all 13 workflow steps**
✅ **Dry-run mode works flawlessly**
✅ **Interactive mode provides clear guidance**
✅ **Auto mode suitable for CI/CD**
✅ **Rollback mechanism functional**
✅ **Final validation catches all failure scenarios**
✅ **Comprehensive error messages**
✅ **Self-documenting with --help**
✅ **Follows existing script patterns**
✅ **Executable permissions set automatically**

---

## **📊 WORKFLOW STEP MAPPING**

This script automates the following workflow steps from `/prompts/tests_documentation_update_enhanced.txt`:

| **Step** | **Phase** | **Function Name** | **Automation Level** |
|----------|-----------|-------------------|----------------------|
| Step 0 | Pre-Analysis | `step0_analyze_changes()` | Fully Automated |
| Step 1 | Documentation | `step1_update_documentation()` | Semi-Automated (Editor) |
| Step 2 | Documentation | `step2_check_consistency()` | Fully Automated |
| Step 3 | Documentation | `step3_validate_script_references()` | Fully Automated |
| Step 4 | Documentation | `step4_validate_directory_structure()` | Fully Automated |
| Step 5 | Testing | `step5_review_existing_tests()` | Fully Automated |
| Step 6 | Testing | `step6_generate_new_tests()` | Semi-Automated (Template) |
| Step 7 | Testing | `step7_execute_test_suite()` | Fully Automated |
| Step 8 | Dependencies | `step8_validate_dependencies()` | Fully Automated |
| Step 9 | Code Quality | `step9_code_quality_validation()` | Fully Automated |
| Step 10 | Context | `step10_context_analysis()` | Semi-Automated (Review) |
| Step 11a | Git | `step11_git_finalization()` (commit) | Interactive |
| Step 11b | Git | `step11_git_finalization()` (push) | Fully Automated |
| Step 11c | Git | `step11_git_finalization()` (permissions) | Fully Automated |

**Automation Levels**:
- **Fully Automated**: Executes without user input
- **Semi-Automated**: Provides tools/templates, requires user action
- **Interactive**: Requires user input/confirmation

---

## **🔐 SAFETY FEATURES**

### **Pre-Execution Safety**
1. **Git Status Check**: Warns if working tree is dirty
2. **Dependency Validation**: Confirms all required tools available
3. **Dry-Run Mode**: Preview all actions before execution
4. **Backup Creation**: Automatic git stash before starting

### **During Execution Safety**
1. **Step-by-Step Validation**: Each step validates before proceeding
2. **Error Detection**: Immediate halt on critical failures
3. **Progress Tracking**: Persistent state allows resume
4. **Interactive Confirmations**: User approval for destructive operations

### **Post-Execution Safety**
1. **Final Validation Suite**: Comprehensive checks before completion
2. **Rollback Capability**: Restore from backup if issues detected
3. **Clear Status Reporting**: Detailed success/failure indicators

---

## **🛠️ TECHNICAL CONSIDERATIONS**

### **Dependencies**
- **Required**: bash 4.0+, git, Node.js/npm, Jest
- **Optional**: tree (for directory structure validation)

### **Environment**
- **Working Directory**: Must be run from project root
- **Git Repository**: Must be a valid git repository
- **Network**: Required for git push operations

### **Compatibility**
- **OS**: Linux (primary), macOS (compatible)
- **Shell**: bash (dash/sh may have limited support)
- **Terminal**: Color support recommended but not required

### **Performance**
- **Estimated Runtime**: 2-5 minutes (depending on test suite size)
- **Dry-Run**: <30 seconds
- **Interactive Mode**: Variable (depends on user review time)

---

## **📝 NEXT STEPS**

1. **Review this plan** - Confirm approach aligns with project needs
2. **Begin Phase 1** - Create script skeleton with utilities
3. **Iterative development** - Build and test each phase
4. **Documentation** - Update shell_scripts/README.md with new script
5. **Integration testing** - Run against actual workflow scenarios

**Estimated Completion**: 2-3 weeks with proper testing and refinement

---

## **📚 REFERENCES**

- **Workflow Specification**: `/prompts/tests_documentation_update_enhanced.txt`
- **Existing Scripts Pattern**: `/shell_scripts/sync_to_public.sh`
- **Project Documentation**: `/README.md` and `/docs/`
- **Copilot Instructions**: `/.github/copilot-instructions.md`

---

## **📋 CHANGE LOG**

| **Version** | **Date** | **Changes** | **Author** |
|-------------|----------|-------------|------------|
| 1.0.0 | 2025-11-06 | Initial plan creation | MP Barbosa |

---

**Document Status**: ✅ Ready for Implementation
**Next Action**: Begin Phase 1 development or request approval to proceed
