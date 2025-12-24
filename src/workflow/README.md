# Workflow Automation Module Documentation

**Version:** 2.3.1 (Critical Fixes & Checkpoint Control) | 2.4.0 (Orchestrator Architecture) 🚧
**Status:** Smart Execution, Parallel Processing, AI Caching, Checkpoint Resume ✅
**Last Updated:** 2025-12-20
**Modules:** 62 total (45 libraries + 4 orchestrators + 13 test suites) + 14 steps + 3 utilities
**Total Lines:** ~32,976 total (~28,782 shell + ~4,194 YAML)
**Documentation:** 100% coverage (all 62 scripts documented) ✅
**Tests:** 50 total tests (37 unit + 13 integration), 100% pass rate ✅
**Performance:** Up to 90% faster with optimization flags

> 📊 See [PROJECT_STATISTICS.md](../../docs/archive/PROJECT_STATISTICS.md) for official counts.

---

## Overview

The Tests & Documentation Workflow Automation script has been modularized to improve maintainability, testability, and reusability. The refactoring splits the original monolithic script into focused modules with single responsibilities.

---

## Module Architecture

### Directory Structure

```
src/workflow/
├── execute_tests_docs_workflow.sh   # Main orchestrator (1,884 lines)
├── lib/                              # Core library modules ✅ COMPLETE (40 modules)
│   ├── config.sh                     # Configuration and constants (57 lines)
│   ├── colors.sh                     # ANSI color definitions (20 lines)
│   ├── utils.sh                      # Utility functions (233 lines)
│   ├── git_cache.sh                  # Git state caching (146 lines)
│   ├── validation.sh                 # Pre-flight checks (280 lines)
│   ├── backlog.sh                    # Backlog tracking (91 lines)
│   ├── summary.sh                    # Summary generation (134 lines)
│   ├── ai_helpers.sh                 # AI integration (14 functional personas) Project-aware
│   ├── ai_helpers.yaml               # AI prompt templates (1,520 lines) ⭐ Project-aware personas
│   ├── ai_cache.sh                   # AI response caching (352 lines) 🚀 NEW v2.3.0
│   ├── session_manager.sh            # Bash session management (376 lines)
│   ├── file_operations.sh            # File resilience operations (496 lines)
│   ├── performance.sh                # Performance optimization (563 lines)
│   ├── step_execution.sh             # Step execution patterns (247 lines)
│   ├── metrics.sh                    # Performance tracking (511 lines) 🚀 v2.2.0
│   ├── change_detection.sh           # Change analysis (448 lines) 🚀 v2.2.0
│   ├── dependency_graph.sh           # Dependency visualization (429 lines) 🚀 v2.2.0
│   ├── workflow_optimization.sh      # Smart & parallel execution (572 lines) 🚀 v2.3.0
│   ├── health_check.sh               # System validation (464 lines)
│   ├── metrics_validation.sh         # Metrics validation utilities (310 lines)
│   ├── project_kind_config.sh        # Project kind configuration (757 lines)
│   ├── project_kind_detection.sh     # Project kind detection (384 lines)
│   └── tech_stack.sh                 # Tech stack detection (1,606 lines)
└── steps/                            # Step modules ✅ COMPLETE (15 modules)
    ├── step_00_analyze.sh            # Pre-workflow change analysis (113 lines)
    ├── step_01_documentation.sh      # Documentation updates (425 lines)
    ├── step_02_consistency.sh        # Consistency analysis (179 lines) 🔄 REFACTORED
    ├── step_03_script_refs.sh        # Script reference validation (320 lines) 🔄 REFACTORED
    ├── step_04_directory.sh          # Directory structure validation (376 lines)
    ├── step_05_test_review.sh        # Test review (133 lines)
    ├── step_06_test_gen.sh           # Test generation (118 lines)
    ├── step_07_test_exec.sh          # Test execution (325 lines)
    ├── step_08_dependencies.sh       # Dependency validation (469 lines)
    ├── step_09_code_quality.sh       # Code quality validation (294 lines)
    ├── step_10_context.sh            # Context analysis (346 lines)
    ├── step_11_git.sh                # Git finalization (367 lines) ✅
    ├── step_12_markdown_lint.sh      # Markdown linting (219 lines) ✨
    ├── step_13_prompt_engineer.sh    # Prompt engineering (509 lines) ✨
    └── step_14_ux_analysis.sh        # UX/accessibility analysis (604 lines) ✨
```

### Additional Scripts & Orchestrators

#### Version 2.4.0 Orchestrators (630 lines total)
```
orchestrators/
├── pre_flight.sh                    # Pre-flight orchestration (227 lines) 🚀 v2.4.0
├── validation_orchestrator.sh       # Validation phase orchestration (228 lines) 🚀 v2.4.0
├── finalization_orchestrator.sh     # Finalization phase orchestration (93 lines) 🚀 v2.4.0
└── quality_orchestrator.sh          # Quality phase orchestration (82 lines) 🚀 v2.4.0
```

**Purpose**: Phase-based orchestration pattern for v2.4.0 architecture
- **pre_flight.sh**: Pre-execution validation and setup
- **validation_orchestrator.sh**: Coordinates validation steps (0-4)
- **quality_orchestrator.sh**: Coordinates quality checks (5-10)
- **finalization_orchestrator.sh**: Coordinates finalization (11-13)

#### New Library Modules (2,094 lines total)
```
lib/
├── argument_parser.sh               # CLI argument parsing (231 lines) 🆕
├── config_wizard.sh                 # Interactive config wizard (532 lines) 🆕 v2.3.1
├── edit_operations.sh               # Advanced edit operations (427 lines) 🆕
├── step_adaptation.sh               # Project-aware step adaptation (493 lines) 🆕
└── doc_template_validator.sh        # Documentation template validation (411 lines) 🆕
```

**Purpose**: Enhanced functionality and user experience
- **argument_parser.sh**: Robust command-line argument parsing with validation
- **config_wizard.sh**: Interactive setup for `.workflow-config.yaml`
- **edit_operations.sh**: Safe file editing with atomic operations
- **step_adaptation.sh**: Dynamic step behavior based on project kind
- **doc_template_validator.sh**: Template consistency validation

#### Test Infrastructure (5,122 lines total)
```
lib/
├── test_ai_cache.sh                 # AI cache tests (466 lines)
├── test_ai_helpers_phase4.sh        # AI helpers tests (412 lines)
├── test_get_project_kind.sh         # Project detection tests (272 lines)
├── test_phase5_enhancements.sh      # Phase 5 tests (341 lines)
├── test_phase5_final_steps.sh       # Phase 5 final tests (318 lines)
├── test_project_kind_config.sh      # Config tests (404 lines)
├── test_project_kind_detection.sh   # Detection tests (403 lines)
├── test_project_kind_integration.sh # Integration tests (431 lines)
├── test_project_kind_prompts.sh     # Prompt tests (313 lines)
├── test_project_kind_validation.sh  # Validation tests (375 lines)
├── test_step_adaptation.sh          # Adaptation tests (406 lines)
├── test_tech_stack_phase3.sh        # Tech stack tests (361 lines)
└── test_workflow_optimization.sh    # Optimization tests (420 lines)
```

**Coverage**: 13 test suites ensuring 100% functionality
- AI integration and caching
- Project kind detection and configuration
- Step adaptation and optimization
- Tech stack detection
- All Phase 4-5 enhancements

