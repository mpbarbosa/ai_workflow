# API Reference - AI Workflow Automation Library Modules

**Version**: v3.0.0  
**Last Updated**: 2026-01-31

This document provides a comprehensive API reference for all 62 library modules in the AI Workflow Automation system.

## Table of Contents

- [Core Modules](#core-modules)
- [File Operations](#file-operations)
- [Session & State Management](#session--state-management)
- [AI & Prompt Management](#ai--prompt-management)
- [Validation & Quality](#validation--quality)
- [Optimization Modules](#optimization-modules)
- [Configuration & Setup](#configuration--setup)
- [Utilities](#utilities)

---

## Core Modules

### ai_helpers.sh

**Purpose**: Core AI interaction functions for calling GitHub Copilot CLI with various personas.

**Key Functions**:

#### `check_copilot_available()`
```bash
check_copilot_available
```
- **Description**: Checks if GitHub Copilot CLI (gh) is available and properly authenticated
- **Returns**: 0 if available, 1 if not
- **Usage**: Always call before AI operations

#### `ai_call(persona, prompt, output_file, [options])`
```bash
ai_call "documentation_specialist" "Analyze this code" "output.md"
```
- **Parameters**:
  - `persona`: AI persona to use (see personas.md for list)
  - `prompt`: The prompt text to send to AI
  - `output_file`: Path to save AI response
  - `options`: Optional flags (e.g., --json)
- **Returns**: 0 on success, 1 on failure
- **Environment**: Uses `AI_CACHE_ENABLED` to control caching
- **Dependencies**: ai_cache.sh (optional), ai_personas.sh

#### `get_persona_prompt(persona, project_kind)`
```bash
get_persona_prompt "code_reviewer" "nodejs_api"
```
- **Description**: Retrieves configured prompt template for a persona
- **Returns**: Prompt text on stdout
- **Configuration**: Reads from `.workflow_core/config/ai_helpers.yaml`

---

### tech_stack.sh

**Purpose**: Automatic technology stack detection and configuration.

**Key Functions**:

#### `detect_tech_stack([target_dir])`
```bash
detect_tech_stack "/path/to/project"
```
- **Description**: Automatically detects project technology stack
- **Returns**: Sets global variables: `PRIMARY_LANGUAGE`, `TEST_FRAMEWORK`, `BUILD_TOOL`
- **Detection Logic**: Examines package.json, requirements.txt, Cargo.toml, etc.

#### `get_test_command()`
```bash
test_cmd=$(get_test_command)
```
- **Description**: Returns the appropriate test command for detected stack
- **Returns**: Test command string (e.g., "npm test", "pytest", "cargo test")

#### `get_language_specific_rules(language)`
```bash
rules=$(get_language_specific_rules "python")
```
- **Description**: Returns language-specific code quality rules
- **Returns**: Multi-line string with conventions and best practices

---

### workflow_optimization.sh

**Purpose**: Smart execution and workflow optimization logic.

**Key Functions**:

#### `should_skip_step(step_number, step_name)`
```bash
if should_skip_step "2" "Documentation Update"; then
    echo "Skipping step 2"
fi
```
- **Description**: Determines if a step can be skipped based on change detection
- **Returns**: 0 if should skip, 1 if should execute
- **Dependencies**: change_detection.sh

#### `get_optimization_recommendations()`
```bash
recommendations=$(get_optimization_recommendations)
```
- **Description**: Analyzes workflow and suggests optimization flags
- **Returns**: Human-readable recommendations

---

### change_detection.sh

**Purpose**: Detect file changes since last git commit.

**Key Functions**:

#### `analyze_changes([target_dir])`
```bash
analyze_changes "/path/to/project"
```
- **Description**: Analyzes git changes and categorizes them
- **Returns**: Sets arrays: `CHANGED_CODE_FILES`, `CHANGED_TEST_FILES`, `CHANGED_DOC_FILES`
- **Side Effects**: Creates analysis report in backlog directory

#### `has_code_changes()`
```bash
if has_code_changes; then
    echo "Code changed, run tests"
fi
```
- **Returns**: 0 if code files changed, 1 if not

#### `has_doc_changes()`
```bash
if has_doc_changes; then
    echo "Documentation changed"
fi
```
- **Returns**: 0 if documentation files changed, 1 if not

#### `has_test_changes()`
```bash
if has_test_changes; then
    echo "Test files changed"
fi
```
- **Returns**: 0 if test files changed, 1 if not

---

## File Operations

### file_operations.sh

**Purpose**: Safe file operations with validation and error handling.

**Key Functions**:

#### `safe_create_file(path, content)`
```bash
safe_create_file "docs/README.md" "# Documentation"
```
- **Description**: Creates file with content, ensuring parent directories exist
- **Returns**: 0 on success, 1 on failure
- **Safety**: Checks permissions, creates directories

#### `safe_read_file(path)`
```bash
content=$(safe_read_file "config.yaml")
```
- **Description**: Reads file content with error handling
- **Returns**: File content on stdout, empty on error
- **Validation**: Checks file exists and is readable

#### `safe_append_file(path, content)`
```bash
safe_append_file "log.txt" "New log entry"
```
- **Description**: Appends content to file, creating if needed
- **Returns**: 0 on success, 1 on failure

---

### edit_operations.sh

**Purpose**: Advanced file editing operations (search/replace, line insertion).

**Key Functions**:

#### `replace_in_file(file, pattern, replacement)`
```bash
replace_in_file "config.js" "port: 3000" "port: 8080"
```
- **Description**: Replaces pattern in file (first occurrence)
- **Returns**: 0 on success, 1 if pattern not found
- **Safety**: Creates backup (.bak)

#### `replace_all_in_file(file, pattern, replacement)`
```bash
replace_all_in_file "*.js" "var " "let "
```
- **Description**: Replaces all occurrences in file
- **Returns**: Number of replacements made

#### `insert_after_line(file, pattern, content)`
```bash
insert_after_line "config.yaml" "plugins:" "  - new-plugin"
```
- **Description**: Inserts content after first line matching pattern
- **Returns**: 0 on success, 1 if pattern not found

---

### batch_operations.sh

**Purpose**: Batch file operations for efficiency.

**Key Functions**:

#### `batch_create_files(file_list_array)`
```bash
files=("doc1.md" "doc2.md" "doc3.md")
batch_create_files "${files[@]}"
```
- **Description**: Creates multiple files in parallel
- **Returns**: 0 if all succeed, 1 if any fail
- **Performance**: Uses background jobs for speed

#### `batch_update_files(update_map)`
```bash
declare -A updates
updates["file1.txt"]="new content 1"
updates["file2.txt"]="new content 2"
batch_update_files updates
```
- **Description**: Updates multiple files atomically
- **Returns**: 0 on success, 1 on failure

---

## Session & State Management

### session_manager.sh

**Purpose**: Manage workflow execution sessions and state persistence.

**Key Functions**:

#### `init_session()`
```bash
init_session
```
- **Description**: Initializes new workflow session
- **Side Effects**: Sets `SESSION_ID`, `SESSION_DIR`, creates session directory
- **Storage**: Creates `.workflow_session/` directory

#### `save_session_state(key, value)`
```bash
save_session_state "last_step" "5"
```
- **Description**: Saves key-value pair to session
- **Persistence**: Writes to `.workflow_session/state.json`

#### `load_session_state(key)`
```bash
last_step=$(load_session_state "last_step")
```
- **Description**: Retrieves value from session
- **Returns**: Value on stdout, empty if not found

#### `cleanup_session()`
```bash
cleanup_session
```
- **Description**: Cleans up temporary session files
- **Safety**: Preserves important artifacts

---

### ai_cache.sh

**Purpose**: AI response caching to reduce token usage (60-80% reduction).

**Key Functions**:

#### `init_ai_cache()`
```bash
init_ai_cache
```
- **Description**: Initializes AI cache system
- **Side Effects**: Creates `.ai_cache/` directory and index.json
- **Default TTL**: 24 hours

#### `get_cache_key(persona, prompt)`
```bash
cache_key=$(get_cache_key "code_reviewer" "Review this code")
```
- **Description**: Generates SHA256 cache key from persona + prompt
- **Returns**: 64-character hex string

#### `get_cached_response(cache_key)`
```bash
if response=$(get_cached_response "$key"); then
    echo "Cache hit!"
fi
```
- **Returns**: Cached response on stdout, exit code 0 if found, 1 if miss

#### `cache_response(cache_key, response)`
```bash
cache_response "$key" "$ai_response"
```
- **Description**: Stores AI response in cache with timestamp
- **TTL**: Configurable, default 24 hours

#### `cleanup_expired_cache()`
```bash
cleanup_expired_cache
```
- **Description**: Removes expired cache entries
- **Scheduling**: Runs automatically every 24 hours

---

### checkpoint_manager.sh

**Purpose**: Checkpoint and resume functionality for long-running workflows.

**Key Functions**:

#### `save_checkpoint(step_number, step_name)`
```bash
save_checkpoint "5" "Test Execution"
```
- **Description**: Saves checkpoint after successful step
- **Persistence**: Writes to `.workflow_checkpoint`

#### `load_checkpoint()`
```bash
if checkpoint=$(load_checkpoint); then
    echo "Resume from step $checkpoint"
fi
```
- **Returns**: Last successful step number, empty if no checkpoint

#### `clear_checkpoint()`
```bash
clear_checkpoint
```
- **Description**: Removes checkpoint file (on successful completion)

---

## AI & Prompt Management

### ai_personas.sh

**Purpose**: Defines 15 specialized AI personas with role-specific prompts.

**Key Functions**:

#### `get_persona_list()`
```bash
personas=$(get_persona_list)
```
- **Returns**: Array of available persona names
- **Personas**: documentation_specialist, code_reviewer, test_engineer, ux_designer, etc.

#### `validate_persona(persona_name)`
```bash
if validate_persona "code_reviewer"; then
    echo "Valid persona"
fi
```
- **Returns**: 0 if valid, 1 if invalid

---

### ai_prompt_builder.sh

**Purpose**: Constructs context-aware AI prompts with project-specific information.

**Key Functions**:

#### `build_prompt(persona, task, context)`
```bash
prompt=$(build_prompt "code_reviewer" "review" "$code_context")
```
- **Description**: Builds complete prompt with system context
- **Returns**: Formatted prompt string
- **Enhancements**: Adds language-specific rules, project kind info

#### `add_project_context(prompt, project_kind)`
```bash
enhanced_prompt=$(add_project_context "$base_prompt" "nodejs_api")
```
- **Description**: Adds project-specific context to prompt
- **Sources**: Reads from `.workflow-config.yaml` and `project_kinds.yaml`

---

### prompt_templates.sh

**Purpose**: Template management for AI prompts.

**Key Functions**:

#### `load_template(template_name)`
```bash
template=$(load_template "code_review")
```
- **Returns**: Template content
- **Location**: `.workflow_core/config/ai_helpers.yaml`

#### `substitute_variables(template, var_map)`
```bash
declare -A vars
vars["project_name"]="my-app"
result=$(substitute_variables "$template" vars)
```
- **Description**: Replaces {{variable}} placeholders in template

---

## Validation & Quality

### enhanced_validations.sh

**Purpose**: Pre-flight and step validation checks.

**Key Functions**:

#### `validate_prerequisites()`
```bash
if ! validate_prerequisites; then
    echo "Prerequisites not met"
    exit 1
fi
```
- **Description**: Validates required tools (git, gh, jq, etc.)
- **Returns**: 0 if all present, 1 if missing dependencies

#### `validate_step_inputs(step_number, inputs)`
```bash
validate_step_inputs "3" "$input_data"
```
- **Description**: Validates inputs before step execution
- **Returns**: 0 if valid, 1 if invalid

#### `validate_git_state()`
```bash
if ! validate_git_state; then
    echo "Git repository in invalid state"
fi
```
- **Description**: Checks git status (clean working directory, valid branch)
- **Returns**: 0 if clean, 1 if uncommitted changes

---

### code_quality_checker.sh

**Purpose**: Code quality analysis and linting.

**Key Functions**:

#### `check_code_quality(file_list)`
```bash
check_code_quality "${changed_files[@]}"
```
- **Description**: Runs linters/formatters on code files
- **Returns**: Quality score (0-100)
- **Tools**: Uses ShellCheck for bash, ESLint for JS, Pylint for Python

#### `get_quality_report()`
```bash
report=$(get_quality_report)
```
- **Returns**: Detailed quality report with issues

---

### test_validator.sh

**Purpose**: Test suite validation and execution.

**Key Functions**:

#### `validate_tests(test_dir)`
```bash
validate_tests "tests/"
```
- **Description**: Validates test files exist and are runnable
- **Returns**: 0 if valid, 1 if issues found

#### `run_tests_with_coverage(test_command)`
```bash
run_tests_with_coverage "npm test"
```
- **Description**: Executes tests and collects coverage metrics
- **Returns**: Test results object
- **Metrics**: Pass/fail count, coverage percentage

---

## Optimization Modules

### ml_optimization.sh

**Purpose**: Machine learning-based workflow optimization (v2.7.0+).

**Key Functions**:

#### `should_enable_ml()`
```bash
if should_enable_ml; then
    echo "ML optimization available"
fi
```
- **Description**: Checks if sufficient historical data exists (10+ runs)
- **Returns**: 0 if ML available, 1 if not

#### `predict_step_duration(step_number, context)`
```bash
predicted_duration=$(predict_step_duration "5" "$context")
```
- **Description**: Predicts step execution time based on historical data
- **Returns**: Duration in seconds
- **Accuracy**: Improves with more historical runs

#### `get_ml_recommendations()`
```bash
recommendations=$(get_ml_recommendations)
```
- **Description**: ML-driven suggestions for workflow optimization
- **Returns**: Optimization suggestions array

---

### multi_stage_pipeline.sh

**Purpose**: Progressive validation pipeline (v2.8.0+).

**Key Functions**:

#### `get_pipeline_stage(step_number)`
```bash
stage=$(get_pipeline_stage "3")
```
- **Description**: Determines pipeline stage for step (validation/quality/finalization)
- **Returns**: Stage name

#### `should_continue_to_next_stage(current_stage_results)`
```bash
if should_continue_to_next_stage "$results"; then
    echo "Proceed to next stage"
fi
```
- **Description**: Determines if pipeline should continue based on results
- **Returns**: 0 to continue, 1 to stop
- **Statistics**: 80%+ of runs complete in first 2 stages

---

### parallel_executor.sh

**Purpose**: Parallel step execution for independent steps.

**Key Functions**:

#### `get_parallel_groups()`
```bash
groups=$(get_parallel_groups)
```
- **Description**: Returns groups of steps that can run in parallel
- **Returns**: JSON array of step groups
- **Dependencies**: Reads from dependency_graph.sh

#### `execute_parallel_group(step_list)`
```bash
execute_parallel_group "2,3,4"
```
- **Description**: Executes steps in parallel using background jobs
- **Returns**: 0 if all succeed, 1 if any fail
- **Performance**: 33% faster for independent steps

---

### workflow_templates.sh

**Purpose**: Pre-configured workflow templates (v2.6.0+).

**Key Functions**:

#### `get_template(template_name)`
```bash
config=$(get_template "docs-only")
```
- **Description**: Returns template configuration
- **Templates**: docs-only (3-4 min), test-only (8-10 min), feature (15-20 min)
- **Returns**: Step list and configuration

#### `apply_template(template_name)`
```bash
apply_template "docs-only"
```
- **Description**: Configures workflow for template
- **Side Effects**: Sets enabled steps and options

---

## Configuration & Setup

### argument_parser.sh

**Purpose**: Command-line argument parsing and validation.

**Key Functions**:

#### `parse_arguments(args)`
```bash
parse_arguments "$@"
```
- **Description**: Parses all CLI arguments
- **Side Effects**: Sets global flags (DRY_RUN, AUTO_MODE, etc.)
- **Validation**: Checks for invalid combinations

#### `validate_parsed_arguments()`
```bash
validate_parsed_arguments
```
- **Description**: Validates parsed arguments
- **Returns**: 0 if valid, 1 if invalid
- **Critical**: Must be called before init_metrics()

---

### config_loader.sh

**Purpose**: Configuration file loading and merging.

**Key Functions**:

#### `load_config(config_file)`
```bash
load_config ".workflow-config.yaml"
```
- **Description**: Loads YAML configuration
- **Returns**: 0 on success, 1 on error
- **Dependencies**: Requires yq for YAML parsing

#### `get_config_value(key, default)`
```bash
value=$(get_config_value "project.kind" "generic")
```
- **Description**: Retrieves config value with fallback
- **Returns**: Value or default

#### `merge_configs(base_config, override_config)`
```bash
merge_configs "default.yaml" "custom.yaml"
```
- **Description**: Merges two configurations (override wins)
- **Returns**: Merged configuration

---

### path_config.sh

**Purpose**: Path management for target projects and workflow directories.

**Key Functions**:

#### `init_paths(target_dir)`
```bash
init_paths "/path/to/project"
```
- **Description**: Initializes all path variables
- **Side Effects**: Sets PROJECT_ROOT, BACKLOG_DIR, METRICS_DIR, etc.

#### `get_workflow_dir()`
```bash
workflow_dir=$(get_workflow_dir)
```
- **Returns**: Workflow automation installation directory

#### `get_target_dir()`
```bash
target_dir=$(get_target_dir)
```
- **Returns**: Target project directory (respects --target option)

---

### project_kind_detector.sh

**Purpose**: Automatic project type detection.

**Key Functions**:

#### `detect_project_kind(target_dir)`
```bash
kind=$(detect_project_kind "/path/to/project")
```
- **Description**: Detects project type from files/structure
- **Returns**: Project kind (nodejs_api, python_cli, react_spa, etc.)
- **Logic**: Examines package.json, requirements.txt, file structure

---

## Utilities

### logging.sh

**Purpose**: Structured logging system.

**Key Functions**:

#### `log_info(message)`
```bash
log_info "Starting step 5"
```
- **Description**: Logs informational message
- **Output**: Timestamped to log file and console

#### `log_error(message)`
```bash
log_error "Failed to execute tests"
```
- **Description**: Logs error message
- **Output**: Timestamped, colored red on console

#### `log_debug(message)`
```bash
log_debug "Variable value: $var"
```
- **Description**: Logs debug message (only if DEBUG=true)

---

### metrics.sh

**Purpose**: Performance metrics collection and reporting.

**Key Functions**:

#### `init_metrics()`
```bash
init_metrics
```
- **Description**: Initializes metrics collection
- **Side Effects**: Creates metrics directory and current_run.json
- **Critical**: Requires METRICS_DIR to be set first

#### `start_step_timer(step_number)`
```bash
start_step_timer "5"
```
- **Description**: Starts timer for step execution
- **Storage**: Saves start time in STEP_START_TIMES array

#### `end_step_timer(step_number, status)`
```bash
end_step_timer "5" "success"
```
- **Description**: Ends timer and records step metrics
- **Calculation**: Computes duration, updates metrics file

#### `finalize_metrics(status)`
```bash
finalize_metrics "success"
```
- **Description**: Finalizes workflow metrics
- **Output**: Appends to history.jsonl, generates summary

---

### error_handler.sh

**Purpose**: Error handling and recovery.

**Key Functions**:

#### `handle_error(error_message, step_number)`
```bash
handle_error "Test execution failed" "7"
```
- **Description**: Handles error with logging and cleanup
- **Recovery**: Attempts recovery strategies if available

#### `set_error_trap(cleanup_function)`
```bash
set_error_trap cleanup_on_error
```
- **Description**: Sets up trap for error handling
- **Usage**: Call early in script execution

---

### color_output.sh

**Purpose**: Terminal color and formatting utilities.

**Key Functions**:

#### `color_echo(color, message)`
```bash
color_echo "green" "✅ Success"
```
- **Description**: Prints colored message to terminal
- **Colors**: green, red, yellow, blue, cyan, magenta

#### `print_header(title)`
```bash
print_header "Step 5: Test Execution"
```
- **Description**: Prints formatted section header

---

### dependency_graph.sh

**Purpose**: Step dependency management and visualization.

**Key Functions**:

#### `get_step_dependencies(step_number)`
```bash
deps=$(get_step_dependencies "5")
```
- **Description**: Returns list of steps that must complete before this step
- **Returns**: Space-separated step numbers

#### `visualize_dependencies()`
```bash
visualize_dependencies > graph.dot
```
- **Description**: Generates dependency graph in DOT format
- **Usage**: Can be rendered with Graphviz

#### `validate_dependency_order(step_list)`
```bash
if validate_dependency_order "5,3,7"; then
    echo "Valid execution order"
fi
```
- **Returns**: 0 if valid topological order, 1 if invalid

---

### auto_commit.sh

**Purpose**: Automatic commit of workflow artifacts (v2.6.0+).

**Key Functions**:

#### `should_auto_commit()`
```bash
if should_auto_commit; then
    echo "Auto-commit enabled"
fi
```
- **Returns**: 0 if --auto-commit flag set, 1 otherwise

#### `commit_workflow_artifacts(step_number, changes)`
```bash
commit_workflow_artifacts "5" "Updated test suite"
```
- **Description**: Commits workflow-generated changes
- **Commit Message**: Auto-generated with step context
- **Safety**: Only commits tracked files

---

### pre_commit_hooks.sh

**Purpose**: Pre-commit validation hooks (v3.0.0+).

**Key Functions**:

#### `install_hooks()`
```bash
install_hooks
```
- **Description**: Installs pre-commit hooks to .git/hooks/
- **Hooks**: pre-commit validation, fast checks (<1 second)

#### `run_pre_commit_checks()`
```bash
if ! run_pre_commit_checks; then
    echo "Pre-commit checks failed"
    exit 1
fi
```
- **Description**: Runs fast validation checks before commit
- **Checks**: Syntax validation, basic linting, file structure
- **Performance**: Completes in under 1 second

---

## Usage Patterns

### Common Workflows

#### 1. Basic AI Call with Caching
```bash
source lib/ai_helpers.sh
source lib/ai_cache.sh

init_ai_cache
ai_call "code_reviewer" "Review this function" "review.md"
# Subsequent identical calls will use cache
```

#### 2. Smart Execution with Change Detection
```bash
source lib/change_detection.sh
source lib/workflow_optimization.sh

analyze_changes
if should_skip_step "2" "Documentation"; then
    echo "No doc changes, skipping"
else
    execute_step_2
fi
```

#### 3. Parallel Step Execution
```bash
source lib/parallel_executor.sh

# Get groups of independent steps
groups=$(get_parallel_groups)

# Execute first group in parallel
execute_parallel_group "2,3,4"
```

#### 4. ML-Optimized Execution
```bash
source lib/ml_optimization.sh

if should_enable_ml; then
    recommendations=$(get_ml_recommendations)
    echo "Suggested optimizations: $recommendations"
fi
```

#### 5. Session Management with Checkpointing
```bash
source lib/session_manager.sh
source lib/checkpoint_manager.sh

init_session

# Execute steps with checkpointing
for step in {1..15}; do
    execute_step "$step"
    save_checkpoint "$step" "Step $step"
done

cleanup_session
```

---

## Error Codes

| Code | Meaning | Module |
|------|---------|--------|
| 0 | Success | All |
| 1 | General failure | All |
| 2 | Invalid arguments | argument_parser.sh |
| 3 | Missing prerequisites | enhanced_validations.sh |
| 4 | Git state invalid | enhanced_validations.sh |
| 5 | File operation failed | file_operations.sh |
| 10 | AI call failed | ai_helpers.sh |
| 11 | Cache error | ai_cache.sh |
| 20 | Test execution failed | test_validator.sh |
| 21 | Coverage below threshold | test_validator.sh |
| 30 | Metrics error | metrics.sh |

---

## Environment Variables

### Core Variables
- `WORKFLOW_RUN_ID`: Unique identifier for workflow run (auto-generated)
- `PROJECT_ROOT`: Root directory of target project
- `METRICS_DIR`: Metrics storage directory
- `AI_CACHE_ENABLED`: Enable/disable AI caching (default: true)
- `DEBUG`: Enable debug logging (default: false)

### Configuration Variables
- `PRIMARY_LANGUAGE`: Detected primary programming language
- `TEST_FRAMEWORK`: Detected test framework
- `BUILD_TOOL`: Detected build tool
- `PROJECT_KIND`: Project type classification

### Mode Flags
- `DRY_RUN`: Preview mode without executing changes
- `AUTO_MODE`: Non-interactive mode
- `SMART_EXECUTION`: Enable smart step skipping
- `PARALLEL_EXECUTION`: Enable parallel step execution

---

## Performance Metrics

### Typical Module Performance

| Module | Operation | Time | Notes |
|--------|-----------|------|-------|
| ai_cache.sh | Cache lookup | <10ms | SHA256 + file read |
| change_detection.sh | Analyze changes | 100-500ms | Depends on repo size |
| parallel_executor.sh | 3 parallel steps | 33% faster | vs sequential |
| ml_optimization.sh | Prediction | 50-100ms | After training |
| file_operations.sh | Batch create | 2-5ms/file | With parallelization |

---

## Best Practices

### 1. Always Check Prerequisites
```bash
source lib/enhanced_validations.sh
validate_prerequisites || exit 1
```

### 2. Initialize Before Use
```bash
# Initialize metrics AFTER setting METRICS_DIR
validate_parsed_arguments  # Sets METRICS_DIR
init_metrics               # Now safe to call
```

### 3. Use Caching for AI Operations
```bash
# Caching is enabled by default
# To disable: export AI_CACHE_ENABLED=false
```

### 4. Handle Errors Gracefully
```bash
source lib/error_handler.sh
set_error_trap cleanup_function

cleanup_function() {
    # Cleanup code here
    cleanup_session
}
```

### 5. Validate Inputs
```bash
source lib/enhanced_validations.sh
validate_step_inputs "$step" "$input" || return 1
```

---

## See Also

- [Configuration Guide](configuration.md)
- [AI Personas Reference](personas.md)
- [Performance Benchmarks](performance-benchmarks.md)
- [Troubleshooting Guide](../guides/TROUBLESHOOTING.md)
- [Quick Start](../guides/QUICK_START.md)

---

**Maintained by**: AI Workflow Automation Team  
**Last Review**: 2026-01-31  
**Next Review**: 2026-02-28
