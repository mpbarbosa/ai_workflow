# Configuration Reference Guide

**Version**: v3.2.7  
**Last Updated**: 2026-02-08  
**Audience**: Users and developers configuring the workflow system

## Table of Contents

1. [Overview](#overview)
2. [Configuration Files](#configuration-files)
3. [Project Configuration](#project-configuration)
4. [Tech Stack Configuration](#tech-stack-configuration)
5. [AI Configuration](#ai-configuration)
6. [Workflow Options](#workflow-options)
7. [Environment Variables](#environment-variables)
8. [Configuration Wizard](#configuration-wizard)
9. [Examples](#examples)
10. [Troubleshooting](#troubleshooting)

---

## Overview

The AI Workflow Automation system uses YAML configuration files to customize behavior for different projects and environments.

### Configuration Hierarchy

1. **Global Config**: `.workflow_core/config/` - Shared configuration (submodule)
2. **Project Config**: `.workflow-config.yaml` - Project-specific settings
3. **Environment Variables**: Runtime overrides
4. **Command-Line Options**: Execution-time overrides

**Precedence**: Command-line > Environment Variables > Project Config > Global Config

---

## Configuration Files

### Primary Configuration File: `.workflow-config.yaml`

Located in your project root, this file defines project-specific settings.

**Generate with**:
```bash
./src/workflow/execute_tests_docs_workflow.sh --init-config
```

### Global Configuration Files

Located in `.workflow_core/config/` (submodule):

| File | Purpose |
|------|---------|
| `ai_helpers.yaml` | AI prompt templates and personas (762 lines) |
| `ai_prompts_project_kinds.yaml` | Project-specific AI prompts |
| `project_kinds.yaml` | Project type definitions |
| `model_selection_rules.yaml` | AI model selection criteria |
| `paths.yaml` | Path configuration |

---

## Project Configuration

### Basic Project Information

```yaml
project:
  name: "Your Project Name"
  type: "project-type"          # Human-readable type description
  description: "Project description"
  kind: "shell_automation"       # Standardized project kind
  version: "1.0.0"               # Project version
```

#### Supported Project Kinds

| Kind | Description | Typical Use |
|------|-------------|-------------|
| `shell_automation` | Shell script automation | Bash frameworks, CLI tools |
| `nodejs_api` | Node.js API server | REST APIs, GraphQL |
| `nodejs_cli` | Node.js CLI tool | Command-line utilities |
| `nodejs_library` | Node.js library | NPM packages |
| `static_website` | Static HTML/CSS/JS | Landing pages, portfolios |
| `client_spa` | Client-side SPA | React, Vue, Angular apps |
| `react_spa` | React application | React-specific projects |
| `vue_spa` | Vue application | Vue-specific projects |
| `python_api` | Python API server | FastAPI, Flask, Django |
| `python_cli` | Python CLI tool | argparse, click applications |
| `python_library` | Python library | PyPI packages |
| `documentation` | Documentation project | Technical docs, wikis |

**Auto-Detection**: If `kind` is not specified, it will be detected from project structure.

### Project Structure

```yaml
structure:
  source_dirs:          # Source code directories
    - src
    - lib
  test_dirs:            # Test directories
    - tests
    - test
    - __tests__
  docs_dirs:            # Documentation directories
    - docs
    - documentation
  exclude_patterns:     # Files/directories to exclude
    - "node_modules/**"
    - "vendor/**"
    - ".git/**"
    - "*.min.js"
```

**Best Practices**:
- List directories in order of importance
- Use glob patterns for exclusions
- Include build output directories in exclusions

---

## Tech Stack Configuration

### Primary Language

```yaml
tech_stack:
  primary_language: "bash"    # bash, javascript, typescript, python, etc.
```

**Impact**:
- Enables language-specific AI prompts
- Affects linting and testing strategies
- Influences documentation standards

**Supported Languages**: bash, javascript, typescript, python, ruby, go, rust, java, c, cpp, php, and more.

### Build System

```yaml
tech_stack:
  build_system: "none"        # none, npm, webpack, maven, gradle, etc.
```

**Options**:
- `none` - No build system
- `npm` - Node.js with npm
- `yarn` - Node.js with Yarn
- `webpack` - Webpack bundler
- `rollup` - Rollup bundler
- `maven` - Java Maven
- `gradle` - Java/Kotlin Gradle
- `cargo` - Rust Cargo
- `go` - Go build

### Test Framework

```yaml
tech_stack:
  test_framework: "shell-script"    # Test framework identifier
  test_command: "./tests/run_all_tests.sh"
  test_patterns:                    # Test file patterns
    - "test_*.sh"
    - "*_test.sh"
```

**Common Test Frameworks**:

| Language | Framework | test_command Example |
|----------|-----------|---------------------|
| Bash | shell-script | `./tests/run_all_tests.sh` |
| JavaScript | jest | `npm test` |
| JavaScript | mocha | `npm run test:mocha` |
| TypeScript | jest | `npm test` |
| Python | pytest | `pytest tests/` |
| Python | unittest | `python -m unittest discover` |
| Ruby | rspec | `bundle exec rspec` |
| Go | go test | `go test ./...` |

### Linting Configuration

```yaml
tech_stack:
  lint_command: "shellcheck src/**/*.sh"
  linter: "shellcheck"              # Optional: specific linter
```

**Common Linters**:

| Language | Linter | lint_command Example |
|----------|--------|---------------------|
| Bash | shellcheck | `shellcheck src/**/*.sh` |
| JavaScript | eslint | `npm run lint` |
| TypeScript | tslint/eslint | `npm run lint` |
| Python | pylint | `pylint src/` |
| Python | flake8 | `flake8 src/` |
| Ruby | rubocop | `rubocop` |

### Documentation Tools

```yaml
tech_stack:
  documentation_tool: "markdown"    # markdown, jsdoc, sphinx, etc.
  api_doc_command: "npm run docs"   # Generate API docs
```

---

## AI Configuration

### AI Persona Configuration

AI personas are defined in `.workflow_core/config/ai_helpers.yaml`.

**Structure**:
```yaml
ai_helpers:
  personas:
    documentation_specialist:
      role: "Senior technical writer and documentation architect"
      capabilities:
        - "Analyze documentation quality and completeness"
        - "Identify gaps and inconsistencies"
        - "Provide actionable improvement suggestions"
      task_template: |
        ## Task
        {task_description}
        
        ## Project Context
        - Project: {project_name}
        - Language: {primary_language}
        - Type: {project_kind}
      standards:
        - "Documentation must be accurate and up-to-date"
        - "All public APIs must be documented"
        - "Examples must be provided for complex features"
```

### Project-Specific AI Prompts

Customize AI behavior per project type in `ai_prompts_project_kinds.yaml`:

```yaml
shell_script_automation:
  documentation_specialist:
    additional_context: |
      For shell scripts, focus on:
      - Usage examples with actual commands
      - Exit codes and error handling
      - Required dependencies
      - POSIX compatibility notes
    
    quality_standards:
      - "Include shellcheck directives where needed"
      - "Document all environment variables"
      - "Provide installation instructions"
```

### AI Model Selection

Configure model selection rules in `model_selection_rules.yaml`:

```yaml
model_selection:
  rules:
    - condition: "file_size > 1MB"
      model: "claude-opus-4"
      reason: "Large file analysis requires extended context"
    
    - condition: "task_type == 'code_review'"
      model: "gpt-5.1-codex"
      reason: "Optimized for code analysis"
    
    - condition: "step_number in [1, 2, 5]"
      model: "claude-sonnet-4.5"
      reason: "Documentation steps use Sonnet"
  
  default_model: "claude-sonnet-4.5"
```

### AI Cache Configuration

```yaml
ai_cache:
  enabled: true                   # Enable response caching
  ttl_hours: 24                  # Time-to-live in hours
  max_size_mb: 500               # Maximum cache size
  cleanup_interval_hours: 24     # Cleanup frequency
```

**Environment Variable Override**:
```bash
export AI_CACHE_ENABLED=false    # Disable caching
export AI_CACHE_TTL=48           # 48-hour TTL
```

---

## Workflow Options

### Execution Modes

```yaml
workflow:
  execution:
    smart_execution: true         # Skip unchanged steps
    parallel_execution: true      # Run independent steps in parallel
    ml_optimization: false        # Use ML predictions (requires 10+ runs)
    multi_stage: false           # Use progressive validation
  
  checkpoints:
    enabled: true                 # Enable checkpoint resume
    auto_cleanup: true           # Clean old checkpoints
  
  metrics:
    enabled: true                # Track performance metrics
    detailed: false              # Collect detailed metrics
```

### Step Configuration

```yaml
workflow:
  steps:
    enabled:                     # Steps to run
      - 0
      - 2
      - 3
      - 5
      - 6
      - 7
    
    skip:                        # Steps to always skip
      - 10                       # Skip UX analysis
    
    continue_on_failure:         # Continue if these steps fail
      - 7
```

### Auto-Commit Configuration

```yaml
workflow:
  auto_commit:
    enabled: false               # Enable auto-commit
    commit_docs: true           # Commit documentation changes
    commit_tests: true          # Commit test changes
    commit_source: false        # Commit source code changes
    message_prefix: "[auto]"    # Commit message prefix
```

### Pre-Commit Hooks

```yaml
hooks:
  enabled: true                  # Enable pre-commit hooks
  fast_validation: true          # Quick validation only
  checks:
    - syntax                     # Check syntax errors
    - shellcheck                # Run shellcheck
    - documentation             # Verify docs updated
```

### Audio Notifications

```yaml
audio:
  enabled: true                              # Enable audio notifications
  continue_prompt_sound: /path/to/beep.mp3  # Sound for continue prompts
  completion_sound: /path/to/done.mp3       # Sound for completion
```

---

## Environment Variables

### Core Variables

| Variable | Purpose | Default | Example |
|----------|---------|---------|---------|
| `PROJECT_ROOT` | Project root directory | Current directory | `/home/user/project` |
| `TARGET_DIR` | Target project directory | `$PROJECT_ROOT` | `/path/to/target` |
| `WORKFLOW_DIR` | Workflow installation directory | Auto-detected | `/opt/ai_workflow` |

### AI Configuration

| Variable | Purpose | Default | Example |
|----------|---------|---------|---------|
| `AI_CACHE_ENABLED` | Enable AI caching | `true` | `false` |
| `AI_CACHE_TTL` | Cache TTL in hours | `24` | `48` |
| `COPILOT_MODEL` | Override AI model | Auto | `claude-opus-4` |

### Execution Control

| Variable | Purpose | Default | Example |
|----------|---------|---------|---------|
| `SMART_EXECUTION` | Enable smart execution | `false` | `true` |
| `PARALLEL_EXECUTION` | Enable parallel execution | `false` | `true` |
| `DRY_RUN` | Preview without changes | `false` | `true` |
| `NO_RESUME` | Disable checkpoint resume | `false` | `true` |
| `VERBOSE` | Verbose output | `false` | `true` |

### GitHub Copilot

| Variable | Purpose | Default | Example |
|----------|---------|---------|---------|
| `COPILOT_GITHUB_TOKEN` | GitHub token for Copilot | - | `ghp_xxx` |
| `GH_TOKEN` | Alternate token variable | - | `ghp_xxx` |
| `GITHUB_TOKEN` | Alternate token variable | - | `ghp_xxx` |

### Testing

| Variable | Purpose | Default | Example |
|----------|---------|---------|---------|
| `TEST_MODE` | Enable test mode | `false` | `true` |
| `TEST_OUTPUT_DIR` | Test output directory | `/tmp/test` | `/tmp/custom` |

---

## Configuration Wizard

### Interactive Setup

Generate configuration interactively:

```bash
./src/workflow/execute_tests_docs_workflow.sh --init-config
```

**Wizard Steps**:
1. Project name and description
2. Primary programming language
3. Test framework and command
4. Build system (if applicable)
5. Documentation tools
6. Project structure

**Output**: Creates `.workflow-config.yaml` with detected settings.

### Updating Configuration

```bash
# Re-run wizard to update configuration
./src/workflow/execute_tests_docs_workflow.sh --init-config

# View current configuration
./src/workflow/execute_tests_docs_workflow.sh --show-tech-stack
```

---

## Examples

### Example 1: Node.js API Project

```yaml
project:
  name: "My API Server"
  type: "nodejs-api-server"
  description: "REST API built with Express.js"
  kind: "nodejs_api"
  version: "2.1.0"

tech_stack:
  primary_language: "javascript"
  build_system: "npm"
  test_framework: "jest"
  test_command: "npm test"
  lint_command: "npm run lint"
  documentation_tool: "jsdoc"

structure:
  source_dirs:
    - src
    - lib
  test_dirs:
    - tests
    - __tests__
  docs_dirs:
    - docs
  exclude_patterns:
    - "node_modules/**"
    - "coverage/**"
    - "dist/**"

workflow:
  execution:
    smart_execution: true
    parallel_execution: true
  auto_commit:
    enabled: true
    commit_docs: true
    commit_tests: true
```

### Example 2: Python CLI Tool

```yaml
project:
  name: "Data Processing Tool"
  type: "python-cli"
  description: "Command-line tool for data processing"
  kind: "python_cli"
  version: "1.5.2"

tech_stack:
  primary_language: "python"
  build_system: "pip"
  test_framework: "pytest"
  test_command: "pytest tests/ -v"
  lint_command: "flake8 src/ && pylint src/"
  documentation_tool: "sphinx"
  api_doc_command: "sphinx-build -b html docs/source docs/build"

structure:
  source_dirs:
    - src
  test_dirs:
    - tests
  docs_dirs:
    - docs
  exclude_patterns:
    - "venv/**"
    - "*.pyc"
    - "__pycache__/**"
    - ".pytest_cache/**"

workflow:
  execution:
    smart_execution: true
    parallel_execution: false
    ml_optimization: true
  steps:
    skip:
      - 10  # No UX analysis for CLI
```

### Example 3: React SPA

```yaml
project:
  name: "Web Application"
  type: "react-spa"
  description: "Single-page application built with React"
  kind: "react_spa"
  version: "3.0.0"

tech_stack:
  primary_language: "typescript"
  build_system: "webpack"
  test_framework: "jest"
  test_command: "npm run test:ci"
  lint_command: "npm run lint && npm run type-check"
  documentation_tool: "typedoc"

structure:
  source_dirs:
    - src
  test_dirs:
    - src/__tests__
    - tests
  docs_dirs:
    - docs
  exclude_patterns:
    - "node_modules/**"
    - "build/**"
    - "dist/**"
    - "coverage/**"

workflow:
  execution:
    smart_execution: true
    parallel_execution: true
    multi_stage: true
  steps:
    enabled:
      - 0
      - 2
      - 3
      - 5
      - 6
      - 7
      - 10  # Include UX analysis

audio:
  enabled: true
  continue_prompt_sound: /usr/share/sounds/beep.mp3
  completion_sound: /usr/share/sounds/complete.mp3
```

### Example 4: Shell Script Framework

```yaml
project:
  name: "Shell Script Framework"
  type: "bash-framework"
  description: "Modular framework for shell script automation"
  kind: "shell_automation"
  version: "2.3.1"

tech_stack:
  primary_language: "bash"
  build_system: "none"
  test_framework: "shell-script"
  test_command: "./tests/run_all_tests.sh"
  lint_command: "shellcheck src/**/*.sh lib/**/*.sh"

structure:
  source_dirs:
    - src
    - lib
  test_dirs:
    - tests
  docs_dirs:
    - docs
  exclude_patterns:
    - ".git/**"
    - "backlog/**"
    - "logs/**"

workflow:
  execution:
    smart_execution: true
    parallel_execution: true
  checkpoints:
    enabled: true
    auto_cleanup: true
  auto_commit:
    enabled: false
```

---

## Troubleshooting

### Configuration Not Loaded

**Problem**: Workflow doesn't use `.workflow-config.yaml` settings.

**Solutions**:
1. Verify file location: Must be in project root
2. Check YAML syntax: Use `yamllint .workflow-config.yaml`
3. Check permissions: Must be readable
4. Enable verbose mode: `VERBOSE=1 ./execute_tests_docs_workflow.sh`

### Auto-Detection Issues

**Problem**: Project kind incorrectly detected.

**Solutions**:
1. Explicitly set `project.kind` in configuration
2. Run configuration wizard: `--init-config`
3. Check for conflicting indicators (e.g., both `package.json` and `setup.py`)

### Test Command Fails

**Problem**: `test_command` doesn't work.

**Solutions**:
1. Test command independently: Run it directly
2. Check working directory: Should run from project root
3. Verify dependencies: Ensure test framework installed
4. Check paths: Use absolute paths if relative paths fail

### AI Personas Not Working

**Problem**: AI responses don't match expected persona.

**Solutions**:
1. Check Copilot authentication: `gh auth status`
2. Verify persona exists: Check `ai_helpers.yaml`
3. Clear AI cache: `rm -rf .ai_cache/`
4. Enable verbose mode to see prompts: `VERBOSE=1`

### Performance Issues

**Problem**: Workflow runs slowly.

**Solutions**:
1. Enable smart execution: `--smart-execution`
2. Enable parallel execution: `--parallel`
3. Reduce scope: Use `--steps` to run specific steps
4. Enable ML optimization: `--ml-optimize` (after 10+ runs)
5. Check exclusions: Ensure large directories excluded

---

## Best Practices

### Configuration Management

1. **Version Control**: Commit `.workflow-config.yaml` to Git
2. **Environment-Specific**: Use environment variables for secrets
3. **Documentation**: Comment complex configuration options
4. **Validation**: Test configuration changes on a branch first
5. **Defaults**: Rely on sensible defaults when possible

### Project Structure

1. **Consistency**: Follow language/framework conventions
2. **Separation**: Keep source, tests, and docs separate
3. **Exclusions**: Exclude generated files and dependencies
4. **Organization**: Group related files in subdirectories

### Performance Tuning

1. **Smart Execution**: Always enable for iterative development
2. **Parallel Execution**: Enable for independent steps
3. **ML Optimization**: Enable after collecting 10+ workflow runs
4. **Multi-Stage**: Use for large projects with frequent changes
5. **Caching**: Keep AI cache enabled unless debugging

### Security

1. **No Secrets**: Never commit tokens or passwords
2. **Environment Variables**: Use for sensitive data
3. **Permissions**: Restrict access to configuration files
4. **Validation**: Sanitize user inputs in custom scripts

---

## Related Documentation

- [Project Reference](../PROJECT_REFERENCE.md) - Complete feature and module inventory
- [Extending the Workflow](./EXTENDING_THE_WORKFLOW.md) - Developer guide for customization
- [API Reference](../api/COMPLETE_API_REFERENCE.md) - Complete API documentation
- [Getting Started](../GETTING_STARTED.md) - Quick start guide
- [Architecture Overview](../architecture/SYSTEM_ARCHITECTURE.md) - System design

---

## Configuration Schema Reference

### Complete Schema

```yaml
# Project identification
project:
  name: string                    # Required: Project name
  type: string                    # Required: Human-readable type
  description: string             # Required: Project description
  kind: string                    # Optional: Standardized kind (auto-detected)
  version: string                 # Required: Semantic version

# Technology stack
tech_stack:
  primary_language: string        # Required: Main programming language
  build_system: string            # Optional: Build system (none, npm, maven, etc.)
  test_framework: string          # Required: Test framework identifier
  test_command: string            # Required: Command to run tests
  test_patterns: array<string>    # Optional: Test file patterns
  lint_command: string            # Optional: Linting command
  linter: string                  # Optional: Specific linter
  documentation_tool: string      # Optional: Documentation generator
  api_doc_command: string         # Optional: API doc generation command

# Project structure
structure:
  source_dirs: array<string>      # Required: Source code directories
  test_dirs: array<string>        # Required: Test directories
  docs_dirs: array<string>        # Required: Documentation directories
  exclude_patterns: array<string> # Optional: Exclusion patterns

# Workflow configuration
workflow:
  execution:
    smart_execution: boolean      # Optional: Enable smart execution (default: false)
    parallel_execution: boolean   # Optional: Enable parallel execution (default: false)
    ml_optimization: boolean      # Optional: Enable ML optimization (default: false)
    multi_stage: boolean          # Optional: Use multi-stage pipeline (default: false)
  
  checkpoints:
    enabled: boolean              # Optional: Enable checkpoints (default: true)
    auto_cleanup: boolean         # Optional: Auto-clean old checkpoints (default: true)
  
  metrics:
    enabled: boolean              # Optional: Track metrics (default: true)
    detailed: boolean             # Optional: Detailed metrics (default: false)
  
  steps:
    enabled: array<integer>       # Optional: Steps to run (default: all)
    skip: array<integer>          # Optional: Steps to skip (default: none)
    continue_on_failure: array<integer>  # Optional: Continue on failure
  
  auto_commit:
    enabled: boolean              # Optional: Auto-commit (default: false)
    commit_docs: boolean          # Optional: Commit docs (default: true)
    commit_tests: boolean         # Optional: Commit tests (default: true)
    commit_source: boolean        # Optional: Commit source (default: false)
    message_prefix: string        # Optional: Commit message prefix

# Pre-commit hooks
hooks:
  enabled: boolean                # Optional: Enable hooks (default: false)
  fast_validation: boolean        # Optional: Fast validation (default: true)
  checks: array<string>           # Optional: Checks to run

# AI cache configuration
ai_cache:
  enabled: boolean                # Optional: Enable caching (default: true)
  ttl_hours: integer              # Optional: TTL in hours (default: 24)
  max_size_mb: integer            # Optional: Max size MB (default: 500)
  cleanup_interval_hours: integer # Optional: Cleanup interval (default: 24)

# Audio notifications
audio:
  enabled: boolean                # Optional: Enable audio (default: false)
  continue_prompt_sound: string   # Optional: Continue prompt sound file
  completion_sound: string        # Optional: Completion sound file
```

**Note**: All optional fields have sensible defaults and can be omitted.