#### Utility Scripts (984 lines total)
```
src/workflow/
├── execute_tests_docs_workflow_v2.4.sh  # v2.4.0 orchestrator-based (481 lines) 🚀
├── benchmark_performance.sh             # Performance benchmarking (243 lines)
└── example_session_manager.sh           # Session manager examples (260 lines)
```

**Purpose**: Development, testing, and documentation
- **execute_tests_docs_workflow_v2.4.sh**: Next-generation orchestrator architecture
- **benchmark_performance.sh**: Measure and compare workflow performance
- **example_session_manager.sh**: Interactive session management examples

---

## Version 2.3.1 Features

### 🆕 Checkpoint Resume Control (v2.3.1)
**Flag:** `--no-resume`  
**Default:** Checkpoint resume enabled

Force fresh workflow start:
- Use `--no-resume` to ignore saved checkpoints
- Starts from Step 0 regardless of checkpoint state
- Useful for debugging and testing
- Default behavior: Resume from last completed step

### 🆕 Tech Stack Configuration (v2.3.1)
**Flags:** `--init-config`, `--show-tech-stack`, `--config-file FILE`

Interactive configuration and tech stack detection:
- `--init-config`: Run interactive wizard to create `.workflow-config.yaml`
- `--show-tech-stack`: Display detected tech stack and configuration
- `--config-file FILE`: Use custom config file instead of `.workflow-config.yaml`
- Auto-detection for Bash, Node.js, Python, and other ecosystems
- Adaptive test execution supporting Jest, BATS, pytest frameworks
- Config-based directory validation (source, test, docs directories)

### 🐛 Critical Bug Fixes (v2.3.1)
- Fixed checkpoint file Bash syntax errors (proper variable quoting)
- Fixed metrics calculation arithmetic errors in historical stats
- Resolved "command not found" errors in checkpoint files
- Fixed Step 7 test execution directory navigation (uses TARGET_DIR correctly)
- Added safe log file directory checks to prevent early execution errors
- Enhanced error handling in metrics calculations

## Version 2.3.0 Features (Phase 2 Complete)

### 🚀 Smart Execution
**Flag:** `--smart-execution`  
**Performance:** 40-85% faster for simple changes

Automatically analyzes git changes and skips unnecessary steps based on change type:
- **Documentation-only changes**: Skips test steps (5, 6, 7)
- **Code changes**: Full pipeline execution
- **Configuration changes**: Skips test generation

### 🚀 Parallel Execution
**Flag:** `--parallel`  
**Performance:** 33% faster (465 seconds saved)

Executes independent validation steps simultaneously:
- Steps 2-4 run in parallel (consistency, script refs, directory validation)
- Automatic dependency coordination
- Error handling for parallel tasks

### 🚀 AI Response Caching
**Flag:** `--no-ai-cache` (to disable; enabled by default)  
**Performance:** 60-80% token usage reduction

Intelligent caching system for AI responses:
- 24-hour TTL with automatic cleanup
- SHA256-based cache keys
- Hit/miss metrics tracking
- Transparent integration (no code changes needed)

### 📊 Integrated Metrics
**Automatic:** Always active

Real-time performance tracking:
- Step timing and success rates
- Historical trend analysis (JSON Lines format)
- Automatic summary at workflow completion
- Metrics available in `metrics/` directory

### 📈 Dependency Visualization
**Flag:** `--show-graph`

Interactive dependency graph:
- Mermaid diagram generation
- Execution phases and time estimates
- Parallelization opportunities
- Saves to backlog directory

### 🎯 Target Project Support
**Flag:** `--target PATH`  
**Default:** Current directory

Run workflow on any project:
- Default: Runs on current directory
- Explicit: Use `--target` to specify path
- No file copying required
- Maintains separate execution artifacts

### Combined Performance

| Change Type | Baseline | Smart | Parallel | Combined |
|-------------|----------|-------|----------|----------|
| Docs Only   | 23 min   | 3.5 min | 15.5 min | 2.3 min (90% faster) |
| Code Changes| 23 min   | 14 min  | 15.5 min | 10 min (57% faster) |
| Full Changes| 23 min   | 23 min  | 15.5 min | 15.5 min (33% faster) |

---

## Completed Modules (All Phases)

### Phase 1 Modules (v2.0.0)

### 1. `lib/config.sh` (56 lines)
**Purpose:** Central configuration and constants

**Exports:**
- `SCRIPT_VERSION`, `SCRIPT_NAME`
- `PROJECT_ROOT`, `SRC_DIR`, `BACKLOG_DIR`, `SUMMARIES_DIR`, `LOGS_DIR`, `DOCS_DIR`
- `WORKFLOW_RUN_ID`, `BACKLOG_RUN_DIR`, `SUMMARIES_RUN_DIR`, `LOGS_RUN_DIR`
- `TOTAL_STEPS`, `DRY_RUN`, `INTERACTIVE_MODE`, `AUTO_MODE`
- `ANALYSIS_COMMITS`, `ANALYSIS_MODIFIED`, `CHANGE_SCOPE`

**Usage:**
```bash
source "$(dirname "$0")/lib/config.sh"
echo "Running $SCRIPT_NAME v$SCRIPT_VERSION"
```

### 2. `lib/colors.sh` (17 lines)
**Purpose:** ANSI color code definitions

**Exports:**
- `RED`, `GREEN`, `YELLOW`, `BLUE`, `CYAN`, `MAGENTA`, `NC`

**Usage:**
```bash
source "$(dirname "$0")/lib/colors.sh"
echo -e "${GREEN}Success!${NC}"
```

### 3. `lib/utils.sh` (224 lines)
**Purpose:** Common utility functions

**Functions:**
- `print_header()`, `print_success()`, `print_error()`, `print_warning()`, `print_info()`, `print_step()`
- `save_step_issues()`, `save_step_summary()`
- `confirm_action()`
- `cleanup()`
- `update_workflow_status()`, `show_progress()`

**Usage:**
```bash
source "$(dirname "$0")/lib/utils.sh"
print_success "Operation completed"
if confirm_action "Continue?" "y"; then
    # Do something
fi
```

### 4. `lib/git_cache.sh` (142 lines)
**Purpose:** Git state caching for performance optimization

**Functions:**
- `init_git_cache()` - Initialize cache once at workflow start
- `get_git_modified_count()`, `get_git_staged_count()`, `get_git_untracked_count()`, etc.
- `get_git_current_branch()`, `get_git_commits_ahead()`, `get_git_commits_behind()`
- `get_git_status_output()`, `get_git_diff_stat_output()`, `get_git_diff_files_output()`
- `is_deps_modified()`, `is_git_repo()`

**Usage:**
```bash
source "$(dirname "$0")/lib/git_cache.sh"
init_git_cache
modified_count=$(get_git_modified_count)
current_branch=$(get_git_current_branch)
```

### 5. `lib/validation.sh` (280 lines)
**Purpose:** Pre-flight checks and dependency validation

**Functions:**
- `check_prerequisites()` - Validates project structure, git, Node.js, npm
- `validate_dependencies()` - Ensures node_modules and Jest are available

**Usage:**
```bash
source "$(dirname "$0")/lib/validation.sh"
check_prerequisites
validate_dependencies
```

