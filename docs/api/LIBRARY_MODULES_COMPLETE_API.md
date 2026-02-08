# Library Modules - Complete API Reference

**Version**: v4.0.0  
**Last Updated**: 2026-02-08

> 📋 **Note**: This is the comprehensive API reference for all 81 library modules in `src/workflow/lib/`. For quick reference, see [API_REFERENCE.md](../reference/API_REFERENCE.md).

## Table of Contents

- [Core Modules](#core-modules)
- [AI Integration Modules](#ai-integration-modules)
- [Performance & Optimization](#performance--optimization)
- [File & Data Operations](#file--data-operations)
- [Git & Version Control](#git--version-control)
- [Testing & Validation](#testing--validation)
- [Configuration & Setup](#configuration--setup)
- [Reporting & Metrics](#reporting--metrics)
- [Utility Modules](#utility-modules)

---

## Core Modules

### ai_helpers.sh
**Purpose**: Primary AI integration module for GitHub Copilot CLI interaction  
**Size**: 102K  
**Functions**:

#### `is_copilot_available()`
Check if GitHub Copilot CLI is available in the system.

**Returns**: 
- `0` - Copilot CLI is available
- `1` - Copilot CLI is not available

**Example**:
```bash
if is_copilot_available; then
    echo "Copilot CLI is ready"
fi
```

#### `is_copilot_authenticated()`
Verify if the user is authenticated with GitHub Copilot.

**Returns**:
- `0` - Authenticated
- `1` - Not authenticated

#### `validate_copilot_cli()`
Comprehensive validation of Copilot CLI setup including availability and authentication.

**Returns**:
- `0` - Copilot CLI is ready to use
- `1` - Validation failed

#### `get_project_metadata()`
Extract project metadata for AI context.

**Returns**: JSON string with project information
```json
{
  "name": "project-name",
  "version": "1.0.0",
  "type": "nodejs_api",
  "tech_stack": ["nodejs", "express"]
}
```

#### `build_ai_prompt(persona, context, template)`
Build a context-aware AI prompt using persona and template.

**Parameters**:
- `persona` - AI persona name (e.g., "documentation_specialist")
- `context` - Context information to include
- `template` - Template name from YAML config

**Returns**: Formatted prompt string

**Example**:
```bash
prompt=$(build_ai_prompt "code_reviewer" "$file_content" "review_template")
```

#### `compose_role_from_yaml(persona)`
Load and compose AI persona role from YAML configuration.

**Parameters**:
- `persona` - Persona identifier

**Returns**: Role description string

#### `build_doc_analysis_prompt(files)`
Build specialized prompt for documentation analysis.

**Parameters**:
- `files` - Array of documentation files to analyze

**Returns**: Analysis prompt string

#### `build_consistency_prompt(docs_list)`
Build prompt for documentation consistency checking.

**Parameters**:
- `docs_list` - List of documentation files

**Returns**: Consistency check prompt

#### `build_test_strategy_prompt(project_type)`
Build prompt for test strategy generation.

**Parameters**:
- `project_type` - Type of project (e.g., "nodejs_api", "python_cli")

**Returns**: Test strategy prompt

#### `build_quality_prompt(code_files)`
Build prompt for code quality assessment.

**Parameters**:
- `code_files` - Array of source code files

**Returns**: Quality assessment prompt

---

### tech_stack.sh
**Purpose**: Technology stack detection and management  
**Size**: 47K  
**Functions**:

#### `detect_tech_stack(project_dir)`
Automatically detect the technology stack of a project.

**Parameters**:
- `project_dir` - Path to project directory

**Returns**: JSON object with detected technologies
```json
{
  "primary_language": "javascript",
  "frameworks": ["react", "express"],
  "tools": ["npm", "jest"],
  "project_kind": "nodejs_api"
}
```

**Example**:
```bash
tech_stack=$(detect_tech_stack "/path/to/project")
echo "$tech_stack" | jq '.primary_language'
```

#### `get_primary_language(project_dir)`
Identify the primary programming language.

**Parameters**:
- `project_dir` - Project directory path

**Returns**: Language name (e.g., "javascript", "python", "shell")

#### `detect_frameworks(project_dir)`
Detect frameworks used in the project.

**Returns**: Array of framework names

#### `detect_test_framework(project_dir)`
Identify the testing framework.

**Returns**: Test framework name (e.g., "jest", "pytest", "bats")

#### `detect_build_tool(project_dir)`
Identify the build tool used.

**Returns**: Build tool name (e.g., "npm", "webpack", "make")

---

### workflow_optimization.sh
**Purpose**: Smart execution and parallel processing optimization  
**Size**: 31K  
**Functions**:

#### `analyze_changes_for_smart_execution()`
Analyze git changes to determine which steps can be skipped.

**Returns**: Array of step indices that should run

**Example**:
```bash
required_steps=$(analyze_changes_for_smart_execution)
echo "Steps to run: ${required_steps[@]}"
```

#### `can_skip_step(step_index)`
Determine if a specific step can be safely skipped.

**Parameters**:
- `step_index` - Step number to check

**Returns**:
- `0` - Step can be skipped
- `1` - Step must run

#### `get_parallel_groups()`
Identify which steps can run in parallel.

**Returns**: JSON array of step groups
```json
[
  [2, 3, 4],
  [5, 6],
  [7]
]
```

#### `execute_parallel_steps(step_array)`
Execute an array of steps in parallel.

**Parameters**:
- `step_array` - Array of step indices

**Returns**:
- `0` - All steps succeeded
- `1` - One or more steps failed

#### `wait_for_parallel_completion()`
Wait for all parallel processes to complete.

**Returns**: Combined exit status of all processes

---

### change_detection.sh
**Purpose**: Git diff analysis and change tracking  
**Size**: 17K  
**Functions**:

#### `analyze_changes()`
Perform comprehensive analysis of git changes.

**Returns**: JSON object with change details
```json
{
  "files_modified": 5,
  "docs_changed": true,
  "code_changed": true,
  "tests_changed": false,
  "categories": ["documentation", "source"]
}
```

#### `get_changed_files()`
Get list of files that have been modified.

**Returns**: Array of file paths

**Example**:
```bash
changed_files=$(get_changed_files)
for file in "${changed_files[@]}"; do
    echo "Modified: $file"
done
```

#### `detect_change_categories()`
Categorize changes by type (docs, code, tests, config).

**Returns**: Array of change categories

#### `has_documentation_changes()`
Check if documentation files were modified.

**Returns**:
- `0` - Documentation was modified
- `1` - No documentation changes

#### `has_code_changes()`
Check if source code files were modified.

**Returns**:
- `0` - Code was modified
- `1` - No code changes

#### `has_test_changes()`
Check if test files were modified.

**Returns**:
- `0` - Tests were modified
- `1` - No test changes

---

### metrics.sh
**Purpose**: Performance tracking and metrics collection  
**Size**: 16K  
**Functions**:

#### `init_metrics()`
Initialize metrics tracking for the current workflow run.

**Returns**: Metrics session ID

**Example**:
```bash
init_metrics
# ... workflow execution ...
finalize_metrics
```

#### `start_step_timer(step_name)`
Start timing a workflow step.

**Parameters**:
- `step_name` - Name of the step

#### `stop_step_timer(step_name)`
Stop timing a workflow step and record duration.

**Parameters**:
- `step_name` - Name of the step

**Returns**: Duration in seconds

#### `record_metric(key, value)`
Record a custom metric.

**Parameters**:
- `key` - Metric name
- `value` - Metric value

**Example**:
```bash
record_metric "ai_calls_count" 15
record_metric "cache_hit_rate" 0.75
```

#### `get_metric(key)`
Retrieve a recorded metric value.

**Parameters**:
- `key` - Metric name

**Returns**: Metric value

#### `finalize_metrics()`
Finalize metrics collection and save to disk.

**Returns**: Path to metrics file

#### `generate_metrics_report()`
Generate a human-readable metrics report.

**Returns**: Formatted metrics report string

---

## AI Integration Modules

### ai_cache.sh
**Purpose**: AI response caching with TTL management  
**Size**: 11K  
**Functions**:

#### `init_ai_cache()`
Initialize the AI response cache system.

**Example**:
```bash
init_ai_cache
```

#### `generate_cache_key(prompt, persona)`
Generate a unique cache key for an AI prompt.

**Parameters**:
- `prompt` - AI prompt text
- `persona` - AI persona name

**Returns**: SHA256 hash key

#### `check_cache(cache_key)`
Check if a cached response exists and is valid.

**Parameters**:
- `cache_key` - Cache key to check

**Returns**:
- `0` - Cache hit (valid cached response exists)
- `1` - Cache miss

#### `get_cached_response(cache_key)`
Retrieve a cached AI response.

**Parameters**:
- `cache_key` - Cache key

**Returns**: Cached response content

#### `save_to_cache(cache_key, response)`
Save an AI response to cache.

**Parameters**:
- `cache_key` - Cache key
- `response` - Response content to cache

**Example**:
```bash
key=$(generate_cache_key "$prompt" "code_reviewer")
if ! check_cache "$key"; then
    response=$(call_ai "$prompt")
    save_to_cache "$key" "$response"
fi
```

#### `cleanup_ai_cache_old_entries()`
Remove expired cache entries (default TTL: 24 hours).

**Returns**: Number of entries removed

#### `get_cache_stats()`
Get cache statistics.

**Returns**: JSON object with cache metrics
```json
{
  "total_entries": 150,
  "cache_size_mb": 2.5,
  "hit_rate": 0.72,
  "oldest_entry_hours": 20
}
```

#### `clear_ai_cache()`
Clear all cache entries.

---

### ai_personas.sh
**Purpose**: AI persona management and project-aware prompting  
**Size**: Varies  
**Functions**:

#### `get_project_kind_prompt(project_kind)`
Get project-kind-specific prompt enhancement.

**Parameters**:
- `project_kind` - Project type (e.g., "nodejs_api", "python_cli")

**Returns**: Project-specific prompt additions

#### `build_project_kind_prompt(persona, project_kind)`
Build a project-aware AI prompt.

**Parameters**:
- `persona` - AI persona name
- `project_kind` - Project type

**Returns**: Enhanced prompt string

#### `should_use_project_kind_prompts()`
Check if project-kind-specific prompts should be used.

**Returns**:
- `0` - Use project-kind prompts
- `1` - Use generic prompts

#### `get_language_documentation_conventions(language)`
Get documentation conventions for a specific language.

**Parameters**:
- `language` - Programming language

**Returns**: Documentation convention guidelines

#### `get_language_quality_standards(language)`
Get code quality standards for a language.

**Parameters**:
- `language` - Programming language

**Returns**: Quality standard guidelines

---

### ai_prompt_builder.sh
**Purpose**: Dynamic AI prompt construction with language-aware enhancements  
**Size**: Varies  
**Functions**:

#### `get_language_specific_content(template_name, language)`
Get language-specific content from YAML templates.

**Parameters**:
- `template_name` - Template identifier
- `language` - Programming language

**Returns**: Language-specific template content

#### `substitute_language_placeholders(prompt, language)`
Replace language placeholders in prompts with actual content.

**Parameters**:
- `prompt` - Prompt template with placeholders
- `language` - Target language

**Returns**: Prompt with substituted content

#### `build_ai_prompt(persona, context, options)`
Build a complete AI prompt with all enhancements.

**Parameters**:
- `persona` - AI persona
- `context` - Contextual information
- `options` - Additional options (JSON)

**Returns**: Complete prompt string

---

### ai_validation.sh
**Purpose**: AI response validation and quality checking  
**Size**: Varies  
**Functions**:

#### `validate_ai_response(response, expected_format)`
Validate an AI response against expected format.

**Parameters**:
- `response` - AI response content
- `expected_format` - Expected format (e.g., "markdown", "json")

**Returns**:
- `0` - Response is valid
- `1` - Response is invalid

#### `should_enable_ai()`
Determine if AI features should be enabled.

**Returns**:
- `0` - AI should be enabled
- `1` - AI should be disabled

---

## Performance & Optimization

### analysis_cache.sh
**Purpose**: File analysis result caching  
**Size**: Varies  
**Functions**:

#### `init_analysis_cache()`
Initialize the analysis cache system.

#### `generate_file_hash(file_path)`
Generate a hash for file content.

**Parameters**:
- `file_path` - Path to file

**Returns**: SHA256 hash of file content

#### `check_docs_analysis_cache(file_list)`
Check if documentation analysis is cached.

**Parameters**:
- `file_list` - Array of documentation files

**Returns**:
- `0` - Cached analysis exists
- `1` - Cache miss

#### `save_docs_analysis_cache(file_list, analysis_result)`
Save documentation analysis to cache.

**Parameters**:
- `file_list` - Array of files analyzed
- `analysis_result` - Analysis result content

---

### code_changes_optimization.sh
**Purpose**: Optimize workflow based on code changes  
**Functions**:

#### `optimize_for_code_changes(changed_files)`
Determine optimal workflow configuration for specific code changes.

**Parameters**:
- `changed_files` - Array of modified files

**Returns**: Optimization recommendations

---

### ml_optimizer.sh
**Purpose**: Machine learning-based workflow optimization  
**Functions**:

#### `init_ml_optimizer()`
Initialize ML optimization system.

#### `predict_step_duration(step_index, context)`
Predict how long a step will take based on historical data.

**Parameters**:
- `step_index` - Step number
- `context` - Execution context

**Returns**: Predicted duration in seconds

#### `train_ml_model()`
Train ML model with historical workflow data.

**Returns**:
- `0` - Training successful
- `1` - Insufficient data or training failed

#### `get_ml_recommendations()`
Get ML-based workflow recommendations.

**Returns**: JSON object with recommendations

---

## File & Data Operations

### file_operations.sh
**Purpose**: Safe file operations with error handling  
**Size**: 15K  
**Functions**:

#### `safe_read_file(file_path)`
Safely read a file with error handling.

**Parameters**:
- `file_path` - Path to file

**Returns**: File content or error message

#### `safe_write_file(file_path, content)`
Safely write content to file with backup.

**Parameters**:
- `file_path` - Target file path
- `content` - Content to write

**Returns**:
- `0` - Write successful
- `1` - Write failed

#### `backup_file(file_path)`
Create a backup of a file.

**Parameters**:
- `file_path` - File to backup

**Returns**: Path to backup file

#### `restore_backup(backup_path)`
Restore a file from backup.

**Parameters**:
- `backup_path` - Path to backup file

**Returns**:
- `0` - Restore successful
- `1` - Restore failed

---

### edit_operations.sh
**Purpose**: Advanced file editing operations  
**Size**: 14K  
**Functions**:

#### `edit_file_section(file_path, start_line, end_line, new_content)`
Edit a specific section of a file.

**Parameters**:
- `file_path` - File to edit
- `start_line` - Start line number
- `end_line` - End line number
- `new_content` - Replacement content

**Returns**:
- `0` - Edit successful
- `1` - Edit failed

#### `append_to_file(file_path, content)`
Append content to end of file.

**Parameters**:
- `file_path` - Target file
- `content` - Content to append

#### `prepend_to_file(file_path, content)`
Prepend content to beginning of file.

**Parameters**:
- `file_path` - Target file
- `content` - Content to prepend

---

### yaml_parser.sh
**Purpose**: YAML parsing and manipulation  
**Functions**:

#### `parse_yaml(yaml_file, query)`
Parse YAML file and extract value.

**Parameters**:
- `yaml_file` - Path to YAML file
- `query` - yq query expression

**Returns**: Query result

**Example**:
```bash
version=$(parse_yaml "config.yaml" ".version")
```

#### `update_yaml(yaml_file, path, value)`
Update a value in YAML file.

**Parameters**:
- `yaml_file` - YAML file path
- `path` - Path to value (yq format)
- `value` - New value

---

## Git & Version Control

### git_helpers.sh
**Purpose**: Git operations and utilities  
**Functions**:

#### `get_changed_files_since(commit_ref)`
Get files changed since a specific commit.

**Parameters**:
- `commit_ref` - Commit reference (e.g., "HEAD~1", "main")

**Returns**: Array of file paths

#### `is_git_repository()`
Check if current directory is a git repository.

**Returns**:
- `0` - Is git repository
- `1` - Not a git repository

#### `get_current_branch()`
Get the current git branch name.

**Returns**: Branch name

#### `has_uncommitted_changes()`
Check for uncommitted changes.

**Returns**:
- `0` - Has uncommitted changes
- `1` - No uncommitted changes

---

### version_control.sh
**Purpose**: Version management and tagging  
**Functions**:

#### `get_current_version()`
Get current version from git tags or version file.

**Returns**: Version string (e.g., "4.0.0")

#### `bump_version(increment_type)`
Bump version number.

**Parameters**:
- `increment_type` - "major", "minor", or "patch"

**Returns**: New version string

#### `create_version_tag(version, message)`
Create a git tag for a version.

**Parameters**:
- `version` - Version string
- `message` - Tag message

---

## Configuration & Setup

### config_wizard.sh
**Purpose**: Interactive configuration wizard  
**Size**: 16K  
**Functions**:

#### `run_config_wizard()`
Run interactive configuration wizard.

**Returns**: Path to generated config file

#### `detect_and_prompt_tech_stack()`
Detect tech stack and prompt for confirmation.

**Returns**: Tech stack configuration

#### `generate_config_file(config_data)`
Generate workflow configuration file.

**Parameters**:
- `config_data` - Configuration data (JSON)

**Returns**: Path to config file

---

### project_kind_config.sh
**Purpose**: Project kind configuration management  
**Size**: 26K  
**Functions**:

#### `load_project_kind_config(kind)`
Load configuration for a specific project kind.

**Parameters**:
- `kind` - Project kind identifier

**Returns**: Configuration object

#### `get_test_command(project_kind)`
Get appropriate test command for project kind.

**Parameters**:
- `project_kind` - Project type

**Returns**: Test command string

---

## Testing & Validation

### test_discovery.sh
**Purpose**: Automatic test discovery  
**Functions**:

#### `discover_tests(project_dir)`
Automatically discover test files in project.

**Parameters**:
- `project_dir` - Project directory

**Returns**: Array of test file paths

#### `identify_test_framework(test_files)`
Identify which test framework is being used.

**Parameters**:
- `test_files` - Array of test files

**Returns**: Test framework name

---

### validation.sh
**Purpose**: General validation utilities  
**Functions**:

#### `validate_file_exists(file_path)`
Validate that a file exists.

**Parameters**:
- `file_path` - File path to check

**Returns**:
- `0` - File exists
- `1` - File does not exist

#### `validate_directory_exists(dir_path)`
Validate that a directory exists.

**Parameters**:
- `dir_path` - Directory path to check

**Returns**:
- `0` - Directory exists
- `1` - Directory does not exist

---

## Reporting & Metrics

### backlog.sh
**Purpose**: Workflow execution history and backlog management  
**Functions**:

#### `init_backlog_entry()`
Initialize a new backlog entry for current run.

**Returns**: Backlog entry directory path

#### `save_step_report(step_name, content)`
Save a step execution report to backlog.

**Parameters**:
- `step_name` - Name of step
- `content` - Report content

---

### changelog_generator.sh
**Purpose**: Automatic changelog generation  
**Functions**:

#### `generate_changelog(version, changes)`
Generate changelog entry.

**Parameters**:
- `version` - Version number
- `changes` - Array of changes

**Returns**: Changelog markdown

---

## Utility Modules

### colors.sh
**Purpose**: Terminal color output utilities  
**Functions**:

#### `print_color(color, message)`
Print colored text to terminal.

**Parameters**:
- `color` - Color name (red, green, blue, yellow, etc.)
- `message` - Message to print

**Example**:
```bash
print_color "green" "✓ Success"
print_color "red" "✗ Error"
```

---

### logging.sh
**Purpose**: Structured logging utilities  
**Functions**:

#### `log_info(message)`
Log info-level message.

#### `log_warning(message)`
Log warning-level message.

#### `log_error(message)`
Log error-level message.

#### `log_debug(message)`
Log debug-level message (only if debug enabled).

---

### session_manager.sh
**Purpose**: Process and session management  
**Size**: 12K  
**Functions**:

#### `create_session()`
Create a new workflow session.

**Returns**: Session ID

#### `get_current_session()`
Get current active session ID.

**Returns**: Session ID or empty string

#### `cleanup_session(session_id)`
Clean up a completed session.

**Parameters**:
- `session_id` - Session to clean up

---

## See Also

- [Step Modules API Reference](API_STEP_MODULES.md)
- [Orchestrator API Reference](API_ORCHESTRATORS.md)
- [Configuration Reference](../reference/CONFIGURATION_REFERENCE.md)
- [Project Reference](../PROJECT_REFERENCE.md)

---

**Maintained by**: AI Workflow Automation Team  
**Repository**: [github.com/mpbarbosa/ai_workflow](https://github.com/mpbarbosa/ai_workflow)
