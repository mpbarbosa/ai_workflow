# AI Workflow Automation - Complete API Reference

**Version**: 3.0.0  
**Last Updated**: 2026-02-06  
**Status**: Comprehensive

## Table of Contents

- [Core Modules](#core-modules)
- [AI & Machine Learning](#ai--machine-learning)
- [File & Git Operations](#file--git-operations)
- [Metrics & Analytics](#metrics--analytics)
- [Configuration & Setup](#configuration--setup)
- [Execution & Optimization](#execution--optimization)
- [Validation & Testing](#validation--testing)
- [Utilities & Helpers](#utilities--helpers)

---

## Core Modules

### ai_helpers.sh

**Purpose**: AI prompt templates and GitHub Copilot CLI integration  
**Version**: 2.0.0  
**Location**: `src/workflow/lib/ai_helpers.sh`

#### Functions

##### `is_copilot_available()`
Check if GitHub Copilot CLI is installed.

**Returns**: 
- `0` - Copilot CLI available
- `1` - Copilot CLI not found

**Example**:
```bash
if is_copilot_available; then
    echo "Copilot CLI ready"
fi
```

##### `is_copilot_authenticated()`
Verify Copilot CLI authentication status.

**Returns**: 
- `0` - Authenticated
- `1` - Not authenticated or not available

**Example**:
```bash
if is_copilot_authenticated; then
    echo "Ready to use AI features"
fi
```

##### `validate_copilot_cli()`
Comprehensive validation with user feedback.

**Returns**: 
- `0` - CLI available and authenticated
- `1` - Not ready (displays help messages)

**Example**:
```bash
if ! validate_copilot_cli; then
    exit 1
fi
```

##### `get_project_metadata()`
Extract project information from `.workflow-config.yaml`.

**Returns**: Pipe-delimited string: `project_name|project_description|primary_language`

**Example**:
```bash
IFS='|' read -r name desc lang < <(get_project_metadata)
echo "Project: $name ($lang)"
```

##### `build_ai_prompt(persona, template_key, replacements...)`
Build AI prompt from templates with variable substitution.

**Parameters**:
- `persona` - AI persona name (e.g., "documentation_specialist")
- `template_key` - Template identifier from ai_helpers.yaml
- `replacements...` - Key-value pairs for variable substitution

**Returns**: Formatted prompt string

**Example**:
```bash
prompt=$(build_ai_prompt "documentation_specialist" "review_docs" \
    "PROJECT_NAME:MyApp" \
    "FILE_PATH:README.md" \
    "CHANGES:Added installation section")
```

##### `ai_call(persona, prompt, output_file)`
Execute AI request via Copilot CLI with caching.

**Parameters**:
- `persona` - AI persona name
- `prompt` - Complete prompt text
- `output_file` - Path to save response

**Returns**: 
- `0` - Success
- `1` - Error or AI unavailable

**Features**:
- Automatic response caching (24-hour TTL)
- Cache hit/miss tracking
- Error handling and retry logic

**Example**:
```bash
ai_call "code_reviewer" \
    "Review this function for bugs: $(cat src/utils.sh)" \
    "review_output.md"
```

---

### change_detection.sh

**Purpose**: Detect and classify code changes for smart workflow execution  
**Version**: 2.0.0  
**Location**: `src/workflow/lib/change_detection.sh`

#### Functions

##### `filter_workflow_artifacts(file_list)`
Remove workflow-generated files from change detection.

**Parameters**:
- `file_list` - Newline-separated file paths

**Returns**: Filtered file list (excludes artifacts)

**Excluded Patterns**:
- `.ai_workflow/backlog/*`
- `.ai_workflow/logs/*`
- `src/workflow/metrics/*`
- `*.tmp`, `*.bak`, `*.swp`
- `.DS_Store`, `Thumbs.db`

**Example**:
```bash
changed_files=$(git diff --name-only HEAD~1)
real_changes=$(filter_workflow_artifacts "$changed_files")
```

##### `is_workflow_artifact(file_path)`
Check if single file is a workflow artifact.

**Parameters**:
- `file_path` - Path to check

**Returns**: 
- `0` - Is artifact (should be ignored)
- `1` - Not an artifact

**Example**:
```bash
if is_workflow_artifact ".ai_workflow/logs/run.log"; then
    echo "Ignoring artifact"
fi
```

##### `detect_change_type()`
Classify changes as docs-only, tests-only, or full-changes.

**Returns**: String - "docs-only", "tests-only", "code-changes", or "full-changes"

**Detection Logic**:
- **docs-only**: Only `*.md`, `docs/*` changed
- **tests-only**: Only `tests/*`, `*.test.*` changed
- **code-changes**: Source files changed (triggers extensive validation)
- **full-changes**: Mixed changes

**Example**:
```bash
change_type=$(detect_change_type)
if [[ "$change_type" == "docs-only" ]]; then
    echo "Running documentation-only workflow (faster)"
fi
```

##### `analyze_changes()`
Comprehensive change analysis with detailed categorization.

**Returns**: JSON object with change statistics

**Output Structure**:
```json
{
  "total_files": 15,
  "docs": 5,
  "tests": 3,
  "source": 7,
  "change_type": "full-changes",
  "documentation_files": ["README.md", "docs/guide.md"],
  "test_files": ["tests/unit/test_api.sh"],
  "source_files": ["src/api.sh", "src/utils.sh"]
}
```

**Example**:
```bash
analysis=$(analyze_changes)
total=$(echo "$analysis" | jq -r '.total_files')
echo "Analyzing $total changed files"
```

---

### metrics.sh

**Purpose**: Track workflow execution metrics and performance  
**Version**: 2.0.0  
**Location**: `src/workflow/lib/metrics.sh`

#### Global Variables

```bash
METRICS_DIR           # Set by argument_parser before init
METRICS_CURRENT       # current_run.json path
METRICS_HISTORY       # history.jsonl path
METRICS_SUMMARY       # summary.md path

# Timing tracking
declare -A STEP_START_TIMES
declare -A STEP_END_TIMES
declare -A STEP_DURATIONS
declare -A STEP_STATUSES

# Workflow metrics
WORKFLOW_START_EPOCH
WORKFLOW_END_EPOCH
WORKFLOW_DURATION
WORKFLOW_SUCCESS
WORKFLOW_STEPS_COMPLETED
WORKFLOW_STEPS_FAILED
WORKFLOW_STEPS_SKIPPED
```

#### Functions

##### `init_metrics()`
Initialize metrics collection system.

**Prerequisites**: `METRICS_DIR` must be set by `argument_parser.sh`

**Creates**:
- Metrics directory structure
- `current_run.json` with workflow metadata
- `history.jsonl` if not exists

**Example**:
```bash
# In main workflow script
validate_parsed_arguments  # Sets METRICS_DIR
init_metrics              # Now safe to initialize
```

##### `record_step_start(step_name)`
Record step start time.

**Parameters**:
- `step_name` - Step identifier (e.g., "step_01_tech_stack")

**Example**:
```bash
record_step_start "step_02_documentation"
# ... execute step ...
record_step_end "step_02_documentation" "success"
```

##### `record_step_end(step_name, status)`
Record step completion and duration.

**Parameters**:
- `step_name` - Step identifier
- `status` - "success", "failed", or "skipped"

**Updates**:
- Step duration calculation
- Success/failure counters
- JSON metrics file

**Example**:
```bash
if execute_step_02; then
    record_step_end "step_02_documentation" "success"
else
    record_step_end "step_02_documentation" "failed"
fi
```

##### `get_step_duration(step_name)`
Retrieve step execution time.

**Parameters**:
- `step_name` - Step identifier

**Returns**: Duration in seconds

**Example**:
```bash
duration=$(get_step_duration "step_01_tech_stack")
echo "Step took ${duration}s"
```

##### `finalize_metrics()`
Complete metrics collection and generate summary.

**Actions**:
- Calculate total workflow duration
- Append to history file
- Generate summary Markdown report
- Calculate success rate

**Output**: Creates `metrics/summary.md` with:
- Workflow duration
- Step-by-step timing
- Success/failure breakdown
- Historical comparison

**Example**:
```bash
# At workflow end
finalize_metrics
echo "Metrics saved to ${METRICS_SUMMARY}"
```

##### `generate_metrics_report()`
Create detailed metrics report.

**Returns**: Markdown-formatted report

**Sections**:
- Workflow Overview
- Step Performance Table
- Historical Trends
- Optimization Recommendations

**Example**:
```bash
report=$(generate_metrics_report)
echo "$report" > reports/performance.md
```

##### `get_historical_average(step_name, count)`
Calculate average duration from history.

**Parameters**:
- `step_name` - Step identifier
- `count` - Number of historical runs (default: 10)

**Returns**: Average duration in seconds

**Used For**: ML optimization predictions

**Example**:
```bash
avg=$(get_historical_average "step_05_code_review" 20)
echo "Average: ${avg}s (based on 20 runs)"
```

---

## AI & Machine Learning

### ai_cache.sh

**Purpose**: Cache AI responses to reduce API calls and costs  
**Version**: 2.3.0  
**Location**: `src/workflow/lib/ai_cache.sh`

#### Configuration

```bash
AI_CACHE_DIR="${AI_CACHE_DIR:-.ai_cache}"
AI_CACHE_INDEX="${AI_CACHE_DIR}/index.json"
AI_CACHE_TTL="${AI_CACHE_TTL:-86400}"  # 24 hours default
AI_CACHE_ENABLED="${AI_CACHE_ENABLED:-true}"
```

#### Functions

##### `init_ai_cache()`
Initialize caching system.

**Creates**:
- Cache directory
- Index file with metadata

**Example**:
```bash
init_ai_cache
echo "Cache ready: $AI_CACHE_DIR"
```

##### `get_cache_key(persona, prompt)`
Generate SHA256 hash for cache lookup.

**Parameters**:
- `persona` - AI persona name
- `prompt` - Complete prompt text

**Returns**: 64-character hex string

**Example**:
```bash
key=$(get_cache_key "documentation_specialist" "Review README")
echo "Cache key: $key"
```

##### `cache_lookup(cache_key)`
Check if cached response exists and is valid.

**Parameters**:
- `cache_key` - SHA256 hash from get_cache_key

**Returns**: 
- `0` - Cache hit (writes response to stdout)
- `1` - Cache miss or expired

**Example**:
```bash
key=$(get_cache_key "$persona" "$prompt")
if cached=$(cache_lookup "$key"); then
    echo "Using cached response"
    echo "$cached" > output.md
else
    # Call AI and cache result
fi
```

##### `cache_store(cache_key, response_file)`
Store AI response in cache.

**Parameters**:
- `cache_key` - SHA256 hash
- `response_file` - Path to response content

**Actions**:
- Copies response to cache
- Updates index with timestamp and metadata
- Returns cache filename

**Example**:
```bash
key=$(get_cache_key "$persona" "$prompt")
ai_call "$persona" "$prompt" "temp_response.md"
cache_store "$key" "temp_response.md"
```

##### `cache_cleanup()`
Remove expired cache entries.

**Logic**:
- Removes entries older than `AI_CACHE_TTL`
- Updates index file
- Deletes orphaned cache files

**Auto-runs**: Every 24 hours automatically

**Example**:
```bash
cache_cleanup
echo "Old cache entries removed"
```

##### `cache_stats()`
Display cache performance metrics.

**Returns**: JSON with:
- Total entries
- Cache size (bytes)
- Hit rate
- Oldest/newest entries

**Example**:
```bash
cache_stats | jq '.hit_rate'
# Output: "73.5"
```

---

### ml_optimization.sh

**Purpose**: Machine learning-based workflow optimization  
**Version**: 2.7.0  
**Location**: `src/workflow/lib/ml_optimization.sh`

#### Requirements

- Minimum 10 historical workflow runs
- Valid metrics in `metrics/history.jsonl`
- Python 3.8+ with pandas, scikit-learn

#### Functions

##### `ml_optimize_enabled()`
Check if ML optimization is available.

**Checks**:
- `--ml-optimize` flag set
- Sufficient historical data (10+ runs)
- Required Python packages installed

**Returns**: 
- `0` - ML ready
- `1` - Not available (falls back to heuristics)

**Example**:
```bash
if ml_optimize_enabled; then
    echo "Using ML predictions"
else
    echo "Using heuristic optimization"
fi
```

##### `ml_predict_step_duration(step_name, change_type)`
Predict step execution time using trained model.

**Parameters**:
- `step_name` - Step identifier
- `change_type` - "docs-only", "tests-only", "code-changes"

**Returns**: Predicted duration in seconds

**Model**: Random Forest Regressor trained on historical data

**Example**:
```bash
predicted=$(ml_predict_step_duration "step_02_documentation" "docs-only")
echo "Estimated: ${predicted}s"
```

##### `ml_recommend_optimization()`
Generate optimization recommendations.

**Analysis**:
- Identifies slowest steps
- Suggests parallel execution opportunities
- Recommends skippable steps based on changes

**Returns**: JSON with recommendations

**Example**:
```bash
recommendations=$(ml_recommend_optimization)
echo "$recommendations" | jq '.parallel_candidates'
```

##### `ml_train_model()`
Train or retrain ML models.

**Data Sources**:
- `metrics/history.jsonl`
- Change detection logs
- Step execution patterns

**Models Created**:
- Step duration predictor
- Skip probability classifier
- Parallel execution suggester

**Example**:
```bash
# After accumulating 10+ workflow runs
ml_train_model
echo "Model updated with latest data"
```

##### `show_ml_status()`
Display ML system status and metrics.

**Output**:
- Model training status
- Historical data count
- Prediction accuracy metrics
- Last training timestamp

**Example**:
```bash
show_ml_status
# Output:
# ML Optimization Status
# ----------------------
# Historical runs: 47
# Model accuracy: 89.3%
# Last trained: 2026-02-05 14:30:22
```

---

## File & Git Operations

### file_operations.sh

**Purpose**: Safe file manipulation with validation  
**Version**: 2.0.0  
**Location**: `src/workflow/lib/file_operations.sh`

#### Functions

##### `safe_edit_file(file_path, old_content, new_content)`
Edit file with automatic backup and validation.

**Parameters**:
- `file_path` - Path to file
- `old_content` - Content to replace (must match exactly)
- `new_content` - Replacement content

**Safety Features**:
- Creates `.bak` backup before editing
- Validates old content exists
- Atomic operation (rollback on failure)
- Verifies edit completed successfully

**Returns**: 
- `0` - Success
- `1` - Content not found or edit failed

**Example**:
```bash
safe_edit_file "src/config.sh" \
    'VERSION="1.0.0"' \
    'VERSION="1.1.0"'
```

##### `batch_edit_files(pattern, old_content, new_content)`
Edit multiple files matching pattern.

**Parameters**:
- `pattern` - Glob pattern (e.g., "src/**/*.sh")
- `old_content` - Content to replace
- `new_content` - Replacement content

**Example**:
```bash
batch_edit_files "src/**/*.sh" \
    "#!/bin/bash" \
    "#!/usr/bin/env bash"
```

##### `validate_file_syntax(file_path, file_type)`
Validate file syntax based on type.

**Supported Types**:
- `bash` - shellcheck validation
- `json` - jq syntax check
- `yaml` - yamllint check
- `markdown` - markdownlint check

**Returns**: 
- `0` - Valid syntax
- `1` - Syntax errors found

**Example**:
```bash
if ! validate_file_syntax "script.sh" "bash"; then
    echo "Syntax errors found"
    exit 1
fi
```

##### `ensure_file_ends_with_newline(file_path)`
Ensure file ends with newline character.

**Parameters**:
- `file_path` - Path to file

**Example**:
```bash
ensure_file_ends_with_newline "README.md"
```

---

### git_automation.sh

**Purpose**: Git operations with safety checks  
**Version**: 2.6.0  
**Location**: `src/workflow/lib/git_automation.sh`

#### Functions

##### `git_safe_commit(message, files...)`
Commit files with validation.

**Parameters**:
- `message` - Commit message
- `files...` - Files to commit

**Safety Checks**:
- Verifies files exist
- Checks for conflicts
- Validates commit message format
- Ensures no uncommitted changes will be lost

**Example**:
```bash
git_safe_commit "docs: update API reference" \
    "docs/api/API_REFERENCE.md" \
    "docs/api/CHANGELOG.md"
```

##### `git_auto_commit_artifacts()`
Automatically commit workflow artifacts (v2.6.0+).

**Committed Artifacts**:
- Documentation updates (docs/*, *.md)
- Test files (tests/*)
- Generated code (when safe)

**Message Format**: Auto-generated based on changes

**Example**:
```bash
# Enable with --auto-commit flag
if [[ "$AUTO_COMMIT" == true ]]; then
    git_auto_commit_artifacts
fi
```

##### `git_detect_conflicts()`
Check for merge conflicts.

**Returns**: 
- `0` - No conflicts
- `1` - Conflicts detected

**Example**:
```bash
if git_detect_conflicts; then
    echo "ERROR: Resolve conflicts first"
    exit 1
fi
```

---

## Configuration & Setup

### config.sh

**Purpose**: Load and manage workflow configuration  
**Version**: 2.0.0  
**Location**: `src/workflow/lib/config.sh`

#### Configuration File

**Location**: `.workflow-config.yaml` (project root)

**Structure**:
```yaml
project:
  name: "My Project"
  description: "Project description"
  kind: "nodejs_api"  # See project_kinds.yaml

tech_stack:
  primary_language: "javascript"
  frameworks:
    - "express"
    - "jest"
  
testing:
  test_command: "npm test"
  coverage_command: "npm run test:coverage"
  test_framework: "jest"

workflow:
  enable_ai_cache: true
  ai_cache_ttl: 86400
  parallel_execution: true
  smart_execution: true
```

#### Functions

##### `load_config(config_file)`
Load configuration from YAML file.

**Parameters**:
- `config_file` - Path to .workflow-config.yaml

**Returns**: 
- `0` - Config loaded successfully
- `1` - File not found or invalid

**Example**:
```bash
if load_config ".workflow-config.yaml"; then
    echo "Configuration loaded"
fi
```

##### `get_config_value(key_path, default_value)`
Retrieve configuration value by dot-notation path.

**Parameters**:
- `key_path` - Dot-separated path (e.g., "project.name")
- `default_value` - Return if key not found

**Example**:
```bash
project_name=$(get_config_value "project.name" "Unnamed Project")
test_cmd=$(get_config_value "testing.test_command" "echo 'No tests'")
```

##### `set_config_value(key_path, value)`
Update configuration value.

**Parameters**:
- `key_path` - Dot-separated path
- `value` - New value

**Example**:
```bash
set_config_value "tech_stack.primary_language" "typescript"
```

##### `validate_config()`
Validate configuration completeness.

**Checks**:
- Required fields present
- Valid project.kind
- Test commands executable
- Path references valid

**Returns**: 
- `0` - Valid configuration
- `1` - Validation errors

**Example**:
```bash
if ! validate_config; then
    echo "Configuration errors found"
    exit 1
fi
```

---

### config_wizard.sh

**Purpose**: Interactive configuration setup  
**Version**: 2.0.0  
**Location**: `src/workflow/lib/config_wizard.sh`

#### Functions

##### `run_config_wizard()`
Interactive wizard to create .workflow-config.yaml.

**Features**:
- Project detection
- Tech stack auto-detection
- Test framework configuration
- Validation and preview

**Example**:
```bash
# Run with --init-config flag
./execute_tests_docs_workflow.sh --init-config
```

##### `detect_project_kind()`
Auto-detect project type from directory contents.

**Detection Logic**:
- `package.json` → Node.js project
- `requirements.txt` → Python project
- `*.sh` files → Shell script automation
- `src/components/` → React/Vue SPA

**Returns**: Project kind string

**Example**:
```bash
kind=$(detect_project_kind)
echo "Detected: $kind"
```

---

## Execution & Optimization

### workflow_optimization.sh

**Purpose**: Smart execution and parallel processing  
**Version**: 2.3.0  
**Location**: `src/workflow/lib/workflow_optimization.sh`

#### Functions

##### `optimize_workflow_execution()`
Main optimization coordinator.

**Strategies**:
1. Change detection and step skipping
2. Parallel execution of independent steps
3. ML-based duration prediction
4. Resource allocation optimization

**Returns**: Optimized execution plan (JSON)

**Example**:
```bash
plan=$(optimize_workflow_execution)
echo "$plan" | jq '.steps_to_execute'
```

##### `determine_skippable_steps(change_type)`
Identify steps that can be skipped.

**Parameters**:
- `change_type` - "docs-only", "tests-only", "code-changes"

**Skip Logic**:
- **docs-only**: Skip code review, test generation
- **tests-only**: Skip documentation steps
- **code-changes**: Run all validation steps

**Returns**: Array of step names to skip

**Example**:
```bash
skippable=$(determine_skippable_steps "docs-only")
echo "Skipping: $skippable"
```

##### `get_parallel_candidates()`
Find steps that can run in parallel.

**Analysis**:
- Dependency graph
- Resource requirements
- Previous execution patterns

**Returns**: Arrays of step groups that can run together

**Example**:
```bash
candidates=$(get_parallel_candidates)
# Output: [["step_2", "step_3"], ["step_5", "step_6"]]
```

##### `calculate_optimization_savings()`
Estimate time saved by optimization.

**Returns**: JSON with:
- Baseline duration
- Optimized duration
- Time saved
- Percentage improvement

**Example**:
```bash
savings=$(calculate_optimization_savings)
echo "$savings" | jq '.percentage_improvement'
# Output: "67.3"
```

---

### multi_stage_pipeline.sh

**Purpose**: Progressive validation with three stages  
**Version**: 2.8.0  
**Location**: `src/workflow/lib/multi_stage_pipeline.sh`

#### Pipeline Stages

**Stage 1: Fast Validation** (2-3 minutes)
- Syntax checking
- Basic linting
- Quick smoke tests
- Success rate: 40% of runs stop here

**Stage 2: Core Validation** (8-10 minutes)
- Documentation review
- Test execution
- Code review
- Success rate: 40% stop here (80% cumulative)

**Stage 3: Comprehensive** (15-20 minutes)
- Full test suite
- Integration tests
- UX analysis
- Final validation

#### Functions

##### `execute_multi_stage_pipeline()`
Run progressive validation workflow.

**Behavior**:
- Stops at first stage that passes (unless --manual-trigger)
- Each stage gates the next
- Reports progress after each stage

**Example**:
```bash
# Use with --multi-stage flag
./execute_tests_docs_workflow.sh --multi-stage
```

##### `should_proceed_to_next_stage(stage_name)`
Determine if next stage is needed.

**Parameters**:
- `stage_name` - Current stage ("fast", "core", "comprehensive")

**Returns**: 
- `0` - Proceed to next stage
- `1` - Stop here (validation complete)

**Example**:
```bash
if should_proceed_to_next_stage "fast"; then
    echo "Issues found, running core validation"
fi
```

##### `show_pipeline_config()`
Display pipeline configuration and stage definitions.

**Example**:
```bash
./execute_tests_docs_workflow.sh --show-pipeline
```

---

## Validation & Testing

### validation.sh

**Purpose**: Pre-execution validation and health checks  
**Version**: 2.0.0  
**Location**: `src/workflow/lib/validation.sh`

#### Functions

##### `validate_prerequisites()`
Check all required tools are installed.

**Checks**:
- Bash version ≥ 4.0
- Git installed and configured
- Node.js ≥ 25.2.1 (if Node project)
- Python ≥ 3.8 (if Python project)
- GitHub Copilot CLI (optional)

**Returns**: 
- `0` - All requirements met
- `1` - Missing prerequisites

**Example**:
```bash
if ! validate_prerequisites; then
    echo "Install missing dependencies first"
    exit 1
fi
```

##### `validate_project_structure()`
Verify project directory structure.

**Checks**:
- Git repository initialized
- Configuration file exists
- Source directories present
- Test directories accessible

**Example**:
```bash
validate_project_structure || exit 1
```

##### `validate_step_dependencies(step_name)`
Check step prerequisites met.

**Parameters**:
- `step_name` - Step identifier

**Checks**:
- Previous steps completed
- Required files exist
- External tools available

**Example**:
```bash
if ! validate_step_dependencies "step_05_code_review"; then
    echo "Prerequisites not met"
    exit 1
fi
```

---

### precommit_hooks.sh

**Purpose**: Fast pre-commit validation (< 1 second)  
**Version**: 3.0.0  
**Location**: `src/workflow/lib/precommit_hooks.sh`

#### Functions

##### `install_precommit_hooks()`
Install Git pre-commit hook.

**Installs**: `.git/hooks/pre-commit` script

**Checks**:
- Syntax validation (shellcheck, jq, yamllint)
- File formatting
- No debug statements
- No TODO/FIXME in production code

**Example**:
```bash
./execute_tests_docs_workflow.sh --install-hooks
```

##### `test_precommit_hooks()`
Test hooks without committing.

**Example**:
```bash
./execute_tests_docs_workflow.sh --test-hooks
```

##### `validate_commit_files()`
Validate files in staging area.

**Returns**: 
- `0` - All files valid
- `1` - Validation errors (commit blocked)

---

## Utilities & Helpers

### utils.sh

**Purpose**: Common utility functions  
**Version**: 2.0.0  
**Location**: `src/workflow/lib/utils.sh`

#### Functions

##### `print_success(message)`
Print success message in green.

##### `print_error(message)`
Print error message in red to stderr.

##### `print_warning(message)`
Print warning message in yellow.

##### `print_info(message)`
Print info message in blue.

##### `confirm(message, default)`
Interactive confirmation prompt.

**Parameters**:
- `message` - Prompt text
- `default` - "y" or "n"

**Returns**: 
- `0` - Yes
- `1` - No

**Example**:
```bash
if confirm "Continue with optimization?" "y"; then
    optimize_workflow_execution
fi
```

##### `retry(max_attempts, command...)`
Retry command on failure.

**Parameters**:
- `max_attempts` - Maximum retry count
- `command...` - Command to execute

**Example**:
```bash
retry 3 git push origin main
```

---

## Module Cross-Reference

### Step Module Dependencies

| Step | Required Modules |
|------|------------------|
| step_00_analyze | change_detection, analysis_cache |
| step_01_tech_stack | tech_stack, config |
| step_02_documentation | ai_helpers, ai_personas, doc_template_validator |
| step_03_dependencies | git_automation, validation |
| step_05_code_review | ai_helpers, code_changes_optimization |
| step_07_unit_tests | validation, metrics |
| step_15_version_update | version_bump, git_automation |

### Orchestrator Dependencies

| Orchestrator | Purpose | Key Modules |
|--------------|---------|-------------|
| pre_flight | Prerequisites check | validation, config, health_check |
| validation | Execution validation | step_validation_cache, dependency_graph |
| quality | Code quality checks | ai_helpers, metrics |
| finalization | Cleanup and reporting | summary, metrics, auto_commit |

---

## Usage Examples

### Complete Workflow Example

```bash
#!/bin/bash
set -euo pipefail

# Source required modules
source "src/workflow/lib/config.sh"
source "src/workflow/lib/validation.sh"
source "src/workflow/lib/change_detection.sh"
source "src/workflow/lib/metrics.sh"
source "src/workflow/lib/workflow_optimization.sh"

# Load configuration
load_config ".workflow-config.yaml"

# Validate prerequisites
validate_prerequisites || exit 1

# Initialize metrics
init_metrics

# Detect changes
change_type=$(detect_change_type)
echo "Change type: $change_type"

# Optimize execution
plan=$(optimize_workflow_execution)

# Execute workflow
for step in $(echo "$plan" | jq -r '.steps_to_execute[]'); do
    record_step_start "$step"
    
    if execute_step "$step"; then
        record_step_end "$step" "success"
    else
        record_step_end "$step" "failed"
        exit 1
    fi
done

# Finalize
finalize_metrics
echo "Workflow complete: $(get_workflow_duration)s"
```

### Custom AI Integration

```bash
#!/bin/bash

source "src/workflow/lib/ai_helpers.sh"
source "src/workflow/lib/ai_cache.sh"

# Initialize AI subsystem
validate_copilot_cli || exit 1
init_ai_cache

# Build prompt
prompt=$(build_ai_prompt "code_reviewer" "review_function" \
    "FUNCTION_NAME:calculate_metrics" \
    "FILE_PATH:src/workflow/lib/metrics.sh" \
    "LANGUAGE:bash")

# Check cache first
cache_key=$(get_cache_key "code_reviewer" "$prompt")
if cached_response=$(cache_lookup "$cache_key"); then
    echo "Using cached review"
    echo "$cached_response"
else
    # Call AI and cache
    ai_call "code_reviewer" "$prompt" "review.md"
    cache_store "$cache_key" "review.md"
    cat "review.md"
fi
```

---

## API Stability

### Stable APIs (v2.0+)
- Core module functions (ai_helpers, change_detection, metrics)
- Configuration format
- Metrics JSON structure

### Beta APIs (v3.0)
- ML optimization functions
- Multi-stage pipeline
- Pre-commit hooks

### Internal APIs (may change)
- Step metadata format
- Cache index structure
- Internal validation functions

---

## See Also

- [Module Development Guide](../developer-guide/MODULE_DEVELOPMENT.md)
- [Testing Guide](../developer-guide/testing.md)
- [Architecture Overview](../developer-guide/architecture.md)
- [Project Reference](../PROJECT_REFERENCE.md)
