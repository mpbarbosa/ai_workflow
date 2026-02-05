# ai_helpers.sh - AI Integration Module

## Overview

**Module**: `src/workflow/lib/ai_helpers.sh`  
**Size**: 102K (2,977 lines)  
**Purpose**: Core AI integration module providing GitHub Copilot CLI integration, prompt building, persona management, and AI response caching.

This is the primary module for all AI interactions in the workflow system. It provides 15 specialized AI personas, handles prompt construction with project-aware enhancements, and manages communication with the GitHub Copilot CLI.

## Key Features

- ✅ **15 Specialized AI Personas** - Documentation specialist, code reviewer, test engineer, UX designer, etc.
- ✅ **Project-Aware Prompts** - Automatically adapts to project kind (shell, nodejs, python, etc.)
- ✅ **Language-Aware Enhancements** - Integrates language-specific conventions and standards
- ✅ **AI Response Caching** - 60-80% token reduction with intelligent caching
- ✅ **YAML Anchor Support** - Token-efficient prompt templates with reusable components
- ✅ **Batch Execution** - Process multiple AI requests efficiently
- ✅ **Error Recovery** - Robust error handling and fallback mechanisms

## Dependencies

### Required Modules
- `utils.sh` - Logging and output functions
- `ai_cache.sh` - AI response caching
- `project_kind_detection.sh` - Project type detection (optional)
- `tech_stack.sh` - Technology stack detection (optional)

### External Tools
- **GitHub Copilot CLI** - Primary AI integration (`copilot` command)
- **Python 3** - YAML parsing with anchor resolution (optional, fallback to awk)
- **jq** - JSON processing

### Configuration Files
- `.workflow_core/config/ai_helpers.yaml` - AI prompt templates (762 lines)
- `.workflow_core/config/ai_prompts_project_kinds.yaml` - Project-specific personas
- `.workflow_core/config/project_kinds.yaml` - Project type definitions
- `.workflow-config.yaml` - Project configuration

## Functions

### Copilot CLI Detection

#### `is_copilot_available()`
Check if GitHub Copilot CLI is installed and available.

**Returns**: 
- `0` - Copilot CLI is available
- `1` - Copilot CLI not found

**Example**:
```bash
if is_copilot_available; then
    echo "Copilot is available"
else
    echo "Please install: npm install -g @githubnext/github-copilot-cli"
fi
```

---

#### `is_copilot_authenticated()`
Check if GitHub Copilot CLI is authenticated.

**Returns**:
- `0` - Authenticated successfully
- `1` - Not authenticated or not available

**Example**:
```bash
if is_copilot_authenticated; then
    echo "Ready to use AI features"
else
    echo "Please authenticate: copilot or gh auth login"
fi
```

---

#### `validate_copilot_cli()`
Validate Copilot CLI installation and authentication, providing user feedback.

**Returns**:
- `0` - Copilot is ready to use
- `1` - Copilot not available or not authenticated

**Output**: Prints helpful messages to guide user authentication

**Example**:
```bash
if ! validate_copilot_cli; then
    echo "Skipping AI features"
    return 0
fi
```

---

### Project Metadata

#### `get_project_metadata()`
Extract project metadata from configuration files.

**Returns**: Pipe-delimited string: `project_name|project_description|primary_language`

**Configuration Sources** (in priority order):
1. `.workflow-config.yaml` (via `get_config_value`)
2. Manual YAML parsing
3. `package.json` detection
4. File-based language detection

**Example**:
```bash
IFS='|' read -r project_name project_desc primary_lang < <(get_project_metadata)
echo "Project: $project_name"
echo "Description: $project_desc"
echo "Language: $primary_lang"
```

**Default Values**:
- Project Name: "Unknown Project"
- Description: "No description available"
- Language: "Unknown" (or detected from files)

---

### Prompt Building

#### `build_ai_prompt(role, task, standards)`
Build a basic structured AI prompt with role, task, and approach sections.

**Parameters**:
- `$1` - `role` - AI role/persona description
- `$2` - `task` - Specific task to accomplish
- `$3` - `standards` - Approach and standards to follow

**Returns**: Formatted prompt text

