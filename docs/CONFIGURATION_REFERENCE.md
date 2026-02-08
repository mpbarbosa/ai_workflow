# Configuration Reference

## Overview

AI Workflow Automation uses a hierarchical configuration system with multiple sources and sensible defaults. This guide covers all configuration options, precedence rules, and examples.

## Configuration Sources

Configuration is loaded from multiple sources in order of precedence (highest to lowest):

1. **Command-line arguments** - Override all other settings
2. **Project configuration file** - `.workflow-config.yaml` in project root
3. **Environment variables** - `WORKFLOW_*` prefixed variables
4. **Global configuration** - `~/.workflow/config.yaml`
5. **Default configuration** - Built-in defaults

## Project Configuration File

### Location

Create `.workflow-config.yaml` in your project root:

```bash
cd /path/to/your/project
touch .workflow-config.yaml
```

### Complete Configuration Schema

```yaml
# Project Metadata
project:
  name: "My Project"                # Project display name
  version: "1.0.0"                   # Current version (auto-updated)
  kind: "nodejs_api"                 # Project type (see Project Kinds below)
  description: "Brief description"   # Optional project description
  repository: "https://github.com/user/repo"  # Optional repository URL

# Technology Stack Configuration
tech_stack:
  primary_language: "javascript"     # Primary programming language
  secondary_languages:               # Optional additional languages
    - "typescript"
    - "bash"
  build_system: "npm"                # Build tool (npm, maven, gradle, cargo, etc.)
  test_framework: "jest"             # Testing framework
  linter: "eslint"                   # Code linter
  formatter: "prettier"              # Code formatter
  package_manager: "npm"             # Package manager (npm, yarn, pnpm, pip, etc.)
  runtime_version: "25.2.1"          # Runtime version

# Project Structure
structure:
  source_dirs:                       # Source code directories
    - "src"
    - "lib"
  test_dirs:                         # Test directories
    - "tests"
    - "__tests__"
    - "test"
  config_files:                      # Configuration file patterns
    - "*.json"
    - "*.yaml"
    - "*.yml"
  docs_dirs:                         # Documentation directories
    - "docs"
    - "documentation"
  exclude_patterns:                  # Files/dirs to exclude
    - "node_modules"
    - "dist"
    - "build"
    - ".git"
    - "coverage"

# Testing Configuration
testing:
  test_command: "npm test"           # Command to run tests
  coverage_command: "npm run test:coverage"  # Coverage command
  coverage_threshold: 80             # Minimum coverage percentage
  test_pattern: "**/*.test.js"       # Test file pattern
  test_timeout: 30000                # Test timeout in milliseconds
  parallel_tests: true               # Run tests in parallel
  watch_mode: false                  # Enable watch mode

# Workflow Behavior
workflow:
  smart_execution: true              # Enable smart step skipping
  parallel_steps: true               # Enable parallel execution
  cache_ai_responses: true           # Enable AI response caching
  resume_on_failure: true            # Resume from checkpoint on failure
  auto_commit: false                 # Auto-commit workflow artifacts
  ml_optimize: false                 # Enable ML optimization
  multi_stage: false                 # Enable multi-stage pipeline
  interactive_mode: true             # Require user confirmation
  verbose: false                     # Enable verbose logging

# Step Configuration
steps:
  enabled:                           # Steps to enable (default: all)
    - "pre_analysis"
    - "documentation_updates"
    - "consistency_analysis"
    - "script_reference_validation"
    - "config_validation"
    - "directory_validation"
    - "test_review"
    - "test_generation"
    - "test_execution"
    - "dependency_validation"
    - "code_quality_validation"
    - "context_analysis"
    - "git_finalization"
    - "markdown_linting"
    - "prompt_engineer_analysis"
    - "version_update"
  
  disabled:                          # Steps to disable
    - "ux_analysis"                  # Example: disable UX analysis
  
  custom_order:                      # Override default step order
    # Leave empty to use default order

# AI Configuration
ai:
  provider: "github_copilot"         # AI provider (github_copilot, openai, etc.)
  model: "gpt-4"                     # Model to use
  temperature: 0.7                   # Response randomness (0.0-1.0)
  max_tokens: 4096                   # Maximum response length
  cache_ttl: 86400                   # Cache TTL in seconds (24 hours)
  personas:                          # Custom persona overrides
    documentation_specialist:
      temperature: 0.5
      max_tokens: 2048
  
# Git Configuration
git:
  auto_commit: false                 # Auto-commit changes
  commit_message_template: "chore: workflow artifacts from {date}"
  branch_protection: true            # Prevent commits to main/master
  require_clean_tree: true           # Require clean working tree
  create_backup: true                # Create backup before changes

# Metrics and Reporting
metrics:
  enabled: true                      # Enable metrics collection
  dashboard: false                   # Show metrics dashboard
  export_format: "json"              # Metrics export format (json, csv)
  history_retention: 90              # Days to retain metrics history

# Paths Configuration (Advanced)
paths:
  workflow_root: ".workflow"         # Workflow data directory
  logs_dir: "logs"                   # Logs subdirectory
  backlog_dir: "backlog"             # Backlog subdirectory
  metrics_dir: "metrics"             # Metrics subdirectory
  cache_dir: ".ai_cache"             # AI cache directory
  summaries_dir: "summaries"         # Summaries directory

# Pre-Commit Hooks
hooks:
  enabled: true                      # Enable pre-commit hooks
  fast_fail: true                    # Stop on first failure
  checks:
    - "syntax"                       # Bash syntax check
    - "shellcheck"                   # ShellCheck linting
    - "trailing_whitespace"          # Check trailing whitespace
    - "file_permissions"             # Check file permissions
```