### Phase 2 Modules (v2.0.0)

### 6. `lib/backlog.sh` (90 lines)
**Purpose:** Workflow summary and backlog report generation

**Functions:**
- `create_workflow_summary()` - Creates comprehensive workflow execution summary

**Usage:**
```bash
source "$(dirname "$0")/lib/backlog.sh"
create_workflow_summary  # Called at end of workflow
```

### 7. `lib/summary.sh` (134 lines)
**Purpose:** Step-level summary generation helpers

**Functions:**
- `determine_step_status()` - Returns ✅, ⚠️, or ❌ based on findings
- `format_step_summary()` - Formats summary with consistent structure
- `create_progress_summary()` - One-line summary for progress tracking
- `generate_step_stats()` - Statistics from step execution
- `aggregate_summaries()` - Aggregates results from multiple steps

**Usage:**
```bash
source "$(dirname "$0")/lib/summary.sh"
status=$(determine_step_status 0 2)  # 0 errors, 2 warnings -> ⚠️
stats=$(generate_step_stats 10 2 3)  # 10 files, 2 issues, 3 warnings
```

### 8. `lib/ai_helpers.sh` (2,359 lines) + `ai_helpers.yaml` (1,520 lines) ⭐ ENHANCED
**Purpose:** AI prompt templates and Copilot CLI integration with externalized YAML configuration

**Architecture Enhancement (v2.0.0):**
- ✅ **YAML Configuration Support**: Externalized AI prompt templates for maintainability
- ✅ **Intelligent Fallback**: Automatic fallback to hardcoded prompts if YAML unavailable
- ✅ **Template Variables**: Dynamic placeholder replacement in YAML templates
- ✅ **Multi-Section Parsing**: Supports multiple prompt types in single YAML file

**Functions:**
- `is_copilot_available()` - Check if Copilot CLI is installed
- `validate_copilot_cli()` - Validate and provide user feedback
- `build_ai_prompt()` - Build structured prompts (role, task, standards)
- `build_doc_analysis_prompt()` - Documentation analysis prompt (YAML-backed)
- `build_consistency_prompt()` - Consistency checking prompt (YAML-backed)
- `build_test_strategy_prompt()` - Test strategy prompt (YAML-backed)
- `build_quality_prompt()` - Code quality validation prompt (YAML-backed)
- `build_issue_extraction_prompt()` - Issue extraction from logs (YAML-backed)
- `execute_copilot_prompt()` - Execute prompt with error handling
- `trigger_ai_step()` - Trigger AI-enhanced step with confirmation

**YAML Configuration Format:**
```yaml
doc_analysis_prompt:
  role: "Senior technical documentation specialist..."
  task_template: |
    Based on changes to: {changed_files}
    Update documentation: {doc_files}
  approach: |
    - Analyze git diff
    - Update affected sections
```

**Usage:**
```bash
source "$(dirname "$0")/lib/ai_helpers.sh"
if is_copilot_available; then
    # Automatically uses YAML config if available, falls back to hardcoded
    prompt=$(build_doc_analysis_prompt "$changed_files" "$docs")
    execute_copilot_prompt "$prompt"
fi
```

### 9. `lib/session_manager.sh` (376 lines) ✨ NEW
**Purpose:** Bash session management with unique session IDs, timeout handling, and cleanup

**Functions:**
- `generate_session_id()` - Generate unique session identifier
- `register_session()`, `unregister_session()` - Session tracking
- `execute_with_session()` - Execute command with session management
- `wait_for_session()`, `kill_session()` - Async process management
- `cleanup_all_sessions()` - Cleanup handler for all active sessions
- `list_active_sessions()` - Display active sessions
- `get_recommended_timeout()` - Recommended timeouts for operations
- `execute_npm_command()`, `execute_git_command()` - Convenience wrappers
- `enhanced_workflow_cleanup()` - Integration with workflow cleanup

**Execution Modes:**
- **Sync:** Waits for completion, enforces timeout, immediate cleanup
- **Async:** Background process with PID tracking, manual cleanup
- **Detached:** Independent process, no tracking

**Usage:**
```bash
source "$(dirname "$0")/lib/session_manager.sh"

# Sync execution with recommended timeout
timeout=$(get_recommended_timeout "npm_test")
execute_with_session "07" "test_suite" "npm test" "$timeout" "sync"

# Async execution for long builds
execute_with_session "08" "build" "npm run build" 300 "async"
wait_for_session "$session_id" 300

# Convenience wrappers
execute_npm_command "07" "test" "--coverage"
execute_git_command "11" "status --short"

# Register cleanup handler
trap cleanup_all_sessions EXIT INT TERM
```

**Documentation:** See [SESSION_MANAGER.md](lib/SESSION_MANAGER.md) for comprehensive API reference and usage patterns.

**Tests:** `test_session_manager.sh` (22 tests, 100% pass rate)

### 10. `lib/file_operations.sh` (496 lines) ✨ NEW
**Purpose:** File operations with resilience, pre-flight checks, and fallback strategies

**Functions:**
- `check_file_exists()` - Pre-flight file existence check with strategy selection
- `get_safe_filename()` - Generate safe alternative filenames (timestamp/increment)
- `safe_create_file()` - Create file with automatic fallback handling
- `safe_create_markdown()` - Create markdown file with standard header
- `ensure_directory()` - Create directory with validation
- `retry_operation()` - Retry with exponential backoff
- `atomic_update_file()` - Atomic file updates via temp files
- `acquire_file_lock()`, `release_file_lock()` - File locking with stale detection
- `resilient_save_step_issues()` - Workflow-integrated issue saving
- `resilient_save_step_summary()` - Workflow-integrated summary saving

**Fallback Strategies:**
- **fail:** Abort on conflict (safest, default)
- **overwrite:** Replace existing file
- **append_timestamp:** Add `_YYYYMMDD_HHMMSS` suffix
- **increment:** Add counter (`_1`, `_2`, etc.)
- **prompt:** Ask user interactively

**Usage:**
```bash
source "$(dirname "$0")/lib/file_operations.sh"

# Safe file creation with timestamp fallback
actual_file=$(safe_create_file "$target" "$content" "append_timestamp")

# Workflow integration
resilient_save_step_issues "07" "Test" "$issues" "append_timestamp"

# Retry with backoff
retry_operation 3 "curl -f $API_URL"

# Atomic update with locking
acquire_file_lock "/tmp/config.lock" 30
atomic_update_file "$config_file" "$new_config" "overwrite"
release_file_lock "/tmp/config.lock"
```

**Documentation:** See [WORKFLOW_RESILIENCE_SUMMARY.md](WORKFLOW_RESILIENCE_SUMMARY.md) for complete API and migration guide.

**Tests:** `test_file_operations.sh` (19 tests, 100% pass rate)

---

### 11. `lib/step_execution.sh` (247 lines) ✨ NEW

**Purpose:** Shared execution patterns for workflow steps (DRY principle)

**Functions:**
- `execute_phase2_ai_analysis()` - Handles Phase 2 AI analysis workflow
- `extract_and_save_issues()` - Standardizes issue extraction from Copilot logs
- `save_step_results()` - Unified step result handling and backlog generation

