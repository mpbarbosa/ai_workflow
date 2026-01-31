# Data Flow Documentation - AI Workflow Automation

**Version**: v3.0.0  
**Last Updated**: 2026-01-31

This document provides a comprehensive overview of how data flows through the AI Workflow Automation system, from inputs to outputs, including state management, caching strategies, and inter-component communication.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Input Sources](#input-sources)
- [State Management](#state-management)
- [Data Transformations](#data-transformations)
- [Inter-Component Communication](#inter-component-communication)
- [Output Artifacts](#output-artifacts)
- [Caching Strategy](#caching-strategy)
- [Data Flow Scenarios](#data-flow-scenarios)
- [Performance Optimization](#performance-optimization)

---

## Overview

The AI Workflow Automation system processes data through a **multi-phase pipeline** with sophisticated caching and state management. Data flows from input sources (git repository, configuration files, user input) through transformation phases (analysis, validation, testing, quality checks) to produce output artifacts (documentation, tests, reports, commits).

### Key Characteristics

- **Immutable Inputs**: Source data (git state, config) captured once and cached
- **Incremental Processing**: Each step builds on previous step outputs
- **Persistent State**: Checkpoints enable resume after failures
- **Multi-Level Caching**: Git cache, AI cache, analysis cache for performance
- **Structured Outputs**: Consistent artifact format across all steps

### Data Flow Layers

```
┌─────────────────────────────────────────────────────────────┐
│                        Input Layer                          │
│  Git Repo • Config Files • User Input • Environment Vars    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Cache Layer                            │
│  Git Cache • AI Cache • Analysis Cache • Step Cache         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   Processing Layer                          │
│  Orchestrators • Steps • Library Modules • AI Integration   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      State Layer                            │
│  Checkpoints • Metrics • Workflow Status • Temp Files       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     Output Layer                            │
│  Backlog • Logs • Summaries • Git Commits • Reports         │
└─────────────────────────────────────────────────────────────┘
```

---

## Architecture

### Data Flow Architecture Pattern

The system uses a **Layered Pipeline Architecture** with these principles:

1. **Capture Once, Use Many**: Input data captured once and cached
2. **Transform Incrementally**: Each step transforms and enriches data
3. **Checkpoint Frequently**: State saved at step boundaries
4. **Output Consistently**: Structured artifacts at each step

### Component Communication Model

```
Main Orchestrator
    ├── Input Layer
    │   └── Captures: git state, config, CLI args
    ├── Cache Layer
    │   └── Provides: Fast access to repeated data
    ├── Orchestrator Layer
    │   ├── Pre-Flight → Validation → Test → Quality → Finalization
    │   └── Each phase: reads inputs, writes outputs
    ├── Step Layer
    │   ├── Step modules execute logic
    │   └── Generate: reports, recommendations, artifacts
    └── Output Layer
        └── Persists: backlog, logs, summaries, commits
```

---

## Input Sources

### 1. Git Repository (Primary Source)

**Captured At**: Pre-flight initialization  
**Module**: `git_cache.sh`  
**Frequency**: Once per workflow run (refreshed in Step 11)

**Data Captured**:
```bash
# Git state
GIT_CACHE[current_branch]     # Current git branch
GIT_CACHE[commits_ahead]      # Commits ahead of remote
GIT_CACHE[commits_behind]     # Commits behind remote

# File change counts
GIT_CACHE[modified_count]     # Modified files
GIT_CACHE[staged_count]       # Staged files
GIT_CACHE[untracked_count]    # Untracked files
GIT_CACHE[deleted_count]      # Deleted files
GIT_CACHE[total_changes]      # Total changed files

# File type counts
GIT_CACHE[docs_modified]      # Documentation files changed
GIT_CACHE[tests_modified]     # Test files changed
GIT_CACHE[scripts_modified]   # Script files changed
GIT_CACHE[code_modified]      # Code files changed

# Special flags
GIT_CACHE[deps_modified]      # package.json/requirements.txt changed
GIT_CACHE[is_git_repo]        # Repository validation flag
```

**Raw Outputs**:
```bash
GIT_STATUS_OUTPUT             # git status --porcelain
GIT_STATUS_SHORT_OUTPUT       # git status --short
GIT_DIFF_STAT_OUTPUT          # git diff --stat
GIT_DIFF_SUMMARY_OUTPUT       # git diff --shortstat
GIT_DIFF_FILES_OUTPUT         # git diff --name-only (filtered)
```

**Performance**: Single batch capture (~1-2 seconds), instant subsequent access

**Usage Example**:
```bash
# Initialize cache (pre-flight)
init_git_cache

# Access cached data (any step)
modified=$(get_git_modified_count)  # Instant, no git subprocess
branch=$(get_git_current_branch)    # Cached value
```

---

### 2. Configuration Files

**Source Files**:
- `.workflow-config.yaml` (Project-specific configuration)
- `.workflow_core/config/paths.yaml` (Path mappings)
- `.workflow_core/config/ai_helpers.yaml` (AI prompt templates)
- `.workflow_core/config/project_kinds.yaml` (Project type definitions)
- `.workflow_core/config/ai_prompts_project_kinds.yaml` (Project-specific prompts)

**Configuration Data Flow**:

```
Project Configuration (.workflow-config.yaml)
    ↓
┌─────────────────────────────────────────────┐
│ project:                                    │
│   kind: nodejs_api                          │
│   name: my-api                              │
│ tech_stack:                                 │
│   primary_language: javascript              │
│   test_framework: jest                      │
│   test_command: npm test                    │
│ workflow:                                   │
│   skip_steps: [13]                          │
└─────────────────────────────────────────────┘
    ↓
Parsed and exported as environment variables:
    PROJECT_KIND="nodejs_api"
    PRIMARY_LANGUAGE="javascript"
    TEST_FRAMEWORK="jest"
    TEST_COMMAND="npm test"
    SKIP_STEPS="13"
```

**Module**: `config.sh`, `project_kind_config.sh`  
**Loaded At**: Pre-flight initialization  
**Scope**: Global (environment variables)

---

### 3. Command-Line Arguments

**Module**: `argument_parser.sh`  
**Parsed At**: Script initialization (before pre-flight)

**Arguments Captured**:
```bash
# Execution mode
AUTO_MODE=false              # --auto flag
DRY_RUN=false                # --dry-run flag
INTERACTIVE_MODE=true        # Default (no --auto)

# Performance optimizations
SMART_EXECUTION=false        # --smart-execution flag
PARALLEL_EXECUTION=false     # --parallel flag
USE_AI_CACHE=true            # Default (--no-ai-cache to disable)
ML_OPTIMIZE=false            # --ml-optimize flag

# Workflow control
RESUME_FROM_STEP=0           # --resume-from N
SELECTED_STEPS=""            # --steps 1,2,3
CONTINUE_ON_ERROR=false      # --continue-on-error flag

# Target project
TARGET_PROJECT_ROOT=""       # --target /path/to/project
PROJECT_ROOT=""              # Current dir or --target value

# Feature flags (v3.0.0+)
AUTO_COMMIT=false            # --auto-commit flag
MULTI_STAGE=false            # --multi-stage flag
INSTALL_HOOKS=false          # --install-hooks flag
```

**Data Flow**:
```
CLI Args → argument_parser.sh → Environment Variables → All Modules
```

---

### 4. Environment Variables

**Pre-defined Variables** (affect behavior):
```bash
# Execution control
WORKFLOW_RUN_ID              # Unique run identifier (auto-generated)
SCRIPT_VERSION               # Workflow version (from script)
WORKFLOW_HOME                # AI workflow installation directory

# Paths
PROJECT_ROOT                 # Target project root
SRC_DIR                      # Source code directory
BACKLOG_DIR                  # Backlog base directory
LOGS_DIR                     # Logs base directory

# Optimization flags
USE_AI_CACHE=true           # Enable AI response caching
USE_ANALYSIS_CACHE=true     # Enable analysis caching
COPILOT_API_TIMEOUT=60      # AI call timeout (seconds)

# Debug
VERBOSE=false               # Verbose logging
DEBUG=false                 # Debug mode
```

**Example Override**:
```bash
# Disable AI caching for testing
USE_AI_CACHE=false ./execute_tests_docs_workflow.sh

# Increase timeout for slow AI responses
COPILOT_API_TIMEOUT=180 ./execute_tests_docs_workflow.sh
```

---

## State Management

### 1. Checkpoints (Resume Capability)

**Location**: `src/workflow/.checkpoints/workflow_TIMESTAMP.checkpoint`  
**Format**: Bash-sourceable key-value pairs  
**Module**: `step_execution.sh` (save_checkpoint, load_checkpoint)

**Checkpoint Data Structure**:
```bash
# Workflow metadata
WORKFLOW_RUN_ID="workflow_20260131_020000"
LAST_COMPLETED_STEP="5"
TIMESTAMP="2026-01-31 02:05:30"
CHANGE_IMPACT="Medium"
GIT_BRANCH="main"
GIT_COMMIT="abc123def456..."

# Step status (per step)
STEP_0_STATUS="COMPLETED"
STEP_1_STATUS="COMPLETED"
STEP_2_STATUS="COMPLETED"
STEP_3_STATUS="COMPLETED"
STEP_4_STATUS="COMPLETED"
STEP_5_STATUS="COMPLETED"
STEP_6_STATUS="NOT_EXECUTED"
STEP_7_STATUS="NOT_EXECUTED"
# ... through Step 15
```

**Usage Flow**:
```
Workflow Start
    ↓
Check for existing checkpoint
    ↓ (found)
Load checkpoint → Resume from LAST_COMPLETED_STEP + 1
    ↓ (not found)
Start from Step 0
    ↓
Execute steps
    ↓
Save checkpoint after each step
    ↓
Workflow Complete → Delete checkpoint
```

**Resume Example**:
```bash
# Step 5 fails
./execute_tests_docs_workflow.sh
# ERROR: Step 5 failed

# Resume from checkpoint
./execute_tests_docs_workflow.sh
# INFO: Found checkpoint at step 5, resuming from step 6
```

---

### 2. Workflow Status Tracking

**Storage**: In-memory associative array  
**Module**: `step_execution.sh`  
**Scope**: Single workflow run

**Status Tracking**:
```bash
declare -A WORKFLOW_STATUS

# Step status values
WORKFLOW_STATUS[0]="✅"      # Completed
WORKFLOW_STATUS[1]="✅"      # Completed
WORKFLOW_STATUS[2]="❌"      # Failed
WORKFLOW_STATUS[3]="⏭️"      # Skipped
WORKFLOW_STATUS[4]="🔄"      # In Progress
WORKFLOW_STATUS[5]=""        # Not Started

# Update status
update_workflow_status "2" "✅"  # Mark step 2 complete
update_workflow_status "3" "❌"  # Mark step 3 failed
```

**Display**:
```bash
# Progress display (printed during execution)
Step 0: ✅  Pre-Analysis
Step 1: ✅  Documentation Updates
Step 2: 🔄  Consistency Analysis (in progress)
Step 3: ⏭️   Script References (skipped)
```

---

### 3. Metrics Tracking

**Location**: `src/workflow/metrics/`  
**Files**:
- `current_run.json` - Current execution metrics
- `history.jsonl` - Historical metrics (JSON Lines)
- `summary.md` - Human-readable summary

**Module**: `metrics.sh`

**Metrics Data Structure**:

```json
{
  "workflow_run_id": "workflow_20260131_020000",
  "start_time": "2026-01-31T02:00:00-05:00",
  "start_epoch": 1738299600,
  "end_time": "2026-01-31T02:23:15-05:00",
  "end_epoch": 1738300995,
  "duration_seconds": 1395,
  "version": "v3.0.0",
  "mode": "auto",
  "success": true,
  "steps": {
    "0": {
      "name": "Pre-Analysis",
      "start_time": "2026-01-31T02:00:05-05:00",
      "end_time": "2026-01-31T02:00:12-05:00",
      "duration_seconds": 7,
      "status": "completed"
    },
    "1": {
      "name": "Documentation Updates",
      "start_time": "2026-01-31T02:00:12-05:00",
      "end_time": "2026-01-31T02:03:45-05:00",
      "duration_seconds": 213,
      "status": "completed",
      "ai_calls": 1,
      "cache_hits": 0
    }
  },
  "summary": {
    "total_steps": 15,
    "completed": 15,
    "failed": 0,
    "skipped": 0,
    "ai_calls": 8,
    "cache_hits": 5,
    "cache_hit_rate": 0.625
  }
}
```

**Metrics Collection Flow**:
```
init_metrics()              # Pre-flight
    ↓
record_step_start(N)        # Before each step
    ↓
record_step_end(N)          # After each step
    ↓
finalize_metrics()          # Workflow complete
    ↓
Append to history.jsonl     # Persistent history
```

---

### 4. Temporary File Management

**Module**: `cleanup_handlers.sh`  
**Mechanism**: Bash trap handlers

**Temp File Tracking**:
```bash
# Array of temp files to cleanup
TEMP_FILES=()

# Register temp file
temp_file=$(mktemp)
TEMP_FILES+=("$temp_file")

# Automatic cleanup on exit
cleanup_temp_files() {
    for file in "${TEMP_FILES[@]}"; do
        rm -f "$file" 2>/dev/null || true
    done
}

trap cleanup_temp_files EXIT
```

**Temp File Locations**:
- `/tmp/workflow_*` - System temp files
- `src/workflow/logs/workflow_*/temp/` - Workflow-specific temp files

---

## Data Transformations

### Phase 1: Input Capture (Pre-Flight)

**Input**: Raw repository, configuration, CLI arguments  
**Output**: Cached state, initialized directories, global variables

**Data Flow**:
```
Git Repository
    ↓
init_git_cache() → GIT_CACHE (associative array)
    ↓
analyze_change_impact() → CHANGE_IMPACT (Low/Medium/High/Full)
    ↓
detect_tech_stack() → PRIMARY_LANGUAGE, TEST_FRAMEWORK
    ↓
detect_project_kind() → PROJECT_KIND, PROJECT_KIND_CONFIDENCE
    ↓
Global Environment (exported variables)
```

**Transformations**:
1. **Git State** → Structured cache (from subprocess output to hash map)
2. **File Changes** → Change Impact (from file list to impact level)
3. **Project Files** → Tech Stack (from package.json/requirements.txt to language/framework)
4. **Project Structure** → Project Kind (from directory layout to project type)

---

### Phase 2: Validation (Steps 0-4)

**Input**: Git cache, project files, configuration  
**Output**: Documentation reports, validation results

**Step 0: Pre-Analysis**
```
GIT_CACHE + PROJECT_KIND
    ↓
step0_analyze_changes()
    ↓
Exports:
    ANALYSIS_COMMITS=5
    ANALYSIS_MODIFIED=12
    CHANGE_SCOPE_DOCS=3
    CHANGE_SCOPE_TESTS=4
    CHANGE_SCOPE_SRC=5
    ↓
Test Infrastructure Validation (v3.0.0)
    smoke_test_infrastructure()
    ↓
Output: Analysis summary in backlog/
```

**Step 1: Documentation Updates**
```
Change Summary + Documentation Files
    ↓
discover_docs_step1()
    ↓
Documentation File List
    ↓
build_documentation_prompt_step1()
    ↓
AI Prompt (with project context)
    ↓
ai_call("documentation_specialist", prompt)
    ↓
AI Response (cached 24h)
    ↓
process_ai_response_step1()
    ↓
Output: step_01_documentation_analysis.md
```

**Data Enrichment**:
- Initial: File paths
- After Step 1: + AI recommendations
- After Step 2: + Cross-reference validation
- After Step 3: + Script reference validation
- After Step 4: + Structure validation

---

### Phase 3: Testing (Steps 5-7)

**Input**: Source files, existing tests, test framework config  
**Output**: Test reports, generated tests, test results

**Data Flow**:
```
Source Files + Test Files
    ↓
Step 5: discover_test_files_step5()
    ↓
Test Inventory + Coverage Data
    ↓
Step 6: identify_untested_code_step6()
    ↓
Coverage Gaps
    ↓
AI: generate_test_stub_step6()
    ↓
Generated Test Files
    ↓
Step 7: execute_test_suite()
    ↓
Test Results (pass/fail/skip counts)
    ↓
Output: Test execution report
```

**Transformation Chain**:
1. **Source Files** → Test Coverage Map (coverage analysis)
2. **Coverage Gaps** → Test Recommendations (AI generation)
3. **Test Files** → Test Results (execution)
4. **Test Results** → Quality Metrics (metrics collection)

---

### Phase 4: Quality (Steps 8-9)

**Input**: Dependencies, source code, linter configs  
**Output**: Dependency report, code quality report

**Step 8: Dependencies**
```
package.json / requirements.txt
    ↓
parse_dependencies()
    ↓
Dependency List
    ↓
check_vulnerabilities() (if npm audit available)
    ↓
Security Report
    ↓
identify_outdated()
    ↓
Update Recommendations
    ↓
Output: step_08_dependency_analysis.md
```

**Step 9: Code Quality**
```
Source Files
    ↓
run_linters() (ESLint, Pylint, etc.)
    ↓
Lint Issues
    +
analyze_complexity()
    ↓
Complexity Metrics
    ↓
AI: build_quality_review_prompt()
    ↓
Code Quality Report
    ↓
Output: step_09_code_quality_analysis.md
```

---

### Phase 5: Finalization (Steps 10-12)

**Input**: All previous step outputs  
**Output**: Context report, git commit, markdown lint report

**Step 10: Context Analysis**
```
Step 1-9 Summaries
    ↓
aggregate_step_insights()
    ↓
Combined Insights
    ↓
analyze_cross_cutting_concerns()
    ↓
Architectural Analysis
    ↓
AI: context_analyst persona
    ↓
Output: step_10_context_analysis.md
```

**Step 11: Git Finalization**
```
All Workflow Changes
    ↓
git add -A (atomic staging)
    ↓
Staged Changes
    ↓
AI: generate_commit_message() (if --ai-batch)
    ↓
Commit Message
    ↓
git commit
    ↓
git push
    ↓
Output: Committed and pushed changes
```

**Step 12: Markdown Linting**
```
Markdown Files
    ↓
run_markdownlint()
    ↓
Lint Issues
    ↓
validate_markdown_structure()
    ↓
Structure Issues
    ↓
Output: step_12_markdown_lint.md
```

---

## Inter-Component Communication

### 1. Orchestrator → Step Communication

**Mechanism**: Function calls with return codes

```bash
# Orchestrator calls step
execute_validation_phase() {
    # ...
    if step1_update_documentation; then
        save_checkpoint 1        # Success
    else
        failed_step="Step 1"    # Failure
        return 1
    fi
}
```

**Data Passed**:
- Global variables (GIT_CACHE, PROJECT_KIND, etc.)
- Environment variables
- Temp file paths

**Return Values**:
- `0`: Success
- `1`: Failure
- Side effects: Files written, variables exported

---

### 2. Step → Library Module Communication

**Mechanism**: Function calls, shared state

```bash
# Step calls library function
step1_update_documentation() {
    # Use git cache
    local modified_count=$(get_git_modified_count)
    
    # Use AI helpers
    ai_call "documentation_specialist" "$prompt" "$output"
    
    # Use file operations
    save_step_issues "1" "Documentation" "$issues"
}
```

**Data Flow**:
- Read from: Global variables, cache
- Write to: Temp files, backlog, logs
- Return: Status codes, stdout output

---

### 3. AI Integration Data Flow

**Module**: `ai_helpers.sh`, `ai_cache.sh`

```
Step needs AI analysis
    ↓
build_prompt_for_step()
    ↓
Prompt Text + Context
    ↓
generate_cache_key(prompt)
    ↓
Cache Key (SHA256)
    ↓
check_cache(cache_key)
    ↓ (cache miss)
ai_call(persona, prompt, output_file)
    ↓
Copilot CLI Execution
    ↓
AI Response
    ↓
save_to_cache(cache_key, response)
    ↓ (future calls)
get_from_cache(cache_key) → Instant response
```

**Cache Hit Rate**: 60-80% (24-hour TTL)

---

### 4. Parallel Execution Communication

**Mechanism**: Background processes + file-based IPC

```bash
# Validation orchestrator parallel execution
execute_parallel_validation() {
    temp_dir="${LOGS_RUN_DIR}/parallel_validation"
    mkdir -p "$temp_dir"
    
    # Launch step 1 in background
    (
        step1_update_documentation
        echo $? > "${temp_dir}/step1_exit.txt"
    ) &
    
    # Launch steps 2-4 similarly
    # ...
    
    # Wait for all
    wait
    
    # Collect results
    step1_exit=$(cat "${temp_dir}/step1_exit.txt")
    # ...
}
```

**IPC Method**: Temp files for exit codes  
**Synchronization**: `wait` command

---

## Output Artifacts

### 1. Backlog (Execution Reports)

**Location**: `src/workflow/backlog/workflow_TIMESTAMP/`  
**Format**: Markdown files  
**Module**: `backlog.sh`

**Structure**:
```
backlog/workflow_20260131_020000/
├── step_00_pre_analysis.md
├── step_01_documentation_analysis.md
├── step_02_consistency_analysis.md
├── step_03_script_validation.md
├── step_04_directory_validation.md
├── step_05_test_review.md
├── step_06_test_generation.md
├── step_07_test_execution.md
├── step_08_dependency_analysis.md
├── step_09_code_quality.md
├── step_10_context_analysis.md
├── step_11_git_finalization.md
├── step_12_markdown_lint.md
├── step_13_prompt_engineering.md (ai_workflow only)
├── step_14_ux_analysis.md (UI projects only)
└── step_15_version_update.md
```

**Content Structure**:
```markdown
# Step N: [Step Name]

**Status**: ✅ Completed / ❌ Failed / ⏭️ Skipped  
**Duration**: Xs  
**Timestamp**: YYYY-MM-DD HH:MM:SS

## Summary
[Brief summary of what was done]

## Details
[Detailed findings, issues, recommendations]

## Issues Found
- Issue 1
- Issue 2

## Recommendations
1. Recommendation 1
2. Recommendation 2
```

---

### 2. Logs (Execution Traces)

**Location**: `src/workflow/logs/workflow_TIMESTAMP/`  
**Format**: Plain text log files  
**Module**: `utils.sh` (log_to_workflow)

**Structure**:
```
logs/workflow_20260131_020000/
├── workflow_execution.log       # Main log
├── step_01_documentation.log    # Step-specific logs
├── step_02_consistency.log
├── ...
└── parallel_validation/         # Temp dir for parallel execution
    ├── step1_exit.txt
    ├── step2_exit.txt
    └── ...
```

**Log Format**:
```
[2026-01-31 02:00:00] [INFO] Starting validation phase
[2026-01-31 02:00:05] [INFO] Step 1: Documentation Updates - starting
[2026-01-31 02:03:45] [SUCCESS] Step 1: Documentation Updates - completed (213s)
[2026-01-31 02:03:45] [INFO] Step 2: Consistency Analysis - starting
[2026-01-31 02:05:30] [ERROR] Step 2: Consistency Analysis - failed
```

---

### 3. Summaries (AI-Generated)

**Location**: `src/workflow/summaries/workflow_TIMESTAMP/`  
**Format**: Markdown files  
**Module**: `summary.sh`

**Purpose**: Human-readable AI analysis summaries

**Example**:
```markdown
# Workflow Summary - 2026-01-31

## Overall Assessment
✅ Workflow completed successfully in 23 minutes

## Key Changes
- Updated 5 documentation files
- Generated 3 new test cases
- Fixed 2 code quality issues

## AI Recommendations
1. Consider refactoring large functions in user service
2. Add error handling to API endpoints
3. Update README with new features

## Next Steps
- Review generated tests
- Address code quality issues
- Update CHANGELOG
```

---

### 4. Git Commits

**Created By**: Step 11 (Git Finalization)  
**Module**: `step_11_git.sh`

**Commit Message Structure**:
```
type(scope): subject

Detailed description of changes made by workflow

Changes:
- Modified files: 12
- Added files: 3
- Deleted files: 1

Documentation:
- Updated README.md
- Updated API documentation
- Fixed broken links

Tests:
- Generated 3 new test cases
- All tests passing (42/42)

Quality:
- Resolved 2 linter issues
- Improved code complexity

AI Analysis: 8 AI calls (5 cached)
Performance: 23 minutes (smart execution)
```

**Commit Types**:
- `feat`: New features or code
- `fix`: Bug fixes
- `docs`: Documentation only
- `test`: Test changes
- `refactor`: Code refactoring
- `chore`: Build, dependencies, config

---

### 5. Metrics Reports

**Location**: `src/workflow/metrics/`  
**Format**: JSON, JSONL, Markdown  
**Module**: `metrics.sh`

**Files Generated**:
1. **current_run.json** - Current execution metrics (JSON)
2. **history.jsonl** - Append-only historical metrics (JSON Lines)
3. **summary.md** - Human-readable performance summary

**Summary Example**:
```markdown
# Workflow Performance Summary

## Latest Run (workflow_20260131_020000)
- **Duration**: 23 minutes 15 seconds
- **Mode**: auto
- **Status**: ✅ Success
- **Steps**: 15 completed, 0 failed, 0 skipped

## Performance Breakdown
| Step | Duration | Status |
|------|----------|--------|
| 0: Pre-Analysis | 7s | ✅ |
| 1: Documentation | 213s | ✅ |
| 2: Consistency | 145s | ✅ |
| ... | ... | ... |

## AI Usage
- Total AI Calls: 8
- Cache Hits: 5
- Cache Hit Rate: 62.5%
- Token Usage: ~15,000 tokens (estimated)

## Historical Comparison
- Average duration (last 10 runs): 21.5 minutes
- This run: 23 minutes (+7% slower)
- Fastest run: 18 minutes
- Slowest run: 28 minutes
```

---

## Caching Strategy

### 1. Git Cache (Performance)

**Purpose**: Eliminate redundant git subprocess calls  
**Module**: `git_cache.sh`  
**Lifespan**: Single workflow run  
**Storage**: In-memory (bash associative array)

**Performance Impact**: 25-30% faster (eliminates 30+ git calls)

**Cache Strategy**:
```bash
# Initialize once (pre-flight)
init_git_cache()  # Batch capture all git state

# Access many times (any step)
get_git_modified_count()    # Instant (no subprocess)
get_git_current_branch()    # Instant
get_git_diff_summary()      # Instant

# Refresh when needed (Step 11 before commit)
refresh_git_cache()  # Re-capture current state
```

**Invalidation**: Manual refresh only (no automatic expiry)

---

### 2. AI Response Cache (Token Reduction)

**Purpose**: Reduce token usage and improve speed  
**Module**: `ai_cache.sh`  
**Lifespan**: 24 hours (TTL)  
**Storage**: Filesystem (`.ai_cache/`)

**Performance Impact**: 60-80% token reduction, instant cached responses

**Cache Strategy**:
```bash
# Generate cache key from prompt
cache_key=$(generate_cache_key "$prompt" "$context")
# SHA256 hash: abc123def456...

# Check cache
if check_cache "$cache_key"; then
    # Cache hit (< 24 hours old)
    response=$(get_from_cache "$cache_key")
else
    # Cache miss - call AI
    ai_call "persona" "$prompt" "$output"
    # Save to cache
    save_to_cache "$cache_key" "$output"
fi
```

**Cache Structure**:
```
.ai_cache/
├── index.json                    # Cache metadata
├── abc123def456...789.txt        # Cached response
├── abc123def456...789.meta       # Metadata (timestamp, TTL)
└── def789abc456...123.txt        # Another cached response
```

**Cleanup**: Automatic every 24 hours (removes expired entries)

---

### 3. Analysis Cache (Incremental Analysis)

**Purpose**: Skip re-analysis of unchanged files  
**Module**: `analysis_cache.sh`  
**Lifespan**: Persistent (until file changes)  
**Storage**: Filesystem (`.analysis_cache/`)

**Cache Strategy**:
```bash
# Check if file changed
if has_file_changed "src/api/users.js"; then
    # File changed - re-analyze
    analyze_file "src/api/users.js"
    cache_analysis_result "src/api/users.js" "$result"
else
    # File unchanged - use cached analysis
    result=$(get_cached_analysis "src/api/users.js")
fi
```

**Invalidation**: Content hash comparison (SHA256)

---

### 4. Step Validation Cache (Smart Execution)

**Purpose**: Remember which steps were validated  
**Module**: `step_validation_cache.sh`  
**Lifespan**: Single workflow run  
**Storage**: In-memory

**Usage**:
```bash
# Check if step should run
if should_execute_step 5; then
    step5_review_existing_tests
else
    print_info "Step 5 skipped (smart execution)"
fi
```

**Cache Data**:
- Step relevance (required/optional/skip)
- Skip conditions met (docs-only, no changes, etc.)
- User selection (--steps option)

---

## Data Flow Scenarios

### Scenario 1: Documentation-Only Changes

**Input**: 5 markdown files changed, no code changes  
**Change Impact**: Low

**Data Flow**:
```
Git Cache: docs_modified=5, code_modified=0
    ↓
analyze_change_impact() → CHANGE_IMPACT="Low"
    ↓
Smart Execution: Skip Steps 5-7 (testing)
    ↓
Step 0: Pre-Analysis ✅
Step 1: Documentation Updates ✅ (AI call)
Step 2: Consistency Analysis ✅
Step 3: Script References ✅
Step 4: Directory Structure ✅
Steps 5-7: ⏭️ Skipped (no code changes)
Step 8: Dependencies ⏭️ Skipped (no package.json change)
Step 9: Code Quality ✅
Step 10-12: ✅
    ↓
Output: Documentation reports, markdown lint
Total Time: ~3-5 minutes (85% faster than baseline)
```

**Optimizations Applied**:
- Smart execution skips testing (Steps 5-7)
- Step 8 skipped (no dependency changes)
- AI cache likely hits on Step 1 (similar doc changes)

---

### Scenario 2: Code Changes with Tests

**Input**: 8 code files changed, 4 test files changed  
**Change Impact**: High

**Data Flow**:
```
Git Cache: code_modified=8, tests_modified=4
    ↓
analyze_change_impact() → CHANGE_IMPACT="High"
    ↓
Full Workflow Execution
    ↓
Step 0: Pre-Analysis ✅
    Exports: CHANGE_SCOPE_SRC=8, CHANGE_SCOPE_TESTS=4
Step 1-4: Documentation & Validation ✅
    ↓
Step 5: Test Review ✅
    Discovers: 42 test files
    Coverage: 85%
    ↓
Step 6: Test Generation ✅
    Identifies: 3 coverage gaps
    Generates: 3 new test stubs
    ↓
Step 7: Test Execution ✅
    Runs: 45 tests (42 existing + 3 new)
    Results: 45 passed, 0 failed
    ↓
Steps 8-12: Quality & Finalization ✅
    ↓
Step 11: Git Commit
    Commits: code files + test files + generated tests
    Message: "feat(api): add user validation logic"
    ↓
Output: Complete workflow artifacts
Total Time: ~23 minutes (baseline)
```

**No Optimizations**: High impact requires full execution

---

### Scenario 3: Resume After Failure

**Input**: Workflow failed at Step 5 (test review)  
**Checkpoint**: Last completed step = 4

**Data Flow**:
```
Workflow Start
    ↓
Check for checkpoint
    ↓ (found)
Load checkpoint: .checkpoints/workflow_20260131_020000.checkpoint
    LAST_COMPLETED_STEP="4"
    ↓
Set: RESUME_FROM_STEP=5
    ↓
Skip Steps 0-4 (already completed)
    ↓
Resume at Step 5
    Fix issue (e.g., install test framework)
    ↓
Execute Steps 5-15
    ↓
Complete workflow
    ↓
Delete checkpoint (success)
```

**Saved Time**: ~10 minutes (skipped Steps 0-4)

---

### Scenario 4: Parallel Execution

**Input**: Documentation changes, parallel mode enabled  
**Flags**: `--parallel --smart-execution`

**Data Flow**:
```
Pre-Flight ✅
    ↓
Step 0: Pre-Analysis ✅
    ↓
Validation Phase - Parallel Execution
    ┌─────────────────┐
    │ Steps 1-4       │
    │ Launch in       │
    │ parallel        │
    └─────────────────┘
         ↓  ↓  ↓  ↓
    Step 1  Step 2  Step 3  Step 4
      ✅      ✅      ✅      ✅
         ↓  ↓  ↓  ↓
    Wait for all to complete
         ↓
    Collect exit codes
         ↓
    All passed ✅
    ↓
Test Phase (skipped - docs only)
Quality Phase ✅
Finalization Phase ✅
    ↓
Total Time: ~5 minutes (parallel) vs ~10 minutes (sequential)
Speedup: 50% faster
```

**Concurrency**: 4 steps running simultaneously

---

### Scenario 5: AI Cache Hit

**Input**: Similar documentation changes as yesterday  
**Cache**: Previous AI responses still valid (< 24 hours)

**Data Flow**:
```
Step 1: Documentation Updates
    ↓
build_documentation_prompt_step1()
    prompt = "Analyze recent documentation changes..."
    ↓
generate_cache_key(prompt)
    cache_key = "abc123def456..."
    ↓
check_cache(cache_key)
    ↓ (cache hit!)
get_from_cache(cache_key)
    ↓ (instant response)
Cached AI Response (< 1 second)
    ↓
process_ai_response_step1()
    ↓
Output: Documentation analysis
    ↓
Savings: 
    - No AI call (no tokens used)
    - No wait time (3-5 minutes saved)
    - Same quality output
```

**Cache Hit Rate**: 60-80% in typical usage

---

## Performance Optimization

### Data Flow Optimizations

1. **Batch Capture** (Git Cache)
   - Before: 30+ git subprocess calls (30-60 seconds)
   - After: 1 batch capture + instant access (1-2 seconds)
   - **Improvement**: 25-30% faster

2. **Response Caching** (AI Cache)
   - Before: Every AI call waits 30-60 seconds
   - After: 60-80% cache hits (< 1 second)
   - **Improvement**: 60-80% token reduction

3. **Smart Execution** (Change Detection)
   - Before: All 15 steps always execute
   - After: Skip irrelevant steps (docs-only: skip testing)
   - **Improvement**: 40-85% faster depending on changes

4. **Parallel Execution** (Validation Phase)
   - Before: Steps 1-4 sequential (10-15 minutes)
   - After: Steps 1-4 parallel (6-8 minutes)
   - **Improvement**: 33% faster

### Combined Optimization Impact

| Scenario | Baseline | Optimized | Improvement |
|----------|----------|-----------|-------------|
| Docs-only | 23 min | 2-3 min | 85% faster |
| Code changes | 23 min | 14 min | 40% faster |
| Full changes | 23 min | 15.5 min | 33% faster |
| With ML (v2.7+) | 23 min | 10-11 min | 52-57% faster |

### Data Size Management

**Cache Size Limits**:
- AI Cache: 100 MB max (auto-cleanup)
- Git Cache: In-memory only (< 1 MB)
- Metrics: Unlimited (append-only history)

**Cleanup Strategy**:
- AI Cache: Remove entries > 24 hours old
- Temp Files: Auto-cleanup on exit (trap handlers)
- Checkpoints: Delete after successful completion
- Logs: User-managed (rotate manually)

---

## Related Documentation

- **Step Modules API**: `docs/reference/API_STEP_MODULES.md`
- **Orchestrators API**: `docs/reference/API_ORCHESTRATORS.md`
- **Library Modules API**: `docs/reference/API_REFERENCE.md`
- **Workflow Diagrams**: `docs/reference/workflow-diagrams.md`
- **Performance Guide**: `docs/ML_OPTIMIZATION_GUIDE.md`
- **Project Reference**: `docs/PROJECT_REFERENCE.md`

---

**Document Version**: 1.0.0  
**Workflow Version**: v3.0.0  
**Last Updated**: 2026-01-31