**Example**:
```bash
role="You are a senior software engineer"
task="Review this code for security issues"
standards="Follow OWASP top 10, check for SQL injection, XSS, etc."

prompt=$(build_ai_prompt "$role" "$task" "$standards")
echo "$prompt" | copilot -t "Review code"
```

---

#### `compose_role_from_yaml(yaml_file, prompt_section)`
Compose role text from YAML configuration with YAML anchor support.

**Parameters**:
- `$1` - `yaml_file` - Path to YAML configuration file
- `$2` - `prompt_section` - Section name (e.g., "doc_analysis_prompt")

**Returns**: Complete role text (role_prefix + behavioral_guidelines or legacy role field)

**YAML Format Support**:
```yaml
# New format with YAML anchors (token-efficient)
doc_analysis_prompt:
  role_prefix: "You are a senior technical writer"
  behavioral_guidelines: *documentation_behavioral_guidelines
  
# Legacy format (backward compatible)
doc_analysis_prompt:
  role: |
    You are a senior technical writer with expertise in...
```

**Example**:
```bash
role=$(compose_role_from_yaml ".workflow_core/config/ai_helpers.yaml" "doc_analysis_prompt")
echo "$role"
```

---

### Specialized Prompt Builders

#### `build_doc_analysis_prompt(changed_files, doc_files)`
Build a documentation analysis prompt (Step 1) with project-aware enhancements.

**Parameters**:
- `$1` - `changed_files` - Space-separated list of changed files
- `$2` - `doc_files` - Documentation files to review

**Features**:
- ✅ Project kind detection (shell_automation, nodejs_api, etc.)
- ✅ Language-aware conventions
- ✅ Smart handling of large file lists (>20 files)
- ✅ Fallback to generic prompts if detection fails

**Returns**: Complete documentation analysis prompt

**Example**:
```bash
changed_files="src/api/server.js src/api/routes.js"
doc_files="README.md docs/API.md"

prompt=$(build_doc_analysis_prompt "$changed_files" "$doc_files")
copilot -t "Analyze documentation" <<< "$prompt"
```

**Output Modes**:
- **Project-Kind Specialized**: Uses project-specific standards (nodejs_api, python_library, etc.)
- **Language-Aware**: Includes language conventions (e.g., JSDoc for JavaScript)
- **Generic**: Falls back to general documentation standards

---

#### `build_consistency_prompt(docs_to_check, tech_stack_summary)`
Build a documentation consistency check prompt (Step 3).

**Parameters**:
- `$1` - `docs_to_check` - List of documentation files
- `$2` - `tech_stack_summary` - Technology stack information

**Returns**: Consistency check prompt

**Example**:
```bash
docs="README.md docs/*.md"
tech_stack="Node.js 18, Express 4.x, PostgreSQL 14"

prompt=$(build_consistency_prompt "$docs" "$tech_stack")
```

---

#### `build_test_strategy_prompt(code_changes, test_files)`
Build a test strategy analysis prompt (Step 5).

**Parameters**:
- `$1` - `code_changes` - Summary of code changes
- `$2` - `test_files` - Existing test files

**Features**:
- ✅ Test framework detection (Jest, Mocha, pytest, etc.)
- ✅ Coverage gap analysis
- ✅ Test quality assessment

**Returns**: Test strategy prompt

**Example**:
```bash
changes="New API endpoint: POST /api/users"
tests="tests/api/users.test.js"

prompt=$(build_test_strategy_prompt "$changes" "$tests")
```

---

#### `build_quality_prompt(files_to_check, quality_standards)`
Build a code quality review prompt (Step 8).

**Parameters**:
- `$1` - `files_to_check` - Files to review
- `$2` - `quality_standards` - Quality standards to enforce

**Returns**: Quality review prompt

**Example**:
```bash
files="src/**/*.js"
standards="ESLint, security best practices, performance"

prompt=$(build_quality_prompt "$files" "$standards")
```

---

#### `build_issue_extraction_prompt(log_content)`
Build a prompt to extract actionable issues from logs (Step 11).

**Parameters**:
- `$1` - `log_content` - Log file content or summary