**Key Features:**
- **DRY Principle:** Eliminates duplicated AI analysis logic across steps
- **Smart Triggering:** Auto/interactive/optional execution modes based on issue detection
- **Consistent Workflow:** Standardized Copilot CLI integration, logging, and user feedback
- **Issue Extraction:** Unified multi-line input handling and backlog saving
- **Error Handling:** Comprehensive validation of Copilot execution and log file creation

**Usage:**
```bash
source "$(dirname "$0")/lib/step_execution.sh"

# Execute AI analysis with automatic issue-based triggering
execute_phase2_ai_analysis \
    "$copilot_prompt" \
    "2" \
    "consistency_analysis" \
    "Consistency_Analysis" \
    "$issues_found" \
    "documentation consistency analysis" \
    "No broken references found" \
    "Did Copilot identify issues?"

# Save step results with unified formatting
save_step_results \
    "2" \
    "Consistency_Analysis" \
    "$issues_found" \
    "No broken references found" \
    "Found ${issues_found} broken references" \
    "$broken_refs_file" \
    "$doc_count"
```

**Impact:**
- **Code Reduction:** Refactored and reorganized from step_02 and step_03
- **step_02_consistency.sh:** 382 → 216 lines (-43%)
- **step_03_script_refs.sh:** 320 lines (current)
- **Maintainability:** Centralized AI workflow logic for easier updates
- **Consistency:** Guaranteed identical behavior across all workflow steps

---

### 12. `lib/performance.sh` (563 lines) ✨

**Purpose:** Performance optimization through parallel execution, caching, and batch operations

**Functions:**
- `parallel_execute()` - Execute commands in parallel with job control
- `parallel_workflow_steps()` - Execute workflow steps in parallel (safe subset)
- `fast_find()`, `fast_find_modified()` - Optimized file search operations
- `fast_grep()`, `fast_grep_count()` - Parallel grep with performance optimization
- `cache_get()`, `cache_set()`, `cache_clear()` - Simple key-value caching
- `memoize()` - Function result caching
- `batch_git_commands()` - Batch git operations for efficiency
- `batch_process()` - Generic batch processing with parallel execution
- `batch_read_files()`, `batch_read_files_limited()` - Batch file reading operations
- `batch_command_outputs()` - Capture outputs from multiple commands
- `fast_file_count()`, `fast_dir_size()` - Optimized file system operations
- `time_command()`, `profile_section()` - Performance profiling utilities

**Usage:**
```bash
source "$(dirname "$0")/lib/performance.sh"

# Parallel command execution
parallel_execute 4 "npm test" "npm run lint" "npm run build"

# Batch file operations
batch_read_files file1.txt file2.txt file3.txt

# Caching for expensive operations
if ! result=$(cache_get "expensive_operation"); then
    result=$(expensive_computation)
    cache_set "expensive_operation" "$result"
fi

# Performance profiling
time_command "npm test" "Test Suite Execution"
```

**Documentation:** See [PERFORMANCE_OPTIMIZATION_SUMMARY.md](PERFORMANCE_OPTIMIZATION_SUMMARY.md) for implementation details and benchmarks.

**Tests:** `lib/test_batch_operations.sh` (6 tests, 100% pass rate)

---

## YAML Configuration System (v2.0.0)

### Overview

The workflow now supports externalized AI prompt templates via `lib/ai_helpers.yaml`, providing:

✅ **Separation of Concerns**: Prompt templates separated from logic
✅ **Maintainability**: Easy updates without touching shell code
✅ **Version Control**: Track prompt evolution independently
✅ **Intelligent Fallback**: Automatic fallback to hardcoded prompts if YAML unavailable

### Configuration File Structure

**Location:** `src/workflow/lib/ai_helpers.yaml` (1,520 lines)

**Format:**
```yaml
doc_analysis_prompt:
  role: "Senior technical documentation specialist..."
  task_template: |
    Based on changes to: {changed_files}
    Update documentation: {doc_files}
    ...
  approach: |
    - Analyze git diff
    - Update affected sections
    ...

consistency_prompt:
  role: "Documentation specialist..."
  task_template: |
    Analyze: {files_to_check}
    ...
  approach: |
    - Read documentation
    - Identify inconsistencies
    ...
```

### Supported Prompt Types

1. **doc_analysis_prompt** - Documentation update prompts (Step 1)
2. **consistency_prompt** - Consistency analysis prompts (Step 2)
3. **test_strategy_prompt** - Test coverage analysis prompts (Steps 5-6)
4. **quality_prompt** - Code quality validation prompts (Step 9)
5. **issue_extraction_prompt** - Log analysis and issue extraction prompts

### Usage in Modules

The `ai_helpers.sh` functions automatically:
1. Check for YAML file existence
2. Parse the appropriate section using `sed`/`awk`
3. Extract role, task_template, and approach
4. Replace `{placeholder}` variables with actual values
5. Fallback to hardcoded strings if YAML unavailable or parsing fails

**Example from `build_doc_analysis_prompt()`:**
```bash
local yaml_file="${SCRIPT_DIR}/lib/ai_helpers.yaml"

if [[ -f "$yaml_file" ]]; then
    role=$(grep 'role:' "$yaml_file" | sed 's/^[[:space:]]*role:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/')
    task_template=$(awk '/task_template: \|/{flag=1; next} /^[[:space:]]*approach:/{flag=0} ...')
    task="${task_template//\{changed_files\}/$changed_files}"
    build_ai_prompt "$role" "$task" "$approach"
else
    # Fallback to hardcoded prompt
    build_ai_prompt "Senior technical documentation specialist..." "..." "..."
fi
```

### Benefits

- **Centralized Prompts**: All AI prompts in one location
- **Easy Testing**: Test different prompt strategies without code changes
- **Documentation**: Prompts serve as documentation of AI integration
- **Flexibility**: Swap entire prompt sets by replacing YAML file
- **Resilience**: Zero-downtime fallback to hardcoded prompts

### Phase 3 Modules (v2.1.0) ⭐ NEW - Short-Term Enhancements

### 14. `lib/metrics.sh` (511 lines) ✨ NEW
**Purpose:** Workflow metrics collection for tracking duration, success rate, and step timing

**Architecture:**
- JSON-based metrics storage with history tracking
- Per-step timing with start/stop timers
- Workflow-level aggregation and statistics
- Human-readable summary generation
- Query API for historical analysis

**Data Storage:**
- `metrics/current_run.json` - Active workflow metrics
- `metrics/history.jsonl` - JSON Lines format for all runs
- `metrics/summary.md` - Human-readable summary

**Functions:**
- `init_metrics()` - Initialize metrics collection
- `start_step_timer()`, `stop_step_timer()` - Step timing
- `finalize_metrics()` - Save to history and generate summary
- `get_success_rate()` - Calculate success rate for last N runs
- `get_average_step_duration()` - Average timing per step
- `generate_metrics_summary()` - Create markdown report

**Metrics Tracked:**
- Workflow duration, success/failure status, execution mode
- Per-step timing, status, and error messages
- Historical trends and success rates
- Critical path duration and bottleneck identification

**Usage:**
```bash
source "$(dirname "$0")/lib/metrics.sh"

# Initialize at workflow start
init_metrics

# Track step execution
start_step_timer 0 "Pre_Analysis"
# ... step execution ...
stop_step_timer 0 "success" ""

# Finalize at workflow end
finalize_metrics "success"

# Query metrics
success_rate=$(get_success_rate 10)  # Last 10 runs
avg_duration=$(get_average_step_duration 7)  # Step 7 average
```

