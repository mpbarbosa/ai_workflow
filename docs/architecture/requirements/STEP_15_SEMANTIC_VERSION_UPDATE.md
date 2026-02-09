# Functional Requirements: Step 15 - AI-Powered Semantic Version Update

**Feature ID**: WF-2026-002  
**Version**: 3.0.0  
**Status**: Draft  
**Created**: 2026-01-15  
**Author**: AI Workflow Automation Team  
**Target Release**: v2.13.0

---

## Executive Summary

Introduce **Step 15: AI-Powered Semantic Version Update** as a new workflow step that intelligently updates semantic version numbers in all modified files and the project's semantic version. This step will run immediately before Step 11 (Git Finalization) in the workflow execution flow, ensuring all version numbers are current before committing changes.

### Current State (v2.12.0)

- **Step 0a (Pre-Processing)**: Runs version updates BEFORE documentation analysis (between Step 0 and Step 1)
- **Limitation**: Early version updates may become stale by the time workflow completes
- **Position**: Pre-processing stage, not part of final validation pipeline

### Target State (v2.13.0)

- **Step 15 (Final Validation)**: Runs version updates AFTER all analysis steps, RIGHT BEFORE Git Finalization
- **Advantage**: Version updates reflect the complete set of changes made during workflow execution
- **Position**: Final validation stage, immediately before commit
- **AI Integration**: Leverages AI to determine appropriate version bump based on change analysis

---

## Problem Statement

### Current Workflow Architecture Issues

1. **Timing Problem**: Step 0a runs too early (pre-processing stage)
   - Version updates happen before documentation, tests, and code quality improvements
   - Changes made during Steps 1-14 may warrant different version bumps
   - Version numbers may become stale by Step 11

2. **Context Problem**: Limited change context available at Step 0a
   - Only git diff available, no analysis results
   - Cannot leverage insights from Steps 1-10, 12-14
   - Manual bump type determination (major/minor/patch)

3. **Workflow Position**: Not aligned with dependency graph best practices
   - Pre-processing steps should prepare environment, not modify content
   - Final validation steps should ensure correctness before commit
   - Version updates are a final validation concern, not pre-processing

### Business Impact

- **Version Accuracy**: Versions may not reflect actual change magnitude
- **Developer Confidence**: Uncertainty about version correctness
- **Release Management**: Manual version verification required
- **Audit Trail**: Commit messages don't match actual changes

---

## Proposed Solution

### High-Level Approach

Create **Step 15: AI-Powered Semantic Version Update** that:

1. **Runs after all analysis steps** (Steps 10, 12, 13, 14)
2. **Immediately precedes Git Finalization** (Step 11)
3. **Leverages AI analysis** to determine appropriate version bumps
4. **Updates all version occurrences** in modified files and project metadata
5. **Follows project patterns** established in existing workflow steps

### Key Differentiators from Step 0a

| Aspect | Step 0a (Pre-Processing) | Step 15 (Proposed) |
|--------|--------------------------|-------------------|
| **Timing** | Before docs analysis | After all analysis, before git |
| **Context** | Git diff only | Full workflow context + AI insights |
| **Bump Logic** | Rule-based heuristics | AI-powered analysis |
| **Purpose** | Prepare version numbers | Final validation before commit |
| **Dependencies** | Step 0 only | Steps 10, 12, 13, 14 |
| **Position** | Pre-processing | Final validation |

---

## Functional Requirements

### FR-001: Step Execution Order

**Priority**: Must Have  
**Description**: Step 15 must execute immediately before Step 11 (Git Finalization) in the workflow execution order.

**Acceptance Criteria**:

- [ ] Step 15 executes after Steps 10, 12, 13, 14 complete successfully
- [ ] Step 15 executes before Step 11 begins
- [ ] Dependency graph updated with: `STEP_DEPENDENCIES[15]="10,12,13,14"`
- [ ] Dependency graph updated with: `STEP_DEPENDENCIES[11]="15"` (replaces `"10,12,13,14"`)
- [ ] Parallel groups updated to include Step 15 between analysis and git

**Technical Implementation**:

```bash
# In dependency_graph.sh
STEP_DEPENDENCIES=(
    [0]=""
    [0a]="0"
    [1]="0a"
    # ... other steps ...
    [10]="1,2,3,4,7,8,9"
    [12]="2"
    [13]="0"
    [14]="0,1"
    [15]="10,12,13,14"    # NEW: Depends on all analysis steps
    [11]="15"              # UPDATED: Now depends on Step 15 (was "10,12,13,14")
)
```