## Project Kinds

The `project.kind` setting determines validation rules, testing strategies, and documentation requirements.

### Supported Project Kinds

| Kind | Description | Primary Languages | Test Frameworks |
|------|-------------|-------------------|-----------------|
| `shell_automation` | Shell script automation | Bash, Shell | bash_unit, bats |
| `nodejs_api` | Node.js REST API | JavaScript, TypeScript | Jest, Mocha, Vitest |
| `nodejs_cli` | Node.js CLI tool | JavaScript, TypeScript | Jest, Mocha |
| `nodejs_library` | Node.js library/package | JavaScript, TypeScript | Jest, Vitest |
| `static_website` | Static HTML/CSS/JS site | HTML, CSS, JavaScript | Cypress, Playwright |
| `client_spa` | Client-side SPA | JavaScript, TypeScript | Jest, Vitest, Playwright |
| `react_spa` | React application | JavaScript, TypeScript, JSX | Jest, React Testing Library |
| `vue_spa` | Vue.js application | JavaScript, TypeScript | Vitest, Vue Test Utils |
| `python_api` | Python REST API | Python | pytest, unittest |
| `python_cli` | Python CLI tool | Python | pytest, unittest |
| `python_library` | Python library/package | Python | pytest, unittest |
| `documentation` | Documentation-only project | Markdown | markdownlint |

### Project Kind Auto-Detection

If `project.kind` is not specified, the workflow automatically detects it using:

```bash
# View detected project kind
./execute_tests_docs_workflow.sh --show-tech-stack
```

Detection looks for:
- `package.json` → Node.js projects
- `setup.py` / `pyproject.toml` → Python projects
- `Cargo.toml` → Rust projects
- `go.mod` → Go projects
- Majority `.sh` files → Shell automation
- React dependencies → React SPA
- Vue dependencies → Vue SPA

## Primary Language Configuration

### Supported Languages

| Language | Detection | Test Frameworks | Build Systems |
|----------|-----------|-----------------|---------------|
| `javascript` | `package.json`, `.js` files | Jest, Mocha, Vitest | npm, yarn, pnpm |
| `typescript` | `tsconfig.json`, `.ts` files | Jest, Vitest | npm, yarn, pnpm |
| `python` | `setup.py`, `.py` files | pytest, unittest | pip, poetry, pipenv |
| `bash` | `.sh` files | bash_unit, bats | N/A |
| `go` | `go.mod`, `.go` files | go test | go |
| `rust` | `Cargo.toml`, `.rs` files | cargo test | cargo |
| `java` | `pom.xml`, `.java` files | JUnit, TestNG | maven, gradle |
| `ruby` | `Gemfile`, `.rb` files | RSpec, Minitest | bundle |
| `cpp` | `CMakeLists.txt`, `.cpp` files | gtest, catch2 | cmake, make |