### 15. `lib/change_detection.sh` (448 lines) ✨ NEW
**Purpose:** Auto-detect change types (docs-only, tests-only, full-stack) for smart step execution

**Change Classifications:**
- `docs-only` - Documentation changes only
- `tests-only` - Test files only
- `config-only` - Configuration files only
- `scripts-only` - Shell scripts only
- `code-only` - Source code only
- `full-stack` - Multiple categories
- `mixed` - Mixed changes

**Functions:**
- `detect_change_type()` - Classify changes from git status
- `analyze_changes()` - Detailed breakdown by category
- `get_recommended_steps()` - Steps required for detected change type
- `should_execute_step()` - Check if step should run
- `display_execution_plan()` - Show recommended workflow
- `assess_change_impact()` - Risk assessment (low/medium/high)
- `generate_change_report()` - Markdown report with recommendations

**Step Recommendations:**
```bash
docs-only:    Steps 0,1,2,11,12    # Skip tests and validation
tests-only:   Steps 0,5,6,7,11     # Skip docs and quality checks
config-only:  Steps 0,8,11          # Dependencies and git only
full-stack:   Steps 0-12            # All steps required
```

**Usage:**
```bash
source "$(dirname "$0")/lib/change_detection.sh"

# Detect change type
change_type=$(detect_change_type)
echo "Detected: ${change_type}"

# Display execution plan
display_execution_plan

# Check if step should run
if should_execute_step 7; then
    echo "Running tests..."
fi

# Assess impact
impact=$(assess_change_impact)  # low, medium, high
echo "Change impact: ${impact}"
```

### 16. `lib/dependency_graph.sh` (429 lines) ✨ NEW
**Purpose:** Visualize execution flow and identify parallelization opportunities

**Features:**
- Step dependency definitions and validation
- Parallelizable step group identification
- Execution time estimates and critical path analysis
- Mermaid diagram generation
- Optimal execution plan with time savings

**Parallel Groups Identified:**
```bash
Group 1: Steps 1,3,4,5,8  # After Pre-Analysis (save ~270s)
Group 2: Steps 2,12       # Consistency checks (save ~45s)
Group 3: Steps 7,9        # Test exec + quality (save ~150s)
Total Savings: ~465s (33% faster execution)
```

**Functions:**
- `check_dependencies()` - Verify step dependencies met
- `get_next_runnable_steps()` - Steps that can run now
- `get_parallel_steps()` - Steps for parallel execution
- `generate_dependency_diagram()` - Mermaid flowchart
- `generate_execution_plan()` - Optimal execution order
- `calculate_critical_path()` - Longest sequential chain
- `display_execution_phases()` - Terminal visualization

**Critical Path Analysis:**
```
Step 0 (30s) → Step 5 (120s) → Step 6 (180s) → 
Step 7 (240s) → Step 10 (120s) → Step 11 (90s)
Total: 780s (~13 minutes)
```

**Usage:**
```bash
source "$(dirname "$0")/lib/dependency_graph.sh"

# Check if step can run
if check_dependencies 6 "0,5"; then
    echo "Step 6 ready to run"
fi

# Get parallel steps
completed="0"
parallel=$(get_parallel_steps "${completed}")
echo "Can run in parallel: ${parallel}"

# Generate visualizations
generate_dependency_diagram "${BACKLOG_RUN_DIR}/graph.md"
generate_execution_plan "${BACKLOG_RUN_DIR}/plan.md"

# Display phases
display_execution_phases
```

**Optimization Results:**
- **Sequential:** ~1,395s (~23 minutes)
- **Parallel:** ~930s (~15.5 minutes)
- **Time Savings:** 33% faster execution

---

## Additional Module Documentation

### 17. `lib/argument_parser.sh` (231 lines) 🆕
**Purpose:** Robust CLI argument parsing with validation and help generation

**Features:**
- Boolean flag parsing (--flag, --no-flag)
- Value argument parsing (--option value)
- Multi-value arguments (--steps 0,1,2)
- Automatic help text generation
- Unknown argument detection
- Default value handling

**Functions:**
- `parse_arguments()` - Main parsing function
- `validate_argument()` - Argument validation
- `get_argument_value()` - Retrieve parsed value
- `display_usage()` - Show help text
- `register_argument()` - Define argument schema

**Usage:**
```bash
source "$(dirname "$0")/lib/argument_parser.sh"

# Register arguments
register_argument "--target" "TARGET_DIR" "required" "Project directory"
register_argument "--smart-execution" "SMART_EXEC" "boolean" "Enable smart execution"

# Parse
parse_arguments "$@"

# Use values
echo "Target: ${TARGET_DIR}"
if [[ "${SMART_EXEC}" == "true" ]]; then
    echo "Smart execution enabled"
fi
```

### 18. `lib/config_wizard.sh` (532 lines) 🆕 v2.3.1
**Purpose:** Interactive configuration wizard for project setup

**Features:**
- Guided `.workflow-config.yaml` creation
- Project kind selection (shell_automation, nodejs_api, react_spa, etc.)
- Tech stack auto-detection with manual override
- Test framework configuration
- Directory structure setup
- Validation of user inputs

**Functions:**
- `run_config_wizard()` - Main interactive wizard
- `detect_and_prompt()` - Auto-detect with confirmation
- `prompt_project_kind()` - Project type selection
- `prompt_tech_stack()` - Technology configuration
- `prompt_test_config()` - Test framework setup
- `generate_config_file()` - Write `.workflow-config.yaml`
- `validate_config()` - Verify configuration

**Interactive Prompts:**
```
1. Project kind selection (12 options)
2. Primary programming language
3. Test framework (Jest/BATS/pytest/etc.)
4. Source directory location
5. Test directory location
6. Documentation directory
7. Test execution command
```

**Generated Config Example:**
```yaml
project:
  kind: nodejs_api
  description: "REST API project"
  
tech_stack:
  primary_language: javascript
  frameworks:
    - express
  
testing:
  framework: jest
  command: "npm test"
  coverage_threshold: 80
  
structure:
  source_dir: "src"
  test_dir: "tests"
  docs_dir: "docs"
```

**Usage:**
```bash
source "$(dirname "$0")/lib/config_wizard.sh"

# Run wizard
run_config_wizard

# Or with specific target
run_config_wizard "/path/to/project"
```

### 19. `lib/edit_operations.sh` (427 lines) 🆕
**Purpose:** Safe file editing with atomic operations and rollback

**Features:**
- Atomic file edits (write to temp, then move)
- Automatic backup creation
- Rollback on failure
- Multi-file batch operations
- Edit validation before commit
- Change tracking and logging

**Functions:**
- `safe_edit_file()` - Atomic file edit
- `batch_edit_files()` - Edit multiple files
- `backup_file()` - Create timestamped backup
- `restore_backup()` - Rollback to backup
- `validate_edit()` - Verify edit syntax
- `commit_edit()` - Finalize edit
- `rollback_edit()` - Undo edit

**Safety Features:**
```bash
# Automatic backup before edit
backup_file "script.sh"

# Edit in temp file first
safe_edit_file "script.sh" "s/old/new/g"

# Validate before committing
if validate_edit "script.sh.tmp"; then
    commit_edit "script.sh"
else
    rollback_edit "script.sh"
fi
```