---

### FR-002: Version Pattern Detection

**Priority**: Must Have  
**Description**: Automatically detect and update all semantic version patterns in modified files.

**Supported Version Patterns**:

- [ ] **Semver in code**: `version="X.Y.Z"`, `VERSION: X.Y.Z`, `Version = X.Y.Z`
- [ ] **Semver in comments**: `# Version: X.Y.Z`, `// @version X.Y.Z`
- [ ] **Package manifests**: `package.json`, `pyproject.toml`, `Cargo.toml`, `pom.xml`
- [ ] **Shell scripts**: `readonly VERSION="X.Y.Z"`, `SCRIPT_VERSION="X.Y.Z"`
- [ ] **Documentation**: Version references in README, CHANGELOG, docs/

**Acceptance Criteria**:

- [ ] Detect all semver patterns (X.Y.Z) in modified files
- [ ] Support multiple version declarations per file
- [ ] Handle both quoted and unquoted versions
- [ ] Preserve original formatting (quotes, spacing, casing)

**Pattern Detection Function**:

```bash
detect_version_patterns() {
    local file="$1"
    
    # Search for semver patterns (X.Y.Z)
    grep -nE '(version|VERSION|Version|@version)["'\'':\s=]*[0-9]+\.[0-9]+\.[0-9]+' "$file" \
        | while IFS=: read -r line_num match; do
            echo "${line_num}:${match}"
        done
}
```

---

### FR-003: AI-Powered Bump Type Determination

**Priority**: Must Have  
**Description**: Use AI analysis to determine appropriate version bump type (major, minor, patch).

**AI Analysis Inputs**:

- [ ] Step 0 pre-analysis results (change scope)
- [ ] Step 10 context analysis (workflow summary)
- [ ] Step 13 prompt engineer analysis (prompt changes)
- [ ] Step 14 UX analysis (UI/UX changes)
- [ ] Git diff statistics (files changed, lines added/deleted)
- [ ] Commit messages (if available from git history)

**Bump Type Rules** (AI-assisted):

| Bump Type | Criteria | Examples |
|-----------|----------|----------|
| **Major (X.0.0)** | Breaking changes | API changes, removed features, incompatible updates |
| **Minor (X.Y.0)** | New features | New capabilities, enhancements, additive changes |
| **Patch (X.Y.Z)** | Bug fixes | Docs updates, bug fixes, refactoring, tests |

**Acceptance Criteria**:

- [ ] Invoke AI with "version_manager" persona
- [ ] Provide comprehensive change context from Steps 0, 10, 13, 14
- [ ] AI returns bump type recommendation (major/minor/patch) with reasoning
- [ ] Fallback to rule-based heuristics if AI unavailable
- [ ] Log AI reasoning for audit trail

**AI Persona Prompt** (add to `ai_helpers.yaml`):

```yaml
version_manager:
  role_prefix: "You are a Version Manager and Semantic Versioning Expert"
  behavioral_guidelines:
    <<: *standard_guidelines
  specific_expertise: |
    Determine appropriate semantic version bumps based on change analysis:
    - MAJOR (X.0.0): Breaking changes, API modifications, removed features
    - MINOR (X.Y.0): New features, enhancements, additive changes
    - PATCH (X.Y.Z): Bug fixes, documentation, refactoring, tests
  
  approach: |
    1. Analyze change context from workflow steps
    2. Identify breaking changes, new features, or bug fixes
    3. Recommend version bump type with clear reasoning
    4. Consider conventional commit message guidelines
  
  output: |
    Bump Type: [major|minor|patch]
    Reasoning: [2-3 sentence explanation]
    Confidence: [high|medium|low]
```

---

### FR-004: Project Semantic Version Update

**Priority**: Must Have  
**Description**: Update the project's semantic version in all relevant metadata files.

**Project Version Locations**:

- [ ] `package.json` (Node.js projects)
- [ ] `pyproject.toml` / `setup.py` (Python projects)
- [ ] `Cargo.toml` (Rust projects)
- [ ] `pom.xml` (Java/Maven projects)
- [ ] `build.gradle` (Java/Gradle projects)
- [ ] `.workflow-config.yaml` (AI Workflow project metadata)
- [ ] Main script version variables (e.g., `SCRIPT_VERSION` in `execute_tests_docs_workflow.sh`)

**Acceptance Criteria**:

- [ ] Detect project type from tech stack configuration
- [ ] Update version in project-specific metadata files
- [ ] Validate version update succeeded (file contains new version)
- [ ] Create backup before update, restore on failure
- [ ] Skip project version update if no metadata file exists

**Version Update Function**:

```bash
update_project_version() {
    local old_version="$1"
    local new_version="$2"
    local project_kind="${PROJECT_KIND:-generic}"
    
    case "$project_kind" in
        nodejs_*)
            update_version_in_file "package.json" "$old_version" "$new_version" "json"
            ;;
        python_*)
            update_version_in_file "pyproject.toml" "$old_version" "$new_version" "toml"
            [[ -f setup.py ]] && update_version_in_file "setup.py" "$old_version" "$new_version" "python"
            ;;
        rust_*)
            update_version_in_file "Cargo.toml" "$old_version" "$new_version" "toml"
            ;;
        # ... other project types
    esac
}
```

---

### FR-005: Modified Files Version Update

**Priority**: Must Have  
**Description**: Update semantic version in all modified files that contain version declarations.

**File Selection Logic**:

- [ ] Get modified files from git cache: `get_git_modified_files`
- [ ] Exclude workflow artifacts: `backlog/`, `logs/`, `summaries/`, `metrics/`
- [ ] Exclude third-party code: use `third_party_exclusion.sh`
- [ ] Include only text files (skip binaries, images, archives)

**Update Process**:

1. **Detect**: Scan each modified file for version patterns
2. **Extract**: Get current version number
3. **Calculate**: Determine new version (old version + bump type)
4. **Update**: Replace all occurrences with new version
5. **Validate**: Verify update succeeded
6. **Report**: Log success/failure/skip for each file

**Acceptance Criteria**:

- [ ] Update all version occurrences within each modified file
- [ ] Preserve original format (quotes, spacing, comment style)
- [ ] Handle multiple version declarations per file
- [ ] Skip files without version patterns
- [ ] Report detailed results (updated/skipped/failed counts)

---

### FR-006: Step Module Structure

**Priority**: Must Have  
**Description**: Follow project patterns and standards for workflow step modules.

**File Structure**:

```text
src/workflow/steps/step_15_version_update.sh
├── Header comment block (purpose, version, dependencies)
├── Version constants (STEP15_VERSION="3.0.0")
├── Library sourcing (colors.sh, utils.sh, ai_helpers.sh)
├── Helper functions
│   ├── detect_version_patterns()
│   ├── extract_version()
│   ├── increment_version()
│   ├── determine_ai_bump_type()
│   ├── update_version_in_file()
│   └── update_project_version()
└── Main step function
    └── step15_version_update()
```

**Acceptance Criteria**:

- [ ] Header comment includes: Purpose, Version, Dependencies, Position
- [ ] Version constants follow pattern: `STEP15_VERSION`, `STEP15_VERSION_MAJOR/MINOR/PATCH`
- [ ] Source required libraries: `colors.sh`, `utils.sh`, `ai_helpers.sh`, `git_cache.sh`
- [ ] Use `print_step "15" "Semantic Version Update"` for step header
- [ ] Export main function: `export -f step15_version_update`

**Code Style**:

```bash
#!/bin/bash
set -euo pipefail

################################################################################
# Step 15: AI-Powered Semantic Version Update
# Purpose: Update semantic versions in modified files and project metadata
# Part of: Tests & Documentation Workflow Automation v2.13.0
# Version: 3.0.0
# Position: Runs after all analysis (10,12,13,14), before Git Finalization (11)
# Dependencies: Steps 10, 12, 13, 14
################################################################################

# Module version information
readonly STEP15_VERSION="3.0.0"
readonly STEP15_VERSION_MAJOR=1
readonly STEP15_VERSION_MINOR=0
readonly STEP15_VERSION_PATCH=0
```

---

### FR-007: Dry Run Support

**Priority**: Must Have  
**Description**: Support dry-run mode to preview version updates without applying changes.

**Acceptance Criteria**:

- [ ] Check `$DRY_RUN` flag at step start
- [ ] Display preview of planned updates
- [ ] List files that would be updated
- [ ] Show old → new version for each file
- [ ] Skip actual file modifications
- [ ] Return success (0) after preview

**Dry Run Output**:

```text
[DRY RUN] Step 15: Semantic Version Update
  Bump Type: minor (AI recommendation: new features added)
  
  Would update project version:
    package.json: 2.12.0 → 2.13.0
  
  Would update file versions:
    src/workflow/execute_tests_docs_workflow.sh: 2.12.0 → 2.13.0
    src/workflow/steps/step_15_version_update.sh: 3.0.0 → 3.0.0 (no change)
    README.md: 2.12.0 → 2.13.0
  
  Total: 3 files would be updated
```

---

### FR-008: Checkpoint and Resume Support

**Priority**: Must Have  
**Description**: Support workflow checkpoint system for resume capability.

**Acceptance Criteria**:

- [ ] Save checkpoint after successful completion: `save_checkpoint 15`
- [ ] Check resume point: `if [[ $resume_from -le 15 ]]`
- [ ] Skip if resuming from later checkpoint
- [ ] Log step start: `log_step_start 15 "Semantic Version Update"`
- [ ] Log step complete: `log_step_complete 15 "Semantic Version Update" "SUCCESS"`

---

### FR-009: Metrics and Reporting

**Priority**: Must Have  
**Description**: Generate comprehensive reports of version update operations.

**Report Sections**:

- [ ] **Summary**: Total files updated/skipped/failed
- [ ] **Bump Type**: AI recommendation and reasoning
- [ ] **Project Version**: Old → New version
- [ ] **File Updates**: Per-file update status
- [ ] **Warnings**: Files that couldn't be updated
- [ ] **Recommendations**: Manual actions required (if any)

**Outputs**:

- [ ] Backlog report: `backlog/workflow_YYYYMMDD_HHMMSS/step_15_version_update.md`
- [ ] Step summary: `summaries/workflow_YYYYMMDD_HHMMSS/step_15_summary.md`
- [ ] Workflow log: Timestamped entries in `logs/workflow_YYYYMMDD_HHMMSS/workflow_execution.log`

**Report Template**:

```markdown
# Step 15: AI-Powered Semantic Version Update

**Status**: ✅ Complete
**Bump Type**: minor (AI-recommended)
**Date**: 2026-01-15 10:30:00

## AI Analysis

**Recommendation**: Minor version bump
**Reasoning**: New features added in Steps 1-10 (documentation enhancements, 
new test capabilities). No breaking changes detected.
**Confidence**: High

## Project Version Update

- **File**: package.json
- **Old Version**: 2.12.0
- **New Version**: 2.13.0
- **Status**: ✅ Updated

## Modified Files

### Updated (3 files)
- `src/workflow/execute_tests_docs_workflow.sh`: 2.12.0 → 2.13.0 ✅
- `src/workflow/steps/step_15_version_update.sh`: 3.0.0 → 3.0.0 (no change) ✅
- `README.md`: 2.12.0 → 2.13.0 ✅

### Skipped (2 files)
- `docs/examples/sample.md`: No version pattern detected
- `tests/test_version.sh`: Version already current (2.13.0)

### Failed (0 files)

## Summary

- Files updated: 3
- Files skipped: 2
- Files failed: 0
- Total files processed: 5

**Result**: All version updates completed successfully.
```

---

### FR-010: Workflow Integration

**Priority**: Must Have  
**Description**: Integrate Step 15 into main workflow orchestrator script.

**Integration Points**:

1. **Main Workflow Script** (`execute_tests_docs_workflow.sh`):

```bash
# Step 15: Semantic Version Update (with checkpoint)
if [[ -z "$failed_step" && $resume_from -le 15 ]] && should_execute_step 15; then
    log_step_start 15 "Semantic Version Update"
    step15_version_update || { failed_step="Step 15"; }
    [[ -z "$failed_step" ]] && update_workflow_status 15 "✅"
    ((executed_steps++)) || true
    save_checkpoint 15
elif [[ -z "$failed_step" && $resume_from -le 15 ]]; then
    print_info "Skipping Step 15 (not selected)"
fi
```

2. **Dependency Graph** (`lib/dependency_graph.sh`):

```bash
STEP_DEPENDENCIES=(
    # ... existing steps ...
    [15]="10,12,13,14"    # NEW
    [11]="15"              # UPDATED (was "10,12,13,14")
)

STEP_TIME_ESTIMATES=(
    # ... existing steps ...
    [15]=60   # Version Update with AI (slightly longer than automated)
)
```

3. **Step Sourcing** (in main workflow):