### Language-Aware Enhancements

When `tech_stack.primary_language` is set, AI prompts are automatically enhanced with:
- Language-specific documentation standards
- Testing best practices
- Code quality rules
- Naming conventions

This happens silently in Steps 2 and 5.

## Command-Line Options

All configuration can be overridden via command-line:

### Basic Options

```bash
# Run specific steps (by name or number)
--steps documentation_updates,test_execution
--steps 0,5,6,7

# Target project
--target /path/to/project

# Configuration file
--config-file .my-config.yaml
```

### Optimization Options

```bash
--smart-execution      # Enable smart step skipping
--parallel             # Enable parallel execution
--ml-optimize          # Enable ML optimization
--multi-stage          # Enable multi-stage pipeline
```

### Execution Options

```bash
--auto                 # Auto-approve all prompts
--dry-run              # Preview without execution
--verbose              # Enable verbose logging
--no-resume            # Disable checkpoint resume
--auto-commit          # Auto-commit artifacts
```

### AI Options

```bash
--no-ai-cache          # Disable AI response caching
--generate-docs        # Auto-generate documentation
--update-changelog     # Update CHANGELOG.md
--generate-api-docs    # Generate API documentation
```

### Hook Options

```bash
--install-hooks        # Install pre-commit hooks
--test-hooks           # Test hooks without committing
```

### Information Options

```bash
--show-tech-stack      # Display detected tech stack
--show-ml-status       # ML optimization status
--show-pipeline        # View pipeline configuration
--show-graph           # Dependency visualization
--init-config          # Run configuration wizard
```

## Environment Variables

Override configuration with environment variables:

```bash
# Project configuration
export WORKFLOW_PROJECT_NAME="My Project"
export WORKFLOW_PROJECT_KIND="nodejs_api"
export WORKFLOW_PRIMARY_LANGUAGE="javascript"

# Workflow behavior
export WORKFLOW_SMART_EXECUTION=true
export WORKFLOW_PARALLEL_STEPS=true
export WORKFLOW_AUTO_COMMIT=false

# AI configuration
export WORKFLOW_AI_PROVIDER="github_copilot"
export WORKFLOW_AI_MODEL="gpt-4"
export WORKFLOW_AI_CACHE_TTL=86400

# Testing
export WORKFLOW_TEST_COMMAND="npm test"
export WORKFLOW_COVERAGE_THRESHOLD=80

# Paths
export WORKFLOW_ROOT=".workflow"
export WORKFLOW_LOGS_DIR="logs"
```

## Configuration Examples

### Minimal Configuration

```yaml
# .workflow-config.yaml
project:
  name: "My Project"
  kind: "nodejs_api"

tech_stack:
  primary_language: "javascript"
  test_framework: "jest"
```

### Documentation-Only Project

```yaml
# .workflow-config.yaml
project:
  name: "Project Documentation"
  kind: "documentation"

structure:
  docs_dirs:
    - "docs"
    - "documentation"

steps:
  enabled:
    - "documentation_updates"
    - "consistency_analysis"
    - "markdown_linting"
  
  disabled:
    - "test_review"
    - "test_generation"
    - "test_execution"
    - "code_quality_validation"
```

### Python API Project

```yaml
# .workflow-config.yaml
project:
  name: "Python REST API"
  kind: "python_api"

tech_stack:
  primary_language: "python"
  build_system: "pip"
  test_framework: "pytest"
  linter: "pylint"
  formatter: "black"

structure:
  source_dirs: ["src", "api"]
  test_dirs: ["tests"]

testing:
  test_command: "pytest"
  coverage_command: "pytest --cov"
  coverage_threshold: 90

workflow:
  smart_execution: true
  parallel_steps: true
  auto_commit: true
```

### Shell Automation Project

