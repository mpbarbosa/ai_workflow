# API Reference - Workflow Orchestrators

**Version**: v3.0.0  
**Last Updated**: 2026-01-31

This document provides a comprehensive API reference for the 4 workflow orchestrator modules that coordinate phase-specific execution in the AI Workflow Automation system.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Pre-Flight Orchestrator](#pre-flight-orchestrator)
- [Validation Orchestrator](#validation-orchestrator)
- [Quality Orchestrator](#quality-orchestrator)
- [Finalization Orchestrator](#finalization-orchestrator)
- [Test Phase (Inline)](#test-phase-inline)
- [Common Patterns](#common-patterns)
- [Integration](#integration)
- [Performance](#performance)

---

## Overview

Orchestrators are phase-specific coordination modules that manage execution of related workflow steps. They implement the **Phase-Based Architecture** pattern, reducing complexity through focused responsibility.

### Orchestrator Modules

| Orchestrator | File | Lines | Phase | Steps | Purpose |
|--------------|------|-------|-------|-------|---------|
| **Pre-Flight** | `pre_flight.sh` | 227 | Initialization | N/A | System checks, dependencies, cache init |
| **Validation** | `validation_orchestrator.sh` | 228 | Validation | 0-4 | Documentation and structure validation |
| **Test** | _(inline in main)_ | ~150 | Testing | 5-7 | Test review, generation, execution |
| **Quality** | `quality_orchestrator.sh` | 82 | Quality | 8-9 | Dependencies and code quality |
| **Finalization** | `finalization_orchestrator.sh` | 93 | Completion | 10-12 | Context, git, markdown lint |

**Total Code**: ~780 lines across 4 orchestrator files + inline test orchestration  
**Architecture Impact**: 91% reduction from original monolithic script (8,200 → 630 lines)

### Key Characteristics

- **Single Responsibility**: Each orchestrator manages one workflow phase
- **Clear Boundaries**: Communication via return codes, shared state, global variables
- **Error Propagation**: Consistent error handling and logging
- **Resume Support**: Checkpoint-based continuation after failures
- **Smart Execution**: Integration with change detection and optimization
- **Parallel Execution**: Support for concurrent step execution (validation phase)

---

## Architecture

### Communication Model

```bash
Main Orchestrator (execute_tests_docs_workflow.sh)
    ├── execute_preflight()         # Pre-flight checks
    ├── execute_validation_phase()  # Steps 0-4
    ├── [inline test phase]         # Steps 5-7
    ├── execute_quality_phase()     # Steps 8-9
    └── execute_finalization_phase() # Steps 10-12
```

### Shared State

Orchestrators communicate through:

1. **Return Codes**
   - `0`: Success
   - `1`: Failure (halt workflow unless `--continue-on-error`)

2. **Global Variables**
   - `WORKFLOW_STATUS`: Array tracking step completion
   - `CHANGE_IMPACT`: Low/Medium/High/Full
   - `RESUME_FROM_STEP`: Checkpoint resume point
   - `PARALLEL_EXECUTION`: Enable parallel execution
   - `SMART_EXECUTION`: Enable smart step skipping

3. **File System**
   - Checkpoints: `.checkpoints/step_XX`
   - Logs: `logs/workflow_TIMESTAMP/`
   - Metrics: `metrics/current_run.json`

### Error Handling Pattern

All orchestrators follow this pattern:

```bash
execute_phase() {
    print_header "Phase Name"
    log_to_workflow "INFO" "Starting phase"
    
    local start_time=$(date +%s)
    local failed_step=""
    local executed_steps=0
    local skipped_steps=0
    
    # Step execution with error tracking
    if ! step_function; then
        failed_step="Step X"
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ -z "$failed_step" ]]; then
        print_success "Phase completed in ${duration}s"
        log_to_workflow "SUCCESS" "Phase completed"
        return 0
    else
        print_error "Phase failed at $failed_step"
        log_to_workflow "ERROR" "Phase failed"
        return 1
    fi
}
```

---

## Pre-Flight Orchestrator

**File**: `src/workflow/orchestrators/pre_flight.sh`  
**Lines**: 227  
**Purpose**: System validation and initialization before workflow execution  
**Dependencies**: Core library modules  
**Execution Time**: ~5-15 seconds

### Main Function

#### `execute_preflight()`

```bash
execute_preflight
```

**Description**: Orchestrates all pre-flight checks and initialization tasks.

**Execution Flow**:
1. Initialize directories (backlog, logs, summaries)
2. Initialize workflow log
3. Check prerequisites (Bash, Node.js, npm, git)
4. Validate dependencies (npm packages)
5. Validate project structure (git repo, directories)
6. Initialize git cache
7. Initialize AI cache (if enabled)
8. Initialize metrics collection
9. Analyze change impact

**Returns**: 
- `0`: Pre-flight successful, workflow can proceed
- `1`: Critical failure, workflow should abort

**Side Effects**:
- Creates workflow directories
- Initializes cache systems
- Sets global variables: `CHANGE_IMPACT`, `ANALYSIS_*`
- Writes workflow log header

**Example Usage**:
```bash
# Called by main orchestrator
if ! execute_preflight; then
    print_error "Pre-flight checks failed - cannot proceed"
    exit 1
fi
```

---

### Prerequisite Validation

#### `check_prerequisites()`

```bash
check_prerequisites
```

**Description**: Validates system prerequisites required for workflow execution.

**Checks**:
1. **Bash Version**: Requires 4.0+
   - Uses associative arrays
   - Modern string manipulation
   
2. **Required Commands**:
   - `git`: Version control operations
   - `node`: JavaScript execution (for markdownlint, etc.)
   - `npm`: Package management

3. **Node.js Version**: Recommends 16.0+
   - Warns if older version detected
   - Non-fatal warning

**Returns**:
- `0`: All prerequisites satisfied
- `1`: Missing required tools or insufficient versions

**Error Messages**:
```bash
# Bash version too old
"Bash 4.0 or higher is required (current: 3.2.57)"

# Missing commands
"Missing required commands: git node npm"

# Node.js version warning
"Node.js 16+ recommended (current: v14.17.0)"
```

**Example Integration**:
```bash
if ! check_prerequisites; then
    cat << 'EOF'
Missing prerequisites detected. Please install:
  - Bash 4.0+
  - Git 2.0+
  - Node.js 16+
  - npm 7+
EOF
    return 1
fi
```

---

### Dependency Validation

#### `validate_dependencies()`

```bash
validate_dependencies
```

**Description**: Validates project dependencies are installed and up-to-date.

**Logic**:
1. Check if `package.json` exists (skip if not Node.js project)
2. Check if `node_modules/` directory exists
3. Prompt for `npm install` if missing (interactive mode)
4. Skip installation prompt in auto mode

**Returns**:
- `0`: Dependencies validated or N/A
- `1`: Dependency installation failed

**Interactive Behavior**:
```bash
# In interactive mode
"node_modules not found - dependencies may need installation"
"Run npm install? (y/N) "

# In auto mode
"Skipping dependency installation (non-interactive mode)"
```

**Environment Variables**:
- `INTERACTIVE_MODE`: Controls prompting behavior
- `PROJECT_ROOT`: Where to check for package.json

**Example Usage**:
```bash
cd "$PROJECT_ROOT"

if ! validate_dependencies; then
    print_error "Dependency validation failed"
    return 1
fi
```

---

### Project Structure Validation

#### `validate_project_structure()`

```bash
validate_project_structure
```

**Description**: Validates project has required structure for workflow execution.

**Validations**:
1. **Git Repository**: Must be inside a git repository
   - Uses `git rev-parse --git-dir`
   - Fatal if not git repo

2. **Source Directory**: Checks for standard source directories
   - `src/` (Node.js, Python, Go)
   - `lib/` (Libraries, utilities)
   - `app/` (Application code)
   - Warning if none found

3. **README**: Checks for project documentation
   - `README.md` in project root
   - Warning if missing

**Returns**:
- `0`: Valid project structure (may have warnings)
- `1`: Not a git repository (fatal)

**Warning vs Error**:
```bash
# Fatal error (returns 1)
"Not a git repository: /path/to/project"

# Non-fatal warning (returns 0)
"No standard source directory found (src/lib/app)"
"No README.md found in project root"
```

---

### Initialization Functions

#### `init_directories()`

```bash
init_directories
```

**Description**: Creates workflow execution directories for current run.

**Creates**:
- `$BACKLOG_RUN_DIR`: Step execution reports (workflow_TIMESTAMP/)
- `$SUMMARIES_RUN_DIR`: AI-generated summaries (workflow_TIMESTAMP/)
- `$LOGS_RUN_DIR`: Execution logs (workflow_TIMESTAMP/)

**Side Effects**: Sets global directory variables for use by steps

**Example**:
```bash
# After init_directories()
BACKLOG_RUN_DIR="src/workflow/backlog/workflow_20260131_020000"
SUMMARIES_RUN_DIR="src/workflow/summaries/workflow_20260131_020000"
LOGS_RUN_DIR="src/workflow/logs/workflow_20260131_020000"
```

#### `init_workflow_log()`

```bash
init_workflow_log
```

**Description**: Initializes main workflow execution log with header.

**Log Format**:
```
==================================
Workflow Execution Log
==================================
Started: 2026-01-31 02:00:00
Version: v3.0.0
Project: /home/user/my-project
Workflow Home: /home/user/ai_workflow
==================================
```

**Side Effects**: Creates `$WORKFLOW_LOG_FILE` in logs directory

---

### Performance Optimizations

Pre-flight orchestrator includes several performance optimizations:

1. **Git Cache Initialization**: Pre-loads git state for fast access
2. **AI Cache Setup**: Enables 24-hour response caching (60-80% token reduction)
3. **Metrics Collection**: Zero-overhead performance tracking
4. **Change Impact Analysis**: Determines workflow execution strategy

**Timing Breakdown**:
- Prerequisites check: ~1-2s
- Dependency validation: ~1-3s (skip if validated)
- Structure validation: ~1s
- Cache initialization: ~1-2s
- Change analysis: ~2-5s
- **Total**: ~5-15 seconds

---

## Validation Orchestrator

**File**: `src/workflow/orchestrators/validation_orchestrator.sh`  
**Lines**: 228  
**Purpose**: Coordinate documentation and structure validation (Steps 0-4)  
**Dependencies**: Steps 0-4 modules  
**Execution Time**: ~5-15 minutes (smart: 2-3 min, parallel: 3-5 min)

### Main Function

#### `execute_validation_phase()`

```bash
execute_validation_phase
```

**Description**: Orchestrates documentation and structure validation across Steps 0-4.

**Steps Managed**:
- **Step 0**: Pre-Analysis (tech stack, project kind, test validation)
- **Step 1**: Documentation Updates (AI-powered documentation review)
- **Step 2**: Consistency Analysis (cross-reference validation)
- **Step 3**: Script Reference Validation (path and command validation)
- **Step 4**: Directory Structure Validation (project structure checks)

**Execution Modes**:
1. **Sequential** (default): Steps run one after another
2. **Parallel** (`--parallel`): Steps 1-4 run simultaneously (Step 0 always first)

**Returns**:
- `0`: All validation steps completed successfully
- `1`: One or more steps failed

**Performance**:
- **Sequential**: ~10-15 minutes
- **Parallel**: ~6-8 minutes (33% faster)
- **Smart + Parallel**: ~3-5 minutes (docs-only changes)

**Example Execution**:
```bash
# Main orchestrator calls validation phase
if ! execute_validation_phase; then
    phase_failed=true
    print_error "Validation phase failed"
fi
```

**Output**:
```
========================================
Validation Phase (Steps 0-4)
========================================

Step 0: Pre-Analysis
  ✓ Analyzing git state...
  ✓ Detecting tech stack...
  ✓ Validating test infrastructure...

⚡ Parallel execution enabled for validation steps (1-4)

Starting parallel validation (Steps 1-4)...
Waiting for parallel steps to complete...
✓ Parallel validation completed successfully

✅ Validation phase completed in 187s (executed: 5, skipped: 0)
```

---

### Sequential Execution

#### `execute_validation_steps(resume_from)`

```bash
execute_validation_steps 0
```

**Description**: Executes validation steps sequentially (Steps 1-4).

**Parameters**:
- `resume_from`: Step number to resume from (for checkpoint recovery)

**Execution Logic**:
1. Check if parallel execution is possible and enabled
2. If yes, delegate to `execute_parallel_validation()`
3. If no, execute steps sequentially:
   - Step 1: Documentation Updates (~3-5 min)
   - Step 2: Consistency Analysis (~2-3 min)
   - Step 3: Script Reference Validation (~2-3 min)
   - Step 4: Directory Structure Validation (~1-2 min)

**Smart Execution Integration**:
```bash
# Each step checks if it should run
if should_execute_step 1; then
    log_step_start 1 "Documentation Updates"
    if ! step1_update_documentation; then
        return 1
    fi
    save_checkpoint 1
else
    print_info "Skipping Step 1 (smart execution)"
fi
```

**Resume Support**:
```bash
# Skip completed steps on resume
if [[ $resume_from -le 1 ]] && should_execute_step 1; then
    # Execute step 1
elif [[ $resume_from -gt 1 ]]; then
    print_info "Skipping Step 1 (resuming from checkpoint)"
fi
```

**Returns**:
- `0`: All steps completed
- `1`: Any step failed

---

### Parallel Execution

#### `execute_parallel_validation()`

```bash
execute_parallel_validation
```

**Description**: Executes Steps 1-4 in parallel for significant performance improvement.

**Algorithm**:
1. Create temporary directory for result tracking
2. Launch each step as background process
3. Capture exit codes to files
4. Wait for all processes to complete
5. Check exit codes and report results
6. Cleanup temporary files

**Implementation**:
```bash
# Launch steps in background
(
    log_step_start 1 "Documentation Updates"
    step1_update_documentation
    echo $? > "${temp_dir}/step1_exit.txt"
) &
local pid1=$!

(
    log_step_start 2 "Consistency Analysis"
    step2_check_consistency
    echo $? > "${temp_dir}/step2_exit.txt"
) &
local pid2=$!

# ... steps 3 and 4 ...

# Wait for all
wait $pid1 $pid2 $pid3 $pid4

# Check results
step1_exit=$(cat "${temp_dir}/step1_exit.txt")
# ... check all exit codes ...
```

**Performance Impact**:
- **Theoretical**: 4x speedup (4 steps in parallel)
- **Actual**: ~33% faster (2x speedup)
  - Reason: Shared resource contention (CPU, I/O, AI calls)
  - Bottleneck: AI call serialization (single Copilot CLI instance)

**Prerequisites**:
- All steps 1-4 must be selected for execution
- `--parallel` flag enabled
- Not in dry-run mode
- No resume checkpoint between steps 1-4

**Returns**:
- `0`: All parallel steps succeeded
- `1`: Any step failed

**Error Handling**:
```bash
# If parallel execution fails
print_error "Parallel validation failed (exit codes: 0 0 1 0)"
# Exit code per step reported for debugging
```

**Output**:
```
⚡ Parallel execution enabled for validation steps (1-4)
Starting parallel validation (Steps 1-4)...
Waiting for parallel steps to complete...
✓ Parallel validation completed successfully
```

---

### Step Execution Tracking

Validation orchestrator tracks execution metrics:

```bash
local executed_steps=0  # Count of steps actually run
local skipped_steps=0   # Count of steps skipped (smart execution, resume, etc.)
local failed_step=""    # Name of failed step (empty if all pass)
```

**Reporting**:
```bash
# Success case
print_success "Validation phase completed in ${duration}s (executed: 5, skipped: 0)"

# With skipped steps (smart execution)
print_success "Validation phase completed in ${duration}s (executed: 2, skipped: 3)"

# Failure case
print_error "Validation phase failed at Step 2"
```

---

## Quality Orchestrator

**File**: `src/workflow/orchestrators/quality_orchestrator.sh`  
**Lines**: 82  
**Purpose**: Coordinate dependency and code quality checks (Steps 8-9)  
**Dependencies**: Steps 8-9 modules  
**Execution Time**: ~3-7 minutes (smart: 2-4 min)

### Main Function

#### `execute_quality_phase()`

```bash
execute_quality_phase
```

**Description**: Orchestrates dependency validation and code quality checks.

**Steps Managed**:
- **Step 8**: Dependency Validation (package.json, requirements.txt, security)
- **Step 9**: Code Quality Validation (linting, complexity, best practices)

**Smart Execution**:
```bash
# Step 8 can be skipped if package.json unchanged
if should_skip_step_by_impact 8 "${CHANGE_IMPACT}"; then
    print_info "⚡ Step 8 skipped (smart execution - ${CHANGE_IMPACT} impact)"
    skipped_steps++
fi
```

**Returns**:
- `0`: Quality checks passed
- `1`: Quality issues found

**Execution Flow**:
```
┌─────────────────────────────────┐
│  Quality Phase (Steps 8-9)      │
└─────────────────────────────────┘
          ↓
    ┌─────────────┐
    │   Step 8    │ ← Skippable (smart execution)
    │ Dependencies│
    └─────────────┘
          ↓
    ┌─────────────┐
    │   Step 9    │
    │ Code Quality│
    └─────────────┘
          ↓
    Success / Failure
```

**Example Output**:
```
========================================
Quality Phase (Steps 8-9)
========================================

⚡ Step 8 skipped (smart execution - Low impact)

Step 9: Code Quality Validation
  ✓ Analyzing source files...
  ✓ Running linters...
  ✓ Checking complexity...
  ✓ AI-powered review...

✅ Quality phase completed in 124s (executed: 1, skipped: 1)
```

---

### Step 8: Dependency Validation

**Smart Skip Conditions**:
- Low impact changes (documentation only)
- No changes to dependency files (package.json, requirements.txt, etc.)
- Explicit skip via `--skip-step-8`

**Execution**:
```bash
if [[ $resume_from -le 8 ]] && should_execute_step 8; then
    if should_skip_step_by_impact 8 "${CHANGE_IMPACT}"; then
        # Smart skip
        print_info "⚡ Step 8 skipped (smart execution)"
        skipped_steps++
    else
        # Execute
        log_step_start 8 "Dependency Validation"
        if step8_validate_dependencies; then
            executed_steps++
            save_checkpoint 8
        else
            failed_step="Step 8"
        fi
    fi
fi
```

---

### Step 9: Code Quality Validation

**Always Executes**: No smart skip logic (code quality always relevant)

**Execution**:
```bash
if [[ -z "$failed_step" && $resume_from -le 9 ]] && should_execute_step 9; then
    log_step_start 9 "Code Quality Validation"
    if step9_validate_code_quality; then
        executed_steps++
        save_checkpoint 9
    else
        failed_step="Step 9"
    fi
fi
```

---

### Performance Characteristics

| Scenario | Step 8 | Step 9 | Total | Notes |
|----------|--------|--------|-------|-------|
| Full execution | 2-3 min | 3-4 min | 5-7 min | All checks |
| Docs-only (smart) | Skipped | 3-4 min | 3-4 min | Step 8 skipped |
| Code-only | 2-3 min | 3-4 min | 5-7 min | Both steps run |

**Future Enhancement**: Parallel execution of Steps 8-9 (estimated 25% speedup)

---

## Finalization Orchestrator

**File**: `src/workflow/orchestrators/finalization_orchestrator.sh`  
**Lines**: 93  
**Purpose**: Coordinate context analysis, git operations, and cleanup (Steps 10-12)  
**Dependencies**: Steps 10-12 modules  
**Execution Time**: ~3-5 minutes

### Main Function

#### `execute_finalization_phase()`

```bash
execute_finalization_phase
```

**Description**: Orchestrates final analysis, git commit, and documentation cleanup.

**Steps Managed**:
- **Step 10**: Context Analysis (cross-cutting concerns, architectural insights)
- **Step 11**: Git Finalization (stage, commit, push with AI-generated message)
- **Step 12**: Markdown Linting (documentation formatting validation)

**Execution Order**: Sequential (no parallelization)
- Step 10 must complete before Step 11 (context needed for commit message)
- Step 12 can run after Step 11 (validates final documentation state)

**Returns**:
- `0`: Finalization completed successfully
- `1`: Finalization failed at a step

**Special Considerations**:
```bash
# Step 11 is critical - commits all workflow changes
# Failure here means changes are staged but not committed
if ! step11_git_finalization; then
    failed_step="Step 11"
    print_error "Git finalization failed - changes are staged but not committed"
    return 1
fi
```

**Example Output**:
```
========================================
Finalization Phase (Steps 10-12)
========================================

Step 10: Context Analysis
  ✓ Aggregating step insights...
  ✓ Analyzing cross-cutting concerns...
  ✓ Generating context report...

Step 11: Git Finalization
  ✓ Analyzing repository state...
  ✓ Staging changes (42 files)...
  ✓ Generating commit message (AI)...
  ✓ Committing changes...
  ✓ Pushing to origin...

Step 12: Markdown Linting
  ✓ Finding markdown files (47 files)...
  ✓ Running markdownlint...
  ✓ No issues found

✅ Finalization phase completed in 203s (executed: 3, skipped: 0)
```

---

### Step 10: Context Analysis

**Purpose**: High-level contextual analysis before commit

**Execution**:
```bash
if [[ $resume_from -le 10 ]] && should_execute_step 10; then
    log_step_start 10 "Context Analysis"
    if step10_context_analysis; then
        executed_steps++
        save_checkpoint 10
    else
        failed_step="Step 10"
    fi
fi
```

**Output**: Feeds into Step 11 commit message generation

---

### Step 11: Git Finalization

**Purpose**: Commit and push all workflow changes

**Critical Step**: Failure here requires manual intervention

**Execution**:
```bash
if [[ -z "$failed_step" && $resume_from -le 11 ]] && should_execute_step 11; then
    log_step_start 11 "Git Finalization"
    if step11_git_finalization; then
        executed_steps++
        save_checkpoint 11
    else
        failed_step="Step 11"
        # Changes are staged but not committed - user must resolve
    fi
fi
```

**Recovery from Failure**:
```bash
# If Step 11 fails, user can:
# 1. Check staged changes
git status

# 2. Review what would be committed
git diff --cached

# 3. Manually commit
git commit -m "Manual commit after workflow"

# 4. Or reset and rerun
git reset HEAD
./execute_tests_docs_workflow.sh --resume-from 11
```

---

### Step 12: Markdown Linting

**Purpose**: Final documentation validation

**Non-critical**: Warnings don't halt workflow

**Execution**:
```bash
if [[ -z "$failed_step" && $resume_from -le 12 ]] && should_execute_step 12; then
    log_step_start 12 "Markdown Linting"
    if step12_markdown_linting; then
        executed_steps++
        save_checkpoint 12
    else
        # Markdown issues are warnings, not failures
        print_warning "Markdown linting found issues (non-critical)"
        executed_steps++
        save_checkpoint 12
    fi
fi
```

---

### Performance Characteristics

| Step | Duration | Skippable | Notes |
|------|----------|-----------|-------|
| Step 10 | 1-2 min | No | Always runs (provides context) |
| Step 11 | 1-2 min | No | Critical (commits changes) |
| Step 12 | 1-2 min | Yes (--skip-step-12) | Optional (linting only) |

**Total**: ~3-5 minutes (sequential execution)

---

## Test Phase (Inline)

**Location**: `src/workflow/execute_tests_docs_workflow.sh` (inline)  
**Lines**: ~150 (estimated within main orchestrator)  
**Purpose**: Test review, generation, and execution (Steps 5-7)  
**Execution Time**: ~5-15 minutes (smart: 0-15 min)

### Overview

The test phase is **not** in a separate orchestrator module. It's implemented inline in the main workflow orchestrator for historical reasons (predates modularization).

**Steps Managed**:
- **Step 5**: Test Review (analyze existing tests, coverage gaps)
- **Step 6**: Test Generation (AI-powered test case generation)
- **Step 7**: Test Execution (run test suite, report results)

### Execution Pattern

```bash
# In main orchestrator (execute_tests_docs_workflow.sh)

# Step 5: Test Review
if [[ $resume_from -le 5 ]] && should_execute_step 5; then
    log_step_start 5 "Test Review"
    if step5_review_existing_tests; then
        update_workflow_status "5" "✅"
        save_checkpoint 5
    else
        failed_step="Step 5"
    fi
fi

# Step 6: Test Generation
if [[ -z "$failed_step" && $resume_from -le 6 ]] && should_execute_step 6; then
    log_step_start 6 "Test Generation"
    if step6_generate_test_cases; then
        update_workflow_status "6" "✅"
        save_checkpoint 6
    else
        failed_step="Step 6"
    fi
fi

# Step 7: Test Execution
if [[ -z "$failed_step" && $resume_from -le 7 ]] && should_execute_step 7; then
    log_step_start 7 "Test Execution"
    if step7_execute_test_suite; then
        update_workflow_status "7" "✅"
        save_checkpoint 7
    else
        failed_step="Step 7"
    fi
fi
```

### Smart Execution

**Test Phase Skip Logic**:
```bash
# Skip entire test phase for Low impact (documentation-only changes)
if [[ "${SMART_EXECUTION}" == "true" && "${CHANGE_IMPACT}" == "Low" ]]; then
    print_info "⚡ Skipping test phase (smart execution - Low impact)"
    print_info "   No code changes detected"
fi
```

**Performance Impact**:
- **Docs-only changes**: Test phase skipped entirely (~10-15 min saved)
- **Code changes**: All test steps execute (~10-15 min)
- **Test-only changes**: Steps 5-7 execute (~10-15 min)

### Execution Flow

```
Test Phase (Steps 5-7)
    ↓
┌─────────────────────┐
│ Smart Execution?    │
└─────────────────────┘
    ↓           ↓
   YES         NO
    ↓           ↓
Skip Phase  Step 5: Test Review
              ↓
            Step 6: Test Generation
              ↓
            Step 7: Test Execution
```

### Dependencies

Test steps have strict sequential dependencies:
- **Step 5** → Must complete before Step 6 (provides coverage gaps)
- **Step 6** → Must complete before Step 7 (generates missing tests)
- **Step 7** → Runs last (executes all tests including generated ones)

### Future Enhancement

Consider extracting to `test_orchestrator.sh` for consistency with other phases:

```bash
# Proposed: src/workflow/orchestrators/test_orchestrator.sh
execute_test_phase() {
    print_header "Test Phase (Steps 5-7)"
    
    # Step 5: Review
    if ! step5_review_existing_tests; then
        return 1
    fi
    
    # Step 6: Generate
    if ! step6_generate_test_cases; then
        return 1
    fi
    
    # Step 7: Execute
    if ! step7_execute_test_suite; then
        return 1
    fi
    
    return 0
}
```

---

## Common Patterns

### Orchestrator Template

All orchestrators follow this structure:

```bash
#!/usr/bin/env bash

################################################################################
# [Phase Name] Orchestrator
# Version: [version]
# Purpose: [description] (Steps X-Y)
################################################################################

set -euo pipefail

execute_[phase]_phase() {
    print_header "[Phase Name] (Steps X-Y)"
    log_to_workflow "INFO" "Starting [phase] phase"
    
    local start_time=$(date +%s)
    local failed_step=""
    local executed_steps=0
    local skipped_steps=0
    local resume_from=${RESUME_FROM_STEP:-0}
    
    # Step execution with error tracking
    if [[ $resume_from -le X ]] && should_execute_step X; then
        log_step_start X "Step Name"
        if stepX_function; then
            ((executed_steps++)) || true
            save_checkpoint X
        else
            failed_step="Step X"
        fi
    fi
    
    # More steps...
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ -z "$failed_step" ]]; then
        print_success "[Phase] completed in ${duration}s (executed: $executed_steps, skipped: $skipped_steps)"
        log_to_workflow "SUCCESS" "[Phase] completed: ${duration}s"
        return 0
    else
        print_error "[Phase] failed at $failed_step"
        log_to_workflow "ERROR" "[Phase] failed at $failed_step"
        return 1
    fi
}
```

### Step Execution Pattern

Every step follows this pattern within orchestrators:

```bash
# Check if step should run (resume point, selection, smart skip)
if [[ $resume_from -le X ]] && should_execute_step X; then
    
    # Optional: Smart execution skip logic
    if [[ "${SMART_EXECUTION}" == "true" ]] && should_skip_step X; then
        print_info "⚡ Step X skipped (smart execution)"
        ((skipped_steps++)) || true
    else
        # Log step start
        log_step_start X "Step Name"
        
        # Execute step function
        if stepX_function; then
            # Success: increment counter, save checkpoint
            ((executed_steps++)) || true
            save_checkpoint X
        else
            # Failure: record failed step
            failed_step="Step X"
        fi
    fi
    
elif [[ $resume_from -le X ]]; then
    # Step not selected (--steps option)
    print_info "Skipping Step X (not selected)"
    ((skipped_steps++)) || true
else
    # Resuming from later checkpoint
    print_info "Skipping Step X (resuming from checkpoint)"
    ((skipped_steps++)) || true
fi
```

### Logging Pattern

Consistent logging across all orchestrators:

```bash
# Phase start
log_to_workflow "INFO" "Starting [phase] phase"

# Step start
log_step_start X "Step Name"

# Success
log_to_workflow "SUCCESS" "[Phase] completed: ${duration}s"
log_step_complete X "Step Name" "SUCCESS"

# Failure
log_to_workflow "ERROR" "[Phase] failed at Step X"
log_step_complete X "Step Name" "FAILED"

# Warning
log_to_workflow "WARNING" "Step X skipped - [reason]"
```

### Checkpoint Pattern

Save and resume from checkpoints:

```bash
# Save checkpoint after successful step
save_checkpoint X

# Check resume point
local resume_from=${RESUME_FROM_STEP:-0}

# Skip completed steps
if [[ $resume_from -gt X ]]; then
    print_info "Skipping Step X (resuming from checkpoint)"
fi
```

---

## Integration

### Main Orchestrator Integration

Orchestrators are sourced and called by the main workflow script:

```bash
# Source all orchestrator modules
ORCHESTRATORS_DIR="${WORKFLOW_DIR}/orchestrators"
for orch_file in "${ORCHESTRATORS_DIR}"/*.sh; do
    [[ -f "$orch_file" ]] && source "$orch_file"
done

# Execute workflow phases
execute_full_workflow() {
    local phase_failed=false
    local resume_from=${RESUME_FROM_STEP:-0}
    
    # Pre-flight
    if ! execute_preflight; then
        return 1
    fi
    
    # Validation phase (Steps 0-4)
    if [[ $resume_from -le 4 ]]; then
        if ! execute_validation_phase; then
            phase_failed=true
        fi
    fi
    
    # Test phase (Steps 5-7) - inline
    if ! $phase_failed && [[ $resume_from -le 7 ]]; then
        # ... inline test step execution ...
    fi
    
    # Quality phase (Steps 8-9)
    if ! $phase_failed && [[ $resume_from -le 9 ]]; then
        if ! execute_quality_phase; then
            phase_failed=true
        fi
    fi
    
    # Finalization phase (Steps 10-12)
    if ! $phase_failed && [[ $resume_from -le 12 ]]; then
        if ! execute_finalization_phase; then
            phase_failed=true
        fi
    fi
    
    # Handle phase failures
    if $phase_failed && [[ "${CONTINUE_ON_ERROR:-false}" != "true" ]]; then
        return 1
    fi
    
    return 0
}
```

### Dependency Graph Integration

Orchestrators respect step dependencies defined in `dependency_graph.sh`:

```bash
# Validation phase respects these dependencies
Step 0 → All steps (must run first)
Steps 1-4 → Independent (can parallelize)

# Test phase dependencies
Step 5 → Step 4 (needs structure validation)
Step 6 → Step 5 (needs coverage gaps)
Step 7 → Step 6 (needs generated tests)

# Quality phase dependencies
Steps 8-9 → Independent (can parallelize - future)

# Finalization dependencies
Step 10 → Steps 1-9 (needs all analysis)
Step 11 → All steps (final commit)
Step 12 → Step 1 (validates docs)
```

---

## Performance

### Loading Time

**Orchestrator Module Loading**: < 10ms total
- Pre-flight: ~2ms
- Validation: ~3ms
- Quality: ~1ms
- Finalization: ~1ms
- **Overhead**: Negligible

### Execution Overhead

**Phase Transition Overhead**: < 1ms per transition
- Function call overhead: ~0.1ms
- Logging overhead: ~0.5ms
- Variable access: ~0.1ms
- **Total per phase**: < 1ms (insignificant)

### Performance Comparison

**Monolithic vs Modular Architecture**:

| Metric | Monolithic (v1.0) | Modular (v3.0) | Improvement |
|--------|-------------------|----------------|-------------|
| Main script lines | 8,200 | 2,723 | 67% reduction |
| Orchestrator lines | 0 | 630 | N/A (new) |
| Loading time | N/A | < 10ms | Negligible overhead |
| Maintainability | Low | High | Significant |
| Testability | Low | High | Each phase testable |

### Optimization Opportunities

**Implemented**:
- ✅ Parallel validation (33% faster for Steps 1-4)
- ✅ Smart execution (40-85% faster depending on changes)
- ✅ Git cache (instant git queries)
- ✅ AI cache (60-80% token reduction)

**Future Enhancements**:
- 🔄 Parallel quality checks (Steps 8-9, estimated 25% speedup)
- 🔄 Test orchestrator extraction (consistency)
- 🔄 Parallel finalization (Steps 10, 12 can run in parallel)

### Performance Metrics by Phase

| Phase | Sequential | Parallel | Smart Skip | Notes |
|-------|-----------|----------|------------|-------|
| Pre-flight | 5-15s | N/A | N/A | Always runs |
| Validation | 10-15 min | 6-8 min | 2-3 min | Steps 1-4 parallelizable |
| Test | 10-15 min | N/A | 0 min | Skipped for docs-only |
| Quality | 5-7 min | N/A | 3-4 min | Step 8 skippable |
| Finalization | 3-5 min | N/A | 3-5 min | Always runs |

**Total Workflow Time**:
- **Baseline**: 23 minutes (all steps, sequential)
- **Parallel**: 15.5 minutes (33% faster)
- **Smart (docs-only)**: 2-3 minutes (85% faster)
- **Smart + Parallel**: 1.5-2 minutes (90% faster)

---

## Related Documentation

- **Step Modules API**: `docs/reference/API_STEP_MODULES.md`
- **Library Modules API**: `docs/reference/API_REFERENCE.md`
- **Main Orchestrator**: `src/workflow/execute_tests_docs_workflow.sh`
- **Orchestrators Directory**: `src/workflow/orchestrators/README.md`
- **Workflow Diagrams**: `docs/reference/workflow-diagrams.md`
- **Project Reference**: `docs/PROJECT_REFERENCE.md`

---

**Document Version**: 1.0.0  
**Workflow Version**: v3.0.0  
**Last Updated**: 2026-01-31