**Usage:**
```bash
source "$(dirname "$0")/lib/edit_operations.sh"

# Safe single file edit
safe_edit_file "config.yaml" "s/version: 1/version: 2/g"

# Batch edit with validation
files=("script1.sh" "script2.sh" "script3.sh")
batch_edit_files "${files[@]}" "s/old_function/new_function/g"

# Manual backup and restore
backup_file "important.sh"
# ... make changes ...
if something_failed; then
    restore_backup "important.sh"
fi
```

### 20. `lib/step_adaptation.sh` (493 lines) 🆕
**Purpose:** Dynamic step behavior based on project kind

**Features:**
- Project-aware step execution
- Custom validation rules per project type
- Framework-specific test execution
- Language-specific linting
- Dynamic output filtering
- Adaptive error handling

**Functions:**
- `adapt_step_for_project()` - Main adaptation logic
- `get_project_validators()` - Project-specific validators
- `get_test_command()` - Framework-specific test cmd
- `get_lint_command()` - Language-specific linter
- `should_skip_step()` - Conditional step skipping
- `adapt_output_format()` - Project-aware formatting

**Project Adaptations:**
```bash
# Node.js project
- Use Jest/Mocha for testing
- ESLint for code quality
- npm/yarn for dependencies
- package.json validation

# Python project
- Use pytest for testing
- pylint/black for quality
- pip for dependencies
- requirements.txt validation

# Shell project
- Use BATS for testing
- shellcheck for quality
- No package manager
- Script permission checks
```

**Usage:**
```bash
source "$(dirname "$0")/lib/step_adaptation.sh"

# Adapt step behavior
project_kind=$(get_project_kind)
adapt_step_for_project "07" "${project_kind}"

# Get project-specific command
test_cmd=$(get_test_command "${project_kind}")
echo "Running: ${test_cmd}"

# Check if step should run
if should_skip_step "08" "${project_kind}"; then
    echo "Skipping dependency check for ${project_kind}"
    return 0
fi
```

### 21. `lib/doc_template_validator.sh` (411 lines) 🆕
**Purpose:** Validate documentation templates and ensure consistency

**Features:**
- Template syntax validation
- Variable placeholder checking
- Required section verification
- Cross-template consistency
- Format compliance checking
- Auto-fix common issues

**Functions:**
- `validate_template()` - Main validation
- `check_required_sections()` - Section presence
- `validate_placeholders()` - Variable syntax
- `check_formatting()` - Markdown compliance
- `suggest_fixes()` - Auto-fix recommendations
- `apply_template_fixes()` - Apply corrections

**Validation Rules:**
```bash
Required Sections:
- Title (# heading)
- Overview/Description
- Usage/Examples (if applicable)
- Configuration (if applicable)

Placeholder Format:
- Variables: ${VARIABLE_NAME}
- Project-aware: ${PROJECT_KIND}
- Dates: ${CURRENT_DATE}

Format Checks:
- Consistent heading levels
- Code block language tags
- Proper list formatting
- Valid markdown links
```

**Usage:**
```bash
source "$(dirname "$0")/lib/doc_template_validator.sh"

# Validate single template
validate_template "docs/templates/README_TEMPLATE.md"

# Validate all templates
for template in docs/templates/*.md; do
    if ! validate_template "${template}"; then
        echo "Issues found in ${template}"
        suggest_fixes "${template}"
    fi
done

# Auto-fix templates
apply_template_fixes "docs/templates/"
```

---

## Orchestrator Architecture (v2.4.0) 🚧

### Overview
Version 2.4.0 introduces a **phase-based orchestrator architecture** that separates workflow execution into distinct phases with dedicated orchestrators.

### Architecture Pattern
```
execute_tests_docs_workflow_v2.4.sh (Main Controller)
├── pre_flight.sh                    # Phase 0: Setup
├── validation_orchestrator.sh       # Phase 1: Validation (Steps 0-4)
├── quality_orchestrator.sh          # Phase 2: Quality (Steps 5-10)
└── finalization_orchestrator.sh     # Phase 3: Finalization (Steps 11-13)
```

### 22. `orchestrators/pre_flight.sh` (227 lines) 🚀 v2.4.0
**Purpose:** Pre-execution validation and environment setup

**Responsibilities:**
- System requirements validation
- Tool availability checks (git, gh, node, etc.)
- Configuration file validation
- Target directory verification
- Checkpoint state assessment
- Performance metrics initialization

**Functions:**
- `run_pre_flight_checks()` - Main orchestration
- `validate_system_requirements()` - Tool checks
- `validate_configuration()` - Config validation
- `check_git_state()` - Repository status
- `initialize_metrics()` - Metrics setup
- `prepare_workspace()` - Directory setup

**Exit Conditions:**
```bash
# Fails if:
- Git not installed or repository not found
- Required tools missing (gh cli for AI features)
- Configuration file invalid
- Target directory doesn't exist
- Insufficient disk space
```

### 23. `orchestrators/validation_orchestrator.sh` (228 lines) 🚀 v2.4.0
**Purpose:** Coordinate validation phase (Steps 0-4)

**Managed Steps:**
- Step 0: Pre-analysis and change detection
- Step 1: Documentation updates
- Step 2: Consistency analysis
- Step 3: Script reference validation
- Step 4: Directory structure validation

**Functions:**
- `orchestrate_validation_phase()` - Main controller
- `execute_validation_step()` - Step wrapper
- `handle_validation_failure()` - Error handling
- `validation_phase_summary()` - Phase report

**Parallel Execution:**
```bash
# Can run in parallel after Step 0:
- Step 1 (Documentation)
- Step 3 (Script refs)
- Step 4 (Directory)

# Must run after Step 1:
- Step 2 (Consistency - checks docs)
```

### 24. `orchestrators/quality_orchestrator.sh` (82 lines) 🚀 v2.4.0
**Purpose:** Coordinate quality assurance phase (Steps 5-10)

**Managed Steps:**
- Step 5: Test coverage review
- Step 6: Test case generation
- Step 7: Test execution
- Step 8: Dependency validation
- Step 9: Code quality checks
- Step 10: Context analysis

**Functions:**
- `orchestrate_quality_phase()` - Main controller
- `execute_quality_step()` - Step wrapper
- `assess_quality_metrics()` - Quality scoring
- `quality_phase_summary()` - Phase report

**Quality Gates:**
```bash
# Phase fails if:
- Test coverage < threshold (default 80%)
- Critical code quality issues found
- Dependency vulnerabilities detected
- Context analysis reveals blockers
```

### 25. `orchestrators/finalization_orchestrator.sh` (93 lines) 🚀 v2.4.0
**Purpose:** Coordinate finalization phase (Steps 11-13)

**Managed Steps:**
- Step 11: Git operations and staging
- Step 12: Markdown linting
- Step 13: Prompt engineering validation

**Functions:**
- `orchestrate_finalization_phase()` - Main controller
- `execute_finalization_step()` - Step wrapper
- `prepare_git_commit()` - Stage changes
- `finalization_summary()` - Final report

**Finalization Flow:**
```bash
1. Step 12: Lint all markdown files
2. Step 13: Validate AI prompts
3. Step 11: Stage approved changes
4. Generate workflow summary
5. Display metrics and recommendations
```

---

## Test Infrastructure