```yaml
# .workflow-config.yaml
project:
  name: "Shell Scripts"
  kind: "shell_automation"

tech_stack:
  primary_language: "bash"
  linter: "shellcheck"
  test_framework: "bats"

structure:
  source_dirs: ["scripts", "bin"]
  test_dirs: ["tests"]

testing:
  test_command: "bats tests/"

workflow:
  smart_execution: true
```

### React SPA Project

```yaml
# .workflow-config.yaml
project:
  name: "React App"
  kind: "react_spa"

tech_stack:
  primary_language: "typescript"
  secondary_languages: ["javascript"]
  build_system: "npm"
  test_framework: "jest"
  linter: "eslint"
  formatter: "prettier"
  package_manager: "npm"

structure:
  source_dirs: ["src"]
  test_dirs: ["src/__tests__"]

testing:
  test_command: "npm test"
  coverage_command: "npm run test:coverage"
  coverage_threshold: 85

workflow:
  smart_execution: true
  parallel_steps: true
  ml_optimize: true
```

## Configuration Wizard

Run the interactive configuration wizard:

```bash
cd /path/to/your/project
/path/to/ai_workflow/src/workflow/execute_tests_docs_workflow.sh --init-config
```

The wizard will:
1. Detect project type
2. Detect tech stack
3. Identify source and test directories
4. Configure testing options
5. Set workflow preferences
6. Generate `.workflow-config.yaml`

## Configuration Validation

Validate your configuration:

```bash
# Dry-run shows configuration validation
./execute_tests_docs_workflow.sh --dry-run

# View detected tech stack
./execute_tests_docs_workflow.sh --show-tech-stack

# Check specific configuration step
./execute_tests_docs_workflow.sh --steps config_validation
```

## Advanced Configuration

### Custom AI Personas

Override AI persona behavior:

```yaml
ai:
  personas:
    documentation_specialist:
      temperature: 0.5
      max_tokens: 2048
      system_prompt: "Custom prompt here"
    
    test_engineer:
      temperature: 0.7
      max_tokens: 4096
```

### Custom Step Order

Override default step execution order:

```yaml
steps:
  custom_order:
    - "pre_analysis"
    - "documentation_updates"
    - "test_review"
    - "test_generation"
    - "consistency_analysis"
    - "test_execution"
    - "git_finalization"
```

### Conditional Step Execution

Enable steps based on conditions:

```yaml
steps:
  conditional:
    ux_analysis:
      enabled_for:
        - "react_spa"
        - "vue_spa"
        - "client_spa"
    
    deployment_gate:
      enabled_when:
        - branch: "main"
        - coverage: ">= 80"
```

## Configuration File Locations

Configuration files are searched in this order:

1. `./.workflow-config.yaml` (project root)
2. `./.workflow/config.yaml` (workflow directory)
3. `~/.workflow/config.yaml` (user home)
4. `~/.config/workflow/config.yaml` (XDG config)

## Troubleshooting Configuration

### View Current Configuration

```bash
# Show tech stack and detected config
./execute_tests_docs_workflow.sh --show-tech-stack --verbose

# Dry-run shows full configuration
./execute_tests_docs_workflow.sh --dry-run
```

### Common Issues

**1. Configuration not loaded**
```bash
# Check file location
ls -la .workflow-config.yaml

# Validate YAML syntax
yamllint .workflow-config.yaml
```

**2. Project kind not detected**
```bash
# Manually specify in config
project:
  kind: "nodejs_api"

# Or use command-line
./execute_tests_docs_workflow.sh --project-kind nodejs_api
```

**3. Test command fails**
```bash
# Verify test command works
npm test

# Update in config
testing:
  test_command: "npm run test:unit"
```

## See Also

- **Getting Started**: `docs/GETTING_STARTED.md`
- **User Guide**: `docs/user-guide/`
- **Project Reference**: `docs/PROJECT_REFERENCE.md`
- **Troubleshooting**: `docs/user-guide/troubleshooting.md`

---

**Version**: 4.0.0  
**Last Updated**: 2026-02-08  
**License**: See LICENSE file