**Returns**: Issue extraction prompt

**Example**:
```bash
log_content=$(cat workflow.log)
prompt=$(build_issue_extraction_prompt "$log_content")
```

---

### AI Execution

#### `execute_copilot_prompt(prompt, output_file, [cache_enabled])`
Execute a single AI prompt via Copilot CLI with caching support.

**Parameters**:
- `$1` - `prompt` - The AI prompt text
- `$2` - `output_file` - Where to save the response
- `$3` - `cache_enabled` - Optional: "true" to use caching (default: true)

**Features**:
- ✅ Automatic response caching (60-80% token reduction)
- ✅ Cache hit detection and logging
- ✅ Error handling with retry logic
- ✅ Progress indicators

**Returns**:
- `0` - Success (response written to output_file)
- `1` - Error (check logs)

**Example**:
```bash
prompt="Analyze this code for security issues"
output_file="security_analysis.md"

if execute_copilot_prompt "$prompt" "$output_file"; then
    echo "Analysis complete: $output_file"
else
    echo "Analysis failed"
fi

# Disable caching
execute_copilot_prompt "$prompt" "$output_file" "false"
```

**Environment Variables**:
- `AI_CACHE_ENABLED` - Global cache control (default: true)
- `AI_CACHE_TTL` - Cache lifetime in seconds (default: 86400 = 24 hours)

---

#### `execute_copilot_batch(prompts_array, output_dir)`
Execute multiple AI prompts in batch mode.

**Parameters**:
- `$1` - `prompts_array` - Array name containing prompts
- `$2` - `output_dir` - Directory for output files

**Features**:
- ✅ Parallel execution capability
- ✅ Progress tracking
- ✅ Batch caching
- ✅ Error aggregation

**Example**:
```bash
declare -a prompts=(
    "doc_analysis|Analyze documentation"
    "code_review|Review code quality"
    "test_strategy|Plan test strategy"
)

execute_copilot_batch prompts "output/"
```

---

#### `trigger_ai_step(step_name, prompt, output_file)`
High-level wrapper for executing AI steps with logging and metrics.

**Parameters**:
- `$1` - `step_name` - Name of the workflow step
- `$2` - `prompt` - AI prompt
- `$3` - `output_file` - Output file path

**Features**:
- ✅ Automatic logging
- ✅ Metrics collection
- ✅ Error handling
- ✅ Checkpoint integration

**Returns**:
- `0` - Success
- `1` - AI execution failed
- `2` - Copilot CLI not available

**Example**:
```bash
step_name="Step 2: Consistency Check"
prompt=$(build_consistency_prompt "$docs" "$tech_stack")
output="docs/consistency_report.md"

if trigger_ai_step "$step_name" "$prompt" "$output"; then
    echo "✅ $step_name completed"
else
    echo "❌ $step_name failed"
fi
```

---

### Language-Aware Prompts (v2.x)

#### `should_use_language_aware_prompts()`
Check if language-aware prompts should be used based on configuration.

**Returns**:
- `0` - Use language-aware prompts (PRIMARY_LANGUAGE is set)
- `1` - Use generic prompts

**Example**:
```bash
if should_use_language_aware_prompts; then
    prompt=$(build_language_aware_doc_prompt "$changes" "$docs")
else
    prompt=$(build_doc_analysis_prompt "$changes" "$docs")
fi
```

---

#### `get_language_documentation_conventions(language)`
Get documentation conventions for a specific language.

**Parameters**:
- `$1` - `language` - Programming language (javascript, python, go, rust, bash)

**Returns**: Language-specific documentation standards

**Example**:
```bash
conventions=$(get_language_documentation_conventions "javascript")
# Returns: JSDoc comments, TypeScript type annotations, README structure, etc.
```

---

#### `get_language_testing_patterns(language)`
Get testing best practices for a specific language.

**Parameters**:
- `$1` - `language` - Programming language

**Returns**: Language-specific testing patterns

**Example**:
```bash
patterns=$(get_language_testing_patterns "python")
# Returns: pytest fixtures, mock patterns, coverage standards, etc.
```

---

