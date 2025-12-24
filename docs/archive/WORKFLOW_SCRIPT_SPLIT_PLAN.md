# Execute Tests & Docs Workflow Script Split Plan

**Date:** 2025-11-12
**Script:** `src/workflow/execute_tests_docs_workflow.sh`
**Current Size:** 4,337 lines
**Target:** Modular architecture with < 500 lines per file

---

## Executive Summary

The `execute_tests_docs_workflow.sh` script has grown to 4,337 lines and needs to be split into a maintainable modular architecture. This plan outlines the strategy to extract functionality into separate modules while maintaining backward compatibility and all existing features.

---

## Current Architecture Analysis

### Script Structure (Line Ranges)
1. **Configuration & Constants** (1-110): Version info, paths, colors, workflow tracking
2. **Git State Caching** (112-182): v1.5.0 performance optimization
3. **Utility Functions** (184-450): Print functions, validation, error handling
4. **Pre-Flight Checks** (452-650): Prerequisites, dependencies, git validation
5. **Git Analysis** (652-850): Change analysis, commit inspection, scope determination
6. **Backlog & Summary Management** (852-1050): Issue tracking, report generation
7. **Step 1: Documentation Updates** (1052-1350): AI-enhanced doc updates
8. **Step 2: Consistency Analysis** (1352-1650): Cross-reference validation
9. **Step 3: Script Reference Validation** (1652-1950): Shell script docs
10. **Step 4: Directory Structure** (1952-2250): Structure validation
11. **Step 5: Test Review** (2252-2550): Test suite analysis
12. **Step 6: Test Generation** (2552-2850): New test creation
13. **Step 7: Test Execution** (2852-3150): Run test suite
14. **Step 8: Dependency Validation** (3152-3450): Package checks
15. **Step 9: Code Quality** (3452-3750): Quality validation
16. **Step 10: Context Analysis** (3752-4050): Final review
17. **Step 11: Git Finalization** (4052-4350): Commit & push

### Dependencies
- Git state caching system (v1.5.0)
- Backlog tracking system (v1.3.0)
- Summary generation (v1.4.0)
- AI-enhanced validation (v1.2.0)

---

## Proposed Modular Architecture

### Directory Structure
```
src/workflow/
├── execute_tests_docs_workflow.sh       # Main orchestrator (< 300 lines)
├── lib/
│   ├── config.sh                        # Configuration & constants
│   ├── colors.sh                        # Color definitions
│   ├── utils.sh                         # Common utility functions
│   ├── git_cache.sh                     # Git state caching (v1.5.0)
│   ├── validation.sh                    # Pre-flight checks
│   ├── backlog.sh                       # Backlog & issue tracking
│   ├── summary.sh                       # Summary generation
│   └── ai_helpers.sh                    # AI prompt templates & helpers
├── steps/
│   ├── step_01_documentation.sh         # Documentation updates
│   ├── step_02_consistency.sh           # Consistency analysis
│   ├── step_03_script_refs.sh           # Script reference validation
│   ├── step_04_directory.sh             # Directory structure
│   ├── step_05_test_review.sh           # Test review
│   ├── step_06_test_gen.sh              # Test generation
│   ├── step_07_test_exec.sh             # Test execution
│   ├── step_08_dependencies.sh          # Dependency validation
│   ├── step_09_quality.sh               # Code quality
│   ├── step_10_context.sh               # Context analysis
│   └── step_11_git_final.sh             # Git finalization
└── README.md                             # Module documentation
```

### Module Breakdown

#### 1. **lib/config.sh** (~80 lines)
**Purpose:** Central configuration and constants
**Content:**
- Script version and metadata
- Directory paths (PROJECT_ROOT, SRC_DIR, BACKLOG_DIR, etc.)
- Workflow tracking variables
- Temp file tracking array

#### 2. **lib/colors.sh** (~30 lines)
**Purpose:** Color code definitions
**Content:**
- ANSI color codes (RED, GREEN, YELLOW, BLUE, CYAN, MAGENTA, NC)
- Consistent color palette for all modules

#### 3. **lib/utils.sh** (~200 lines)
**Purpose:** Common utility functions
**Content:**
- `print_*` functions (info, success, warning, error, header, section)
- `confirm_step()` for user interaction
- `cleanup()` for temp file management
- `trigger_ai_step()` for Copilot CLI integration
- Step status tracking helpers

#### 4. **lib/git_cache.sh** (~150 lines)
**Purpose:** Git state caching system (v1.5.0)
**Content:**
- `init_git_cache()` - Initialize cache once
- `get_git_status()` - Cached status output
- `get_git_diff_stat()` - Cached diff statistics
- `get_git_diff_files()` - Cached changed files
- `get_current_branch()` - Cached branch name
- Cache invalidation helpers

#### 5. **lib/validation.sh** (~150 lines)
**Purpose:** Pre-flight checks and validation
**Content:**
- `check_prerequisites()` - Git, npm, etc.
- `validate_dependencies()` - Node modules
- `validate_git_state()` - Clean working tree
- `validate_environment()` - Directory structure