```bash
# Source step modules
source "${WORKFLOW_STEPS_DIR}/step_00_analyze.sh"
source "${WORKFLOW_STEPS_DIR}/step_01_documentation.sh"
# ... other steps ...
source "${WORKFLOW_STEPS_DIR}/step_14_ux_analysis.sh"
source "${WORKFLOW_STEPS_DIR}/step_15_version_update.sh"  # NEW
source "${WORKFLOW_STEPS_DIR}/step_11_git.sh"
```

**Acceptance Criteria**:

- [ ] Step 15 module sourced before Step 11
- [ ] Step 15 execution added in correct order (after 14, before 11)
- [ ] Checkpoint support included
- [ ] Workflow status tracking included
- [ ] Logging integrated (start/complete)

---

### FR-011: Error Handling and Validation

**Priority**: Must Have  
**Description**: Robust error handling with graceful degradation.

**Error Scenarios**:

1. **AI Unavailable**: Fall back to rule-based bump type determination
2. **File Update Failed**: Continue with other files, report failure
3. **Project Version Not Found**: Skip project update, report warning
4. **Invalid Version Pattern**: Skip file, report warning
5. **Git Cache Unavailable**: Use direct git commands

**Acceptance Criteria**:

- [ ] Try AI analysis, fall back to heuristics if unavailable
- [ ] Continue processing files even if some fail
- [ ] Return success (0) if at least project version updated
- [ ] Return success (0) if no updates needed (valid state)
- [ ] Return failure (1) only if critical error (e.g., cannot read git state)
- [ ] Log all warnings and errors to workflow log

**Fallback Logic**:

```bash
# Try AI analysis first
if check_copilot_available && [[ "${AUTO_MODE:-false}" != true ]]; then
    bump_type=$(determine_ai_bump_type) || {
        print_warning "AI analysis failed, using heuristics"
        bump_type=$(determine_heuristic_bump_type)
    }
else
    print_info "Using heuristic bump type (AI unavailable or auto mode)"
    bump_type=$(determine_heuristic_bump_type)
fi
```

---

### FR-012: Step Relevance Configuration

**Priority**: Should Have  
**Description**: Support project-specific step relevance rules.

**Project Kind Rules**:

```yaml
# In config/project_kinds.yaml
project_kinds:
  nodejs_library:
    steps:
      step_15_version_update: required  # Package version critical
  
  python_api:
    steps:
      step_15_version_update: required  # API versioning important
  
  documentation:
    steps:
      step_15_version_update: optional  # Version less critical
  
  static_website:
    steps:
      step_15_version_update: skip      # No versioning needed
```

**Acceptance Criteria**:

- [ ] Check step relevance: `should_run_step 15`
- [ ] Skip if marked as `skip` for project kind
- [ ] Mark as optional if marked as `optional`
- [ ] Always run if marked as `required` or no config
- [ ] Log relevance decision

---

## Non-Functional Requirements

### NFR-001: Performance

**Priority**: Must Have

- [ ] Step execution time: ≤ 60 seconds for typical projects
- [ ] AI analysis timeout: 30 seconds maximum
- [ ] File processing: ≥ 100 files per second
- [ ] No blocking operations without timeout

### NFR-002: Reliability

**Priority**: Must Have

- [ ] Success rate: ≥ 99% for valid version patterns
- [ ] Data safety: Backup files before modification
- [ ] Rollback capability: Restore on failure
- [ ] Idempotent: Safe to run multiple times

### NFR-003: Maintainability

**Priority**: Must Have

- [ ] Code coverage: 100% (follow project standard)
- [ ] Unit tests: All functions tested
- [ ] Integration tests: Full step execution tested
- [ ] Documentation: Inline comments for complex logic

### NFR-004: Compatibility

**Priority**: Must Have

- [ ] Bash version: 4.0+
- [ ] Git version: 2.0+
- [ ] Works with/without AI (graceful degradation)
- [ ] Supports all project kinds (12+ types)

---

## Testing Strategy

### Unit Tests

```bash
# tests/test_step_15_version_update.sh
test_detect_version_patterns()
test_extract_version()
test_increment_version_major()
test_increment_version_minor()
test_increment_version_patch()
test_update_version_in_file()
test_determine_heuristic_bump_type()
test_update_project_version()
test_should_run_step()
```

### Integration Tests

```bash
# tests/integration/test_step_15_integration.sh
test_step15_full_execution()
test_step15_with_ai()
test_step15_without_ai()
test_step15_dry_run()
test_step15_no_changes()
test_step15_checkpoint_resume()
```

### End-to-End Tests