The workflow includes comprehensive test coverage with 13 specialized test suites (covering 14 functional AI personas) across all critical functionality.

### Test Organization (5,122 lines total)

**AI Integration Tests:**
- `test_ai_cache.sh` (466 lines) - AI response caching validation
- `test_ai_helpers_phase4.sh` (412 lines) - AI helper functions

**Project Configuration Tests:**
- `test_get_project_kind.sh` (272 lines) - Project detection
- `test_project_kind_config.sh` (404 lines) - Configuration management
- `test_project_kind_detection.sh` (403 lines) - Detection logic
- `test_project_kind_integration.sh` (431 lines) - End-to-end integration
- `test_project_kind_prompts.sh` (313 lines) - Prompt generation
- `test_project_kind_validation.sh` (375 lines) - Validation rules

**Workflow Tests:**
- `test_step_adaptation.sh` (406 lines) - Dynamic step behavior
- `test_tech_stack_phase3.sh` (361 lines) - Tech stack detection
- `test_workflow_optimization.sh` (420 lines) - Smart & parallel execution
- `test_phase5_enhancements.sh` (341 lines) - Phase 5 features
- `test_phase5_final_steps.sh` (318 lines) - Phase 5 finalization

### Running Tests

**All Tests:**
```bash
cd src/workflow/lib
for test in test_*.sh; do
    echo "Running ${test}..."
    bash "${test}"
done
```

**Specific Test Suite:**
```bash
bash src/workflow/lib/test_ai_cache.sh
bash src/workflow/lib/test_project_kind_integration.sh
```

**Test Output:**
```
✅ PASS: AI cache creation
✅ PASS: Cache hit detection
✅ PASS: Cache expiration (TTL)
✅ PASS: Cache cleanup
...
Total: 36 tests, 36 passed, 0 failed
```

### Test Coverage

| Component | Tests | Coverage |
|-----------|-------|----------|
| AI Integration | 878 lines | 100% |
| Project Detection | 2,598 lines | 100% |
| Workflow Optimization | 1,127 lines | 100% |
| Tech Stack Detection | 361 lines | 100% |
| Step Adaptation | 406 lines | 100% |

---

## Utility Scripts

### `execute_tests_docs_workflow_v2.4.sh` (481 lines) 🚀 v2.4.0
**Purpose:** Next-generation orchestrator-based workflow execution

**Architecture:**
- Phase-based execution model
- Dedicated orchestrators for each phase
- Improved error handling and recovery
- Enhanced metrics collection
- Better parallel execution support

**Usage:**
```bash
# Run with orchestrator architecture
./execute_tests_docs_workflow_v2.4.sh --target /path/to/project

# With optimization flags
./execute_tests_docs_workflow_v2.4.sh --smart-execution --parallel
```

**Benefits:**
- More modular and maintainable
- Better separation of concerns
- Easier to extend with new phases
- Improved error isolation
- Enhanced logging per phase

### `benchmark_performance.sh` (243 lines)
**Purpose:** Measure and compare workflow performance

**Features:**
- Baseline performance measurement
- Smart execution benchmarking
- Parallel execution benchmarking
- Combined optimization benchmarking
- Historical comparison
- Performance regression detection

**Usage:**
```bash
# Run all benchmarks
./benchmark_performance.sh

# Specific benchmark
./benchmark_performance.sh --mode smart
./benchmark_performance.sh --mode parallel
./benchmark_performance.sh --mode combined

# Compare with baseline
./benchmark_performance.sh --compare
```

**Output:**
```
=== Workflow Performance Benchmark ===

Baseline Execution:        1,395s (23m 15s)
Smart Execution:            837s (13m 57s) - 40% faster
Parallel Execution:         930s (15m 30s) - 33% faster
Combined Optimization:      651s (10m 51s) - 53% faster

Time Savings: 744s (12m 24s)
Recommendation: Use --smart-execution --parallel for best performance
```

### `example_session_manager.sh` (260 lines)
**Purpose:** Interactive examples and documentation for session manager

**Features:**
- Live demonstrations of session management
- Interactive process handling examples
- Async command execution patterns
- Error handling demonstrations
- Best practices showcase

**Examples Included:**
1. **Basic Session Creation:**
   ```bash
   # Start long-running process
   start_session "build" "npm run build"
   ```

2. **Interactive Process Management:**
   ```bash
   # Interactive command with input
   start_session "wizard" "./config_wizard.sh"
   send_to_session "wizard" "y\n"
   ```

3. **Parallel Sessions:**
   ```bash
   # Multiple concurrent sessions
   start_session "build" "npm run build"
   start_session "test" "npm test"
   start_session "lint" "npm run lint"
   ```

4. **Error Handling:**
   ```bash
   # Handle session failures
   if ! wait_for_session "build" 300; then
       echo "Build failed"
       cleanup_session "build"
   fi
   ```

**Usage:**
```bash
# Run interactive examples
./example_session_manager.sh

# Run specific example
./example_session_manager.sh --example parallel
./example_session_manager.sh --example error-handling
```

---

## Module Extraction Pattern

Each step module should follow this standard pattern:

### Template: `steps/step_XX_name.sh`

```bash
#!/bin/bash
################################################################################
# Step XX: [Step Name]
# Purpose: [Description of what this step does]
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# Main step function - called by workflow orchestrator
# Returns: 0 for success, 1 for failure
step_XX_function_name() {
    print_step "XX" "[Step Name]"

    cd "$PROJECT_ROOT"

    # Phase 1: Automated validation
    print_info "Phase 1: Automated validation..."

    # ... step-specific logic ...

    # Phase 2: AI-powered analysis (if applicable)
    if [[ "$AUTO_MODE" != true ]]; then
        print_info "Phase 2: AI-powered analysis..."

        # Build Copilot prompt
        local copilot_prompt="..."

        if command -v copilot &> /dev/null; then
            if confirm_action "Run Copilot analysis?" "y"; then
                copilot -p "$copilot_prompt" --allow-all-tools
            fi
        fi
    fi

    # Save backlog if issues found
    if [[ -n "$issues_found" ]]; then
        save_step_issues "XX" "[Step Name]" "$issues_found"
    fi

    # Save summary
    save_step_summary "XX" "[Step Name]" "$summary_content" "✅"

    # Update workflow status
    update_workflow_status "Step XX" "✅"

    return 0
}

# Export step function
export -f step_XX_function_name
```

---

## Extraction Procedure

To extract a step from the monolithic script:

1. **Locate the step function**
   ```bash
   grep -n "^stepX_" execute_tests_docs_workflow.sh
   ```

2. **Extract the function**
   - Copy the entire function (from opening `{` to closing `}`)
   - Include all helper functions specific to that step
   - Include AI persona prompts

3. **Create the module file**
   ```bash
   cat > steps/step_XX_name.sh << 'EOF'
   #!/bin/bash
   # ... paste extracted code ...
   EOF
   chmod +x steps/step_XX_name.sh
   ```

4. **Test the module**
   ```bash
   bash -n steps/step_XX_name.sh  # Syntax check
   ```

5. **Update the main orchestrator**
   - Add source statement: `source "$(dirname "$0")/steps/step_XX_name.sh"`
   - Call function in workflow: `step_XX_function_name`

---

## Phase 3 Step Modules (✅ COMPLETE)