#### 6. **lib/backlog.sh** (~200 lines)
**Purpose:** Backlog and issue tracking (v1.3.0)
**Content:**
- `create_step_backlog()` - Generate issue reports
- `append_to_backlog()` - Add issues to step report
- `finalize_step_backlog()` - Close report with summary
- `create_workflow_summary()` - Generate overall summary
- Markdown formatting helpers

#### 7. **lib/summary.sh** (~150 lines)
**Purpose:** Summary generation (v1.4.0)
**Content:**
- `create_step_summary()` - Generate step conclusions
- `determine_step_status()` - Status indicators (✅ ⚠️ ❌)
- `create_workflow_summary_report()` - Final summary
- Quick-reference summary templates

#### 8. **lib/ai_helpers.sh** (~100 lines)
**Purpose:** AI prompt templates and helpers
**Content:**
- Persona templates for each step
- `build_ai_prompt()` - Construct prompts with context
- `execute_copilot_prompt()` - Copilot CLI wrapper
- AI mode handling (auto/interactive/optional)

#### 9. **steps/step_01_documentation.sh** (~250 lines)
**Purpose:** Documentation updates (Step 1)
**Content:**
- `execute_step_01()` - Main step function
- Phase 1: Automated doc validation
- Phase 2: AI-powered analysis
- Documentation update suggestions

**Pattern for all step files:**
- Single exported function: `execute_step_XX()`
- Two-phase validation (Automated + AI)
- Backlog integration
- Summary generation
- Dry-run support

#### 10-20. **steps/step_02_*.sh through step_11_*.sh**
Similar structure to step_01, each ~200-300 lines:
- Step-specific validation logic
- AI persona integration
- Backlog tracking
- Summary output

#### 21. **execute_tests_docs_workflow.sh** (Main Orchestrator, ~250 lines)
**Purpose:** Workflow coordination
**Content:**
```bash
#!/bin/bash
# Main orchestrator - sources all modules and executes workflow

# Source all library modules
source "$(dirname "$0")/lib/config.sh"
source "$(dirname "$0")/lib/colors.sh"
source "$(dirname "$0")/lib/utils.sh"
source "$(dirname "$0")/lib/git_cache.sh"
source "$(dirname "$0")/lib/validation.sh"
source "$(dirname "$0")/lib/backlog.sh"
source "$(dirname "$0")/lib/summary.sh"
source "$(dirname "$0")/lib/ai_helpers.sh"

# Source all step modules
for step_file in "$(dirname "$0")/steps"/step_*.sh; do
    source "$step_file"
done

# Main workflow execution
main() {
    trap cleanup EXIT INT TERM

    print_header "${SCRIPT_NAME} v${SCRIPT_VERSION}"
    parse_arguments "$@"

    check_prerequisites
    validate_dependencies
    init_git_cache

    # Create run directories
    mkdir -p "$BACKLOG_RUN_DIR" "$SUMMARIES_RUN_DIR" "$LOGS_RUN_DIR"

    # Execute all steps
    execute_step_01  # Documentation
    execute_step_02  # Consistency
    execute_step_03  # Script refs
    execute_step_04  # Directory
    execute_step_05  # Test review
    execute_step_06  # Test generation
    execute_step_07  # Test execution
    execute_step_08  # Dependencies
    execute_step_09  # Quality
    execute_step_10  # Context
    execute_step_11  # Git finalization

    # Generate final summary
    create_workflow_summary_report
}

main "$@"
```

---

## Implementation Strategy

### Phase 1: Extract Core Libraries (Priority: HIGH)
**Estimated Time:** 2-3 hours
**Files to Create:** `lib/*.sh`

1. Create `lib/` directory
2. Extract configuration → `lib/config.sh`
3. Extract colors → `lib/colors.sh`
4. Extract utilities → `lib/utils.sh`
5. Extract git caching → `lib/git_cache.sh`
6. Extract validation → `lib/validation.sh`
7. Extract backlog → `lib/backlog.sh`
8. Extract summary → `lib/summary.sh`
9. Extract AI helpers → `lib/ai_helpers.sh`

**Testing:** Verify each library sources correctly

### Phase 2: Extract Step Modules (Priority: MEDIUM)
**Estimated Time:** 4-6 hours
**Files to Create:** `steps/*.sh`

1. Create `steps/` directory
2. Extract each step (1-11) to separate file
3. Ensure consistent function naming: `execute_step_XX()`
4. Verify backlog and summary integration
5. Test AI prompt templates

**Testing:** Execute each step independently

### Phase 3: Refactor Main Script (Priority: HIGH)
**Estimated Time:** 1-2 hours
**Files to Modify:** `execute_tests_docs_workflow.sh`

1. Remove extracted code
2. Add source statements for libraries
3. Add source statements for steps
4. Simplify main() function
5. Update help text

**Testing:** Full workflow execution

### Phase 4: Documentation & Testing (Priority: HIGH)
**Estimated Time:** 2-3 hours
**Files to Create:** `src/workflow/README.md`