#### `get_language_quality_standards(language)`
Get code quality standards for a specific language.

**Parameters**:
- `$1` - `language` - Programming language

**Returns**: Language-specific quality standards

**Example**:
```bash
standards=$(get_language_quality_standards "go")
# Returns: go fmt, golint rules, error handling patterns, etc.
```

---

### Project-Kind Aware Prompts (v2.6+)

#### `should_use_project_kind_prompts()`
Check if project-kind aware prompts should be used.

**Returns**:
- `0` - Use project-kind prompts (project.kind is configured)
- `1` - Use generic prompts

**Example**:
```bash
if should_use_project_kind_prompts; then
    prompt=$(build_project_kind_doc_prompt "$changes" "$docs")
fi
```

---

#### `get_project_kind_prompt(project_kind, persona, field)`
Extract project-kind specific prompt field.

**Parameters**:
- `$1` - `project_kind` - Project type (nodejs_api, shell_automation, etc.)
- `$2` - `persona` - AI persona (documentation_specialist, code_reviewer, test_engineer, ux_designer)
- `$3` - `field` - Field to extract (role, task_context, approach)

**Returns**: Prompt field content

**Example**:
```bash
role=$(get_project_kind_prompt "nodejs_api" "documentation_specialist" "role")
task=$(get_project_kind_prompt "nodejs_api" "test_engineer" "task_context")
approach=$(get_project_kind_prompt "python_library" "code_reviewer" "approach")
```

---

#### `build_project_kind_doc_prompt(changed_files, doc_files)`
Build project-kind aware documentation prompt.

**Parameters**:
- `$1` - `changed_files` - Changed files list
- `$2` - `doc_files` - Documentation files

**Returns**: Project-kind specialized documentation prompt

**Example**:
```bash
# For a Node.js API project
prompt=$(build_project_kind_doc_prompt "src/api/*.js" "README.md docs/API.md")
# Returns prompt with OpenAPI, Express, REST API conventions
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `AI_CACHE_ENABLED` | `true` | Enable AI response caching |
| `AI_CACHE_TTL` | `86400` | Cache lifetime in seconds (24 hours) |
| `PROJECT_ROOT` | Current dir | Project root directory |
| `TARGET_DIR` | `PROJECT_ROOT` | Target project directory |
| `PRIMARY_LANGUAGE` | Auto-detect | Primary programming language |

### Configuration Files

#### `.workflow_core/config/ai_helpers.yaml`
Main AI configuration with prompt templates and personas.

**Structure**:
```yaml
behavioral_guidelines: &documentation_behavioral_guidelines |
  Analyze systematically, prioritize high-impact issues...

doc_analysis_prompt:
  role_prefix: "You are a senior technical writer"
  behavioral_guidelines: *documentation_behavioral_guidelines
  task_template: |
    Update documentation based on changes...
  approach: |
    1. Review changed files
    2. Check documentation accuracy
    ...
```

#### `.workflow_core/config/ai_prompts_project_kinds.yaml`
Project-specific AI personas for different project types.

**Supported Project Kinds**:
- `shell_automation` - Shell script projects
- `nodejs_api` - Node.js API servers
- `nodejs_cli` - Node.js CLI tools
- `nodejs_library` - Node.js libraries
- `python_api` - Python API servers
- `python_library` - Python libraries
- `static_website` - Static websites
- `client_spa` - Single-page applications
- `react_spa` - React applications
- `vue_spa` - Vue applications

## Usage Patterns

### Basic AI Execution
```bash
# Source the module
source "$(dirname "$0")/lib/ai_helpers.sh"

# Validate Copilot
if ! validate_copilot_cli; then
    exit 1
fi

# Build and execute prompt
prompt=$(build_doc_analysis_prompt "$changed_files" "$docs")
trigger_ai_step "Documentation Analysis" "$prompt" "output.md"
```

### Project-Aware Execution
```bash
# Enable project detection
source "$(dirname "$0")/lib/project_kind_detection.sh"
source "$(dirname "$0")/lib/ai_helpers.sh"

# Check project kind
if should_use_project_kind_prompts; then
    prompt=$(build_project_kind_doc_prompt "$changes" "$docs")
