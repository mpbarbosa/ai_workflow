# AI Workflow Automation - Unified API Reference

**Version**: v4.0.1  
**Last Updated**: 2026-02-09  
**Status**: Complete and Authoritative

> 📋 **Reference**: See [PROJECT_REFERENCE.md](PROJECT_REFERENCE.md) for module inventory and version history.

---

## Table of Contents

1. [Overview](#overview)
2. [Library Modules (73 total)](#library-modules)
   - [Core Modules](#core-modules)
   - [AI & Machine Learning](#ai--machine-learning)
   - [File & Git Operations](#file--git-operations)
   - [Metrics & Analytics](#metrics--analytics)
   - [Configuration & Setup](#configuration--setup)
   - [Execution & Optimization](#execution--optimization)
   - [Validation & Testing](#validation--testing)
   - [Utilities & Helpers](#utilities--helpers)
3. [Step Modules (20 total)](#step-modules)
4. [Orchestrators (4 total)](#orchestrators)
5. [Configuration Files](#configuration-files)
6. [Usage Patterns](#usage-patterns)
7. [Error Handling](#error-handling)
8. [Best Practices](#best-practices)

---

## Overview

This unified API reference consolidates all module APIs, providing a single source of truth for the AI Workflow Automation system. The system consists of:

- **81 Library Modules**: Reusable functions for workflow operations
- **21 Step Modules**: Workflow pipeline execution steps
- **4 Orchestrators**: High-level workflow coordination (pre_flight, validation, quality, finalization)
- **4 Configuration Files**: YAML-based settings and templates

### Architecture Pattern

```
execute_tests_docs_workflow.sh (main entry point)
    ↓
orchestrators/ (pre_flight, validation, quality, finalization)
    ↓
steps/ (step_00 through step_16)
    ↓
lib/ (73 reusable modules)
    ↓
config/ (YAML configuration files)
```

### Module Loading

All library modules follow this pattern:

```bash
# Source a library module
source "${WORKFLOW_LIB_DIR}/module_name.sh"

# Or from within workflow scripts
source "$(dirname "$0")/lib/module_name.sh"
```

---

## Library Modules

### Core Modules

Core modules provide fundamental workflow functionality.

#### ai_helpers.sh

**Purpose**: AI prompt templates and GitHub Copilot CLI integration  
**Size**: 113.4 KB  
**Functions**: 22+ exported functions  
**Dependencies**: `colors.sh`, `ai_personas.sh`, `project_kind_detection.sh`, `tech_stack.sh`

##### Key Functions

###### `is_copilot_available()`
Check if GitHub Copilot CLI is available in the environment.

**Parameters**: None  
**Returns**: 
- `0` - Copilot CLI is available
- `1` - Copilot CLI not found

**Example**:
```bash
if is_copilot_available; then
    echo "✓ Copilot CLI is available"
else
    echo "✗ Copilot CLI not found"
    exit 1
fi
```

---

###### `is_copilot_authenticated()`
Verify Copilot CLI authentication status.

**Parameters**: None  
**Returns**: 
- `0` - Authenticated and ready
- `1` - Not authenticated or not available

**Example**:
```bash
if is_copilot_authenticated; then
    echo "Ready to use AI features"
else
    echo "Please authenticate: gh copilot auth"
    exit 1
fi
```

---

###### `validate_copilot_cli()`
Comprehensive validation with user feedback and guidance.

**Parameters**: None  
**Returns**: 
- `0` - CLI available and authenticated
- `1` - Not ready (displays help messages)

**Side Effects**: Prints installation/authentication instructions on failure

**Example**:
```bash
if ! validate_copilot_cli; then
    exit 1  # User has been informed of the issue
fi
```

---

###### `get_project_metadata()`
Extract project information from `.workflow-config.yaml`.

**Parameters**: None  
**Returns**: Pipe-delimited string: `project_name|project_description|primary_language`

**Example**:
```bash
IFS='|' read -r name desc lang < <(get_project_metadata)
echo "Project: $name ($lang)"
echo "Description: $desc"
```

---

###### `build_ai_prompt(persona, context, template_vars...)`
Build AI prompt from templates with variable substitution.

**Parameters**:
- `persona` (string, required): AI persona name (e.g., "documentation_specialist")
- `context` (string, required): Execution context
- `template_vars...` (key=value pairs, optional): Variables for substitution

**Returns**: Formatted prompt string

**Example**:
```bash
prompt=$(build_ai_prompt "documentation_specialist" "review" \
    "PROJECT_NAME=MyApp" \
    "FILE_PATH=README.md" \
    "CHANGES=Added installation section")
```

---

###### `execute_copilot_prompt(prompt, [options])`
Execute an AI prompt via GitHub Copilot CLI with automatic caching.

**Parameters**:
- `prompt` (string, required): The prompt text to send to Copilot
- `options` (string, optional): Additional CLI flags (e.g., `--model claude-sonnet-4`)

**Returns**: JSON response from Copilot CLI

**Side Effects**: 
- Caches response for 24 hours
- Updates AI cache metrics
- Logs API calls to metrics

**Example**:
```bash
response=$(execute_copilot_prompt "Analyze this code for issues" "--model claude-sonnet-4")
echo "$response" | jq -r '.content'
```

---

###### `get_language_documentation_conventions(language)`
Retrieve language-specific documentation conventions.

**Parameters**:
- `language` (string, required): Programming language name (e.g., "javascript", "python", "go")

**Returns**: String with documentation conventions (JSDoc, Javadoc, rustdoc, etc.)

**Supported Languages**: JavaScript, Python, Go, Java, Ruby, Rust, C++, Bash, TypeScript, PHP

**Example**:
```bash
conventions=$(get_language_documentation_conventions "javascript")
echo "$conventions"
# Output: "Use JSDoc with @param, @returns, @example tags..."
```

---

#### workflow_optimization.sh

**Purpose**: Smart execution, parallel processing, and performance optimization  
**Size**: 31 KB  
**Functions**: 15+ exported functions  
**Dependencies**: `change_detection.sh`, `dependency_graph.sh`, `metrics.sh`

##### Key Functions

###### `should_skip_step(step_num)`
Determine if a step should be skipped based on change detection.

**Parameters**:
- `step_num` (string, required): Step number (e.g., "01", "02", "15")

**Returns**: 
- `0` - Skip this step (no relevant changes)
- `1` - Execute this step (changes detected)

**Example**:
```bash
if should_skip_step "01"; then
    echo "Skipping step 01 (no documentation changes)"
    return 0
fi
```

---

###### `get_parallel_groups()`
Get independent step groups that can run in parallel.

**Parameters**: None

**Returns**: JSON array of step groups

**Example**:
```bash
groups=$(get_parallel_groups)
echo "$groups" | jq -r '.[]' | while read -r group; do
    # Execute steps in group simultaneously
    execute_parallel_group "$group"
done
```

---

###### `calculate_optimization_metrics()`
Calculate performance improvements from optimizations.

**Parameters**: None

**Returns**: JSON object with optimization statistics

**Side Effects**: Updates metrics file with optimization data

**Example**:
```bash
metrics=$(calculate_optimization_metrics)
time_saved=$(echo "$metrics" | jq -r '.time_saved_seconds')
echo "Saved ${time_saved}s through optimizations"
```

---

#### change_detection.sh

**Purpose**: Git diff analysis and change categorization  
**Size**: 17 KB  
**Functions**: 12+ exported functions  
**Dependencies**: `colors.sh`, `validation.sh`

##### Key Functions

###### `analyze_changes([commit_range])`
Analyze Git changes and categorize by type.

**Parameters**:
- `commit_range` (string, optional): Git revision range (default: "HEAD")

**Returns**: JSON object with change categories

**Example**:
```bash
changes=$(analyze_changes "HEAD~3..HEAD")
doc_changes=$(echo "$changes" | jq -r '.documentation | length')
code_changes=$(echo "$changes" | jq -r '.code | length')
echo "Documentation files changed: $doc_changes"
echo "Code files changed: $code_changes"
```

---

###### `has_documentation_changes()`
Check if documentation files have been modified.

**Parameters**: None

**Returns**: 
- `0` - Documentation changes detected
- `1` - No documentation changes

**Example**:
```bash
if has_documentation_changes; then
    execute_step "01"  # Documentation analysis
fi
```

---

###### `has_code_changes()`
Check if source code files have been modified.

**Parameters**: None

**Returns**: 
- `0` - Code changes detected
- `1` - No code changes

**Example**:
```bash
if has_code_changes; then
    execute_step "06"  # Test review
    execute_step "10"  # Code quality
fi
```

---

###### `has_test_changes()`
Check if test files have been modified.

**Parameters**: None

**Returns**: 
- `0` - Test changes detected
- `1` - No test changes

**Example**:
```bash
if has_test_changes; then
    execute_step "08"  # Test execution
fi
```

---

#### tech_stack.sh

**Purpose**: Technology stack detection and configuration  
**Size**: 47 KB  
**Functions**: 18+ exported functions  
**Dependencies**: `colors.sh`, `validation.sh`, `project_kind_detection.sh`

##### Key Functions

###### `detect_tech_stack()`
Automatically detect project technology stack.

**Parameters**: None

**Returns**: JSON object with detected technologies

**Side Effects**: Caches detection results to `.tech_stack_cache`

**Example**:
```bash
stack=$(detect_tech_stack)
primary_lang=$(echo "$stack" | jq -r '.primary_language')
frameworks=$(echo "$stack" | jq -r '.frameworks | join(", ")')
echo "Language: $primary_lang"
echo "Frameworks: $frameworks"
```

---

###### `get_test_command()`
Get the appropriate test command for the project.

**Parameters**: None

**Returns**: String with test command

**Example**:
```bash
test_cmd=$(get_test_command)
echo "Running tests: $test_cmd"
eval "$test_cmd"
```

---

###### `get_lint_command()`
Get the appropriate linting command for the project.

**Parameters**: None

**Returns**: String with lint command

**Example**:
```bash
lint_cmd=$(get_lint_command)
if [[ -n "$lint_cmd" ]]; then
    eval "$lint_cmd"
fi
```

---

### AI & Machine Learning

Modules for AI integration, ML optimization, and intelligent features.

#### ai_cache.sh

**Purpose**: AI response caching with TTL management  
**Size**: 11 KB  
**Functions**: 8+ exported functions  
**Dependencies**: None (pure Bash implementation)

##### Key Functions

###### `cache_ai_response(prompt, response, [ttl])`
Cache an AI response with automatic expiration.

**Parameters**:
- `prompt` (string, required): The prompt that generated the response
- `response` (string, required): The AI response to cache
- `ttl` (integer, optional): Time to live in seconds (default: 86400 = 24 hours)

**Returns**: Cache key (SHA256 hash)

**Side Effects**: Writes to `.ai_cache/` directory

**Example**:
```bash
key=$(cache_ai_response "$prompt" "$response" 43200)  # 12-hour cache
echo "Cached with key: $key"
```

---

###### `get_cached_response(prompt)`
Retrieve a cached AI response if available and not expired.

**Parameters**:
- `prompt` (string, required): The prompt to look up

**Returns**: 
- Cached response (stdout) if found and valid
- Empty string if not found or expired

**Exit Code**:
- `0` - Cache hit
- `1` - Cache miss

**Example**:
```bash
if cached=$(get_cached_response "$prompt"); then
    echo "Using cached response"
    echo "$cached"
else
    # Make AI call and cache result
    response=$(execute_copilot_prompt "$prompt")
    cache_ai_response "$prompt" "$response"
fi
```

---

###### `clear_expired_cache()`
Remove expired entries from AI cache.

**Parameters**: None

**Returns**: Number of entries removed

**Side Effects**: Deletes expired cache files

**Example**:
```bash
removed=$(clear_expired_cache)
echo "Cleaned up $removed expired cache entries"
```

---

###### `get_cache_stats()`
Get AI cache statistics.

**Parameters**: None

**Returns**: JSON object with cache statistics

**Example**:
```bash
stats=$(get_cache_stats)
hit_rate=$(echo "$stats" | jq -r '.hit_rate_percent')
echo "Cache hit rate: ${hit_rate}%"
```

---

#### ai_personas.sh

**Purpose**: AI persona management and context building  
**Size**: 7.0 KB  
**Functions**: 10+ exported functions  
**Dependencies**: `ai_helpers.sh`, `project_kind_detection.sh`

##### Key Functions

###### `get_persona_context(persona_name)`
Get context and system prompt for an AI persona.

**Parameters**:
- `persona_name` (string, required): Name of the persona (e.g., "documentation_specialist", "code_reviewer")

**Returns**: JSON object with persona context

**Available Personas**:
- `documentation_specialist` - Documentation review and enhancement
- `code_reviewer` - Code quality and best practices
- `test_engineer` - Test development and validation
- `ux_designer` - UI/UX and accessibility analysis
- `technical_writer` - Documentation creation from scratch
- `prompt_engineer` - AI prompt optimization
- `software_quality_engineer` - Comprehensive quality assessment
- `dependency_analyst` - Dependency management and updates
- `git_automation_specialist` - Git operations and automation
- `markdown_formatter` - Markdown linting and formatting
- `change_analyst` - Change impact analysis
- `config_validator` - Configuration validation
- `directory_analyst` - Directory structure analysis
- `script_reference_validator` - Script reference validation
- `context_manager` - Context and scope management

**Example**:
```bash
context=$(get_persona_context "documentation_specialist")
system_prompt=$(echo "$context" | jq -r '.system_prompt')
expertise=$(echo "$context" | jq -r '.expertise | join(", ")')
echo "Persona expertise: $expertise"
```

---

#### ml_optimizer.sh

**Purpose**: Machine learning-driven workflow optimization  
**Size**: 24 KB  
**Functions**: 12+ exported functions  
**Dependencies**: `metrics.sh`, `workflow_optimization.sh`

##### Key Functions

###### `predict_step_duration(step_num)`
Predict step execution duration using historical data.

**Parameters**:
- `step_num` (string, required): Step number to predict

**Returns**: Predicted duration in seconds

**Requirements**: Minimum 10 historical workflow runs

**Example**:
```bash
predicted=$(predict_step_duration "01")
echo "Estimated step 01 duration: ${predicted}s"
```

---

###### `get_optimization_recommendations()`
Get ML-driven optimization recommendations.

**Parameters**: None

**Returns**: JSON array of recommendations

**Example**:
```bash
recommendations=$(get_optimization_recommendations)
echo "$recommendations" | jq -r '.[] | "• " + .recommendation'
```

---

###### `should_use_ml_optimization()`
Check if ML optimization should be enabled.

**Parameters**: None

**Returns**: 
- `0` - ML optimization ready (sufficient historical data)
- `1` - Not enough data

**Example**:
```bash
if should_use_ml_optimization; then
    enable_ml_features
fi
```

---

### File & Git Operations

Modules for file manipulation and Git automation.

#### file_operations.sh

**Purpose**: Safe file operations with atomic writes and backups  
**Size**: 15 KB  
**Functions**: 14+ exported functions  
**Dependencies**: `colors.sh`, `validation.sh`

##### Key Functions

###### `safe_write_file(file_path, content)`
Write content to file with atomic operation and backup.

**Parameters**:
- `file_path` (string, required): Path to file
- `content` (string, required): Content to write

**Returns**: 
- `0` - Success
- `1` - Failure

**Side Effects**: 
- Creates backup at `${file_path}.backup`
- Uses atomic write (temp file + move)

**Example**:
```bash
if safe_write_file "config.yaml" "$new_config"; then
    echo "Configuration updated successfully"
else
    echo "Failed to update configuration"
fi
```

---

###### `safe_append_file(file_path, content)`
Append content to file safely.

**Parameters**:
- `file_path` (string, required): Path to file
- `content` (string, required): Content to append

**Returns**: 
- `0` - Success
- `1` - Failure

**Example**:
```bash
safe_append_file "CHANGELOG.md" "## v4.0.0\n\n- New features\n"
```

---

###### `backup_file(file_path, [backup_dir])`
Create timestamped backup of a file.

**Parameters**:
- `file_path` (string, required): Path to file to backup
- `backup_dir` (string, optional): Backup directory (default: `./backups/`)

**Returns**: Path to backup file

**Example**:
```bash
backup=$(backup_file "important.txt")
echo "Backup created at: $backup"
```

---

#### git_automation.sh

**Purpose**: Git operations automation and commit management  
**Size**: 22 KB  
**Functions**: 16+ exported functions  
**Dependencies**: `colors.sh`, `validation.sh`, `metrics.sh`

##### Key Functions

###### `auto_commit_changes(message, [file_patterns...])`
Automatically stage and commit changes with intelligent message.

**Parameters**:
- `message` (string, required): Commit message base
- `file_patterns...` (strings, optional): File patterns to commit (default: all changes)

**Returns**: 
- `0` - Commit successful
- `1` - No changes or commit failed

**Example**:
```bash
# Commit all documentation changes
auto_commit_changes "docs: update API reference" "docs/**/*.md"

# Commit all workflow artifacts
auto_commit_changes "workflow: automated updates"
```

---

###### `generate_commit_message(changes)`
Generate intelligent commit message from changes.

**Parameters**:
- `changes` (JSON, required): Change analysis object

**Returns**: Generated commit message following conventional commits

**Example**:
```bash
changes=$(analyze_changes)
message=$(generate_commit_message "$changes")
echo "$message"
# Output: "docs: update 3 documentation files
#
# - Updated API_REFERENCE.md
# - Enhanced USER_GUIDE.md
# - Fixed typos in README.md"
```

---

###### `create_workflow_branch(branch_name)`
Create a workflow branch for automated commits.

**Parameters**:
- `branch_name` (string, required): Branch name

**Returns**: 
- `0` - Branch created/checked out
- `1` - Failed to create branch

**Example**:
```bash
if create_workflow_branch "workflow/$(date +%Y%m%d-%H%M%S)"; then
    # Make automated changes
    auto_commit_changes "workflow: automated updates"
fi
```

---

#### edit_operations.sh

**Purpose**: Advanced file editing operations  
**Size**: 14 KB  
**Functions**: 12+ exported functions  
**Dependencies**: `file_operations.sh`, `validation.sh`

##### Key Functions

###### `replace_in_file(file_path, search_pattern, replacement)`
Replace text in file using sed.

**Parameters**:
- `file_path` (string, required): Path to file
- `search_pattern` (string, required): Pattern to search for
- `replacement` (string, required): Replacement text

**Returns**: 
- `0` - Replacement successful
- `1` - File not found or replacement failed

**Example**:
```bash
replace_in_file "VERSION" "3.0.0" "4.0.0"
```

---

###### `insert_at_line(file_path, line_num, content)`
Insert content at specific line number.

**Parameters**:
- `file_path` (string, required): Path to file
- `line_num` (integer, required): Line number (1-indexed)
- `content` (string, required): Content to insert

**Returns**: 
- `0` - Insert successful
- `1` - Failed

**Example**:
```bash
insert_at_line "config.sh" 10 "# New configuration option"
```

---

### Metrics & Analytics

Modules for performance tracking and analysis.

#### metrics.sh

**Purpose**: Performance metrics collection and reporting  
**Size**: 16 KB  
**Functions**: 18+ exported functions  
**Dependencies**: `colors.sh`

##### Key Functions

###### `init_metrics()`
Initialize metrics collection for workflow run.

**Parameters**: None

**Returns**: 
- `0` - Metrics initialized
- `1` - Initialization failed

**Side Effects**: Creates metrics directory and session file

**Example**:
```bash
init_metrics
```

---

###### `record_step_start(step_num, step_name)`
Record the start of a workflow step.

**Parameters**:
- `step_num` (string, required): Step number
- `step_name` (string, required): Step name

**Returns**: Timestamp (Unix epoch)

**Example**:
```bash
start_time=$(record_step_start "01" "documentation_analysis")
```

---

###### `record_step_end(step_num, start_time, status)`
Record the completion of a workflow step.

**Parameters**:
- `step_num` (string, required): Step number
- `start_time` (integer, required): Start timestamp from `record_step_start`
- `status` (string, required): "success", "failure", or "skipped"

**Returns**: Duration in seconds

**Side Effects**: Updates metrics file

**Example**:
```bash
duration=$(record_step_end "01" "$start_time" "success")
echo "Step 01 completed in ${duration}s"
```

---

###### `finalize_metrics()`
Finalize metrics collection and generate report.

**Parameters**: None

**Returns**: Path to metrics report file

**Side Effects**: 
- Calculates totals and statistics
- Generates JSON and Markdown reports
- Archives to metrics history

**Example**:
```bash
report=$(finalize_metrics)
echo "Metrics report: $report"
```

---

###### `get_workflow_duration()`
Get total workflow duration.

**Parameters**: None

**Returns**: Duration in seconds

**Example**:
```bash
duration=$(get_workflow_duration)
minutes=$((duration / 60))
seconds=$((duration % 60))
echo "Total workflow time: ${minutes}m ${seconds}s"
```

---

#### performance.sh

**Purpose**: Performance timing and profiling utilities  
**Size**: 16 KB  
**Functions**: 10+ exported functions  
**Dependencies**: None

##### Key Functions

###### `start_timer(timer_name)`
Start a named timer.

**Parameters**:
- `timer_name` (string, required): Unique timer identifier

**Returns**: Start timestamp

**Example**:
```bash
start_timer "api_call"
# ... perform operation ...
elapsed=$(stop_timer "api_call")
echo "API call took ${elapsed}s"
```

---

###### `stop_timer(timer_name)`
Stop a named timer and get elapsed time.

**Parameters**:
- `timer_name` (string, required): Timer identifier

**Returns**: Elapsed time in seconds (with millisecond precision)

**Example**:
```bash
elapsed=$(stop_timer "api_call")
echo "Elapsed: ${elapsed}s"
```

---

### Configuration & Setup

Modules for configuration management and project setup.

#### config_wizard.sh

**Purpose**: Interactive configuration wizard  
**Size**: 16 KB  
**Functions**: 8+ exported functions  
**Dependencies**: `colors.sh`, `tech_stack.sh`, `project_kind_detection.sh`

##### Key Functions

###### `run_config_wizard()`
Launch interactive configuration wizard.

**Parameters**: None

**Returns**: 
- `0` - Configuration completed
- `1` - User cancelled or error

**Side Effects**: Creates/updates `.workflow-config.yaml`

**Example**:
```bash
if run_config_wizard; then
    echo "Configuration saved successfully"
fi
```

---

###### `validate_config([config_file])`
Validate workflow configuration file.

**Parameters**:
- `config_file` (string, optional): Path to config file (default: `.workflow-config.yaml`)

**Returns**: 
- `0` - Configuration valid
- `1` - Invalid configuration

**Example**:
```bash
if ! validate_config; then
    echo "Invalid configuration, please run: --init-config"
    exit 1
fi
```

---

#### project_kind_detection.sh

**Purpose**: Project type detection and classification  
**Size**: 14 KB  
**Functions**: 12+ exported functions  
**Dependencies**: `tech_stack.sh`

##### Key Functions

###### `detect_project_kind()`
Automatically detect project type.

**Parameters**: None

**Returns**: Project kind string (e.g., "nodejs_api", "react_spa", "python_library")

**Supported Project Kinds**:
- `shell_automation` - Shell script projects
- `nodejs_api` - Node.js API/backend
- `nodejs_cli` - Node.js CLI tool
- `nodejs_library` - Node.js library/package
- `static_website` - Static HTML/CSS/JS site
- `client_spa` - Vanilla JavaScript SPA
- `react_spa` - React application
- `vue_spa` - Vue.js application
- `python_api` - Python API/backend
- `python_cli` - Python CLI tool
- `python_library` - Python library/package
- `documentation` - Documentation-only project

**Example**:
```bash
kind=$(detect_project_kind)
echo "Detected project kind: $kind"
```

---

### Execution & Optimization

Modules for workflow execution and performance optimization.

#### dependency_graph.sh

**Purpose**: Step dependency management and visualization  
**Size**: 15 KB  
**Functions**: 10+ exported functions  
**Dependencies**: None

##### Key Functions

###### `get_step_dependencies(step_num)`
Get list of steps that must complete before this step.

**Parameters**:
- `step_num` (string, required): Step number

**Returns**: JSON array of dependency step numbers

**Example**:
```bash
deps=$(get_step_dependencies "08")
echo "$deps" | jq -r '.[]' | while read -r dep; do
    echo "Step 08 depends on step $dep"
done
```

---

###### `generate_dependency_graph([format])`
Generate dependency graph visualization.

**Parameters**:
- `format` (string, optional): Output format - "mermaid" (default), "dot", or "json"

**Returns**: Dependency graph in specified format

**Example**:
```bash
# Generate Mermaid diagram
graph=$(generate_dependency_graph "mermaid")
echo "$graph" > dependency_graph.md

# Generate JSON for programmatic use
json=$(generate_dependency_graph "json")
```

---

###### `can_execute_step(step_num)`
Check if step's dependencies are satisfied.

**Parameters**:
- `step_num` (string, required): Step number to check

**Returns**: 
- `0` - All dependencies satisfied
- `1` - Missing dependencies

**Example**:
```bash
if can_execute_step "08"; then
    execute_step "08"
else
    echo "Cannot execute step 08: dependencies not met"
fi
```

---

#### session_manager.sh

**Purpose**: Process and session management  
**Size**: 12 KB  
**Functions**: 14+ exported functions  
**Dependencies**: `colors.sh`

##### Key Functions

###### `start_session(session_name)`
Start a new workflow session.

**Parameters**:
- `session_name` (string, required): Unique session identifier

**Returns**: Session ID

**Side Effects**: Creates session directory in `.workflow_sessions/`

**Example**:
```bash
session=$(start_session "workflow_$(date +%Y%m%d_%H%M%S)")
echo "Started session: $session"
```

---

###### `end_session(session_id, [status])`
End a workflow session.

**Parameters**:
- `session_id` (string, required): Session ID from `start_session`
- `status` (string, optional): "success" or "failure" (default: "success")

**Returns**: 
- `0` - Session ended successfully
- `1` - Error ending session

**Side Effects**: Archives session data

**Example**:
```bash
end_session "$session" "success"
```

---

#### checkpoint_manager.sh

**Purpose**: Checkpoint and resume functionality  
**Size**: 10 KB  
**Functions**: 8+ exported functions  
**Dependencies**: `metrics.sh`

##### Key Functions

###### `save_checkpoint(step_num)`
Save workflow checkpoint after step completion.

**Parameters**:
- `step_num` (string, required): Completed step number

**Returns**: 
- `0` - Checkpoint saved
- `1` - Save failed

**Side Effects**: Writes to `.checkpoints/current`

**Example**:
```bash
save_checkpoint "05"
```

---

###### `load_checkpoint()`
Load last saved checkpoint.

**Parameters**: None

**Returns**: Last completed step number (or empty if no checkpoint)

**Example**:
```bash
if last_step=$(load_checkpoint); then
    echo "Resuming from step $last_step"
    start_step=$((last_step + 1))
fi
```

---

###### `clear_checkpoint()`
Clear saved checkpoint.

**Parameters**: None

**Returns**: 
- `0` - Checkpoint cleared
- `1` - No checkpoint found

**Example**:
```bash
clear_checkpoint  # Start fresh
```

---

### Validation & Testing

Modules for validation, testing, and quality assurance.

#### validation.sh

**Purpose**: Input validation and sanity checks  
**Size**: 9.7 KB  
**Functions**: 16+ exported functions  
**Dependencies**: `colors.sh`

##### Key Functions

###### `validate_file_exists(file_path)`
Check if file exists and is readable.

**Parameters**:
- `file_path` (string, required): Path to file

**Returns**: 
- `0` - File exists and is readable
- `1` - File not found or not readable

**Example**:
```bash
if ! validate_file_exists "config.yaml"; then
    echo "Configuration file not found"
    exit 1
fi
```

---

###### `validate_directory(dir_path)`
Check if directory exists and is accessible.

**Parameters**:
- `dir_path` (string, required): Path to directory

**Returns**: 
- `0` - Directory exists and is accessible
- `1` - Directory not found or not accessible

**Example**:
```bash
if validate_directory "docs"; then
    echo "Documentation directory found"
fi
```

---

###### `validate_command(command_name)`
Check if command is available in PATH.

**Parameters**:
- `command_name` (string, required): Command name

**Returns**: 
- `0` - Command available
- `1` - Command not found

**Example**:
```bash
if ! validate_command "jq"; then
    echo "Please install jq: apt install jq"
    exit 1
fi
```

---

#### health_check.sh

**Purpose**: System health checks and prerequisites validation  
**Size**: 15 KB  
**Functions**: 12+ exported functions  
**Dependencies**: `validation.sh`, `colors.sh`

##### Key Functions

###### `run_health_check()`
Run comprehensive system health check.

**Parameters**: None

**Returns**: 
- `0` - All checks passed
- `1` - One or more checks failed

**Side Effects**: Prints detailed health report

**Example**:
```bash
if ! run_health_check; then
    echo "System not ready for workflow execution"
    exit 1
fi
```

---

###### `check_dependencies()`
Verify all required dependencies are installed.

**Parameters**: None

**Returns**: 
- `0` - All dependencies available
- `1` - Missing dependencies

**Required Dependencies**:
- Bash 4.0+
- Git 2.0+
- jq 1.6+
- Node.js 25.2.1+ (for some features)
- GitHub Copilot CLI (for AI features)

**Example**:
```bash
if ! check_dependencies; then
    echo "Please install missing dependencies"
    exit 1
fi
```

---

### Utilities & Helpers

General utility modules for common operations.

#### colors.sh

**Purpose**: Terminal color formatting and output styling  
**Size**: 3.5 KB  
**Functions**: 20+ color constants and helper functions  
**Dependencies**: None

##### Key Functions

###### `log_info(message)`
Print informational message with blue formatting.

**Parameters**:
- `message` (string, required): Message to display

**Returns**: None (prints to stdout)

**Example**:
```bash
log_info "Starting workflow execution..."
```

---

###### `log_success(message)`
Print success message with green formatting.

**Parameters**:
- `message` (string, required): Message to display

**Returns**: None (prints to stdout)

**Example**:
```bash
log_success "Step 01 completed successfully"
```

---

###### `log_warning(message)`
Print warning message with yellow formatting.

**Parameters**:
- `message` (string, required): Message to display

**Returns**: None (prints to stderr)

**Example**:
```bash
log_warning "No tests found, skipping test execution"
```

---

###### `log_error(message)`
Print error message with red formatting.

**Parameters**:
- `message` (string, required): Message to display

**Returns**: None (prints to stderr)

**Example**:
```bash
log_error "Failed to execute step 08: tests failed"
```

---

#### utils.sh

**Purpose**: Common utility functions  
**Size**: 6.9 KB  
**Functions**: 14+ exported functions  
**Dependencies**: None

##### Key Functions

###### `get_timestamp([format])`
Get current timestamp.

**Parameters**:
- `format` (string, optional): Date format string (default: ISO 8601)

**Returns**: Formatted timestamp string

**Example**:
```bash
timestamp=$(get_timestamp)
echo "Current time: $timestamp"

# Custom format
timestamp=$(get_timestamp "%Y%m%d_%H%M%S")
echo "Timestamp: $timestamp"
```

---

###### `generate_uuid()`
Generate a UUID v4.

**Parameters**: None

**Returns**: UUID string

**Example**:
```bash
uuid=$(generate_uuid)
echo "Generated UUID: $uuid"
```

---

###### `calculate_duration(start_time, end_time)`
Calculate duration between two timestamps.

**Parameters**:
- `start_time` (integer, required): Start timestamp (Unix epoch)
- `end_time` (integer, required): End timestamp (Unix epoch)

**Returns**: Duration in seconds

**Example**:
```bash
start=$(date +%s)
# ... perform operation ...
end=$(date +%s)
duration=$(calculate_duration "$start" "$end")
echo "Operation took ${duration}s"
```

---

## Step Modules

Step modules implement the 20-step workflow pipeline. Each step follows a standard interface.

### Standard Step Interface

All step modules implement these functions:

#### `validate_step_XX()`
Pre-flight validation before step execution.

**Parameters**: None

**Returns**: 
- `0` - Validation passed, proceed with execution
- `1` - Validation failed, skip step

**Example**:
```bash
validate_step_01() {
    if [[ ! -d "docs" ]]; then
        log_warning "No docs directory found"
        return 1
    fi
    return 0
}
```

---

#### `execute_step_XX()`
Main step execution logic.

**Parameters**: None

**Returns**: 
- `0` - Execution successful
- `1` - Execution failed

**Side Effects**: 
- Generates step report in `backlog/`
- Updates metrics

**Example**:
```bash
execute_step_01() {
    log_info "Analyzing documentation..."
    
    # Step logic here
    
    generate_step_report "01" "Documentation Analysis"
    return 0
}
```

---

### Step Module Reference

#### Step 0a: Pre-Processing

**Module**: `version_update.sh`  
**Purpose**: Version management and pre-execution setup  
**Dependencies**: None  
**AI Persona**: None

**Key Operations**:
- Initialize workflow environment
- Set up logging and metrics
- Validate prerequisites

---

#### Step 0b: Bootstrap Documentation

**Module**: `bootstrap_docs.sh`  
**Purpose**: Generate comprehensive documentation from scratch with necessity-first evaluation  
**Dependencies**: `ai_helpers.sh`, `ai_personas.sh`  
**AI Persona**: `technical_writer` (v3.1.0, UPDATED v4.0.1)

**Key Operations**:
- Evaluate documentation necessity (NEW v4.0.1)
- Analyze codebase structure (if generation needed)
- Generate API documentation (if gaps exist)
- Create user guides (if missing)
- Generate architecture documentation (if complex system undocumented)

**Configuration**:
```yaml
step_0b:
  enabled: true
  parallel_generation: true
  documentation_types:
    - api_reference
    - user_guide
    - architecture
    - developer_guide
```

**Example Usage**:
```bash
# Bootstrap documentation for new project
./execute_tests_docs_workflow.sh --steps 0b
```

---

#### Step 00: Change Analysis

**Module**: `pre_analysis.sh`  
**Purpose**: Analyze Git changes and determine execution strategy  
**Dependencies**: `change_detection.sh`, `workflow_optimization.sh`  
**AI Persona**: `change_analyst`

**Key Operations**:
- Analyze Git diff
- Categorize changes (docs, code, tests, config)
- Generate optimization recommendations

---

#### Step 01: Documentation Analysis

**Module**: `documentation.sh`  
**Purpose**: Analyze and validate documentation quality  
**Dependencies**: `ai_helpers.sh`, `doc_template_validator.sh`  
**AI Persona**: `documentation_specialist`

**Key Operations**:
- Review documentation completeness
- Check for outdated content
- Validate documentation structure
- Generate improvement recommendations

**Performance**: 75-85% faster with Step 1 Optimization (v3.2.0)
- Incremental processing (96% time savings for unchanged docs)
- Parallel analysis (71% time savings)

---

#### Step 02: Consistency Check

**Module**: `consistency.sh`  
**Purpose**: Verify consistency across documentation  
**Dependencies**: `ai_helpers.sh`  
**AI Persona**: `documentation_specialist`

**Key Operations**:
- Check version consistency
- Validate cross-references
- Ensure terminology consistency

---

#### Step 02.5: Documentation Optimization

**Module**: `doc_optimize.sh`  
**Purpose**: Optimize documentation structure and content  
**Dependencies**: `ai_helpers.sh`, `edit_operations.sh`  
**AI Persona**: `documentation_specialist`

**Key Operations**:
- Remove duplicate content
- Improve navigation
- Enhance readability

---

#### Step 03: Script References

**Module**: `script_refs.sh`  
**Purpose**: Validate script references in documentation  
**Dependencies**: `validation.sh`  
**AI Persona**: `script_reference_validator`

**Key Operations**:
- Find all script references
- Verify scripts exist
- Check script permissions

---

#### Step 04: Config Validation

**Module**: `config_validation.sh`  
**Purpose**: Validate workflow and project configuration  
**Dependencies**: `config_wizard.sh`, `validation.sh`  
**AI Persona**: `config_validator`

**Key Operations**:
- Validate YAML syntax
- Check required fields
- Verify configuration values

---

#### Step 05: Directory Structure

**Module**: `directory.sh`  
**Purpose**: Analyze and validate project directory structure  
**Dependencies**: `validation.sh`  
**AI Persona**: `directory_analyst`

**Key Operations**:
- Check for required directories
- Validate naming conventions
- Generate structure report

---

#### Step 06: Test Review

**Module**: `test_review.sh`  
**Purpose**: Review existing tests for coverage and quality  
**Dependencies**: `ai_helpers.sh`, `tech_stack.sh`  
**AI Persona**: `test_engineer`

**Key Operations**:
- Analyze test coverage
- Review test quality
- Identify missing tests

---

#### Step 07: Test Generation

**Module**: `test_gen.sh`  
**Purpose**: Generate missing tests  
**Dependencies**: `ai_helpers.sh`, `tech_stack.sh`  
**AI Persona**: `test_engineer`

**Key Operations**:
- Generate unit tests
- Create integration tests
- Generate test fixtures

---

#### Step 08: Test Execution

**Module**: `test_exec.sh`  
**Purpose**: Execute test suite and validate results  
**Dependencies**: `tech_stack.sh`, `metrics.sh`  
**AI Persona**: None

**Key Operations**:
- Run test suite
- Collect test results
- Generate test report

---

#### Step 09: Dependencies

**Module**: `dependencies.sh`  
**Purpose**: Analyze and update project dependencies  
**Dependencies**: `tech_stack.sh`  
**AI Persona**: `dependency_analyst`

**Key Operations**:
- Check for outdated dependencies
- Identify security vulnerabilities
- Generate update recommendations

---

#### Step 10: Code Quality

**Module**: `code_quality.sh`  
**Purpose**: Comprehensive code quality assessment  
**Dependencies**: `ai_helpers.sh`, `metrics.sh`  
**AI Persona**: `software_quality_engineer`

**Key Operations**:
- Run linters
- Check code style
- Analyze complexity
- Generate quality report (score: A-F)

---

#### Step 11: Deployment Gate

**Module**: `deployment_gate.sh`  
**Purpose**: Pre-deployment validation and gating  
**Dependencies**: `validation.sh`, `metrics.sh`  
**AI Persona**: None

**Key Operations**:
- Validate deployment readiness
- Check quality gates
- Generate deployment report

---

#### Step 11.5: Context Management

**Module**: `context.sh`  
**Purpose**: Manage workflow context and scope  
**Dependencies**: None  
**AI Persona**: `context_manager`

**Key Operations**:
- Update context files
- Clean up temporary files
- Archive session data

---

#### Step 12: Git Automation

**Module**: `git_finalization.sh`  
**Purpose**: Automated Git operations and finalization  
**Dependencies**: `git_automation.sh`, `auto_commit.sh`  
**AI Persona**: `git_automation_specialist`

**Key Operations**:
- Stage workflow artifacts
- Generate commit messages
- Create commits (with `--auto-commit`)
- Tag releases

---

#### Step 13: Markdown Linting

**Module**: `markdown_lint.sh`  
**Purpose**: Lint and format Markdown documentation  
**Dependencies**: None (uses markdownlint-cli if available)  
**AI Persona**: `markdown_formatter`

**Key Operations**:
- Run markdownlint
- Fix common issues
- Generate lint report

---

#### Step 14: Prompt Engineer

**Module**: `prompt_engineer.sh`  
**Purpose**: Optimize AI prompts and templates  
**Dependencies**: `ai_helpers.sh`, `ai_prompt_builder.sh`  
**AI Persona**: `prompt_engineer`

**Key Operations**:
- Analyze prompt effectiveness
- Optimize prompt templates
- Generate prompt improvements

---

#### Step 15: UX Analysis

**Module**: `ux_analysis.sh`  
**Purpose**: UI/UX and accessibility analysis  
**Dependencies**: `ai_helpers.sh`  
**AI Persona**: `ux_designer`

**Key Operations**:
- Analyze UI components
- Check WCAG 2.1 compliance
- Generate UX recommendations

**Applicable To**: client_spa, react_spa, vue_spa projects

---

#### Step 16: Version Update

**Module**: `final_version_update.sh`  
**Purpose**: Update version numbers and finalize workflow  
**Dependencies**: `metrics.sh`, `changelog_generator.sh`  
**AI Persona**: None

**Key Operations**:
- Update version files
- Generate/update CHANGELOG
- Finalize metrics

---

## Orchestrators

Orchestrators coordinate high-level workflow phases.

### pre_flight.sh

**Purpose**: Pre-flight checks and setup  
**Functions**: `run_pre_flight_checks()`

**Operations**:
- Validate environment
- Check dependencies
- Initialize metrics
- Setup workspace

---

### validation.sh (orchestrator)

**Purpose**: Coordinate validation steps  
**Functions**: `run_validation_phase()`

**Operations**:
- Execute Steps 00-05
- Collect validation results
- Generate validation report

---

### quality.sh (orchestrator)

**Purpose**: Coordinate quality assurance steps  
**Functions**: `run_quality_phase()`

**Operations**:
- Execute Steps 06-10
- Run tests and quality checks
- Generate quality report

---

### finalization.sh (orchestrator)

**Purpose**: Coordinate finalization steps  
**Functions**: `run_finalization_phase()`

**Operations**:
- Execute Steps 11-16
- Archive artifacts
- Cleanup and reporting

---

## Configuration Files

Configuration files in `.workflow_core/config/`.

### paths.yaml

**Purpose**: Path configuration and resolution

**Key Sections**:
```yaml
workflow:
  root: .
  lib: src/workflow/lib
  steps: src/workflow/steps
  config: .workflow_core/config

output:
  backlog: backlog
  logs: logs
  metrics: metrics
```

---

### ai_helpers.yaml

**Purpose**: AI prompt templates and persona definitions

**Size**: 762 lines

**Key Sections**:
- Base prompt templates
- Persona system prompts
- Language-specific conventions
- Project-kind specific prompts

---

### project_kinds.yaml

**Purpose**: Project type definitions and standards

**Key Sections**:
```yaml
project_kinds:
  nodejs_api:
    test_frameworks: [jest, mocha]
    quality_standards:
      code_quality: 85
      test_coverage: 80
  shell_automation:
    test_frameworks: [bats]
    quality_standards:
      code_quality: 80
      test_coverage: 70
```

---

### ai_prompts_project_kinds.yaml

**Purpose**: Project-kind specific AI prompts

**Personas**:
- documentation_specialist
- code_reviewer
- test_engineer
- ux_designer

---

## Usage Patterns

### Basic Workflow Execution

```bash
#!/bin/bash

# Source required modules
source "$(dirname "$0")/lib/ai_helpers.sh"
source "$(dirname "$0")/lib/metrics.sh"

# Initialize
init_metrics
validate_copilot_cli || exit 1

# Execute workflow
for step in {00..16}; do
    if validate_step_"${step}"; then
        execute_step_"${step}"
    fi
done

# Finalize
finalize_metrics
```

---

### Smart Execution Pattern

```bash
#!/bin/bash

source "$(dirname "$0")/lib/workflow_optimization.sh"
source "$(dirname "$0")/lib/change_detection.sh"

# Analyze changes
changes=$(analyze_changes)

# Execute only necessary steps
for step in {00..16}; do
    if should_skip_step "$step"; then
        log_info "Skipping step $step (no relevant changes)"
        continue
    fi
    execute_step "$step"
done
```

---

### Parallel Execution Pattern

```bash
#!/bin/bash

source "$(dirname "$0")/lib/workflow_optimization.sh"

# Get parallel groups
groups=$(get_parallel_groups)

# Execute each group in parallel
echo "$groups" | jq -r '.[]' | while read -r group; do
    # Parse step numbers from group
    steps=($(echo "$group" | jq -r '.[]'))
    
    # Execute steps in parallel
    for step in "${steps[@]}"; do
        execute_step "$step" &
    done
    
    # Wait for group to complete
    wait
done
```

---

### AI Call Pattern with Caching

```bash
#!/bin/bash

source "$(dirname "$0")/lib/ai_helpers.sh"
source "$(dirname "$0")/lib/ai_cache.sh"

ai_call_with_cache() {
    local persona="$1"
    local prompt="$2"
    local output_file="$3"
    
    # Check cache first
    if cached=$(get_cached_response "$prompt"); then
        log_info "Using cached AI response"
        echo "$cached" > "$output_file"
        return 0
    fi
    
    # Make AI call
    response=$(execute_copilot_prompt "$prompt")
    
    # Cache response
    cache_ai_response "$prompt" "$response"
    
    # Write output
    echo "$response" > "$output_file"
}
```

---

### Error Handling Pattern

```bash
#!/bin/bash

# Set error handling
set -euo pipefail

# Trap errors
trap 'handle_error $? $LINENO' ERR

handle_error() {
    local exit_code=$1
    local line_number=$2
    
    log_error "Error on line $line_number (exit code: $exit_code)"
    
    # Cleanup
    cleanup_on_error
    
    # Save checkpoint
    save_checkpoint "$CURRENT_STEP"
    
    exit "$exit_code"
}

# Cleanup function
cleanup_on_error() {
    log_info "Performing cleanup..."
    
    # Kill background processes
    kill_background_processes
    
    # Archive partial results
    archive_session
    
    # Generate error report
    generate_error_report
}
```

---

## Error Handling

### Common Error Codes

- `0` - Success
- `1` - General error
- `2` - Invalid arguments
- `3` - Missing dependencies
- `4` - Configuration error
- `5` - Validation failure
- `6` - Execution failure
- `7` - AI call failure
- `8` - File operation error
- `9` - Git operation error

### Error Handling Functions

#### `handle_error(exit_code, line_number, [context])`

Global error handler for workflow execution.

**Parameters**:
- `exit_code` (integer, required): Error exit code
- `line_number` (integer, required): Line number where error occurred
- `context` (string, optional): Additional error context

**Example**:
```bash
trap 'handle_error $? $LINENO "Step 05 execution"' ERR
```

---

## Best Practices

### Module Development

1. **Follow Single Responsibility Principle**
   - Each module should have one clear purpose
   - Keep functions focused and small

2. **Use Consistent Naming**
   - Functions: `verb_noun()` pattern
   - Variables: `lowercase_with_underscores`
   - Constants: `UPPERCASE_WITH_UNDERSCORES`

3. **Document Functions**
   ```bash
   # Function: calculate_duration
   # Purpose: Calculate duration between two timestamps
   # Parameters:
   #   $1 - start_time (Unix timestamp)
   #   $2 - end_time (Unix timestamp)
   # Returns: Duration in seconds
   # Example: duration=$(calculate_duration "$start" "$end")
   calculate_duration() {
       local start_time=$1
       local end_time=$2
       echo $((end_time - start_time))
   }
   ```

4. **Error Handling**
   - Always check return codes
   - Use `set -euo pipefail`
   - Provide meaningful error messages

5. **Testing**
   - Write tests for all public functions
   - Use test fixtures for file operations
   - Mock external dependencies

### Workflow Execution

1. **Use Smart Execution**
   - Enable `--smart-execution` for faster iterations
   - Combine with `--parallel` for maximum performance

2. **Monitor Metrics**
   - Review metrics after each run
   - Track optimization improvements
   - Identify bottlenecks

3. **Leverage AI Cache**
   - Cache is enabled by default
   - 60-80% token reduction
   - 24-hour TTL

4. **Configure Project Kind**
   - Run `--init-config` for new projects
   - Explicit configuration improves accuracy
   - Enables project-specific features

5. **Use Workflow Templates**
   - `docs-only.sh` for documentation changes (3-4 min)
   - `test-only.sh` for test development (8-10 min)
   - `feature.sh` for full feature development (15-20 min)

### Performance Optimization

1. **Combine Optimization Features**
   ```bash
   ./execute_tests_docs_workflow.sh \
       --smart-execution \
       --parallel \
       --ml-optimize \
       --multi-stage \
       --auto
   ```

2. **Use ML Optimization**
   - Requires 10+ historical runs
   - 15-30% additional performance improvement
   - Predictive step durations

3. **Multi-Stage Pipeline**
   - 80%+ of runs complete in first 2 stages
   - Progressive validation
   - Faster failure detection

### CI/CD Integration

1. **GitHub Actions Example**
   ```yaml
   - name: Run Workflow Automation
     run: |
       ./execute_tests_docs_workflow.sh \
         --auto \
         --smart-execution \
         --parallel \
         --auto-commit
   ```

2. **Pre-Commit Hook**
   ```bash
   # Install hooks
   ./execute_tests_docs_workflow.sh --install-hooks
   
   # Test hooks without committing
   ./execute_tests_docs_workflow.sh --test-hooks
   ```

---

## See Also

- [PROJECT_REFERENCE.md](PROJECT_REFERENCE.md) - Complete project reference
- [USER_GUIDE.md](user-guide/USER_GUIDE.md) - User guide
- [COMMAND_LINE_REFERENCE.md](user-guide/COMMAND_LINE_REFERENCE.md) - CLI reference
- [MODULE_DEVELOPMENT.md](developer-guide/MODULE_DEVELOPMENT.md) - Module development guide
- [COOKBOOK.md](COOKBOOK.md) - Real-world recipes
- [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - Integration patterns

---

**Last Updated**: 2026-02-08  
**Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))