1. Document module structure
2. Create module API reference
3. Update main README.md
4. Update `.github/copilot-instructions.md`
5. Run full integration tests
6. Verify dry-run mode
7. Test auto and interactive modes

---

## Testing Strategy

### Unit Testing (Per Module)
```bash
# Test each library independently
bash -n lib/config.sh      # Syntax check
bash -n lib/colors.sh
bash -n lib/utils.sh
# ... etc

# Test sourcing
bash -c "source lib/config.sh && echo \$SCRIPT_VERSION"
```

### Integration Testing
```bash
# Test full workflow
./execute_tests_docs_workflow.sh --dry-run
./execute_tests_docs_workflow.sh --auto --dry-run
./execute_tests_docs_workflow.sh --interactive --dry-run
```

### Regression Testing
- Compare output before/after split
- Verify all 13 steps execute correctly
- Check backlog generation
- Verify summary generation
- Test AI integration

---

## Migration Checklist

- [ ] Create `src/workflow/lib/` directory
- [ ] Create `src/workflow/steps/` directory
- [ ] Extract `lib/config.sh` (80 lines)
- [ ] Extract `lib/colors.sh` (30 lines)
- [ ] Extract `lib/utils.sh` (200 lines)
- [ ] Extract `lib/git_cache.sh` (150 lines)
- [ ] Extract `lib/validation.sh` (150 lines)
- [ ] Extract `lib/backlog.sh` (200 lines)
- [ ] Extract `lib/summary.sh` (150 lines)
- [ ] Extract `lib/ai_helpers.sh` (100 lines)
- [ ] Extract `steps/step_01_documentation.sh` (250 lines)
- [ ] Extract `steps/step_02_consistency.sh` (250 lines)
- [ ] Extract `steps/step_03_script_refs.sh` (250 lines)
- [ ] Extract `steps/step_04_directory.sh` (250 lines)
- [ ] Extract `steps/step_05_test_review.sh` (250 lines)
- [ ] Extract `steps/step_06_test_gen.sh` (250 lines)
- [ ] Extract `steps/step_07_test_exec.sh` (250 lines)
- [ ] Extract `steps/step_08_dependencies.sh` (250 lines)
- [ ] Extract `steps/step_09_quality.sh` (250 lines)
- [ ] Extract `steps/step_10_context.sh` (250 lines)
- [ ] Extract `steps/step_11_git_final.sh` (250 lines)
- [ ] Refactor `execute_tests_docs_workflow.sh` (250 lines)
- [ ] Test all modules independently
- [ ] Run full integration test (dry-run)
- [ ] Run full integration test (auto mode)
- [ ] Run full integration test (interactive mode)
- [ ] Update documentation
- [ ] Update `.github/copilot-instructions.md`
- [ ] Create module README
- [ ] Verify backward compatibility

---

## Expected Benefits

### Maintainability
- **Reduced Complexity:** 4,337 lines → 21 files averaging ~200 lines each
- **Single Responsibility:** Each module has one clear purpose
- **Easier Debugging:** Isolate issues to specific modules

### Reusability
- **Library Functions:** Utilities can be used by other scripts
- **Step Templates:** Easy to add new workflow steps
- **Git Cache:** Reusable in other workflow scripts

### Testing
- **Unit Tests:** Test each module independently
- **Isolated Changes:** Modify one step without affecting others
- **Clear Boundaries:** Well-defined module interfaces

### Development
- **Parallel Work:** Multiple developers can work on different modules
- **Faster Iteration:** Smaller files are easier to edit
- **Better Version Control:** Granular commits per module

---

## Risks & Mitigation

### Risk: Sourcing Dependencies
**Mitigation:** Use absolute paths and verify all sourcing in init phase

### Risk: Variable Scope Issues
**Mitigation:** Use explicit exports and document global variables

### Risk: Breaking Changes
**Mitigation:** Maintain comprehensive test suite and version control

### Risk: Performance Overhead
**Mitigation:** Source files are lightweight; minimal performance impact

---

## Version Strategy

After split completion:
- Main script: **v2.0.0** (major refactoring)
- Update changelog with modularization details
- Tag release: `workflow-v2.0.0`

---

## Timeline

| Phase | Duration | Complexity |
|-------|----------|------------|
| Phase 1: Core Libraries | 2-3 hours | Medium |
| Phase 2: Step Modules | 4-6 hours | High |
| Phase 3: Main Refactor | 1-2 hours | Low |
| Phase 4: Documentation | 2-3 hours | Medium |
| **Total** | **9-14 hours** | **High** |

---

## Next Steps

1. **Review this plan** with stakeholders
2. **Create feature branch:** `git checkout -b workflow-modularization`
3. **Execute Phase 1:** Extract core libraries
4. **Execute Phase 2:** Extract step modules
5. **Execute Phase 3:** Refactor main script
6. **Execute Phase 4:** Documentation and testing
7. **Merge to main:** After full validation

---

**Generated:** 2025-11-12
**Plan Version:** 1.0.0
**Status:** Ready for Execution
