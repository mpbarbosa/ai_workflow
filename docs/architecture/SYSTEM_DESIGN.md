# System Architecture - AI Workflow Automation

**Version**: v4.1.0  
**Last Updated**: 2026-02-10  
**Status**: Production

## Table of Contents

1. [Overview](#overview)
2. [Architecture Principles](#architecture-principles)
3. [System Components](#system-components)
4. [Data Flow](#data-flow)
5. [Module Architecture](#module-architecture)
6. [Integration Patterns](#integration-patterns)
7. [Performance Architecture](#performance-architecture)
8. [Security Architecture](#security-architecture)

## Overview

AI Workflow Automation is a modular, shell-based workflow system designed for validating and enhancing documentation, code, and tests with AI support. The system follows a **functional core, imperative shell** architecture with strict separation of concerns.

### Key Characteristics

- **Language**: Bash 4.0+ (shell scripts)
- **Lines of Code**: 26,562 (22,411 shell + 4,151 YAML)
- **Modules**: 112 (82 libraries + 22 steps + 4 configs + 4 orchestrators)
- **Functions**: 848 functions across library modules
- **Test Coverage**: 100% (37+ automated tests)
- **Performance**: Up to 93% faster with ML optimization

### Design Philosophy

1. **Modularity First**: Single responsibility, composable functions
2. **Configuration as Code**: YAML-based configuration, not hardcoded values
3. **AI-Augmented**: GitHub Copilot CLI integration with 17 specialized personas
4. **Performance-Conscious**: Smart execution, parallel processing, ML optimization
5. **Developer-Friendly**: Comprehensive testing, clear APIs, extensive documentation

## Architecture Principles

### 1. Functional Core / Imperative Shell

**Functional Core (Library Modules)**:
- Pure functions with no side effects
- Deterministic and testable
- Composable and reusable
- Return values, not stdout manipulation

```bash
# ✅ Good: Pure function
get_changed_files() {
    local base_ref="${1:-HEAD~1}"
    git diff --name-only "$base_ref"
}

# ❌ Bad: Side effects
get_changed_files() {
    git diff --name-only HEAD~1 > /tmp/changes.txt
    echo "Saved to /tmp/changes.txt"
}
```

**Imperative Shell (Step Modules & Orchestrators)**:
- Side effects isolated to execution layer
- I/O operations (file writes, git commands)
- User interaction and prompts
- Coordinate library functions

```bash
# Step module: orchestrates pure functions
execute_step() {
    local changes=$(get_changed_files)  # Pure
    save_to_backlog "$changes"         # Side effect
    commit_changes                      # Side effect
}
```

### 2. Single Responsibility Principle

Each module has ONE clear purpose:

- `ai_helpers.sh` - AI integration only
- `change_detection.sh` - Change analysis only
- `metrics.sh` - Metrics collection only
- `git_automation.sh` - Git operations only

### 3. Dependency Injection

Functions receive dependencies as parameters, not global state:

```bash
# ✅ Good: Dependency injection
generate_report() {
    local input_file="$1"
    local output_file="$2"
    local template="$3"
    
    # Process with injected dependencies
}

# ❌ Bad: Global dependencies
generate_report() {
    # Relies on global INPUT_FILE, OUTPUT_FILE, TEMPLATE
}
```

### 4. Configuration as Code

All configuration externalized to YAML files:

```
.workflow_core/config/
├── ai_helpers.yaml          # AI prompt templates (762 lines)
├── ai_prompts_project_kinds.yaml  # Project-specific prompts
├── paths.yaml               # Path configuration
├── project_kinds.yaml       # Project type definitions
└── workflow_steps.yaml      # Step configuration (NEW v4.0.0)
```

**Benefits**:
- No hardcoded values in scripts
- Easy customization per project
- Version-controlled configuration
- Testable with different configs

### 5. Fail-Fast Error Handling

```bash
#!/usr/bin/env bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Explicit error checking
if ! validate_prerequisites; then
    echo "ERROR: Prerequisites not met" >&2
    exit 1
fi
```

## System Components

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    CLI Entry Point                          │
│          execute_tests_docs_workflow.sh                     │
│  (Argument parsing, pre-flight, orchestration)              │
└────────────────┬────────────────────────────────────────────┘
                 │
      ┌──────────┴──────────┐
      │                     │
      ▼                     ▼
┌─────────────┐      ┌──────────────────┐
│ Orchestrators│      │ Library Modules  │
│  (4 modules) │◄─────┤  (82 modules)    │
└─────┬────────┘      └──────────────────┘
      │                      │
      │ ┌────────────────────┤
      │ │                    │
      ▼ ▼                    ▼
┌──────────────┐      ┌─────────────────┐
│ Step Modules │      │  Configuration  │
│ (22 modules) │      │   (4 YAML)      │
└──────┬───────┘      └─────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│        External Services             │
│  • GitHub Copilot CLI (AI)           │
│  • Git (version control)             │
│  • Project under validation          │
└──────────────────────────────────────┘
```

### Component Responsibilities

#### 1. CLI Entry Point (execute_tests_docs_workflow.sh)

**Lines**: 2,009  
**Purpose**: Main orchestrator and entry point

**Responsibilities**:
- Parse 20+ command-line options
- Run pre-flight checks
- Load configuration
- Orchestrate workflow execution
- Handle checkpoints and resume
- Collect and report metrics

**Key Functions**:
- `main()` - Entry point
- `parse_arguments()` - CLI parsing
- `run_workflow()` - Workflow orchestration
- `handle_checkpoint()` - Resume logic

#### 2. Orchestrators (4 modules, 630 lines)

Coordinate workflow phases without business logic.

**Modules**:
- `pre_flight.sh` (200 lines) - Pre-flight validation
- `validation.sh` (180 lines) - Validation orchestration
- `quality.sh` (150 lines) - Quality checks orchestration
- `finalization.sh` (100 lines) - Finalization orchestration

**Pattern**:
```bash
# Orchestrator: coordinates but doesn't implement
run_validation_phase() {
    init_metrics                    # From metrics.sh
    analyze_changes                 # From change_detection.sh
    
    for step in "${validation_steps[@]}"; do
        if should_skip_step "$step"; then  # From conditional_execution.sh
            continue
        fi
        execute_step "$step"          # From step_execution.sh
    done
    
    finalize_metrics                # From metrics.sh
}
```

#### 3. Library Modules (82 modules)

Provide reusable functionality with pure functions.

**Organization**:
```
src/workflow/lib/
├── Core Infrastructure (12 modules)
│   ├── ai_helpers.sh (102K)
│   ├── change_detection.sh (17K)
│   ├── metrics.sh (16K)
│   └── workflow_optimization.sh (31K)
├── Supporting Modules (70 modules)
│   ├── AI & Caching (6)
│   ├── Git Operations (5)
│   ├── File Operations (2)
│   ├── Documentation (6)
│   ├── Step Management (7)
│   ├── Optimization (11)
│   ├── Configuration (4)
│   └── Utilities (29)
└── Tests (37+ test scripts)
```

**Characteristics**:
- Pure functions (no side effects)
- Single responsibility
- Well-documented APIs
- 100% test coverage
- Composable and reusable

#### 4. Step Modules (22 modules)

Execute workflow steps with side effects.

**Organization**:
```
src/workflow/steps/
├── Preprocessing (2 steps)
│   ├── pre_analysis.sh (Step 0a)
│   └── bootstrap_documentation.sh (Step 0b)
├── Validation (5 steps)
│   ├── documentation_updates.sh (Step 1)
│   ├── documentation_analysis.sh (Step 2)
│   ├── documentation_optimize.sh (Step 2.5)
│   ├── implementation_review.sh (Step 3)
│   └── test_review.sh (Step 4)
├── Testing (3 steps)
│   ├── test_generation.sh (Step 5)
│   ├── test_dry_run.sh (Step 6)
│   └── test_execution.sh (Step 7)
├── Quality (9 steps)
│   ├── documentation_validation.sh (Step 8)
│   ├── code_quality.sh (Step 9)
│   ├── integration_test.sh (Step 10)
│   ├── final_review.sh (Step 11)
│   ├── front_end_analysis.sh (Step 11.7)
│   ├── config_review.sh (Step 12)
│   ├── deploy_check.sh (Step 13)
│   ├── security_audit.sh (Step 14)
│   └── ux_analysis.sh (Step 15)
└── Finalization (3 steps)
    ├── post_processing.sh (Step 16)
    ├── git_finalization.sh (Step 17)
    └── version_update.sh (Step 18)
```

**Structure**:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Source libraries (no business logic)
source "$(dirname "$0")/../lib/ai_helpers.sh"
source "$(dirname "$0")/../lib/colors.sh"

# Required: Validate prerequisites
validate_step() {
    [[ -d "docs" ]] || return 1
    check_copilot_available || return 1
    return 0
}

# Required: Execute step logic
execute_step() {
    echo_info "Executing step..."
    
    # Business logic here (side effects allowed)
    ai_call "persona" "prompt" "output.md"
    save_to_backlog "step_output.md"
    
    echo_success "Step completed!"
    return 0
}

# Entry point when run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_step || exit 1
    execute_step
fi
```

#### 5. Configuration (4 YAML files, 4,151 lines)

External configuration for AI, paths, and project kinds.

**Files**:

1. **ai_helpers.yaml** (762 lines)
   - 11 AI persona prompt templates
   - Language-specific conventions
   - Context-building rules

2. **ai_prompts_project_kinds.yaml** (200 lines)
   - Project-kind specific prompts
   - 6 specialized personas

3. **project_kinds.yaml** (150 lines)
   - 12+ project type definitions
   - Quality standards per type
   - Testing framework configs

4. **workflow_steps.yaml** (NEW v4.0.0)
   - Step metadata and order
   - Dependencies and stages
   - Descriptive step names

## Data Flow

### Workflow Execution Flow

```
┌──────────────────┐
│  User invokes    │
│  workflow CLI    │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────┐
│  1. Parse Arguments          │
│     • --smart-execution      │
│     • --parallel             │
│     • --steps 1,2,5          │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  2. Pre-Flight Checks        │
│     • Prerequisites          │
│     • Git status             │
│     • Configuration          │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  3. Load Configuration       │
│     • .workflow-config.yaml  │
│     • Tech stack detection   │
│     • Project kind           │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  4. Analyze Changes          │
│     • Git diff analysis      │
│     • Change categorization  │
│     • Smart execution prep   │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  5. Initialize Metrics       │
│     • Start timers           │
│     • Baseline collection    │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  6. Execute Workflow         │
│     • Load step modules      │
│     • Check dependencies     │
│     • Smart skip logic       │
│     • Parallel execution     │
│     • Checkpoint save        │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  7. Finalize & Report        │
│     • Collect metrics        │
│     • Generate reports       │
│     • Auto-commit artifacts  │
│     • Display dashboard      │
└──────────────────────────────┘
```

### Step Execution Flow

```
┌─────────────────┐
│ Load Step       │
│ Module          │
└────────┬────────┘
         │
         ▼
    ┌────────┐
    │ Check  │
    │ Deps   │◄──────────┐
    └───┬────┘           │
        │                │
        ▼                │
    ┌────────┐           │
    │ Smart  │ Yes       │
    │ Skip?  ├───────────┤
    └───┬────┘           │
        │ No             │
        ▼                │
    ┌────────┐           │
    │Validate│           │
    │ Step   │           │
    └───┬────┘           │
        │                │
        ▼                │
    ┌────────┐           │
    │Execute │           │
    │ Step   │           │
    └───┬────┘           │
        │                │
        ▼                │
    ┌────────┐           │
    │ Track  │           │
    │Metrics │           │
    └───┬────┘           │
        │                │
        ▼                │
    ┌────────┐           │
    │ Save   │           │
    │Chkpoint│           │
    └───┬────┘           │
        │                │
        ▼                │
    ┌────────┐           │
    │ Next   │           │
    │ Step   ├───────────┘
    └────────┘
```

### AI Integration Flow

```
┌──────────────┐
│ AI Request   │
└──────┬───────┘
       │
       ▼
   ┌─────────┐
   │ Check   │
   │ Cache   │
   └───┬─────┘
       │
       ├─── Hit ───► Return cached response
       │
       └─── Miss
            │
            ▼
       ┌─────────────┐
       │ Build       │
       │ Prompt      │
       │ • Persona   │
       │ • Context   │
       │ • Language  │
       └──────┬──────┘
              │
              ▼
       ┌─────────────┐
       │ Call GitHub │
       │ Copilot CLI │
       └──────┬──────┘
              │
              ▼
       ┌─────────────┐
       │ Validate    │
       │ Response    │
       └──────┬──────┘
              │
              ▼
       ┌─────────────┐
       │ Cache       │
       │ Response    │
       │ (24h TTL)   │
       └──────┬──────┘
              │
              ▼
       ┌─────────────┐
       │ Return to   │
       │ Caller      │
       └─────────────┘
```

## Module Architecture

### Layered Architecture

```
┌─────────────────────────────────────────────────────┐
│              Presentation Layer                     │
│  • CLI Interface (execute_tests_docs_workflow.sh)   │
│  • Argument Parsing                                 │
│  • User Prompts & Output                            │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│           Orchestration Layer                       │
│  • Orchestrators (pre_flight, validation, etc.)     │
│  • Workflow Coordination                            │
│  • Phase Management                                 │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│             Business Logic Layer                    │
│  • Step Modules (22 modules)                        │
│  • Workflow Steps Execution                         │
│  • Side Effects (I/O, Git, AI)                      │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│             Library Layer                           │
│  • Pure Functions (82 modules)                      │
│  • Reusable Utilities                               │
│  • No Side Effects                                  │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│           Infrastructure Layer                      │
│  • File System                                      │
│  • Git Commands                                     │
│  • GitHub Copilot CLI                               │
│  • External Tools                                   │
└─────────────────────────────────────────────────────┘
```

### Module Dependencies

**Dependency Rules**:
1. Lower layers never depend on upper layers
2. Library modules have no external dependencies (except utils)
3. Step modules depend on library modules only
4. Orchestrators coordinate but don't implement logic
5. Circular dependencies are prohibited

**Example Dependency Chain**:
```
execute_tests_docs_workflow.sh
    └─► orchestrators/validation.sh
            └─► steps/documentation_updates.sh
                    └─► lib/ai_helpers.sh
                            └─► lib/colors.sh
                            └─► lib/ai_cache.sh
                                    └─► lib/jq_wrapper.sh
```

### Module Communication

**Shared State Management**:

```bash
# ✅ Good: Explicit state passing
analyze_changes() {
    local change_data=$(detect_changes)
    echo "$change_data"
}

# Use the returned data
changes=$(analyze_changes)
process_changes "$changes"
```

```bash
# ❌ Bad: Global state
CHANGES=""  # Global variable

analyze_changes() {
    CHANGES=$(detect_changes)  # Modifies global
}

analyze_changes
process_changes  # Relies on global CHANGES
```

**Error Propagation**:

```bash
# ✅ Good: Return codes
function_that_can_fail() {
    [[ -f "required.txt" ]] || return 1
    # ... logic ...
    return 0
}

# Caller checks return code
if ! function_that_can_fail; then
    echo "ERROR: Function failed" >&2
    exit 1
fi
```

## Integration Patterns

### Pattern 1: Library Module Integration

```bash
#!/usr/bin/env bash
set -euo pipefail

# Calculate script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required modules
source "$SCRIPT_DIR/src/workflow/lib/ai_helpers.sh"
source "$SCRIPT_DIR/src/workflow/lib/change_detection.sh"
source "$SCRIPT_DIR/src/workflow/lib/metrics.sh"

# Use library functions
main() {
    init_metrics
    analyze_changes
    
    if has_code_changes; then
        # AI integration
        ai_call "code_reviewer" "Review changes" "review.md"
    fi
    
    finalize_metrics
}

main
```

### Pattern 2: Custom Step Module

```bash
#!/usr/bin/env bash
set -euo pipefail

# Required structure for step modules
validate_step() {
    # Prerequisites check
    [[ -d "src" ]] || return 1
    return 0
}

execute_step() {
    # Step logic
    echo "Executing custom step..."
    return 0
}

# Entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_step || exit 1
    execute_step
fi
```

**Register in workflow_steps.yaml**:
```yaml
- id: custom_step
  name: "Custom Analysis"
  file: custom_step.sh
  category: validation
  dependencies: [documentation_updates]
  stage: 2
```

### Pattern 3: Git Hooks Integration

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
source "$REPO_ROOT/src/workflow/lib/pre_commit_hooks.sh"

if ! run_pre_commit_check; then
    echo "Pre-commit validation failed!"
    exit 1
fi

exit 0
```

### Pattern 4: CI/CD Integration

```yaml
# .github/workflows/workflow.yml
name: AI Workflow

on: [push, pull_request]

jobs:
  workflow:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for change detection
      
      - name: Setup Environment
        run: |
          # Install prerequisites
          sudo apt-get update
          sudo apt-get install -y jq bc
      
      - name: Run Workflow
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          ./src/workflow/execute_tests_docs_workflow.sh \
            --auto \
            --smart-execution \
            --parallel \
            --ml-optimize
      
      - name: Upload Artifacts
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: workflow-artifacts
          path: |
            src/workflow/backlog/
            src/workflow/metrics/
            src/workflow/logs/
```

## Performance Architecture

### Optimization Strategies

#### 1. Smart Execution (40-85% faster)

**Mechanism**: Skip steps based on change analysis

```bash
# Change detection
analyze_changes
    ├─► Detect code changes
    ├─► Detect doc changes
    └─► Detect test changes

# Smart skipping
should_skip_step(step_id)
    ├─► Check change requirements
    ├─► Check dependencies
    └─► Return skip decision

# Example: Skip test generation if no code changes
if ! has_code_changes; then
    skip_step 5  # Test generation
fi
```

**Performance Impact**:
- Documentation-only: 85% faster (23 min → 3.5 min)
- Code changes: 40% faster (23 min → 14 min)

#### 2. Parallel Execution (33% faster)

**Mechanism**: Run independent steps simultaneously

```bash
# Dependency graph analysis
analyze_dependencies()
    └─► Identify independent steps

# Parallel execution
run_parallel_steps([3, 4, 5])
    ├─► Fork step 3 in background
    ├─► Fork step 4 in background
    ├─► Fork step 5 in background
    └─► Wait for all to complete

# Example: Run independent validation steps
run_parallel [
    documentation_validation,
    code_quality,
    security_audit
]
```

**Constraints**:
- Maximum 4 parallel jobs (configurable)
- I/O-bound operations benefit most
- CPU-bound operations may not improve

#### 3. AI Response Caching (60-80% token reduction)

**Mechanism**: Cache AI responses with TTL

```bash
# Cache key generation
cache_key = SHA256(persona + prompt)

# Cache lookup
if cache_hit(cache_key):
    return cached_response
    
# Cache miss: call AI
response = ai_call(persona, prompt)
cache_store(cache_key, response, ttl=24h)

return response
```

**Performance Impact**:
- 60-80% reduction in AI tokens
- Near-instant responses for cached queries
- Automatic cleanup every 24 hours

#### 4. ML Optimization (15-30% additional improvement)

**Mechanism**: Predict step durations and optimize execution order

```bash
# Training data collection
for each run:
    collect_metrics(step_durations, skip_decisions, changes)

# Prediction
predict_step_duration(step_id, changes)
    └─► ML model (requires 10+ historical runs)

# Optimization
reorder_steps(predicted_durations)
    └─► Longest steps first for parallel execution
```

**Requirements**:
- 10+ historical workflow runs
- Metrics collection enabled
- ML data directory configured

#### 5. Multi-Stage Pipeline (80%+ complete in 2 stages)

**Mechanism**: Progressive validation with early exit

```bash
# Stage 1: Core (essential steps)
run_stage_1()
    ├─► Documentation validation
    ├─► Code review
    └─► Basic tests

# Exit if Stage 1 fails
if stage_1_failed:
    exit 1

# Stage 2: Extended (additional validation)
run_stage_2()
    ├─► Integration tests
    ├─► Security audit
    └─► UX analysis

# Stage 3: Finalization (cleanup only)
run_stage_3()
    ├─► Git finalization
    └─► Version update
```

**Performance Impact**:
- 80%+ of runs complete in 2 stages
- Early failure detection
- Reduced resource usage

### Performance Metrics

**Tracking**:
```json
{
  "total_duration": "12m 34s",
  "steps_completed": 15,
  "steps_skipped": 8,
  "ai_tokens_used": 12450,
  "ai_cache_hit_rate": 0.72,
  "parallel_jobs": 4,
  "improvement_over_baseline": "78%"
}
```

## Security Architecture

### Threat Model

**Assets**:
- Source code under validation
- AI responses (may contain sensitive info)
- Git credentials
- Configuration files

**Threats**:
1. Code injection via user input
2. Credential leakage in logs
3. Unauthorized access to AI responses
4. Malicious step modules

### Security Controls

#### 1. Input Validation

```bash
# Sanitize user input
sanitize_input() {
    local input="$1"
    # Remove dangerous characters
    echo "$input" | tr -d '\n\r\t' | sed 's/[;&|`$]//g'
}

# Validate file paths
validate_path() {
    local path="$1"
    # Prevent directory traversal
    [[ "$path" =~ \.\./  ]] && return 1
    [[ -e "$path" ]] || return 1
    return 0
}
```

#### 2. Credential Management

```bash
# Never log sensitive data
log_safe() {
    local message="$1"
    # Redact tokens and passwords
    echo "$message" | sed 's/token=[^[:space:]]*/token=REDACTED/g'
}

# Use environment variables
export GH_TOKEN="${GH_TOKEN:-}"  # From environment only
```

#### 3. Secure Defaults

```bash
# Restrictive file permissions
umask 0077  # New files: 600, new dirs: 700

# Safe temp file creation
temp_file=$(mktemp -t workflow.XXXXXX)
trap "rm -f '$temp_file'" EXIT
```

#### 4. Code Signing (Future)

- Sign step modules with GPG
- Verify signatures before execution
- Prevent unauthorized module injection

### Audit Logging

```bash
# Audit trail for sensitive operations
audit_log() {
    local action="$1"
    local user="${USER:-unknown}"
    local timestamp=$(date -Iseconds)
    
    echo "$timestamp | $user | $action" >> "$AUDIT_LOG"
}

# Example usage
audit_log "AI_CALL: documentation_specialist"
audit_log "GIT_COMMIT: Auto-commit workflow artifacts"
```

## Further Reading

- **[Architecture Decision Records](adr/)** - Design decisions and rationale
- **[Module API Reference](../api/README.md)** - Module documentation
- **[Performance Guide](../ML_OPTIMIZATION_GUIDE.md)** - Optimization strategies
- **[Testing Guide](../TESTING_BEST_PRACTICES.md)** - Testing patterns

---

**Last Updated**: 2026-02-10 | **Version**: v4.1.0
