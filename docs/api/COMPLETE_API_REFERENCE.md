# Complete API Reference - AI Workflow Automation

**Version**: v3.2.7  
**Last Updated**: 2026-02-08  
**Status**: Comprehensive API documentation for all modules

> 📋 **Note**: This is the complete API reference for all library modules, step modules, and orchestrators. For quick reference, see [API_REFERENCE.md](./API_REFERENCE.md).

## Table of Contents

- [Core Modules (12)](#core-modules)
- [Supporting Modules (61)](#supporting-modules)
- [Step Modules (20)](#step-modules)
- [Orchestrator Modules (4)](#orchestrator-modules)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)

---

## Core Modules

These are the foundational modules that provide essential functionality for the workflow system.

### ai_helpers.sh

**Purpose**: AI prompt templates and GitHub Copilot CLI integration  
**Size**: 102K  
**Location**: `src/workflow/lib/ai_helpers.sh`

#### Functions

##### is_copilot_available()
Check if GitHub Copilot CLI is available in the system.

**Returns**: 
- `0` if Copilot CLI is available
- `1` if not available

**Example**:
```bash
if is_copilot_available; then
    echo "Copilot CLI is ready"
fi
```

##### is_copilot_authenticated()
Check if GitHub Copilot CLI is authenticated.

**Returns**: 
- `0` if authenticated
- `1` if not authenticated

**Example**:
```bash
if ! is_copilot_authenticated; then
    echo "Please authenticate with: gh auth login"
    exit 1
fi
```

##### validate_copilot_cli()
Validate Copilot CLI availability and authentication with user feedback.

**Usage**: `validate_copilot_cli`

**Returns**:
- `0` if Copilot CLI is ready
- `1` if validation fails

**Example**:
```bash
validate_copilot_cli || exit 1
```

##### get_project_metadata()
Extract project metadata from configuration.

**Returns**: Pipe-delimited string: `project_name|project_description|primary_language`

**Example**:
```bash
local metadata
metadata=$(get_project_metadata)
IFS='|' read -r project_name project_desc language <<< "$metadata"
```

##### build_ai_prompt()
Build a structured AI prompt with role, task, and standards.

**Parameters**:
- `$1` - role: The AI persona role
- `$2` - task: The task description
- `$3` - standards: Quality standards to apply

**Returns**: Complete prompt string to stdout

**Example**:
```bash
local prompt
prompt=$(build_ai_prompt "documentation_specialist" \
                         "Analyze README.md for completeness" \
                         "Clear structure, accurate examples")
```

##### compose_role_from_yaml()
Compose role text from YAML configuration with anchor support.

**Parameters**:
- `$1` - yaml_file: Path to YAML configuration
- `$2` - prompt_section: Section name in YAML

**Returns**: Complete role text

**Example**:
```bash
local role
role=$(compose_role_from_yaml "config/ai_helpers.yaml" "doc_analysis")
```

##### build_doc_analysis_prompt()
Build a specialized prompt for documentation analysis.

**Parameters**:
- `$1` - doc_file: Path to documentation file
- `$2` - project_context: Optional project context

**Returns**: Documentation analysis prompt

**Example**:
```bash
local prompt
prompt=$(build_doc_analysis_prompt "README.md" "shell_script_automation")
```

##### build_consistency_prompt()
Build a prompt for consistency checking across documentation.

**Parameters**:
- `$1` - files: Array of files to check
- `$2` - standards: Consistency standards

**Returns**: Consistency check prompt

##### build_test_strategy_prompt()
Build a prompt for test strategy generation.

**Parameters**:
- `$1` - code_files: Files to test
- `$2` - test_framework: Framework to use

**Returns**: Test strategy prompt

##### build_quality_prompt()
Build a prompt for code quality analysis.

**Parameters**:
- `$1` - code_files: Files to analyze
- `$2` - quality_standards: Standards to apply

**Returns**: Quality analysis prompt

##### build_issue_extraction_prompt()
Build a prompt for extracting issues from analysis.

**Parameters**:
- `$1` - analysis_file: Path to analysis file

**Returns**: Issue extraction prompt

##### log_ai_prompt()
Log an AI prompt to the workflow log.

**Parameters**:
- `$1` - step_id: Current step identifier
- `$2` - prompt: Prompt text to log

**Returns**: `0` on success

##### get_model_for_step()
Get the appropriate AI model for a workflow step.

**Parameters**:
- `$1` - step_id: Step identifier

**Returns**: Model name (e.g., "claude-sonnet-4.5")

**Example**:
```bash
local model
model=$(get_model_for_step "step_5")
```

##### get_current_step_id()
Get the current step identifier from context.

**Returns**: Step ID string

##### execute_copilot_batch()
Execute a batch of Copilot CLI commands.

**Parameters**:
- `$1` - commands_file: File containing commands
- `$2` - output_dir: Directory for outputs

**Returns**: `0` on success, `1` on failure

##### execute_copilot_prompt()
Execute a single Copilot CLI prompt.

**Parameters**:
- `$1` - prompt: Prompt text
- `$2` - output_file: File to save response
- `$3` - model: Optional model override

**Returns**: `0` on success, `1` on failure

**Example**:
```bash
execute_copilot_prompt "$prompt" "response.md" "claude-sonnet-4.5"
```

##### trigger_ai_step()
Trigger an AI-powered workflow step.

**Parameters**:
- `$1` - step_id: Step identifier
- `$2` - persona: AI persona to use
- `$3` - task: Task description

**Returns**: `0` on success, `1` on failure

##### extract_and_save_issues_from_log()
Extract issues from AI analysis log and save them.

**Parameters**:
- `$1` - log_file: Path to log file
- `$2` - output_file: File to save issues

**Returns**: `0` on success

##### get_language_documentation_conventions()
Get documentation conventions for a programming language.

**Parameters**:
- `$1` - language: Programming language name

**Returns**: Documentation conventions string

**Example**:
```bash
local conventions
conventions=$(get_language_documentation_conventions "javascript")
```

##### get_language_quality_standards()
Get quality standards for a programming language.

**Parameters**:
- `$1` - language: Programming language name

**Returns**: Quality standards string

---

### tech_stack.sh

**Purpose**: Technology stack detection and configuration  
**Size**: 47K  
**Location**: `src/workflow/lib/tech_stack.sh`

#### Functions

##### init_tech_stack()
Initialize technology stack detection and configuration.

**Returns**: `0` on success

**Example**:
```bash
init_tech_stack || { echo "Failed to initialize tech stack"; exit 1; }
```

##### load_tech_stack_config()
Load technology stack from configuration file.

**Parameters**:
- `$1` - config_file: Optional path to config file (defaults to `.workflow-config.yaml`)

**Returns**: `0` on success, `1` if file not found

**Example**:
```bash
load_tech_stack_config ".custom-config.yaml"
```

##### parse_yaml_config()
Parse YAML configuration file.

**Parameters**:
- `$1` - yaml_file: Path to YAML file

**Returns**: Parsed configuration as key-value pairs

**Example**:
```bash
parse_yaml_config ".workflow-config.yaml" | while IFS='=' read -r key value; do
    echo "$key: $value"
done
```

##### get_config_value()
Get a specific value from configuration.

**Parameters**:
- `$1` - key: Configuration key (supports dot notation)

**Returns**: Configuration value

**Example**:
```bash
local primary_lang
primary_lang=$(get_config_value "tech_stack.primary_language")
```

##### detect_tech_stack()
Automatically detect the technology stack of the current project.

**Returns**: `0` on success

**Example**:
```bash
if detect_tech_stack; then
    echo "Tech stack detected: $PRIMARY_LANGUAGE"
fi
```

##### detect_javascript_project()
Detect if the project is a JavaScript/Node.js project.

**Returns**: Confidence score (0-100)

##### detect_python_project()
Detect if the project is a Python project.

**Returns**: Confidence score (0-100)

##### detect_go_project()
Detect if the project is a Go project.

**Returns**: Confidence score (0-100)

##### detect_java_project()
Detect if the project is a Java project.

**Returns**: Confidence score (0-100)

##### detect_ruby_project()
Detect if the project is a Ruby project.

**Returns**: Confidence score (0-100)

##### detect_rust_project()
Detect if the project is a Rust project.

**Returns**: Confidence score (0-100)

##### detect_cpp_project()
Detect if the project is a C/C++ project.

**Returns**: Confidence score (0-100)

##### detect_bash_project()
Detect if the project is a Bash/Shell script project.

**Returns**: Confidence score (0-100)

##### get_confidence_score()
Calculate confidence score based on detected indicators.

**Parameters**:
- `$1` - indicators: JSON object with indicator counts

**Returns**: Confidence score (0-100)

##### load_default_tech_stack()
Load default technology stack configuration.

**Returns**: `0` on success

##### export_tech_stack_variables()
Export technology stack variables to environment.

**Returns**: `0` on success

**Example**:
```bash
export_tech_stack_variables
echo "Language: $PRIMARY_LANGUAGE"
echo "Framework: $PRIMARY_FRAMEWORK"
```

##### init_tech_stack_cache()
Initialize technology stack cache.

**Returns**: `0` on success

##### get_tech_stack_property()
Get a specific property from the tech stack.

**Parameters**:
- `$1` - property: Property name

**Returns**: Property value

**Example**:
```bash
local test_cmd
test_cmd=$(get_tech_stack_property "test_command")
```

##### print_tech_stack_summary()
Print a summary of the detected technology stack.

**Usage**: `print_tech_stack_summary`

**Example**:
```bash
print_tech_stack_summary
# Output:
# Technology Stack Summary
# ========================
# Primary Language: JavaScript
# Framework: React
# Package Manager: npm
# ...
```

##### is_language_supported()
Check if a programming language is supported.

**Parameters**:
- `$1` - language: Language name

**Returns**: `0` if supported, `1` if not

**Example**:
```bash
if is_language_supported "typescript"; then
    echo "TypeScript is supported"
fi
```

---

### workflow_optimization.sh

**Purpose**: Smart execution, parallel processing, and checkpoint management  
**Size**: 31K  
**Location**: `src/workflow/lib/workflow_optimization.sh`

#### Functions

##### should_skip_step_by_impact()
Determine if a step should be skipped based on change impact analysis.

**Parameters**:
- `$1` - step_id: Step identifier
- `$2` - change_type: Type of changes detected

**Returns**: `0` if step should be skipped, `1` if it should run

**Example**:
```bash
if should_skip_step_by_impact "step_5" "docs_only"; then
    echo "Skipping step 5 - no relevant changes"
    return 0
fi
```

##### analyze_change_impact()
Analyze the impact of recent changes on workflow steps.

**Returns**: JSON object with change analysis

**Example**:
```bash
local impact
impact=$(analyze_change_impact)
echo "$impact" | jq '.change_type'
```

##### execute_parallel_tracks()
Execute independent workflow steps in parallel.

**Parameters**:
- `$1` - track_config: JSON configuration of parallel tracks

**Returns**: `0` if all tracks succeed, `1` if any fail

**Example**:
```bash
local config='{"track1": ["step_2", "step_3"], "track2": ["step_5", "step_6"]}'
execute_parallel_tracks "$config"
```

##### generate_parallel_tracks_report()
Generate a report of parallel execution.

**Parameters**:
- `$1` - execution_log: Path to execution log

**Returns**: `0` on success

##### execute_parallel_validation()
Execute validation steps in parallel.

**Parameters**:
- `$@` - step_ids: List of step identifiers

**Returns**: `0` if all validations pass

**Example**:
```bash
execute_parallel_validation "step_2" "step_3" "step_5"
```

##### save_checkpoint()
Save a workflow checkpoint for resume capability.

**Parameters**:
- `$1` - step_id: Current step identifier
- `$2` - state: Optional state data to save

**Returns**: `0` on success

**Example**:
```bash
save_checkpoint "step_7" "$(echo "$metrics" | jq -c .)"
```

##### load_checkpoint()
Load the last workflow checkpoint.

**Returns**: Checkpoint data as JSON

**Example**:
```bash
local checkpoint
checkpoint=$(load_checkpoint)
local last_step
last_step=$(echo "$checkpoint" | jq -r '.last_step')
```

##### cleanup_old_checkpoints()
Clean up old checkpoint files.

**Parameters**:
- `$1` - retention_days: Number of days to retain (default: 7)

**Returns**: `0` on success

**Example**:
```bash
cleanup_old_checkpoints 14  # Keep 14 days of checkpoints
```

---

### change_detection.sh

**Purpose**: Git diff analysis and change type classification  
**Size**: 17K  
**Location**: `src/workflow/lib/change_detection.sh`

#### Functions

##### filter_workflow_artifacts()
Filter out workflow-generated artifacts from change detection.

**Parameters**:
- `$1` - file_list: List of files (one per line)

**Returns**: Filtered list of files

**Example**:
```bash
git diff --name-only | filter_workflow_artifacts
```

##### is_workflow_artifact()
Check if a file is a workflow-generated artifact.

**Parameters**:
- `$1` - file_path: Path to file

**Returns**: `0` if it's an artifact, `1` if not

**Example**:
```bash
if is_workflow_artifact "backlog/workflow_20260208/step_2.md"; then
    echo "Skipping artifact file"
fi
```

##### detect_change_type()
Detect the type of changes in the repository.

**Returns**: Change type string: `docs_only`, `code_only`, `tests_only`, `mixed`, or `none`

**Example**:
```bash
local change_type
change_type=$(detect_change_type)
echo "Detected changes: $change_type"
```

##### matches_pattern()
Check if a file matches a pattern.

**Parameters**:
- `$1` - file_path: File to check
- `$2` - pattern: Glob pattern

**Returns**: `0` if matches, `1` if not

**Example**:
```bash
if matches_pattern "src/utils.js" "*.js"; then
    echo "JavaScript file"
fi
```

##### analyze_changes()
Perform comprehensive analysis of repository changes.

**Returns**: JSON object with detailed change analysis

**Example**:
```bash
local analysis
analysis=$(analyze_changes)
echo "$analysis" | jq '.statistics'
```

##### get_recommended_steps()
Get recommended workflow steps based on changes.

**Parameters**:
- `$1` - change_type: Type of changes detected

**Returns**: Space-separated list of step IDs

**Example**:
```bash
local steps
steps=$(get_recommended_steps "docs_only")
echo "Recommended steps: $steps"
```

##### should_execute_step()
Determine if a specific step should execute based on changes.

**Parameters**:
- `$1` - step_id: Step identifier
- `$2` - change_type: Type of changes

**Returns**: `0` if step should execute, `1` if not

**Example**:
```bash
if should_execute_step "step_5" "$CHANGE_TYPE"; then
    execute_step_5
fi
```

##### display_execution_plan()
Display the execution plan based on change analysis.

**Parameters**:
- `$1` - steps: List of steps to execute

**Returns**: `0` on success

**Example**:
```bash
display_execution_plan "$RECOMMENDED_STEPS"
```

##### get_step_name_for_display()
Get a human-readable name for a step.

**Parameters**:
- `$1` - step_id: Step identifier

**Returns**: Step name string

**Example**:
```bash
local name
name=$(get_step_name_for_display "step_5")
echo "Executing: $name"
```

##### assess_change_impact()
Assess the impact level of changes.

**Returns**: Impact level: `low`, `medium`, `high`

**Example**:
```bash
local impact
impact=$(assess_change_impact)
if [[ "$impact" == "high" ]]; then
    echo "Running full validation suite"
fi
```

##### generate_change_report()
Generate a detailed report of changes.

**Parameters**:
- `$1` - output_file: File to save report

**Returns**: `0` on success

**Example**:
```bash
generate_change_report "backlog/workflow_$(date +%Y%m%d_%H%M%S)/CHANGE_REPORT.md"
```

##### classify_files_by_nature()
Classify changed files by their nature (docs, code, tests, config).

**Parameters**:
- `$1` - file_list: List of files

**Returns**: JSON object with file classifications

**Example**:
```bash
local files
files=$(git diff --name-only)
local classification
classification=$(classify_files_by_nature "$files")
```

---

### metrics.sh

**Purpose**: Performance tracking and metrics collection  
**Size**: 16K  
**Location**: `src/workflow/lib/metrics.sh`

#### Functions

##### init_metrics()
Initialize metrics collection for the workflow run.

**Returns**: `0` on success

**Example**:
```bash
init_metrics
```

##### get_execution_mode()
Get the current execution mode.

**Returns**: Mode string: `normal`, `smart`, `parallel`, `smart_parallel`

**Example**:
```bash
local mode
mode=$(get_execution_mode)
echo "Execution mode: $mode"
```

##### start_step_timer()
Start a timer for a workflow step.

**Parameters**:
- `$1` - step_id: Step identifier

**Returns**: `0` on success

**Example**:
```bash
start_step_timer "step_5"
# ... execute step ...
stop_step_timer "step_5"
```

##### stop_step_timer()
Stop a timer for a workflow step.

**Parameters**:
- `$1` - step_id: Step identifier

**Returns**: Duration in seconds

**Example**:
```bash
local duration
duration=$(stop_step_timer "step_5")
echo "Step 5 took: ${duration}s"
```

##### get_step_name()
Get the name of a step from its ID.

**Parameters**:
- `$1` - step_id: Step identifier

**Returns**: Step name string

##### start_phase_timer()
Start a timer for a workflow phase.

**Parameters**:
- `$1` - phase_name: Phase identifier

**Returns**: `0` on success

##### stop_phase_timer()
Stop a timer for a workflow phase.

**Parameters**:
- `$1` - phase_name: Phase identifier

**Returns**: Duration in seconds

##### generate_phase_report()
Generate a report for a completed phase.

**Parameters**:
- `$1` - phase_name: Phase identifier

**Returns**: `0` on success

##### update_current_run_step()
Update the current run metrics with step completion.

**Parameters**:
- `$1` - step_id: Step identifier
- `$2` - status: Step status (success/failure/skipped)
- `$3` - duration: Step duration in seconds

**Returns**: `0` on success

##### finalize_metrics()
Finalize metrics collection and generate reports.

**Returns**: `0` on success

**Example**:
```bash
init_metrics
# ... execute workflow ...
finalize_metrics
```

##### generate_metrics_summary()
Generate a summary of workflow metrics.

**Returns**: Summary text

**Example**:
```bash
local summary
summary=$(generate_metrics_summary)
echo "$summary"
```

##### get_workflow_status_emoji()
Get an emoji representing workflow status.

**Parameters**:
- `$1` - status: Status string

**Returns**: Emoji character

##### format_duration()
Format a duration in seconds to human-readable format.

**Parameters**:
- `$1` - seconds: Duration in seconds

**Returns**: Formatted duration (e.g., "2m 30s")

**Example**:
```bash
local formatted
formatted=$(format_duration 150)
echo "Duration: $formatted"  # Output: Duration: 2m 30s
```

##### generate_step_timing_table()
Generate a table of step timings.

**Returns**: Formatted table text

##### get_step_status_emoji()
Get an emoji for step status.

**Parameters**:
- `$1` - status: Status string

**Returns**: Emoji character

##### generate_historical_stats()
Generate statistics from historical workflow runs.

**Returns**: JSON object with statistics

**Example**:
```bash
local stats
stats=$(generate_historical_stats)
echo "$stats" | jq '.average_duration'
```

##### calculate_average_duration()
Calculate average duration for a step from history.

**Parameters**:
- `$1` - step_id: Step identifier

**Returns**: Average duration in seconds

##### display_recent_runs()
Display information about recent workflow runs.

**Parameters**:
- `$1` - count: Number of runs to display (default: 5)

**Returns**: `0` on success

##### get_success_rate()
Get the success rate from historical runs.

**Returns**: Success rate as percentage

##### get_average_step_duration()
Get average duration for a specific step.

**Parameters**:
- `$1` - step_id: Step identifier

**Returns**: Average duration in seconds

---

### performance.sh

**Purpose**: Performance utilities and optimization helpers  
**Size**: 16K  
**Location**: `src/workflow/lib/performance.sh`

#### Functions

##### parallel_execute()
Execute multiple commands in parallel.

**Parameters**:
- `$@` - commands: Commands to execute

**Returns**: `0` if all succeed, `1` if any fail

**Example**:
```bash
parallel_execute "npm test" "npm run lint" "npm run build"
```

##### parallel_workflow_steps()
Execute workflow steps in parallel.

**Parameters**:
- `$@` - step_ids: Step identifiers

**Returns**: `0` if all succeed

##### fast_find()
Fast file finding with caching.

**Parameters**:
- `$1` - pattern: File pattern
- `$2` - directory: Starting directory

**Returns**: List of matching files

**Example**:
```bash
local js_files
js_files=$(fast_find "*.js" "src")
```

##### fast_find_modified()
Fast finding of modified files with git.

**Parameters**:
- `$1` - since: Git ref (default: HEAD)

**Returns**: List of modified files

##### fast_grep()
Fast grep with optimizations.

**Parameters**:
- `$1` - pattern: Search pattern
- `$2` - files: Files to search

**Returns**: Matching lines

##### fast_grep_count()
Fast grep with count only.

**Parameters**:
- `$1` - pattern: Search pattern
- `$2` - files: Files to search

**Returns**: Count of matches

##### cache_get()
Get a value from cache.

**Parameters**:
- `$1` - key: Cache key

**Returns**: Cached value or empty

**Example**:
```bash
local cached
cached=$(cache_get "step_5_result")
if [[ -n "$cached" ]]; then
    echo "Using cached result"
fi
```

##### cache_set()
Set a value in cache.

**Parameters**:
- `$1` - key: Cache key
- `$2` - value: Value to cache
- `$3` - ttl: Time to live in seconds (optional)

**Returns**: `0` on success

**Example**:
```bash
cache_set "step_5_result" "$result" 3600  # Cache for 1 hour
```

##### cache_clear()
Clear the cache.

**Parameters**:
- `$1` - pattern: Optional pattern to match keys

**Returns**: `0` on success

##### memoize()
Memoize a function call.

**Parameters**:
- `$1` - function_name: Function to memoize
- `$@` - arguments: Function arguments

**Returns**: Function result (cached or fresh)

##### batch_git_commands()
Execute multiple git commands efficiently.

**Parameters**:
- `$@` - commands: Git commands

**Returns**: `0` on success

##### fast_file_count()
Fast file counting.

**Parameters**:
- `$1` - directory: Directory to count

**Returns**: File count

##### fast_dir_size()
Fast directory size calculation.

**Parameters**:
- `$1` - directory: Directory path

**Returns**: Size in bytes

##### time_command()
Time a command execution.

**Parameters**:
- `$@` - command: Command to time

**Returns**: Duration in seconds

**Example**:
```bash
local duration
duration=$(time_command npm test)
echo "Tests took: ${duration}s"
```

##### profile_section()
Profile a section of code.

**Parameters**:
- `$1` - section_name: Name of section
- `$2` - command: Command to profile

**Returns**: Profiling information

##### generate_perf_report()
Generate a performance report.

**Returns**: `0` on success

##### batch_process()
Process items in batches.

**Parameters**:
- `$1` - batch_size: Items per batch
- `$2` - processor: Function to process items
- `$@` - items: Items to process

**Returns**: `0` on success

##### lazy_load()
Lazy load a module or resource.

**Parameters**:
- `$1` - resource: Resource to load

**Returns**: `0` on success

##### parallel_file_process()
Process files in parallel.

**Parameters**:
- `$1` - processor: Function to process each file
- `$@` - files: Files to process

**Returns**: `0` on success

##### execute_if_needed()
Execute a command only if needed (based on timestamps).

**Parameters**:
- `$1` - target: Target file
- `$2` - dependencies: Dependency files
- `$3` - command: Command to execute

**Returns**: `0` on success

---

## Supporting Modules

> 📋 **Note**: This section documents the 61 supporting modules. Due to length, key modules are shown in detail.

### ai_cache.sh

**Purpose**: AI response caching with TTL management  
**Size**: 11K  
**Location**: `src/workflow/lib/ai_cache.sh`

#### Functions

##### init_ai_cache()
Initialize the AI cache system.

**Returns**: `0` on success

##### get_cache_key()
Generate a cache key for an AI prompt.

**Parameters**:
- `$1` - prompt: AI prompt text

**Returns**: SHA256 hash of prompt

##### cache_ai_response()
Cache an AI response.

**Parameters**:
- `$1` - prompt: AI prompt
- `$2` - response: AI response
- `$3` - ttl: Time to live in seconds (default: 86400)

**Returns**: `0` on success

##### get_cached_ai_response()
Get a cached AI response.

**Parameters**:
- `$1` - prompt: AI prompt

**Returns**: Cached response or empty

##### cleanup_expired_cache()
Clean up expired cache entries.

**Returns**: Number of entries removed

##### get_cache_stats()
Get cache statistics.

**Returns**: JSON object with cache stats

---

### session_manager.sh

**Purpose**: Process and session management  
**Size**: 12K  
**Location**: `src/workflow/lib/session_manager.sh`

#### Functions

##### create_session()
Create a new workflow session.

**Returns**: Session ID

##### get_current_session()
Get the current session ID.

**Returns**: Session ID or empty

##### close_session()
Close the current session.

**Returns**: `0` on success

##### save_session_state()
Save session state.

**Parameters**:
- `$1` - state: State data as JSON

**Returns**: `0` on success

##### restore_session_state()
Restore session state.

**Returns**: State data as JSON

---

### ai_prompt_builder.sh

**Purpose**: Dynamic AI prompt construction  
**Size**: 8.4K  
**Location**: `src/workflow/lib/ai_prompt_builder.sh`

#### Functions

##### build_prompt_from_template()
Build a prompt from a template.

**Parameters**:
- `$1` - template_name: Template identifier
- `$2` - variables: JSON object with template variables

**Returns**: Complete prompt

##### add_context_to_prompt()
Add contextual information to a prompt.

**Parameters**:
- `$1` - base_prompt: Base prompt text
- `$2` - context: Context to add

**Returns**: Enhanced prompt

##### format_prompt_for_model()
Format a prompt for a specific AI model.

**Parameters**:
- `$1` - prompt: Prompt text
- `$2` - model: Model name

**Returns**: Formatted prompt

---

### validation.sh

**Purpose**: Input validation and sanitization  
**Size**: 9.7K  
**Location**: `src/workflow/lib/validation.sh`

#### Functions

##### validate_file_path()
Validate a file path.

**Parameters**:
- `$1` - path: File path to validate

**Returns**: `0` if valid, `1` if not

##### validate_directory()
Validate a directory path.

**Parameters**:
- `$1` - path: Directory path to validate

**Returns**: `0` if valid, `1` if not

##### validate_step_id()
Validate a step identifier.

**Parameters**:
- `$1` - step_id: Step ID to validate

**Returns**: `0` if valid, `1` if not

##### validate_configuration()
Validate workflow configuration.

**Returns**: `0` if valid, `1` if not

##### sanitize_input()
Sanitize user input.

**Parameters**:
- `$1` - input: Input to sanitize

**Returns**: Sanitized input

---

## Step Modules

Step modules implement the 20-step workflow pipeline. Each step module follows a standard interface.

### Standard Step Interface

All step modules implement these functions:

```bash
validate_step_XX() {
    # Validate prerequisites for step
    # Returns: 0 if ready, 1 if not
}

execute_step_XX() {
    # Execute the step
    # Returns: 0 on success, 1 on failure
}

cleanup_step_XX() {
    # Optional cleanup function
    # Returns: 0 on success
}
```

### Step 0: Pre-Analysis

**File**: `src/workflow/steps/step_0_pre_analysis.sh`  
**Purpose**: Initial project analysis and validation  
**AI Persona**: Project Analyst  
**Execution Time**: ~30 seconds

**Functions**:
- `validate_step_0()`: Check project structure
- `execute_step_0()`: Analyze project and generate initial report

### Step 0a: Pre-Processing

**File**: `src/workflow/steps/step_0a_pre_processing.sh`  
**Purpose**: Prepare project for workflow execution  
**Execution Time**: ~15 seconds

### Step 0b: Bootstrap Documentation

**File**: `src/workflow/steps/step_0b_bootstrap_documentation.sh`  
**Purpose**: Generate comprehensive documentation from scratch  
**AI Persona**: Technical Writer  
**Execution Time**: ~2-5 minutes

**Functions**:
- `validate_step_0b()`: Check if documentation bootstrapping is needed
- `execute_step_0b()`: Generate API docs, architecture guides, user guides

### Step 1: README Analysis

**File**: `src/workflow/steps/step_1_readme_analysis.sh`  
**Purpose**: Analyze and improve README documentation  
**AI Persona**: Documentation Specialist  
**Execution Time**: ~45 seconds

### Step 2: Documentation Analysis

**File**: `src/workflow/steps/step_2_documentation_analysis.sh`  
**Purpose**: Comprehensive documentation review  
**AI Persona**: Documentation Specialist  
**Execution Time**: ~1-2 minutes

### Step 2.5: Documentation Optimization

**File**: `src/workflow/steps/step_02_5_doc_optimize.sh`  
**Purpose**: Optimize documentation structure and content  
**Execution Time**: ~30 seconds

### Step 3: Documentation Consistency

**File**: `src/workflow/steps/step_3_documentation_consistency.sh`  
**Purpose**: Ensure consistency across all documentation  
**AI Persona**: Documentation Specialist  
**Execution Time**: ~1 minute

### Step 4: API Documentation

**File**: `src/workflow/steps/step_4_api_documentation.sh`  
**Purpose**: Generate and validate API documentation  
**AI Persona**: API Documentation Specialist  
**Execution Time**: ~1-2 minutes

### Step 5: Test Strategy

**File**: `src/workflow/steps/step_5_test_strategy.sh`  
**Purpose**: Design comprehensive test strategy  
**AI Persona**: Test Engineer  
**Execution Time**: ~1 minute

### Step 6: Test Development

**File**: `src/workflow/steps/step_6_test_development.sh`  
**Purpose**: Implement tests based on strategy  
**AI Persona**: Test Engineer  
**Execution Time**: ~2-3 minutes

### Step 7: Test Execution

**File**: `src/workflow/steps/step_7_test_execution.sh`  
**Purpose**: Run tests and generate reports  
**Execution Time**: Varies by project (1-10 minutes)

### Step 8: Test Results Analysis

**File**: `src/workflow/steps/step_8_test_results_analysis.sh`  
**Purpose**: Analyze test results and identify issues  
**AI Persona**: Test Engineer  
**Execution Time**: ~1 minute

### Step 9: Code Quality Analysis

**File**: `src/workflow/steps/step_9_code_quality.sh`  
**Purpose**: Comprehensive code quality review  
**AI Persona**: Code Reviewer  
**Execution Time**: ~2-3 minutes

### Step 10: UX Analysis

**File**: `src/workflow/steps/step_10_ux_analysis.sh`  
**Purpose**: UI/UX and accessibility analysis  
**AI Persona**: UX Designer  
**Execution Time**: ~1-2 minutes  
**Requirements**: Frontend project with HTML/CSS/JS

### Step 11: Issue Extraction

**File**: `src/workflow/steps/step_11_issue_extraction.sh`  
**Purpose**: Extract and categorize identified issues  
**AI Persona**: Issue Analyst  
**Execution Time**: ~30 seconds

### Step 12: Changelog Generation

**File**: `src/workflow/steps/step_12_changelog_generation.sh`  
**Purpose**: Generate changelog from commits and changes  
**AI Persona**: Technical Writer  
**Execution Time**: ~30 seconds

### Step 13: Final Recommendations

**File**: `src/workflow/steps/step_13_final_recommendations.sh`  
**Purpose**: Generate actionable recommendations  
**AI Persona**: Prompt Engineer  
**Execution Time**: ~1 minute

### Step 14: Summary Generation

**File**: `src/workflow/steps/step_14_summary_generation.sh`  
**Purpose**: Create executive summary of workflow  
**AI Persona**: Technical Writer  
**Execution Time**: ~30 seconds

### Step 15: Version Update

**File**: `src/workflow/steps/step_15_version_update.sh`  
**Purpose**: Update version numbers and tags  
**Execution Time**: ~15 seconds

### Step 16: Post-Processing

**File**: `src/workflow/steps/step_16_post_processing.sh`  
**Purpose**: Cleanup and finalization  
**Execution Time**: ~15 seconds

---

## Orchestrator Modules

Orchestrators coordinate groups of workflow steps.

### Pre-Flight Orchestrator

**File**: `src/workflow/orchestrators/pre_flight.sh`  
**Purpose**: Validate environment and prerequisites  
**Steps**: 0, 0a, 0b (if needed)

**Functions**:
- `validate_pre_flight()`: Check all prerequisites
- `execute_pre_flight()`: Run pre-flight checks
- `generate_pre_flight_report()`: Generate validation report

### Validation Orchestrator

**File**: `src/workflow/orchestrators/validation.sh`  
**Purpose**: Documentation and test validation  
**Steps**: 1-8

**Functions**:
- `execute_validation_phase()`: Run all validation steps
- `check_validation_status()`: Get validation results
- `generate_validation_summary()`: Create validation report

### Quality Orchestrator

**File**: `src/workflow/orchestrators/quality.sh`  
**Purpose**: Code quality and UX analysis  
**Steps**: 9-11

**Functions**:
- `execute_quality_phase()`: Run quality analysis
- `check_quality_metrics()`: Get quality scores
- `generate_quality_report()`: Create quality report

### Finalization Orchestrator

**File**: `src/workflow/orchestrators/finalization.sh`  
**Purpose**: Final steps and cleanup  
**Steps**: 12-16

**Functions**:
- `execute_finalization()`: Run final steps
- `generate_final_artifacts()`: Create final outputs
- `cleanup_workflow()`: Cleanup temporary files

---

## Usage Examples

### Example 1: Basic Workflow Execution

```bash
#!/bin/bash
source "src/workflow/lib/ai_helpers.sh"
source "src/workflow/lib/metrics.sh"
source "src/workflow/lib/change_detection.sh"

# Initialize
init_metrics
validate_copilot_cli || exit 1

# Detect changes
local change_type
change_type=$(detect_change_type)
echo "Changes detected: $change_type"

# Get recommended steps
local steps
steps=$(get_recommended_steps "$change_type")
echo "Will execute: $steps"

# Execute workflow
for step in $steps; do
    start_step_timer "$step"
    
    if should_execute_step "$step" "$change_type"; then
        source "src/workflow/steps/step_${step#step_}_*.sh"
        execute_step_${step#step_}
    fi
    
    stop_step_timer "$step"
done

# Finalize
finalize_metrics
```

### Example 2: AI Integration

```bash
#!/bin/bash
source "src/workflow/lib/ai_helpers.sh"

# Validate Copilot
validate_copilot_cli || exit 1

# Build prompt
local prompt
prompt=$(build_ai_prompt \
    "documentation_specialist" \
    "Analyze README.md for completeness and accuracy" \
    "Clear structure, accurate examples, proper formatting")

# Execute with caching
local response
response=$(execute_copilot_prompt "$prompt" "analysis.md")

echo "Analysis saved to: analysis.md"
```

### Example 3: Parallel Execution

```bash
#!/bin/bash
source "src/workflow/lib/workflow_optimization.sh"
source "src/workflow/lib/performance.sh"

# Define parallel tracks
local track_config='{
    "track1": ["step_2", "step_3", "step_4"],
    "track2": ["step_5", "step_6"]
}'

# Execute in parallel
if execute_parallel_tracks "$track_config"; then
    echo "Parallel execution completed successfully"
else
    echo "Some steps failed"
    exit 1
fi

# Generate report
generate_parallel_tracks_report "logs/parallel_execution.log"
```

### Example 4: Custom Step with Metrics

```bash
#!/bin/bash
source "src/workflow/lib/metrics.sh"
source "src/workflow/lib/validation.sh"

validate_step_custom() {
    validate_directory "src" || return 1
    validate_file_path "package.json" || return 1
    return 0
}

execute_step_custom() {
    local step_id="custom_step"
    
    # Start timing
    start_step_timer "$step_id"
    
    # Your logic here
    echo "Executing custom step..."
    sleep 2
    
    # Stop timing
    local duration
    duration=$(stop_step_timer "$step_id")
    
    # Update metrics
    update_current_run_step "$step_id" "success" "$duration"
    
    return 0
}

# Main execution
validate_step_custom && execute_step_custom
```

### Example 5: Tech Stack Detection

```bash
#!/bin/bash
source "src/workflow/lib/tech_stack.sh"

# Initialize and detect
init_tech_stack

if detect_tech_stack; then
    echo "Detected tech stack:"
    print_tech_stack_summary
    
    # Get specific properties
    local test_cmd
    test_cmd=$(get_tech_stack_property "test_command")
    echo "Test command: $test_cmd"
    
    # Export to environment
    export_tech_stack_variables
    echo "Primary language: $PRIMARY_LANGUAGE"
else
    echo "Failed to detect tech stack"
    exit 1
fi
```

---

## Best Practices

### 1. Error Handling

Always check return codes and handle errors gracefully:

```bash
if ! validate_copilot_cli; then
    echo "ERROR: Copilot CLI not available"
    return 1
fi

local result
result=$(some_function) || {
    echo "ERROR: Function failed"
    return 1
}
```

### 2. Resource Cleanup

Use trap for cleanup:

```bash
cleanup() {
    cleanup_old_checkpoints
    cache_clear "temp_*"
}

trap cleanup EXIT
```

### 3. Logging

Log important operations:

```bash
log_info "Starting step 5: Test Strategy"
log_debug "Using model: $model"
log_error "Step failed: $error_message"
```

### 4. Metrics Collection

Always use metrics for performance tracking:

```bash
init_metrics
start_step_timer "my_step"
# ... do work ...
stop_step_timer "my_step"
finalize_metrics
```

### 5. AI Caching

AI responses are automatically cached. No special handling needed:

```bash
# First call - makes API request and caches
execute_copilot_prompt "$prompt" "output1.md"

# Second call with same prompt - uses cache
execute_copilot_prompt "$prompt" "output2.md"
```

### 6. Parallel Execution Safety

Ensure steps are independent before running in parallel:

```bash
# Good - independent steps
execute_parallel_validation "step_2" "step_5"

# Bad - step_6 depends on step_5
execute_parallel_validation "step_5" "step_6"  # DON'T DO THIS
```

### 7. Configuration Loading

Load configuration early:

```bash
source "src/workflow/lib/tech_stack.sh"
load_tech_stack_config || {
    echo "Using defaults"
    load_default_tech_stack
}
```

---

## See Also

- [PROJECT_REFERENCE.md](../PROJECT_REFERENCE.md) - Single source of truth
- [API_REFERENCE.md](./API_REFERENCE.md) - Quick API reference
- [LIBRARY_API_REFERENCE.md](./LIBRARY_API_REFERENCE.md) - Library modules
- [STEP_MODULES.md](./STEP_MODULES.md) - Step module details
- [User Guide](../user-guide/USER_GUIDE.md) - Usage documentation
- [Developer Guide](../developer-guide/contributing.md) - Contributing guidelines

---

**Last Updated**: 2026-02-08  
**Version**: v3.2.7  
**Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))