else
    prompt=$(build_doc_analysis_prompt "$changes" "$docs")
fi

execute_copilot_prompt "$prompt" "output.md"
```

### Batch AI Processing
```bash
# Prepare multiple prompts
declare -a prompts=(
    "step1|$(build_doc_analysis_prompt "$changes" "$docs")"
    "step3|$(build_consistency_prompt "$docs" "$tech_stack")"
    "step5|$(build_test_strategy_prompt "$code_changes" "$tests")"
)

# Execute in batch
execute_copilot_batch prompts "output_dir/"
```

### Caching Control
```bash
# Global cache disable
export AI_CACHE_ENABLED=false

# Per-call cache control
execute_copilot_prompt "$prompt" "output.md" "false"  # No cache
execute_copilot_prompt "$prompt" "output.md" "true"   # Use cache
```

## Error Handling

### Error Codes
- `0` - Success
- `1` - General error
- `2` - Copilot CLI not available
- `3` - Invalid input/configuration
- `4` - AI execution failed
- `5` - Cache error (non-fatal, falls back to direct execution)

### Error Recovery
```bash
# Validate before execution
if ! validate_copilot_cli; then
    print_error "Copilot CLI not available"
    print_info "Install: npm install -g @githubnext/github-copilot-cli"
    return 2
fi

# Handle execution errors
if ! execute_copilot_prompt "$prompt" "$output"; then
    print_error "AI execution failed"
    # Check logs in logs/ai_execution.log
    return 4
fi

# Cache errors are non-fatal
# System automatically falls back to direct execution
```

## Testing

### Unit Tests
```bash
# Run ai_helpers tests
cd src/workflow/lib
./test_ai_helpers.sh

# Test specific functions
test_is_copilot_available
test_build_doc_analysis_prompt
test_execute_copilot_prompt
```

### Integration Tests
```bash
# Test full workflow
cd src/workflow
./test_step1_integration.sh

# Test with real Copilot
export COPILOT_INTEGRATION_TEST=true
./test_ai_execution.sh
```

## Performance

### Metrics
- **Cache Hit Rate**: 60-80% (after first run)
- **Token Reduction**: 60-80% with caching
- **Prompt Construction**: < 100ms per prompt
- **AI Execution**: 2-10 seconds per prompt (depends on complexity)

### Optimization Tips
1. **Enable Caching**: Keep `AI_CACHE_ENABLED=true` (default)
2. **Batch Requests**: Use `execute_copilot_batch` for multiple prompts
3. **Project Configuration**: Set `project.kind` and `PRIMARY_LANGUAGE` for optimized prompts
4. **Reuse Prompts**: Identical prompts benefit from caching

## Related Modules

- **[ai_cache.sh](../supporting/ai_cache.md)** - AI response caching implementation
- **[ai_prompt_builder.sh](../supporting/ai_prompt_builder.md)** - Advanced prompt construction
- **[ai_personas.sh](../supporting/ai_personas.md)** - Persona management
- **[project_kind_detection.sh](../supporting/project_kind_detection.md)** - Project type detection
- **[tech_stack.sh](tech_stack.md)** - Technology detection

## Changelog

- **v3.1.0** (2026-01-30): Added technical_writer persona for bootstrap documentation
- **v3.0.0** (2026-01-28): Enhanced project kind detection, improved caching
- **v2.7.0** (2025-12-25): Added ML optimization support
- **v2.6.0** (2025-12-24): Added project-kind aware prompts
- **v2.4.0** (2025-12-23): Added UX designer persona
- **v2.3.0** (2025-12-23): Added AI response caching
- **v2.2.0** (2025-12-21): Added language-aware prompts
- **v2.0.0** (2025-12-18): Initial modular release

## See Also

- [AI Integration Architecture](../../architecture/AI_INTEGRATION.md)
- [Persona Development Guide](../../developer-guide/AI_PERSONAS.md)
- [Prompt Engineering Best Practices](../../reference/PROMPT_ENGINEERING.md)
- [Step 0b: Bootstrap Documentation](../../reference/API_STEP_MODULES.md#step-0b-bootstrap-documentation)