All 13 step modules successfully extracted from the monolithic script:

### Step 0: `steps/step_00_analyze.sh` (56 lines)
**Purpose:** Pre-workflow change analysis
**Function:** `step0_pre_analysis()`
**Features:** Git change detection, scope determination

### Step 1: `steps/step_01_documentation.sh` (1,020 lines)
**Purpose:** Documentation updates and validation
**Function:** `step1_update_documentation()`
**Features:** Two-phase validation, AI-powered documentation analysis, automatic issue extraction in auto-mode
**Recent Updates (Dec 15, 2025):** Auto-mode now automatically extracts structured issues from Copilot logs

### Step 2: `steps/step_02_consistency.sh` (373 lines)
**Purpose:** Consistency analysis across codebase
**Function:** `step2_consistency_analysis()`
**Features:** Cross-reference validation, AI consistency checking

### Step 3: `steps/step_03_script.sh` (320 lines)
**Purpose:** Shell script reference validation
**Function:** `step3_script_reference_validation()`
**Features:** Script validation, dependency checking

### Step 4: `steps/step_04_directory.sh` (263 lines)
**Purpose:** Directory structure validation
**Function:** `step4_directory_structure_validation()`
**Features:** Structure compliance, path validation

### Step 5: `steps/step_05_test_review.sh` (223 lines)
**Purpose:** Test suite review and coverage analysis
**Function:** `step5_test_review()`
**Features:** Coverage analysis, test quality assessment

### Step 6: `steps/step_06_test_gen.sh` (486 lines)
**Purpose:** Test generation for untested code
**Function:** `step6_test_generation()`
**Features:** AI test generation, coverage gap analysis

### Step 7: `steps/step_07_test_exec.sh` (306 lines)
**Purpose:** Test execution and validation
**Function:** `step7_test_execution()`
**Features:** Jest execution, failure analysis
**Recent Updates (Dec 15, 2025):** Test output increased from 100 → 200 lines for better debugging visibility

### Step 8: `steps/step_08_dependencies.sh` (460 lines)
**Purpose:** Dependency validation and security
**Function:** `step8_dependency_validation()`
**Features:** npm audit, version checking
**Recent Updates (Dec 15, 2025):** Production deps display increased from 20 → 50 lines, outdated from 10 → 20 lines

### Step 9: `steps/step_09_code_quality.sh` (294 lines)
**Purpose:** Code quality validation
**Function:** `step9_code_quality()`
**Features:** AI-powered quality analysis, best practices
**Recent Updates (Dec 15, 2025):** File preview increased from 30 → 50 lines for comprehensive code analysis

### Step 10: `steps/step_10_context.sh` (337 lines)
**Purpose:** Copilot context analysis
**Function:** `step10_context_analysis()`
**Features:** Context file validation, AI instruction review

### Step 11: `steps/step_11_git.sh` (367 lines) ✅ **PHASE 3 COMPLETE**
**Purpose:** AI-powered git finalization and commit message generation
**Function:** `step11_git_finalization()`
**Features:**
- Two-phase git finalization (automated + AI)
- Repository state analysis with git cache integration
- Change enumeration and categorization
- Conventional commit type inference
- AI-powered commit message generation
- Interactive commit message refinement
- Git Workflow Specialist AI persona with Technical Communication Expert
- Auto-mode intelligent defaults for CI/CD compatibility
- Comprehensive git context for AI prompts
- Supports interactive copy-paste workflow
- Auto-mode with default messages
- Breaking change detection
- Semantic versioning integration

### Step 12: `steps/step_12_markdown_lint.sh` (216 lines)
**Purpose:** Markdown linting and quality validation
**Function:** `step12_markdown_lint()`
**Features:**
- Markdown file discovery and validation
- AI-powered markdown quality analysis
- Best practices enforcement
- Formatting consistency checks
- Documentation quality assessment

### Phase 4: Refactor Main Orchestrator

- [ ] Remove all extracted code from `execute_tests_docs_workflow.sh`
- [ ] Add source statements for all modules
- [ ] Simplify main() function to workflow coordination only
- [ ] Target: < 300 lines total
- [ ] Update help text and version to 2.0.0

---

## Testing Strategy

### Unit Testing
```bash
# Test each module independently
cd src/workflow
for lib in lib/*.sh; do
    echo "Testing $lib..."
    bash -n "$lib"  # Syntax check
done

for step in steps/*.sh; do
    echo "Testing $step..."
    bash -n "$step"  # Syntax check
done
```

### Integration Testing
```bash
# Test complete workflow
./execute_tests_docs_workflow.sh --dry-run
./execute_tests_docs_workflow.sh --auto --dry-run
```

### Regression Testing
- Compare output before/after refactoring
- Verify all 13 steps execute correctly
- Check backlog generation works
- Verify summary generation works

---

## Benefits Achieved (All Phases Complete)

✅ **All library modules extracted** (40 modules including tests and configs)
✅ **All step modules extracted** (15 modules, 4,797 lines)
✅ **Total modularization:** Complete workflow automation system
✅ **YAML configuration system** for AI prompts with intelligent fallback
✅ **Single responsibility** per module
✅ **Reusable functions** across multiple scripts
✅ **Easier testing** with 54 automated tests
✅ **Clear dependencies** and interfaces
✅ **Performance optimization** preserved (git caching)
✅ **AI integration** modularized and testable with externalized configuration
✅ **Professional architecture** ready for production use

---

## Version History

### v2.0.0 (2025-11-13) - Phase 1, 2 & 3 Complete
- ✅ Created modular directory structure
- ✅ **Phase 1:** Extracted 5 core library modules (config, colors, utils, git_cache, validation)
- ✅ **Phase 2:** Extracted 3 remaining library modules (backlog, summary, ai_helpers)
- ✅ **Phase 3:** Extracted all 13 step modules (step_00 through step_12)
- ✅ 54 automated tests (100% pass rate)
- ✅ Complete module documentation
- ✅ **19,952 total production lines** from monolithic script (3,361 libs + 3,632 steps)
- ✅ All modules ready for Phase 4 integration

### v1.5.0 (Previous)
- Git state caching optimization
- 25-30% performance improvement

### v1.4.0
- Summary generation system

### v1.3.0
- Backlog tracking system

### v1.2.0
- AI-enhanced validation with Copilot CLI

---

## Contributing

When adding or modifying modules:

1. **Follow the established patterns** (see Module Extraction Pattern above)
2. **Include proper headers** with purpose and version
3. **Export functions** explicitly
4. **Add error handling** for all operations
5. **Support dry-run mode** via `$DRY_RUN` variable
6. **Support auto mode** via `$AUTO_MODE` variable
7. **Document all functions** with usage examples
8. **Test syntax** with `bash -n` before committing

---

## References

- Original monolithic script: `execute_tests_docs_workflow.sh` (4,337 lines)
- Split plan: `/docs/WORKFLOW_SCRIPT_SPLIT_PLAN.md`
- Performance optimization: `/docs/WORKFLOW_PERFORMANCE_OPTIMIZATION.md`
- Workflow automation plan: `/docs/TESTS_DOCS_WORKFLOW_AUTOMATION_PLAN.md`

---

**Maintained by:** MP Barbosa
**Last Updated:** 2025-11-12
**Status:** Phase 3 Complete - All Modules Extracted (Ready for Phase 4 Integration)
