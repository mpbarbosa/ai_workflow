# Module API Reference

**AI Workflow Automation v4.0.0**  
**Last Updated**: 2026-02-08

> **Note**: This is the comprehensive API reference for all 81 library modules. For architecture overview, see [ARCHITECTURE_DEEP_DIVE.md](ARCHITECTURE_DEEP_DIVE.md).

## Table of Contents

1. [Core Framework Modules](#core-framework-modules)
2. [Step Orchestration](#step-orchestration)
3. [AI Integration](#ai-integration)
4. [Change Detection & Optimization](#change-detection--optimization)
5. [Git & Artifact Management](#git--artifact-management)
6. [Monitoring & Observability](#monitoring--observability)
7. [Utility Modules](#utility-modules)
8. [Module Dependency Map](#module-dependency-map)

---

## Core Framework Modules

### config.sh
**Purpose**: Central configuration and constants for workflow automation

**Key Variables**:
```bash
PROJECT_ROOT         # Root directory of the workflow project
SRC_DIR             # Source code directory
BACKLOG_DIR         # Execution history storage
WORKFLOW_RUN_ID     # Unique ID for current workflow run
TOTAL_STEPS         # Total number of steps in workflow
```

**Usage**:
```bash
source lib/config.sh
echo "Project root: $PROJECT_ROOT"
echo "Run ID: $WORKFLOW_RUN_ID"
```

**Dependencies**: None (foundational module)

---

### utils.sh
**Purpose**: Common utility functions for formatted output and data handling

**Functions**:

#### `print_header(message)`
Display formatted header with borders
```bash
print_header "Step 1: Documentation Analysis"
# Output:
# ================================================================================
# Step 1: Documentation Analysis
# ================================================================================
```

#### `print_success(message)`, `print_error(message)`, `print_warning(message)`, `print_info(message)`
Color-coded status messages
```bash
print_success "Tests passed!"
print_error "Build failed"
print_warning "Cache miss detected"
print_info "Processing 42 files..."
```

#### `save_step_issues(step_num, step_name, issues_content)`
Save issues to backlog directory
- **Parameters**:
  - `step_num`: Step number (e.g., "01")
  - `step_name`: Step name (e.g., "documentation")
  - `issues_content`: Issue content as string
- **Returns**: 0 on success, 1 on failure
- **Output**: Creates `${BACKLOG_DIR}/step${step_num}_${step_name}_issues.md`

```bash
save_step_issues "01" "documentation" "Found 3 broken links"
```

#### `confirm_action(prompt)`
Interactive user confirmation
- **Parameters**: `prompt` - Question to ask
- **Returns**: 0 if user confirms (y/yes), 1 otherwise
```bash
if confirm_action "Delete old logs?"; then
    rm -rf logs/old/
fi
```

**Dependencies**: colors.sh

---

### colors.sh
**Purpose**: ANSI color definitions for consistent terminal output

**Variables**:
```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'  # No Color
```

**Usage**:
```bash
source lib/colors.sh
echo -e "${GREEN}Success!${NC}"
echo -e "${RED}Error occurred${NC}"
```

**Dependencies**: None

---

### validation.sh
**Purpose**: Pre-flight checks and dependency validation

**Functions**:

#### `detect_project_tech_stack()`
Detect project technologies (Node.js, Python, Ruby, Go, Rust, Java)
- **Returns**: Array of detected technologies or "shell" if none found
- **Output**: Sets `DETECTED_TECH_STACK` array

```bash
detect_project_tech_stack
for tech in "${DETECTED_TECH_STACK[@]}"; do
    echo "Found: $tech"
done
```

#### `check_prerequisites()`
Verify project directory structure, git, required tools
- **Returns**: 0 if all checks pass, 1 otherwise
- **Checks**:
  - Project directory exists and is a git repository
  - Required commands available (git, node/npm if Node.js project)
  - Write permissions for artifact directories

```bash
if ! check_prerequisites; then
    echo "Prerequisites not met"
    exit 1
fi
```

**Dependencies**: config.sh, utils.sh

---

## Step Orchestration

### step_registry.sh (v4.0.4)
**Purpose**: Configuration-driven step management and execution order resolution

**Functions**:

#### `load_step_definitions()`
Parse workflow steps from `.workflow-config.yaml`
- **Returns**: 0 on success, 1 on failure
- **Side Effects**: Populates global registries (STEP_REGISTRY_BY_NAME, STEP_REGISTRY_BY_INDEX, STEP_REGISTRY_DEPENDENCIES)

```bash
load_step_definitions
if [[ $? -eq 0 ]]; then
    echo "Step registry loaded successfully"
fi
```

#### `get_step_metadata(step_identifier)`
Lookup step by name or index
- **Parameters**: `step_identifier` - Step name or numeric index
- **Returns**: Pipe-delimited string: `module:function:description:enabled`
- **Example Output**: `documentation_updates.sh:execute_documentation_updates:Update documentation:true`

```bash
metadata=$(get_step_metadata "documentation_updates")
IFS=':' read -r module function description enabled <<< "$metadata"
echo "Module: $module"
echo "Function: $function"
```

#### `resolve_step_dependencies()`
Perform topological sort for execution order
- **Returns**: Array of steps in dependency-resolved order
- **Algorithm**: Kahn's algorithm for DAG sorting

```bash
resolve_step_dependencies
for step in "${RESOLVED_EXECUTION_ORDER[@]}"; do
    echo "Execute: $step"
done
```

**Global Registries**:
- `STEP_REGISTRY_BY_NAME`: Associative array indexed by step name
- `STEP_REGISTRY_BY_INDEX`: Associative array indexed by numeric index
- `STEP_REGISTRY_DEPENDENCIES`: Dependency relationships

**Breaking Changes from v3.x**: 
- v3.x used numeric indices (`01`, `02`, etc.)
- v4.0+ uses descriptive step names (`documentation_updates`, `test_execution`)

**Dependencies**: config.sh, utils.sh

---

### step_loader.sh (v4.0)
**Purpose**: Dynamic sourcing of step modules with validation

**Functions**:

#### `load_step_module(step_name)`
Dynamically source step module
- **Parameters**: `step_name` - Name of step to load
- **Returns**: 0 on success, 1 on failure
- **Validation**: Checks file exists and contains required function

```bash
if load_step_module "documentation_updates"; then
    echo "Module loaded successfully"
else
    echo "Failed to load module"
    exit 1
fi
```

#### `execute_step(step_name)`
Generic execution wrapper for steps
- **Parameters**: `step_name` - Name of step to execute
- **Returns**: Exit code from step function
- **Timing**: Automatically tracks execution time via metrics.sh

```bash
execute_step "test_execution"
exit_code=$?
if [[ $exit_code -eq 0 ]]; then
    echo "Step succeeded"
fi
```

**Global Array**: 
- `LOADED_STEP_MODULES`: Tracks loaded modules to prevent re-loading

**Dependencies**: step_registry.sh, utils.sh

---

### step_execution.sh
**Purpose**: Shared execution patterns for workflow steps (DRY principle)

**Functions**:

#### `execute_phase2_ai_analysis(copilot_prompt, step_number, step_name, display_name, has_issues, analysis_type, optional_prompt_msg, success_question)`
Execute Phase 2 AI analysis with issue extraction
- **Parameters**:
  - `copilot_prompt`: AI prompt text
  - `step_number`: Step number (e.g., "02")
  - `step_name`: Step name (e.g., "consistency_check")
  - `display_name`: Human-readable name
  - `has_issues`: "yes" or "no"
  - `analysis_type`: Type of analysis (e.g., "consistency", "quality")
  - `optional_prompt_msg`: Additional context
  - `success_question`: Question to ask on completion
- **Returns**: 0 on success, 1 on failure

```bash
execute_phase2_ai_analysis \
    "$prompt" \
    "02" \
    "consistency_check" \
    "Documentation Consistency Check" \
    "yes" \
    "consistency" \
    "" \
    "Were consistency issues found?"
```

#### `execute_copilot_prompt(prompt, output_file)`
Execute Copilot CLI with logging
- **Parameters**:
  - `prompt`: AI prompt
  - `output_file`: File to save response
- **Returns**: Copilot CLI exit code

```bash
execute_copilot_prompt \
    "Analyze this codebase" \
    "${BACKLOG_DIR}/analysis.md"
```

**Dependencies**: ai_helpers.sh, utils.sh

---

### step_metadata.sh
**Purpose**: Comprehensive metadata for workflow steps

**Metadata Arrays**:
```bash
STEP_NAMES[0]="pre_analysis"
STEP_DESCRIPTIONS[0]="Analyze project structure and changes"
STEP_CATEGORIES[0]="analysis"
STEP_CAN_SKIP[0]=0              # Cannot skip
STEP_CAN_PARALLELIZE[0]=0       # Cannot parallelize
STEP_REQUIRES_AI[0]=0           # No AI required
STEP_AFFECTS_FILES[0]="*.md docs/**"
```

**Usage**:
```bash
source lib/step_metadata.sh
echo "Step 0 name: ${STEP_NAMES[0]}"
echo "Can skip? ${STEP_CAN_SKIP[0]}"
```

**Dependencies**: None (metadata only)

---

## AI Integration

### ai_helpers.sh
**Purpose**: AI prompt templates and Copilot CLI integration

**Functions**:

#### `is_copilot_available()`
Check if Copilot CLI is installed
- **Returns**: 0 if available, 1 if not

```bash
if is_copilot_available; then
    echo "Copilot CLI detected"
fi
```

#### `is_copilot_authenticated()`
Check if Copilot CLI is authenticated
- **Returns**: 0 if authenticated, 1 if not

```bash
if ! is_copilot_authenticated; then
    echo "Please authenticate with: copilot"
    exit 1
fi
```

#### `validate_copilot_cli()`
Validate and provide feedback
- **Returns**: 0 if ready, 1 if not ready
- **Output**: Prints helpful messages for setup

```bash
validate_copilot_cli || exit 1
```

#### `get_project_metadata()`
Get project information from configuration
- **Returns**: Pipe-delimited string: `project_name|project_description|primary_language`

```bash
IFS='|' read -r name desc lang <<< "$(get_project_metadata)"
echo "Project: $name"
echo "Language: $lang"
```

#### `build_ai_persona_prompt(persona, context)`
Build persona-aware AI prompts
- **Parameters**:
  - `persona`: Persona name (e.g., "documentation_specialist", "test_engineer")
  - `context`: Additional context
- **Returns**: Complete AI prompt

```bash
prompt=$(build_ai_persona_prompt "code_reviewer" "Review security issues")
```

**Integration Points**:
- GitHub Copilot CLI
- Environment tokens: COPILOT_GITHUB_TOKEN, GH_TOKEN, GITHUB_TOKEN
- gh auth for authentication

**Dependencies**: config.sh, utils.sh

---

### ai_cache.sh (v1.0)
**Purpose**: Cache AI responses to reduce token usage

**Functions**:

#### `init_ai_cache()`
Initialize cache directory and index
- **Returns**: 0 on success, 1 on failure
- **Side Effects**: Creates `${AI_CACHE_DIR}/index.json`

```bash
init_ai_cache
```

#### `generate_cache_key(prompt, context)`
Generate SHA256 cache key
- **Parameters**:
  - `prompt`: AI prompt text
  - `context` (optional): Additional context
- **Returns**: SHA256 hash

```bash
key=$(generate_cache_key "Analyze docs" "project=ai_workflow")
echo "Cache key: $key"
```

#### `get_cached_response(cache_key)`
Retrieve cached response
- **Parameters**: `cache_key` - Cache key from generate_cache_key
- **Returns**: Cached content or empty string

```bash
response=$(get_cached_response "$cache_key")
if [[ -n "$response" ]]; then
    echo "Cache hit!"
fi
```

#### `cache_response(cache_key, response)`
Store response in cache
- **Parameters**:
  - `cache_key`: Cache key
  - `response`: Response content
- **Returns**: 0 on success, 1 on failure

```bash
cache_response "$cache_key" "Analysis complete: no issues found"
```

#### `cleanup_ai_cache_old_entries()`
Remove expired entries (TTL: 24 hours)
- **Returns**: 0 on success

```bash
cleanup_ai_cache_old_entries
```

**Cache Configuration**:
- **TTL**: 86400 seconds (24 hours)
- **Max Size**: 100 MB
- **Location**: `src/workflow/.ai_cache/`
- **Index**: `src/workflow/.ai_cache/index.json`

**Dependencies**: utils.sh

---

## Change Detection & Optimization

### change_detection.sh
**Purpose**: Auto-detect change types and filter workflow artifacts

**Functions**:

#### `filter_workflow_artifacts(file_list)`
Remove ephemeral workflow artifacts from file list
- **Parameters**: `file_list` - Newline-separated list of files
- **Returns**: Filtered file list
- **Patterns Filtered**:
  - `.ai_workflow/*`
  - `src/workflow/.checkpoints/*`
  - `*.tmp`, `*.bak`, `*.swp`
  - `*~`

```bash
modified_files=$(git diff --name-only HEAD^)
clean_files=$(filter_workflow_artifacts "$modified_files")
echo "Clean files: $clean_files"
```

#### `is_workflow_artifact(file_path)`
Check if file is a workflow artifact
- **Parameters**: `file_path` - Path to check
- **Returns**: 0 if artifact, 1 if not

```bash
if is_workflow_artifact ".ai_workflow/cache/test.json"; then
    echo "This is an artifact"
fi
```

**Dependencies**: None

---

### conditional_execution.sh (v2.7.1)
**Purpose**: Smart step execution based on file changes

**Functions**:

#### `get_modified_files()`
Get modified files from Git
- **Returns**: Newline-separated list of modified files
- **Git Range**: Compares HEAD to last workflow commit

```bash
files=$(get_modified_files)
echo "Modified files:"
echo "$files"
```

#### `get_new_dirs_count()`, `get_deleted_dirs_count()`
Count directory changes
- **Returns**: Number of new/deleted directories

```bash
new_dirs=$(get_new_dirs_count)
echo "New directories: $new_dirs"
```

#### `modified_files_contain(pattern)`
Check if pattern exists in modified files
- **Parameters**: `pattern` - Pattern to search (supports wildcards)
- **Returns**: 0 if found, 1 if not found
- **Example Patterns**: `"docs/"`, `"*.sh"`, `"README.md"`

```bash
if modified_files_contain "docs/"; then
    echo "Documentation changed"
fi

if modified_files_contain "*.test.js"; then
    echo "Test files modified"
fi
```

**Performance Target**: 40-60% reduction in unnecessary step execution

**Dependencies**: config.sh

---

### workflow_optimization.sh (v1.0.3)
**Purpose**: Advanced workflow features for performance and reliability

**Functions**:

#### `should_skip_step_by_impact(step_num, impact)`
Determine if step should be skipped based on change impact
- **Parameters**:
  - `step_num`: Step number
  - `impact`: Impact level (Low/Medium/High)
- **Returns**: 0 to skip, 1 to execute

```bash
if should_skip_step_by_impact "05" "Low"; then
    echo "Skipping step 5 (low impact)"
fi
```

#### `execute_parallel_validation()`
Run validation steps (1-4) in parallel
- **Returns**: 0 if all succeed, 1 if any fail

```bash
execute_parallel_validation
```

#### `save_checkpoint()`
Save workflow checkpoint for resume
- **Returns**: Checkpoint file path
- **Location**: `${WORKFLOW_HOME}/src/workflow/.checkpoints/`

```bash
checkpoint=$(save_checkpoint)
echo "Checkpoint saved: $checkpoint"
```

#### `load_checkpoint()`
Load and validate checkpoint
- **Returns**: 0 if valid, 1 if invalid
- **Side Effects**: Sets RESUME_FROM_STEP variable

```bash
if load_checkpoint; then
    echo "Resuming from step: $RESUME_FROM_STEP"
fi
```

#### `cleanup_old_checkpoints()`
Remove checkpoints older than 7 days
- **Returns**: 0 on success

```bash
cleanup_old_checkpoints
```

**Dependencies**: conditional_execution.sh, metrics.sh

---

### skip_predictor.sh (v1.0)
**Purpose**: ML-powered step necessity prediction

**Functions**:

#### `init_skip_predictor()`
Initialize ML system with training data
- **Returns**: 0 if enabled, 1 if disabled (requires ≥10 historical samples)

```bash
if init_skip_predictor; then
    echo "ML prediction enabled"
else
    echo "Insufficient training data"
fi
```

#### `calculate_feature_similarity(features_json_1, features_json_2)`
Calculate cosine similarity between feature vectors
- **Parameters**:
  - `features_json_1`: JSON feature vector
  - `features_json_2`: JSON feature vector
- **Returns**: Similarity score (0.0-1.0)

```bash
similarity=$(calculate_feature_similarity "$features1" "$features2")
echo "Similarity: $similarity"
```

#### `predict_step_necessity(step_num, feature_vector)`
Predict if step is necessary
- **Parameters**:
  - `step_num`: Step number
  - `feature_vector`: JSON feature vector
- **Returns**: JSON with prediction and confidence
- **Confidence Thresholds**:
  - ≥0.85: Auto-skip
  - 0.70-0.85: Skip with warning
  - 0.50-0.70: Prompt user
  - <0.50: Always run

```bash
prediction=$(predict_step_necessity "05" "$features")
confidence=$(echo "$prediction" | jq -r '.confidence')
```

**Critical Steps**: Steps 0 and 15 are never skipped (safety)

**ML Data Location**: 
- `${ML_DATA_DIR}/skip_history.jsonl`
- `${ML_DATA_DIR}/training_data.jsonl`

**Dependencies**: jq_wrapper.sh

---

## Git & Artifact Management

### git_automation.sh (v2.7.1)
**Purpose**: Intelligent post-workflow Git automation

**Functions**:

#### `detect_workflow_artifacts()`
Find artifacts to stage
- **Returns**: Newline-separated list of artifact files
- **Artifact Patterns**:
  - `src/workflow/logs/workflow_*/`
  - `src/workflow/backlog/workflow_*/`
  - `docs/**/*.md` (if modified)
  - `test-results/`
  - `coverage/`

```bash
artifacts=$(detect_workflow_artifacts)
echo "Artifacts to stage:"
echo "$artifacts"
```

#### `auto_stage_artifacts()`
Auto-stage detected artifacts
- **Returns**: 0 on success, 1 on failure
- **Exclusions**: node_modules, .cache, secrets, .local files

```bash
if auto_stage_artifacts; then
    echo "Artifacts staged successfully"
fi
```

#### `generate_smart_commit_message()`
Generate AI-aware commit messages
- **Returns**: Generated commit message
- **Format**: Conventional Commits style

```bash
msg=$(generate_smart_commit_message)
git commit -m "$msg"
```

#### `push_to_remote()`
Push changes with safety checks
- **Returns**: 0 on success, 1 on failure
- **Safety Checks**: Verifies remote exists, checks for divergence

```bash
if push_to_remote; then
    echo "Pushed to remote successfully"
fi
```

**Performance Target**: Reduce manual Git operations by 80%

**Dependencies**: None

---

### dependency_graph.sh
**Purpose**: Visualize execution flow and identify parallelization

**Data Structures**:
```bash
STEP_DEPENDENCIES=(
    [0]=""                    # Pre-analysis (no deps)
    [1]="0"                   # Documentation depends on 0
    [3]="1 2"                 # Script refs depends on 1 and 2
    [7]="3 4 5 6"            # Test exec depends on 3,4,5,6
)

PARALLEL_GROUPS=(
    "3 4 5 14"               # Group 1: Can run in parallel
    "9 10"                   # Group 2: Can run in parallel
)
```

**3-Track Parallel Structure** (v3.3.0):
- **Track 1 (Analysis)**: 0 → (3,4,5,14 parallel) → 11.5
- **Track 2 (Validation)**: 6 → 7 → 8 → 10 → 11 (+ 9 parallel)
- **Track 3 (Documentation)**: 0a → 0b → 1 → 2 → 13 → 15
- **Convergence**: All → 16 → 12 (FINAL)

**Time Estimation**: 60-70% reduction vs sequential execution

**Dependencies**: step_metadata.sh

---

## Monitoring & Observability

### metrics.sh
**Purpose**: Track performance and execution statistics

**Functions**:

#### `init_metrics()`
Initialize metrics collection
- **Returns**: 0 on success
- **Side Effects**: Creates METRICS_CURRENT, METRICS_HISTORY, METRICS_SUMMARY files

```bash
init_metrics
```

#### `start_step_timer(step_num)`
Record step start time
- **Parameters**: `step_num` - Step number

```bash
start_step_timer "07"
```

#### `end_step_timer(step_num, status)`
Record step end time
- **Parameters**:
  - `step_num`: Step number
  - `status`: "success", "failure", or "skipped"

```bash
end_step_timer "07" "success"
```

#### `record_phase_timing(phase_name, duration)`
Track phase timing
- **Parameters**:
  - `phase_name`: Name of phase
  - `duration`: Duration in seconds

```bash
record_phase_timing "documentation_analysis" 45.3
```

#### `finalize_workflow_metrics(success)`
Generate final metrics report
- **Parameters**: `success` - true/false
- **Returns**: 0 on success

```bash
finalize_workflow_metrics true
```

**Metrics Files**:
- **Current**: `${METRICS_DIR}/current_run.json`
- **History**: `${METRICS_DIR}/history.jsonl`
- **Summary**: `${METRICS_DIR}/summary.md`

**Tracked Data**:
- Step durations
- Step statuses (success/failure/skipped)
- Phase timings
- Workflow success/failure rates

**Dependencies**: config.sh, utils.sh

---

### performance.sh
**Purpose**: Parallel execution and optimized operations

**Functions**:

#### `parallel_execute(max_jobs, command1, command2, ...)`
Execute commands in parallel
- **Parameters**:
  - `max_jobs`: Maximum concurrent jobs
  - `command1...N`: Commands to execute
- **Returns**: 0 if all succeed, 1 if any fail

```bash
parallel_execute 4 \
    "npm test" \
    "npm run lint" \
    "npm run build"
```

#### `parallel_workflow_steps(step1_func, step2_func, ...)`
Execute workflow steps in parallel
- **Parameters**: Function names to execute
- **Returns**: 0 on success, 1 if any fail

```bash
parallel_workflow_steps \
    execute_step_03 \
    execute_step_04 \
    execute_step_05
```

**Job Control**: Uses `wait -n` to manage max parallel jobs

**Dependencies**: utils.sh

---

### session_manager.sh
**Purpose**: Manage unique bash sessions and cleanup

**Functions**:

#### `generate_session_id(step_num, operation_name)`
Create unique session ID
- **Parameters**:
  - `step_num`: Step number
  - `operation_name`: Operation name
- **Returns**: Session ID (e.g., "step07_test_exec_20251113_193721_abc123")

```bash
session_id=$(generate_session_id "07" "test_exec")
echo "Session: $session_id"
```

#### `register_session(session_id, description)`
Track active session
- **Parameters**:
  - `session_id`: Session ID
  - `description`: Human-readable description

```bash
register_session "$session_id" "Running unit tests"
```

#### `unregister_session(session_id)`
Clean up completed session
- **Parameters**: `session_id` - Session to remove

```bash
unregister_session "$session_id"
```

#### `execute_with_session(step_num, operation, command, timeout, mode)`
Execute with session management
- **Parameters**:
  - `step_num`: Step number
  - `operation`: Operation name
  - `command`: Command to execute
  - `timeout_seconds`: Timeout in seconds
  - `mode`: "sync" or "async"
- **Returns**: Command exit code

```bash
execute_with_session \
    "07" \
    "test_exec" \
    "npm test" \
    300 \
    "sync"
```

**Global Arrays**:
- `ACTIVE_SESSIONS`: Currently active sessions
- `SESSION_CLEANUP_QUEUE`: Sessions pending cleanup

**Dependencies**: utils.sh, cleanup_handlers.sh

---

### cleanup_handlers.sh
**Purpose**: Standardized cleanup patterns

**Functions**:

#### `init_cleanup()`
Initialize cleanup system with trap handlers
- **Returns**: 0 on success
- **Signals**: EXIT, INT, TERM

```bash
init_cleanup
```

#### `register_cleanup_handler(name, command)`
Register cleanup function
- **Parameters**:
  - `name`: Unique name for handler
  - `command`: Command/function to execute

```bash
register_cleanup_handler "temp_files" "rm -rf /tmp/workflow_*"
```

#### `register_temp_file(file_path)`, `register_temp_dir(dir_path)`
Register ephemeral resources
- **Parameters**: Path to file/directory

```bash
temp_file=$(mktemp)
register_temp_file "$temp_file"
```

#### `execute_cleanup()`
Run all registered handlers
- **Note**: Called automatically on exit

```bash
execute_cleanup  # Usually not needed - happens automatically
```

#### `unregister_cleanup_handler(name)`, `unregister_temp_file(file_path)`
Remove from registry
- **Parameters**: Handler name or file path

```bash
unregister_cleanup_handler "temp_files"
```

**Dependencies**: utils.sh, session_manager.sh

---

## Utility Modules

### jq_wrapper.sh (v1.0.5)
**Purpose**: Safe wrapper for jq command with validation

**Function**:

#### `jq_safe([jq_options_and_args])`
Safe jq execution with validation and logging
- **Parameters**: All jq arguments (options and expressions)
- **Returns**: Same exit code as jq
- **Features**:
  - Validates --argjson arguments
  - Logs to WORKFLOW_LOG_FILE if set
  - Prevents empty JSON errors

```bash
# Basic usage
result=$(jq_safe '.name' data.json)

# With arguments
result=$(jq_safe -n \
    --arg name "test" \
    --argjson count 5 \
    '{name: $name, count: $count}')

# Complex query
result=$(jq_safe \
    --slurpfile config config.json \
    '.data | select(.enabled) | .[]' \
    data.json)
```

**Logging**: Enabled if DEBUG=true or WORKFLOW_LOG_FILE is set

**Dependencies**: None (wrapper around jq)

---

### file_operations.sh
**Purpose**: Safe file operations with pre-flight checks

**Functions**:

#### `check_file_exists(filepath, strategy)`
Handle file conflicts with configurable strategy
- **Parameters**:
  - `filepath`: File to check
  - `strategy`: Conflict resolution strategy
    - `fail`: Exit with error
    - `overwrite`: Replace existing file
    - `append_timestamp`: Add timestamp suffix
    - `increment`: Add numeric suffix
    - `prompt`: Ask user for decision
- **Returns**: 
  - 0: Proceed with operation
  - 1: Abort
  - 2: Use get_safe_filename

```bash
output_file="report.md"
if check_file_exists "$output_file" "append_timestamp"; then
    echo "Using: $output_file"
fi
```

#### `get_safe_filename(base_filename, strategy)`
Generate safe filename
- **Parameters**:
  - `base_filename`: Original filename
  - `strategy`: "timestamp" or "increment"
- **Returns**: Safe filename

```bash
safe_file=$(get_safe_filename "report.md" "timestamp")
# Returns: report_20260208_192735.md
```

**Dependencies**: utils.sh

---

## Module Dependency Map

```
Foundational Layer:
├── config.sh (no dependencies)
├── colors.sh (no dependencies)
└── jq_wrapper.sh (no dependencies)

Output & Utilities Layer:
├── utils.sh
│   └── colors.sh
├── file_operations.sh
│   └── utils.sh
└── validation.sh
    ├── config.sh
    └── utils.sh

Resource Management Layer:
├── cleanup_handlers.sh
│   └── utils.sh
└── session_manager.sh
    ├── utils.sh
    └── cleanup_handlers.sh

Step Orchestration Layer:
├── step_metadata.sh (no dependencies)
├── step_registry.sh
│   ├── config.sh
│   └── utils.sh
├── step_loader.sh
│   └── step_registry.sh
└── step_execution.sh
    ├── ai_helpers.sh
    └── utils.sh

AI Integration Layer:
├── ai_helpers.sh
│   ├── config.sh
│   └── utils.sh
└── ai_cache.sh
    └── utils.sh

Change Detection & Optimization Layer:
├── change_detection.sh (no dependencies)
├── conditional_execution.sh
│   └── config.sh
├── workflow_optimization.sh
│   ├── conditional_execution.sh
│   └── metrics.sh
└── skip_predictor.sh
    └── jq_wrapper.sh

Git & Dependencies Layer:
├── git_automation.sh (no dependencies)
└── dependency_graph.sh
    └── step_metadata.sh

Monitoring Layer:
├── metrics.sh
│   ├── config.sh
│   └── utils.sh
└── performance.sh
    └── utils.sh
```

---

## Quick Reference: Common Usage Patterns

### Pattern 1: Basic Step Execution
```bash
#!/bin/bash
source lib/config.sh
source lib/utils.sh
source lib/step_registry.sh
source lib/step_loader.sh

load_step_definitions
load_step_module "documentation_updates"
execute_step "documentation_updates"
```

### Pattern 2: Conditional Execution with Change Detection
```bash
source lib/conditional_execution.sh

if modified_files_contain "docs/"; then
    execute_step "documentation_updates"
else
    print_info "Skipping documentation update (no changes)"
fi
```

### Pattern 3: Parallel Execution
```bash
source lib/performance.sh

parallel_workflow_steps \
    execute_step_03 \
    execute_step_04 \
    execute_step_05
```

### Pattern 4: AI Integration with Caching
```bash
source lib/ai_helpers.sh
source lib/ai_cache.sh

init_ai_cache
cache_key=$(generate_cache_key "Analyze docs")

if ! response=$(get_cached_response "$cache_key"); then
    response=$(execute_copilot_prompt "Analyze documentation")
    cache_response "$cache_key" "$response"
fi
```

### Pattern 5: Session Management with Cleanup
```bash
source lib/session_manager.sh
source lib/cleanup_handlers.sh

init_cleanup
session_id=$(generate_session_id "07" "test_exec")
register_session "$session_id" "Running tests"

execute_with_session "07" "test_exec" "npm test" 300 "sync"
unregister_session "$session_id"
```

---

## See Also

- [ARCHITECTURE_DEEP_DIVE.md](ARCHITECTURE_DEEP_DIVE.md) - System architecture and design patterns
- [DEVELOPER_ONBOARDING.md](DEVELOPER_ONBOARDING.md) - Getting started guide for contributors
- [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - Integrating ai_workflow into your projects
- [PROJECT_REFERENCE.md](PROJECT_REFERENCE.md) - Single source of truth for project statistics

---

**Last Updated**: 2026-02-08  
**Version**: 4.0.0  
**Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))