```bash
# Run full workflow with Step 15
./execute_tests_docs_workflow.sh --steps 0,10,12,13,14,15,11 --dry-run
./execute_tests_docs_workflow.sh --steps 15 --ai-batch
```

---

## Migration Strategy

### Phase 1: Implementation (Week 1)

- [ ] Create `step_15_version_update.sh` module
- [ ] Implement core version detection and update functions
- [ ] Add AI persona to `ai_helpers.yaml`
- [ ] Write unit tests

### Phase 2: Integration (Week 2)

- [ ] Update dependency graph
- [ ] Integrate into main workflow script
- [ ] Add step execution logic
- [ ] Write integration tests

### Phase 3: Validation (Week 3)

- [ ] Test on sample projects (Node.js, Python, Shell)
- [ ] Verify AI analysis accuracy
- [ ] Performance benchmarking
- [ ] Documentation updates

### Phase 4: Release (Week 4)

- [ ] Code review and approval
- [ ] Update CHANGELOG.md
- [ ] Update PROJECT_REFERENCE.md
- [ ] Release v2.13.0

---

## Backward Compatibility

### Step 0a Preservation

**Decision**: Keep Step 0a (pre-processing) for backward compatibility

**Rationale**:

- Existing workflows may depend on early version updates
- Some use cases benefit from pre-processing version updates
- No harm in having both steps (different purposes)

**Coexistence Strategy**:

- Step 0a: Quick pre-processing updates (heuristic-based)
- Step 15: Comprehensive final updates (AI-powered)
- If both run, Step 15 takes precedence (overwrites Step 0a changes)

### Configuration Compatibility

- [ ] No breaking changes to existing configuration
- [ ] New step is opt-in (can be skipped with `--steps` option)
- [ ] Works with all existing workflow flags (`--auto`, `--dry-run`, `--ai-batch`)

---

## Success Criteria

### Definition of Done

- [ ] Step 15 module implemented and tested (100% coverage)
- [ ] Dependency graph updated and validated
- [ ] Main workflow integration complete
- [ ] AI persona added to `ai_helpers.yaml`
- [ ] Documentation updated (README, PROJECT_REFERENCE, CHANGELOG)
- [ ] All tests passing (unit, integration, E2E)
- [ ] Performance benchmarks met (≤60s execution)
- [ ] Code review approved by maintainer

### Validation Checklist

- [ ] Run full workflow on 3+ different project types
- [ ] Verify correct version updates in all files
- [ ] Confirm Step 15 executes before Step 11
- [ ] Test dry-run mode
- [ ] Test checkpoint resume
- [ ] Test with AI enabled/disabled
- [ ] Verify backlog and summary reports generated
- [ ] Check metrics collection working

---

## Open Questions

1. **Q**: Should Step 15 update versions that Step 0a already updated?
   **A**: Yes. Step 15 runs final validation and should be authoritative. Overwrites Step 0a if necessary.

2. **Q**: What if AI recommends different bump type than git heuristics?
   **A**: Trust AI recommendation. Log both for audit trail. AI has more context from workflow steps.

3. **Q**: Should Step 15 be mandatory or optional?
   **A**: Optional by default, but can be marked as `required` per project kind in configuration.

4. **Q**: How to handle monorepo with multiple package versions?
   **A**: Phase 1: Update root package version only. Phase 2: Support workspace version updates.

5. **Q**: Should Step 15 validate version format (e.g., no leading zeros)?
   **A**: Yes. Add validation function to ensure semver compliance.

---

## References

### Related Documents

- [STEP_15_VERSION_UPDATE_IMPLEMENTATION.md](../../STEP_15_VERSION_UPDATE_IMPLEMENTATION.md) - Step 0a implementation (for comparison)
- [docs/PROJECT_REFERENCE.md](../PROJECT_REFERENCE.md) - Project statistics and module inventory
- [src/workflow/lib/dependency_graph.sh](../../src/workflow/lib/dependency_graph.sh) - Step dependencies
- [.workflow_core/config/ai_helpers.yaml](../../.workflow_core/config/ai_helpers.yaml) - AI persona prompts

### Technical Resources

- Semantic Versioning Specification: https://semver.org/
- Conventional Commits: https://www.conventionalcommits.org/
- GitHub Copilot CLI Documentation: (internal)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 3.0.0 | 2026-01-15 | AI Workflow Team | Initial draft |

---

**Status**: ✅ Ready for Review  
**Next Steps**: Implementation Phase 1 (Module Creation)  
**Estimated Effort**: 4 weeks (1 week per phase)
